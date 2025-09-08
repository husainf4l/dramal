import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final _firebaseAuthService = FirebaseAuthService();

  // Storage keys
  final _accessTokenKey = 'access_token';
  final _refreshTokenKey = 'refresh_token';
  final _userDataKey = 'user_data';
  final _isLoggedInKey = 'is_logged_in';

  // Observable states
  RxBool isLoggedIn = false.obs;
  RxString userEmail = ''.obs;
  RxString userName = ''.obs;
  RxString userId = ''.obs;
  Rx<UserData?> currentUser = Rx<UserData?>(null);
  RxString accessToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAuthStatus();
  }

  /// Load authentication status from storage
  void _loadAuthStatus() {
    final token = _storage.read(_accessTokenKey);
    final userData = _storage.read(_userDataKey);
    final isLoggedInStored = _storage.read(_isLoggedInKey);

    // Debug: Print stored data
    print('=== AUTH CONTROLLER LOAD DEBUG ===');
    print('Loading authentication status...');
    print('Stored Token: $token');
    print('Stored User Data: $userData');
    print('Stored isLoggedIn: $isLoggedInStored');

    if (token != null && userData != null) {
      accessToken.value = token;
      currentUser.value = UserData.fromJson(userData);
      isLoggedIn.value = true;
      userEmail.value = currentUser.value?.email ?? '';
      userName.value = currentUser.value?.fullName ?? '';
      userId.value = currentUser.value?.id ?? '';

      print('Successfully loaded user data:');
      print('  - Email: ${userEmail.value}');
      print('  - Name: ${userName.value}');
      print('  - ID: ${userId.value}');
      print('  - User Object: ${currentUser.value?.toJson()}');
    } else {
      print('No stored auth data found');
    }
    print('=================================');
  }

  /// Save authentication data to storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    // Debug: Print authentication response data
    print('=== AUTH CONTROLLER SAVE DEBUG ===');
    print('Saving authentication data...');
    print('Access Token: ${authResponse.accessToken}');
    print('Refresh Token: ${authResponse.refreshToken}');
    print('User Data: ${authResponse.user.toJson()}');
    print('User Details:');
    print('  - ID: ${authResponse.user.id}');
    print('  - Email: ${authResponse.user.email}');
    print('  - First Name: ${authResponse.user.firstName}');
    print('  - Last Name: ${authResponse.user.lastName}');
    print('  - Full Name: ${authResponse.user.fullName}');
    print('  - Avatar: ${authResponse.user.avatar}');
    print('==================================');

    await _storage.write(_accessTokenKey, authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await _storage.write(_refreshTokenKey, authResponse.refreshToken);
    }
    await _storage.write(_userDataKey, authResponse.user.toJson());
    await _storage.write(_isLoggedInKey, true);

    // Update observables
    accessToken.value = authResponse.accessToken;
    currentUser.value = authResponse.user;
    isLoggedIn.value = true;
    userEmail.value = authResponse.user.email;
    userName.value = authResponse.user.fullName;
    userId.value = authResponse.user.id;

    // Debug: Print updated observables
    print('=== AUTH CONTROLLER OBSERVABLES UPDATED ===');
    print('Updated observables:');
    print('  - isLoggedIn: ${isLoggedIn.value}');
    print('  - userEmail: ${userEmail.value}');
    print('  - userName: ${userName.value}');
    print('  - userId: ${userId.value}');
    print('  - accessToken: ${accessToken.value}');
    print('==========================================');
  }

  /// Clear authentication data
  Future<void> _clearAuthData() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_refreshTokenKey);
    await _storage.remove(_userDataKey);
    await _storage.remove(_isLoggedInKey);

    // Update observables
    accessToken.value = '';
    currentUser.value = null;
    isLoggedIn.value = false;
    userEmail.value = '';
    userName.value = '';
    userId.value = '';
  }

  /// Clear subscription data (for testing purposes)
  Future<void> clearSubscriptionData() async {
    await _storage.remove('subscription_status');
    await _storage.remove('subscription_expiry');
    await _storage.remove('subscription_plan_id');
    await _storage.remove('subscription_plan_name');
    print('Subscription data cleared');
  }

  /// Register with email and password
  Future<bool> signUp(
    String email,
    String password, {
    String? firstName,
    String? lastName,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Create user document in Firestore
        final userData = UserData(
          id: userCredential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData.toJson());

        // Create AuthResponse
        final authResponse = AuthResponse(
          accessToken: await userCredential.user!.getIdToken() ?? '',
          user: userData,
        );

        await _saveAuthData(authResponse);
        Get.snackbar('Success', 'Account created successfully!');
        return true;
      } else {
        Get.snackbar('Error', 'Registration failed');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Get or create user document in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        UserData userData;
        if (userDoc.exists) {
          // User exists, use existing data
          userData = UserData.fromJson(userDoc.data()!);
        } else {
          // Create new user document
          userData = UserData(
            id: userCredential.user!.uid,
            email: email,
            createdAt: DateTime.now(),
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData.toJson());
        }

        // Create AuthResponse
        final authResponse = AuthResponse(
          accessToken: await userCredential.user!.getIdToken() ?? '',
          user: userData,
        );

        await _saveAuthData(authResponse);
        Get.snackbar('Success', 'Login successful!');
        return true;
      } else {
        Get.snackbar('Error', 'Login failed');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuthService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        Get.snackbar('Error', 'Google sign-in failed');
        return false;
      }

      final user = userCredential.user!;

      // Get or create user document in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      UserData userData;
      if (userDoc.exists) {
        // User exists, use existing data
        userData = UserData.fromJson(userDoc.data()!);
      } else {
        // Create new user document
        userData = UserData(
          id: user.uid,
          email: user.email ?? '',
          firstName: user.displayName?.split(' ').first,
          lastName: user.displayName?.split(' ').skip(1).join(' '),
          avatar: user.photoURL,
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData.toJson());
      }

      // Create AuthResponse
      final authResponse = AuthResponse(
        accessToken: await user.getIdToken() ?? '',
        user: userData,
      );

      await _saveAuthData(authResponse);
      Get.snackbar('Success', 'Google sign-in successful!');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Google sign-in failed: ${e.toString()}');
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      // Check if Apple ID is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        Get.snackbar('Error', 'Apple Sign-In is not available on this device');
        return false;
      }

      // Get Apple credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        Get.snackbar('Error', 'Failed to get Apple identity token');
        return false;
      }

      // Create Firebase credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken!,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        Get.snackbar('Error', 'Apple sign-in failed');
        return false;
      }

      final user = userCredential.user!;

      // Get or create user document in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      UserData userData;
      if (userDoc.exists) {
        // User exists, use existing data
        userData = UserData.fromJson(userDoc.data()!);
      } else {
        // Create new user document
        userData = UserData(
          id: user.uid,
          email: appleCredential.email ?? user.email ?? '',
          firstName: appleCredential.givenName,
          lastName: appleCredential.familyName,
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData.toJson());
      }

      // Create AuthResponse
      final authResponse = AuthResponse(
        accessToken: await user.getIdToken() ?? '',
        user: userData,
      );

      await _saveAuthData(authResponse);
      Get.snackbar('Success', 'Apple sign-in successful!');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Apple sign-in failed: ${e.toString()}');
      return false;
    }
  }

  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await logout();
        return false;
      }

      // Get fresh ID token
      final token = await user.getIdToken(true);
      if (token != null) {
        accessToken.value = token;
        await _storage.write(_accessTokenKey, token);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _performLogout(showSuccessMessage: true);
  }

  /// Internal logout for account deletion (no success message)
  Future<void> logoutAfterAccountDeletion() async {
    await _performLogout(showSuccessMessage: false);
  }

  /// Internal logout implementation
  Future<void> _performLogout({bool showSuccessMessage = true}) async {
    try {
      // Sign out from Google and Firebase
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Always clear local data
      await _clearAuthData();

      if (showSuccessMessage) {
        Get.snackbar('Success', 'Logged out successfully');
      }
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value && accessToken.value.isNotEmpty;

  /// Get current access token
  String get currentAccessToken => accessToken.value;

  /// Show instructions for resetting Apple ID authorization
  void showAppleEmailInstructions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Apple Sign-In Email'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apple only provides your email on the first sign-in attempt. To get your email again:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text('1. Go to Settings > Apple ID'),
            SizedBox(height: 8),
            Text('2. Tap "Sign-In & Security"'),
            SizedBox(height: 8),
            Text('3. Tap "Apps Using Apple ID"'),
            SizedBox(height: 8),
            Text('4. Find and remove this app'),
            SizedBox(height: 8),
            Text('5. Try signing in again'),
            SizedBox(height: 12),
            Text(
              'This will allow Apple to ask for your email permission again.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
