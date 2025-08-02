import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';

class GitHubAuthService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'github_access_token';
  static const String _refreshTokenKey = 'github_refresh_token';
  static const String _expiresAtKey = 'github_expires_at';
  
  late final Dio _dio;
  
  GitHubAuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.githubApiBaseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ));
  }
  
  /// 获取授权URL
  Future<String> getAuthorizationUrl() async {
    // TODO: 实现GitHub OAuth2授权URL生成
    return 'https://github.com/login/oauth/authorize?client_id=${AppConstants.githubClientId}&scope=repo,user,read:org';
  }
  
  /// 启动OAuth2认证流程
  Future<bool> authenticate() async {
    try {
      final authUrl = await getAuthorizationUrl();
      final launched = await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        throw Exception('无法打开GitHub授权页面');
      }
      
      return true;
    } catch (e) {
      throw Exception('GitHub认证失败: $e');
    }
  }
  
  /// 处理授权回调
  Future<bool> handleAuthorizationCallback(String callbackUrl) async {
    try {
      final uri = Uri.parse(callbackUrl);
      final queryParams = uri.queryParameters;
      
      if (queryParams.containsKey('error')) {
        throw Exception('授权被拒绝: ${queryParams['error']}');
      }
      
      if (!queryParams.containsKey('code')) {
        throw Exception('未收到授权码');
      }
      
      final authorizationCode = queryParams['code']!;
      
      // TODO: 实现GitHub OAuth2令牌交换
      final credentials = {
        'access_token': 'dummy_token_$authorizationCode',
        'refresh_token': null,
        'expires_in': 3600,
      };
      
      // 保存认证信息
      await _saveCredentials(credentials);
      
      return true;
    } catch (e) {
      throw Exception('处理授权回调失败: $e');
    }
  }
  
  /// 保存认证凭据
  Future<void> _saveCredentials(Map<String, dynamic> credentials) async {
    await _storage.write(key: _tokenKey, value: credentials['access_token']);
    if (credentials['refresh_token'] != null) {
      await _storage.write(key: _refreshTokenKey, value: credentials['refresh_token']);
    }
    if (credentials['expires_in'] != null) {
      final expiresAt = DateTime.now().add(Duration(seconds: credentials['expires_in']));
      await _storage.write(
        key: _expiresAtKey, 
        value: expiresAt.millisecondsSinceEpoch.toString(),
      );
    }
  }
  
  /// 获取访问令牌
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  /// 检查令牌是否过期
  Future<bool> isTokenExpired() async {
    final expiresAtStr = await _storage.read(key: _expiresAtKey);
    if (expiresAtStr == null) return false;
    
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(int.parse(expiresAtStr));
    return DateTime.now().isAfter(expiresAt);
  }
  
  /// 刷新访问令牌
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        throw Exception('没有刷新令牌');
      }
      
      final response = await _dio.post(
        AppConstants.githubTokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': AppConstants.githubClientId,
          'client_secret': AppConstants.githubClientSecret,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        final expiresIn = response.data['expires_in'];
        
        // 直接保存到存储
        await _storage.write(key: _tokenKey, value: accessToken);
        if (newRefreshToken != null) {
          await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        }
        if (expiresIn != null) {
          final expiration = DateTime.now().add(Duration(seconds: expiresIn));
          await _storage.write(
            key: _expiresAtKey, 
            value: expiration.millisecondsSinceEpoch.toString(),
          );
        }
        return true;
      }
      
      return false;
    } catch (e) {
      throw Exception('刷新令牌失败: $e');
    }
  }
  
  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('未找到访问令牌');
      }
      
      final response = await _dio.get(
        '/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('获取用户信息失败');
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }
  
  /// 登出
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
  }
  
  /// 检查是否已认证
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    if (await isTokenExpired()) {
      try {
        return await refreshToken();
      } catch (e) {
        await logout();
        return false;
      }
    }
    
    return true;
  }
} 