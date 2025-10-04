import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> ensureUserDoc() async {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) return;

  final ref = FirebaseFirestore.instance.collection('users').doc(u.uid);
  final snap = await ref.get();

  if (!snap.exists) {
    await ref.set({
      'name': u.displayName,
      'email': u.email,
      // role trong doc này chỉ để hiển thị; quyền thật nằm ở custom claims
      'role': 'user',
      'status': 'active', // 🔴 mặc định active
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  } else {
    final data = snap.data() as Map<String, dynamic>;
    final updates = <String, dynamic>{
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
    if (data['status'] == null) {
      updates['status'] = 'active';
    }
    if (updates.isNotEmpty) {
      await ref.update(updates);
    }
  }
}
