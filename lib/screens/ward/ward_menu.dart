import 'package:final_year_project/screens/ward/patientInfoForm.dart';
import 'package:final_year_project/screens/ward/ward_profile.dart';
import 'package:final_year_project/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../provider/ward_auth_provider.dart';
import 'CurrentCampsPage.dart';
import 'RegisterUserPage.dart';


class WardMenuPage extends StatefulWidget {
  @override
  State<WardMenuPage> createState() => _WardMenuPageState();
}

class _WardMenuPageState extends State<WardMenuPage> {
  @override
  Widget build(BuildContext context) {
    final wardAuthProvider = Provider.of<WardAuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ward Menu'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double gridSpacing = constraints.maxWidth * 0.05;
            double gridPadding = constraints.maxWidth * 0.1;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  vertical: gridSpacing, horizontal: gridPadding),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: constraints.maxWidth < 600 ? 2 : 3,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                      children: <Widget>[
                        buildMenuButton(
                          context,
                          'Register New User',
                          'assets/add_user.svg',
                          RegisterUserPage(),
                        ),
                        buildMenuButton(
                          context,
                          'Camps Details',
                          'assets/camp.svg',
                          CurrentCampsPage(),
                        ),
                        buildMenuButtonWithIcon(
                          context,
                          'View And Update Ward Details',
                          Icons.local_hospital,
                          WardProfilePage(),
                        ),
                        buildMenuButtonWithIcon(
                          context,
                          'Generate Reports',
                          Icons.list_alt,
                          null,
                        ),
                        buildMenuButtonWithIcon(
                          context,
                          'Add Patient Health Record',
                          Icons.medical_information,
                          PatientInfoForm(),
                        )
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 34.0),
        child: ElevatedButton.icon(
          onPressed: () async {
            _showLogoutConfirmationDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            minimumSize: Size(300, 40),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.logout,
              color: Colors.white,
              size: 24,
            ),
          ),
          label: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    );
  }

  Widget buildMenuButton(BuildContext context, String label, String assetPath, Widget? page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconSize = constraints.maxWidth * 0.25; // Increased icon size factor
        double textSize = constraints.maxWidth * 0.10; // Increased text size factor

        return ElevatedButton(
          onPressed: () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                assetPath,
                color: Colors.white,
                width: iconSize,
                height: iconSize,
              ),
              const SizedBox(height: 8.0),
              Text(
                label,
                style: TextStyle(fontSize: textSize, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildMenuButtonWithIcon(BuildContext context, String label, IconData icon, Widget? page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconSize = constraints.maxWidth * 0.25; // Increased icon size factor
        double textSize = constraints.maxWidth * 0.10; // Increased text size factor

        return ElevatedButton(
          onPressed: () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: iconSize,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Text(
                label,
                style: TextStyle(fontSize: textSize, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Are you sure you want to log out?', style: TextStyle(fontSize: 20, color: Colors.black)),
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
              child: Text('No', style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await Provider.of<WardAuthProvider>(context, listen: false).signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.redAccent,
              ),
              child: Text('Yes', style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
