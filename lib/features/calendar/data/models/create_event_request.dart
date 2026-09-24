/// Exact request body accepted by `POST /calendar`.
///
/// The backend derives `userId` from the authenticated session and always
/// stores custom events with `eventType = CUSTOM`; sending either property is
/// rejected by the global whitelist validation pipe.
class CreateEventRequest {
  const CreateEventRequest({
    required this.title,
    this.description,
    required this.startsAt,
    this.endsAt,
    this.location,
    this.isAllDay,
  });

  final String title;
  final String? description;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? location;
  final bool? isAllDay;

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'startsAt': startsAt.toIso8601String(),
    if (endsAt != null) 'endsAt': endsAt!.toIso8601String(),
    if (location != null) 'location': location,
    if (isAllDay != null) 'isAllDay': isAllDay,
  };
}
