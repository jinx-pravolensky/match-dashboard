import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/auth/login_screen.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionGuard {
  static Future<void> checkUserStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) return;

    final url = Uri.parse('${ApiConfig.baseUrl}/auth/check-status/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 404) {
        if (!context.mounted) return;
        await prefs.clear();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          headerAnimationLoop: false,
          title: 'AKUN DIHAPUS',
          desc:
              'Maaf, Akun Anda sudah dihapus Admin! Silahkan Masuk Akun lain.',
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnOkText: 'OK',
          btnOkColor: Colors.red,
          btnOkOnPress: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginScreen.routeName,
              (route) => false,
            );
          },
        ).show();
      }
    } catch (e) {
      print(e);
    }
  }
}
