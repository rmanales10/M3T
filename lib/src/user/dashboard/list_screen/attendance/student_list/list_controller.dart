import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

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
}
