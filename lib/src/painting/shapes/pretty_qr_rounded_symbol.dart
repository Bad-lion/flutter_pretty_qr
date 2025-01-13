import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:pretty_qr_code/src/painting/pretty_qr_brush.dart';
import 'package:pretty_qr_code/src/painting/pretty_qr_shape.dart';
import 'package:pretty_qr_code/src/rendering/pretty_qr_painting_context.dart';
import 'package:pretty_qr_code/src/rendering/pretty_qr_render_experiments.dart';
import 'package:pretty_qr_code/src/painting/extensions/pretty_qr_module_extensions.dart';

/// A rectangular symbol with rounded corners.
@sealed
class PrettyQrRoundedSymbol extends PrettyQrShape {
  /// The color or brush to use when filling the QR code.
  @nonVirtual
  final Color color;

  /// If non-null, the corners of QR modules are rounded by this [BorderRadius].
  @nonVirtual
  final BorderRadiusGeometry borderRadius;

  @nonVirtual
  final double outSquareRadius;
  @nonVirtual
  final double innerSquareRadius;
  @nonVirtual
  final double whiteSquareDeflate;
  @nonVirtual
  final double blackSquareDeflate;
  @nonVirtual
  final double whiteSquareRadius;

  /// The default value for [borderRadius].
  static const kDefaultBorderRadius = BorderRadius.all(
    Radius.circular(8),
  );

  /// Creates a basic QR shape.
  @literal
  const PrettyQrRoundedSymbol({
    this.color = const Color(0xFF000000),
    this.borderRadius = kDefaultBorderRadius,
    this.outSquareRadius = 12,
    this.whiteSquareDeflate = 7,
    this.whiteSquareRadius = 8,
    this.innerSquareRadius = 6,
    this.blackSquareDeflate = 12,
  });

  @override
  void paint(PrettyQrPaintingContext context) {
    final pointPath = Path();
    final closeSquerePath = Path();
    final squarePath = Path();
    final squareWhitePath = Path();
    final innerSquarePath = Path();

    final pointBrush = PrettyQrBrush.from(color);
    final closeSquareBrush = PrettyQrBrush.from(Colors.white);

    final pointPaint = pointBrush.toPaint(
      context.estimatedBounds,
      textDirection: context.textDirection,
    );
    final closeSquerPaint = closeSquareBrush.toPaint(
      context.estimatedBounds,
      textDirection: context.textDirection,
    );

    final radius = borderRadius.resolve(context.textDirection);

    for (final module in context.matrix) {
      if (!module.isDark) continue;

      final moduleRect = module.resolveRect(context);
      final modulePath = Path()
        ..addRRect(radius.toRRect(moduleRect))
        ..close();

      if (PrettyQrRenderExperiments.needsAvoidComplexPaths) {
        context.canvas.drawPath(modulePath, pointPaint);
      } else {
        pointPath.addPath(modulePath, Offset.zero);
      }
    }

    final sss = context.matrix.first.resolveRect(context);

    final pointSize = (sss.right) * 7;

    final qrSize = context.estimatedBounds.right;

    final topLeftSquer = Rect.fromLTRB(0, 0, pointSize, pointSize);
    final topRightSquer =
        Rect.fromLTWH(qrSize - pointSize, 0, pointSize, pointSize);
    final bottomLeftSquer =
        Rect.fromLTWH(0, qrSize - pointSize, pointSize, pointSize);

    closeSquerePath.addRect(topLeftSquer);
    closeSquerePath.addRect(topRightSquer);
    closeSquerePath.addRect(bottomLeftSquer);

    squarePath.addRRect(RRect.fromRectAndRadius(
        topLeftSquer, Radius.circular(outSquareRadius)));
    squarePath.addRRect(RRect.fromRectAndRadius(
        topRightSquer, Radius.circular(outSquareRadius)));
    squarePath.addRRect(RRect.fromRectAndRadius(
        bottomLeftSquer, Radius.circular(outSquareRadius)));

    squareWhitePath.addRRect(RRect.fromRectAndRadius(
        topLeftSquer.deflate(whiteSquareDeflate),
        Radius.circular(whiteSquareRadius)));
    squareWhitePath.addRRect(RRect.fromRectAndRadius(
        topRightSquer.deflate(whiteSquareDeflate),
        Radius.circular(whiteSquareRadius)));
    squareWhitePath.addRRect(RRect.fromRectAndRadius(
        bottomLeftSquer.deflate(whiteSquareDeflate),
        Radius.circular(whiteSquareRadius)));

    innerSquarePath.addRRect(RRect.fromRectAndRadius(
        topLeftSquer.deflate(blackSquareDeflate),
        Radius.circular(innerSquareRadius)));
    innerSquarePath.addRRect(RRect.fromRectAndRadius(
        topRightSquer.deflate(blackSquareDeflate),
        Radius.circular(innerSquareRadius)));
    innerSquarePath.addRRect(RRect.fromRectAndRadius(
        bottomLeftSquer.deflate(blackSquareDeflate),
        Radius.circular(innerSquareRadius)));

    pointPath.close();
    closeSquerePath.close();
    squarePath.close();
    squareWhitePath.close();
    innerSquarePath.close();

    context.canvas.drawPath(pointPath, pointPaint);
    context.canvas.drawPath(closeSquerePath, closeSquerPaint);
    context.canvas.drawPath(squarePath, pointPaint);
    context.canvas.drawPath(squareWhitePath, closeSquerPaint);
    context.canvas.drawPath(innerSquarePath, pointPaint);
  }

  @override
  PrettyQrRoundedSymbol? lerpFrom(PrettyQrShape? a, double t) {
    if (identical(a, this)) {
      return this;
    }

    if (a == null) return this;
    if (a is! PrettyQrRoundedSymbol) return null;

    if (t == 0.0) return a;
    if (t == 1.0) return this;

    return PrettyQrRoundedSymbol(
      color: PrettyQrBrush.lerp(a.color, color, t)!,
      borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!,
    );
  }

  @override
  PrettyQrRoundedSymbol? lerpTo(PrettyQrShape? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    if (b == null) return this;
    if (b is! PrettyQrRoundedSymbol) return null;

    if (t == 0.0) return this;
    if (t == 1.0) return b;

    return PrettyQrRoundedSymbol(
      color: PrettyQrBrush.lerp(color, b.color, t)!,
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t)!,
    );
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, color, borderRadius);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is PrettyQrRoundedSymbol &&
        other.color == color &&
        other.borderRadius == borderRadius;
  }
}
