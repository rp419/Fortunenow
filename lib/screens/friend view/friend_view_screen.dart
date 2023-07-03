import 'package:flutter/material.dart';

import 'package:fortunenow/models/user_model.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/app_colors.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/screens/gallery/gallery_screen.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class FriendViewScreen extends StatelessWidget {
  const FriendViewScreen({
    Key? key,
    required this.userModel,
  }) : super(key: key);
  final UserModel userModel;
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => LoadingOverlay(
        isLoading: value.isLoading,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ButtonAddWidget(
                iconData: Icons.person_add,
                title: value.user!.friends.contains(userModel.userId) ? 'Remove friend' : 'Add friend',
                onTap: () {
                  value.addRemoveFriend(userModel.userId);
                },
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          body: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  userModel.profilePic == null
                      ? Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.buttonColor.withOpacity(0.5),
                            size: Get.height * 0.3,
                          ),
                        )
                      : Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(
                                  userModel.profilePic ?? '',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 22,
                  ),
                  if (value.user!.friends.contains(userModel.userId))
                    ListTile(
                      title: const Text(
                        'View Gallery',
                        style: AppConstants.textStyle18,
                      ),
                      dense: true,
                      enabled: true,
                      onTap: () {
                        Get.to(
                          () => GalleryScreen(
                            userId: userModel.userId,
                            firebaseProvider: value,
                          ),
                        );
                      },
                      splashColor: AppColors.buttonColor,
                      selectedColor: AppColors.buttonColor,
                      iconColor: AppColors.buttonColor,
                      contentPadding: EdgeInsets.zero,
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  Text(
                    userModel.fullName,
                    style: AppConstants.loginTitleStyle,
                  ),
                  Text(
                    userModel.status ?? '',
                    style: AppConstants.textStyle14.copyWith(
                      color: AppColors.greyTextColor,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  BottomRowWidget(
                    title: 'User name:',
                    subtitle: '@${userModel.username}',
                  ),
                  BottomRowWidget(
                    title: 'Sign:',
                    subtitle: userModel.sign ?? 'Not available',
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonAddWidget extends StatelessWidget {
  const ButtonAddWidget({
    Key? key,
    required this.title,
    required this.iconData,
    this.onTap,
  }) : super(key: key);
  final String title;
  final IconData iconData;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppConstants.textStyle16.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              const Icon(
                Icons.person_add,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomRowWidget extends StatelessWidget {
  const BottomRowWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppConstants.textStyle14.copyWith(
            color: AppColors.greyTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          subtitle,
          style: AppConstants.textStyle14.copyWith(
            color: AppColors.greyTextColor,
          ),
        ),
      ],
    );
  }
}
