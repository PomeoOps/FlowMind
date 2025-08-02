import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/note.dart';

// part 'siyuan_service.g.dart';

// 简化的思源笔记API服务
class SiyuanApiService {
  final Dio _dio;
  final String _baseUrl;
  final String _token;

  SiyuanApiService(this._dio, {required String baseUrl, required String token})
      : _baseUrl = baseUrl,
        _token = token;

  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, dynamic>? body) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$endpoint',
        data: body,
        options: Options(
          headers: {'Authorization': 'Token $_token'},
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('API请求失败: $e');
    }
  }

  Future<Map<String, dynamic>> getNotebooks() async {
    return await _makeRequest('/api/notebook/lsNotebooks', null);
  }

  Future<Map<String, dynamic>> getDocument(Map<String, dynamic> body) async {
    return await _makeRequest('/api/filetree/getDoc', body);
  }

  Future<Map<String, dynamic>> getHPathByPath(Map<String, dynamic> body) async {
    return await _makeRequest('/api/filetree/getHPathByPath', body);
  }

  Future<Map<String, dynamic>> getIDsByHPath(Map<String, dynamic> body) async {
    return await _makeRequest('/api/filetree/getIDsByHPath', body);
  }

  Future<Map<String, dynamic>> getChildBlocks(Map<String, dynamic> body) async {
    return await _makeRequest('/api/block/getChildBlocks', body);
  }

  Future<Map<String, dynamic>> appendBlock(Map<String, dynamic> body) async {
    return await _makeRequest('/api/block/appendBlock', body);
  }

  Future<Map<String, dynamic>> updateBlock(Map<String, dynamic> body) async {
    return await _makeRequest('/api/block/updateBlock', body);
  }

  Future<Map<String, dynamic>> deleteBlock(Map<String, dynamic> body) async {
    return await _makeRequest('/api/block/deleteBlock', body);
  }

  Future<Map<String, dynamic>> searchBlocks(Map<String, dynamic> body) async {
    return await _makeRequest('/api/search/searchBlock', body);
  }

  Future<Map<String, dynamic>> setBlockAttrs(Map<String, dynamic> body) async {
    return await _makeRequest('/api/attr/setBlockAttrs', body);
  }

  Future<Map<String, dynamic>> getBlockAttrs(Map<String, dynamic> body) async {
    return await _makeRequest('/api/attr/getBlockAttrs', body);
  }
}

class SiyuanService {
  final SiyuanApiService _apiService;
  final String _token;

  SiyuanService()
      : _token = AppConstants.siyuanToken,
        _apiService = SiyuanApiService(
          Dio(BaseOptions(
            baseUrl: AppConstants.siyuanApiBaseUrl,
            connectTimeout: AppConstants.connectionTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
          )),
          baseUrl: AppConstants.siyuanApiBaseUrl,
          token: AppConstants.siyuanToken,
        );

  /// 获取所有笔记本
  Future<List<Map<String, dynamic>>> getNotebooks() async {
    try {
      final response = await _apiService.getNotebooks();

      if (response['code'] == 0) {
        return List<Map<String, dynamic>>.from(response['data']['notebooks'] ?? []);
      }

      throw Exception('获取笔记本失败: ${response['msg']}');
    } catch (e) {
      throw Exception('获取笔记本失败: $e');
    }
  }

  /// 获取文档内容
  Future<Map<String, dynamic>> getDocument({
    required String id,
  }) async {
    try {
      final response = await _apiService.getDocument({'id': id});

      if (response['code'] == 0) {
        return response['data'] ?? {};
      }

      throw Exception('获取文档失败: ${response['msg']}');
    } catch (e) {
      throw Exception('获取文档失败: $e');
    }
  }

  /// 根据路径获取文档ID
  Future<String?> getDocumentIdByPath({
    required String path,
  }) async {
    try {
      final hpathResponse = await _apiService.getHPathByPath({'path': path});

      if (hpathResponse['code'] != 0) {
        throw Exception('获取路径失败: ${hpathResponse['msg']}');
      }

      final hpath = hpathResponse['data'];
      final idsResponse = await _apiService.getIDsByHPath({'path': hpath});

      if (idsResponse['code'] == 0) {
        final ids = List<String>.from(idsResponse['data'] ?? []);
        return ids.isNotEmpty ? ids.first : null;
      }

      throw Exception('获取文档ID失败: ${idsResponse['msg']}');
    } catch (e) {
      throw Exception('获取文档ID失败: $e');
    }
  }

  /// 获取子块
  Future<List<Map<String, dynamic>>> getChildBlocks({
    required String id,
  }) async {
    try {
      final response = await _apiService.getChildBlocks({'id': id});

      if (response['code'] == 0) {
        return List<Map<String, dynamic>>.from(response['data'] ?? []);
      }

      throw Exception('获取子块失败: ${response['msg']}');
    } catch (e) {
      throw Exception('获取子块失败: $e');
    }
  }

  /// 添加块
  Future<String?> appendBlock({
    required String dataType,
    required String data,
    String? parentID,
  }) async {
    try {
      final response = await _apiService.appendBlock({
        'dataType': dataType,
        'data': data,
        if (parentID != null) 'parentID': parentID,
      });

      if (response['code'] == 0) {
        return response['data'];
      }

      throw Exception('添加块失败: ${response['msg']}');
    } catch (e) {
      throw Exception('添加块失败: $e');
    }
  }

