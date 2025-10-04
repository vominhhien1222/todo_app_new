import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String status; // 'active' | 'locked'
  final List<String> roles;

  AppUser({
    required this.uid,
    this.displayName,
    this.email,
    required this.status,
    required this.roles,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      displayName: d['displayName'],
      email: d['email'],
      status: (d['status'] ?? 'active') as String,
      roles:
          (d['roles'] as List?)?.map((e) => e.toString()).toList() ??
          const ['user'],
    );
  }
}
