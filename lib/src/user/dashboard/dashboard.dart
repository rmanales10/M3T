import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen1.dart';
import 'package:app_attend/src/user/dashboard/list_screen/home/home_final.dart';
import 'package:app_attend/src/user/dashboard/list_screen/report/report_screen.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_screen.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem(child: Text(item));
  List<Widget> body = const [
    HomeFinal(),
    AttendanceScreen1(),
    ReportScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue,
      body: body[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        selectedItemColor: blue, // Color for selected icon
        unselectedItemColor: Colors.black, // Color for unselected icons
        items: [
          barItem('Home', Icons.home),
          barItem('Attendance', Icons.people),
          barItem('Reports', Icons.report),
          barItem('Profile', Icons.person_2),
        ],
      ),
    );
  }

  BottomNavigationBarItem barItem(String label, IconData icon) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(icon),
    );
  }
}
