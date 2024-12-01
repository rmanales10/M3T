import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/api_services/firestore_service.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
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

  final AuthService _auth = Get.put(AuthService());
  final FirestoreService _firestoreService = Get.put(FirestoreService());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Fetch user data
    _firestoreService.fetchUserData(_auth.currentUser!.uid);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(size),
            _buildPersonalDetailsSection(),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Size size) {
    return Container(
      width: size.width,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: const BorderRadiusDirectional.vertical(
          bottom: Radius.circular(20),
        ),
        color: blue,
      ),
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black,
            radius: 45,
            backgroundImage: NetworkImage(
                'https://static1.srcdn.com/wordpress/wp-content/uploads/2024/10/untitled-design-2024-10-01t123706-515-1.jpg'),
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
                '${_firestoreService.userData['fullname'] ?? ''}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
          const Text(
            'Instructor',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Obx(() => Column(
                children: [
                  _buildLabeledField('Name & Surname', Icons.person,
                      '${_firestoreService.userData['fullname'] ?? ''}'),
                  const SizedBox(height: 15),
                  _buildLabeledField('Email Address', Icons.email,
                      '${_firestoreService.userData['email'] ?? ''}'),
                  const SizedBox(height: 15),
                  _buildLabeledField('Phone Number', Icons.phone,
                      '${_firestoreService.userData['phone'] ?? ''}'),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _resetPassword,
            child: Text(
              'Reset Password',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 16,
                color: blue,
              ),
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () => _auth.signOut(),
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.red),
                const SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
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

  Widget _buildLabeledField(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _resetPassword() {
    // Logic to reset password
    Get.snackbar(
      'Reset Password',
      'Password reset link has been sent to your email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }
}
