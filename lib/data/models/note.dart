import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@collection
@JsonSerializable()
class Note {
  Id id = Isar.autoIncrement;

  @Index()
  String? siyuanId;

  @Index()
  String? title;

  String? content;
  String? path;
  String? type; // document, folder, etc.
  DateTime? createdAt;
  DateTime? updatedAt;
  String? tags;
  String? relatedProjects;
  String? relatedPapers;
  String? parentId;
  bool? isBookmarked;
  String? summary;
  String? aiGeneratedContent;
  DateTime? lastSyncAt;

  Note({
    this.siyuanId,
    this.title,
    this.content,
    this.path,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.relatedProjects,
    this.relatedPapers,
    this.parentId,
    this.isBookmarked,
    this.summary,
    this.aiGeneratedContent,
    this.lastSyncAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);

  @override
  String toString() {
    return 'Note{id: $id, title: $title, siyuanId: $siyuanId}';
  }
} 