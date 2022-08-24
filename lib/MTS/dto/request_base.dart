// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import '../../utils/channel.dart';
import '../mts.dart';

class CustomResponse {
  CustomResponse({
    required this.Module,
    required this.Job,
    required this.Class,
    required this.Input,
    required this.Output,
    required this.API_SEQ,
  });

  late String Module;
  late String Class;
  late String Job;
  late CustomInput Input;
  late CustomOutput Output;
  late String API_SEQ;

  CustomResponse.fromJson(Map<String, dynamic> json) {
    Module = json['Module'];
    Class = json['Class'];
    Job = json['Job'];
    Input = json['Input'];
    Output = json['OutPut'];
    API_SEQ = json['API_SEQ'];
  }

  Map<String, dynamic> get data => {
        'Module': Module,
        'Job': Job,
        'Class': Class,
        'Input': Input,
        'OutPut': Output,
        'API_SEQ': API_SEQ,
      };
}

class CustomRequest {
  CustomRequest({
    required this.Module,
    required this.Job,
    this.Class = '증권서비스',
    required this.Input,
  }) : super();

  final String Module;
  final String Class;
  final String Job;
  final dynamic Input;

  dynamic get data => {
        'Module': Module,
        'Job': Job,
        'Class': Class,
        'Input': Input,
      };

  Future<CustomResponse> fetch() async {
    print('===========$Module ${Job.padLeft(6, ' ')}===========');
    var response = await channel.invokeMethod('getMTSData', {'data': data});
    return jsonDecode(response);
  }
}
