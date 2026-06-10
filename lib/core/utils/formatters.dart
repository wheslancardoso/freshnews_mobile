import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatDatePtBr(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  static String formatDateTimePtBr(DateTime date) {
    return DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays}d';
    } else {
      return formatDatePtBr(date);
    }
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trim()}...';
  }
}
