import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ns3_project/service/api_config.dart';

import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/screens/super_admin_screens/profile_akun/detail_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/auth/login_screen.dart';
import 'package:ns3_project/components/text_format.dart';

class ComponentMenuAkun extends StatefulWidget {
  const ComponentMenuAkun({super.key});

  @override
  State<ComponentMenuAkun> createState() => _ComponentMenuAkunState();
}

class _ComponentMenuAkunState extends State<ComponentMenuAkun> {
  String userName = "Super Admin";
  String userEmail = "Memuat...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    setState(() {
      userName = prefs.getString('userName') ?? "Memuat Nama...";
      userEmail = prefs.getString('userEmail') ?? "Memuat Email...";
    });

    if (userId != null) {
      try {
        final url = Uri.parse('${ApiConfig.baseUrl}/admin/user/$userId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            userName = data['name'] ?? userName;
            userEmail = data['email'] ?? userEmail;
          });

          prefs.setString('userName', data['name']);
          prefs.setString('userEmail', data['email']);
        }
      } catch (e) {
        print("Gagal mengambil data profil: $e");
      }
    }
  }

  void _prosesLogOut() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Ingin Keluar?',
      desc: 'Yakin ingin Keluar Akun ini?',
      btnCancelText: 'Batalkan',
      btnCancelColor: goldColor,
      btnCancelOnPress: () {},
      btnOkColor: redColor,
      btnOkText: 'Ya, Keluar',
      btnOkOnPress: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      },
    ).show();
  }

  void _showComingSoon() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      animType: AnimType.scale,
      title: 'Sedang Dikembangkan',
      desc: 'Maaf, Fitur ini masih dalam tahap pengembangan!',
      btnOkColor: const Color(0xFF0F2C59),
      btnOkText: 'Oke',
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(
                'assets/images/Admin-Pertandingan.png',
              ),
            ),

            const SizedBox(height: 20),

            Text(userName, style: text16Primary),
            Text(userEmail, style: text18PrimaryBold),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.perm_contact_cal_rounded,
                    "Profil Saya",
                    () {
                      Navigator.pushNamed(
                        context,
                        DetailProfileSuperAdmin.routeName,
                      );
                    },
                  ),

                  _buildMenuItem(
                    Icons.assignment_outlined,
                    "Pencarian Akun",
                    _showComingSoon,
                  ),

                  _buildMenuItem(
                    Icons.radar_rounded,
                    "Scan Target",
                    _showComingSoon,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _prosesLogOut,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text("Keluar Akun", style: text16WhiteBold),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2C59),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: goldColor, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),  
            const Icon(Icons.arrow_forward_ios, color: goldColor, size: 16),
          ],
        ),
      ),
    );
  }
}
