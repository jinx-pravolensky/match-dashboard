import 'package:flutter/material.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/headers.dart' show HeadersApp;
import 'package:ns3_project/screens/viewers/folders/components/component_data_ranting.dart'
    show ComponentDataRantingViewer;

class ViewerDataRantingScreen extends StatelessWidget {
  const ViewerDataRantingScreen({super.key});
  static String routeName = '/viewer-data-ranting';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: ViewerDataRantingBody(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
    );
  }
}

class ViewerDataRantingBody extends StatefulWidget {
  const ViewerDataRantingBody({super.key});

  @override
  State<ViewerDataRantingBody> createState() => _ViewerDataRantingBodyState();
}

class _ViewerDataRantingBodyState extends State<ViewerDataRantingBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: HeadersApp(),
          ),
          Expanded(child: ComponentDataRantingViewer()),
        ],
      ),
    );
  }
}
