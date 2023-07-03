import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:fortunenow/models/user_model.dart';
import 'package:fortunenow/screens/friend%20view/friend_view_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../res/app_constants.dart';
import '../show image/show_image_screen.dart';

class PostDisplayScreen extends StatefulWidget {
  const PostDisplayScreen({
    Key? key,
    required this.photoModel,
    required this.index,
  }) : super(key: key);
  final List<PhotoModel> photoModel;
  final int index;
  @override
  State<PostDisplayScreen> createState() => _PostDisplayScreenState();
}

class _PostDisplayScreenState extends State<PostDisplayScreen> {
  late PageController _pageController;
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => LoadingOverlay(
        isLoading: value.isLoading,
        child: Scaffold(
          appBar: AppBar(),
          body: SizedBox.expand(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              children: widget.photoModel
                  .map(
                    (e) => PostBuilder(
                      size: size,
                      photoModel: e,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class PostBuilder extends StatefulWidget {
  const PostBuilder({
    Key? key,
    required this.size,
    required this.photoModel,
  }) : super(key: key);
  final Size size;
  final PhotoModel photoModel;
  @override
  State<PostBuilder> createState() => _PostBuilderState();
}

class _PostBuilderState extends State<PostBuilder> {
  @override
  void initState() {
    super.initState();
    getFriends();
  }

  List<UserModel> friendsList = [];
  getFriends() async {
    try {
      for (var i = 0; i < widget.photoModel.userTags.length; i++) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(widget.photoModel.userTags[i]).get();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd - MMMM- y').format(widget.photoModel.createdAt),
                style: AppConstants.textStyle16,
              ),
              Consumer<FirebaseProvider>(
                builder: (context, value, child) => GestureDetector(
                  onTap: () {
                    value.deletePost(widget.photoModel);
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: widget.size.height * 0.6,
              enableInfiniteScroll: false,
              autoPlay: true,
            ),
            items: (widget.photoModel.photoUrls).map(
              (i) {
                return Builder(
                  builder: (BuildContext context) {
                    return CachedNetworkImage(
                      width: double.infinity,
                      imageUrl: i,
                      placeholder: (context, url) {
                        return const Center(child: CircularProgressIndicator());
                      },
                      imageBuilder: (context, imageProvider) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => ShowImageScreen(
                                url: i,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ).toList(),
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
                children: friendsList
                    .map(
                      (e) => GestureDetector(
                        onTap: () {
                          Get.to(() => FriendViewScreen(userModel: e));
                        },
                        child: Text(
                          '#${e.fullName} ',
                        ),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              const Text(
                'Tagged Star Sign  ',
                style: AppConstants.textStyle16,
              ),
              Row(
                children: widget.photoModel.starTags
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
        ],
      ),
    );
  }
}
