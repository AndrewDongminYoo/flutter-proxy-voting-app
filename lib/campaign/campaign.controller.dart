import 'package:bside/campaign/campaign.data.dart';
import 'package:bside/campaign/campaign.model.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class CampaignController extends GetxController {
  Campaign campaign = campaigns[0];

  void setCampaign(Campaign newCampaign) {
    campaign = newCampaign;
    update();
  }
}
