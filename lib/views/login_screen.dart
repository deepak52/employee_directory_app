import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_homeScreen_view.dart';
import 'employee_homescreen_view.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final user = await ApiService.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      final userController = Get.find<UserController>();
      userController.setUser(user);

      final role = user.role.toLowerCase();
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
          mainAxisAlignment: MainAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}
