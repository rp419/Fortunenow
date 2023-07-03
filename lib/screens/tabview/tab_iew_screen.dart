import 'package:flutter/material.dart';
import 'package:fortunenow/res/app_colors.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/res/images.dart';

import 'package:fortunenow/screens/tabview/friends/friends_screen.dart';
import 'package:fortunenow/screens/tabview/home/home_screen.dart';
import 'package:fortunenow/screens/tabview/profile/profile_screen.dart';

class TabViewScreen extends StatefulWidget {
  const TabViewScreen({Key? key}) : super(key: key);

  @override
  State<TabViewScreen> createState() => _TabViewScreenState();
}

class _TabViewScreenState extends State<TabViewScreen> {
  List<Widget> screens = const [
    HomeScreen(),
    FriendsScreen(),
    ProfileScreen(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.buttonColor,
        unselectedItemColor: AppColors.bootomNavUnSelectedColor,
        showSelectedLabels: true,
        currentIndex: currentIndex,
        showUnselectedLabels: false,
        selectedLabelStyle: AppConstants.textStyle14,
        onTap: (value) {
          currentIndex = value;
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                Images.home,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                Images.friends,
              ),
            ),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                Images.profile,
              ),
            ),
            label: 'Profile',
          ),
        ],
        elevation: 3,
        backgroundColor: Colors.white,
      ),
      body: screens[currentIndex],
    );
  }
}
