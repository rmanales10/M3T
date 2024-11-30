import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/gestures.dart';
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

  RxBool isTermsAccepted = false.obs; // RxBool for terms acceptance

  final AuthService _authService = Get.put(AuthService());

  void _registerUser() {
    if (_formKey.currentState?.validate() == true && isTermsAccepted.value) {
      _authService.registerUser(
        fullnameController.text,
        emailController.text,
        passwordController.text,
        phoneController.text,
      );
    } else {
      // Show a message if terms are not accepted
      Get.snackbar(
          'Error', 'You must accept the Terms and Privacy Policy to register.');
    }
  }

  // Function to show Terms and Privacy Policy dialog
  void _showTermsAndPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Privacy Policy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                const Text(
                  'Data Collection and Use: \n\n'
                  'In compliance with the Data Privacy Act of 2012 in the Philippines, personal data is collected, used, '
                  'and protected to uphold your privacy rights. Data is gathered for legitimate purposes and handled '
                  'lawfully, with consent obtained where necessary. Personal data will be accurate, relevant, and '
                  'stored only for as long as needed.\n\n'
                  'Your Rights: \n\n'
                  'As a data subject, you have the right to access, correct, or delete your personal data. You can also '
                  'obtain your data in a portable format, object to its processing for certain purposes, and withdraw your '
                  'consent at any time. Complaints can be lodged with the National Privacy Commission.\n\n'
                  'Security Measures: \n\n'
                  'We implement strong security measures to prevent unauthorized access or breaches of personal data. '
                  'Our organization is committed to aligning with international standards, including the EU’s GDPR, to '
                  'ensure transparency and trust in data management.\n\n'
                  'Data Protection Officer: \n\n'
                  'A dedicated Data Protection Officer is appointed to ensure compliance with data privacy regulations '
                  'and to address any concerns or inquiries related to personal data.\n\n'
                  'If you have any questions or concerns, please contact us at rmanales10@gmail.com.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phoneController.text = "09";
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
                        formLabel('Full Name'),
                        myTextField(
                            'Enter fullname',
                            Icons.person,
                            fullnameController,
                            fullNameValidator,
                            TextInputType.text),
                        const SizedBox(height: 8.0),
                        formLabel('Email'),
                        myTextField(
                            'Enter your email address',
                            Icons.email,
                            emailController,
                            emailValidator,
                            TextInputType.emailAddress),
                        const SizedBox(height: 8.0),
                        formLabel('Phone Number'),
                        myTextField(
                            'Enter phone number',
                            Icons.phone,
                            phoneController,
                            phoneNumberValidator,
                            TextInputType.phone),
                        const SizedBox(height: 8.0),
                        formLabel('Password'),
                        Obx(
                          () => myPasswordField('Insert password',
                              Icons.visibility, isObscured.value, () {
                            isObscured.value = !isObscured.value;
                          }, passwordController, passwordValidator),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Obx(
                              () => Checkbox(
                                value: isTermsAccepted.value,
                                onChanged: (bool? value) {
                                  isTermsAccepted.value = value!;
                                },
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms and Privacy Policy',
                                      style: TextStyle(
                                          color: blue,
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _showTermsAndPrivacyPolicyDialog(); // Show dialog
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Terms and Privacy Policy Section

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
