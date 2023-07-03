import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fortunenow/models/user_model.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/app_colors.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/screens/add%20friend/add_contact_screen.dart';
import 'package:fortunenow/screens/friend%20view/friend_view_screen.dart';
import 'package:fortunenow/widgets/button_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
        ),
        body: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Friends',
                  style: AppConstants.loginTitleStyle,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('friends', arrayContains: value.user!.userId)
                        .snapshots(),
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
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Friends",
                            style: AppConstants.textStyle18,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          UserModel userModel =
                              UserModel.fromMap(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              onTap: () {
                                Get.to(
                                  () => FriendViewScreen(
                                    userModel: userModel,
                                  ),
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: userModel.profilePic == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                    )
                                  : Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            userModel.profilePic ?? '',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              title: Text(
                                userModel.fullName,
                                style: AppConstants.textStyle14,
                              ),
                              subtitle: Text(
                                '@${userModel.username}',
                                style: AppConstants.textStyle14.copyWith(
                                  color: AppColors.greyTextColor,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                        ),
                        itemCount: snapshot.data?.docs.length ?? 0,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ButtonWidget(
                  onTap: () {
                    Get.to(
                      () => const AddContactScreen(),
                    );
                  },
                  title: 'Add Contact',
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
