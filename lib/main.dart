
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parikshamadadkendra/StudentAnnouncements.dart';
import 'package:parikshamadadkendra/Team/TeamPage.dart';
import 'package:parikshamadadkendra/register_or_login.dart';
import 'package:parikshamadadkendra/theme.dart';
import 'package:provider/provider.dart';

import 'package:parikshamadadkendra/Choose_login.dart';
import 'package:parikshamadadkendra/Choose_register.dart';
import 'package:parikshamadadkendra/splash_screen.dart';
import 'package:parikshamadadkendra/dashboard_screen.dart';
import 'package:parikshamadadkendra/firebase_options.dart';

import 'auth_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Define notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Same channel ID as in AndroidManifest.xml
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  // Initialize the plugin settings
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the local notifications plugin before running the app
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create the notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      // Show a local notification for foreground notifications
      await flutterLocalNotificationsPlugin.show(
        message.hashCode, // You can use the message hash as an ID
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Same as in your manifest
            'High Importance Notifications',

            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  // Run the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}


// Background handler
/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔵 Background message: ${message.notification?.title}');
}*/
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;
  bool isEmailVerified = false;
  bool _isLoading = true;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    registerNotification();
 //   _setupFCM();

/*    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show a snackbar or dialog
        showForegroundNotification(message.notification!.title, message.notification!.body);
      }
    });*/


    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);





    // Check the current user when the app initializes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        if (user != null) {
          _user = user;
          isEmailVerified = user.emailVerified;
        } else {
          _user = null;
          isEmailVerified = false;
        }
        _isLoading = false;  // Stop the loading indicator
      });
    });

    }
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    // Leave this empty, do not try to show anything manually here.
  }
  void showForegroundNotification(String? title, String? body) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$body'),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.blue,
      ),
    );
  }



  void registerNotification() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Handle foreground messages
        if (message.notification != null) {
     /*     // Show notification as a popup
          showSimpleNotification(
            Text(message.notification!.title!),
            subtitle: Text(message.notification!.body!),
          );*/
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle notification tap
        // Navigate to specific screen based on message data
      });
    }
  }












/*

  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions
    await messaging.requestPermission();

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'Default',

              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',

            ),
          ),
        );
      }
    });

    // Notification click handler
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🔴 Notification Clicked!");
      // Navigate if needed
    });

    // Init local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
*/


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: "MyClassroom",
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          navigatorKey: navigatorKey,
// Apply dynamic theme
          home: _isLoading
              ? SplashScreen()  // Show SplashScreen while loading
              : _user == null
              ? RegisterOrLoginScreen()  // Redirect to login if no user is found
              : isEmailVerified
              ? AuthHandler()  // Show dashboard if user is logged in and verified
              : ChooseLogin(),  // Ask to verify email if user is logged in but not verified
          routes: {
            '/register': (context) => ChooseRegister(),
            '/dashboard': (context) => DashboardScreen(),
            '/login': (context) => ChooseLogin(),
          },
        );
      },
    );
  }
}
