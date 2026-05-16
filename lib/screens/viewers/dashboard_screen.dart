import 'package:flutter/material.dart';
import 'package:ns3_project/components/size_config.dart';

class DashboardViewers extends StatelessWidget {
  const DashboardViewers({super.key});
  static String routeName = '/dashboard-viewers';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(body: DashboardBody());
  }
}

class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ListView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: <Widget>[
        Center(
          child: Image.asset(
            'assets/images/logo/Logo-app.png',
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
