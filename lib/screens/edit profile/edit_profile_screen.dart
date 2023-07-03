import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/app_colors.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/widgets/button_widget.dart';
import 'package:fortunenow/widgets/text_field_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    Key? key,
    required this.firebaseProvider,
  }) : super(key: key);
  final FirebaseProvider firebaseProvider;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  @override
  void initState() {
    _nameController = TextEditingController(text: widget.firebaseProvider.user?.fullName);
    _statusController = TextEditingController(text: widget.firebaseProvider.user?.status);
    newSign = (widget.firebaseProvider.user?.sign?.isEmpty ?? true) ? null : widget.firebaseProvider.user?.sign;
    super.initState();
  }

  String? newSign;
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => LoadingOverlay(
        isLoading: value.isLoading,
        child: Scaffold(
          appBar: AppBar(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              value.updateUser(
                value.user!.copyWith(
                  fullName: _nameController.text,
                  sign: newSign ?? value.user!.sign,
                  status: _statusController.text,
                ),
              );
            },
            label: Text(
              'Update',
              style: AppConstants.textStyle18.copyWith(
                color: Colors.white,
              ),
            ),
            icon: const Icon(
              Icons.edit_note_sharp,
              color: Colors.white,
            ),
            backgroundColor: AppColors.buttonColor,
          ),
          body: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: Get.height * 0.05,
                    ),
                    TextFielldWidget(
                      controller: _nameController,
                      label: 'Full name',
                      obsText: false,
                      isPhone: false,
                      hint: value.user?.fullName ?? "",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFielldWidget(
                      controller: _statusController,
                      label: 'Status',
                      obsText: false,
                      isPhone: false,
                      hint: value.user?.status ?? "....",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    DropdownButton<String>(
                      value: newSign,
                      isExpanded: true,
                      hint: const Text('Select your Star sign'),
                      items: starSigns
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        newSign = value;
                        setState(() {});
                      },
                    ),
                    SizedBox(
                      height: Get.height * 0.1,
                    ),
                    ButtonWidget(
                      title: 'Delete Account',
                      onTap: () {
                        value.deleteAccount();
                      },
                      bgColor: Colors.red[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
