import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/service/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';

class ComponentAddAkun extends StatefulWidget {
  const ComponentAddAkun({super.key});

  @override
  State<ComponentAddAkun> createState() => _ComponentAddAkunState();
}

class _ComponentAddAkunState extends State<ComponentAddAkun> {
  final _formKey = GlobalKey<FormState>();
  final focusId = FocusNode();
  final focusNama = FocusNode();
  final focusEmail = FocusNode();
  final focusPassword = FocusNode();
  final focusPhone = FocusNode();

  TextEditingController customIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? selectedRole;
  String? selectedGender;

  @override
  void dispose() {
    focusId.dispose();
    focusNama.dispose();
    focusEmail.dispose();
    focusPassword.dispose();
    focusPhone.dispose();
    super.dispose();
  }

  Future<void> submitData() async {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == null || selectedGender == null) {
        _showErrorDialog(
          "Peringatan",
          "Peran dan Jenis Kelamin harus dipilih!",
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
      );

      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('userId');
      final url = Uri.parse('${ApiConfig.baseUrl}/admin/create-account');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'customId': customIdController.text.trim(),
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
            'role': selectedRole,
            'phoneNumber': phoneController.text.trim(),
            'gender': selectedGender,
            'createdBy': adminId,
          }),
        );

        Navigator.pop(context);

        if (response.statusCode == 201) {
          AwesomeDialog(
            context: context,
            title: 'BERHASIL',
            animType: AnimType.scale,
            btnOkColor: Colors.teal,
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            dialogType: DialogType.success,
            desc: 'Akun baru telah ditambahkan!',
            btnOkOnPress: () {
              setState(() {
                customIdController.clear();
                nameController.clear();
                emailController.clear();
                passwordController.clear();
                phoneController.clear();
                selectedRole = null;
                selectedGender = null;
              });
            },
          ).show();
        } else {
          final errorData = jsonDecode(response.body);
          _showErrorDialog(
            'GAGAL',
            errorData['message'] ?? "Gagal tambah akun",
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
      animType: AnimType.scale,
      title: title,
      desc: pesan,
      btnOkColor: Colors.red,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 2, color: Colors.grey),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                "Form Tambah Akun",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                margin: const EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _labelField('No. ID'),
                      const SizedBox(height: 5),
                      _buildTextField(
                        customIdController,
                        "Masukkan ID...",
                        Icons.assignment_rounded,
                        focusNode: focusId,
                        nextFocus: focusNama,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) => value == null || value.isEmpty
                            ? "ID tidak boleh kosong"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _labelField('Nama'),
                      const SizedBox(height: 5),
                      _buildTextField(
                        nameController,
                        "Masukkan Nama...",
                        Icons.assignment_ind_rounded,
                        focusNode: focusNama,
                        nextFocus: focusEmail,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                        ],
                        validator: (value) => value == null || value.isEmpty
                            ? "Nama tidak boleh kosong"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _labelField('Email'),
                      const SizedBox(height: 5),
                      _buildTextField(
                        emailController,
                        "Masukkan Email...",
                        Icons.email_rounded,
                        focusNode: focusEmail,
                        nextFocus: focusPassword,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email tidak boleh kosong";
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return "Format email tidak valid";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _labelField('Password'),
                      const SizedBox(height: 5),
                      _buildTextField(
                        passwordController,
                        "Masukkan Password...",
                        Icons.lock_person_rounded,
                        focusNode: focusPassword,
                        nextFocus: focusPhone,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password tidak boleh kosong";
                          }
                          if (value.length < 8) {
                            return "Password minimal 8 karakter";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _labelField('Peran'),
                      const SizedBox(height: 5),
                      _buildDropdown(
                        "Pilih Peran...",
                        ['superadmin', 'admin', 'juri'],
                        selectedRole,
                        (val) => setState(() => selectedRole = val),
                      ),
                      const SizedBox(height: 10),
                      _labelField('No. Handphone'),
                      const SizedBox(height: 5),
                      _buildTextField(
                        phoneController,
                        "Masukkan Nomor...",
                        Icons.phone_android_rounded,
                        focusNode: focusPhone,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Nomor HP tidak boleh kosong"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _labelField('Jenis Kelamin'),
                      const SizedBox(height: 5),
                      _buildDropdown(
                        "Pilih Jenis Kelamin...",
                        ['Laki-laki', 'Perempuan'],
                        selectedGender,
                        (val) => setState(() => selectedGender = val),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                height: 2,
                margin: const EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3366),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text("Submit", style: text16WhiteBold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputAction? textInputAction,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: text14PrimaryBold,
      onFieldSubmitted: (value) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          onFieldSubmitted?.call(value);
        }
      },
      decoration: InputDecoration(
        label: Text(hint),
        labelStyle: text14PrimaryBold,
        prefixIcon: Icon(icon, color: secondaryColor, size: 30),
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
      validator: validator,
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
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.assignment_add,
          color: secondaryColor,
          size: 30,
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
      hint: Text(hint, style: text14PrimaryBold),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _labelField(String lable) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Text(lable, style: text14greyBold),
    );
  }
}
