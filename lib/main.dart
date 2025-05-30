import 'package:flutter/material.dart';
import 'package:flutter_se/view/add_product_page.dart';
import 'package:flutter_se/view/create_room_page.dart';
import 'package:flutter_se/view/enter_email.dart';
import 'package:flutter_se/view/home_page.dart';
import 'package:flutter_se/view/homepage2.dart';
import 'package:flutter_se/view/invite_member_page.dart';
import 'package:flutter_se/view/join_room_page.dart';
import 'package:flutter_se/view/login_page.dart';
import 'package:flutter_se/view/member_leave_page.dart';
import 'package:flutter_se/view/notification_page.dart';
import 'package:flutter_se/view/notification_service.dart';
import 'package:flutter_se/view/register_page.dart';
import 'package:flutter_se/view/splashDecider_Page.dart';
import 'package:flutter_se/view/update_profile_page.dart';
import 'package:flutter_se/view/view_profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  final firebaseApi = FirebaseApi();
  await firebaseApi.initNotification();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: isLoggedIn ? '/splashDecider' : '/',
      routes: {
        // '/': (context) => const SplashScreen(),
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/homeNull': (context) => const HomePage(),
        '/home': (context) => const HomePage2(),
        '/inviteMember': (context) => const InviteMemberPage(),
        '/memberLeave': (context) => const MemberLeavePage(),
        '/createRoom': (context) => const CreateRoomPage(),
        '/addProduct': (context) => const AddProductPage(),
        '/joinRoom': (context) => const JoinRoomPage(),
        '/viewProfile': (context) => const ProfilePage(),
        '/updateProfile': (context) => const UpdateProfilePage(),
        '/notification_screen': (context) => const NotificationPage(),
        '/forgotPassword': (context) => const EnterEmailPage(),
        '/splashDecider': (context) => const SplashDeciderPage(),
      },
    );
  }
}
