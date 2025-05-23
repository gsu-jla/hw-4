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
    apiKey: 'AIzaSyDQj-LrJo7eihFrKYAywwXd4SWtHg91Q3c',
    appId: '1:702128653184:web:14117c24774d7861673765',
    messagingSenderId: '702128653184',
    projectId: 'mad-msg-board',
    authDomain: 'mad-msg-board.firebaseapp.com',
    storageBucket: 'mad-msg-board.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClTOcC0DZcekAmFC8WXADu7Cf9mNEYQWM',
    appId: '1:702128653184:android:5948d3c84302063d673765',
    messagingSenderId: '702128653184',
    projectId: 'mad-msg-board',
    storageBucket: 'mad-msg-board.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAB9AgY0VF_ximaAswqGoBJOHCsdMMca2I',
    appId: '1:702128653184:ios:ff3b801be10f7ce1673765',
    messagingSenderId: '702128653184',
    projectId: 'mad-msg-board',
    storageBucket: 'mad-msg-board.firebasestorage.app',
    iosBundleId: 'com.example.msgBoard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAB9AgY0VF_ximaAswqGoBJOHCsdMMca2I',
    appId: '1:702128653184:ios:ff3b801be10f7ce1673765',
    messagingSenderId: '702128653184',
    projectId: 'mad-msg-board',
    storageBucket: 'mad-msg-board.firebasestorage.app',
    iosBundleId: 'com.example.msgBoard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQj-LrJo7eihFrKYAywwXd4SWtHg91Q3c',
    appId: '1:702128653184:web:e56548422db5f4a7673765',
    messagingSenderId: '702128653184',
    projectId: 'mad-msg-board',
    authDomain: 'mad-msg-board.firebaseapp.com',
    storageBucket: 'mad-msg-board.firebasestorage.app',
  );
}
