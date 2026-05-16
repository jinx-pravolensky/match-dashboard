import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/admin_screens/folders/components/component_folder_ranting.dart';

class FolderRantingScreen extends StatelessWidget {
  final String matchId;
  final String matchTitle;

  const FolderRantingScreen({
    super.key, 
    required this.matchId, 
    required this.matchTitle
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(matchTitle, style: text20PrimaryBold), 
      ),
      body: SafeArea(
        child: ComponentFolderRanting(matchId: matchId),
      ),
    );
  }
}