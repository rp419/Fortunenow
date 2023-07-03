import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/validators.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../../res/app_colors.dart';
import '../../../res/app_constants.dart';
import '../../../widgets/button_widget.dart';
import '../../../widgets/text_field_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _mailController;
  late TextEditingController _passwwordController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _userNameController;
  @override
  void initState() {
    _mailController = TextEditingController();
    _passwwordController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _userNameController = TextEditingController();
    super.initState();
  }

  final _instance = FirebaseFirestore.instance;
  String? usernameString;
  Future<bool> userExists(String username) async =>
      (await _instance.collection("users").where("username", isEqualTo: username).get()).docs.isNotEmpty;
  final _formState = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => LoadingOverlay(
        isLoading: value.isLoading,
        child: Scaffold(
          appBar: AppBar(),
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
                        height: Get.height * 0.05,
                      ),
                      const Text(
                        'Sign up',
                        style: AppConstants.loginTitleStyle,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFielldWidget(
                        controller: _nameController,
                        hint: 'John doe',
                        label: 'Full Name',
                        obsText: false,
                        validator: Validators.emptyValidator,
                        isPhone: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFielldWidget(
                        controller: _userNameController,
                        hint: '@johndoe',
                        label: 'Username',
                        obsText: false,
                        autovalidateMode: AutovalidateMode.always,
                        validator: (p0) {
                          if (p0?.isEmpty ?? true) {
                            return 'Please enter a username';
                          }
                          return usernameString;
                        },
                        isPhone: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFielldWidget(
                        controller: _phoneController,
                        hint: '+123456789',
                        label: 'Phone',
                        obsText: false,
                        validator: Validators.phoneValidator,
                        isPhone: true,
                      ),
                      const SizedBox(
                        height: 10,
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
                        validator: Validators.passwordValidator,
                        label: 'Password',
                        isPhone: false,
                        obsText: true,
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      ButtonWidget(
                        title: 'Sign up',
                        onTap: () async {
                          if (_userNameController.text.isNotEmpty) {
                            if (await userExists(_userNameController.text)) {
                              usernameString = 'Username already exists';
                              setState(() {});
                              return;
                            } else {
                              usernameString = null;
                            }
                          }
                          if (_formState.currentState?.validate() ?? false) {
                            value.usersignUp(
                              email: _mailController.text,
                              password: _passwwordController.text,
                              name: _nameController.text,
                              username: _userNameController.text,
                              phone: _phoneController.text,
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: Get.height * 0.1,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: AppConstants.textStyle16.copyWith(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign in',
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
