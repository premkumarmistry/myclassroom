import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> initializeFirebaseForTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}
