import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';

class EditAkunScreen extends StatefulWidget {
  final dynamic userData;
  const EditAkunScreen({super.key, required this.userData});
  static String routeName = '/edit-data-akun';

  @override
  State<EditAkunScreen> createState() => _EditAkunScreenState();
}

class _EditAkunScreenState extends State<EditAkunScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController customIdController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String? selectedGender;
  late String roleDisplay;

  @override
  void initState() {
    super.initState();
    customIdController = TextEditingController(
      text: widget.userData['customId'],
    );
    nameController = TextEditingController(text: widget.userData['name']);
    emailController = TextEditingController(text: widget.userData['email']);
    phoneController = TextEditingController(
      text: widget.userData['phoneNumber'],
    );
    selectedGender = widget.userData['gender'];

    String roleRaw = widget.userData['role'] ?? 'viewer';
    if (roleRaw == 'superadmin')
      roleDisplay = "Super Admin";
    else if (roleRaw == 'admin')
      roleDisplay = "Admin";
    else if (roleRaw == 'juri')
      roleDisplay = "Juri";
    else
      roleDisplay = "Viewer";
  }

  Future<void> updateData() async {
    if (_formKey.currentState!.validate()) {
      bool isChanged =
          customIdController.text.trim() != widget.userData['customId'] ||
          nameController.text.trim() != widget.userData['name'] ||
          emailController.text.trim() != widget.userData['email'] ||
          phoneController.text.trim() != widget.userData['phoneNumber'] ||
          selectedGender != widget.userData['gender'];

      if (!isChanged) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          title: 'Data Kosong',
          desc:
              'Tidak ada Data yang di Edit, apakah ingin membatalkan Edit Data?',
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnCancelText: 'Batalkan',
          btnCancelColor: const Color(0xFFD32F2F),
          btnCancelOnPress: () {
            Navigator.pop(context);
          },
          btnOkText: 'Lanjutkan Edit',
          btnOkColor: const Color(0xFF0F2C59),
          btnOkOnPress: () {},
        ).show();
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
      );

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/admin/update-account/${widget.userData['_id']}',
      );

      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'customId': customIdController.text.trim(),
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phoneNumber': phoneController.text.trim(),
            'gender': selectedGender,
          }),
        );

        Navigator.pop(context);

        if (response.statusCode == 200) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'BERHASIL',
            desc: 'Data ${nameController.text} berhasil diperbarui!',
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            btnOkColor: Colors.teal,
            btnOkOnPress: () {
              Navigator.pop(context, true);
            },
          ).show();
        } else {
          final errorData = jsonDecode(response.body);
          _showErrorDialog(
            'GAGAL',
            errorData['message'] ?? "Gagal update data",
          );
        }
      } catch (e) {
        Navigator.pop(context);
        _showErrorDialog('KONEKSI GAGAL', "Gagal terhubung ke server.");
      }
    }
  }

  void _showErrorDialog(String title, String pesan) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: title,
      desc: pesan,
      btnOkColor: Colors.red,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Edit Data Akun", style: text18PrimaryBold),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryColor,
            size: 25,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReadOnlyField(
                          "Peran Akun (Tidak dapat diubah)",
                          roleDisplay,
                          Icons.lock_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          customIdController,
                          "Masukkan ID...",
                          Icons.badge_outlined,
                          "ID tidak boleh kosong",
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          nameController,
                          "Masukkan Nama...",
                          Icons.person_outline,
                          "Nama tidak boleh kosong",
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          emailController,
                          "Masukkan Email...",
                          Icons.mail_outline,
                          "Email tidak boleh kosong",
                          isEmail: true,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          phoneController,
                          "Masukkan No. Handphone...",
                          Icons.phone_android,
                          "No. HP tidak boleh kosong",
                          isPhone: true,
                        ),
                        const SizedBox(height: 15),
                        _buildDropdown(
                          "Pilih Jenis Kelamin...",
                          ['Laki-laki', 'Perempuan'],
                          selectedGender,
                          (val) => setState(() => selectedGender = val),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F2C59),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: updateData,
                            child: const Text(
                              "Simpan Perubahan",
                              style: text16WhiteBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    String errorMsg, {
    bool isPhone = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone
          ? TextInputType.phone
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      style: text14PrimaryBold,
      inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: text14PrimaryBold,
        prefixIcon: Icon(icon, color: primaryColor, size: 28),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal, width: 3.0),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? errorMsg : null,
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey, size: 28),
              const SizedBox(width: 15),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      style: text14PrimaryBold,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: const Icon(
          Icons.list_alt_outlined,
          color: primaryColor,
          size: 28,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal, width: 3.0),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.black87)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
