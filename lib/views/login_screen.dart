import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_homeScreen_view.dart';
import 'employee_homescreen_view.dart'; // Screen after login
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final user = await ApiService.login(username, password);

    if (user != null) {
      print("Logged in user role: ${user.role}"); // Debug

      final userController = Get.find<UserController>();
      userController.setUser(user);

      final role = user.role?.toString().toLowerCase() ?? '';

      if (role == 'admin') {
        Get.off(() => AdminHomeView());
      } else if (role == 'employee') {
        Get.off(() => EmployeeHomeView());
      } else {
        setState(() {
          _error = "Unknown user role: ${user.role}";
        });
      }
    } else {
      setState(() {
        _error = "Invalid username or password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}
