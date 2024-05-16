import 'package:flutter/foundation.dart';

class UserModel with ChangeNotifier {
  String? name;
  String? phoneNumber;

  void updateUserData(String? name, String? phoneNumber) {
    this.name = name;
    this.phoneNumber = phoneNumber;
    notifyListeners();
  }
}
