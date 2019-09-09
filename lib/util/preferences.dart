import 'package:shared_preferences/shared_preferences.dart';

class Preferences {

  static void skipIntro() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool("skip_intro", true);
  }

  static Future<bool> verifyIntro() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool("skip_intro");
  }

  static Future<String> getLoggedUser() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString("user");
  }

  static void setLoggedUser(user) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("user", user);
  }

}