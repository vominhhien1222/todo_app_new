import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';

class AdminUsersProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  Stream<List<AppUser>> streamUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((e) => AppUser.fromDoc(e)).toList());
  }

  Future<void> setUserStatus(String uid, bool lock) async {
    await _db.collection('users').doc(uid).update({
      'status': lock ? 'locked' : 'active',
    });
  }
}
