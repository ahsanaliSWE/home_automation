import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();

    Get.defaultDialog(
      title: "Forgot Password",
      content: Column(
        children: [
          Text("Enter your email address to receive a password reset link."),
          SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      confirm: TextButton(
        onPressed: () {
          authController.resetPassword(emailController.text.trim());
          Get.back(); // Close the dialog
        },
        child: Text("Send Reset Link"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(), // Close the dialog
        child: Text("Cancel"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  authController.loginUser(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                },
                child: Text("Login"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  authController.signInWithGoogle(); // Call Google Sign-In method
                },
                child: Text("Sign in with Google"),
              ),
              TextButton(
                onPressed: () => _showForgotPasswordDialog(), // Show forgot password dialog
                child: Text("Forgot Password?"),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
