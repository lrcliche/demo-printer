import 'package:intl/intl.dart';

/// Formatea cadenas ISO o fechas a dd/MM/yyyy HH:mm
String fmtDate(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '-';
  try {
    final dt = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  } catch (_) {
    return dateStr;
  }
}

/// Formatea cadenas ISO o fechas a dd/MM/yyyy HH:mm:ss
String fmtDateTime(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '-';
  try {
    final dt = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
  } catch (_) {
    return dateStr;
  }
}

/// Formatea la cantidad eliminando decimales innecesarios
String qtyLabel(num? qty) {
  if (qty == null) return '1';
  if (qty % 1 == 0) {
    return qty.toInt().toString();
  }
  return qty.toStringAsFixed(2);
}
