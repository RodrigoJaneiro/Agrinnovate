// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String display_name;
  String email;
  String uid;
  Timestamp created_time;

  User({
    required this.display_name,
    required this.email,
    required this.uid,
    required this.created_time,
  });

  User.fromJson(Map<String, Object?> json)
      : this(
          display_name: json['display_name']! as String,
          email: json['email']! as String,
          uid: json['uid']! as String,
          created_time: json['created_time']! as Timestamp,
        );

  User copyWith({
    String? display_name,
    String? email,
    String? uid,
    Timestamp? created_time,
  }) {
    return User(
        display_name: display_name ?? this.display_name,
        email: email ?? this.email,
        uid: uid ?? this.uid,
        created_time: created_time ?? this.created_time);
  }

  Map<String, Object?> toJson() {
    return {
      'display_name': display_name,
      'email': email,
      'uid': uid,
      'created_time': created_time,
    };
  }
}
