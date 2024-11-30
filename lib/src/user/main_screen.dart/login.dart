import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_attend/src/user/api_services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  RxBool isObscured = true.obs;

  final AuthService _authService = Get.put(AuthService());

  Future<void> _loginUser() async {
    if (formKey.currentState?.validate() == true) {
      _authService.loginUser(email.text, password.text);
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
                  'Log in',
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
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        formLabel('Email'),
                        SizedBox(height: 8.0),
                        myTextField('Enter your email address', Icons.email,
                            email, emailValidator),
                        SizedBox(height: 20.0),
                        formLabel('Password'),
                        SizedBox(height: 8.0),
                        Obx(() => myPasswordField('Insert password',
                                Icons.visibility, isObscured.value, () {
                              isObscured.value = !isObscured.value;
                            }, password, passwordValidator)),
                        SizedBox(height: 10.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.toNamed('/forgot'),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      myButton('Log in', blue, _loginUser), // Call _loginUser
                      SizedBox(height: 10),
                      labelTap(context, 'Don\'t have an account? ',
                          'Create an Account', () => Get.toNamed('/register'))
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
