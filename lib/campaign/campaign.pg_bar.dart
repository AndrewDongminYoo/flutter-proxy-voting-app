// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/custom_text.dart';
import '../theme.dart';

class OrangeProgressBar extends LinearProgressIndicator {
  final double status;
  OrangeProgressBar({
    Key? key,
    required this.status,
  }) : super(
          key: key,
          value: status,
          backgroundColor: const Color(0xFFEEB304),
          color: customColor[ColorType.orange],
        );
}

class CampaignProgress extends Expanded {
  final double value;
  CampaignProgress({
    Key? key,
    required this.value,
  }) : super(
          key: key,
          child: Column(
            children: [
              OrangeProgressBar(status: value),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                      text: '공개',
                      colorType:
                          (value == 0.0 ? ColorType.white : ColorType.white54)),
                  CustomText(
                      text: '주주제안',
                      colorType:
                          (value == 0.3 ? ColorType.white : ColorType.white54)),
                  CustomText(
                      text: '의결권 위임',
                      colorType:
                          (value == 0.6 ? ColorType.white : ColorType.white54)),
                  CustomText(
                      text: '주주총회',
                      colorType:
                          (value == 1.0 ? ColorType.white : ColorType.white54))
                ],
              )
            ],
          ),
        );
}
