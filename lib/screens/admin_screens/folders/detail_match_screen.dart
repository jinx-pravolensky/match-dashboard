import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/admin_screens/folders/share_match_screen.dart';
import 'package:ns3_project/service/api_config.dart';

class DetailMatchScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const DetailMatchScreen({super.key, required this.matchData});

  @override
  State<DetailMatchScreen> createState() => _DetailMatchScreenState();
}

class _DetailMatchScreenState extends State<DetailMatchScreen> {
  bool isDeleting = false;

  String _getRealCreatorName() {
    final adminData = widget.matchData['adminId'];
    if (adminData != null && adminData is Map) {
      return adminData['name'] ?? "Admin Perbakin";
    }

    return "Admin Perbakin";
  }

  Future<void> _hapusDataMatch() async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: 'HAPUS PERMANEN?',
      desc:
          'Yakin ingin menghapus ${widget.matchData['title']}? Semua data di dalamnya akan terhapus permanen!',
      btnCancelOnPress: () {},
      btnCancelText: 'Batalkan',
      btnCancelColor: goldenColor,
      btnOkOnPress: () async {
        setState(() => isDeleting = true);
        try {
          final url = Uri.parse(
            '${ApiConfig.baseUrl}/match/${widget.matchData['_id']}',
          );
          final response = await http.delete(url);

          setState(() => isDeleting = false);

          if (response.statusCode == 200) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.scale,
              title: 'BERHASIL HAPUS',
              desc: 'Data pertandingan telah dihapus!',
              btnOkColor: const Color(0xFFD32F2F),
              btnOkText: 'OK',
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              btnOkOnPress: () {
                Navigator.pop(context, true);
              },
            ).show();
          }
        } catch (e) {
          setState(() => isDeleting = false);
          print("Error Hapus: $e");
        }
      },
      btnOkText: 'Ya, Hapus',
      btnOkColor: const Color(0xFFD32F2F),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.matchData['title'] ?? 'Detail Match',
          style: text18PrimaryBold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.matchData['matchCustomId'] ?? 'ID_TIDAK_DIKETAHUI',
                    style: text16blackBold,
                  ),
                ),
                const SizedBox(height: 5),
                Divider(color: Colors.grey.shade300, thickness: 1.5),
                const SizedBox(height: 5),
                _buildReadOnlyField(
                  "Nama Pertandingan",
                  Icons.assignment_rounded,
                  widget.matchData['title'] ?? '-',
                ),
                const SizedBox(height: 10),
                _buildReadOnlyField(
                  "Lokasi Pertandingan",
                  Icons.travel_explore_rounded,
                  widget.matchData['location'] ?? '-',
                ),
                const SizedBox(height: 10),
                _buildReadOnlyField(
                  "Tanggal Dimulai",
                  Icons.article_rounded,
                  widget.matchData['date'] ?? '-',
                ),
                const SizedBox(height: 10),
                _buildReadOnlyField(
                  "Nama Penyelenggara",
                  Icons.assignment_add,
                  widget.matchData['organizer'] ?? '-',
                ),
                const SizedBox(height: 10),
                _buildReadOnlyField(
                  "Pembuat Pertandingan",
                  Icons.person_pin_rounded,
                  _getRealCreatorName(),
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade300, thickness: 1.5),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BagikanMatchScreen(
                                matchId: widget.matchData['_id'],
                              ),
                            ),
                          );
                        },
                        child: const Text("Bagikan", style: text16WhiteBold),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: isDeleting ? null : _hapusDataMatch,
                        child: isDeleting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Hapus Data", style: text16WhiteBold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text14greyBold),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: goldColor, size: 24),
              const SizedBox(width: 15),
              Expanded(child: Text(value, style: text14PrimaryBold)),
            ],
          ),
        ),
      ],
    );
  }
}
