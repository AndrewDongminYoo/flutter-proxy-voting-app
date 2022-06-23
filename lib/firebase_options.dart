// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANKbdzmkSH_rjMW22C4LMd2zvVHxfsG7Y',
    appId: '1:288458571879:android:608990ecede656972014c2',
    messagingSenderId: '288458571879',
    projectId: 'bside-kr',
    storageBucket: 'bside-kr.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIajIGg77kHQEc40xljeOAgL0n0qkwNeM',
    appId: '1:288458571879:ios:c8ca3e58759e15f42014c2',
    messagingSenderId: '288458571879',
    projectId: 'bside-kr',
    storageBucket: 'bside-kr.appspot.com',
    androidClientId: '288458571879-nq0bg2g9pgpgso37rnpmrhjqeuvcj77l.apps.googleusercontent.com',
    iosClientId: '288458571879-2i36sn3hb187n4ib83sdctodv61dtamv.apps.googleusercontent.com',
    iosBundleId: 'ai.bside.bside',
  );
}
