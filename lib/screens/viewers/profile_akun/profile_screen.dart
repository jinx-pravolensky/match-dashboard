import 'package:flutter/material.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/service/session_guard.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/viewers/profile_akun/components/component_halaman_akun.dart'
    show ComponentHalamanAkunViewer;

class ProfileViewerScreen extends StatelessWidget {
  const ProfileViewerScreen({super.key});
  static String routeName = '/profile-viewer';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(
      backgroundColor: Colors.white,
      body: DataProfileViewerBody(),
    );
  }
}

class DataProfileViewerBody extends StatefulWidget {
  const DataProfileViewerBody({super.key});
  @override
  State<DataProfileViewerBody> createState() => _DataProfileViewerBodyState();
}

class _DataProfileViewerBodyState extends State<DataProfileViewerBody> {
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
          const Expanded(child: ComponentHalamanAkunViewer()),
        ],
      ),
    );
  }
}
