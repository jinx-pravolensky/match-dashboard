import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/super_admin_screens/data_akun/components/component_detail_akun.dart';
import 'package:ns3_project/service/session_guard.dart';

class DetailDataAkunScreen extends StatelessWidget {
  const DetailDataAkunScreen({super.key});
  static String routeName = '/detail-data-akun';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final dynamic userData = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 30,
            color: primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Data Akun", style: text20PrimaryBold),
      ),
      body: DetailAkunBody(userData: userData),
    );
  }
}

class DetailAkunBody extends StatefulWidget {
  final dynamic userData;
  const DetailAkunBody({super.key, required this.userData});

  @override
  State<DetailAkunBody> createState() => _DetailAkunBodyState();
}

class _DetailAkunBodyState extends State<DetailAkunBody> {
  @override
  void initState() {
    super.initState();
    SessionGuard.checkUserStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          child: Image.asset(
            'assets/images/Admin-Pertandingan.png',
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        Expanded(child: ComponentDetailAkun(userData: widget.userData)),
      ],
    );
  }
}
