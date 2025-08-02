import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/paper.dart';

// // part 'zotero_service.g.dart';

// 简化的Zotero API服务
class ZoteroApiService {
  final Dio _dio;
  final String _baseUrl;

  ZoteroApiService(this._dio, {required String baseUrl}) : _baseUrl = baseUrl;

  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, dynamic>? queryParams) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$endpoint',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      throw Exception('Zotero API请求失败: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserItems({
    required String userId,
    String? format = 'json',
    String? itemType,
    String? query,
    String? tag,
    String? collection,
    int? limit = 100,
    int? start = 0,
    String? apiKey,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
      'limit': limit,
      'start': start,
    };
    if (itemType != null) queryParams['itemType'] = itemType;
    if (query != null) queryParams['q'] = query;
    if (tag != null) queryParams['tag'] = tag;
    if (collection != null) queryParams['collection'] = collection;

    final response = await _makeRequest('/users/$userId/items', queryParams);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> getItem({
    required String userId,
    required String itemKey,
    String? format = 'json',
    String? apiKey,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
    };
    return await _makeRequest('/users/$userId/items/$itemKey', queryParams);
  }

  Future<List<Map<String, dynamic>>> getUserCollections({
    required String userId,
    String? format = 'json',
    String? apiKey,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
    };
    final response = await _makeRequest('/users/$userId/collections', queryParams);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<List<Map<String, dynamic>>> getCollectionItems({
    required String userId,
    required String collectionKey,
    String? format = 'json',
    String? itemType,
    int? limit = 100,
    int? start = 0,
    String? apiKey,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
      'limit': limit,
      'start': start,
    };
    if (itemType != null) queryParams['itemType'] = itemType;
    final response = await _makeRequest('/users/$userId/collections/$collectionKey/items', queryParams);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<List<Map<String, dynamic>>> getItemChildren({
    required String userId,
    required String itemKey,
    String? format = 'json',
    String? apiKey,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
    };
    final response = await _makeRequest('/users/$userId/items/$itemKey/children', queryParams);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> getItemFile({
    required String userId,
    required String itemKey,
    String? format = 'json',
    String? apiKey,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
    };
    return await _makeRequest('/users/$userId/items/$itemKey/file', queryParams);
  }
}

class ZoteroService {
  final ZoteroApiService _apiService;
  final String _apiKey;
  final String _userId;

  ZoteroService()
      : _apiKey = AppConstants.zoteroApiKey,
        _userId = AppConstants.zoteroUserId,
        _apiService = ZoteroApiService(
          Dio(BaseOptions(
            baseUrl: AppConstants.zoteroApiBaseUrl,
            connectTimeout: AppConstants.connectionTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
          )),
          baseUrl: AppConstants.zoteroApiBaseUrl,
        );

  /// 获取用户所有论文
  Future<List<Map<String, dynamic>>> getUserItems({
    String? itemType,
    String? query,
    String? tag,
    String? collection,
    int? limit = 100,
    int? start = 0,
  }) async {
    try {
      final items = await _apiService.getUserItems(
        userId: _userId,
        itemType: itemType,
        query: query,
        tag: tag,
        collection: collection,
        limit: limit,
        start: start,
        apiKey: _apiKey,
      );

      return items;
    } catch (e) {
      throw Exception('获取Zotero论文失败: $e');
    }
  }

  /// 获取论文详细信息
  Future<Map<String, dynamic>> getItem({
    required String itemKey,
  }) async {
    try {
      final item = await _apiService.getItem(
        userId: _userId,
        itemKey: itemKey,
        apiKey: _apiKey,
      );

      return item;
    } catch (e) {
      throw Exception('获取论文详情失败: $e');
    }
  }

  /// 获取用户收藏夹
  Future<List<Map<String, dynamic>>> getUserCollections() async {
    try {
      final collections = await _apiService.getUserCollections(
        userId: _userId,
        apiKey: _apiKey,
      );

      return collections;
    } catch (e) {
      throw Exception('获取收藏夹失败: $e');
    }
  }

  /// 获取收藏夹中的论文
  Future<List<Map<String, dynamic>>> getCollectionItems({
    required String collectionKey,
    String? itemType,
    int? limit = 100,
    int? start = 0,
  }) async {
    try {
      final items = await _apiService.getCollectionItems(
        userId: _userId,
        collectionKey: collectionKey,
        itemType: itemType,
        limit: limit,
        start: start,
        apiKey: _apiKey,
      );

      return items;
    } catch (e) {
      throw Exception('获取收藏夹论文失败: $e');
    }
  }

  /// 获取论文附件
  Future<List<Map<String, dynamic>>> getItemChildren({
    required String itemKey,
  }) async {
    try {
      final children = await _apiService.getItemChildren(
        userId: _userId,
        itemKey: itemKey,
        apiKey: _apiKey,
      );

      return children;
    } catch (e) {
      throw Exception('获取论文附件失败: $e');
    }
  }

  /// 获取论文文件信息
  Future<Map<String, dynamic>> getItemFile({
    required String itemKey,
  }) async {
    try {
      final file = await _apiService.getItemFile(
        userId: _userId,
        itemKey: itemKey,
        apiKey: _apiKey,
      );

      return file;
    } catch (e) {
      throw Exception('获取论文文件失败: $e');
    }
  }

  /// 将Zotero数据转换为Paper模型
  Paper convertToPaper(Map<String, dynamic> zoteroItem) {
    final data = zoteroItem['data'] ?? {};
    final meta = zoteroItem['meta'] ?? {};

    return Paper(
      zoteroKey: zoteroItem['key'],
      title: data['title'],
      abstract: data['abstractNote'],
      authors: _extractAuthors(data['creators']),
      journal: data['publicationTitle'],
      year: data['date']?.toString().substring(0, 4),
      doi: data['DOI'],
      url: data['url'],
      itemType: data['itemType'],
      publisher: data['publisher'],
      volume: data['volume'],
      issue: data['issue'],
      pages: data['pages'],
      isbn: data['ISBN'],
      issn: data['ISSN'],
      language: data['language'],
      keywords: data['tags']?.map((tag) => tag['tag']).join(', '),
      citationKey: data['citationKey'],
      addedAt: meta['dateAdded'] != null 
        ? DateTime.parse(meta['dateAdded'])
        : null,
      modifiedAt: meta['lastModified'] != null
        ? DateTime.parse(meta['lastModified'])
        : null,
    );
  }

  /// 提取作者信息
  String _extractAuthors(List<dynamic>? creators) {
    if (creators == null || creators.isEmpty) return '';
    
    final authors = creators
        .where((creator) => creator['creatorType'] == 'author')
        .map((creator) => '${creator['firstName'] ?? ''} ${creator['lastName'] ?? ''}'.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    
    return authors.join(', ');
  }

  /// 同步所有论文到本地数据库
  Future<List<Paper>> syncAllPapers() async {
    try {
      final items = await getUserItems(
        itemType: 'journalArticle',
        limit: 1000,
      );

      final papers = items
          .where((item) => item['data']?['itemType'] == 'journalArticle')
          .map((item) => convertToPaper(item))
          .toList();

      return papers;
    } catch (e) {
      throw Exception('同步论文失败: $e');
    }
  }

  /// 搜索论文
  Future<List<Paper>> searchPapers({
    required String query,
    String? itemType,
    String? tag,
    String? collection,
  }) async {
    try {
      final items = await getUserItems(
        query: query,
        itemType: itemType,
        tag: tag,
        collection: collection,
        limit: 100,
      );

      final papers = items
          .where((item) => item['data']?['itemType'] == 'journalArticle')
          .map((item) => convertToPaper(item))
          .toList();

      return papers;
    } catch (e) {
      throw Exception('搜索论文失败: $e');
    }
  }
} 