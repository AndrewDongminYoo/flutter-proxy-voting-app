# bside_pie

A new Flutter project.

## 기능

**핵심 기능**

- 본인인증 + 주주 명부 대조
- 안건 투표
- 전자 서명, 신분증 업로드

**부가 기능**

- 등기 관리
- 내역 관리 (알림, 위임, 문의)
- 히스토리 (이전 전자위임 기록)

## 구현 방식

- State management: GetX
- Router: GetX
- Test: flutter_test, integration_test
- Network: Amplify GraphQL
- Database: Amplify DataStore (DynamoDB+AppSync), Amplify Storage (S3)
- Signature: signature
- Upload image: image_picker, amplify
- i18n: Getx
- asset: FlutterGen
- Other libraries: FlutterFire, AppsFlyer, AppCenter, Fastlane

## 필수 파일

- .env
- android/key.properties
- android/upload-keystore.jks

## Scripts

```bash
# install
flutter pub get

# create .env
touch .env

# run storybook
flutter run -t lib/main_dashbook.dart

# Set firebase
flutterfire configure

# deploy Android & iOS
flutter build appbundle && cd android && bundle exec fastlane beta & cd ..
flutter build ipa && cd ios && bundle exec fastlane beta & cd ..

# Select xcode-beta
sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer/

# Debug
flutter upgrade
flutter clean && flutter run
```

## 참고사항

- [History of everything](https://github.com/2d-inc/HistoryOfEverything)
- [Official samples - component 위주](https://github.com/flutter/samples)
- [Flutter samples - UI 위주](https://github.com/diegoveloper/flutter-samples)
- [Planets app tutorial](https://github.com/sergiandreplace/flutter_planets_tutorial)
- [NewsBuzz](https://github.com/theankurkedia/NewsBuzz)
- [BookSearch](https://github.com/Norbert515/BookSearch)
- [Beer Me Up](https://github.com/benoitletondor/Beer-Me-Up)
- [SpaceX Go](https://github.com/jesusrp98/spacex-go)
- [Flutter quiz app](https://github.com/fireship-io/flutter-firebase-quizapp-course)