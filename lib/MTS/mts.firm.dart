// 🎯 Dart imports:
import 'dart:convert' show jsonEncode;

// SecuritiesFirm or TradingFirm
class FIRM {
  String _module = '';
  String _image = '';
  String _name = '';
  int _id = 0;

  String get name => _name;
  String get module => _module;
  int get id => _id;
  String get image => _image;

  FIRM(this._module, this._id, this._image, this._name);

  FIRM.fromJson(Map<String, dynamic> json) {
    _module = json['module'];
    _id = json['id'];
    _image = json['image'];
    _name = json['name'];
  }

  String toJsonString() => jsonEncode({
        'module': _module,
        'id': _id,
        'image': _image,
        'name': _name,
      });
}

class CustomModule {
  const CustomModule(this.firmName);
  final String firmName;
  @override
  String toString() => firmName;
}
