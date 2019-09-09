import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_chat_app/model/user.dart';
import 'package:learning_chat_app/view/home.dart';

class HomePresenter {

  final HomeViewState view;

  HomePresenter(this.view);

  void getLoggedUser(userId) async {
    var user;
    if (userId != null && userId.isNotEmpty) {
      DocumentSnapshot result = await Firestore.instance.collection("users")
          .document(userId)
          .get();
      user = User.fromJson(result);
    }
    view.setUser(user);
  }

  void getThemes() async {
    QuerySnapshot result = await Firestore.instance.collection("themes")
        .orderBy("theme")
        .getDocuments();
    List<DocumentSnapshot> docs = result.documents;
    if (docs.isNotEmpty) {
      List<DropdownMenuItem<String>> themes =
        docs.map((d) => DropdownMenuItem<String>(
          child: Text('${d.data['theme']}'),
          value: d.data['theme'],
        )).toList();
      view.setThemes(themes);
    }
  }

  Stream<QuerySnapshot> getStudentChats(userId) {
    return Firestore.instance.collection("chats")
        .where("student.id", isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getTeacherChats(userId) {
    return Firestore.instance.collection("chats")
        .where("teacher.id", isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getOpenedChats() {
    return Firestore.instance.collection("chats")
        .where("teacher", isNull: true)
        .snapshots();
  }
  
  void createChat(user, theme) {
    if (theme == null) {
      view.showError('Por favor, selecione um tema');
      return;
    }
    Firestore.instance.collection("chats").add({
      'student': {
        'id': user.id,
        'name': user.name,
        'photo': user.photo
      },
      'teacher': null,
      'theme': theme,
      'messages': [

      ]
    }).catchError((error) {
      view.showError(error);
    });
  }

  void setChatTeacher(chat, user) {
    Firestore.instance.collection("chats").document(chat.id).updateData({
      'teacher': {
        'id': user.id,
        'name': user.name,
        'photo': user.photo
      }
    }).then((value) {
      view.openChat(chat);
    }).catchError((error) {
      view.showError(error);
    });
  }

}