import 'package:flutter/material.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/admin_screens/akun/components/component_halaman_akun.dart';
import 'package:ns3_project/service/session_guard.dart';

class AkunAdminScreen extends StatelessWidget {
  const AkunAdminScreen({super.key});
  static String routeName = '/profile-admin';

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
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const HeadersApp(),
          ),
          const Expanded(child: ComponentHalamanAkun()),
        ],
      ),
    );
  }
}
