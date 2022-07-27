import 'package:flutter/material.dart';

import '../../lib.dart';


class CertificaitionIdForm extends StatefulWidget {
  const CertificaitionIdForm({Key? key}) : super(key: key);

  @override
  State<CertificaitionIdForm> createState() => _CertificaitionIdFormState();
}

class _CertificaitionIdFormState extends State<CertificaitionIdForm> {
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

class CertificaitionPasswordForm extends StatefulWidget {
  const CertificaitionPasswordForm({Key? key}) : super(key: key);

  @override
  State<CertificaitionPasswordForm> createState() => _CertificaitionPasswordFormState();
}

class _CertificaitionPasswordFormState extends State<CertificaitionPasswordForm> {
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