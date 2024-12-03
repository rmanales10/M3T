import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final totalTeacher = 0.obs;
  final totalSubject = 0.obs;
  final totalSection = 0.obs;
  final totalStudent = 0.obs;

  Future<void> getTotal() async {
    try {
      QuerySnapshot teacherSnapshot =
          await _firestore.collection('users').get();
      totalTeacher.value = teacherSnapshot.docs.length;

      QuerySnapshot subjectSnapshot =
          await _firestore.collection('subjects').get();
      totalSubject.value = subjectSnapshot.docs.length;

      QuerySnapshot studentSnapshot =
          await _firestore.collection('students').get();
      totalStudent.value = studentSnapshot.docs.length;

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('students').get();

      Set<String> uniqueSectionYearBlocks = Set<String>();

      snapshot.docs.forEach((doc) {
        if (doc.data() != null &&
            (doc.data() as Map<String, dynamic>)
                .containsKey('section_year_block')) {
          String sectionYearBlock =
              (doc.data() as Map<String, dynamic>)['section_year_block'];
          uniqueSectionYearBlocks.add(sectionYearBlock);
        }
      });

      totalSection.value = uniqueSectionYearBlocks.length;
    } catch (e) {
      log('Error $e');
    }
  }
}
