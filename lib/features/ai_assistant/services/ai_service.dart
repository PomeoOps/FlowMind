import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/app_constants.dart';

// part 'ai_service.g.dart';

// 简化的OpenAI API服务
class OpenAIApiService {
  final Dio _dio;
  final String _baseUrl;

  OpenAIApiService(this._dio, {required String baseUrl}) : _baseUrl = baseUrl;

  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, dynamic> body, String authorization) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$endpoint',
        data: body,
        options: Options(
          headers: {'Authorization': authorization},
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('OpenAI API请求失败: $e');
    }
  }

  Future<Map<String, dynamic>> createChatCompletion({
    required Map<String, dynamic> body,
    required String authorization,
  }) async {
    return await _makeRequest('/chat/completions', body, authorization);
  }

  Future<Map<String, dynamic>> createCompletion({
    required Map<String, dynamic> body,
    required String authorization,
  }) async {
    return await _makeRequest('/completions', body, authorization);
  }
}

class AIService {
  final OpenAIApiService _apiService;
  final String _apiKey;

  AIService()
      : _apiKey = AppConstants.openaiApiKey,
        _apiService = OpenAIApiService(
          Dio(BaseOptions(
            baseUrl: AppConstants.openaiApiBaseUrl,
            connectTimeout: AppConstants.connectionTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
          )),
          baseUrl: AppConstants.openaiApiBaseUrl,
        );

