import 'package:flutter/material.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/super_admin_screens/data_akun/components/component_data_akun.dart'
    show ComponentDataAkun;
import 'package:ns3_project/service/session_guard.dart';

class DataAkunScreen extends StatelessWidget {
  const DataAkunScreen({super.key});
  static String routeName = '/daftar-data-akun';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(body: SafeArea(child: DataAkunBody()));
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
    return Column(children: const [Expanded(child: ComponentDataAkun())]);
  }
}
