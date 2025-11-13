// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCP3tuY0tmj9jXFU4cACDE0REt4oOZw458",
    authDomain: "tbarguig-demo.firebaseapp.com",
    projectId: "tbarguig-demo",
    storageBucket: "tbarguig-demo.firebasestorage.app",
    messagingSenderId: "323751355210",
    appId: "1:323751355210:web:3555080895d05b2008d7b3",
    measurementId: "G-9RYTL34JZN",
  );
}
