import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_chat_app/view/chat.dart';

class ChatPresenter {

  final ChatViewState view;

  ChatPresenter(this.view);

  Stream<DocumentSnapshot> getChat(chatId) {
    return Firestore.instance.collection("chats").document(chatId).snapshots();
  }

  void readMessages(messages, chatId, isStudent) {
    var newMessages = List.of(messages);
    for (var message in newMessages) {
      message[isStudent ? 'read_student' : 'read_teacher'] = true;
    }
    Firestore.instance.collection("chats").document(chatId).updateData({
      'messages': newMessages
    });
  }

  void sendMessage(messages, message, chatId, userId, isStudent) {
    if (message == null || message.isEmpty) {
      view.showError("Por favor, digite sua mensagem");
    }
    var newMessages = List.of(messages);
    newMessages.add({'content': message, 'user': userId,
      'read_student': isStudent, 'read_teacher': !isStudent});
    Firestore.instance.collection("chats").document(chatId).updateData({
      'messages': newMessages
    }).then((value) {
      view.scrollToBottom();
    });
  }

}