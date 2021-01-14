import 'package:elfchat/models/User.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseAuth _auth;
  final FireStoreServices _db;

  User get user => _auth.currentUser;

  Stream<User> get authStateChanges => _auth.authStateChanges();

  bool get isSignedIn => _auth.currentUser != null;

  AuthServices(this._db) : _auth = FirebaseAuth.instance {
    authStateChanges.listen((newUser) async {
      if (newUser != null) {
        _db.ensureUser(ElfUser(
          userID: newUser.uid,
          email: newUser.email,
          displayName: newUser.displayName,
          photoURL: newUser.photoURL,
        ));
      }
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await _auth.signInWithCredential(credential);
  }

  signOut() async {
    try {
      var google = GoogleSignIn();
      await google.signOut();
    } catch (e) {
      print('Error signing out with google ${e.toString()}');
    } finally {
      await FirebaseAuth.instance.signOut();
    }
  }
}
