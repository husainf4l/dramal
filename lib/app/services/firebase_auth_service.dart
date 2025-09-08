import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:get/get.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  FirebaseAuthService() {
    _googleSignIn = GoogleSignIn.instance;
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Sign in failed: ${e.toString()}');
      return null;
    }
  }

  /// Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Sign up failed: ${e.toString()}');
      return null;
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');

      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      print('Google Sign-In result: ${googleUser.email}');

      // Get authorization for the required scopes
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      if (authorization == null) {
        print('Failed to get authorization for required scopes');
        return null;
      }

      // Get the ID token from authentication
      final authentication = await googleUser.authentication;

      print('Got Google authentication tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: authentication.idToken,
      );

      // Once signed in, return the UserCredential
      final result = await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${result.user?.email}');
      return result;
    } catch (e) {
      print('Google Sign-In error: $e');
      Get.snackbar('Error', 'Google sign in failed: ${e.toString()}');
      return null;
    }
  }

  /// Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of the nonce.
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      Get.snackbar('Error', 'Apple sign in failed: ${e.toString()}');
      return null;
    }
  }

  /// Delete current user account
  Future<bool> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Delete the user from Firebase Auth
      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Account deletion failed: ${e.toString()}');
      return false;
    }
  }

  /// Generate a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Handle Firebase Auth exceptions
  void _handleFirebaseAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'The account already exists for that email.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      default:
        message = 'An error occurred: ${e.message}';
    }
    Get.snackbar('Authentication Error', message);
  }
}
