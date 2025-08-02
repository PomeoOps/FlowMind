import 'package:url_launcher/url_launcher.dart';
// import 'package:regex/regex.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/meeting.dart';

class TencentMeetingService {
  static final RegExp _meetingUrlRegex = RegExp(
    r'https?://meeting\.tencent\.com/[a-zA-Z0-9]+',
    caseSensitive: false,
  );

  static final RegExp _meetingIdRegex = RegExp(
    r'(\d{9,11})',
    caseSensitive: false,
  );

  /// 检测文本中的腾讯会议链接
  static List<String> extractMeetingUrls(String text) {
    final matches = _meetingUrlRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  /// 检测文本中的会议ID
  static List<String> extractMeetingIds(String text) {
    final matches = _meetingIdRegex.allMatches(text);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// 生成腾讯会议链接
  static String generateMeetingUrl(String meetingId) {
    return 'https://meeting.tencent.com/$meetingId';
  }

  /// 打开腾讯会议链接
  static Future<bool> openMeeting(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      throw Exception('打开会议链接失败: $e');
    }
  }

  /// 打开会议ID对应的链接
  static Future<bool> openMeetingById(String meetingId) async {
    final url = generateMeetingUrl(meetingId);
    return await openMeeting(url);
  }

  /// 解析会议信息
  static MeetingInfo? parseMeetingInfo(String text) {
    // 尝试从URL中提取信息
    final urls = extractMeetingUrls(text);
    if (urls.isNotEmpty) {
      final url = urls.first;
      final meetingId = _extractMeetingIdFromUrl(url);
      if (meetingId != null) {
        return MeetingInfo(
          meetingId: meetingId,
          url: url,
          title: _extractTitleFromText(text),
        );
      }
    }

    // 尝试从文本中提取会议ID
    final ids = extractMeetingIds(text);
    if (ids.isNotEmpty) {
      final meetingId = ids.first;
      return MeetingInfo(
        meetingId: meetingId,
        url: generateMeetingUrl(meetingId),
        title: _extractTitleFromText(text),
      );
    }

    return null;
  }

  /// 从URL中提取会议ID
  static String? _extractMeetingIdFromUrl(String url) {
    final match = _meetingIdRegex.firstMatch(url);
    return match?.group(1);
  }

  /// 从文本中提取标题
  static String _extractTitleFromText(String text) {
    // 简单的标题提取逻辑
    final lines = text.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isNotEmpty && 
          !trimmedLine.startsWith('http') && 
          !_meetingIdRegex.hasMatch(trimmedLine)) {
        return trimmedLine;
      }
    }
    return '腾讯会议';
  }

  /// 验证会议ID格式
  static bool isValidMeetingId(String meetingId) {
    return _meetingIdRegex.hasMatch(meetingId) && meetingId.length >= 9;
  }

  /// 验证会议URL格式
  static bool isValidMeetingUrl(String url) {
    return _meetingUrlRegex.hasMatch(url);
  }

  /// 创建会议记录
  static Meeting createMeetingFromInfo(MeetingInfo info) {
    return Meeting(
      meetingId: info.meetingId,
      title: info.title,
      meetingUrl: info.url,
      platform: 'tencent',
      status: 'scheduled',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 获取会议状态
  static String getMeetingStatus(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) return 'scheduled';
    
    final now = DateTime.now();
    if (endTime != null && now.isAfter(endTime)) {
      return 'completed';
    } else if (now.isAfter(startTime)) {
      return 'ongoing';
    } else {
      return 'scheduled';
    }
  }

  /// 格式化会议时间
  static String formatMeetingTime(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) return '时间未定';
    
    final startStr = '${startTime.month}/${startTime.day} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    
    if (endTime != null) {
      final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      return '$startStr - $endStr';
    }
    
    return startStr;
  }

  /// 检查会议是否即将开始
  static bool isMeetingStartingSoon(DateTime? startTime, {Duration threshold = const Duration(minutes: 15)}) {
    if (startTime == null) return false;
    
    final now = DateTime.now();
    final timeUntilStart = startTime.difference(now);
    
    return timeUntilStart.isNegative == false && timeUntilStart <= threshold;
  }

  /// 获取会议提醒时间
  static DateTime? getReminderTime(DateTime? startTime, {Duration reminderOffset = const Duration(minutes: 15)}) {
    if (startTime == null) return null;
    
    return startTime.subtract(reminderOffset);
  }
}

class MeetingInfo {
  final String meetingId;
  final String url;
  final String title;

  MeetingInfo({
    required this.meetingId,
    required this.url,
    required this.title,
  });

  @override
  String toString() {
    return 'MeetingInfo{meetingId: $meetingId, url: $url, title: $title}';
  }
} 