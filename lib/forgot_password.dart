import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'background.dart';

class PasswordRecovery extends StatefulWidget {
  const PasswordRecovery({super.key});

  @override
  State<PasswordRecovery> createState() => _PasswordRecoveryState();
}

class _PasswordRecoveryState extends State<PasswordRecovery> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var isObscure = true.obs;
  var step = 1.obs;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Background(
          child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  step.value == 1 ? "EMAIL VERIFICATION" : "PASSWORD RESET",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2661FA),
                    fontSize: 36,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              if (step.value == 1) buildEmailVerificationStep(size),
              if (step.value == 2) buildPasswordResetStep(size),
            ],
          )),
        ),
      ),
    );
  }

  Widget buildEmailVerificationStep(Size size) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "Email",
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                verifyEmail();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 255, 136, 34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              ),
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                width: size.width * 0.5,
                child: Text(
                  "VERIFY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordResetStep(Size size) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: Obx(() => TextFormField(
            controller: newPasswordController,
            obscureText: isObscure.value,
            decoration: InputDecoration(
              labelText: "New Password",
              suffixIcon: GestureDetector(
                onTap: () {
                  isObscure.toggle();
                },
                child: Icon(
                  isObscure.value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
              ),
            ),
          )),
        ),
        SizedBox(height: size.height * 0.03),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: Obx(() => TextFormField(
            controller: confirmPasswordController,
            obscureText: isObscure.value,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              suffixIcon: GestureDetector(
                onTap: () {
                  isObscure.toggle();
                },
                child: Icon(
                  isObscure.value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
              ),
            ),
          )),
        ),
        SizedBox(height: size.height * 0.03),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                resetPassword();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 255, 136, 34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              ),
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                width: size.width * 0.5,
                child: Text(
                  "RESET",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> verifyEmail() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.131.73.249/solarpower/verifyemail.php"),
        body: {'email': emailController.text},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey("success")) {
          // Email verification successful, proceed to password reset
          step.value = 2;
        } else {
          // Email not found in the database
          showErrorDialog(responseData["error"]);
        }
      } else {
        throw Exception('Failed to verify email: ${response.statusCode}');
      }
    } catch (e) {
      showErrorDialog("Failed to verify email. Please try again.");
    }
  }


  Future<void> resetPassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      showErrorDialog("Passwords do not match.");
      return;
    }

    try {
      Map<String, dynamic> postData = {
        'email': emailController.text,
        'password': newPasswordController.text,
      };

      final response = await http.post(
        Uri.parse("http://10.131.73.249/solarpower/recoverpassword.php"),
        body: postData,
      );

      if (response.statusCode == 200) {
        if (response.body.contains("Error")) {
          showErrorDialog(response.body);
        } else {
          showSuccessDialog("Password has been reset.");
        }
      } else {
        throw Exception('Failed to reset password: ${response.statusCode}');
      }
    } catch (e) {
      showErrorDialog("Failed to reset password. Please try again.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    emailController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}