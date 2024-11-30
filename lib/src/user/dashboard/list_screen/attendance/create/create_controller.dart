import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:math' as rnd;

class CreateController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  String generateUniqueId() {
    var random = rnd.Random();
    int randomNumber = 1000000 + random.nextInt(9000000);
    return 'attendance-$randomNumber';
  }

  Future<void> createAttendance(
      {required var subject,
      required var section,
      required var date,
      required var time}) async {
    String autoId = generateUniqueId();
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('attendance')
          .doc(autoId)
          .set({
        'id': autoId,
        'section': section,
        'date': date,
        'time': time,
        'subject': subject,
        'is_submitted': false,
      }, SetOptions(merge: true));
    } catch (e) {
      log('error $e');
    }
  }
}
