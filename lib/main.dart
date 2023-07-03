import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fortunenow/provider/firebase_provider.dart';
import 'package:fortunenow/res/app_colors.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FirebaseProvider(),
      lazy: false,
      child: GetMaterialApp(
        title: 'Fortunenow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Manrope',
          scaffoldBackgroundColor: AppColors.scaffoldColor,
          useMaterial3: true,
        ),
        home: const Scaffold(),
      ),
    );
  }
}
