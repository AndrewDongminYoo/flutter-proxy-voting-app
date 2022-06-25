import '../vote/vote.service.dart';
import 'package:get/get.dart';

import '../shared/loading_screen.dart';
import 'shareholder.data.dart';
import 'vote.model.dart';

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
    // ignore: prefer_typing_uninitialized_variables
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
      // FIXME
      // shareholder = shareholders[0];
      // Get.toNamed('/checkvotenum');
      print(shareholder);
      Get.toNamed('/duplicate');
    } else if (shareholders.length == 1) {
      shareholder = shareholders[0];
      Get.toNamed('/checkvotenum');
    } else {
      Get.toNamed('/not-shareholder');
    }
  }

  void selectShareholder(int index) async {
    shareholder = shareholders[index];
    await _service.validateShareholder(index);
  }

  List<String> addressList() {
    return shareholders.map((e) {
      return e.address;
    }).toList();
  }

  void postVoteResult(int uid, List<VoteType> voteResult) async {
    // TODO: device name
    const deviceName = "";

    final response = await _service.postVoteResult(
        uid,
        shareholder!.id,
        deviceName,
        _switchVoteValue(voteResult[0]),
        _switchVoteValue(voteResult[1]),
        _switchVoteValue(voteResult[2]),
        _switchVoteValue(voteResult[3]));
    VoteAgenda.fromJson(response.body['agenda']);
  }

  int _switchVoteValue(VoteType voteType) {
    switch (voteType) {
      case VoteType.agree:
        return 1;
      case VoteType.abstention:
        return 0;
      case VoteType.disagree:
        return -1;
      case VoteType.none:
        return -2;
    }
  }

  void postBackId(int uid, String backId) async {
    await _service.postBackId(uid, backId);
  }
}
