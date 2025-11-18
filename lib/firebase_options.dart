// File generated using Firebase CLI
// This file provides Firebase configuration for all platforms

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
    apiKey: 'AIzaSyA0QsXq67VkGQx6nht-WkdzAJ1R6IZ-2os',
    appId: '1:240602565577:web:a5716dabecb3afeba1f618',
    messagingSenderId: '240602565577',
    projectId: 'smart-harvest-system',
    authDomain: 'smart-harvest-system.firebaseapp.com',
    storageBucket: 'smart-harvest-system.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxr0T1X37vO6XlVdkiHNptUHQZsL2scT4',
    appId: '1:240602565577:android:73e7e231debe3b48a1f618',
    messagingSenderId: '240602565577',
    projectId: 'smart-harvest-system',
    storageBucket: 'smart-harvest-system.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxr0T1X37vO6XlVdkiHNptUHQZsL2scT4',
    appId: '1:240602565577:ios:73e7e231debe3b48a1f618',
    messagingSenderId: '240602565577',
    projectId: 'smart-harvest-system',
    storageBucket: 'smart-harvest-system.firebasestorage.app',
    iosBundleId: 'com.example.harvestgenius',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxr0T1X37vO6XlVdkiHNptUHQZsL2scT4',
    appId: '1:240602565577:macos:73e7e231debe3b48a1f618',
    messagingSenderId: '240602565577',
    projectId: 'smart-harvest-system',
    storageBucket: 'smart-harvest-system.firebasestorage.app',
    iosBundleId: 'com.example.harvestgenius',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDxr0T1X37vO6XlVdkiHNptUHQZsL2scT4',
    appId: '1:240602565577:windows:73e7e231debe3b48a1f618',
    messagingSenderId: '240602565577',
    projectId: 'smart-harvest-system',
    storageBucket: 'smart-harvest-system.firebasestorage.app',
  );
}

