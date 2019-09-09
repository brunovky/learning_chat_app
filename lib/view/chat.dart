import 'package:flutter/material.dart';
import 'package:learning_chat_app/model/chat.dart';
import 'package:learning_chat_app/model/user.dart';
import 'package:learning_chat_app/presenter/chat.dart';

class ChatView extends StatefulWidget {

  final Chat chat;
  final User user;

  const ChatView({Key key, this.chat, this.user}) : super(key: key);

  @override
  ChatViewState createState() => ChatViewState(chat, user);

}

class ChatViewState extends State<ChatView> {

  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController message = TextEditingController();
  ScrollController scrollController = ScrollController();

  final Chat chat;
  final User user;
  dynamic messages;

  ChatPresenter presenter;

  ChatViewState(this.chat, this.user);

  @override
  void initState() {
    this.presenter = ChatPresenter(this);
    super.initState();
  }

  @override
  void dispose() {
    message.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Chat')
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: presenter.getChat(chat.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator()
                );
              }
              this.messages = snapshot.data['messages'];
              presenter.readMessages(messages, chat.id,
                  user.type == UserType.STUDENT);
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 160,
                  maxHeight: MediaQuery.of(context).size.height - 160
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  controller: scrollController,
                  padding: EdgeInsets.all(10.0),
                  itemCount: snapshot.data['messages'].length,
                  itemBuilder: (context, index) {
                    Message message = Message.fromMap(snapshot.data['messages']
                        [snapshot.data['messages'].length - index - 1]);
                    return MessageCard(
                      message: message,
                      chat: chat,
                      user: user
                    );
                  }
                ),
              );
            }
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: TextField(
                controller: message,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Digite sua mensagem'
                )
              ),
              trailing: GestureDetector(
                child: Icon(Icons.send, color: Colors.blueAccent),
                onTap: () {
                  presenter.sendMessage(messages, message.text, chat.id,
                      user.id, user.type == UserType.STUDENT);
                }
              ),
            )
          )
        ],
      ),
    );
  }

  void scrollToBottom() {
    message.clear();
    scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300)
    );
  }

  void showError(message) {
    key.currentState.showSnackBar(SnackBar(content: Text('$message')));
  }

}

class MessageCard extends StatelessWidget {

  final Message message;
  final User user;
  final Chat chat;

  const MessageCard({Key key, this.message, this.user, this.chat}) :
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: message.user == user.id ? null : Container(
            margin: EdgeInsets.only(right: 12.0, bottom: 12.0),
            width: 32,
            height: 32,
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage('${user.type == UserType.STUDENT ?
                chat.teacher.photo : chat.student.photo}'),
              backgroundColor: Colors.transparent
            )
        ),
        title: Text('${message.content}',
          textAlign: message.user == user.id ? TextAlign.start : TextAlign.end
        ),
        trailing: message.user != user.id ? null : Container(
            margin: EdgeInsets.only(right: 12.0, bottom: 12.0),
            width: 32,
            height: 32,
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage('${user.type == UserType.STUDENT ?
              chat.student.photo : chat.teacher.photo}'),
              backgroundColor: Colors.transparent
            )
        ),
      )
    );
  }

}

