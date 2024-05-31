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
    apiKey: 'AIzaSyBPTs2J2MkIrMS-Fb65DItTwzpTzZkSuX4',
    appId: '1:208896530099:web:94610be768f6f9074482c6',
    messagingSenderId: '208896530099',
    projectId: 'animalwhispererflutter',
    authDomain: 'animalwhispererflutter.firebaseapp.com',
    storageBucket: 'animalwhispererflutter.appspot.com',
    measurementId: 'G-L67RV1GQGW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwtV0OjRUD78jpkE7bEDAIdnbPjE2eTqU',
    appId: '1:208896530099:android:0cea104e34eae09a4482c6',
    messagingSenderId: '208896530099',
    projectId: 'animalwhispererflutter',
    storageBucket: 'animalwhispererflutter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyButghJT1xGXpyMWDzzTy6s_yCM4CE0icQ',
    appId: '1:208896530099:ios:89e0406f033486f04482c6',
    messagingSenderId: '208896530099',
    projectId: 'animalwhispererflutter',
    storageBucket: 'animalwhispererflutter.appspot.com',
    iosBundleId: 'com.example.animalWhispererFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyButghJT1xGXpyMWDzzTy6s_yCM4CE0icQ',
    appId: '1:208896530099:ios:89e0406f033486f04482c6',
    messagingSenderId: '208896530099',
    projectId: 'animalwhispererflutter',
    storageBucket: 'animalwhispererflutter.appspot.com',
    iosBundleId: 'com.example.animalWhispererFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBPTs2J2MkIrMS-Fb65DItTwzpTzZkSuX4',
    appId: '1:208896530099:web:d295810b0fe1d5824482c6',
    messagingSenderId: '208896530099',
    projectId: 'animalwhispererflutter',
    authDomain: 'animalwhispererflutter.firebaseapp.com',
    storageBucket: 'animalwhispererflutter.appspot.com',
    measurementId: 'G-BZCWJS7JT9',
  );
}
