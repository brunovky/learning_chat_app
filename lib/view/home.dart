import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:learning_chat_app/model/chat.dart';
import 'package:learning_chat_app/model/user.dart';
import 'package:learning_chat_app/presenter/home.dart';
import 'package:learning_chat_app/util/preferences.dart';
import 'package:learning_chat_app/view/account.dart';
import 'package:learning_chat_app/view/chat.dart';
import 'package:learning_chat_app/view/login.dart';

class HomeView extends StatefulWidget {

  @override
  HomeViewState createState() => HomeViewState();

}

class HomeViewState extends State<HomeView> {

  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController theme = TextEditingController();
  List<DropdownMenuItem<String>> themes = List();
  String selectedTheme;
  User user;
  bool loading = true;

  HomePresenter presenter;

  @override
  void initState() {
    this.presenter = HomePresenter(this);
    presenter.getThemes();
    Preferences.getLoggedUser().then((userId) {
      presenter.getLoggedUser(userId);
    });
    super.initState();
  }

  @override
  void dispose() {
    theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: key,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text('LearningChat'),
          actions: <Widget>[
            FlatButton(
                child: Icon(Icons.account_circle, color: Colors.white),
                onPressed: () {
                  showAccountOrLogin(context);
                }
            ),
            FlatButton(
                child: Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: () {
                  dismissAccountOrExit(context);
                }
            )
          ],
        ),
        floatingActionButton: buildFAB(context),
        body: Stack(
          children: <Widget>[
            buildBody(context)
          ],
        ),
      ),
      onWillPop: () {
        dismissAccountOrExit(context);
        return Future.value(false);
      },
    );
  }

  Widget buildFAB(context) {
    if (user == null) {
      return null;
    }
    return FloatingActionButton(
      child: Icon(Icons.chat, color: Colors.white),
      backgroundColor: Colors.redAccent,
      onPressed: () {
        addChat(context);
      }
    );
  }

  Widget buildBody(context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator()
      );
    }
    if (user == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Icon(Icons.chat,
                color: Colors.blueAccent,
                size: 128
              )
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Text('Faça seu login para participar dos chats.',
                    style: Theme.of(context).textTheme.headline,
                    textAlign: TextAlign.center
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 80),
                  ),
                  SizedBox(
                    width: 320,
                    height: 48,
                    child: RaisedButton(
                      color: Colors.blueAccent,
                      elevation: 3,
                      child: Text('FAZER LOGIN',
                        style: Theme.of(context).textTheme.button.copyWith(
                          color: Colors.white
                        )
                      ),
                      onPressed: () {
                        showAccountOrLogin(context);
                      }
                    ),
                  )
                ],
              ),
            )
          )
        ],
      );
    }
    if (user.type == UserType.STUDENT) {
      return StreamBuilder(
          stream: presenter.getStudentChats(user.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator()
              );
            }
            return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  Chat chat = Chat.fromJson(snapshot.data.documents[index]);
                  return ChatCard(
                    chat: chat,
                    user: user,
                    onTap: () {
                      openChat(chat);
                    },
                  );
                }
            );
          }
      );
    }
    return StreamBuilder(
      stream: presenter.getTeacherChats(user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator()
          );
        }
        return StreamBuilder(
          stream: presenter.getOpenedChats(),
          builder: (context, snapshot2) {
            if (!snapshot2.hasData) {
              return Center(
                child: CircularProgressIndicator()
              );
            }
            return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: snapshot.data.documents.length +
                    snapshot2.data.documents.length,
                itemBuilder: (context, index) {
                  AsyncSnapshot as = index < snapshot.data.documents.length ?
                    snapshot : snapshot2;
                  if (index >= snapshot.data.documents.length) {
                    index -= snapshot.data.documents.length;
                  }
                  Chat chat = Chat.fromJson(as.data.documents[index]);
                  return ChatCard(
                    chat: chat,
                    user: user,
                    onTap: () {
                      if (chat.teacher == null) {
                        setChatTeacher(context, chat);
                      } else {
                        openChat(chat);
                      }
                    },
                  );
                }
            );
          }
        );
      }
    );
  }

  void showAccountOrLogin(context) async {
    Widget screen = user == null ? LoginView() : AccountView(user: user);
    Map results = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => screen));
    if (results != null && results.containsKey('user')) {
      setState(() {
        this.user = results['user'];
      });
    } else if (results != null && results.containsKey('data')) {
      setState(() {
        this.user.name = results['data']['name'];
        this.user.password = results['data']['password'];
        this.user.photo = results['data']['photo'];
      });
    }
  }

  void dismissAccountOrExit(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Atenção'),
          content: Text(user == null ? 'Deseja sair da app?' :
            'Deseja sair da sua conta?'),
          actions: <Widget>[
            FlatButton(
              child: Text('SIM'),
              onPressed: () {
                Navigator.pop(context);
                if (user == null) {
                  exit(0);
                } else {
                  Preferences.setLoggedUser(null);
                  setState(() {
                    user = null;
                  });
                }
              },
            ),
            FlatButton(
              child: Text('NÃO'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  void addChat(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text('Escolha um tema'),
                    value: selectedTheme,
                    onChanged: (newTheme) {
                      setState(() {
                        this.selectedTheme = newTheme;
                      });
                    },
                    items: themes,
                  ),
                )
              ),
              ListTile(
                title: RaisedButton(
                  color: Colors.blueAccent,
                  elevation: 3,
                  child: Text('CRIAR SALA',
                    style: Theme.of(context).textTheme.button.copyWith(
                      color: Colors.white
                    ),
                  ),
                  onPressed: () {
                    presenter.createChat(user, selectedTheme);
                  },
                )
              )
            ],
          ),
        );
      }
    );
  }

  void setThemes(themes) {
    setState(() {
      this.themes = themes;
      this.selectedTheme = this.themes[0].value;
    });
  }

  void showError(message) {
    key.currentState.showSnackBar(SnackBar(content: Text('$message')));
  }

  void setChatTeacher(context, chat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Atenção'),
          content: Text('Deseja iniciar este chat com este(a) aluno(a)?'),
          actions: <Widget>[
            FlatButton(
              child: Text('SIM'),
              onPressed: () {
                Navigator.pop(context);
                presenter.setChatTeacher(chat, user);
              },
            ),
            FlatButton(
              child: Text('NÃO'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  void openChat(chat) {
    Navigator.push(key.currentContext, MaterialPageRoute(builder: (context) =>
        ChatView(chat: chat, user: user)));
  }

  void setUser(user) {
    setState(() {
      this.user = user;
      this.loading = false;
    });
  }

}

class ChatCard extends StatelessWidget {

  final Chat chat;
  final User user;
  final dynamic onTap;

  const ChatCard({Key key, this.chat, this.user, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.all(8.0),
      child: Badge(
        badgeContent: Text('${chat.messages.where((m) => user.type ==
            UserType.STUDENT ? !m.readStudent : !m.readTeacher).length}',
          style: TextStyle(
            color: Colors.white
          )
        ),
        child: ListTile(
          leading: Stack(
            children: chat.teacher != null ? <Widget>[
              Container(
                margin: EdgeInsets.only(right: 12.0, bottom: 12.0),
                width: 32,
                height: 32,
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage('${chat.student.photo}'),
                  backgroundColor: Colors.transparent
                )
              ),
              Container(
                margin: EdgeInsets.only(left: 12.0, top: 12.0),
                width: 32,
                height: 32,
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage('${chat.teacher.photo}'),
                  backgroundColor: Colors.transparent
                )
              )
            ] :
            <Widget>[
              Container(
                alignment: Alignment.center,
                width: 32,
                height: 32,
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage('${chat.student.photo}'),
                  backgroundColor: Colors.transparent
                )
              )
            ],
          ),
          title: Text('Professor(a): ${chat.teacher != null ? chat.teacher.name
              : "-"}'),
          subtitle: Text('Tema: ${chat.theme}'),
          onTap: onTap
        ),
        showBadge: chat.messages.where((m) => user.type ==
            UserType.STUDENT ? !m.readStudent : !m.readTeacher).isNotEmpty,
        badgeColor: Colors.redAccent,
        toAnimate: true,
        animationType: BadgeAnimationType.scale
      )
    );
  }
}
