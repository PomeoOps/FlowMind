class AppConstants {
  // GitHub OAuth2 配置
  static const String githubClientId = 'your_github_client_id';
  static const String githubClientSecret = 'your_github_client_secret';
  static const String githubRedirectUri = 'com.flowmind://oauth/callback';
  static const String githubAuthUrl = 'https://github.com/login/oauth/authorize';
  static const String githubTokenUrl = 'https://github.com/login/oauth/access_token';
  static const String githubApiBaseUrl = 'https://api.github.com';
  
  // Zotero API 配置
  static const String zoteroApiBaseUrl = 'https://api.zotero.org';
  static const String zoteroApiKey = 'your_zotero_api_key';
  static const String zoteroUserId = 'your_zotero_user_id';
  
  // 思源笔记 API 配置
  static const String siyuanApiBaseUrl = 'http://localhost:6806';
  static const String siyuanToken = 'your_siyuan_token';
  
  // OpenAI API 配置
  static const String openaiApiKey = 'your_openai_api_key';
  static const String openaiApiBaseUrl = 'https://api.openai.com/v1';
  
  // 腾讯会议配置
  static const String tencentMeetingBaseUrl = 'https://meeting.tencent.com';
  
  // 应用配置
  static const String appName = 'FlowMind';
  static const String appVersion = '1.0.0';
  static const String appDescription = '用 AI 串联你的代码、阅读、笔记与协作，打造专属工作大脑';
  
  // 数据库配置
  static const String databaseName = 'flowmind.db';
  static const int databaseVersion = 1;
  
  // 缓存配置
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // 网络配置
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // 文件配置
  static const String downloadsPath = '/downloads';
  static const String tempPath = '/temp';
  static const String logsPath = '/logs';
  
  // 通知配置
  static const String notificationChannelId = 'flowmind_channel';
  static const String notificationChannelName = 'FlowMind Notifications';
  static const String notificationChannelDescription = 'FlowMind application notifications';
  
  // 主题配置
  static const String lightThemeName = 'light';
  static const String darkThemeName = 'dark';
  static const String systemThemeName = 'system';
} 