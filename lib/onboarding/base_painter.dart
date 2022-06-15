import 'package:bside/onboarding/page_indicator.dart';
import 'package:flutter/material.dart';

abstract class BasePainter extends CustomPainter {
  final PageIndicator widget;
  final double page;
  final int index;
  final Paint _paint;

  double lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }

  BasePainter(this.widget, this.page, this.index, this._paint);

  void draw(Canvas canvas, double space, double size, double radius);

  bool _shouldSkip(int index) {
    return false;
  }
  //double secondOffset = index == widget.count-1 ? radius : radius + ((index + 1) * (size + space));

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    for (int i = 0, c = widget.count; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(
          Offset(i * (size + space) + radius, radius), radius, _paint);
    }

    double page = this.page;
    if (page < index) {
      page = 0.0;
    }
    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  bool shouldRepaint(BasePainter oldDelegate) {
    return oldDelegate.page != page;
  }
}

class WarmPainter extends BasePainter {
  WarmPainter(PageIndicator widget, double page, int index, Paint paint)
      : super(widget, page, index, paint);

  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double distance = size + space;
    double start = index * (size + space);

    if (progress > 0.5) {
      double right = start + size + distance;
      //progress=>0.5-1.0
      //left:0.0=>distance

      double left = index * distance + distance * (progress - 0.5) * 2;
      canvas.drawRRect(
          RRect.fromLTRBR(left, 0.0, right, size, Radius.circular(radius)),
          _paint);
    } else {
      double right = start + size + distance * progress * 2;

      canvas.drawRRect(
          RRect.fromLTRBR(start, 0.0, right, size, Radius.circular(radius)),
          _paint);
    }
  }
}
