import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techknow/users/authentication/loginscreen.dart';
import 'package:techknow/users/fragments/dashboard_of_fragments.dart';
import 'package:techknow/users/userPreferences/user_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'techknow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: RememberUserPrefs.readUserInfo(),
        builder: (context, dataSnapShot) {
          if (dataSnapShot.data == null) {
            return const LoginScreen();
          } else {
            return DashboardOfFragments();
          }
        },
      ),
    );
  }
}
