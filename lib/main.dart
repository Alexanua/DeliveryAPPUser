import 'dart:convert';

import 'package:delivery_user_app/splashScreen/splash_screen.dart';
import 'package:delivery_user_app/telegram/auth_telegram.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

 Future<void> main() async {

   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,

   );

   getChatId();
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ORDELI user',
      theme: ThemeData(
      primarySwatch: Colors.blue,
      ),
      home: const MySplashScreen(

      ),
    );
  }
}


