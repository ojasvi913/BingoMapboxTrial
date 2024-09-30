import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServicesGoogle {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        if (googleSignInAuthentication.accessToken != null && googleSignInAuthentication.idToken != null) {
          final AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          final UserCredential userCredential = await auth.signInWithCredential(authCredential);

          // Optional: Check if user is signed in successfully
          if (userCredential.user != null) {
            print('Successfully signed in with Google');
          }
        } else {
          print('Google Sign-In tokens are null');
        }
      } else {
        print('Google Sign-In account is null');
      }
    } on FirebaseAuthException catch (e) {
      print('Error signing in with Google: ${e.message}');
    } catch (e) {
      print('General error: ${e.toString()}');
    }
  }

  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }
}
