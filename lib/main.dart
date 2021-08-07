import 'package:firebase/login.dart';
import 'package:firebase/home.dart';
import 'package:firebase/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            home: Login(),
            routes: {
              "/login": (context) => Login(),
              "/register": (context) => Register(),
              "/home": (context) => Home(),
            },
          );
        }

        return Container();
      },
    );
  }
}
