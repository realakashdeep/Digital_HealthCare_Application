import 'package:final_year_project/provider/doctor/doctor_provider.dart';
import 'package:final_year_project/provider/doctor/doctors_auth_provider.dart';
import 'package:final_year_project/provider/health_record_data_provider.dart';
import 'package:final_year_project/provider/user/user_provider.dart';
import 'package:final_year_project/provider/ward/ward_auth_provider.dart';
import 'package:final_year_project/provider/ward/ward_user_provider.dart';
import 'package:final_year_project/provider/caregivers/care_givers_auth_provider.dart';
import 'package:final_year_project/screens/ward/care_givers/careGiversForm.dart';
import 'package:final_year_project/screens/ward/care_givers/patientInfoForm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'constants/text_strings.dart';
import 'provider/user/auth_provider.dart' as MyAuthProvider;
import 'screens/splash_screen.dart';
import 'screens/user/user_home.dart';
import 'screens/user/profile/user_profile.dart';
import 'screens/welcome.dart';
import 'firebase_options.dart';
import 'provider/user/auth_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MyAuthProvider.AuthProvider()),
        ChangeNotifierProvider(create: (context) => WardAuthProvider()),
        ChangeNotifierProvider(create: (context) => WardUserProvider()),
        ChangeNotifierProvider(create: (context) => HealthRecordDataProvider()),
        ChangeNotifierProvider(create: (context) => CareGiversAuthProvider()), // Add this provider
        ChangeNotifierProvider(create: (context) => DoctorsAuthProvider()),
        ChangeNotifierProvider(create: (context) => DoctorsProvider()),// Add this provider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: tTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/auth_checker': (context) => AuthChecker(),
        '/user_home': (context) => UserHome(),
        '/user_profile': (context) => UserProfile(),
        '/welcome': (context) => WelcomePage(),
        '/patient_form' : (context) => PatientInfoForm(),
        '/caregivers_form' :(context) => CareGiversForm()
      },
    );
  }
}
