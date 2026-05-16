import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/service/session_guard.dart';
import 'package:ns3_project/screens/admin_screens/match/components/component_add_match.dart';

class AddMatchScreen extends StatelessWidget {
  const AddMatchScreen({super.key});
  static String routeName = '/add-match-admin';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Buat Pertandingan Baru", style: text20PrimaryBold),
      ),
      body: const BodyAddMatchScreen(),
    );
  }
}

class BodyAddMatchScreen extends StatefulWidget {
  const BodyAddMatchScreen({super.key});

  @override
  State<BodyAddMatchScreen> createState() => _BodyAddMatchScreenState();
}

class _BodyAddMatchScreenState extends State<BodyAddMatchScreen> {
  @override
  void initState() {
    super.initState();
    SessionGuard.checkUserStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const SafeArea(
      child: ComponentBuatMatch(),
    );
  }
}