import 'package:firebase_messaging/firebase_messaging.dart';



// This function must be top-level to work with background messages
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}