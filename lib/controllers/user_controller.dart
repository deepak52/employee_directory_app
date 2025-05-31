import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserController extends GetxController {
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadUserFromPrefs();
  }

  Future<void> setUser(UserModel user) async {
    currentUser.value = user;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      currentUser.value = UserModel.fromJson(jsonDecode(userString));
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  bool get isAdmin => currentUser.value?.role?.toLowerCase() == 'admin';
  bool get isLoggedIn => currentUser.value != null;
}
