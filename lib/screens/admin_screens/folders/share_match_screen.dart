import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';

class BagikanMatchScreen extends StatefulWidget {
  final String matchId;

  const BagikanMatchScreen({super.key, required this.matchId});

  @override
  State<BagikanMatchScreen> createState() => _BagikanMatchScreenState();
}

class _BagikanMatchScreenState extends State<BagikanMatchScreen> {
  TextEditingController idController = TextEditingController();

  bool isSearching = false;
  Map<String, dynamic>? pendingAdmin;
  List<Map<String, dynamic>> selectedAdminList = [];

  Future<void> _searchAdmin() async {
    String idSearch = idController.text.trim();
    if (idSearch.isEmpty) return;

    setState(() => isSearching = true);
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/admin/search-admin/$idSearch?matchId=${widget.matchId}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool alreadySelected = selectedAdminList.any(
          (admin) => admin['customId'] == data['customId'],
        );
        if (!alreadySelected) {
          setState(() {
            pendingAdmin = data;
          });
        } else {
          _tampilkanPesan(
            "Admin ini sudah ada di daftar terpilih di bawah!",
            Colors.orange,
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        _tampilkanPesan(
          errorData['message'] ?? "Admin tidak ditemukan!",
          Colors.redAccent,
        );
      }
    } catch (e) {
      _tampilkanPesan("Gagal terhubung ke server!", Colors.redAccent);
    }
    setState(() => isSearching = false);
  }
  void _tampilkanPesan(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pesan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _simpanBagikanMatch() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      List<String> idAdminSaja = selectedAdminList
          .map((a) => a['_id'].toString())
          .toList();

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/match/${widget.matchId}/share',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"adminIds": idAdminSaja}),
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'BERHASIL DIBAGIKAN',
          desc:
              'Pertandingan ini berhasil dibagikan ke teman-teman Anda! Sekarang mereka punya akses penuh!',
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnOkColor: primaryColor,
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
      } else {
        final errorData = jsonDecode(response.body);
        _tampilkanPesan(
          errorData['message'] ?? "Gagal membagikan match!",
          Colors.redAccent,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _tampilkanPesan("Terjadi kesalahan jaringan!", Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isInputDisabled = pendingAdmin != null || isSearching;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bagikan Pertandingan", style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cari ID Admin",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: idController,
                enabled: !isInputDisabled,
                keyboardType: TextInputType.number,
                style: text14PrimaryBold,
                decoration: InputDecoration(
                  hintText: "Cari ID Admin...",
                  prefixIcon: const Icon(
                    Icons.document_scanner_rounded,
                    color: goldColor,
                  ),
                  filled: isInputDisabled,
                  fillColor: isInputDisabled
                      ? Colors.grey.shade100
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: goldColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInputDisabled
                        ? Colors.grey
                        : const Color(0xFF0F2C59),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isInputDisabled ? null : _searchAdmin,
                  child: isSearching
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Cari ID", style: text16WhiteBold),
                ),
              ),
              const SizedBox(height: 25),
              if (pendingAdmin != null || selectedAdminList.isNotEmpty)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Daftar Admin Terpilih",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(thickness: 1.5),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                if (pendingAdmin != null)
                                  _buildAdminCard(
                                    admin: pendingAdmin!,
                                    isPending: true,
                                    onDelete: () {
                                      setState(() {
                                        pendingAdmin = null;
                                        idController.clear();
                                      });
                                    },
                                    onAdd: () {
                                      setState(() {
                                        selectedAdminList.add(pendingAdmin!);
                                        pendingAdmin = null;
                                        idController.clear();
                                      });
                                    },
                                  ),
                                ...selectedAdminList
                                    .map(
                                      (admin) => _buildAdminCard(
                                        admin: admin,
                                        isPending: false,
                                        onDelete: () {
                                          setState(() {
                                            selectedAdminList.remove(admin);
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                        ),
                        if (selectedAdminList.isNotEmpty &&
                            pendingAdmin == null)
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F2C59),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _simpanBagikanMatch,
                              child: const Text(
                                "Bagikan Pertandingan",
                                style: text16WhiteBold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required Map<String, dynamic> admin,
    required bool isPending,
    required VoidCallback onDelete,
    VoidCallback? onAdd,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin['name'] ?? 'Tanpa Nama',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  admin['customId'] ?? '-',
                  style: const TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isPending)
            InkWell(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2C59),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}
