import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';

class DetailPertandinganScreen extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const DetailPertandinganScreen({super.key, required this.matchData});

  String _getRealCreatorName() {
    final adminData = matchData['adminId'];
    if (adminData != null && adminData is Map) {
      return adminData['name'] ?? "Admin Perbakin";
    }
    return "Admin Perbakin";
  }
//
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
          matchData['title'] ?? 'Detail Match',
          style: text18PrimaryBold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    matchData['matchCustomId'] ?? 'ID_TIDAK_DIKETAHUI',
                    style: text16blackBold,
                  ),
                ),
                const SizedBox(height: 5),
                Divider(color: Colors.grey.shade300, thickness: 2),
                const SizedBox(height: 10),
                _buildReadOnlyField(
                  "Nama Pertandingan",
                  Icons.assignment_rounded,
                  matchData['title'] ?? '-',
                ),
                const SizedBox(height: 15),
                _buildReadOnlyField(
                  "Lokasi Pertandingan",
                  Icons.travel_explore_rounded,
                  matchData['location'] ?? '-',
                ),
                const SizedBox(height: 15),
                _buildReadOnlyField(
                  "Tanggal Dimulai",
                  Icons.calendar_month_rounded,
                  matchData['date'] ?? '-',
                ),
                const SizedBox(height: 15),
                _buildReadOnlyField(
                  "Nama Penyelenggara",
                  Icons.assignment_add,
                  matchData['organizer'] ?? '-',
                ),
                const SizedBox(height: 15),
                _buildReadOnlyField(
                  "Pembuat Pertandingan",
                  Icons.person_pin_rounded,
                  _getRealCreatorName(),
                ),
                const SizedBox(height: 10),
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
              Icon(icon, color: secondaryColor, size: 24),
              const SizedBox(width: 15),
              Expanded(child: Text(value, style: text14PrimaryBold)),
            ],
          ),
        ),
      ],
    );
  }
}
