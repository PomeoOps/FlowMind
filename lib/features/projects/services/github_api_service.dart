import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/services/github_auth_service.dart';

// part 'github_api_service.g.dart';

// 简化的GitHub API服务
class GitHubApiService {
  final Dio _dio;
  final String _baseUrl;

  GitHubApiService(this._dio, {required String baseUrl}) : _baseUrl = baseUrl;

  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, dynamic>? queryParams) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$endpoint',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      throw Exception('GitHub API请求失败: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserRepositories({
    String? sort = 'updated',
    int? perPage = 100,
    int? page = 1,
    String? authorization,
  }) async {
    final queryParams = <String, dynamic>{
      'sort': sort,
      'per_page': perPage,
      'page': page,
    };

    final response = await _makeRequest('/user/repos', queryParams);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> getRepository({
    required String owner,
    required String repo,
    String? authorization,
  }) async {
    return await _makeRequest('/repos/$owner/$repo', null);
  }

  Future<List<Map<String, dynamic>>> getRepositoryCommits({
    required String owner,
    required String repo,
    String? sha,
    String? path,
    String? author,
    String? since,
    String? until,
    int? perPage = 30,
    int? page = 1,
    String? authorization,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };
    if (sha != null) queryParams['sha'] = sha;
    if (path != null) queryParams['path'] = path;
    if (author != null) queryParams['author'] = author;
    if (since != null) queryParams['since'] = since;
    if (until != null) queryParams['until'] = until;

    final response = await _makeRequest('/repos/$owner/$repo/commits', queryParams);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> getCommit({
    required String owner,
    required String repo,
    required String sha,
    String? authorization,
  }) async {
    return await _makeRequest('/repos/$owner/$repo/commits/$sha', null);
  }

  Future<Map<String, dynamic>> getRepositoryLanguages({
    required String owner,
    required String repo,
    String? authorization,
  }) async {
    return await _makeRequest('/repos/$owner/$repo/languages', null);
  }

  Future<Map<String, dynamic>> getRepositoryTopics({
    required String owner,
    required String repo,
    String? authorization,
  }) async {
    return await _makeRequest('/repos/$owner/$repo/topics', null);
  }

  Future<Map<String, dynamic>> getCurrentUser({
    String? authorization,
  }) async {
    return await _makeRequest('/user', null);
  }

  Future<List<Map<String, dynamic>>> getUserOrganizations({
    String? authorization,
  }) async {
    final response = await _makeRequest('/user/orgs', null);
    return List<Map<String, dynamic>>.from(response as List);
  }
}

class GitHubService {
  final GitHubApiService _apiService;
  final GitHubAuthService _authService;

  GitHubService(this._authService)
      : _apiService = GitHubApiService(
          Dio(BaseOptions(
            baseUrl: AppConstants.githubApiBaseUrl,
            connectTimeout: AppConstants.connectionTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
          )),
          baseUrl: AppConstants.githubApiBaseUrl,
        );

  /// 获取用户仓库列表
  Future<List<Map<String, dynamic>>> getUserRepositories({
    String? sort = 'updated',
    int? perPage = 100,
    int? page = 1,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final repositories = await _apiService.getUserRepositories(
        sort: sort,
        perPage: perPage,
        page: page,
        authorization: 'Bearer $token',
      );

      return repositories;
    } catch (e) {
      throw Exception('获取用户仓库失败: $e');
    }
  }

  /// 获取仓库详细信息
  Future<Map<String, dynamic>> getRepository({
    required String owner,
    required String repo,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final repository = await _apiService.getRepository(
        owner: owner,
        repo: repo,
        authorization: 'Bearer $token',
      );

      return repository;
    } catch (e) {
      throw Exception('获取仓库信息失败: $e');
    }
  }

  /// 获取仓库提交历史
  Future<List<Map<String, dynamic>>> getRepositoryCommits({
    required String owner,
    required String repo,
    String? sha,
    String? path,
    String? author,
    String? since,
    String? until,
    int? perPage = 30,
    int? page = 1,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final commits = await _apiService.getRepositoryCommits(
        owner: owner,
        repo: repo,
        sha: sha,
        path: path,
        author: author,
        since: since,
        until: until,
        perPage: perPage,
        page: page,
        authorization: 'Bearer $token',
      );

      return commits;
    } catch (e) {
      throw Exception('获取提交历史失败: $e');
    }
  }

  /// 获取提交详细信息
  Future<Map<String, dynamic>> getCommit({
    required String owner,
    required String repo,
    required String sha,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final commit = await _apiService.getCommit(
        owner: owner,
        repo: repo,
        sha: sha,
        authorization: 'Bearer $token',
      );

      return commit;
    } catch (e) {
      throw Exception('获取提交信息失败: $e');
    }
  }

  /// 获取仓库编程语言统计
  Future<Map<String, dynamic>> getRepositoryLanguages({
    required String owner,
    required String repo,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final languages = await _apiService.getRepositoryLanguages(
        owner: owner,
        repo: repo,
        authorization: 'Bearer $token',
      );

      return languages;
    } catch (e) {
      throw Exception('获取语言统计失败: $e');
    }
  }

  /// 获取仓库主题标签
  Future<Map<String, dynamic>> getRepositoryTopics({
    required String owner,
    required String repo,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final topics = await _apiService.getRepositoryTopics(
        owner: owner,
        repo: repo,
        authorization: 'Bearer $token',
      );

      return topics;
    } catch (e) {
      throw Exception('获取主题标签失败: $e');
    }
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final user = await _apiService.getCurrentUser(
        authorization: 'Bearer $token',
      );

      return user;
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  /// 获取用户组织列表
  Future<List<Map<String, dynamic>>> getUserOrganizations() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }

      final organizations = await _apiService.getUserOrganizations(
        authorization: 'Bearer $token',
      );

      return organizations;
    } catch (e) {
      throw Exception('获取组织列表失败: $e');
    }
  }
} 