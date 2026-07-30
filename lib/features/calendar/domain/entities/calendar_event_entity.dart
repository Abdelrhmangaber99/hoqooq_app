import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../authentication/domain/entities/user.dart';
import 'calendar_event_type.dart';

part 'calendar_event_entity.freezed.dart';
part 'calendar_event_entity.g.dart';

/// Wire shape for `GET/PATCH /calendar` per API_CONTRACT.md finding I.
///
/// Named `CalendarEventEntity`, not `CalendarEvent` — that name is already
/// taken by this feature's bloc event base class. Replaces the mock
/// `Appointment` model entirely (it conflated hearing+meeting+client-name
/// into one flat shape matching nothing real). `CalendarController` never
/// applies `plainToInstance` — the real response is the raw entity as
/// loaded by `CalendarService.findAll`'s `relations: ['user']`, so `user`
/// is nested here. `referenceId` stays a plain opaque string by the
/// endpoint's own design (a generic polymorphic link to a Case/Hearing/Task
/// — never itself a relation).
@freezed
abstract class CalendarEventEntity with _$CalendarEventEntity {
  const factory CalendarEventEntity({
    required String id,
    required String tenantId,
    required String userId,
    User? user,
    required String title,
    String? description,
    @JsonKey(unknownEnumValue: CalendarEventType.unknown)
    required CalendarEventType eventType,
    String? referenceId,
    required DateTime startsAt,
    DateTime? endsAt,
    String? location,
    required bool isAllDay,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarEventEntity;

  factory CalendarEventEntity.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventEntityFromJson(json);
}
