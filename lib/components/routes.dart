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
import 'package:ns3_project/screens/viewers/folders/folder_ranting_screen.dart';
import 'package:ns3_project/screens/viewers/folders/folder_sesi_screen.dart';
import 'package:ns3_project/screens/viewers/folders/tambah_ranting_screen.dart';
import 'package:ns3_project/screens/viewers/profile_akun/detail_profile_screen.dart';
import 'package:ns3_project/screens/viewers/profile_akun/profile_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  RegisterScreen.routeName: (context) => const RegisterScreen(),

  // Super Admin Routes
  DashboardSuperAdmin.routeName: (context) => const DashboardSuperAdmin(),
  DataAkunScreen.routeName: (context) => const DataAkunScreen(),
  DetailDataAkunScreen.routeName: (context) => const DetailDataAkunScreen(),
  DetailProfileSuperAdmin.routeName: (context) =>
      const DetailProfileSuperAdmin(),
  TambahAkunScreen.routeName: (context) => const TambahAkunScreen(),
  ProfileSuperAdminScreen.routeName: (context) =>
      const ProfileSuperAdminScreen(),

  // Admin Pertandingan Routes
  DashboardAdminPertandingan.routeName: (context) =>
      const DashboardAdminPertandingan(),
  MatchScreen.routeName: (context) => const MatchScreen(),
  FoldersScreen.routeName: (context) => const FoldersScreen(),
  AdminEventScreen.routeName: (context) => const AdminEventScreen(),
  AkunAdminScreen.routeName: (context) => const AkunAdminScreen(),
  DetailProfileAdmin.routeName: (context) => const DetailProfileAdmin(),
  AddMatchScreen.routeName: (context) => const AkunAdminScreen(),

  // Juri Routes
  DashboardJuri.routeName: (context) => const DashboardJuri(),
  AkunJuriScreen.routeName: (context) => const AkunJuriScreen(),
  DetailProfileJuri.routeName: (context) => const DetailProfileJuri(),
  JuriMatchScreen.routeName: (context) => const JuriMatchScreen(),

  // Viewer Routes
  DashboardViewers.routeName: (context) => const DashboardViewers(),
  ProfileViewerScreen.routeName: (context) => const ProfileViewerScreen(),
  DetailProfileViewerScreen.routeName: (context) =>
      const DetailProfileViewerScreen(),
  ViewerDataRantingScreen.routeName: (context) =>
      const ViewerDataRantingScreen(),
  ViewerTambahRanting.routeName: (context) => const ViewerTambahRanting(),
  ViewerFolderSesiScreen.routeName: (context) => const ViewerTambahRanting(),
};
