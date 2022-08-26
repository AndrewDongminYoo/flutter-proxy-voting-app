// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

// 🌎 Project imports:
import '../../utils/channel.dart';
import '../mts.dart';

class CustomRequest implements InputOutput {
  CustomRequest({
    required this.Module,
    required this.Job,
    this.Class = '증권서비스',
    required this.Input,
  }) : super();

  final CustomModule Module;
  final String Class;
  final String Job;
  final CustomInput Input;

  @override
  Map<String, dynamic> get data => {
        'Module': Module.toString(),
        'Job': Job,
        'Class': Class,
        'Input': Input.json,
      };

  @override
  Future<CustomResponse> fetch() async {
    print('===========$Module ${Job.padLeft(6, ' ')}===========');
    String? response = await channel.invokeMethod('getMTSData', {'data': data});
    dynamic json = jsonDecode(response!);
    return CustomResponse.from(json);
  }

  @override
  String toString() => data.toString();
}
