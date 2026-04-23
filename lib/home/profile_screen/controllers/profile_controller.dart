import 'package:get/get.dart';
import 'package:prepify/services/auth_service.dart';

class ProfileController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = AuthService.currentUser;
    if (user != null) {
      email.value = user.email ?? '';
      // always fetch the latest name from firestore; displayName may be stale
      final snap = await AuthService.getUserData(user.uid);
      name.value = snap.data()?['name'] ?? user.displayName ?? '';
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
  }

  Future<void> updateName(String newName) async {
    final user = AuthService.currentUser;
    if (user != null) {
      await AuthService.updateUserName(user.uid, newName);
      name.value = newName;
    }
  }
}