  /// 生成论文摘要
  Future<String> generatePaperSummary({
    required String title,
    required String abstract,
    String? authors,
    String? journal,
  }) async {
    try {
      final prompt = '''
请总结这篇论文的核心内容：

标题：$title
作者：${authors ?? '未知'}
期刊：${journal ?? '未知'}
摘要：$abstract

请从以下几个方面进行总结：
1. 研究背景和问题
2. 核心方法和创新点
3. 主要贡献
4. 实验结果
5. 可复现性难点
6. 未来研究方向

请用中文回答，格式要清晰易读。
''';

      final response = await _apiService.createChatCompletion(
        body: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的学术论文分析助手，擅长总结和分析学术论文的核心内容。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        },
        authorization: 'Bearer $_apiKey',
      );

      return response['choices'][0]['message']['content'] ?? '生成摘要失败';
    } catch (e) {
      throw Exception('生成论文摘要失败: $e');
    }
  }

  /// 解释代码
  Future<String> explainCode({
    required String code,
    String? language,
    String? context,
  }) async {
    try {
      final prompt = '''
请解释以下代码的作用，并指出可能的Bug或优化建议：

编程语言：${language ?? '未知'}
代码上下文：${context ?? '无'}
代码：
```${language ?? ''}
$code
```

请从以下几个方面进行分析：
1. 代码功能说明
2. 核心逻辑分析
3. 可能的Bug或问题
4. 性能优化建议
5. 代码改进建议

请用中文回答，格式要清晰易读。
''';

      final response = await _apiService.createChatCompletion(
        body: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的代码分析助手，擅长解释代码逻辑、发现潜在问题并提供优化建议。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.2,
          'max_tokens': 1500,
        },
        authorization: 'Bearer $_apiKey',
      );

      return response['choices'][0]['message']['content'] ?? '代码解释失败';
    } catch (e) {
      throw Exception('代码解释失败: $e');
    }
  }

  /// 生成项目进展总结
  Future<String> generateProjectSummary({
    required List<Map<String, dynamic>> commits,
    required List<Map<String, dynamic>> notes,
    String? projectName,
  }) async {
    try {
      final commitSummary = commits.take(10).map((commit) {
        return '- ${commit['commit']?['message'] ?? '未知提交'} (${commit['commit']?['author']?['date'] ?? '未知时间'})';
      }).join('\n');

      final noteSummary = notes.take(5).map((note) {
        return '- ${note['title'] ?? '未知笔记'} (${note['updatedAt'] ?? '未知时间'})';
      }).join('\n');

      final prompt = '''
请根据最近一周的项目活动生成进展摘要：

项目名称：${projectName ?? '未知项目'}

最近提交记录：
$commitSummary

最近笔记更新：
$noteSummary

请从以下几个方面进行总结：
1. 主要开发进展
2. 关键功能实现
3. 遇到的问题和解决方案
4. 下一步计划
5. 需要关注的风险点

请用中文回答，格式要清晰易读，适合向团队汇报。
''';

      final response = await _apiService.createChatCompletion(
        body: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的项目管理助手，擅长分析项目进展并生成清晰的总结报告。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1200,
        },
        authorization: 'Bearer $_apiKey',
      );

      return response['choices'][0]['message']['content'] ?? '生成项目总结失败';
    } catch (e) {
      throw Exception('生成项目总结失败: $e');
    }
  }

  /// 生成会议纪要
  Future<String> generateMeetingMinutes({
    required String transcript,
    String? meetingTitle,
    List<String>? participants,
  }) async {
    try {
      final participantsList = participants?.join('、') ?? '未知参与者';

      final prompt = '''
请根据以下会议录音转写内容生成会议纪要：

会议标题：${meetingTitle ?? '未知会议'}
参与者：$participantsList

会议内容：
$transcript

请从以下几个方面生成会议纪要：
1. 会议主题和议程
2. 主要讨论内容
3. 重要决策和结论
4. 下一步任务和负责人
5. 时间节点和里程碑
6. 需要跟进的事项

请用中文回答，格式要清晰易读，适合作为正式会议纪要。
''';

      final response = await _apiService.createChatCompletion(
        body: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的会议纪要助手，擅长从会议录音转写中提取关键信息并生成结构化的会议纪要。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.2,
          'max_tokens': 2000,
        },
        authorization: 'Bearer $_apiKey',
      );

      return response['choices'][0]['message']['content'] ?? '生成会议纪要失败';
    } catch (e) {
      throw Exception('生成会议纪要失败: $e');
    }
  }

  /// 扩展笔记内容
  Future<String> expandNote({
    required String noteContent,
    String? noteTitle,
    String? context,
  }) async {
    try {
      final prompt = '''
请将以下笔记扩展为结构化的研究记录：

笔记标题：${noteTitle ?? '未知笔记'}
笔记内容：$noteContent
相关上下文：${context ?? '无'}

请从以下几个方面进行扩展：
1. 背景信息补充
2. 相关概念解释
3. 研究方法和步骤
4. 数据分析和结果
5. 结论和启示
6. 后续研究建议
7. 相关参考资料
8. TODO清单

请用中文回答，格式要清晰易读，适合作为正式的研究记录。
''';

      final response = await _apiService.createChatCompletion(
        body: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的研究记录助手，擅长将简单的笔记扩展为结构化的研究记录。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.3,
          'max_tokens': 2000,
        },
        authorization: 'Bearer $_apiKey',
      );

      return response['choices'][0]['message']['content'] ?? '扩展笔记失败';
    } catch (e) {
      throw Exception('扩展笔记失败: $e');
    }
  }

  /// 语音转文字
  Future<String> transcribeAudio({
    required String audioFilePath,
  }) async {
    try {
      // TODO: 实现语音转文字功能
      // 由于FormData类型问题，暂时返回占位符
      return '语音转文字功能开发中...';
    } catch (e) {
      throw Exception('语音转文字失败: $e');
    }
  }

  /// 通用对话
  Future<String> chat({
    required String message,
    String? context,
    String? role,
  }) async {
    try {
      final systemPrompt = role != null 
        ? '你是一个$role，请根据用户的问题提供专业的回答。'
        : '你是一个智能助手，请根据用户的问题提供有帮助的回答。';

      final userPrompt = context != null 
        ? '上下文：$context\n\n用户问题：$message'
        : message;

      final response = await _apiService.createChatCompletion(
        body: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': userPrompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
        authorization: 'Bearer $_apiKey',
      );

      return response['choices'][0]['message']['content'] ?? '对话失败';
    } catch (e) {
      throw Exception('对话失败: $e');
    }
  }
} 