// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

import '../mts.dart';

class CustomResponse implements InputOutput {
  CustomResponse({
    required this.Module,
    required this.Job,
    required this.Class,
    required this.Input,
    required this.Output,
    required this.API_SEQ,
  });

  late CustomModule Module;
  late String Class;
  late String Job;
  late CustomInput Input;
  late CustomOutput Output;
  late String API_SEQ;

  CustomResponse.from(Map<String, dynamic> json) {
    Module = CustomModule.get(json['Module']);
    Class = json['Class'];
    Job = json['Job'];
    Input = CustomInput.from(json['Input']);
    Output = CustomOutput.from(json['Output']);
    API_SEQ = json['API_SEQ'] ?? '';
  }

  @override
  Map<String, dynamic> get data => {
        'Module': Module.toString(),
        'Job': Job,
        'Class': Class,
        'Input': Input.json,
        'Output': Output.json,
        'API_SEQ': API_SEQ,
      };

  @override
  Future<void> fetch(String username) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference col = firestore.collection('transactions');
    DocumentReference dbRef = col.doc('$Module $Job $username');
    await dbRef.collection(today()).add(data);
    if (Output.ErrorCode != '00000000') return;
    Output.Result.json.forEach((String key, dynamic value) {
      if (value is List<Map<String, dynamic>>) {
        for (Map<String, dynamic> result in value) {
          print(key);
          result.forEach((k1, v1) {
            print('$k1: $v1');
          });
        }
      } else if (value is Map<String, dynamic>) {
        value.forEach((k1, v1) {
          print('$k1: $v1');
        });
      }
    });
  }

  @override
  String toString() => data.toString();
}
