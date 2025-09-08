import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../services/firebase_auth_service.dart';
import 'package:get/get.dart';

class AccountDeletionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuthService _authService = FirebaseAuthService();

  /// Deletes the user account and all associated Firebase data
  ///
  /// [reason] - Optional reason for account deletion (for logging purposes)
  ///
  /// Returns true if successful, throws exception if failed
  static Future<bool> deleteAccount({
    String? reason,
  }) async {
    try {
      final AuthController authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      final userId = currentUser.id;

      print('Starting account deletion for user: $userId');

      // 1. Delete all user data from Firestore
      await _deleteUserFirestoreData(userId);

      // 2. Delete the Firebase Auth user
      final authDeleted = await _authService.deleteUser();
      if (!authDeleted) {
        throw Exception('Failed to delete Firebase Auth user');
      }

      // 3. Clear all local data
      await _clearLocalData();

      print('✅ Account deletion completed successfully');
      return true;
    } catch (e) {
      print('❌ Account deletion error: $e');
      rethrow;
    }
  }

  /// Delete all user-related data from Firestore
  static Future<void> _deleteUserFirestoreData(String userId) async {
    try {
      print('Deleting Firestore data for user: $userId');

      // Delete user profile document
      await _firestore.collection('users').doc(userId).delete();
      print('✅ User profile deleted');

      // Delete all kids associated with this user
      final kidsQuery = await _firestore
          .collection('kids')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in kidsQuery.docs) {
        batch.delete(doc.reference);
      }

      if (kidsQuery.docs.isNotEmpty) {
        await batch.commit();
        print('✅ Deleted ${kidsQuery.docs.length} kid profiles');
      }

      // TODO: Add deletion of other user-related collections as needed
      // For example: appointments, medical records, etc.
    } catch (e) {
      print('❌ Error deleting Firestore data: $e');
      rethrow;
    }
  }

  /// Clears all local data after successful account deletion
  static Future<void> _clearLocalData() async {
    try {
      print('Starting local data cleanup...');

      // 1. Clear AuthController data (this calls logout and clears tokens)
      final AuthController authController = Get.find<AuthController>();
      await authController.logoutAfterAccountDeletion();
      print('Auth tokens and user data cleared via specialized logout');

      // 2. Clear all GetStorage data as backup (in case logout didn't clear everything)
      final storage = GetStorage();
      await storage.erase();
      print('All local storage cleared');

      // 3. Double-check that critical observables are reset
      authController.isLoggedIn.value = false;
      authController.accessToken.value = '';
      authController.userEmail.value = '';
      authController.userName.value = '';
      authController.userId.value = '';
      authController.currentUser.value = null;

      print('✅ Local data cleanup completed successfully');
    } catch (e) {
      print('❌ Error during local data cleanup: $e');
      // Don't throw here as the account was already deleted on Firebase
      // But ensure critical cleanup still happens
      try {
        final storage = GetStorage();
        await storage.erase();

        final AuthController authController = Get.find<AuthController>();
        authController.isLoggedIn.value = false;
        authController.accessToken.value = '';
        print('✅ Emergency cleanup completed');
      } catch (cleanupError) {
        print('❌ Emergency cleanup also failed: $cleanupError');
      }
    }
  }

  /// Test method to validate Firebase connectivity
  static Future<bool> testFirebaseConnection() async {
    try {
      final AuthController authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        return false;
      }

      // Try to read user document from Firestore
      final doc =
          await _firestore.collection('users').doc(currentUser.id).get();
      return doc.exists;
    } catch (e) {
      print('Firebase connection test error: $e');
      return false;
    }
  }
}

/// Exception class for account deletion errors
class AccountDeletionException implements Exception {
  final String message;
  final int? statusCode;

  AccountDeletionException(this.message, [this.statusCode]);

  @override
  String toString() => 'AccountDeletionException: $message';
}
