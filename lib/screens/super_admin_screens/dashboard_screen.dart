import 'package:flutter/material.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/session_guard.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/screens/super_admin_screens/add_akun/add_akun_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/data_akun/data_akun_screen.dart';
import 'package:ns3_project/screens/super_admin_screens/profile_akun/profile_screen.dart';

class DashboardSuperAdmin extends StatefulWidget {
  const DashboardSuperAdmin({super.key});
  static String routeName = '/dashboard-super-admin';

  @override
  State<DashboardSuperAdmin> createState() => _DashboardSuperAdminState();
}

class _DashboardSuperAdminState extends State<DashboardSuperAdmin> {
  @override
  void initState() {
    super.initState();
    SessionGuard.checkUserStatus(context);
  }

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DataAkunScreen(),
    TambahAkunScreen(),
    ProfileSuperAdminScreen(),
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
          _navItem(Icons.view_list_rounded, 'Data Akun', 0),
          _navItem(Icons.assignment_add, 'Tambah Akun', 1),
          _navItem(Icons.perm_contact_cal_rounded, 'Profile Akun', 2),
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
