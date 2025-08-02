import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting.g.dart';

@collection
@JsonSerializable()
class Meeting {
  Id id = Isar.autoIncrement;

  @Index()
  String? meetingId;

  @Index()
  String? title;

  String? description;
  DateTime? startTime;
  DateTime? endTime;
  String? host;
  List<String>? participants;
  String? meetingUrl;
  String? platform; // tencent, zoom, teams, etc.
  String? status; // scheduled, ongoing, completed, cancelled
  String? recordingUrl;
  String? transcript;
  String? summary;
  String? actionItems;
  String? relatedProjects;
  String? notes;
  bool? isReminderSet;
  DateTime? reminderTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  Meeting({
    this.meetingId,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.host,
    this.participants,
    this.meetingUrl,
    this.platform,
    this.status,
    this.recordingUrl,
    this.transcript,
    this.summary,
    this.actionItems,
    this.relatedProjects,
    this.notes,
    this.isReminderSet,
    this.reminderTime,
    this.createdAt,
    this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingToJson(this);

  @override
  String toString() {
    return 'Meeting{id: $id, title: $title, startTime: $startTime, platform: $platform}';
  }
} 