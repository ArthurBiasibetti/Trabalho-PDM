// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCKyPtjgwFrVqUEycji2p7WDZ0RjZNw5jI',
    appId: '1:510473543471:web:af11fe76fc795bc66a4bda',
    messagingSenderId: '510473543471',
    projectId: 'olho-do-pai',
    authDomain: 'olho-do-pai.firebaseapp.com',
    storageBucket: 'olho-do-pai.appspot.com',
    measurementId: 'G-QQTZ6QLR3J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBw9PGjcuc2SP5_KRx80I73bRdFS-7RYlI',
    appId: '1:510473543471:android:d3e39d98758cc7606a4bda',
    messagingSenderId: '510473543471',
    projectId: 'olho-do-pai',
    storageBucket: 'olho-do-pai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDGDQJ9zAqkRbZ1RgSk6cMNMt4i9kiKK0',
    appId: '1:510473543471:ios:87769097f20e96456a4bda',
    messagingSenderId: '510473543471',
    projectId: 'olho-do-pai',
    storageBucket: 'olho-do-pai.appspot.com',
    iosClientId: '510473543471-6l2v77cibabc567css40id1gpcaipf66.apps.googleusercontent.com',
    iosBundleId: 'com.example.trabalhoPdm',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBDGDQJ9zAqkRbZ1RgSk6cMNMt4i9kiKK0',
    appId: '1:510473543471:ios:87769097f20e96456a4bda',
    messagingSenderId: '510473543471',
    projectId: 'olho-do-pai',
    storageBucket: 'olho-do-pai.appspot.com',
    iosClientId: '510473543471-6l2v77cibabc567css40id1gpcaipf66.apps.googleusercontent.com',
    iosBundleId: 'com.example.trabalhoPdm',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCKyPtjgwFrVqUEycji2p7WDZ0RjZNw5jI',
    appId: '1:510473543471:web:da3a4892b2a608d86a4bda',
    messagingSenderId: '510473543471',
    projectId: 'olho-do-pai',
    authDomain: 'olho-do-pai.firebaseapp.com',
    storageBucket: 'olho-do-pai.appspot.com',
    measurementId: 'G-KZPRH006H2',
  );

}