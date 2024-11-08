import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trabalho_pdm/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trabalho_pdm/service/mongo_service.dart';
import 'package:trabalho_pdm/service/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
