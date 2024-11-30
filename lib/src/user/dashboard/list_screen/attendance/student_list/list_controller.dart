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
    var autoId = generateUniqueId();

    await _firestore.collection('record').doc(autoId).set({
      'attendance_id': attendanceId,
      'code': code,
      'datenow': datenow,
      'id': autoId,
      'room': room,
      'schedule': schedule,
      'student_record': studentRecord,
      'subject': subject,
      'teacher': teacher,
      'user_id': currentUser!.uid,
      'section': section,
    }, SetOptions(merge: true));
  }

  RxList<Map<String, dynamic>> attendaceStudentRecord =
      <Map<String, dynamic>>[].obs;
  Future<void> printAttendanceStudentRecord({required var attendanceId}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('record')
        .where('attendance_id', isEqualTo: attendanceId)
        .get();
    attendanceId.value = querySnapshot.docs
        .map((doc) => {
              'attendance_id': doc['attendance_id'],
              'code': doc['code'],
              'datenow': doc['datenow'],
              'id': doc['id'],
              'room': doc['room'],
              'schedule': doc['schedule'],
              'section': doc['section'],
              'student_record': doc['student_record'],
              'subject': doc['subject'],
              'teacher': doc['teacher'],
              'user_id': doc['user_id'],
            })
        .toList();
  }
}
