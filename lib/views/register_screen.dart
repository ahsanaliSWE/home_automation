import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  // Controllers for the registration form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name TextField
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // Phone TextField
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),

                // Email TextField
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // Password TextField
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // Confirm Password TextField
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text.trim() ==
                        confirmPasswordController.text.trim()) {
                      // Call register method with additional user details
                      authController.registerUser(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        nameController.text.trim(),
                        phoneController.text.trim(),
                      );
                    } else {
                      Get.snackbar("Error", "Passwords do not match",
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  child: Text("Register"),
                ),
                SizedBox(height: 10),

                // Navigate to login screen
                TextButton(
                  onPressed: () => Get.offAllNamed('/login'),
                  child: Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
