import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paper.g.dart';

@collection
@JsonSerializable()
class Paper {
  Id id = Isar.autoIncrement;

  @Index()
  String? zoteroKey;

  @Index()
  String? title;

  String? abstract;
  String? authors;
  String? journal;
  String? year;
  String? doi;
  String? url;
  String? pdfPath;
  String? tags;
  String? notes;
  DateTime? addedAt;
  DateTime? modifiedAt;
  String? itemType; // journalArticle, conferencePaper, book, etc.
  String? publisher;
  String? volume;
  String? issue;
  String? pages;
  String? isbn;
  String? issn;
  String? language;
  String? keywords;
  String? citationKey;
  bool? isRead;
  DateTime? readAt;
  String? summary;
  String? relatedProjects;

  Paper({
    this.zoteroKey,
    this.title,
    this.abstract,
    this.authors,
    this.journal,
    this.year,
    this.doi,
    this.url,
    this.pdfPath,
    this.tags,
    this.notes,
    this.addedAt,
    this.modifiedAt,
    this.itemType,
    this.publisher,
    this.volume,
    this.issue,
    this.pages,
    this.isbn,
    this.issn,
    this.language,
    this.keywords,
    this.citationKey,
    this.isRead,
    this.readAt,
    this.summary,
    this.relatedProjects,
  });

  factory Paper.fromJson(Map<String, dynamic> json) => _$PaperFromJson(json);
  Map<String, dynamic> toJson() => _$PaperToJson(this);

  @override
  String toString() {
    return 'Paper{id: $id, title: $title, authors: $authors, year: $year}';
  }
} 