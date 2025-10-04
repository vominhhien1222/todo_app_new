import 'package:firebase_auth/firebase_auth.dart';

class RoleUtils {
  static Future<List<String>> getRoles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final token = await user.getIdTokenResult(true);
    final claims = token.claims ?? {};
    final raw = claims['roles'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  static Future<bool> isAdmin() async {
    final roles = await getRoles();
    return roles.contains('admin') || roles.contains('super_admin');
  }
}
