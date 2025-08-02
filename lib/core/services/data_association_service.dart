import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import '../constants/app_constants.dart';
import '../../data/models/project.dart';
import '../../data/models/paper.dart';
import '../../data/models/note.dart';
import '../../data/models/meeting.dart';

class DataAssociationService {
  final Isar _isar = GetIt.instance<Isar>();

  /// 根据关键词关联项目、论文、笔记和会议
  Future<Map<String, List<dynamic>>> associateByKeywords(String keywords) async {
    final results = <String, List<dynamic>>{};
    
    try {
      // 搜索项目
      final projects = await _isar.projects
          .filter()
          .nameContains(keywords, caseSensitive: false)
          .or()
          .descriptionContains(keywords, caseSensitive: false)
          .or()
          .tagsContains(keywords, caseSensitive: false)
          .findAll();

      // 搜索论文
      final papers = await _isar.papers
          .filter()
          .titleContains(keywords, caseSensitive: false)
          .or()
          .abstractContains(keywords, caseSensitive: false)
          .or()
          .authorsContains(keywords, caseSensitive: false)
          .or()
          .tagsContains(keywords, caseSensitive: false)
          .findAll();

      // 搜索笔记
      final notes = await _isar.notes
          .filter()
          .titleContains(keywords, caseSensitive: false)
          .or()
          .contentContains(keywords, caseSensitive: false)
          .or()
          .tagsContains(keywords, caseSensitive: false)
          .findAll();

      // 搜索会议
      final meetings = await _isar.meetings
          .filter()
          .titleContains(keywords, caseSensitive: false)
          .or()
          .descriptionContains(keywords, caseSensitive: false)
          .findAll();

      results['projects'] = projects;
      results['papers'] = papers;
      results['notes'] = notes;
      results['meetings'] = meetings;

      return results;
    } catch (e) {
      throw Exception('数据关联查询失败: $e');
    }
  }

