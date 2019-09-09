import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_chat_app/model/user.dart';

class Chat {

  final String id;
  final String theme;
  final List<Message> messages;
  final User student;
  final User teacher;

  Chat(this.id, this.student, this.teacher, this.theme, this.messages);

  factory Chat.fromJson(DocumentSnapshot doc) {
    return Chat(
      doc.documentID,
      User.fromMap(doc.data['student']),
      User.fromMap(doc.data['teacher']),
      doc.data['theme'],
      (doc.data['messages'] as List).map((m) => Message.fromMap(m)).toList()
    );
  }

}

class Message {

  final String content;
  final String user;
  final bool readStudent;
  final bool readTeacher;

  Message(this.content, this.user, this.readStudent, this.readTeacher);

  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
      map['content'],
      map['user'],
      map['read_student'],
      map['read_teacher']
    );
  }

}