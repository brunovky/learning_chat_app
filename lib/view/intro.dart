import 'package:flutter/material.dart';
import 'package:learning_chat_app/util/preferences.dart';
import 'package:learning_chat_app/view/home.dart';

class IntroView extends StatefulWidget {

  @override
  _IntroViewState createState() => _IntroViewState();

}

class _IntroViewState extends State<IntroView> {

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: 3,
            itemBuilder: (context, position) {
              return buildPage(position);
            },
            onPageChanged: (pageNumber) {
              setState(() {
                currentPage = pageNumber;
              });
            }
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 60,
            width: MediaQuery.of(context).size.width,
            child: DotSelector(
              page: currentPage
            ),
          )
        ],
      )
    );
  }

  Widget buildPage(position) {
    return position == 0 ? FirstPage() :
           position == 1 ? SecondPage() : ThirdPage();
  }

}

class FirstPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Image.asset('language.png',
              width: 256,
              height: 256
            )
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: Text('Está a fim de aprender um novo idioma?',
                style: Theme.of(context).textTheme.headline.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center
              )
            )
          )
        ],
      )
    );
  }

}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Image.asset('talk.png',
              width: 256,
              height: 256
            )
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: Text('Gosta de conversar e trocar mensagens?',
                style: Theme.of(context).textTheme.headline.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center
              )
            )
          )
        ],
      )
    );
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Image.asset('check.png',
              width: 256,
              height: 256
            )
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text('Então está no lugar certo! \nConheça a LearningChat!',
                  style: Theme.of(context).textTheme.headline.copyWith(
                    color: Colors.white,
                  ),
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
                    child: Text('ENTRAR',
                      style: Theme.of(context).textTheme.button.copyWith(
                        color: Colors.white
                      )
                    ),
                    onPressed: () {
                      Preferences.skipIntro();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomeView()));
                    }
                  ),
                )
              ],
            )
          )
        ],
      )
    );
  }
}

class DotSelector extends StatelessWidget {

  final int page;

  DotSelector({Key key, this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildSelector(0),
        Padding(
            padding: EdgeInsets.only(left: 18.0)
        ),
        buildSelector(1),
        Padding(
            padding: EdgeInsets.only(left: 18.0)
        ),
        buildSelector(2)
      ],
    );
  }

  Widget buildSelector(page) {
    return this.page == page ?
      Icon(Icons.radio_button_checked, color: Colors.white) :
      Icon(Icons.radio_button_unchecked, color: Colors.white);
  }

}
