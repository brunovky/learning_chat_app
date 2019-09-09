import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_chat_app/model/user.dart';
import 'package:learning_chat_app/view/login.dart';

class LoginPresenter {

  final LoginViewState view;

  LoginPresenter(this.view);

  void signIn(email, password) async {
    QuerySnapshot result = await Firestore.instance.collection("users")
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .getDocuments();
    List<DocumentSnapshot> docs = result.documents;
    if (docs.isEmpty) {
      view.showError("E-mail e/ou senha inválidos");
    } else {
      var user = User.fromJson(docs[0]);
      view.doLogin(user);
    }
  }

}