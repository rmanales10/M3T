import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/api_services/firestore_service.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _auth = Get.put(AuthService());
  final FirestoreService _firestoreService = Get.put(FirestoreService());
  @override
  Widget build(BuildContext context) {
    _firestoreService.fetchUserData(_auth.currentUser!.uid);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width,
              height: 230,
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.vertical(
                    bottom: Radius.circular(20)),
                color: blue,
              ),
              padding: EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 4, 4, 3),
                    radius: 45,
                    backgroundImage: NetworkImage(
                        'https://static1.srcdn.com/wordpress/wp-content/uploads/2024/10/untitled-design-2024-10-01t123706-515-1.jpg'),
                  ),
                  SizedBox(height: 10),
                  Obx(() => Text(
                        '${_firestoreService.userData['fullname'] ?? ''}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                  Text(
                    'Instructor',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Personal Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Obx(() => Column(
                        children: [
                          leftLabel('Name & surname'),
                          myDisabledField(
                              '${_firestoreService.userData['fullname'] ?? ''}',
                              Icons.person,
                              fullnameController),
                          SizedBox(height: 10),
                          leftLabel('Email Address'),
                          myDisabledField(
                              '${_firestoreService.userData['email'] ?? ''}',
                              Icons.email,
                              emailController),
                          SizedBox(height: 10),
                          leftLabel('Phone Number'),
                          myDisabledField(
                              '${_firestoreService.userData['phone'] ?? ''}',
                              Icons.phone,
                              phoneController),
                        ],
                      )),
                  SizedBox(height: 10),
                  GestureDetector(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          color: blue),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _auth.signOut(),
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                              fontSize: 20,
                              color: blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Align leftLabel(String label) {
    return Align(
        alignment: AlignmentDirectional.centerStart, child: formLabel(label));
  }
}
