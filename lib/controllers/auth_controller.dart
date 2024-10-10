import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => HomeScreen());
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // The user canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user?.uid).get();

      if (!userDoc.exists) {
        // If the user doesn't exist, create a new user document
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': userCredential.user?.displayName,
          'email': userCredential.user?.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Get.offAllNamed('/home'); // Navigate to the home screen
    } catch (e) {
      Get.snackbar("Error", "Failed to sign in with Google: $e");
    }
  }

  // Register user and create initial collections
  void registerUser(String email, String password, String name, String phone) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Create a new document in the 'users' collection with the user's ID
        await _firestore.collection("users").doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': name,
          'phone': phone,
          'createdAt': DateTime.now(),
        });

        Get.snackbar("Success", "Account created successfully!",
            snackPosition: SnackPosition.BOTTOM);
        _setInitialScreen(
            user); // Navigate to the home screen after registration
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Login user
  void loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Success", "Password reset email sent!");
    } catch (e) {
      Get.snackbar("Error", "Failed to send password reset email: $e");
    }
  }

  // Sign out user
  void signOut() async {
    await _auth.signOut();
  }
}
