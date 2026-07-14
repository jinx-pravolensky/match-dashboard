import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/auth/login_screen.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComponenDetailAkunViewer extends StatefulWidget {
  const ComponenDetailAkunViewer({super.key});

  @override
  State<ComponenDetailAkunViewer> createState() =>
      _ComponenDetailAkunViewerState();
}

class _ComponenDetailAkunViewerState extends State<ComponenDetailAkunViewer> {
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

    String nama = userData!['name'] ?? 'Tanpa Nama';
    String email = userData!['email'] ?? 'Tanpa Email';
    String phoneRaw = userData!['phoneNumber']?.toString() ?? '';
    String phone = phoneRaw.trim().isEmpty ? 'Belum Ditambahkan' : phoneRaw;
    String genderRaw = userData!['gender']?.toString() ?? '';
    String gender = genderRaw.trim().isEmpty ? 'Belum Diatur' : genderRaw;

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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildInfoField(
                      "Nama Lengkap",
                      nama,
                      Icons.assignment_rounded,
                    ),
                    _buildInfoField("Email", email, Icons.email_rounded),
                    _buildInfoField(
                      "Nomor HP",
                      phone,
                      Icons.tablet_mac_rounded,
                    ),
                    _buildInfoField(
                      "Jenis Kelamin",
                      gender,
                      Icons.article_rounded,
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => {},
                            child: const Text(
                              "Edit Data",
                              style: text14WhiteBold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.question,
                                title: 'Hapus Akun?',
                                desc:
                                    'Anda yakin ingin menghapus Akun Anda? Akun yang dihapus tidak bisa dikembalikan!',
                                descAlign: TextAlign.center,
                                padding: const EdgeInsets.all(15),
                                dismissOnTouchOutside: false,
                                dismissOnBackKeyPress: false,
                                btnCancelOnPress: () {},
                                btnCancelColor: const Color(0xFFDDA15E),
                                btnCancelText: 'Batalkan',
                                btnOkColor: const Color(0xFFD32F2F),
                                btnOkText: 'Ya, Hapus',
                                btnOkOnPress: () async {
                                  final userId = userData!['_id'];
                                  final url = Uri.parse(
                                    '${ApiConfig.baseUrl}/auth/delete-account/$userId',
                                  );
                                  try {
                                    final response = await http.delete(url);
                                    if (response.statusCode == 200) {
                                      if (!mounted) return;
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.success,
                                        animType: AnimType.scale,
                                        title: 'BERHASIL DIHAPUS',
                                        desc: 'Berhasil menghapus Akun!',
                                        dismissOnTouchOutside: false,
                                        dismissOnBackKeyPress: false,
                                        btnOkColor: Colors.teal,
                                        btnOkText: 'OK',
                                        btnOkOnPress: () async {
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          await prefs.clear();

                                          if (!mounted) return;
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            LoginScreen.routeName,
                                            (route) => false,
                                          );
                                        },
                                      ).show();
                                    } else {
                                      print(
                                        "Gagal menghapus: ${response.body}",
                                      );
                                    }
                                  } catch (e) {
                                    print("Error saat menghapus akun: $e");
                                  }
                                },
                              ).show();
                            },
                            child: const Text(
                              "Hapus Akun",
                              style: text14WhiteBold,
                            ),
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.only(bottom: 10),
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
                const Icon(Icons.circle, color: Colors.transparent, size: 0),
                Icon(icon, color: secondaryColor, size: 25),
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
