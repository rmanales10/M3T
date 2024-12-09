import 'package:app_attend/firebase_options.dart';
import 'package:app_attend/src/admin/dashboard/dashboard.dart';
import 'package:app_attend/src/admin/dashboard/screens/activity_log/activity_log.dart';
import 'package:app_attend/src/admin/dashboard/screens/homepage/home_page.dart';
import 'package:app_attend/src/admin/dashboard/screens/students/student_page.dart';
import 'package:app_attend/src/admin/dashboard/screens/subjects/subject_page.dart';
import 'package:app_attend/src/admin/dashboard/screens/teachers/teacher_page.dart';
import 'package:app_attend/src/admin/main_screen/admin.dart';

import 'package:app_attend/src/user/dashboard/dashboard.dart';
import 'package:app_attend/src/user/main_screen.dart/forgot_password.dart';
import 'package:app_attend/src/user/main_screen.dart/login.dart';
import 'package:app_attend/src/user/main_screen.dart/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/user/main_screen.dart/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  kIsWeb ? runApp(Admin()) : runApp(User());
}

class User extends StatelessWidget {
  const User({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tap Attend',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => WelcomeScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/dashboard', page: () => Dashboard()),
        GetPage(name: '/forgot', page: () => ForgotPassword()),
      ],
    );
  }
}

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tap Attend',
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreenForAdmin()),
        GetPage(name: '/activity-log', page: () => ActivityLogPage()),
        GetPage(name: '/subject', page: () => SubjectPage()),
        GetPage(name: '/student', page: () => StudentPage()),
        GetPage(name: '/teacher', page: () => TeacherPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/dashboard', page: () => AdminDashboard()),
      ],
    );
  }
}
