// 🎯 Dart imports:
import 'dart:convert' show json;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import '../../auth/auth.controller.dart';
import '../../shared/shared.dart';
import '../../theme.dart';

class EditModal extends StatefulWidget {
  const EditModal({Key? key}) : super(key: key);

  @override
  State<EditModal> createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  final AuthController _authCtrl = AuthController.get();

  int _viewPage = 1;
  int _selected = 0;
  String address = '';
  String _detailAddress = '';
  String _searchAddress = '';
  String _pickAddress = '';
  List<String> _searchedRoadAddressList = [];

  onClose() {
    goBack();
  }

  onSubmit() {
    if (_detailAddress.isNotEmpty) {
      address = '$_pickAddress, $_detailAddress';
      _authCtrl.setAddress(address);
      setState(() {});
      goBackWithVal(context, address);
    } else {
      goBack();
    }
  }

  @override
  void initState() {
    if (Get.arguments is String) {
      address = Get.arguments;
    } else if (_authCtrl.user.address.isNotEmpty) {
      address = _authCtrl.user.address;
    }
    if (address.isNotEmpty) {
      List splitAddress = address.split(', ');
      _pickAddress = splitAddress[0];
      _searchAddress = splitAddress[0];
      _detailAddress = splitAddress[1];
      _viewPage = 3;
    }
    super.initState();
  }

  onSearch() async {
    try {
      String clientId = dotenv.get('NAVER_GEOCODE_ID');
      String clientKey = dotenv.get('NAVER_GEOCODE_KEY');

      //naver cloud platform geocode header
      Map<String, String> headers = {
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientKey
      };

      List<String> roadAddressList = [];

      final parameters = {'query': _searchAddress};
      final uri = Uri.https('naveropenapi.apigw.ntruss.com',
          '/map-geocode/v2/geocode', parameters);
      final response = await http.get(uri, headers: headers);
      final jsonObj = json.decode(response.body);

      for (var e in jsonObj['addresses']) {
        roadAddressList.add(e['roadAddress']);
      }

      _searchedRoadAddressList = roadAddressList;

      setState(() {
        _viewPage = 2;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _onSelectAddress(int index) {
    setState(() {
      _selected = index;
    });
  }

  _onConfirmed(String pickConfirmAddress) {
    _pickAddress = pickConfirmAddress;
    _detailAddress = '';
    setState(() {
      _viewPage = 3;
    });
  }

  Widget detailAddressForm(String labelText) {
    return TextFormField(
      minLines: 2,
      maxLines: 3,
      initialValue: _detailAddress,
      autofocus: true,
      style: const TextStyle(
        letterSpacing: 2.0,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
      ),
      onChanged: (text) {
        _detailAddress = text;
      },
    );
  }

  Widget searchAddressForm() {
    TextEditingController controller =
        TextEditingController(text: _pickAddress);
    return TextFormField(
      controller: controller,
      minLines: 2,
      maxLines: 3,
      readOnly: _viewPage == 3 ? true : false,
      autofocus: _viewPage == 3 ? false : true,
      style: const TextStyle(
        letterSpacing: 2.0,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            controller.clear();
            _pickAddress = '';
            _searchAddress = '';
            setState(() {
              _viewPage = 1;
            });
          },
        ),
        border: const OutlineInputBorder(),
        labelText: '주소',
      ),
      onChanged: (text) {
        _searchAddress = text;
      },
    );
  }

  Widget selectAddressWidget() {
    return Column(
      children: [
        SizedBox(
          height: 130,
          width: Get.width,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _searchedRoadAddressList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: CustomCard(
                  content: RadioListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    activeColor: customColor[ColorType.yellow],
                    title: CustomText(
                      text: _searchedRoadAddressList[index],
                      textAlign: TextAlign.left,
                    ),
                    value: _searchedRoadAddressList[index],
                    groupValue: _searchedRoadAddressList[_selected],
                    onChanged: (value) {
                      _onSelectAddress(index);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        CustomButton(
          width: CustomW.w4,
          label: '확인',
          onPressed: () => _onConfirmed(_searchedRoadAddressList[_selected]),
        )
      ],
    );
  }

  Widget changeAddressWidget() {
    return Column(
      children: [
        searchAddressForm(),
        const SizedBox(
          height: 10,
        ),
        _viewPage == 1 ? Container() : detailAddressForm('세부 주소'),
        _viewPage == 1
            ? Container()
            : const SizedBox(
                height: 10,
              ),
        CustomButton(
          label: _viewPage == 1 ? '검색' : '확인',
          onPressed: () => _viewPage == 1 ? onSearch() : onSubmit(),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(
        left: 25,
        right: 25,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: _viewPage == 1
                ? '주소를 검색해주세요!'
                : _viewPage == 2
                    ? '주소를 선택해주세요!'
                    : '세부 주소를 입력해주세요!',
            typoType: TypoType.body,
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: Colors.black,
              semanticLabel: 'Close modal',
            ),
          )
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: SizedBox(
          height: _viewPage == 1
              ? 180
              : _viewPage == 2
                  ? 220
                  : 280,
          child: _viewPage == 2 ? selectAddressWidget() : changeAddressWidget(),
        ),
      ),
    );
  }
}
