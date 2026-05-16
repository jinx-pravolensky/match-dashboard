import 'package:flutter/material.dart';
import 'package:ns3_project/auth/login_screen.dart';
import 'package:ns3_project/auth/register_screen.dart';
import 'package:ns3_project/screens/admin_screens/akun/akun_screen.dart';
import 'package:ns3_project/screens/admin_screens/akun/detail_profile_screen.dart';
import 'package:ns3_project/screens/admin_screens/event/event_screen.dart';
import 'package:ns3_project/screens/admin_screens/folders/folders_screen.dart';
import 'package:ns3_project/screens/admin_screens/match/add_match_screen.dart';
import 'package:ns3_project/screens/admin_screens/match/match_screen.dart';
import 'package:ns3_project/screens/juri_screens/akun/akun_screens.dart';
import 'package:ns3_project/screens/juri_screens/akun/detail_profile_screen.dart';
import 'package:ns3_project/screens/juri_screens/match/match_screen.dart';
import 'package:ns3_project/screens/splash_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/data_akun/detail_akun_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/profile_akun/detail_profile_screen.dart';
import 'package:ns3_project/screens/viewers/dashboard_screen.dart';
import 'package:ns3_project/screens/juri_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/admin_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/dashboard_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/add_akun/add_akun_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/data_akun/data_akun_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/profile_akun/profile_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  RegisterScreen.routeName: (context) => RegisterScreen(),

  // Super Admin Routes
  DashboardSuperAdmin.routeName: (context) => DashboardSuperAdmin(),
  DataAkunScreen.routeName: (context) => const DataAkunScreen(),
  DetailDataAkunScreen.routeName: (context) => DetailDataAkunScreen(),
  DetailProfileSuperAdmin.routeName: (context) => DetailProfileSuperAdmin(),
  TambahAkunScreen.routeName: (context) => const TambahAkunScreen(),
  ProfileSuperAdminScreen.routeName: (context) => const ProfileSuperAdminScreen(),

  // Admin Pertandingan Routes
  DashboardAdminPertandingan.routeName: (context) => DashboardAdminPertandingan(),
  MatchScreen.routeName: (context) => MatchScreen(),
  FoldersScreen.routeName: (context) => FoldersScreen(),
  AdminEventScreen.routeName: (context) => AdminEventScreen(),
  AkunAdminScreen.routeName: (context) => AkunAdminScreen(),
  DetailProfileAdmin.routeName: (context) => DetailProfileAdmin(),
  AddMatchScreen.routeName: (context) => AkunAdminScreen(),

  // Juri Routes
  DashboardJuri.routeName: (context) => DashboardJuri(),
  AkunJuriScreen.routeName: (context) => AkunJuriScreen(),
  DetailProfileJuri.routeName: (context) => DetailProfileJuri(),
  JuriMatchScreen.routeName: (context) => JuriMatchScreen(),

  DashboardViewers.routeName: (context) => DashboardViewers(),
};
