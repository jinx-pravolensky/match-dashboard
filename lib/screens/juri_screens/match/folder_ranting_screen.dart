import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/juri_screens/match/components/component_folder_ranting.dart';

class FolderRantingJuriScreen extends StatelessWidget {
  final String matchId;
  final String matchTitle;

  const FolderRantingJuriScreen({
    super.key,
    required this.matchId,
    required this.matchTitle,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(matchTitle, style: text20PrimaryBold),
      ),
      body: SafeArea(child: ComponentFolderRantingJuri(matchId: matchId)),
    );
  }
}
