<p align="center">
  <img src="./docs/flutter-sample.webp" width="200" />
  <h1 align="center">Flutter Sample</h1>
</p>

전자위임 샘플앱은 **인증된 소액주주들이 전문투자기관들과 함께 기업에 대해 심도 깊은 의견을 나누고 유용한 정보를 공유 하고 행동할 수 있는 앱**입니다. 전자위임 샘플앱은 소액주주를 만나는 주요 창구로서, 우리가 구축하고자 하는 '주주인증, 결집 및 실행이 가능한 주주 행동주의 플랫폼'를 구성하는 핵심 서비스중 하나 입니다. MTS 기능으로 주주를 인증하고, 라운지로 결집시킨 뒤에 전자위임으로 행동하고자 합니다.

## Quick Start

### Requirements

- Flutter (>=3.0.x)
  - Flutter beta 버전으로 업그레이드 필요
  - 혹은 하단 scripts 참고
- .env
- android/key.properties
- android/upload-keystore.jks

### Scripts

```bash
# Flutter 버전 업데이트
flutter channel master
flutter upgrade

# 내용 확인
flutter --version
> Flutter is already up to date on channel master
> Flutter 3.4.0-19.0.pre.72 • channel master • https://github.com/flutter/flutter.git
> Framework • revision 202f5771f4 (5 hours ago) • 2022-09-04 20:28:23 -0400
> Engine • revision b94120dfe9
> Tools • Dart 2.19.0 (build 2.19.0-168.0.dev) • DevTools 2.17.0
```

```bash
# install
flutter pub get

# create .env
touch .env

# Run
flutter run
```

## Tutorial

```bash
# run storybook
flutter run -t lib/main_dashbook.dart

# Set firebase
flutterfire configure

# deploy Android & iOS
flutter build appbundle && cd android && bundle exec fastlane beta & cd ..
cd ios && pod update && cd .. && flutter build ipa
flutter build ipa && cd ios && bundle exec fastlane beta & cd ..
nano ios/Runner.xcodeproj/project.pbxproj # ios version update

# Select xcode-beta
sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer/

# Debug
flutter upgrade
flutter clean && flutter run

# import sorter
flutter pub run import_sorter:main
```
