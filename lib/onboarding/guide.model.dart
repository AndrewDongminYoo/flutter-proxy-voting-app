class Guide {
  final int id;
  final String name;
  final String aosImageUrl;
  final String iosImageUrl;

  Guide(
      {required this.id,
      required this.name,
      required this.aosImageUrl,
      required this.iosImageUrl});
}

List<Guide> mockGuideList = [
  Guide(
      id: 0,
      name: '주주제안',
      aosImageUrl: 'assets/images/onboarding_1_aos.png',
      iosImageUrl: 'assets/images/onboarding_1_ios.png'),
  Guide(
      id: 1,
      name: '캠페인 현황',
      aosImageUrl: 'assets/images/onboarding_2_aos.png',
      iosImageUrl: 'assets/images/onboarding_2_ios.png'),
  Guide(
      id: 2,
      name: '댓글 소통',
      aosImageUrl: 'assets/images/onboarding_3_aos.png',
      iosImageUrl: 'assets/images/onboarding_3_ios.png'),
];
