import '../../../../core/network/api_result.dart';
import '../../data/models/meeting_requests.dart';
import '../entities/client_meeting.dart';

abstract class IMeetingRepository {
  ApiResult<List<ClientMeeting>> getMeetings();
  ApiResult<ClientMeeting> create(CreateMeetingRequest request);
  ApiResult<ClientMeeting> update(String id, UpdateMeetingRequest request);
  ApiResult<ClientMeeting> complete(String id, String outcomeNotes);
  ApiResult<void> cancel(String id);
}
