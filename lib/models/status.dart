/// Shared Active/Inactive status used by both [Employee] and [Client]
/// (DDD Sections 4 & 6). Modeled as an enum for compile-time safety
/// instead of raw strings throughout the app; [label]/[fromString]
/// handle conversion to/from the Firestore-facing String value
/// ("Active" / "Inactive") at the model serialization boundary.
enum Status { active, inactive }

extension StatusX on Status {
  String get label {
    switch (this) {
      case Status.active:
        return 'Active';
      case Status.inactive:
        return 'Inactive';
    }
  }

  static Status fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return Status.active;
      case 'inactive':
        return Status.inactive;
      default:
        throw ArgumentError('Unknown status value: $value');
    }
  }
}
