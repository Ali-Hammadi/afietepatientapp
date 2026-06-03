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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXA1JFOQD51eT6CLKklppiiMppZN29rv8',
    appId: '1:109907298173:web:afeiteproject',
    messagingSenderId: '109907298173',
    projectId: 'afeiteproject',
    storageBucket: 'afeiteproject.firebasestorage.app',
    authDomain: 'afeiteproject.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXA1JFOQD51eT6CLKklppiiMppZN29rv8',
    appId: '1:109907298173:android:0642ec373d78f5e44d6e14',
    messagingSenderId: '109907298173',
    projectId: 'afeiteproject',
    storageBucket: 'afeiteproject.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXA1JFOQD51eT6CLKklppiiMppZN29rv8',
    appId: '1:109907298173:ios:afeiteproject',
    messagingSenderId: '109907298173',
    projectId: 'afeiteproject',
    storageBucket: 'afeiteproject.firebasestorage.app',
  );
}
