import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/authentication/controllers/onboarding/onbording_controlller.dart';

class SkipTextButton extends StatelessWidget {
  const SkipTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        OnbordingControlller.instance.skipPage();
      },
      child: const Text("Skip"),
    );
  }
}
