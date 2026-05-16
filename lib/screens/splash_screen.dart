import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/auth/login_screen.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/animation/navigator_route.dart';
import 'package:ns3_project/screens/admin_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/juri_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/viewers/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static String routeName = "/splash-screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _controller.forward();
    _checkSessionAndNavigate();
  }
  Future<void> _checkSessionAndNavigate() async {
    // 1. Kasih waktu 2 detik biar animasi logo lu selesai muter
    await Future.delayed(const Duration(seconds: 2));
    // 2. Cek memori HP (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final String? savedUserId = prefs.getString('userId');
    final String? savedRole = prefs.getString('role');
    if (!mounted) return; // Mencegah error kalau widget udah keburu ilang
    // 3. Seleksi Jalur
    if (savedUserId != null && savedRole != null) {
      // ADA SESI! Langsung tendang ke Dashboard sesuai jabatannya
      if (savedRole == 'superadmin') {
        Navigator.pushReplacementNamed(context, DashboardSuperAdmin.routeName);
      } else if (savedRole == 'admin') {
        Navigator.pushReplacementNamed(context, DashboardAdminPertandingan.routeName);
      } else if (savedRole == 'juri') {
        Navigator.pushReplacementNamed(context, DashboardJuri.routeName);
      } else if (savedRole == 'viewer') {
        Navigator.pushReplacementNamed(context, DashboardViewers.routeName);
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard-atlet');
      }
    } else {
      // GAK ADA SESI / BARU LOG OUT! Arahin ke Login pakai animasi lu
      Navigator.pushReplacement(
        context,
        navigatorRoute(const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              alignment: Alignment.center,
              width: getProportionateScreenWidth(250),
              height: getProportionateScreenWidth(250),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(
                getProportionateScreenWidth(8),
              ),
              child: Image.asset(
                'assets/images/logo/Logo-app.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}