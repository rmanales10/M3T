import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList<Map<String, dynamic>> allRecord = <Map<String, dynamic>>[].obs;
  Future<void> fetchAllRecord() async {
    QuerySnapshot querySnapshot = await _firestore.collection('record').get();
    allRecord.value = querySnapshot.docs
        .map((doc) => {
              'section': doc['section'],
              'datenow': doc['datenow'],
              'subject': doc['subject'],
              'student_record': doc['student_record'],
            })
        .toList();
  }
}
