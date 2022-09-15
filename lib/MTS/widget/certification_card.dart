// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// 🌎 Project imports:
import '../../shared/shared.dart';
import '../../theme.dart';
import '../mts.dart';

// ignore: must_be_immutable
class CertificationCard extends StatelessWidget {
  final MtsController _mtsController = MtsController.get();
  RKSWCertItem item;
  Function()? onPressed;

  CertificationCard({
    super.key,
    required this.item,
    required this.onPressed,
  });

  void changePass(BuildContext context) {
    _mtsController.changePass(context, item);
  }

  void detailInfo() {
    Map<String, String> response = _mtsController.detailInfo(item);
    Get.dialog(AlertDialog(
      title: CustomText(
        text: '인증서정보',
        typoType: TypoType.h2Bold,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('발급자명: ${response["발급자"]}'),
          Text('발급기관: ${response["발급기관"]}'),
          Text('인증기관: ${response["인증기관"]}'),
          Text('용도구분: ${response["용도구분"]}'),
          Text('유효기간: ${response["유효기간"]}'),
        ],
      ),
    ));
  }

  void deleteCert() {
    _mtsController.deleteCert(item);
  }

  @override
  Widget build(BuildContext context) {
    bool isExpired = DateTime.now().isAfter(item.expireDate);
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          width: Get.width - 20,
          height: Get.width * 0.42,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(18),
            ),
            color: isExpired ? Colors.grey : Colors.white,
            boxShadow: kElevationToShadow[3],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: isExpired ? '${item.username}(만료)' : item.username,
                    typoType: TypoType.h1Bold,
                    textAlign: TextAlign.start,
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        Get.bottomSheet(Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 80,
                          ),
                          height: Get.height * 0.5,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                UnderlinedButton(
                                  textColor: Colors.black,
                                  onPressed: () => changePass(context),
                                  label: '암호변경',
                                  width: CustomW.w4,
                                ),
                                UnderlinedButton(
                                  textColor: Colors.black,
                                  onPressed: detailInfo,
                                  label: '인증서 정보',
                                  width: CustomW.w4,
                                ),
                                UnderlinedButton(
                                  textColor: const Color(0xFFC70039),
                                  onPressed: deleteCert,
                                  label: '삭제하기',
                                  width: CustomW.w4,
                                ),
                              ],
                            ),
                          ),
                        ));
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: isExpired ? Colors.white : Colors.grey,
                        size: 30,
                      ))
                ],
              ),
              CustomText(
                text: '구분 ${item.origin}',
                typoType: TypoType.h2Bold,
                isFullWidth: true,
                textAlign: TextAlign.start,
              ),
              CustomText(
                text: '용도 ${item.policy}',
                typoType: TypoType.h2Bold,
                isFullWidth: true,
                textAlign: TextAlign.start,
              ),
              Stack(
                children: [
                  CustomText(
                    text: '만료일 ${item.certExpire}',
                    typoType: TypoType.h2Bold,
                    textAlign: TextAlign.start,
                    isFullWidth: true,
                  ),
                  isExpired
                      ? EnhanceIcon(
                          icon: Icons.delete_forever_rounded,
                          alignment: Alignment.bottomRight,
                        )
                      : Container()
                ],
              ),
            ],
          ),
        ));
  }
}
