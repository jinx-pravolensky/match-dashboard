import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/screens/admin_screens/match/add_match_screen.dart';

class ComponentDataMatch extends StatefulWidget {
  const ComponentDataMatch({super.key});

  @override
  State<ComponentDataMatch> createState() => _ComponentDataMatchState();
}

class _ComponentDataMatchState extends State<ComponentDataMatch> {
  List<dynamic> allMatch = [];
  List<dynamic> listMatch = [];

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();
  String currentSort = "Data Terlama";

  @override
  void initState() {
    super.initState();
    fetchDataMatch();
  }

  void _applySearchAndSort() {
    List<dynamic> temp = List.from(allMatch);

    if (searchController.text.isNotEmpty) {
      final keyword = searchController.text.toLowerCase();
      temp = temp.where((match) {
        final id = (match['matchCustomId'] ?? '').toString().toLowerCase();
        final title = (match['title'] ?? '').toString().toLowerCase();
        return id.contains(keyword) || title.contains(keyword);
      }).toList();
    }

    if (currentSort == 'Data Terbaru') {
      temp = temp.reversed.toList();
    } else if (currentSort == 'Nama A-Z') {
      temp.sort((a, b) {
        final titleA = (a['title'] ?? '').toString().toLowerCase();
        final titleB = (b['title'] ?? '').toString().toLowerCase();
        return titleA.compareTo(titleB);
      });
    }

    setState(() {
      listMatch = temp;
    });
  }

  PopupMenuItem<String> _buildPopupItem(String title) {
    final isSelected = currentSort == title;
    return PopupMenuItem<String>(
      value: title,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> fetchDataMatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('userId');

      if (adminId == null) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/match/admin/$adminId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          allMatch = data;
          _applySearchAndSort();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (allMatch.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFilledState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Belum ada data saat ini,\nsilahkan tambahkan data\nMatch terlebih dahulu.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMatchScreen()),
              );

              if (result == true) fetchDataMatch();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Tambahkan Match",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledState() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Daftar History Match",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryColor, width: 1.5),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          _applySearchAndSort();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari ID atau Nama...',
                          hintStyle: TextStyle(
                            color: Colors.black45,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.library_books_outlined,
                        color: primaryColor,
                        size: 35,
                      ),
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      offset: const Offset(0, 50),
                      elevation: 5,
                      onSelected: (String value) {
                        setState(() {
                          currentSort = value;
                          _applySearchAndSort();
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          _buildPopupItem('Data Terlama'),
                          _buildPopupItem('Data Terbaru'),
                          _buildPopupItem('Nama A-Z'),
                        ];
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: listMatch.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Match tidak ditemukan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: listMatch.length,
                        itemBuilder: (context, index) {
                          final match = listMatch[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: primaryColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  match['title'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "ID : ${match['matchCustomId'] ?? '-'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: creamColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.share_location_rounded,
                                      size: 20,
                                      color: secondaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        match['location'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 20,
                                      color: secondaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        match['date'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.supervised_user_circle_rounded,
                                      size: 20,
                                      color: secondaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        match['organizer'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMatchScreen()),
              );

              if (result == true) fetchDataMatch();
            },
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }
}
