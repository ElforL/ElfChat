import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/screens/ChatPage.dart';
import 'package:elfchat/screens/HomePage.dart';
import 'package:elfchat/screens/LogInPage.dart';
import 'package:elfchat/screens/SearchPage.dart';
import 'package:elfchat/screens/UserPage.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FireStoreServices _db = FireStoreServices();
  final AuthServices _auth = AuthServices(_db);
  runApp(MyApp(_auth, _db));
}

class MyApp extends StatelessWidget {
  final AuthServices _auth;
  final FireStoreServices _db;

  const MyApp(this._auth, this._db);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElfChat',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFDDDDDD),
        primarySwatch: Colors.green,
        inputDecorationTheme: InputDecorationTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(_auth, _db),
        '/user': (context) => UserPage(_db, _auth),
        '/chat': (context) => ChatPage(_auth, _db),
        '/search': (context) => SearchPage(_auth, _db),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthServices _auth;
  final FireStoreServices _db;

  const AuthWrapper(this._auth, this._db);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        if (!_auth.isSignedIn)
          return LogInPage(auth: _auth);
        else
          return HomePage(_auth, _db);
      },
    );
  }
}
