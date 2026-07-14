import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/viewers/folders/components/component_data_sesi.dart';

class ViewerFolderSesiScreen extends StatelessWidget {
  final Map<String, dynamic> trainingData;
  const ViewerFolderSesiScreen({super.key, required this.trainingData});
  static String routeName = '/viewer-sesi-screen';

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
        title: const Text("Sesi Latihan", style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: ComponentFolderSesiViewer(trainingData: trainingData),
      ),
    );
  }
}
