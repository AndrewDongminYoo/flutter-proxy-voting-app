// 🎯 Dart imports:
import 'dart:convert' show jsonEncode;

class MTS {
  String _module = '';
  String _id = '';
  int _password = 0;

  String get module => _module;
  String get id => _id;
  int get password => _password;

  setModule(String securitiesFirmModule) {
    // some check to make sure the module is not already set
    _module = securitiesFirmModule;
  }

  setId(String securitiesFirmId) {
    // some check to make sure the id is not already set
    _id = securitiesFirmId;
  }

  setPassword(int securitiesFirmPassword) {
    // some check to make sure the password is not already set
    _password = securitiesFirmPassword;
  }

  MTS(this._module, this._id, this._password);

  MTS.fromJson(Map<String, dynamic> json) {
    _module = json['module'];
    _id = json['id'];
    _password = json['password'];
  }

  toJsonString() => jsonEncode({
        'module': module,
        'id': id,
        'password': password,
      });
}
