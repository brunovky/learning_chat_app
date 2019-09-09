import 'package:cloud_firestore/cloud_firestore.dart';

class User {

  final String id;
  final String email;
  final UserType type;
  String name;
  String password;
  String photo;

  User(this.id, this.name, this.email, this.password, this.photo, this.type);

  factory User.fromJson(DocumentSnapshot doc) {
    return User(
      doc.documentID,
      doc.data['name'],
      doc.data['email'],
      doc.data['password'],
      doc.data['photo'],
      doc.data['type'] == "STUDENT" ? UserType.STUDENT : UserType.TEACHER
    );
  }

  factory User.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) {
      return null;
    }
    return User(
      map['id'],
      map['name'],
      null,
      null,
      map['photo'],
      null
    );
  }

}

enum UserType {

  STUDENT,
  TEACHER

}