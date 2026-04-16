import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAx_iWUI9_fgiMa6MiWahCD5Zy6IzXfcbM',
    appId: '1:791202314719:web:3586dedec5885b5384ec6a',
    messagingSenderId: '791202314719',
    projectId: 'gmmxapp',
    authDomain: 'gmmxapp.firebaseapp.com',
    storageBucket: 'gmmxapp.firebasestorage.app',
    measurementId: 'G-4HY57ZKCLX',
  );

  // Placeholder values. Run `flutterfire configure --project=gmmxapp` to regenerate this file with real keys.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwcJReu_E2i_OVUh79xJEreYK3miFIitw',
    appId: '1:791202314719:android:abf0151d0f61947c84ec6a',
    messagingSenderId: '791202314719',
    projectId: 'gmmxapp',
    storageBucket: 'gmmxapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAv020ldYw45JSuqkD4dUF7Mu-bg9mx25s',
    appId: '1:791202314719:ios:bdfde4780672f84e84ec6a',
    messagingSenderId: '791202314719',
    projectId: 'gmmxapp',
    storageBucket: 'gmmxapp.firebasestorage.app',
    iosBundleId: 'com.example.gmmxMobile',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAv020ldYw45JSuqkD4dUF7Mu-bg9mx25s',
    appId: '1:791202314719:ios:bdfde4780672f84e84ec6a',
    messagingSenderId: '791202314719',
    projectId: 'gmmxapp',
    storageBucket: 'gmmxapp.firebasestorage.app',
    iosBundleId: 'com.example.gmmxMobile',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAx_iWUI9_fgiMa6MiWahCD5Zy6IzXfcbM',
    appId: '1:791202314719:web:0f0b83833ee31f6384ec6a',
    messagingSenderId: '791202314719',
    projectId: 'gmmxapp',
    authDomain: 'gmmxapp.firebaseapp.com',
    storageBucket: 'gmmxapp.firebasestorage.app',
    measurementId: 'G-GB75VSFNTM',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_LINUX_API_KEY',
    appId: 'REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'gmmxapp',
    authDomain: 'gmmxapp.firebaseapp.com',
    storageBucket: 'gmmxapp.appspot.com',
  );
}