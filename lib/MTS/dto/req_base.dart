// ignore_for_file: non_constant_identifier_names
// π― Dart imports:
import 'dart:convert' show jsonDecode;

// π Project imports:
import '../../utils/global_channel.dart';
import '../mts.dart';

class CustomRequest implements InputOutput {
  CustomRequest({
    required this.Module,
    required this.Job,
    this.Class = 'μ¦κΆμλΉμ€',
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
  Future<CustomResponse> send(String username) async {
    print('===========$Module ${Job.padLeft(6, ' ')}===========');
    String? response = await channel.invokeMethod('getMTSData', {'data': data});
    dynamic json = jsonDecode(response!);
    return CustomResponse.from(json as Map<String, dynamic>);
  }

  @override
  String toString() => data.toString();
}
