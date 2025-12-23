/// Utility class for formatting DateTime objects into user-friendly strings
/// Handles relative time (Today, Yesterday) and absolute dates with Bangladesh timezone
class DateTimeFormatter {
  /// Formats a DateTime into a human-readable string with relative or absolute time
  ///
  /// Examples:
  /// - "Today 2:30 PM"
  /// - "Yesterday 11:45 AM"
  /// - "3 days ago"
  /// - "Jan 15, 2024 9:00 AM"
  static String formatRelativeDateTime(DateTime date) {
    // Convert UTC to Bangladesh local time
    final localDate = date.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localDate);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(localDate)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(localDate)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatFullDate(localDate);
    }
  }

  /// Formats time in 12-hour format with AM/PM
  /// Example: "2:30 PM"
  static String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Formats date as "Month Day, Year Time"
  /// Example: "Jan 15, 2024 9:00 AM"
  static String _formatFullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}, '
        '${date.year} ${_formatTime(date)}';
  }

  /// Formats only the date without time
  /// Example: "Jan 15, 2024"
  static String formatDateOnly(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats only the time
  /// Example: "2:30 PM"
  static String formatTimeOnly(DateTime date) {
    final localDate = date.toLocal();
    return _formatTime(localDate);
  }

  /// Formats with day of week
  /// Example: "Monday, Jan 15, 2024"
  static String formatWithDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final localDate = date.toLocal();
    return '${days[localDate.weekday - 1]}, ${months[localDate.month - 1]} ${localDate.day}, ${localDate.year}';
  }

  /// Returns a short relative time string
  /// Example: "2h ago", "5m ago", "3d ago"
  static String formatShortRelative(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}