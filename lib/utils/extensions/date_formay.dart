// date_formatter.dart
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter();

  String call(int? millis) {
    if (millis == null) return '—';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('dd/MM/yy h:mma').format(dt);
  }
}
