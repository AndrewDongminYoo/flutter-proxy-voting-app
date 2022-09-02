import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/shared.dart';
import '../models/certification.model.dart';

// ignore: must_be_immutable
class CertificationCard extends StatelessWidget {
  RKSWCertItem item;

  CertificationCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    bool isExpired = DateTime.now().isAfter(item.expireDate);
    return GestureDetector(
        onTap: () {
          goToMtsLoginWithID();
        },
        child: Container(
          width: Get.width - 20,
          height: Get.width * 0.4,
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
                    text: item.username,
                    typoType: TypoType.h1Bold,
                    textAlign: TextAlign.start,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 30,
                  )
                ],
              ),
              CustomText(
                text: '구분 ${item.origin}',
                typoType: TypoType.h2Bold,
                isFullWidth: true,
                textAlign: TextAlign.start,
              ),
              CustomText(
                text: '용도 ${item.objective}',
                typoType: TypoType.h2Bold,
                isFullWidth: true,
                textAlign: TextAlign.start,
              ),
              CustomText(
                text: '만료일 ${item.expiredTime}',
                typoType: TypoType.h2Bold,
                isFullWidth: true,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ));
  }
}
