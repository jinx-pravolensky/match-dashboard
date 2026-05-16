import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/session_guard.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/admin_screens/akun/akun_screen.dart';
import 'package:ns3_project/screens/admin_screens/event/event_screen.dart';
import 'package:ns3_project/screens/admin_screens/match/match_screen.dart';
import 'package:ns3_project/screens/admin_screens/folders/folders_screen.dart';

class DashboardAdminPertandingan extends StatefulWidget {
  const DashboardAdminPertandingan({super.key});
  static String routeName = '/dashboard-admin-pertandingan';

  @override
  State<DashboardAdminPertandingan> createState() => _DashboardAdminPertandinganState();
}

class _DashboardAdminPertandinganState extends State<DashboardAdminPertandingan> {
  @override
  void initState() {
    super.initState();
    SessionGuard.checkUserStatus(context);
  }

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FoldersScreen(),
    MatchScreen(),
    AdminEventScreen(),
    AkunAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.article_rounded, 'Folders', 0),
          _navItem(Icons.library_books_rounded, 'Match', 1),
          _navItem(Icons.assignment_rounded, 'Event', 2),
          _navItem(Icons.perm_contact_cal_rounded, 'Akun', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? goldColor : Colors.white, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? goldColor : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
