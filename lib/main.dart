import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'core/constants/app_constants.dart';
import 'data/models/project.dart';
import 'data/models/paper.dart';
import 'data/models/note.dart';
import 'data/models/meeting.dart';
import 'presentation/themes/app_theme.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'features/auth/services/github_auth_service.dart';
import 'features/projects/services/github_api_service.dart';
import 'features/projects/blocs/project_bloc.dart';
import 'features/papers/services/zotero_service.dart';
import 'features/papers/blocs/paper_bloc.dart';
import 'features/ai_assistant/services/ai_service.dart';
import 'features/notes/services/siyuan_service.dart';
import 'features/meetings/services/tencent_meeting_service.dart';
import 'core/services/data_association_service.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 先初始化数据库
    await _initializeDatabase();
    
    // 再初始化依赖注入
    await _initializeDependencies();
    
    runApp(const FlowMindApp());
  } catch (e) {
    print('初始化失败: $e');
    // 如果初始化失败，显示错误页面
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('初始化失败: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 重新启动应用
                  main();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

Future<void> _initializeDependencies() async {
  try {
    // 注册服务
    getIt.registerSingleton<GitHubAuthService>(GitHubAuthService());
    getIt.registerSingleton<ZoteroService>(ZoteroService());
    getIt.registerSingleton<AIService>(AIService());
    getIt.registerSingleton<SiyuanService>(SiyuanService());
    getIt.registerSingleton<DataAssociationService>(DataAssociationService());
    
    // 注册GitHub服务（依赖GitHubAuthService）
    getIt.registerSingleton<GitHubService>(GitHubService(getIt<GitHubAuthService>()));
    
    // 注册Bloc
    getIt.registerFactory<ProjectBloc>(() => ProjectBloc(getIt<GitHubService>()));
    getIt.registerFactory<PaperBloc>(() => PaperBloc(getIt<ZoteroService>()));
  } catch (e) {
    print('依赖注入初始化失败: $e');
    rethrow;
  }
}

Future<void> _initializeDatabase() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [ProjectSchema, PaperSchema, NoteSchema, MeetingSchema],
      directory: dir.path,
    );
    getIt.registerSingleton<Isar>(isar);
  } catch (e) {
    print('数据库初始化失败: $e');
    // 数据库初始化失败不应该阻止应用启动
    // 可以注册一个空的Isar实例或跳过
  }
}

class FlowMindApp extends StatelessWidget {
  const FlowMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectBloc>(
          create: (context) => getIt<ProjectBloc>(),
        ),
        BlocProvider<PaperBloc>(
          create: (context) => getIt<PaperBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const DashboardPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


