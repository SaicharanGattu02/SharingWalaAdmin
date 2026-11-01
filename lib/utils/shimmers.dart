import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Color shimmerBaseColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
}

Color shimmerHighlightColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
}

Container fadeShimmercircle({required double size}) {
  return Container(
    margin: const EdgeInsets.all(2),
    decoration: const BoxDecoration(color: Color(0xffE6E8EB), shape: BoxShape.circle),
    height: size,
    width: size,
  );
}

Container fadeShimmerbox({
  required double height,
  required double width,
  required double radius,
}) {
  return Container(
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: const Color(0xffE6E8EB),
      borderRadius: BorderRadius.circular(radius),
    ),
    height: height,
    width: width,
  );
}

Widget shimmerRoundedContainer(double width, double height) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(100),
    ),
  );
}

Container fadeShimmerboxelite({
  required double height,
  required double width,
  required double radius,
}) {
  return Container(
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: const Color(0xFF3D3D3D),
      borderRadius: BorderRadius.circular(radius),
    ),
    height: height,
    width: width,
  );
}

Container fadeShimmerboxporter({
  required double height,
  required double width,
  required double radius,
}) {
  return Container(
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: const Color(0xFF959595),
      borderRadius: BorderRadius.circular(radius),
    ),
    height: height,
    width: width,
  );
}

Shimmer shimmerCircle(double size, BuildContext context) {
  return Shimmer.fromColors(
    baseColor: shimmerBaseColor(context),
    highlightColor: shimmerHighlightColor(context),
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    ),
  );
}

Widget shimmerRectangle(double size, BuildContext context) {
  return Shimmer.fromColors(
    baseColor: shimmerBaseColor(context),
    highlightColor: shimmerHighlightColor(context),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

Shimmer shimmerDivider(double height, double width, BuildContext context) {
  return Shimmer.fromColors(
    baseColor: shimmerBaseColor(context),
    highlightColor: shimmerHighlightColor(context),
    child: Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(color: Colors.white),
    ),
  );
}

Shimmer shimmerContainer(
  double width,
  double height,
  BuildContext context, {
  bool isButton = false,
}) {
  return Shimmer.fromColors(
    baseColor: shimmerBaseColor(context),
    highlightColor: shimmerHighlightColor(context),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isButton ? Colors.grey : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: isButton
          ? Center(child: shimmerText(80, 18, context))
          : const SizedBox(),
    ),
  );
}

// Shimmer component for text
Shimmer shimmerText(double width, double height, BuildContext context) {
  return Shimmer.fromColors(
    baseColor: shimmerBaseColor(context),
    highlightColor: shimmerHighlightColor(context),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}

// Shimmer component for linear progress bar
Shimmer shimmerLinearProgress(double height, BuildContext context) {
  return Shimmer.fromColors(
    baseColor: shimmerBaseColor(context),
    highlightColor: shimmerHighlightColor(context),
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}

/// High-fidelity Ride Card Shimmer that mirrors MyRideCard
Widget rideCardShimmer(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
  final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  final routeBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  final base = shimmerBaseColor(context);
  final highlight = shimmerHighlightColor(context);

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Driver info row
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 90,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Route points
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: routeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        height: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Meta strip (chips & price)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 55,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 55,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 55,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shimmer list with multiple rideCardShimmers
Widget rideCardListShimmer(BuildContext context, {int count = 3}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(count, (_) => rideCardShimmer(context)),
  );
}

/// Shimmer for Host Posted Trips or Guest Active Trip Requests
Widget hostTripCardShimmer(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
  final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  final base = shimmerBaseColor(context);
  final highlight = shimmerHighlightColor(context);

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor, width: 1.2),
    ),
    child: Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 130,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 70,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
