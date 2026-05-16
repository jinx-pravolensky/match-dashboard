import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/super_admin_screens/data_akun/edit_data_akun_screen.dart';

class ComponentDetailAkun extends StatelessWidget {
  final dynamic userData;
  const ComponentDetailAkun({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    String customId = userData['customId'] ?? '-';
    String nama = userData['name'] ?? 'Tanpa Nama';
    String email = userData['email'] ?? 'Tanpa Email';
    String phone = userData['phoneNumber'] ?? '-';
    String gender = userData['gender'] ?? '-';

    String roleRaw = userData['role'] ?? 'viewer';
    String roleDisplay = "Viewer";
    if (roleRaw == 'superadmin') roleDisplay = "Super Admin";
    if (roleRaw == 'admin') roleDisplay = "Admin";
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(customId, style: text18PrimaryBold),
            const SizedBox(height: 5),
            const Divider(thickness: 1.5),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildInfoField("Nama", nama, Icons.assignment_ind_rounded),
                    _buildInfoField("Email", email, Icons.email_rounded),
                    _buildInfoField(
                      "Nomor Handphone",
                      phone,
                      Icons.tablet_android_rounded,
                    ),
                    _buildInfoField(
                      "Jenis Kelamin",
                      gender,
                      Icons.assignment_rounded,
                    ),
                    _buildInfoField(
                      "Peran",
                      roleDisplay,
                      Icons.article_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Divider(thickness: 1.5),
            const SizedBox(height: 5),
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditAkunScreen(userData: userData),
                        ),
                      );
                      if (result == true) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text("Edit Data", style: text14WhiteBold),
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
                            'Yakin ingin menghapus akun ${userData['name']}? Data yang dihapus tidak bisa dikembalikan!',
                        descAlign: TextAlign.center,
                        padding: const EdgeInsets.all(15),
                        dismissOnTouchOutside: false,
                        dismissOnBackKeyPress: false,
                        btnCancelOnPress: () {},
                        btnCancelColor: yellowColor,
                        btnCancelText: 'Batalkan',
                        btnOkColor: const Color(0xFFD32F2F),
                        btnOkText: 'Ya, Hapus',
                        btnOkOnPress: () async {
                          final url = Uri.parse(
                            '${ApiConfig.baseUrl}/admin/delete-account/${userData['_id']}',
                          );
                          try {
                            final response = await http.delete(url);
                            if (response.statusCode == 200) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.scale,
                                title: 'BERHASIL DIHAPUS',
                                desc:
                                    'Akun ${userData['name']} berhasil dihapus!',
                                dismissOnTouchOutside: false,
                                dismissOnBackKeyPress: false,
                                btnOkColor: Colors.teal,
                                btnOkText: 'OK',
                                btnOkOnPress: () {
                                  Navigator.pop(context, true);
                                },
                              ).show();
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                      ).show();
                    },
                    child: const Text("Hapus Akun", style: text14WhiteBold),
                  ),
                ),
              ],
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
              border: Border.all(color: Colors.black87, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: secondaryColor, size: 28),
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
