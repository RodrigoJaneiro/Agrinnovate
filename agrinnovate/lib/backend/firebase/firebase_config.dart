import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyD4mycW23nHO2_GjmWu7MYeUZ53qLmSvKI",
            authDomain: "agrinnovate-d31ea.firebaseapp.com",
            projectId: "agrinnovate-d31ea",
            storageBucket: "agrinnovate-d31ea.appspot.com",
            messagingSenderId: "711371671856",
            appId: "1:711371671856:web:05368d26b2c595122360f5",
            measurementId: "G-QV1PRHY6CW"));
  } else {
    await Firebase.initializeApp();
  }
}
