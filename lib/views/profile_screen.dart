import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  Map<String, dynamic>? userData;

  // Controllers for editing profile fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // GlobalKey for the form
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Fetch user data from Firebase
  Future<void> _getUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
          _nameController.text = userData?['name'] ?? '';
          _phoneController.text = userData?['phone'] ?? '';
        });
      }
    }
  }

  // Method to update the user details (name and phone only)
  Future<void> _updateUserDetails() async {
    if (_formKey.currentState!.validate()) {
      // Validate inputs before updating
      if (user != null) {
        try {
          // Update Firestore user data (name and phone only)
          await _firestore.collection('users').doc(user!.uid).update({
            'name': _nameController.text,
            'phone': _phoneController.text,
          });

          Get.snackbar("Success", "Profile updated successfully!");
          _getUserData(); // Refresh user data
        } catch (e) {
          Get.snackbar("Error", "Failed to update profile: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Profile Information",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      _buildTextField("Name", _nameController, (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      }),
                      SizedBox(height: 20),

                      // Email is read-only and not editable
                      _buildReadOnlyTextField("Email", userData?['email'] ?? ''),
                      SizedBox(height: 20),

                      _buildTextField("Phone Number", _phoneController, (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number cannot be empty';
                        }
                        if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                          return 'Phone number must be 11 digits';
                        }
                        return null;
                      }),
                      SizedBox(height: 30),

                      // Update Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _updateUserDetails,
                          icon: Icon(Icons.save),
                          label: Text("Update Profile"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,  
    );
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
