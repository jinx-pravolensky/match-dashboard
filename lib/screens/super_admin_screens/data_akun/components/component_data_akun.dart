import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/screens/super_admin_screens/data_akun/detail_akun_screen.dart';

class ComponentDataAkun extends StatefulWidget {
  const ComponentDataAkun({super.key});

  @override
  State<ComponentDataAkun> createState() => _ComponentDataAkunState();
}

class _ComponentDataAkunState extends State<ComponentDataAkun> {
  List<dynamic> listAkun = [];
  List<dynamic> filteredAkun = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataAkun();
  }

  Future<void> fetchDataAkun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('userId');

      if (adminId == null) {
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/admin/users/$adminId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> fetchedData = jsonDecode(response.body);
        fetchedData.sort((a, b) {
          int getPriority(String role) {
            if (role == 'superadmin') return 1;
            if (role == 'admin') return 2;
            if (role == 'juri') return 3;
            return 4;
          }

          return getPriority(
            a['role'] ?? '',
          ).compareTo(getPriority(b['role'] ?? ''));
        });

        setState(() {
          listAkun = fetchedData;
          filteredAkun = fetchedData;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = listAkun;
    } else {
      results = listAkun.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        return name.contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredAkun = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (listAkun.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDataState();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Belum ada Daftar Akun,\nDaftar Akun akan muncul\nsetelah Akun dibuat.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildDataState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadersApp(),
              const SizedBox(height: 15),
              const Text(
                "Daftar Akun",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF0F2C59),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        onChanged: (value) => _runFilter(value),
                        decoration: const InputDecoration(
                          hintText: 'Cari Nama Akun...',
                          hintStyle: text14greyBold,
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.library_books_outlined,
                        color: primaryColor,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredAkun.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Whooops!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Nama Akun Tidak Ditemukan!",
                        style: text16PrimaryBold,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredAkun.length,
                  itemBuilder: (context, index) {
                    final user = filteredAkun[index];
                    return _buildUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(dynamic user) {
    String nama = user['name'] ?? 'Tanpa Nama';
    String email = user['email'] ?? 'Tanpa Email';
    String roleRaw = user['role'] ?? 'viewer';
    String roleDisplay = "Viewer";
    if (roleRaw == 'superadmin') roleDisplay = "Super Admin";
    if (roleRaw == 'admin') roleDisplay = "Admin";
    if (roleRaw == 'juri') roleDisplay = "Juri";
    Color roleColor;
    Color bgColor;
    if (roleRaw == 'superadmin') {
      roleColor = redBorder;
      bgColor = redIsi;
    } else if (roleRaw == 'admin') {
      roleColor = blueBorder;
      bgColor = blueIsi;
    } else {
      roleColor = greenBorder;
      bgColor = greenIsi;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF0F2C59), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              DetailDataAkunScreen.routeName,
              arguments: user,
            );

            if (result == true) {
              fetchDataAkun();
            }
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 3,
          ),
          leading: CircleAvatar(
            backgroundColor: bgColor,
            child: Icon(
              Icons.account_circle_outlined,
              color: roleColor,
              size: 28,
            ),
          ),
          title: Text(
            nama,
            style: text14PrimaryBold,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            email,
            style: text12greyBold,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleColor, width: 1.5),
            ),
            child: Text(
              roleDisplay,
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
