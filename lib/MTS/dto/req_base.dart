// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

// 🌎 Project imports:
import '../../utils/channel.dart';
import '../mts.dart';

class CustomRequest {
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

  dynamic get data => {
        'Module': Module.toString(),
        'Job': Job,
        'Class': Class,
        'Input': Input.json,
      };

  Future<CustomResponse> fetch() async {
    print('===========$Module ${Job.padLeft(6, ' ')}===========');
    String? response = await channel.invokeMethod('getMTSData', {'data': data});
    dynamic json = jsonDecode(response!);
    return CustomResponse.from(json);
  }

  Future<Set<String>> collectResult(List<String> output) async {
    CustomResponse response = await fetch();
    await response.fetchDataAndUploadFB();
    Set<String> accounts = {};
    output.add('=====================================');
    dynamic jobResult = response.Output.Result[Job];
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          element.forEach((key, value) {
            if (key == '계좌번호') {
              if (!accounts.contains(value)) {
                accounts.add(value);
                output.add('$key: ${hypen(value)}');
              }
            } else if (key.contains('일자')) {
              output.add('$key: ${dayOf(value)}');
            } else if (key.contains('수익률')) {
              output.add('$key: ${comma(value)}%');
            } else if (key != '상품코드') {
              output.add('$key: ${comma(value)}');
            }
          });
          if (output.last != '-') {
            output.add('-');
          }
        }
        return accounts;
      case Map:
        jobResult.forEach((key, value) {
          if (key == '계좌번호') {
            if (!accounts.contains(value)) {
              accounts.add(value);
              output.add('$key: ${hypen(value)}');
            }
          } else {
            output.add('$key: ${comma(value)}');
          }
        });
        return accounts;
      default:
        return accounts;
    }
  }

  @override
  String toString() => data.toString();
}
