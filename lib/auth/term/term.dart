// import 'shared/custom_color.dart';
// import 'shared/custom_grid.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../shared/custom_text.dart';
// import 'privacy_term_page.dart';
// import 'service_term_page.dart';

// const items = {
//   1: '[필수]서비스 이용약관',
//   2: '[필수]개인정보 수집 및 이용동의',
//   3: '[필수]통신사 본인인증',
//   4: '[선택]실시간 주주총회 등 광고성 정보수신'
// };

// class ServiceTerm extends StatefulWidget {
//   const ServiceTerm({Key? key}) : super(key: key);

//   @override
//   State<ServiceTerm> createState() => _ServiceTermState();
// }

// class _ServiceTermState extends State<ServiceTerm> {
//   final List agreeTerms = [false, false, false, false];
//   bool showDetails = false;

//   getAllAgreeTerms() {
//     return agreeTerms.every((element) => element);
//   }

//   setAllAgreeTerms(value) {
//     for (var i = 0; i < agreeTerms.length; i++) {
//       agreeTerms[i] = value;
//     }
//     setState(() {});
//   }

//   openPage(int index) async {
//     // switch (index) {
//     //   case 0:
//     //     Get.to(() => const ServicePage());
//     //     break;
//     //   case 1:
//     //     Get.to(() => const PrivacyPage());
//     //     break;
//     //   case 2:
//     //     await launchUrl(
//     //         Uri.parse("https://safe.ok-name.co.kr/eterms/agreement002.jsp"));
//     //     break;
//     //   case 3:
//     //     await launchUrl(
//     //         Uri.parse("https://safe.ok-name.co.kr/eterms/agreement001.jsp"));
//     //     break;
//     //   default:
//     //     break;
//     // }
//     // return;
//   }

//   Widget _buildCheckBox(int index, String label) {
//     return CheckboxListTile(
//       value: agreeTerms[index],
//       onChanged: (value) {
//         setState(() {
//           agreeTerms[index] = value;
//         });
//       },
//       title: RichText(
//           text: TextSpan(children: [
//         TextSpan(
//             text: label,
//             style: TextStyle(color: customColor[ColorType.purple]),
//             recognizer: TapGestureRecognizer()
//               ..onTap = () {
//                 openPage(index);
//               }),
//         const TextSpan(text: '에 동의', style: TextStyle(color: Colors.black))
//       ])),
//       checkboxShape: const CircleBorder(),
//       activeColor: customColor[ColorType.yellow],
//       controlAffinity: ListTileControlAffinity.leading,
//     );
//   }

//   Widget _buildTerms() {
//     return ListView.builder(
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         itemBuilder: (context, index) {
//           return _buildCheckBox(index, items[index]!);
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // FIXME: 약관 리스트 출력시 에러 발생
//     return showDetails
//         ? _buildTerms()
//         : Align(
//           alignment: Alignment.topCenter,
//           child: Column(children: [
//               CheckboxListTile(
//                 value: getAllAgreeTerms(),
//                 onChanged: setAllAgreeTerms,
//                 title: const Text('약관 모두 동의'),
//                 checkboxShape: const CircleBorder(),
//                 activeColor: customColor[ColorType.yellow],
//                 controlAffinity: ListTileControlAffinity.leading,
//               ),
//               Container(
//                 alignment: Alignment.center,
//                 width: customW[CustomW.w3],
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       showDetails = true;
//                     });
//                   },
//                   child: Ink(
//                       child: const CustomText(
//                     text: '약관 모두 보기',
//                     typoType: TypoType.body,
//                   )),
//                 ),
//               )
//             ]),
//         );
//   }
// }
