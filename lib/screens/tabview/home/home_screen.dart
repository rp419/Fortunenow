import 'package:flutter/material.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:provider/provider.dart';

import '../../../res/app_colors.dart';
import '../../../res/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
        ),
        body: SizedBox.expand(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  HomeScreenWIdget(
                    title: 'Quote of the Day',
                    containerColor: AppColors.pinkColor,
                    text: value.todayModel?.quoteDay ?? '',
                  ),
                  HomeScreenWIdget(
                    title: 'Lucky Numbers',
                    containerColor: AppColors.orangeColor,
                    text: value.todayModel?.luckyNumbers ?? '',
                  ),
                  HomeScreenWIdget(
                    title: 'Prediction',
                    containerColor: AppColors.yellowColor,
                    text: value.todayModel?.prediction ?? '',
                  ),
                  const SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenWIdget extends StatelessWidget {
  const HomeScreenWIdget({
    Key? key,
    required this.title,
    required this.text,
    required this.containerColor,
  }) : super(key: key);
  final String title;
  final String text;
  final Color containerColor;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Text(
          title,
          style: AppConstants.loginTitleStyle,
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: containerColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
            child: Text(
              text,
              style: AppConstants.loginTitleStyle.copyWith(
                color: AppColors.greyTextColor,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
