import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/admin_screens/folders/setup_ranting_screen.dart';

class DetailValidasiRantingScreen extends StatelessWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;

  const DetailValidasiRantingScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(rantingData['sub_kategori'], style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      rantingData['logo'],
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      rantingData['kategori_utama'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      rantingData['gambar_target'],
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildInfoRow(
                  Icons.assignment_rounded,
                  rantingData['sub_kategori'],
                  "",
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.center_focus_strong_rounded,
                  "Black Aiming Mark",
                  rantingData['bulls_eye'],
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.article_rounded,
                  "Format",
                  rantingData['format'].join(', '),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Notes :",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  rantingData['notes'],
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2C59),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetupRantingScreen(
                            matchId: matchId,
                            rantingData: rantingData,
                          ),
                        ),
                      );
                      print("Yakin milih: ${rantingData['sub_kategori']}");
                    },
                    child: const Text("Pilih", style: text16WhiteBold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: secondaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: text12blackBold
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
