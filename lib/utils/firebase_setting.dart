// 📦 Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 🌎 Project imports:
import 'firebase_options.dart';

Future<PendingDynamicLinkData?>? setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  return await FirebaseDynamicLinks.instance.getInitialLink();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

// FirebaseFirestore _firestore = FirebaseFirestore.instance;
// CollectionReference liveRef = _firestore.collection('live');
