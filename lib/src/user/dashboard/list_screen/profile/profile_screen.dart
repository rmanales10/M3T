import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
  final _controller = Get.put(ProfileController());
  late final String base64Image;
  final isEdit = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initProfile();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                _buildProfileHeader(size),
                _buildPersonalDetailsSection(),
                _buildActionsSection(),
              ],
            ),
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
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Obx(() {
                _controller.fetchUserInfo();
                final imageString = _controller.userInfo['base64image'];
                Uint8List? profileImageBytes;

                if (imageString != null && imageString.isNotEmpty) {
                  try {
                    profileImageBytes = base64Decode(imageString);
                  } catch (e) {
                    log('Error decoding image string: $e');
                  }
                }

                return ClipOval(
                  child: profileImageBytes == null
                      ? Icon(
                          Icons.person_4_outlined,
                          size: 100,
                        )
                      : Image.memory(
                          profileImageBytes,
                          height: 100,
                          width: 100,
                          gaplessPlayback: true,
                          fit: BoxFit.cover,
                        ),
                );
              }),
              // Positioned edit icon on top of CircleAvatar
              Positioned(
                top: 60,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: Colors.white),
                  ),
                  child: IconButton(
                    onPressed: pickImageAndProcess,
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Full Name of the User
          Obx(() {
            _controller.fetchUserInfo();
            return Text(
              '${_controller.userInfo['fullname'] ?? ''}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
          // Instructor Title
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                  onPressed: () async {
                    isEdit.value = !isEdit.value;
                    await _controller.updateUserInfo(
                        fullname: fullnameController.text,
                        phoneNumber: phoneController.text);
                  },
                  child: Obx(() => Text(
                        isEdit.value ? 'Done' : 'Edit',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      )))
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => Column(
              children: [
                _buildLabeledField('Name & Surname', Icons.person,
                    fullnameController, isEdit.value),
                const SizedBox(height: 15),
                _buildLabeledField(
                    'Email Address', Icons.email, emailController, false),
                const SizedBox(height: 15),
                _buildLabeledField(
                    'Phone Number', Icons.phone, phoneController, isEdit.value),
              ],
            ),
          )
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

  Widget _buildLabeledField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isEdit,
  ) {
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
                child: TextField(
                  enabled: isEdit,
                  controller: controller,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration.collapsed(
                    hintText: '',
                    border: InputBorder.none, // Removes the default underline
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1, // Use multi-line if you want
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _resetPassword() {
    _controller.resetPass(email: emailController.text);
    Get.snackbar(
      'Reset Password',
      'Password reset link has been sent to your email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }

  Future<void> pickImageAndProcess() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Pick an image from gallery
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Check if the platform is Web
        if (kIsWeb) {
          // Web: Use 'readAsBytes' to process the picked image
          final Uint8List webImageBytes = await pickedFile.readAsBytes();

          setState(() {
            base64Image = base64Encode(webImageBytes);
          });
          await _controller.storeImage(image: base64Image);

          log("Image selected on Web: ${webImageBytes.lengthInBytes} bytes");
        } else {
          // Native (Android/iOS): Use File to get image bytes
          final File nativeImageFile = File(pickedFile.path);

          // Ensure that the file exists
          if (await nativeImageFile.exists()) {
            final Uint8List nativeImageBytes =
                await nativeImageFile.readAsBytes();

            setState(() {
              base64Image = base64Encode(nativeImageBytes);
            });
            await _controller.storeImage(image: base64Image);

            log("Image selected on Native: ${nativeImageFile.path}");
          } else {
            log("File does not exist: ${pickedFile.path}");
          }
        }
      } else {
        log("No image selected.");
      }
    } catch (e) {
      log("Error picking image: $e");
    }
  }

  Future<void> initProfile() async {
    await _controller.fetchUserInfo();
    setState(() {
      fullnameController.text = _controller.userInfo['fullname'];
      emailController.text = _controller.userInfo['email'];
      phoneController.text = _controller.userInfo['phone'];
    });
  }
}
