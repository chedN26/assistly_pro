import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a document map's date-like fields between Firestore's
/// native [Timestamp] type and the ISO8601 [String] format every
/// model's `fromMap()`/`toMap()` uses.
///
/// Every model in `lib/models/` is deliberately DB-agnostic — none of
/// them import `cloud_firestore` — so this conversion happens here,
/// in the Firebase repository layer, rather than in the models
/// themselves. Firestore stores dates as [Timestamp] when written via
/// the Admin SDK's `Timestamp.fromDate(...)` (as the seed script
/// does) or the Flutter SDK's equivalent; the models only ever deal
/// in [DateTime]/ISO8601 strings.
class FirestoreDateCodec {
  FirestoreDateCodec._();

  /// Converts [Timestamp] values (as read back from Firestore) in
  /// [dateFields] to ISO8601 strings, so the result can be passed
  /// straight into a model's `fromMap()`.
  static Map<String, dynamic> decode(Map<String, dynamic> map, List<String> dateFields) {
    final Map<String, dynamic> result = Map<String, dynamic>.from(map);
    for (final String field in dateFields) {
      final dynamic value = result[field];
      if (value is Timestamp) {
        result[field] = value.toDate().toIso8601String();
      }
    }
    return result;
  }

  /// Converts ISO8601 string values (as produced by a model's
  /// `toMap()`) in [dateFields] to Firestore [Timestamp]s before
  /// writing.
  static Map<String, dynamic> encode(Map<String, dynamic> map, List<String> dateFields) {
    final Map<String, dynamic> result = Map<String, dynamic>.from(map);
    for (final String field in dateFields) {
      final dynamic value = result[field];
      if (value is String) {
        result[field] = Timestamp.fromDate(DateTime.parse(value));
      }
    }
    return result;
  }
}
