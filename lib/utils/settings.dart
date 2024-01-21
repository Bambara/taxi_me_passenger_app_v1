import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static setSigned(bool signed) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool("signed", signed);
  }

  static Future<bool> getSigned() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool("signed")!;
  }

  static setDispatcher(bool dispatcher) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool("dispatcher", dispatcher);
  }

  static Future<bool> getDispatcher() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool("dispatcher")!;
  }

  static setOnTrip(bool onTrip) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool("onTrip", onTrip);
  }

  static Future<bool> getOnTrip() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool("onTrip")!;
  }

  static setDispatcherID(String dispatcherID) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("dispatcherID", dispatcherID);
  }

  static Future<String> getDispatcherID() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("dispatcherID")!;
  }

  static setTripId(String tripID) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("tripId", tripID);
  }

  static Future<String> getTripId() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("tripId")!;
  }

  static setUserID(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("userId", token);
  }

  static Future<String> getUserID() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("userId")!;
  }

  static setEmail(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("email", token);
  }

  static Future<String> getEmail() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("email")!;
  }

  static setContactNumber(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("contactNumber", token);
  }

  static Future<String> getContactNumber() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("contactNumber")!;
  }

  static setPassengerCode(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("passengerCode", token);
  }

  static Future<String> getPassengerCode() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("passengerCode")!;
  }

  static setUserProfilePic(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("userProfilePic", token);
  }

  static Future<String> getUserProfilePic() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("userProfilePic")!;
  }

  static setToken(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("token", token);
  }

  static Future<String> getToken() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("token")!;
  }

  static Future<String?> getDeleteAccount() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString("deleteAccount");
  }

  static setDeleteAccount(String token) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("deleteAccount", 'yes');
  }
}
