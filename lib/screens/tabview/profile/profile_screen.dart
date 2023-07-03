import 'package:flutter/material.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/app_colors.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/res/images.dart';
import 'package:fortunenow/screens/edit%20profile/edit_profile_screen.dart';
import 'package:fortunenow/screens/gallery/gallery_screen.dart';
import 'package:fortunenow/widgets/button_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => LoadingOverlay(
        isLoading: value.isLoading,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            forceMaterialTransparency: true,
            actions: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => EditProfileScreen(
                      firebaseProvider: value,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      Images.edit,
                      height: 18,
                    ),
                    const Text(
                      'Edit profile',
                      style: AppConstants.textStyle14,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SizedBox.expand(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 106,
                  width: 106,
                  decoration: BoxDecoration(
                    image: value.user?.profilePic == null
                        ? null
                        : DecorationImage(
                            image: NetworkImage(
                              value.user?.profilePic ?? '',
                            ),
                            fit: BoxFit.cover,
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: value.user?.profilePic == null
                      ? GestureDetector(
                          onTap: () {
                            selectPhotoMethod(context, value);
                          },
                          child: const Icon(
                            Icons.add_a_photo_rounded,
                            color: AppColors.buttonColor,
                            size: 100,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selectPhotoMethod(context, value);
                              },
                              child: Image.asset(Images.camera),
                            ),
                          ],
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  value.user?.fullName ?? '',
                  style: AppConstants.textStyle18,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.containerBgColor2,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          '${(value.user?.friends ?? []).length}',
                          style: AppConstants.textStyle18.copyWith(
                            color: AppColors.greyTextColor,
                          ),
                        ),
                        Text(
                          'Friends',
                          style: AppConstants.textStyle14.copyWith(
                            color: AppColors.greyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ButtonWidget(
                    title: 'Gallery   📷',
                    onTap: () {
                      Get.to(
                        () => GalleryScreen(
                          userId: value.user!.userId,
                          firebaseProvider: value,
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ButtonWidget(
                    title: 'Signout',
                    onTap: () {
                      value.signOut();
                    },
                    bgColor: Colors.red[600],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> selectPhotoMethod(BuildContext context, FirebaseProvider value) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  value.uploadProfilePicture(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  value.uploadProfilePicture(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
