import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._(); // prevent instantiation

  /// Converts UTC DateTime to BD time (+6h)
  static DateTime toBD(DateTime date) {
    return date.isUtc
        ? date.add(const Duration(hours: 6))
        : date.toUtc().add(const Duration(hours: 6));
  }

  /// "16-04-2026"
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd-MM-yyyy').format(toBD(date));
  }

  /// "04:00 PM"
  static String formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    final bd = toBD(date);
    final hour = bd.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${bd.minute.toString().padLeft(2, '0')} $period';
  }

  /// "16-04-2026, 04:00 PM"
  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${formatDate(date)}, ${formatTime(date)}';
  }

  /// "HH:mm" string (e.g. "09:00") → "09:00 AM"
  static String formatTimeString(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return 'N/A';
    final parts = rawTime.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }
    return rawTime; // already formatted e.g. "4:00 PM - 5:15 PM"
  }
}