import 'package:get/get.dart';

class ProfileController extends GetxController {
  var name = "Sweekriti Diwakar".obs;
  var email = "sweekriti@gmail.com".obs;
  var password = "password123".obs;

  void updateProfile(String newName, String newEmail, String newPassword) {
    name.value = newName;
    email.value = newEmail;
    password.value = newPassword;
  }
}
