import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  RxBool isObscured = true.obs;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = Get.put(AuthService());

  void _registerUser() {
    if (_formKey.currentState?.validate() == true) {
      _authService.registerUser(
        fullnameController.text,
        emailController.text,
        passwordController.text,
        phoneController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  padding: EdgeInsets.all(24.0),
                  margin: EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        formLabel('Fullname'),
                        const SizedBox(height: 8.0),
                        myTextField('Enter fullname', Icons.person,
                            fullnameController, fullNameValidator),
                        const SizedBox(height: 20.0),
                        formLabel('Email'),
                        const SizedBox(height: 8.0),
                        myTextField('Enter your email address', Icons.email,
                            emailController, emailValidator),
                        const SizedBox(height: 20.0),
                        formLabel('Phone Number'),
                        const SizedBox(height: 8.0),
                        myTextField('Enter phone number', Icons.phone,
                            phoneController, phoneNumberValidator),
                        const SizedBox(height: 20.0),
                        formLabel('Password'),
                        const SizedBox(height: 8.0),
                        Obx(
                          () => myPasswordField('Insert password',
                              Icons.visibility, isObscured.value, () {
                            isObscured.value = !isObscured.value;
                          }, passwordController, passwordValidator),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        alignment: Alignment.center,
                        child: labelTap(
                          context,
                          'Already have an account? ',
                          'Log in',
                          () => Get.toNamed('/login'),
                        ),
                      ),
                      myButton('Continue', blue,
                          _registerUser) // Call _registerUser on button press
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
