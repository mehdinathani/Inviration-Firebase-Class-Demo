import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasedemo/firebase_options.dart';
import 'package:firebasedemo/homepage.dart';
import 'package:firebasedemo/login_view.dart';
import 'package:firebasedemo/registeration_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterationView(),
        '/home': (context) => const Homepage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.data != null) {
            return const Homepage();
          }
          return const LoginView();
        },
      ),
    );
  }
}
