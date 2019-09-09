import 'package:flutter/material.dart';
import 'package:learning_chat_app/presenter/login.dart';
import 'package:learning_chat_app/util/preferences.dart';

class LoginView extends StatefulWidget {

  @override
  LoginViewState createState() => LoginViewState();

}

class LoginViewState extends State<LoginView> {

  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  bool loading = false;

  LoginPresenter presenter;

  @override
  void initState() {
    this.presenter = LoginPresenter(this);
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Login do usuário')
      ),
      body: Column(
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
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'E-mail'
                    ),
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(passwordFocus);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                  TextField(
                    controller: password,
                    obscureText: true,
                    focusNode: passwordFocus,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Senha'
                    ),
                    onSubmitted: (value) {
                      signIn();
                    }
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                  SizedBox(
                    width: 320,
                    height: 48,
                    child: RaisedButton(
                        color: Colors.blueAccent,
                        elevation: 3,
                        child: loading ?
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white)
                          ) :
                          Text('LOGIN',
                            style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.white
                            )
                          ),
                        onPressed: () {
                          signIn();
                        }
                    ),
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  void doLogin(user) {
    Preferences.setLoggedUser(user.id);
    Navigator.pop(key.currentContext, {'user': user});
  }

  void signIn() {
    if (!loading) {
      setState(() {
        this.loading = true;
      });
      presenter.signIn(email.text, password.text);
    }
  }

  void showError(message) {
    setState(() {
      this.loading = false;
    });
    key.currentState.showSnackBar(SnackBar(content: Text('$message')));
  }

}