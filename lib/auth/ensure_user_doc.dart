import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🔹 Đảm bảo user hiện tại có document trong Firestore.
/// - Nếu là user mới → tạo doc mới với role mặc định.
/// - Nếu đã có → cập nhật lại thời gian đăng nhập gần nhất.
/// - Nếu email trùng trong danh sách admin → tự set role = 'admin'.
Future<void> ensureUserDoc() async {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) return;

  final ref = FirebaseFirestore.instance.collection('users').doc(u.uid);
  final snap = await ref.get();

  // 🔹 Danh sách email của admin (có thể thay bằng fetch từ Firestore riêng nếu cần)
  const adminEmails = [
    'admin123@gmail.com',
    'superadmin@gmail.com',
    'hienadmin@gmail.com', // thêm email admin của bạn ở đây
  ];

  if (!snap.exists) {
    // 🆕 User mới → tạo document
    final role = adminEmails.contains(u.email) ? 'admin' : 'user';

    await ref.set({
      'name': u.displayName ?? 'Người dùng mới',
      'email': u.email,
      'role': role, // ✅ Tự nhận admin nếu nằm trong danh sách
      'status': 'active', // 🔹 Mặc định active
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  } else {
    // 🔁 User cũ → cập nhật thời gian đăng nhập
    final data = snap.data() as Map<String, dynamic>;
    final updates = <String, dynamic>{
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    // 🔹 Nếu thiếu status hoặc role thì bổ sung
    if (data['status'] == null) updates['status'] = 'active';
    if (data['role'] == null) {
      final role = adminEmails.contains(u.email) ? 'admin' : 'user';
      updates['role'] = role;
    }

    if (updates.isNotEmpty) {
      await ref.update(updates);
    }
  }
}
