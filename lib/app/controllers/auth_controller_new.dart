// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/firebase_auth_service.dart';

// class AuthController extends GetxController {
//   final _storage = GetStorage();
//   final _firebaseAuthService = FirebaseAuthService();
//   final _isLoggedInKey = 'isLoggedIn';
//   final _userKey = 'user';

//   // Observable for authentication status
//   RxBool isLoggedIn = false.obs;
//   RxString userEmail = ''.obs;
//   RxString userName = ''.obs;
//   Rx<User?> firebaseUser = Rx<User?>(null);

//   @override
//   void onInit() {
//     super.onInit();
//     _initAuthListener();
//     _loadAuthStatus();
//   }

//   /// Initialize Firebase auth state listener
//   void _initAuthListener() {
//     _firebaseAuthService.authStateChanges.listen((User? user) {
//       firebaseUser.value = user;
//       if (user != null) {
//         isLoggedIn.value = true;
//         userEmail.value = user.email ?? '';
//         userName.value = user.displayName ?? '';
//         _saveAuthStatus(user);
//       } else {
//         isLoggedIn.value = false;
//         userEmail.value = '';
//         userName.value = '';
//         _clearAuthStatus();
//       }
//     });
//   }

//   /// Load authentication status from storage
//   void _loadAuthStatus() {
//     final currentUser = _firebaseAuthService.currentUser;
//     if (currentUser != null) {
//       isLoggedIn.value = true;
//       userEmail.value = currentUser.email ?? '';
//       userName.value = currentUser.displayName ?? '';
//       firebaseUser.value = currentUser;
//     } else {
//       isLoggedIn.value = _storage.read(_isLoggedInKey) ?? false;
//       userEmail.value = _storage.read(_userKey) ?? '';
//     }
//   }

//   /// Save authentication status to storage
//   Future<void> _saveAuthStatus(User user) async {
//     await _storage.write(_isLoggedInKey, true);
//     await _storage.write(_userKey, user.email ?? '');
//   }

//   /// Clear authentication status from storage
//   Future<void> _clearAuthStatus() async {
//     await _storage.remove(_isLoggedInKey);
//     await _storage.remove(_userKey);
//   }

//   /// Login with email and password
//   Future<bool> login(String email, String password) async {
//     try {
//       final credential = await _firebaseAuthService.signInWithEmailAndPassword(
//           email, password);
//       return credential != null;
//     } catch (e) {
//       Get.snackbar('Error', 'Login failed: ${e.toString()}');
//       return false;
//     }
//   }

//   /// Sign up with email and password
//   Future<bool> signUp(
//       String email, String password, String confirmPassword) async {
//     try {
//       if (password != confirmPassword) {
//         Get.snackbar('Error', 'Passwords do not match');
//         return false;
//       }

//       final credential = await _firebaseAuthService
//           .createUserWithEmailAndPassword(email, password);
//       return credential != null;
//     } catch (e) {
//       Get.snackbar('Error', 'Sign up failed: ${e.toString()}');
//       return false;
//     }
//   }

//   /// Sign in with Google
//   Future<bool> signInWithGoogle() async {
//     try {
//       final credential = await _firebaseAuthService.signInWithGoogle();
//       return credential != null;
//     } catch (e) {
//       Get.snackbar('Error', 'Google sign in failed: ${e.toString()}');
//       return false;
//     }
//   }

//   /// Sign in with Apple
//   Future<bool> signInWithApple() async {
//     try {
//       final credential = await _firebaseAuthService.signInWithApple();
//       return credential != null;
//     } catch (e) {
//       Get.snackbar('Error', 'Apple sign in failed: ${e.toString()}');
//       return false;
//     }
//   }

//   /// Logout user
//   Future<void> logout() async {
//     try {
//       await _firebaseAuthService.signOut();
//     } catch (e) {
//       Get.snackbar('Error', 'Logout failed: ${e.toString()}');
//     }
//   }
// }
