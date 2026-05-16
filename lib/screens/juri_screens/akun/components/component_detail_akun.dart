import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';

class ComponenDetailAkunJuri extends StatefulWidget {
  const ComponenDetailAkunJuri({super.key});

  @override
  State<ComponenDetailAkunJuri> createState() => _ComponenDetailAkunJuriState();
}

class _ComponenDetailAkunJuriState extends State<ComponenDetailAkunJuri> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return;
      final url = Uri.parse('${ApiConfig.baseUrl}/admin/user/$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (userData == null) {
      return const Center(
        child: Text("Gagal memuat data profil", style: text14PrimaryBold),
      );
    }

    String customId = userData!['customId'] ?? '-';
    String nama = userData!['name'] ?? 'Tanpa Nama';
    String email = userData!['email'] ?? 'Tanpa Email';
    String phone = userData!['phoneNumber'] ?? '-';
    String gender = userData!['gender'] ?? '-';

    String roleRaw = userData!['role'] ?? 'viewer';
    String roleDisplay = "Viewer";
    if (roleRaw == 'superadmin') roleDisplay = "Super Admin";
    if (roleRaw == 'admin') roleDisplay = "Admin Pertandingan";
    if (roleRaw == 'juri') roleDisplay = "Juri";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Text(customId, style: text16PrimaryBold),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildInfoField(
                      "Nama Lengkap",
                      nama,
                      Icons.perm_contact_calendar_rounded,
                    ),
                    _buildInfoField("Email", email, Icons.email_rounded),
                    _buildInfoField(
                      "Nomor HP",
                      phone,
                      Icons.phone_android_rounded,
                    ),
                    _buildInfoField("Jenis Kelamin", gender, Icons.wc_rounded),
                    _buildInfoField(
                      "Peran",
                      roleDisplay,
                      Icons.admin_panel_settings_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0F2C59), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: goldColor, size: 25),
                const SizedBox(width: 15),
                Expanded(child: Text(value, style: text14PrimaryBold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
