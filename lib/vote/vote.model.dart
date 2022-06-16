import 'dart:ui';

enum VoteType {
  none(-2),
  agree(-1),
  disagree(0),
  abstention(1);

  const VoteType(this.value);
  final num value;
}

class VoteButton {
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  final String label;
  final VoteType value;

  VoteButton({
    required this.borderColor,
    required this.textColor,
    required this.bgColor,
    required this.label,
    required this.value 
  });
}
