import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@collection
@JsonSerializable()
class Project {
  Id id = Isar.autoIncrement;

  @Index()
  String? githubId;

  @Index()
  String? name;

  String? description;
  String? fullName;
  String? htmlUrl;
  String? cloneUrl;
  String? language;
  int? stars;
  int? forks;
  int? openIssues;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? pushedAt;
  String? defaultBranch;
  bool? isPrivate;
  bool? isFork;
  String? homepage;
  String? topics;
  String? license;
  String? owner;
  String? avatarUrl;
  String? localPath;
  DateTime? lastSyncAt;
  String? status; // active, archived, deleted
  String? tags;
  String? notes;
  DateTime? lastActivityAt;

  Project({
    this.githubId,
    this.name,
    this.description,
    this.fullName,
    this.htmlUrl,
    this.cloneUrl,
    this.language,
    this.stars,
    this.forks,
    this.openIssues,
    this.createdAt,
    this.updatedAt,
    this.pushedAt,
    this.defaultBranch,
    this.isPrivate,
    this.isFork,
    this.homepage,
    this.topics,
    this.license,
    this.owner,
    this.avatarUrl,
    this.localPath,
    this.lastSyncAt,
    this.status,
    this.tags,
    this.notes,
    this.lastActivityAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  @override
  String toString() {
    return 'Project{id: $id, name: $name, githubId: $githubId, language: $language, stars: $stars}';
  }
} 