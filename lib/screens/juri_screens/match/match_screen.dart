import 'package:flutter/material.dart';
import 'package:ns3_project/components/headers.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/juri_screens/match/components/component_folder_match.dart'
    show ComponentFolderDataMatch;
import 'package:ns3_project/service/session_guard.dart';

class JuriMatchScreen extends StatelessWidget {
  const JuriMatchScreen({super.key});
  static String routeName = '/juri-match-screen';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(body: MatchScreenBody());
  }
}

class MatchScreenBody extends StatefulWidget {
  const MatchScreenBody({super.key});

  @override
  State<MatchScreenBody> createState() => _MatchScreenBodyState();
}

class _MatchScreenBodyState extends State<MatchScreenBody> {
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
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const HeadersApp(),
          ),
          const Expanded(child: ComponentFolderDataMatch()),
        ],
      ),
    );
  }
}
