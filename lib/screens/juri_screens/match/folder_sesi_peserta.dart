import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/juri_screens/match/components/component_folder_sesi.dart';

class FolderSesiScreen extends StatelessWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;
  final Map<String, dynamic> pesertaData;

  const FolderSesiScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
    required this.pesertaData,
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
        title: const Text("Sesi Kegiatan", style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: ComponentFolderSesi(
          matchId: matchId,
          rantingData: rantingData,
          pesertaData: pesertaData,
        ),
      ),
    );
  }
}
