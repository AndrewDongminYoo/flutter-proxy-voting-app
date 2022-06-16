class AgendaItem {
  const AgendaItem(
      {required this.section,
      required this.agendaFrom,
      required this.head,
      this.body = '',
      this.defaultOption = 0});

  final String section;
  final String agendaFrom;
  final String head;
  final String body;
  final int defaultOption;
}
