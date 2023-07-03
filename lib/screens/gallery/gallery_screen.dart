import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:fortunenow/models/user_model.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/app_colors.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/screens/gallery/add_photo_screen.dart';
import 'package:fortunenow/screens/gallery/post_display_screen.dart';

enum Filters {
  all,
  users,
  date,
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    Key? key,
    required this.userId,
    required this.firebaseProvider,
  }) : super(key: key);
  final String userId;
  final FirebaseProvider firebaseProvider;
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  DateTime? selectedDate;
  Filters selectedFilter = Filters.all;
  UserModel? selectedUserModel;
  @override
  void initState() {
    super.initState();
    getUsers();
  }

  List<UserModel> friendsList = [];
  getUsers() async {
    try {
      for (var i = 0; i < widget.firebaseProvider.user!.friends.length; i++) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(widget.firebaseProvider.user!.friends[i]).get();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Filters',
                        style: AppConstants.textStyle16,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FilterWidget(
                        title: 'All',
                        onTap: () {
                          selectedFilter = Filters.all;
                          selectedDate = null;
                          selectedUserModel = null;
                          Get.back();
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FilterWidget(
                        title: 'By Date',
                        onTap: () async {
                          Get.back();
                          DateTime? dateTime = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000),
                          );
                          if (dateTime != null) {
                            selectedDate = dateTime;
                            selectedFilter = Filters.date;
                            selectedUserModel = null;
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FilterWidget(
                        title: 'By Friends',
                        onTap: () async {
                          Get.back();
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: SizedBox(
                                height: size.height * 0.4,
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
                                            child: ListTile(
                                              onTap: () {
                                                selectedFilter = Filters.users;
                                                selectedDate = null;
                                                selectedUserModel = e;
                                                Get.back();
                                                setState(() {});
                                              },
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
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.filter_alt,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(
            () => Consumer<FirebaseProvider>(
              builder: (context, value, child) => AddPhotoScreen(
                userModel: value.user!,
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
        label: Text(
          'Add Photo',
          style: AppConstants.textStyle18.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.buttonColor,
      ),
      body: SizedBox.expand(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                'Something went wrong',
                style: AppConstants.textStyle16,
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.buttonColor,
                ),
              );
            }
            if (snapshot.data?.data()?.isEmpty ?? true) {
              return const Center(
                child: Text(
                  "No Photos",
                  style: AppConstants.textStyle18,
                ),
              );
            }
            UserModel userModel = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            if (userModel.photos.isEmpty) {
              return const Center(
                child: Text(
                  'No Posts Available',
                  style: AppConstants.textStyle18,
                ),
              );
            }
            if (selectedFilter == Filters.users) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: userModel.photos
                      .where(
                        (element) => element.userTags.contains(selectedUserModel!.userId),
                      )
                      .length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => PostDisplayScreen(
                            photoModel: userModel.photos
                                .where(
                                  (element) => element.userTags.contains(selectedUserModel!.userId),
                                )
                                .toList(),
                            index: index,
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        imageUrl: userModel.photos
                            .where(
                              (element) => element.userTags.contains(selectedUserModel!.userId),
                            )
                            .toList()[index]
                            .photoUrls
                            .first,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: imageProvider,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            if (selectedFilter == Filters.date) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: userModel.photos
                      .where(
                        (element) =>
                            element.createdAt.day == selectedDate!.day &&
                            element.createdAt.month == selectedDate!.month,
                      )
                      .length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => PostDisplayScreen(
                            photoModel: userModel.photos
                                .where(
                                  (element) =>
                                      element.createdAt.day == selectedDate!.day &&
                                      element.createdAt.month == selectedDate!.month,
                                )
                                .toList(),
                            index: index,
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        imageUrl: userModel.photos
                            .where(
                              (element) =>
                                  element.createdAt.day == selectedDate!.day &&
                                  element.createdAt.month == selectedDate!.month,
                            )
                            .toList()[index]
                            .photoUrls
                            .first,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: imageProvider,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: userModel.photos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => PostDisplayScreen(
                          photoModel: userModel.photos,
                          index: index,
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      imageUrl: userModel.photos[index].photoUrls.first,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: imageProvider,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);
  final String title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.buttonColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(
            title,
            style: AppConstants.textStyle18.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
