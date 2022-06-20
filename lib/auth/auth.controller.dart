import 'package:get/get_state_manager/get_state_manager.dart';

class AuthController extends GetxController {
  bool isLogined = false;

  void signUp() {
    isLogined = true;
  }
}
