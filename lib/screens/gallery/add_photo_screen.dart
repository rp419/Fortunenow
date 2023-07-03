import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortunenow/models/user_model.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../res/app_constants.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({
    Key? key,
    required this.userModel,
  }) : super(key: key);
  final UserModel userModel;

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  List<String> taggedUsers = [];
  List<String> taggedStarSigns = [];
  List<String> taggedUsersName = [];

  XFile? image;
  pickFile(ImageSource source) async {
    image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    getFriends();
    super.initState();
  }

  List<UserModel> friendsList = [];
  getFriends() async {
    try {
      for (var i = 0; i < widget.userModel.friends.length; i++) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userModel.friends[i]).get();
        UserModel friend = UserModel.fromMap(doc.data()!);
        friendsList.add(friend);
      }
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => LoadingOverlay(
        isLoading: value.isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Photo'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              value.addPost(
                PhotoModel(photoUrls: [], userTags: taggedUsers, starTags: taggedStarSigns, createdAt: DateTime.now()),
                image!,
              );
            },
            backgroundColor: AppColors.buttonColor,
            icon: const Icon(
              Icons.upload,
              color: Colors.white,
            ),
            label: Text(
              'Post',
              style: AppConstants.textStyle18.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          body: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: image == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 120,
                            color: AppColors.buttonColor,
                          )
                        : CarouselSlider(
                            options: CarouselOptions(
                              height: 170,
                              enableInfiniteScroll: false,
                              autoPlay: true,
                              viewportFraction: 0.6,
                            ),
                            items: [
                              Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 120,
                                    width: 220,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(image!.path),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext bc) {
                            return SafeArea(
                              child: Wrap(
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Photo Library'),
                                    onTap: () {
                                      Get.back();
                                      pickFile(ImageSource.gallery);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_camera),
                                    title: const Text('Camera'),
                                    onTap: () {
                                      Get.back();
                                      pickFile(ImageSource.camera);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Add Picture',
                        style: AppConstants.textStyle18.copyWith(
                          color: AppColors.buttonColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      const Text(
                        'Tag Friends  ',
                        style: AppConstants.textStyle16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: taggedUsersName
                            .map(
                              (e) => Text(
                                '#$e ',
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  friendsList.isEmpty
                      ? const Center(
                          child: Text('No Friends'),
                        )
                      : Container(
                          height: size.height * 0.12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListView(
                            children: friendsList
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: AppColors.buttonColor.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        checkboxShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        value: taggedUsers.contains(e.userId),
                                        onChanged: (value) {
                                          if (taggedUsers.contains(e.userId)) {
                                            taggedUsers.remove(e.userId);
                                            taggedUsersName.remove(e.fullName);
                                          } else {
                                            taggedUsers.add(e.userId);
                                            taggedUsersName.add(e.fullName);
                                          }
                                          setState(() {});
                                        },
                                        activeColor: AppColors.buttonColor,
                                        dense: true,
                                        title: Text(
                                          e.fullName,
                                          style: AppConstants.textStyle16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                  const SizedBox(
                    height: 30,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      const Text(
                        'Tag Star Sign  ',
                        style: AppConstants.textStyle16,
                      ),
                      Row(
                        children: taggedStarSigns
                            .map(
                              (e) => Text(
                                '#$e ',
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: size.height * 0.16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView(
                      children: starSigns
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: AppColors.buttonColor.withOpacity(
                                    0.5,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  checkboxShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  value: taggedStarSigns.contains(e),
                                  onChanged: (value) {
                                    if (taggedStarSigns.contains(e)) {
                                      taggedStarSigns.remove(e);
                                    } else {
                                      taggedStarSigns.add(e);
                                    }
                                    setState(() {});
                                  },
                                  activeColor: AppColors.buttonColor,
                                  dense: true,
                                  title: Text(
                                    e,
                                    style: AppConstants.textStyle16,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
