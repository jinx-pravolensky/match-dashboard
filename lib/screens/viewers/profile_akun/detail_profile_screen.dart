import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/session_guard.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/viewers/profile_akun/components/component_detail_akun.dart'
    show ComponenDetailAkunViewer;

class DetailProfileViewerScreen extends StatelessWidget {
  const DetailProfileViewerScreen({super.key});
  static String routeName = '/detail-profile-viewer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryColor,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Profil Saya", style: text20PrimaryBold),
      ),
      body: const DetailProfileViewerBody(),
    );
  }
}

class DetailProfileViewerBody extends StatefulWidget {
  const DetailProfileViewerBody({super.key});

  @override
  State<DetailProfileViewerBody> createState() =>
      _DetailProfileViewerBodyState();
}

class _DetailProfileViewerBodyState extends State<DetailProfileViewerBody> {
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
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: Image.asset(
              'assets/images/Admin-Pertandingan.png',
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          const Expanded(child: ComponenDetailAkunViewer()),
        ],
      ),
    );
  }
}
