import 'package:get/get.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  void setUser(UserModel user) {
    currentUser.value = user;
  }

  void logout() {
    currentUser.value = null;
  }

  // ✅ Add this getter
  bool get isAdmin => currentUser.value?.role?.toLowerCase() == 'admin';
}
