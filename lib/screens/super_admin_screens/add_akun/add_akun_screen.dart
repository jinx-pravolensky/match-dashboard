import 'package:flutter/material.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/service/session_guard.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/super_admin_screens/add_akun/components/component_form_input.dart';

class TambahAkunScreen extends StatelessWidget {
  const TambahAkunScreen({super.key});
  static String routeName = '/tambah-data-akun';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: const DataAkunBody(),
      resizeToAvoidBottomInset: false,
    );
  }
}

class DataAkunBody extends StatefulWidget {
  const DataAkunBody({super.key});
  @override
  State<DataAkunBody> createState() => _DataAkunBodyState();
}

class _DataAkunBodyState extends State<DataAkunBody> {
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 10),
            child: HeadersApp(),
          ),
          Expanded(child: ComponentAddAkun()),
        ],
      ),
    );
  }
}
