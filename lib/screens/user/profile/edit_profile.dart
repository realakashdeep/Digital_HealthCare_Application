import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../models/user_model.dart';
import '../../../services/user_services.dart';
import '../../../constants/text_strings.dart';

class EditProfile extends StatefulWidget {
  final MyUser? user;
  const EditProfile({Key? key, required this.user, required this.userService}) : super(key: key);
  final UserService userService;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  File? _imageFile;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Define GlobalKey<FormState> here

  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _nameController.text = widget.user!.name;
      _phoneController.text = widget.user!.phoneNumber;
      _genderController.text = widget.user!.gender;
      _aadharController.text = widget.user!.aadhaarNumber;
      _addressController.text = "Ward " + widget.user!.ward + ", " + widget.user!.district + ", " + widget.user!.state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tEditProfile),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'update_password') {
                _showUpdatePasswordDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'update_password',
                  child: Text('Update Password'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileImage(),
            SizedBox(height: 20.0),
            _buildTextField(controller: _nameController, labelText: tName),
            SizedBox(height: 10.0),
            _buildTextField(controller: _phoneController, labelText: tPhoneNumber, keyboardType: TextInputType.phone),
            SizedBox(height: 10.0),
            _buildTextField(controller: _genderController, labelText: tGender),
            SizedBox(height: 10.0),
            _buildTextField(controller: _addressController, labelText: tAddress, maxLines: null),
            SizedBox(height: 10.0),
            _buildTextField(controller: _aadharController, labelText: tAadharNumber, keyboardType: TextInputType.number),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _showUpdateProfileConfirmationDialog(context);
              },
              child: Text('Save Profile', style: TextStyle(fontSize: 20, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                minimumSize: Size(300, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        image: _imageFile != null
            ? DecorationImage(
          image: FileImage(_imageFile!),
          fit: BoxFit.cover,
        )
            : widget.user?.profilePictureURL != null
            ? DecorationImage(
          image: NetworkImage(widget.user!.profilePictureURL!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: Stack(
        children: [
          if ((_imageFile == null && widget.user?.profilePictureURL == null) || (widget.user?.profilePictureURL == ''))
            Center(
              child: Icon(
                Icons.account_circle,
                size: 100.0,
                color: Colors.white,
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintStyle: TextStyle(color: Colors.black),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: Colors.grey),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void _showUpdateProfileConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Are you sure you want to update your profile?',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _updateProfilePhoto(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Update',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfilePhoto(BuildContext context) async {
    try {
      print('Updating profile photo...');
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            key: _keyLoader, // Set the key
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );

      if (_imageFile != null) {
        final Reference storageReference = FirebaseStorage.instance.ref().child('pfp/${widget.user!.userId}');
        final TaskSnapshot uploadTask = await storageReference.putFile(_imageFile!);
        final String downloadURL = await uploadTask.ref.getDownloadURL();
        await widget.userService.updateUserProfilePicture(widget.user!.userId, downloadURL); // Access userService from widget
        print('Updated Profile Photo...');
        // Close loading indicator
        Navigator.of(_keyLoader.currentContext!).pop();

        // Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo updated successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print('Error updating profile photo: $error');
      Navigator.of(context).pop();

      // Show snackbar for error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile photo. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>(); // Add GlobalKey<FormState> for form validation

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Update Password',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          content: Form(
            key: _formKey, // Assign _formKey to the Form widget
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPasswordField(controller: _passwordController, labelText: 'New Password'),
                SizedBox(height: 10.0),
                _buildPasswordField(controller: _confirmPasswordController, labelText: 'Confirm Password'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) { // Validate form before updating password
                  _updatePassword(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Update',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password.';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters long.';
        }
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return 'Password must contain at least one uppercase letter';
        }
        if (!RegExp(r'[a-z]').hasMatch(value)) {
          return 'Password must contain at least one lowercase letter';
        }
        if (!RegExp(r'[0-9]').hasMatch(value)) {
          return 'Password must contain at least one digit';
        }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return 'Password must contain at least one special character.';
        }
        return null;
      },
    );
  }

  void _updatePassword(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent, // Make dialog transparent
          elevation: 0, // Remove shadow
          content: Center(
            child: CircularProgressIndicator(), // Show loading indicator
          ),
        );
      },
    );

    try {
      if (_passwordController.text == _confirmPasswordController.text) {
        await widget.userService.updateUserPassword(widget.user!.userId, _passwordController.text);
        Navigator.of(context).pop(); // Close the loading indicator dialog
        Navigator.of(context).pop(); // Close the update password dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.of(context).pop(); // Close the loading indicator dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      Navigator.of(context).pop(); // Close the loading indicator dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update password. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

}
