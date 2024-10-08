// import 'package:doctor_appointment_app/doctors_management/provider/userprovider.dart';
// import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
// import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
// import 'package:doctor_appointment_app/firebase_options.dart';
// import 'package:doctor_appointment_app/pateints_management/components/nav_bar.dart';
// import 'package:doctor_appointment_app/pateints_management/pages/homepage.dart';
// import 'package:doctor_appointment_app/pateints_management/services/pateint_provider.dart';
// import 'package:doctor_appointment_app/selection_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);

//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     messaging.requestPermission();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Received a message while in the foreground: ${message.messageId}');
//     });

//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   } catch (e) {
//     print('Error initializing Firebase: $e');
//   }

//   runApp(MyApp());
// }

// // Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling a background message: ${message.messageId}');
//   // Handle the message
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => UserProvider()),
//          ChangeNotifierProvider(create: (_) => PateintProvider()),
//         // Add other providers here if needed
//       ],
//       child: MaterialApp(
//         title: 'Doctor Appointment App',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           textTheme: GoogleFonts.latoTextTheme(),
//         ),
//         debugShowCheckedModeBanner: false,
//         home: InitialScreen(),
//         routes: {
//           '/homepage': (context) => NavBAr(),
//         },
//       ),
//     );
//   }
// }

// class InitialScreen extends StatefulWidget {
//   @override
//   _InitialScreenState createState() => _InitialScreenState();
// }

// class _InitialScreenState extends State<InitialScreen> {
//   bool _isLoading = true;
//   bool _isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       setState(() {
//         _isLoggedIn = true;
//       });
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return _isLoggedIn ? DoctorHomeScreen() : UserSelectionScreen();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/doctors_management/provider/userprovider.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
import 'package:doctor_appointment_app/firebase_options.dart';
import 'package:doctor_appointment_app/pateints_management/components/nav_bar.dart';
import 'package:doctor_appointment_app/pateints_management/pages/homepage.dart';
import 'package:doctor_appointment_app/pateints_management/services/pateint_provider.dart';
import 'package:doctor_appointment_app/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground: ${message.messageId}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(MyApp());
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Handle the message
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PateintProvider()),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        title: 'Doctor Appointment App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.latoTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
        home: InitialScreen(),
        routes: {
          '/homepage': (context) => NavBAr(),
        },
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isDoctor = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('User is logged in with UID: ${user.uid}');

      try {
        // Check if the user is a doctor
        DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.uid)
            .get();

        if (doctorSnapshot.exists) {
          print('User is a doctor');
          setState(() {
            _isDoctor = true;
            _isLoggedIn = true;
          });
        } else {
          // If not a doctor, check if the user is a patient
          DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(user.uid)
              .get();

          if (patientSnapshot.exists) {
            print('User is a patient');
            setState(() {
              _isDoctor = false;
              _isLoggedIn = true;
            });
          } else {
            print('User is neither a doctor nor a patient');
            setState(() {
              _isLoggedIn = false;
            });
          }
        }
      } catch (e) {
        print('Error checking user role: $e');
      }
    } else {
      print('No user is logged in');
      setState(() {
        _isLoggedIn = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoggedIn) {
      return _isDoctor ? DoctorHomeScreen() : NavBAr(); // Patient Home Screen
    } else {
      return UserSelectionScreen();
    }
  }
}
