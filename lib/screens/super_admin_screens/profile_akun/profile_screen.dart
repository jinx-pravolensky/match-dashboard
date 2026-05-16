import 'package:flutter/material.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/service/session_guard.dart';
import 'package:ns3_project/screens/super_admin_screens/profile_akun/components/component_menu_profile.dart'
    show ComponentMenuAkun;

class ProfileSuperAdminScreen extends StatelessWidget {
  const ProfileSuperAdminScreen({super.key});
  static String routeName = '/profile-super-admin';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(
      backgroundColor: Colors.white,
      body: DataProfileBody(),
    );
  }
}

class DataProfileBody extends StatefulWidget {
  const DataProfileBody({super.key});

  @override
  State<DataProfileBody> createState() => _DataProfileBodyState();
}

class _DataProfileBodyState extends State<DataProfileBody> {
  @override
  void initState() {
    super.initState();
    SessionGuard.checkUserStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: HeadersApp(),
          ),
          Expanded(child: ComponentMenuAkun()),
        ],
      ),
    );
  }
}
