import 'package:flutter/material.dart';
import 'package:bside/shared/custom_color.dart';

class HorizontalProgressBar extends StatelessWidget {
  final double value;
  const HorizontalProgressBar({Key? key, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: const Color(0xFFEEB304),
      color: customColor[ColorType.orange],
    );
  }
}

class CampaignProgress extends StatelessWidget {
  final double value;
  const CampaignProgress({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        HorizontalProgressBar(value: value),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('공개',
                style:
                    TextStyle(color: value == 0.0 ? Colors.white :Colors.white54)),
            Text('주주제안', style: TextStyle(color: value == 0.3 ? Colors.white :Colors.white54)),
            Text('의결권 위임', style: TextStyle(color: value == 0.6 ? Colors.white :Colors.white54)),
            Text('주주총회', style: TextStyle(color: value == 1.0 ? Colors.white :Colors.white54))
          ],
        )
      ],
    ));
  }
}
