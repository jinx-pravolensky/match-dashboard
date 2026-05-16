import 'package:flutter/material.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/service/session_guard.dart';

class AdminEventScreen extends StatelessWidget {
  const AdminEventScreen({super.key});
  static String routeName = '/admin-event';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(body: BodyAdminEventScreen());
  }
}

class BodyAdminEventScreen extends StatefulWidget {
  const BodyAdminEventScreen({super.key});

  @override
  State<BodyAdminEventScreen> createState() => _BodyAdminEventScreenState();
}

class _BodyAdminEventScreenState extends State<BodyAdminEventScreen> {
  @override
  void initState() {
    super.initState();
    SessionGuard.checkUserStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
