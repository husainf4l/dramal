import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vaccine_model.dart';
import '../models/kid_model.dart';

class VaccineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable states
  RxList<VaccineData> vaccines = <VaccineData>[].obs;
  RxList<VaccineRecord> vaccineRecords = <VaccineRecord>[].obs;
  RxBool isLoadingVaccines = false.obs;
  RxBool isLoadingRecords = false.obs;
  RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadVaccines();
  }

  /// Load all available vaccines
  Future<void> loadVaccines() async {
    try {
      isLoadingVaccines.value = true;
      print('🔍 Loading vaccines...');

      final querySnapshot = await _firestore
          .collection('vaccines')
          .orderBy('recommendedAgeMonths')
          .get();

      print('📊 Found ${querySnapshot.docs.length} vaccine documents');

      final vaccinesList = <VaccineData>[];

      for (final doc in querySnapshot.docs) {
        try {
          final vaccineData = VaccineData.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
          vaccinesList.add(vaccineData);
          print('✅ Successfully loaded vaccine: ${vaccineData.name}');
        } catch (e) {
          print('❌ Error parsing vaccine document ${doc.id}: $e');
        }
      }

      vaccines.assignAll(vaccinesList);
      print('✅ Successfully loaded ${vaccinesList.length} vaccines');
    } catch (e) {
      print('❌ Error loading vaccines: $e');
      Get.snackbar(
        'Error',
        'Failed to load vaccines: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingVaccines.value = false;
    }
  }

  /// Load vaccine records for a specific kid
  Future<void> loadVaccineRecordsForKid(String kidId) async {
    try {
      isLoadingRecords.value = true;
      print('🔍 Loading vaccine records for kid: $kidId');

      final querySnapshot = await _firestore
          .collection('vaccine_records')
          .where('kidId', isEqualTo: kidId)
          .orderBy('administeredDate', descending: true)
          .get();

      print('📊 Found ${querySnapshot.docs.length} vaccine record documents');

      final recordsList = <VaccineRecord>[];

      for (final doc in querySnapshot.docs) {
        try {
          final recordData = VaccineRecord.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
          recordsList.add(recordData);
        } catch (e) {
          print('❌ Error parsing vaccine record document ${doc.id}: $e');
        }
      }

      vaccineRecords.assignAll(recordsList);
      print('✅ Successfully loaded ${recordsList.length} vaccine records');
    } catch (e) {
      print('❌ Error loading vaccine records: $e');
      Get.snackbar(
        'Error',
        'Failed to load vaccine records: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRecords.value = false;
    }
  }

  /// Add a new vaccine record
  Future<bool> addVaccineRecord(VaccineRecord record) async {
    try {
      isSaving.value = true;
      final now = DateTime.now();

      final recordWithTimestamps = VaccineRecord(
        id: '',
        kidId: record.kidId,
        vaccineId: record.vaccineId,
        administeredDate: record.administeredDate,
        administeredBy: record.administeredBy,
        batchNumber: record.batchNumber,
        notes: record.notes,
        isBooster: record.isBooster,
        nextDueDate: record.nextDueDate,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore
          .collection('vaccine_records')
          .add(recordWithTimestamps.toJson());

      final newRecord = VaccineRecord(
        id: docRef.id,
        kidId: record.kidId,
        vaccineId: record.vaccineId,
        administeredDate: record.administeredDate,
        administeredBy: record.administeredBy,
        batchNumber: record.batchNumber,
        notes: record.notes,
        isBooster: record.isBooster,
        nextDueDate: record.nextDueDate,
        createdAt: now,
        updatedAt: now,
      );

      vaccineRecords.add(newRecord);

      Get.snackbar(
        'Success',
        'Vaccine record added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('❌ Error adding vaccine record: $e');
      Get.snackbar(
        'Error',
        'Failed to add vaccine record: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update an existing vaccine record
  Future<bool> updateVaccineRecord(VaccineRecord record) async {
    try {
      isSaving.value = true;
      final now = DateTime.now();

      final updatedRecord = VaccineRecord(
        id: record.id,
        kidId: record.kidId,
        vaccineId: record.vaccineId,
        administeredDate: record.administeredDate,
        administeredBy: record.administeredBy,
        batchNumber: record.batchNumber,
        notes: record.notes,
        isBooster: record.isBooster,
        nextDueDate: record.nextDueDate,
        createdAt: record.createdAt,
        updatedAt: now,
      );

      await _firestore
          .collection('vaccine_records')
          .doc(record.id)
          .update(updatedRecord.toJson());

      final index = vaccineRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        vaccineRecords[index] = updatedRecord;
      }

      Get.snackbar(
        'Success',
        'Vaccine record updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('❌ Error updating vaccine record: $e');
      Get.snackbar(
        'Error',
        'Failed to update vaccine record: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete a vaccine record
  Future<bool> deleteVaccineRecord(String recordId) async {
    try {
      await _firestore.collection('vaccine_records').doc(recordId).delete();

      vaccineRecords.removeWhere((record) => record.id == recordId);

      Get.snackbar(
        'Success',
        'Vaccine record deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('❌ Error deleting vaccine record: $e');
      Get.snackbar(
        'Error',
        'Failed to delete vaccine record: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get vaccine status for a specific kid
  Future<List<KidVaccineStatus>> getVaccineStatusForKid(
      String kidId, KidData kid) async {
    try {
      // Load vaccine records for this kid
      await loadVaccineRecordsForKid(kidId);

      final statusList = <KidVaccineStatus>[];

      for (final vaccine in vaccines) {
        // Get records for this vaccine
        final vaccineRecordsForVaccine = vaccineRecords
            .where((record) => record.vaccineId == vaccine.id)
            .toList();

        // Determine status
        String status;
        bool isCompleted;
        DateTime? lastAdministeredDate;
        DateTime? nextDueDate;

        if (vaccineRecordsForVaccine.isNotEmpty) {
          // Sort records by date (most recent first)
          vaccineRecordsForVaccine
              .sort((a, b) => b.administeredDate.compareTo(a.administeredDate));

          lastAdministeredDate =
              vaccineRecordsForVaccine.first.administeredDate;

          // Check if booster is needed
          final latestRecord = vaccineRecordsForVaccine.first;
          if (latestRecord.nextDueDate != null) {
            nextDueDate = latestRecord.nextDueDate;
            if (nextDueDate!.isBefore(DateTime.now())) {
              status = 'overdue';
              isCompleted = false;
            } else if (nextDueDate.difference(DateTime.now()).inDays <= 30) {
              status = 'due';
              isCompleted = false;
            } else {
              status = 'completed';
              isCompleted = true;
            }
          } else {
            status = 'completed';
            isCompleted = true;
          }
        } else {
          // No records found - check if vaccine is due based on age
          final ageInDays = DateTime.now().difference(kid.dateOfBirth).inDays;
          final recommendedDate = DateTime.now().subtract(
            Duration(days: ageInDays - (vaccine.recommendedAgeMonths * 30)),
          );

          if (recommendedDate.isBefore(DateTime.now())) {
            status = 'overdue';
            isCompleted = false;
          } else if (recommendedDate.difference(DateTime.now()).inDays <= 30) {
            status = 'due';
            isCompleted = false;
          } else {
            status = 'upcoming';
            isCompleted = false;
          }
        }

        statusList.add(KidVaccineStatus(
          vaccine: vaccine,
          records: vaccineRecordsForVaccine,
          isCompleted: isCompleted,
          lastAdministeredDate: lastAdministeredDate,
          nextDueDate: nextDueDate,
          status: status,
        ));
      }

      return statusList;
    } catch (e) {
      print('❌ Error getting vaccine status: $e');
      return [];
    }
  }

  /// Get records for a specific vaccine and kid
  List<VaccineRecord> getRecordsForVaccine(String vaccineId, String kidId) {
    return vaccineRecords
        .where(
            (record) => record.vaccineId == vaccineId && record.kidId == kidId)
        .toList();
  }

  /// Get vaccine by ID
  VaccineData? getVaccineById(String vaccineId) {
    return vaccines.firstWhereOrNull((vaccine) => vaccine.id == vaccineId);
  }

  /// Get record by ID
  VaccineRecord? getRecordById(String recordId) {
    return vaccineRecords.firstWhereOrNull((record) => record.id == recordId);
  }
}
