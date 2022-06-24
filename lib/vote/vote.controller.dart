import 'package:bside/vote/vote.service.dart';
import 'package:get/get.dart';

import '../shared/loading_screen.dart';
import 'shareholder.data.dart';

class VoteController extends GetxController {
  final VoteService _service = VoteService();
  final shareholders = <Shareholder>[];
  Shareholder? shareholder;

  void startLoading() {
    Get.dialog(const LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void toVote(String name) async {
    startLoading();
    var response;
    try {
      response = await _service.findSharesByName('tli', name);
    } catch (e) {
      print(e);
    } finally {}

    (response.body['shareholders'])
        .forEach((e) => shareholders.add(Shareholder.fromSharesJson(e)));

    stopLoading();
    if (shareholders.length > 1) {
      Get.toNamed('/duplicate');
    } else if (shareholders.length == 1) {
      shareholder = shareholders[0];
      Get.toNamed('/checkvotenum');
    } else {
      Get.toNamed('/not-shareholder');
    }
  }

  void selectShareholder(int index) async {
    await _service.validateShareholder(index);
    shareholder = shareholders[index];
  }

  List<String> addressList() {
    return shareholders.map((e) {
      return e.address;
    }).toList();
  }
}
