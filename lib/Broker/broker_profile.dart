import 'dart:io';
import 'package:dh/Navigation/basescaffold.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Registeration/signin.dart';

class BrokerProfile extends StatefulWidget {
  final String userPhoneNumber;

  const BrokerProfile({super.key, required this.userPhoneNumber});

  @override
  State<BrokerProfile> createState() => _BrokerProfileState();
}

class _BrokerProfileState extends State<BrokerProfile> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('userdata');

  String? userEmail;
  String? userName;
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final snapshot = await _database.child(widget.userPhoneNumber).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          userEmail = data['email'] ?? 'Email not available';
          userName = data['username'] ?? 'Username not available';
          profileImageUrl = data['profileImage'] ?? "";
        });
      } else {
        _showSnackBar("User data not found");
      }
    } catch (e) {
      _showSnackBar("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating, // Ensures it appears in front
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _editProfile() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _resetPassword,
                icon: const Icon(Icons.lock),
                label: const Text("Change Password"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _database.child(widget.userPhoneNumber).update({
                "username": nameController.text,
                "email": emailController.text,
              });
              setState(() {
                userName = nameController.text;
                userEmail = emailController.text;
              });
              Navigator.pop(context);
              _showSnackBar("Profile updated successfully");
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _resetPassword() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Reset Password"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        prefixIcon: Icon(Icons.lock),
                        errorMaxLines: 2, // Allows wrapping to the next line
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$')
                            .hasMatch(value)) {
                          return "Password contain 1 uppercase letter, 1"
                              " lowercase letter, 1 digit & 1 symbol.";
                        }
                        return null;
                      },
                    ),

                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await _database.child(widget.userPhoneNumber).update({
                        "password": passwordController.text,
                      });
                      Navigator.pop(context);

                      // Showing snackbar below reset button
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password reset successfully"),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text("Reset"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  bool _validatePassword(String password) {
    RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
    return regex.hasMatch(password);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImageUrl = pickedFile.path;
      });

      await _database.child(widget.userPhoneNumber).update({
        "profileImage": profileImageUrl,
      });

      _showSnackBar("Profile picture updated successfully!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Profile',
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.green)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? FileImage(File(profileImageUrl!))
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 15),

            // User Info Container
            Container(
              width: MediaQuery.of(context).size.width * 0.9, // Adjust width
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoTile(Icons.person, userName ?? "Username not available"),
                  _infoTile(Icons.email, userEmail ?? "Email not available"),
                  _infoTile(Icons.phone, widget.userPhoneNumber),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _profileButton("Edit Profile", Icons.edit, _editProfile),
            const SizedBox(height: 10),
            _logoutButton(),
          ],
        ),
      ),
    );
  }


  Widget _infoTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _profileButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.black),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.green),
      label: Text(text, style: const TextStyle(fontSize: 16, fontWeight:
      FontWeight.bold,color: Colors.green)),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Background remains white
        foregroundColor: Colors.black, // Text and icon color set to red
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.black), // Optional red border
      ),
      onPressed: _logout,
      icon: const Icon(Icons.logout, color: Colors.red, size: 20),
      label: const Text("Log Out",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
    );
  }


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
  }
}
