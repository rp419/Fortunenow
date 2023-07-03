import 'package:flutter/material.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/validators.dart';
import 'package:fortunenow/screens/auth/signup/singup_screen.dart';
import 'package:get/get.dart';

import 'package:fortunenow/res/app_colors.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../../widgets/button_widget.dart';
import '../../../widgets/text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _mailController;
  late TextEditingController _passwwordController;
  @override
  void initState() {
    _mailController = TextEditingController();
    _passwwordController = TextEditingController();
    super.initState();
  }

  final _formState = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => LoadingOverlay(
        isLoading: value.isLoading,
        child: Scaffold(
          body: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formState,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Get.height * 0.15,
                      ),
                      const Text(
                        'Sign in',
                        style: AppConstants.loginTitleStyle,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFielldWidget(
                        controller: _mailController,
                        hint: 'example@gmail.com',
                        label: 'Email',
                        obsText: false,
                        validator: Validators.emailValidator,
                        isPhone: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFielldWidget(
                        controller: _passwwordController,
                        hint: '*****',
                        label: 'Password',
                        validator: Validators.passwordValidator,
                        isPhone: false,
                        obsText: true,
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      ButtonWidget(
                        title: 'Sign in',
                        onTap: () {
                          if (_formState.currentState?.validate() ?? false) {
                            value.usersignIn(email: _mailController.text, password: _passwwordController.text);
                          }
                        },
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      // const Row(
                      //   children: [
                      //     Expanded(child: Divider()),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Text('Or continue with'),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Expanded(child: Divider()),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: Get.height * 0.05,
                      // ),
                      // const Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     SignUpSocialWidget(
                      //       image: Images.google,
                      //     ),
                      //     SignUpSocialWidget(
                      //       image: Images.fb,
                      //     ),
                      //     SignUpSocialWidget(
                      //       image: Images.apple,
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: Get.height * 0.1,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Get.to(() => const SignUpScreen());
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Don\'t have an account? ',
                              style: AppConstants.textStyle16.copyWith(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: AppConstants.textStyle16.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.buttonColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpSocialWidget extends StatelessWidget {
  const SignUpSocialWidget({
    Key? key,
    required this.image,
  }) : super(key: key);
  final String image;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.containerBgColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
        child: Image.asset(
          image,
          height: 24,
        ),
      ),
    );
  }
}
