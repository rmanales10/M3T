import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ReportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList<Map<String, dynamic>> reports = <Map<String, dynamic>>[].obs;
  Future<void> getReports() async {
    QuerySnapshot querySnapshot = await _firestore.collection('reports').get();
    reports.value = querySnapshot.docs
        .map((doc) => {
              'attendance_id': doc['attendance_id'],
              'date': doc['date'],
              'section': doc['section'],
              'subject': doc['subject'],
              'type': doc['type'],
              'url': doc['url'],
            })
        .toList();
  }
}
