import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String figtree = "Figtree";
const String interBold = "InterBold";
const String inter = "InterNormal";
const String MapId = "cdcb557842c93dcbd692fa6a";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String capitalize(String value) {
  if (value.isEmpty) return "";
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

String formatDashboardDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) {
    return "";
  }

  try {
    final date = DateTime.parse(rawDate);

    return DateFormat('EEE, MMM d').format(date);
  } catch (e) {
    return rawDate;
  }
}

String format12HourTime(String? rawDateTime) {
  if (rawDateTime == null || rawDateTime.isEmpty) {
    return "";
  }

  try {
    final dateTime = DateTime.parse(rawDateTime).toLocal();

    return DateFormat('hh:mm a').format(dateTime);
  } catch (e) {
    return rawDateTime;
  }
}
