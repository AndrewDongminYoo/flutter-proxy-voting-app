// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../auth/widget/auth_forms.dart';
import '../../auth/widget/card_formatter.dart';

class TradingFirmIdForm extends StatefulWidget {
  const TradingFirmIdForm({Key? key}) : super(key: key);

  @override
  State<TradingFirmIdForm> createState() => _TradingFirmIdFormState();
}

class _TradingFirmIdFormState extends State<TradingFirmIdForm> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      inputFormatters: [
        CardFormatter(
          sample: 'xxxxxxxxxx',
          separator: '',
        ),
      ],
      style: authFormFieldStyle,
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '아이디',
        helperText: '아이디를 입력해주세요',
      ),
    );
  }
}

class TradingFirmPasswordForm extends StatefulWidget {
  const TradingFirmPasswordForm({Key? key}) : super(key: key);

  @override
  State<TradingFirmPasswordForm> createState() =>
      _TradingFirmPasswordFormState();
}

class _TradingFirmPasswordFormState extends State<TradingFirmPasswordForm> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      inputFormatters: [
        CardFormatter(
          sample: 'xxxxxxxxxx',
          separator: '',
        ),
      ],
      style: authFormFieldStyle,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '비밀번호',
        helperText: '비밀번호를 입력해주세요',
      ),
    );
  }
}
