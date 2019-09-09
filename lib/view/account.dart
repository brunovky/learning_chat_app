import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_chat_app/model/user.dart';
import 'package:learning_chat_app/presenter/account.dart';

class AccountView extends StatefulWidget {

  final User user;

  const AccountView({Key key, this.user}) : super(key: key);

  @override
  AccountViewState createState() => AccountViewState(user);

}

class AccountViewState extends State<AccountView> {

  final User user;

  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  bool loading = false;
  File image;

  AccountPresenter presenter;

  AccountViewState(this.user);

  @override
  void initState() {
    this.presenter = AccountPresenter(this);
    name.text = user.name;
    password.text = user.password;
    super.initState();
  }

  @override
  void dispose() {
    name.dispose();
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
          title: Text('Conta do usuário')
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: GestureDetector(
                      child: CircleAvatar(
                          radius: 30.0,
                          backgroundColor: Colors.transparent,
                          backgroundImage: image != null ? FileImage(image) :
                          NetworkImage('${user.photo}')
                      ),
                      onTap: () {
                        pickImage();
                      }
                  ),
                )
              ],
            )
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Nome'
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
                          updateAccount();
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
                        Text('ATUALIZAR',
                          style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.white
                          )
                        ),
                        onPressed: () {
                          updateAccount();
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

  void updateAccount() {
    setState(() {
      this.loading = true;
    });
    presenter.updateAccount(user.id, name.text, password.text, image);
  }

  void pickImage() async {
    var _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.image = _image;
    });
  }

  void goToBack(data) {
    Navigator.pop(key.currentContext, {'data': data});
  }

  void showError(message) {
    setState(() {
      this.loading = false;
    });
    key.currentState.showSnackBar(SnackBar(content: Text('$message')));
  }

}