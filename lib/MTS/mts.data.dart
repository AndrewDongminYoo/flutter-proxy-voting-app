class Mts {
  String _module = '';
  String _id = '';
  int _password = 0;

  String get module => _module;
  String get id => _id;
  int get password => _password;

  set setModule(String securitiesFirmModule) {
    _module = securitiesFirmModule;
  }

  set setId(String securitiesFirmId) {
    _id = securitiesFirmId;
  }

  set setPassword(int securitiesFirmPassword) {
    _password = securitiesFirmPassword;
  }

  Mts(this._module, this._id, this._password);

  Mts.fromJson(Map<String, dynamic> json) {
    _module = json['module'];
    _id = json['id'];
    _password = json['password'];
  }

  Map<String, dynamic> toJson() => {
        '_module': module,
        '_id': id,
        '_password': password,
      };
}
