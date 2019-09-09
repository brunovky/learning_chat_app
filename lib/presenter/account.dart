import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:learning_chat_app/view/account.dart';

class AccountPresenter {

  final AccountViewState view;

  AccountPresenter(this.view);

  void updateAccount(userId, name, password, image) {
    if (name.isEmpty) {
      view.showError("Por favor, digite seu nome");
      return;
    }
    if (password.isEmpty) {
      view.showError("Por favor, digite sua senha");
      return;
    }
    if (image != null) {
      FirebaseStorage.instance
          .ref()
          .child(userId)
          .putFile(image)
          .onComplete.then((value) {
        if (value.error == null) {
          value.ref.getDownloadURL().then((url) {
            updateData(userId, name, password, url);
          });
        } else {
          view.showError("Erro ao salvar imagem");
        }
      });
    } else {
      updateData(userId, name, password, null);
    }
  }

  void updateData(userId, name, password, url) {
    var data = {"name": name, "password": password};
    if (url != null) {
      data["photo"] = url;
    }
    Firestore.instance.collection("users").document(userId)
        .updateData(data).then((value) {
      view.goToBack(data);
    }).catchError((error) {
      view.showError(error);
    });
  }

}