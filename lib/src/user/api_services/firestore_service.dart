import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable collections and counts
  var attendanceRecords = <Map<String, dynamic>>[].obs;
  var userData = {}.obs;
  var studentData = <Map<String, dynamic>>[].obs;
  var studentAttendanceRecords = <Map<String, dynamic>>[].obs;
  var attendanceId = "".obs;
  RxInt presentCount = 0.obs;
  RxInt absentCount = 0.obs;
  RxInt totalCount = 0.obs;
  var subjects = [].obs;

  // Fetch user data
  Future<void> fetchUserData(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(documentId).get();
      if (documentSnapshot.exists) {
        userData.value = documentSnapshot.data() as Map<String, dynamic>;
      } else {
        log("No document found with ID: $documentId");
      }
    } catch (e) {
      log("Error fetching user data: $e");
    }
  }

  // Fetch all students
  Future<void> getAllStudent() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('students').get();
      studentData.value = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'fullname': doc['fullname'],
          'idnumber': doc['idnumber'],
          'section': doc['section'],
        };
      }).toList();
    } catch (e) {
      log("Error fetching students: $e");
      studentData.clear();
    }
  }

  // Retrieve or create an attendance document ID
  Future<String> getOrCreateAttendanceId({
    required String userId,
    required DateTime date,
    required String section,
    required String subject,
    required String time,
  }) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .where('date', isEqualTo: Timestamp.fromDate(date))
          .where('subject', isEqualTo: subject)
          .where('section', isEqualTo: section)
          .where('time', isEqualTo: time)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      } else {
        DocumentReference docRef = await _firestore
            .collection('users')
            .doc(userId)
            .collection('attendance')
            .add({
          'date': date,
          'section': section,
          'subject': subject,
          'time': time,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return docRef.id;
      }
    } catch (e) {
      log('Error retrieving or creating attendance document: $e');
      rethrow;
    }
  }

  // Store an attendance record
  Future<void> storeAttendanceRecord({
    required String userId,
    required String attendanceId,
    required String recordId,
    required String fullname,
    required String idnumber,
    required String section,
    required String subject,
    required DateTime date,
    required bool isAbsent,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(attendanceId)
          .collection('record')
          .doc(recordId)
          .set({
        'fullname': fullname,
        'idnumber': idnumber,
        'section': section,
        'subject': subject,
        'date': date,
        'isAbsent': isAbsent,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Attendance record saved successfully!',
          snackPosition: SnackPosition.TOP, duration: Duration(seconds: 1));
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong!',
          snackPosition: SnackPosition.TOP);
    }
  }

  // Retrieve attendance records for a specific user
  Future<void> retrieveAttendance({required String userId}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> records = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'date': (doc['date'] as Timestamp).toDate(),
          'section': doc['section'],
          'subject': doc['subject'],
          'time': doc['time'] as String,
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
      attendanceRecords.value = records;
    } catch (e) {
      log('Error retrieving attendance: $e');
      attendanceRecords.clear();
    }
  }

  // Retrieve records in a specific attendance document's record subcollection
  Future<void> retrieveAttendanceRecord({
    required String userId,
    required String attendanceId,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(attendanceId)
          .collection('record')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> records = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'fullname': doc['fullname'],
          'idnumber': doc['idnumber'],
          'section': doc['section'],
          'subject': doc['subject'],
          'isAbsent': doc['isAbsent'],
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();

      studentAttendanceRecords.value = records;
    } catch (e) {
      log('Error retrieving attendance record: $e');
      studentAttendanceRecords.clear();
    }
  }

  // Delete an attendance record
  Future<void> deleteAttendanceRecord({
    required String userId,
    required String attendanceId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(attendanceId)
          .delete();

      Get.snackbar('Success', 'Attendance record deleted!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(milliseconds: 1));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete attendance record',
        snackPosition: SnackPosition.TOP,
      );
      log("Error deleting attendance record: $e");
    }
  }

  // Fetch attendance status for students within an attendance document
  Future<void> getStudentAttendanceStatus({
    required String userId,
    required String attendanceId,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(attendanceId)
          .collection('record')
          .get();

      for (var doc in querySnapshot.docs) {
        studentAttendanceRecords.add({
          'id': doc.id,
          'isAbsent': doc['isAbsent'] ?? true,
        });
      }
    } catch (e) {
      log('Error fetching student attendance status: $e');
    }
  }

  // Retrieve attendance ID based on date
  Future<void> getAllAttendanceStatus({
    required String userId,
    required DateTime date,
    required String section,
    required String subject,
  }) async {
    // Define start and end of the day for querying
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      // Query the Firestore collection for the attendance records
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('section', isEqualTo: section)
          .where('subject', isEqualTo: subject)
          .get();

      // Check if documents are returned and set the attendanceId value accordingly
      if (querySnapshot.docs.isNotEmpty) {
        attendanceId.value = querySnapshot.docs.first.id; // Use the first match
      } else {
        attendanceId.value = ""; // No match found, set to empty
      }
    } catch (e) {
      // Log any errors and set attendanceId to an empty string in case of failure
      log("Error retrieving attendance status: $e");
      attendanceId.value = "";
    }
  }

  // Fetch sections and subjects
  Future<void> fetchSectionsAndSubjects({required String userId}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .get();

      List<Map<String, dynamic>> records = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'date': doc['date'],
          'section': doc['section'],
          'subject': doc['subject'],
          'time': doc['time'],
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
      subjects.value = records;
    } catch (e) {
      log("Error fetching sections and subjects: $e");
    }
  }

  // Get attendance counts
  Future<void> getAttendanceCounts({
    required String userId,
    required String attendanceId,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(attendanceId)
          .collection('record')
          .get();

      presentCount.value = 0;
      absentCount.value = 0;
      totalCount.value = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        bool isAbsent = doc['isAbsent'] ?? true;
        if (isAbsent) {
          absentCount.value++;
        } else {
          presentCount.value++;
        }
      }

      log("Attendance ID: $attendanceId, Present: ${presentCount.value}, Absent: ${absentCount.value}, Total: ${totalCount.value}");
    } catch (e) {
      log('Error fetching attendance counts: $e');
    }
  }
}