  /// 根据时间范围关联数据
  Future<Map<String, List<dynamic>>> associateByTimeRange({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final results = <String, List<dynamic>>{};
    
    try {
      // 获取所有数据，然后在内存中过滤
      final allProjects = await _isar.projects.where().findAll();
      final allPapers = await _isar.papers.where().findAll();
      final allNotes = await _isar.notes.where().findAll();
      final allMeetings = await _isar.meetings.where().findAll();

      // 过滤时间范围内的项目
      final projects = allProjects.where((project) {
        return (project.createdAt != null && 
                project.createdAt!.isAfter(startTime) && 
                project.createdAt!.isBefore(endTime)) ||
               (project.updatedAt != null && 
                project.updatedAt!.isAfter(startTime) && 
                project.updatedAt!.isBefore(endTime));
      }).toList();

      // 过滤时间范围内的论文（暂时跳过，因为Paper模型没有时间字段）
      final papers = <Paper>[];

      // 过滤时间范围内的笔记
      final notes = allNotes.where((note) {
        return (note.createdAt != null && 
                note.createdAt!.isAfter(startTime) && 
                note.createdAt!.isBefore(endTime)) ||
               (note.updatedAt != null && 
                note.updatedAt!.isAfter(startTime) && 
                note.updatedAt!.isBefore(endTime));
      }).toList();

      // 过滤时间范围内的会议
      final meetings = allMeetings.where((meeting) {
        return (meeting.startTime != null && 
                meeting.startTime!.isAfter(startTime) && 
                meeting.startTime!.isBefore(endTime)) ||
               (meeting.createdAt != null && 
                meeting.createdAt!.isAfter(startTime) && 
                meeting.createdAt!.isBefore(endTime));
      }).toList();

      results['projects'] = projects;
      results['papers'] = papers;
      results['notes'] = notes;
      results['meetings'] = meetings;

      return results;
    } catch (e) {
      throw Exception('时间范围关联查询失败: $e');
    }
  }

  /// 根据标签关联数据
  Future<Map<String, List<dynamic>>> associateByTags(List<String> tags) async {
    final results = <String, List<dynamic>>{};
    
    try {
      // 获取所有数据，然后在内存中过滤
      final allProjects = await _isar.projects.where().findAll();
      final allPapers = await _isar.papers.where().findAll();
      final allNotes = await _isar.notes.where().findAll();
      final allMeetings = await _isar.meetings.where().findAll();

      for (final tag in tags) {
        // 搜索包含该标签的项目
        final projects = allProjects.where((project) => 
          project.tags?.contains(tag) == true).toList();

        // 搜索包含该标签的论文
        final papers = allPapers.where((paper) => 
          paper.tags?.contains(tag) == true).toList();

        // 搜索包含该标签的笔记
        final notes = allNotes.where((note) => 
          note.tags?.contains(tag) == true).toList();

        // 搜索包含该标签的会议（暂时跳过，因为Meeting模型没有tags字段）
        final meetings = <Meeting>[];

        results['projects'] = [...(results['projects'] ?? []), ...projects];
        results['papers'] = [...(results['papers'] ?? []), ...papers];
        results['notes'] = [...(results['notes'] ?? []), ...notes];
        results['meetings'] = [...(results['meetings'] ?? []), ...meetings];
      }

      // 去重
      results['projects'] = _removeDuplicates(results['projects'] ?? []);
      results['papers'] = _removeDuplicates(results['papers'] ?? []);
      results['notes'] = _removeDuplicates(results['notes'] ?? []);
      results['meetings'] = _removeDuplicates(results['meetings'] ?? []);

      return results;
    } catch (e) {
      throw Exception('标签关联查询失败: $e');
    }
  }

  /// 智能关联推荐
  Future<Map<String, List<dynamic>>> intelligentAssociation({
    String? projectId,
    String? paperId,
    String? noteId,
    String? meetingId,
  }) async {
    final results = <String, List<dynamic>>{};
    
    try {
      if (projectId != null) {
        final project = await _isar.projects.get(int.parse(projectId));
        if (project != null) {
          // 根据项目名称和描述推荐相关论文
          final relatedPapers = await _findRelatedPapers(project);
          results['papers'] = relatedPapers;

          // 根据项目标签推荐相关笔记
          final relatedNotes = await _findRelatedNotes(project);
          results['notes'] = relatedNotes;

          // 根据项目时间推荐相关会议
          final relatedMeetings = await _findRelatedMeetings(project);
          results['meetings'] = relatedMeetings;
        }
      }

      if (paperId != null) {
        final paper = await _isar.papers.get(int.parse(paperId));
        if (paper != null) {
          // 根据论文内容推荐相关项目
          final relatedProjects = await _findRelatedProjects(paper);
          results['projects'] = relatedProjects;

          // 根据论文主题推荐相关笔记
          final relatedNotes = await _findRelatedNotes(paper);
          results['notes'] = relatedNotes;
        }
      }

      if (noteId != null) {
        final note = await _isar.notes.get(int.parse(noteId));
        if (note != null) {
          // 根据笔记内容推荐相关项目
          final relatedProjects = await _findRelatedProjects(note);
          results['projects'] = relatedProjects;

          // 根据笔记主题推荐相关论文
          final relatedPapers = await _findRelatedPapers(note);
          results['papers'] = relatedPapers;
        }
      }

      if (meetingId != null) {
        final meeting = await _isar.meetings.get(int.parse(meetingId));
        if (meeting != null) {
          // 根据会议主题推荐相关项目
          final relatedProjects = await _findRelatedProjects(meeting);
          results['projects'] = relatedProjects;

          // 根据会议内容推荐相关笔记
          final relatedNotes = await _findRelatedNotes(meeting);
          results['notes'] = relatedNotes;
        }
      }

      return results;
    } catch (e) {
      throw Exception('智能关联推荐失败: $e');
    }
  }

  /// 查找相关论文
  Future<List<Paper>> _findRelatedPapers(dynamic source) async {
    final keywords = _extractKeywords(source);
    final papers = <Paper>[];

          for (final keyword in keywords) {
        final allPapers = await _isar.papers.where().findAll();
        final related = allPapers.where((paper) =>
          paper.title?.contains(keyword) == true ||
          paper.abstract?.contains(keyword) == true ||
          paper.tags?.contains(keyword) == true
        ).toList();
        papers.addAll(related);
      }

    return _removeDuplicates(papers);
  }

  /// 查找相关项目
  Future<List<Project>> _findRelatedProjects(dynamic source) async {
    final keywords = _extractKeywords(source);
    final projects = <Project>[];

    for (final keyword in keywords) {
      final related = await _isar.projects
          .filter()
          .nameContains(keyword, caseSensitive: false)
          .or()
          .descriptionContains(keyword, caseSensitive: false)
          .or()
          .tagsContains(keyword, caseSensitive: false)
          .findAll();
      projects.addAll(related);
    }

    return _removeDuplicates(projects);
  }

  /// 查找相关笔记
  Future<List<Note>> _findRelatedNotes(dynamic source) async {
    final keywords = _extractKeywords(source);
    final notes = <Note>[];

    for (final keyword in keywords) {
      final related = await _isar.notes
          .filter()
          .titleContains(keyword, caseSensitive: false)
          .or()
          .contentContains(keyword, caseSensitive: false)
          .or()
          .tagsContains(keyword, caseSensitive: false)
          .findAll();
      notes.addAll(related);
    }

    return _removeDuplicates(notes);
  }

  /// 查找相关会议
  Future<List<Meeting>> _findRelatedMeetings(dynamic source) async {
    final keywords = _extractKeywords(source);
    final meetings = <Meeting>[];

          for (final keyword in keywords) {
        final allMeetings = await _isar.meetings.where().findAll();
        final related = allMeetings.where((meeting) =>
          meeting.title?.contains(keyword) == true ||
          meeting.description?.contains(keyword) == true
        ).toList();
        meetings.addAll(related);
      }

    return _removeDuplicates(meetings);
  }

  /// 提取关键词
  List<String> _extractKeywords(dynamic source) {
    final keywords = <String>[];
    
    if (source is Project) {
      if (source.name != null) keywords.addAll(_splitIntoKeywords(source.name!));
      if (source.description != null) keywords.addAll(_splitIntoKeywords(source.description!));
      if (source.tags != null) keywords.addAll(_splitIntoKeywords(source.tags!));
    } else if (source is Paper) {
      if (source.title != null) keywords.addAll(_splitIntoKeywords(source.title!));
      if (source.abstract != null) keywords.addAll(_splitIntoKeywords(source.abstract!));
      if (source.tags != null) keywords.addAll(_splitIntoKeywords(source.tags!));
    } else if (source is Note) {
      if (source.title != null) keywords.addAll(_splitIntoKeywords(source.title!));
      if (source.content != null) keywords.addAll(_splitIntoKeywords(source.content!));
      if (source.tags != null) keywords.addAll(_splitIntoKeywords(source.tags!));
    } else if (source is Meeting) {
      if (source.title != null) keywords.addAll(_splitIntoKeywords(source.title!));
      if (source.description != null) keywords.addAll(_splitIntoKeywords(source.description!));
      // Meeting模型暂时没有tags字段
    }

    return keywords.where((keyword) => keyword.length > 2).toSet().toList();
  }

  /// 将文本分割为关键词
  List<String> _splitIntoKeywords(String text) {
    return text
        .split(RegExp(r'[\s,，。！？；：""''（）【】、]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word.trim())
        .toList();
  }

  /// 去重
  List<T> _removeDuplicates<T>(List<T> list) {
    final seen = <int>{};
    return list.where((item) {
      final hashCode = item.hashCode;
      if (seen.contains(hashCode)) {
        return false;
      }
      seen.add(hashCode);
      return true;
    }).toList();
  }

  /// 生成关联报告
  Future<String> generateAssociationReport(Map<String, List<dynamic>> associations) async {
    final report = StringBuffer();
    
    report.writeln('# 数据关联分析报告');
    report.writeln();
    report.writeln('## 关联统计');
    report.writeln();
    report.writeln('- 相关项目：${associations['projects']?.length ?? 0} 个');
    report.writeln('- 相关论文：${associations['papers']?.length ?? 0} 篇');
    report.writeln('- 相关笔记：${associations['notes']?.length ?? 0} 条');
    report.writeln('- 相关会议：${associations['meetings']?.length ?? 0} 个');
    report.writeln();

    if (associations['projects']?.isNotEmpty == true) {
      report.writeln('## 相关项目');
      report.writeln();
      for (final project in associations['projects']!) {
        report.writeln('- ${project.name ?? '未知项目'}');
      }
      report.writeln();
    }

    if (associations['papers']?.isNotEmpty == true) {
      report.writeln('## 相关论文');
      report.writeln();
      for (final paper in associations['papers']!) {
        report.writeln('- ${paper.title ?? '未知论文'}');
      }
      report.writeln();
    }

    if (associations['notes']?.isNotEmpty == true) {
      report.writeln('## 相关笔记');
      report.writeln();
      for (final note in associations['notes']!) {
        report.writeln('- ${note.title ?? '未知笔记'}');
      }
      report.writeln();
    }

    if (associations['meetings']?.isNotEmpty == true) {
      report.writeln('## 相关会议');
      report.writeln();
      for (final meeting in associations['meetings']!) {
        report.writeln('- ${meeting.title ?? '未知会议'}');
      }
      report.writeln();
    }

    return report.toString();
  }
} 