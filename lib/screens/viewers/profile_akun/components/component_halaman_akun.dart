import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/auth/login_screen.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/screens/viewers/profile_akun/detail_profile_screen.dart';

class ComponentHalamanAkunViewer extends StatefulWidget {
  const ComponentHalamanAkunViewer({super.key});

  @override
  State<ComponentHalamanAkunViewer> createState() =>
      _ComponentHalamanAkunViewerState();
}

class _ComponentHalamanAkunViewerState
    extends State<ComponentHalamanAkunViewer> {
  String userName = "Pengguna Aplikasi";
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
        print("Gagal narik data profil: $e");
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
      btnOkColor: const Color(0xFFD32F2F),
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
            Text(userName, style: text14Primary),
            Text(userEmail, style: text16PrimaryBold),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.assignment_rounded, "Profil Saya", () {
                    Navigator.pushNamed(
                      context,
                      DetailProfileViewerScreen.routeName,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2C59),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFDDA15E), size: 30),
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
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFDDA15E),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
