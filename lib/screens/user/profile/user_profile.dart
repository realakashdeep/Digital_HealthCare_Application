
import 'package:final_year_project/screens/user/user_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../constants/text_strings.dart';
import '../../../models/user_model.dart';
import '../../../services/user_services.dart';
import 'edit_profile.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final UserService _userService = UserService();
   MyUser? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      MyUser? user = await _userService.getUser(userId!);
      if (user != null) {
        setState(() {
          _user = user;
        });
      } else {
        // Handle case where user data is not found
      }
    } catch (e) {
      throw(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tProfile),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _user != null ? _buildUserProfile() : _buildLoadingIndicator(),
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Profile photo (Replace with actual user photo)
          Container(
            width: 200.0,
            height: 200.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/rwd.jpeg'), // Replace with actual image
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20.0),

          // User name
          Text(
            _user!.name,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),

          // Email (Replace with actual user email)
          buildUserInfo(tPhoneNumber, _user!.phoneNumber),
          SizedBox(height: 10.0),

          // Gender (Replace with actual user gender)
          buildUserInfo(tGender, _user!.gender),
          SizedBox(height: 10.0),

          // Address (Replace with actual user address)
          buildUserInfo(tAddress, _user!.district+" "+_user!.state),
          SizedBox(height: 10.0),

          // Aadhar Number (Replace with actual user Aadhar number)
          buildUserInfo(tAadharNumber, _user!.aadhaarNumber),
          SizedBox(height: 20.0),

          // Edit profile button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
            },
            child: Text(tEditProfile),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),

          // Log out button (Implement logout functionality)
          ElevatedButton(
            onPressed: () async {
              _userService.signOut().then(
                      (value) => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => UserLogin()),
                            (Route<dynamic> route) => false,
                      )
                );
            },
            child: Text(tLogOut),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildUserInfo(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10.0),
        Text(value),
      ],
    );
  }
}
