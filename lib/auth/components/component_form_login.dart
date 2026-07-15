import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/service/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/auth/register_screen.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/components/animation/navigator_route.dart';
import 'package:ns3_project/screens/admin_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/juri_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/viewers/dashboard_screen.dart';

class ComponentFormLogin extends StatefulWidget {
  const ComponentFormLogin({super.key});

  @override
  State<ComponentFormLogin> createState() => _ComponentFormLoginState();
}

class _ComponentFormLoginState extends State<ComponentFormLogin> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  Future<void> prosesLogin() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.teal)),
      );

      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
          }),
        );

        Navigator.pop(context);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          String role = data['user']['role'];
          String token = data['token'];

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('userId', data['user']['id'].toString());
          await prefs.setString('role', role);
          await prefs.setString('token', token);

          print("✅ LOGIN SUKSES! ID DISIMPAN KE HP: ${data['user']['id']}");

          _showSuccessDialog(role);
        } else {
          final errorData = jsonDecode(response.body);

          _showErrorDialog(
            'LOGIN GAGAL',
            errorData['message'] ?? "Login Gagal",
          );
        }
      } catch (e) {
        Navigator.pop(context);

        _showErrorDialog(
          'KONEKSI GAGAL',
          "Gagal terhubung ke server. Cek internet \natau Koneksi Server!",
        );
      }
    }
  }

  void _showSuccessDialog(String role) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'LOGIN BERHASIL',
      desc: 'Selamat datang kembali!',
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      btnOkText: 'MASUK',
      btnOkColor: Colors.teal,
      btnOkOnPress: () {
        if (role == 'superadmin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            DashboardSuperAdmin.routeName,
            (route) => false,
          );
        } else if (role == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            DashboardAdminPertandingan.routeName,
            (route) => false,
          );
        } else if (role == 'juri') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            DashboardJuri.routeName,
            (route) => false,
          );
        } else if (role == 'viewer') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            DashboardViewers.routeName,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard-atlet',
            (route) => false,
          );
        }
      },
    ).show();
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
            controller: emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.teal,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
            ],
            style: text14PrimaryBold,
            decoration: InputDecoration(
              label: const Text('Masukkan Email'),
              labelStyle: text14PrimaryBold,
              prefixIcon: const Icon(
                Icons.mail_rounded,
                size: 30,
                color: primaryColor,
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
                borderSide: const BorderSide(color: Colors.teal, width: 3),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Email tidak boleh kosong';

              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

              if (!emailRegex.hasMatch(value))
                return 'Format email tidak valid';

              return null;
            },
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: passwordController,
            obscureText: _obscureText,
            textInputAction: TextInputAction.done,
            cursorColor: Colors.teal,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            style: text14PrimaryBold,
            decoration: InputDecoration(
              label: const Text('Masukkan Password'),
              labelStyle: text14PrimaryBold,
              prefixIcon: const Icon(
                Icons.lock_person_rounded,
                size: 30,
                color: primaryColor,
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
                borderSide: const BorderSide(color: Colors.teal, width: 3),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Password tidak boleh kosong';

              if (value.length < 8) return 'Password minimal 8 karakter';

              return null;
            },
          ),

          Container(
            margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextButton(
              onPressed: () => prosesLogin(),
              child: Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "Masuk",
                  textAlign: TextAlign.center,
                  style: text16WhiteBold,
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Belum memiliki akun? ", style: text12PrimaryBold),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, navigatorRoute(RegisterScreen()));
                },
                child: const Text("Daftar Disini", style: text12TealBold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
