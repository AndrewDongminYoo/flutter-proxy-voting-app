// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../theme.dart';

class OrangeProgressBar extends LinearProgressIndicator {
  @override
  final double value;
  OrangeProgressBar({
    Key? key,
    required this.value,
  }) : super(
          key: key,
          value: value,
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
              OrangeProgressBar(value: value),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('공개',
                      style: TextStyle(
                        color: value == 0.0 ? Colors.white : Colors.white54,
                      )),
                  Text('주주제안',
                      style: TextStyle(
                        color: value == 0.3 ? Colors.white : Colors.white54,
                      )),
                  Text('의결권 위임',
                      style: TextStyle(
                        color: value == 0.6 ? Colors.white : Colors.white54,
                      )),
                  Text('주주총회',
                      style: TextStyle(
                        color: value == 1.0 ? Colors.white : Colors.white54,
                      ))
                ],
              )
            ],
          ),
        );
}
