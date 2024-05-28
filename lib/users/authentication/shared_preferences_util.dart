import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static Future<void> storeCustomerId(String customerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('customerId', customerId);
  }

  static Future<String?> getCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('customerId');
  }
}