  /// 更新块
  Future<bool> updateBlock({
    required String id,
    required String dataType,
    required String data,
  }) async {
    try {
      final response = await _apiService.updateBlock({
        'id': id,
        'dataType': dataType,
        'data': data,
      });

      if (response['code'] == 0) {
        return true;
      }

      throw Exception('更新块失败: ${response['msg']}');
    } catch (e) {
      throw Exception('更新块失败: $e');
    }
  }

  /// 删除块
  Future<bool> deleteBlock({
    required String id,
  }) async {
    try {
      final response = await _apiService.deleteBlock({'id': id});

      if (response['code'] == 0) {
        return true;
      }

      throw Exception('删除块失败: ${response['msg']}');
    } catch (e) {
      throw Exception('删除块失败: $e');
    }
  }

  /// 搜索块
  Future<List<Map<String, dynamic>>> searchBlocks({
    required String query,
    String? notebook,
    int? page = 1,
    int? size = 20,
  }) async {
    try {
      final response = await _apiService.searchBlocks({
        'query': query,
        if (notebook != null) 'notebook': notebook,
        'page': page,
        'size': size,
      });

      if (response['code'] == 0) {
        return List<Map<String, dynamic>>.from(response['data']['blocks'] ?? []);
      }

      throw Exception('搜索块失败: ${response['msg']}');
    } catch (e) {
      throw Exception('搜索块失败: $e');
    }
  }

  /// 设置块属性
  Future<bool> setBlockAttrs({
    required String id,
    required Map<String, dynamic> attrs,
  }) async {
    try {
      final response = await _apiService.setBlockAttrs({
        'id': id,
        'attrs': attrs,
      });

      if (response['code'] == 0) {
        return true;
      }

      throw Exception('设置块属性失败: ${response['msg']}');
    } catch (e) {
      throw Exception('设置块属性失败: $e');
    }
  }

  /// 获取块属性
  Future<Map<String, dynamic>> getBlockAttrs({
    required String id,
  }) async {
    try {
      final response = await _apiService.getBlockAttrs({'id': id});

      if (response['code'] == 0) {
        return response['data'] ?? {};
      }

      throw Exception('获取块属性失败: ${response['msg']}');
    } catch (e) {
      throw Exception('获取块属性失败: $e');
    }
  }

  /// 将思源笔记数据转换为Note模型
  Note convertToNote(Map<String, dynamic> siyuanBlock) {
    return Note(
      siyuanId: siyuanBlock['id'],
      title: siyuanBlock['content']?.toString().substring(0, 50),
      content: siyuanBlock['content'],
      type: siyuanBlock['type'],
      createdAt: siyuanBlock['created'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(siyuanBlock['created'])
        : null,
      updatedAt: siyuanBlock['updated'] != null
        ? DateTime.fromMillisecondsSinceEpoch(siyuanBlock['updated'])
        : null,
      tags: siyuanBlock['attrs']?['custom-tags']?.toString(),
      parentId: siyuanBlock['parentID'],
    );
  }

  /// 同步所有笔记到本地数据库
  Future<List<Note>> syncAllNotes() async {
    try {
      final notebooks = await getNotebooks();
      final allNotes = <Note>[];

      for (final notebook in notebooks) {
        final notebookId = notebook['id'];
        final notes = await searchBlocks(
          query: '',
          notebook: notebookId,
          size: 1000,
        );

        final convertedNotes = notes
            .where((block) => block['type'] == 'd')
            .map((block) => convertToNote(block))
            .toList();

        allNotes.addAll(convertedNotes);
      }

      return allNotes;
    } catch (e) {
      throw Exception('同步笔记失败: $e');
    }
  }

  /// 搜索笔记
  Future<List<Note>> searchNotes({
    required String query,
    String? notebook,
  }) async {
    try {
      final blocks = await searchBlocks(
        query: query,
        notebook: notebook,
        size: 100,
      );

      final notes = blocks
          .where((block) => block['type'] == 'd')
          .map((block) => convertToNote(block))
          .toList();

      return notes;
    } catch (e) {
      throw Exception('搜索笔记失败: $e');
    }
  }

  /// 创建新笔记
  Future<Note?> createNote({
    required String title,
    required String content,
    String? parentId,
    String? tags,
  }) async {
    try {
      final blockId = await appendBlock(
        dataType: 'markdown',
        data: '# $title\n\n$content',
        parentID: parentId,
      );

      if (blockId != null) {
        // 设置标签
        if (tags != null) {
          await setBlockAttrs(
            id: blockId,
            attrs: {'custom-tags': tags},
          );
        }

        // 获取创建的笔记
        final document = await getDocument(id: blockId);
        return convertToNote(document);
      }

      return null;
    } catch (e) {
      throw Exception('创建笔记失败: $e');
    }
  }

  /// 更新笔记
  Future<bool> updateNote({
    required String id,
    String? title,
    String? content,
    String? tags,
  }) async {
    try {
      final document = await getDocument(id: id);
      final currentContent = document['content'] ?? '';

      String newContent = currentContent;
      if (title != null || content != null) {
        final lines = currentContent.split('\n');
        if (title != null && lines.isNotEmpty) {
          lines[0] = '# $title';
        }
        if (content != null) {
          if (lines.length > 1) {
            lines[1] = content;
          } else {
            lines.add(content);
          }
        }
        newContent = lines.join('\n');
      }

      final success = await updateBlock(
        id: id,
        dataType: 'markdown',
        data: newContent,
      );

      if (success && tags != null) {
        await setBlockAttrs(
          id: id,
          attrs: {'custom-tags': tags},
        );
      }

      return success;
    } catch (e) {
      throw Exception('更新笔记失败: $e');
    }
  }
} 