import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:math' as rnd;

class ListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  String generateUniqueId() {
    var random = rnd.Random();
    int randomNumber = 1000000 + random.nextInt(9000000);
    return 'record-$randomNumber';
  }

  RxList<Map<String, dynamic>> studentList = <Map<String, dynamic>>[].obs;
  Future<void> getStudentsList(
      {required var section, required var subject}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('students')
        .where('section_year_block', isEqualTo: section)
        .get();

    studentList.value = querySnapshot.docs
        .map((doc) => {
              'id': doc['id'],
              'section_year_block': doc['section_year_block'],
              'subject': doc['subject'],
              'full_name': doc['full_name'],
            })
        .toList();
  }

  Future<void> addAttendanceStudentRecord({
    required var attendanceId,
    required var code,
    required var datenow,
    required var room,
    required var schedule,
    required var studentRecord,
    required var subject,
    required var teacher,
    required var section,
  }) async {
    await _firestore.collection('record').doc(attendanceId).set({
      'attendance_id': attendanceId,
      'code': code,
      'datenow': datenow,
      'room': room,
      'schedule': schedule,
      'student_record': studentRecord,
      'subject': subject,
      'teacher': teacher,
      'user_id': currentUser!.uid,
      'section': section,
      'is_submitted': false,
    }, SetOptions(merge: true));
  }

  RxMap<String, dynamic> attendaceStudentRecord = <String, dynamic>{}.obs;
  Future<void> printAttendanceStudentRecord({required var attendanceId}) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('record').doc(attendanceId).get();
      if (documentSnapshot.exists) {
        attendaceStudentRecord.value =
            documentSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error $e');
    }
  }

  Future<void> isSubmitted({required var attendanceId}) async {
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('attendance')
        .doc(attendanceId)
        .set({'is_submitted': true}, SetOptions(merge: true));
  }
}
