import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/auth/login_screen.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/components/animation/navigator_route.dart';
import 'package:ns3_project/service/api_config.dart';

class ComponentFormRegister extends StatefulWidget {
  const ComponentFormRegister({super.key});

  @override
  State<ComponentFormRegister> createState() => _ComponentFormRegisterState();
}

class _ComponentFormRegisterState extends State<ComponentFormRegister> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureText = true;
  bool _confirmObscureText = true;

  Future<void> prosesRegister() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
          }),
        );
        Navigator.pop(context);
        if (response.statusCode == 201) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'DAFTAR BERHASIL',
            desc: 'Akun berhasil terdaftar! Masuk Akun',
            btnOkText: 'LOGIN SEKARANG',
            btnOkColor: Colors.teal,
            btnOkOnPress: () {
              Navigator.pushReplacement(
                context,
                navigatorRoute(const LoginScreen()),
              );
            },
          ).show();
        } else {
          final errorData = jsonDecode(response.body);
          _showErrorDialog(
            'DAFTAR GAGAL',
            errorData['message'] ?? "Pendaftaran gagal!",
          );
        }
      } catch (e) {
        Navigator.pop(context);
        _showErrorDialog('KONEKSI GAGAL', "Gagal terhubung ke server!");
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
      btnOkText: 'OK',
      btnOkColor: Colors.red,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            autofocus: false,
            showCursor: true,
            cursorColor: Colors.teal,
            textAlign: TextAlign.start,
            controller: nameController,
            scrollPhysics: const ScrollPhysics(),
            textInputAction: TextInputAction.next,
            style: text14PrimaryBold,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              label: const Text('Masukkan Nama'),
              labelStyle: text14PrimaryBold,
              prefixIcon: const Icon(
                size: 32,
                color: primaryColor,
                Icons.assignment_ind_rounded,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.teal, width: 3.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 3.0,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            autofocus: false,
            showCursor: true,
            cursorColor: Colors.teal,
            textAlign: TextAlign.start,
            controller: emailController,
            scrollPhysics: const ScrollPhysics(),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
            ],
            style: text14PrimaryBold,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              label: const Text('Masukkan Email'),
              labelStyle: text14PrimaryBold,
              prefixIcon: const Icon(
                size: 30,
                color: primaryColor,
                Icons.mail_rounded,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.teal, width: 3.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 3.0,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }

              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

              if (!emailRegex.hasMatch(value)) {
                return 'Format email tidak valid';
              }

              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            autofocus: false,
            showCursor: true,
            autocorrect: false,
            enableSuggestions: false,
            cursorColor: Colors.teal,
            textAlign: TextAlign.start,
            obscureText: _obscureText,
            controller: passwordController,
            scrollPhysics: const ScrollPhysics(),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            style: text14PrimaryBold,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              label: const Text('Masukkan Password'),
              labelStyle: text14PrimaryBold,
              prefixIcon: const Icon(
                size: 30,
                color: primaryColor,
                Icons.lock_person_rounded,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.teal, width: 3.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 3.0,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 8) {
                return 'Password minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            autofocus: false,
            showCursor: true,
            autocorrect: false,
            enableSuggestions: false,
            cursorColor: Colors.teal,
            textAlign: TextAlign.start,
            controller: confirmPasswordController,
            obscureText: _confirmObscureText,
            scrollPhysics: const ScrollPhysics(),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            style: text14PrimaryBold,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              label: const Text('Konfirmasi Password'),
              labelStyle: text14PrimaryBold,
              prefixIcon: const Icon(
                size: 30,
                color: primaryColor,
                Icons.lock_rounded,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmObscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _confirmObscureText = !_confirmObscureText;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.teal, width: 3.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 3.0,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password tidak boleh kosong';
              }
              if (value != passwordController.text) {
                return 'Password tidak sama';
              }
              return null;
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextButton(
              onPressed: () => {prosesRegister()},
              child: Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "Submit",
                  textAlign: TextAlign.center,
                  style: text16WhiteBold,
                ),
              ),
            ),
          ),
          Container(
            margin: null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sudah memiliki akun? ", style: text12PrimaryBold),
                GestureDetector(
                  onTap: () => {
                    Navigator.pushReplacement(
                      context,
                      navigatorRoute(const LoginScreen()),
                    ),
                  },
                  child: const Text("Masuk Akun", style: text12TealBold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
