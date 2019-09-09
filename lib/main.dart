import 'package:flutter/material.dart';
import 'package:learning_chat_app/util/preferences.dart';
import 'package:learning_chat_app/view/home.dart';
import 'package:learning_chat_app/view/intro.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FutureBuilder(
      future: Preferences.verifyIntro(),
      builder: (context, snapshot) {
        return snapshot.hasData ? HomeView() : IntroView();
      }
    )
  ));
}