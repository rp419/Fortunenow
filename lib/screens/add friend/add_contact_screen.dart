import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortunenow/models/user_model.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/screens/friend%20view/friend_view_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    try {
      final results = await FirebaseFirestore.instance
          .collection(
            'users',
          )
          .get();
      allUsers = results.docs
          .map(
            (e) => UserModel.fromMap(
              e.data(),
            ),
          )
          .toList();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool isLoading = true;

  List<UserModel> allUsers = [];
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(),
        body: SizedBox.expand(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      CupertinoSearchTextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _searchController.text.isEmpty
                          ? const Center(
                              child: Text(
                                'Search Friends',
                                style: AppConstants.textStyle18,
                              ),
                            )
                          : Expanded(
                              child: ListView(
                                children: allUsers
                                    .map(
                                      (e) => e.fullName.toLowerCase().contains(
                                                _searchController.text.toLowerCase(),
                                              )
                                          ? value.user?.userId == e.userId
                                              ? Container()
                                              : ListTile(
                                                  onTap: () {
                                                    Get.to(
                                                      () => FriendViewScreen(userModel: e),
                                                    );
                                                  },
                                                  leading: e.profilePic == null
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 40,
                                                        )
                                                      : Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: DecorationImage(
                                                              image: NetworkImage(
                                                                e.profilePic ?? '',
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                  title: Text(
                                                    e.fullName,
                                                    style: AppConstants.textStyle16,
                                                  ),
                                                  subtitle: Text(
                                                    e.email,
                                                  ),
                                                )
                                          : Container(),
                                    )
                                    .toList(),
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
