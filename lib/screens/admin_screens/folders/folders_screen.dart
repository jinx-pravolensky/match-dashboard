import 'package:flutter/material.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/admin_screens/folders/components/component_data_folders.dart';
import 'package:ns3_project/service/session_guard.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});
  static String routeName = '/folders-admin';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(
      body: BodyFoldersScreen(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
    );
  }
}

class BodyFoldersScreen extends StatefulWidget {
  const BodyFoldersScreen({super.key});

  @override
  State<BodyFoldersScreen> createState() => _BodyFoldersScreenState();
}

class _BodyFoldersScreenState extends State<BodyFoldersScreen> {
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
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: HeadersApp(),
          ),
          Expanded(child: ComponentDataFolders()),
        ],
      ),
    );
  }
}
