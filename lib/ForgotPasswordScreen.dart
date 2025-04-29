import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isValidEmail = false;

  // Method to send password reset link to user's email
  void resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email using Firebase Authentication
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _isLoading = false;
      });

      // Show success message using Toast
      showToast('Password reset email sent! Check your inbox.', Colors.green);

      // Optionally, you can clear the text field after sending the email
      _emailController.clear();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? "An error occurred";
      });

      // Show error message using Toast
      showToast(_errorMessage, Colors.red);
    }
  }

  // Email validation to allow only specific domains
  void validateEmail(String email) {
    final validDomains = ['@upluniversity.ac.in', '@srict.in'];
    setState(() {
      if (email.isEmpty) {
        _isValidEmail = false;
      } else if (validDomains.any((domain) => email.endsWith(domain))) {
        _isValidEmail = true;
        _errorMessage = '';
      } else {
        _isValidEmail = false;
        _errorMessage = 'Please enter a valid email address with @upluniversity.ac.in or @srict.in domain.';
      }
    });
  }

  /// *🔹 Show Toast Message*
  void showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        centerTitle: true,
        actions: [

          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeData.brightness == Brightness.dark
                  ? Icons.wb_sunny // Sun for Light Mode
                  : Icons.nightlight_round, // Moon for Dark Mode
              color: Colors.white,
            ),
            onPressed: () {
              // Toggle the theme using the provider
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          )


        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 60),
              Text(
                'Reset Your Password',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'example@upluniversity.ac.in',
                  errorText: _errorMessage.isEmpty ? null : _errorMessage,
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (email) => validateEmail(email),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _isValidEmail ? resetPassword : null,
                child: Text('Send Password Reset Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
