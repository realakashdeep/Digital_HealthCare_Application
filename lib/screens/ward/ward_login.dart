import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:final_year_project/provider/ward_user_provider.dart';
import 'package:final_year_project/screens/ward/ward_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/ward_auth_provider.dart';
import '../../provider/care_givers_auth_provider.dart';
import '../../provider/doctors_auth_provider.dart';
import 'care_givers/careGiversMenu.dart';
import 'doctors/doctorsMenuPage.dart';

class WardLoginPage extends StatefulWidget {
  @override
  _WardLoginPageState createState() => _WardLoginPageState();
}

class _WardLoginPageState extends State<WardLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true; // Initially obscure the password
  String _selectedRole = 'Ward'; // Default selected role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Digital HealthCare Facilities'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 22),
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 40),
                  // Dropdown menu
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: <String>['Ward', 'Care Givers', 'Doctor']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Log In As',
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  buildTextField(_emailController, 'Email', 'Enter Email'),
                  SizedBox(height: 16),
                  buildTextField(_passwordController, 'Password', 'Enter Password', obscureText: _obscureText),
                  SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          switch (_selectedRole) {
                            case 'Ward':
                              await _handleWardLogin(context);
                              break;
                            case 'Care Givers':
                              await _handleCareGiversLogin(context);
                              break;
                            case 'Doctor':
                              await _handleDoctorLogin(context);
                              break;
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed: $error')),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize: Size(300, 40),
                    ),
                    child: Text('Log In', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleWardLogin(BuildContext context) async {
    try {
      // Check if the ward email exists
      bool exists = await _checkWardEmailExists('Wards', _emailController.text);
      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ward email not found')),
        );
        return;
      }

      // Sign in the ward user
      final wardAuthProvider = Provider.of<WardAuthProvider>(context, listen: false);
      await wardAuthProvider.signIn(_emailController.text, _passwordController.text);
      final ward = wardAuthProvider.ward;


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WardMenuPage()),
              (route) => false,
        );

    } catch (error) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed login: $error')),
      );
    }
  }



  Future<void> _handleCareGiversLogin(BuildContext context) async {
    final careGiversAuthProvider = Provider.of<CareGiversAuthProvider>(context, listen: false);

    try {

      bool exists = await _checkEmailExists('caregivers', _emailController.text);
      bool passExists = await _checkPassExists('caregivers', _passwordController.text);
      print(exists);
      if (exists && passExists) {
        print("mail & pass exists");
        await careGiversAuthProvider.signIn(_emailController.text, _passwordController.text);


          print("user is  not null ");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => CareGiversMenuPage()),
                (route) => false,
          );

      } else {
        print("Wrong Credentials");
        if(exists && !passExists)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password does not match.')),
          );
        else if(!exists && passExists)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mail does not exist. Register First.')),
          );
        else if(!exists && !passExists)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong Credentials')),
          );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    }
  }
  Future<void> _handleDoctorLogin(BuildContext context) async {
    User? _user;
    final doctorsAuthProvider = Provider.of<DoctorsAuthProvider>(context, listen: false);
    bool passExists = await _checkPassExists('doctors', _passwordController.text);
    bool exists = await _checkEmailExists('doctors', _emailController.text);

    try {
      print(exists && passExists);

      if (exists && passExists) {
        print("exists.");
        _user = await doctorsAuthProvider.signIn(_emailController.text, _passwordController.text);

        if (_user != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DoctorsMenuPage()),
                (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: User not found after sign-in')),
          );
        }
      } else {
        if(exists && !passExists)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password does not match.')),
          );
        else if(!exists && passExists)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mail does not exist. Register First.')),
          );
        else if(!exists && !passExists)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong Credentials')),
          );
      }
    } catch (error) {
      print("Error during login: $error"); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${error.toString()}')),
      );
      if(exists && !passExists)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password does not match.')),
        );
      else if(!exists && passExists)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mail does not exist. Register First.')),
        );
      else if(!exists && !passExists)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wrong Credentials')),
        );
    }
  }


  String _encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    print(digest);
    return digest.toString();
  }



  Widget buildTextField(TextEditingController controller, String labelText, String hintText, {bool obscureText = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }

          if (labelText == 'Email') {
            RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegExp.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          } else if (labelText == 'Ward ID') {
            RegExp wardIdRegExp = RegExp(r'^[A-Z]{3}\d{6}$');
            if (!wardIdRegExp.hasMatch(value)) {
              return 'Invalid Ward ID format. Example: KMC001050';
            }
          } else if (labelText == 'Password') {
            if (value.contains(' ')) {
              return 'Password cannot contain spaces';
            }

            if (value.length < 6) {
              return 'Password cannot be less than 6 characters';
            }

            if (value.length > 32) {
              return 'Password cannot be longer than 32 characters';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: labelText == 'Password'
              ? IconButton(
            icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  Future<bool> _checkEmailExists(String collection, String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if(querySnapshot.docs.isNotEmpty)
      print("email exists");
    else
      print("email does not exist");
    return querySnapshot.docs.isNotEmpty;
  }
  Future<bool> _checkPassExists(String collection, String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('password', isEqualTo: email)
        .limit(1)
        .get();
    if(querySnapshot.docs.isNotEmpty)
      print("pass exists");
    else
      print("pass does not exist");
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> _checkWardEmailExists(String collection, String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('wardEmail', isEqualTo: email)
        .limit(1)
        .get();
    if(querySnapshot.docs.isNotEmpty)
      print("email exists");
    else
      print("email does not exist");
    return querySnapshot.docs.isNotEmpty;
  }
}
