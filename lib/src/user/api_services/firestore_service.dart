import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userData = {}.obs;
  RxInt presentCount = 0.obs;
  RxInt absentCount = 0.obs;
  RxInt totalCount = 0.obs;
  var subjects = [].obs;

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
