import 'package:flutter/material.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/admin_screens/match/components/component_data_match.dart';
import 'package:ns3_project/service/session_guard.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});
  static String routeName = '/match-admin';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(
      backgroundColor: Colors.white,
      body: BodyMatchScreen(),
      resizeToAvoidBottomInset: false,
    );
  }
}

class BodyMatchScreen extends StatefulWidget {
  const BodyMatchScreen({super.key});

  @override
  State<BodyMatchScreen> createState() => _BodyMatchScreenState();
}

class _BodyMatchScreenState extends State<BodyMatchScreen> {
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
            child: HeadersApp(),
          ),
          Expanded(child: ComponentDataMatch()),
        ],
      ),
    );
  }
}
