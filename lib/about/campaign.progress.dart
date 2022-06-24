import 'package:flutter/material.dart';

class CampaignProgressView extends StatelessWidget {
  const CampaignProgressView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stepper(
      type: StepperType.vertical,
      steps: const [
        Step(
          title: Text('Step 1 title'),
          content: Text(''),
        ),
        Step(
          title: Text('Step 2 title'),
          content: Text(''),
        ),
      ],
    );
  }
}
