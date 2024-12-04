import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<void> storeImage({required var image}) async {
    await _firestore.collection('users').doc(currentUser!.uid).set({
      'base64image': image,
    }, SetOptions(merge: true));
  }

  RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  Future<void> fetchUserInfo() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (documentSnapshot.exists) {
        userInfo.value = documentSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error $e');
    }
  }
}
