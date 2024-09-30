import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User?> signInWithGoogle() async {
  try {
    // Trigger the Google Authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return null; // Return null if sign-in was cancelled
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    return userCredential.user;
  } catch (e) {
    print('Error signing in with Google: $e');
    return null;
  }
}

Future<void> linkEmailPassword(String email, String password) async {
  try {
    if (_auth.currentUser == null) {
      throw Exception("No user signed in");
    }

    // Create credentials with the provided email and password
    final credential = EmailAuthProvider.credential(email: email, password: password);

    // Link the credential to the current user
    await _auth.currentUser!.linkWithCredential(credential);

    // You can handle additional actions after linking, such as navigating to the next screen
    print('Email/Password linked successfully');

    // Optionally, sign out the user after linking
    // await _auth.signOut();
  } catch (e) {
    print('Error linking email/password: $e');
    throw e; // Re-throw the exception to handle it where the function is called
  }
}

Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    print('Error signing in with email/password: $e');
    return null;
  }
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  await _auth.signOut();
}
