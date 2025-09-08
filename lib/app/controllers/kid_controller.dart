import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kid_model.dart';
import 'auth_controller.dart';

class KidController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  // Observable states
  RxList<KidData> kids = <KidData>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  Rx<KidData?> selectedKid = Rx<KidData?>(null);

  @override
  void onInit() {
    super.onInit();
    loadKids();
  }

  /// Load all kids for the current user
  Future<void> loadKids() async {
    if (_authController.currentUser.value == null) {
      print('❌ No current user found when loading kids');
      return;
    }

    try {
      isLoading.value = true;
      final userId = _authController.currentUser.value!.id;

      print('🔍 Loading kids for user: $userId');

      final querySnapshot = await _firestore
          .collection('kids')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('📊 Found ${querySnapshot.docs.length} kids documents');

      final kidsList = <KidData>[];

      for (final doc in querySnapshot.docs) {
        try {
          final kidData = KidData.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
          kidsList.add(kidData);
          print('✅ Successfully loaded kid: ${kidData.name}');
        } catch (e) {
          print('❌ Error parsing kid document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
        }
      }

      kids.assignAll(kidsList);
      print('✅ Successfully loaded ${kidsList.length} kids');

      // Set selected kid to first kid if none selected or if current selected kid is not in the list
      if (selectedKid.value == null && kidsList.isNotEmpty) {
        selectedKid.value = kidsList.first;
      } else if (selectedKid.value != null &&
          !kidsList.contains(selectedKid.value)) {
        selectedKid.value = kidsList.isNotEmpty ? kidsList.first : null;
      }
    } catch (e) {
      print('❌ Error loading kids: $e');
      Get.snackbar(
        'Error',
        'Failed to load kids data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new kid
  Future<bool> addKid(KidData kidData) async {
    if (_authController.currentUser.value == null) return false;

    try {
      isSaving.value = true;
      final userId = _authController.currentUser.value!.id;
      final now = DateTime.now();

      final kidWithUserId = KidData(
        id: '', // Will be set by Firestore
        userId: userId,
        name: kidData.name,
        dateOfBirth: kidData.dateOfBirth,
        gender: kidData.gender,
        bloodType: kidData.bloodType,
        allergies: kidData.allergies,
        address: kidData.address,
        parentPhone: kidData.parentPhone,
        emergencyContact: kidData.emergencyContact,
        emergencyPhone: kidData.emergencyPhone,
        insuranceProvider: kidData.insuranceProvider,
        insuranceNumber: kidData.insuranceNumber,
        doctorName: kidData.doctorName,
        doctorPhone: kidData.doctorPhone,
        medicalNotes: kidData.medicalNotes,
        insuranceInfo: kidData.insuranceInfo,
        createdAt: now,
        updatedAt: now,
      );

      final docRef =
          await _firestore.collection('kids').add(kidWithUserId.toJson());
      
      // Create the kid data with the proper document ID
      final newKid = KidData(
        id: docRef.id,
        userId: userId,
        name: kidData.name,
        dateOfBirth: kidData.dateOfBirth,
        gender: kidData.gender,
        bloodType: kidData.bloodType,
        allergies: kidData.allergies,
        address: kidData.address,
        parentPhone: kidData.parentPhone,
        emergencyContact: kidData.emergencyContact,
        emergencyPhone: kidData.emergencyPhone,
        insuranceProvider: kidData.insuranceProvider,
        insuranceNumber: kidData.insuranceNumber,
        doctorName: kidData.doctorName,
        doctorPhone: kidData.doctorPhone,
        medicalNotes: kidData.medicalNotes,
        insuranceInfo: kidData.insuranceInfo,
        createdAt: now,
        updatedAt: now,
      );

      // Update the document with its own ID to ensure consistency
      await docRef.update({'id': docRef.id});

      kids.add(newKid);

      Get.snackbar(
        'Success',
        'Kid profile added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('Error adding kid: $e');
      Get.snackbar(
        'Error',
        'Failed to add kid profile',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update an existing kid
  Future<bool> updateKid(KidData kidData) async {
    try {
      isSaving.value = true;
      print('🔄 Updating kid with ID: "${kidData.id}"');
      
      // Validate that we have a valid ID
      if (kidData.id.isEmpty) {
        print('❌ Cannot update kid: ID is empty');
        throw Exception('Kid ID cannot be empty');
      }
      
      final now = DateTime.now();

      final updatedKid = KidData(
        id: kidData.id,
        userId: kidData.userId,
        name: kidData.name,
        dateOfBirth: kidData.dateOfBirth,
        gender: kidData.gender,
        bloodType: kidData.bloodType,
        allergies: kidData.allergies,
        address: kidData.address,
        parentPhone: kidData.parentPhone,
        emergencyContact: kidData.emergencyContact,
        emergencyPhone: kidData.emergencyPhone,
        insuranceProvider: kidData.insuranceProvider,
        insuranceNumber: kidData.insuranceNumber,
        doctorName: kidData.doctorName,
        doctorPhone: kidData.doctorPhone,
        medicalNotes: kidData.medicalNotes,
        insuranceInfo: kidData.insuranceInfo,
        createdAt: kidData.createdAt,
        updatedAt: now,
      );

      await _firestore
          .collection('kids')
          .doc(kidData.id)
          .update(updatedKid.toJson());

      final index = kids.indexWhere((kid) => kid.id == kidData.id);
      if (index != -1) {
        kids[index] = updatedKid;
      }

      Get.snackbar(
        'Success',
        'Kid profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('Error updating kid: $e');
      Get.snackbar(
        'Error',
        'Failed to update kid profile',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete a kid
  Future<bool> deleteKid(String kidId) async {
    try {
      await _firestore.collection('kids').doc(kidId).delete();

      kids.removeWhere((kid) => kid.id == kidId);

      Get.snackbar(
        'Success',
        'Kid profile deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('Error deleting kid: $e');
      Get.snackbar(
        'Error',
        'Failed to delete kid profile',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get kid by ID
  KidData? getKidById(String kidId) {
    return kids.firstWhereOrNull((kid) => kid.id == kidId);
  }

  /// Select a kid
  void selectKid(KidData kid) {
    selectedKid.value = kid;
  }
}
