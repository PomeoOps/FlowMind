# FlowMind - 智能工作助手

用 AI 串联你的代码、阅读、笔记与协作，打造专属工作大脑

## 🚀 项目简介

FlowMind 是一个面向开发者/研究者的智能工作助手应用，旨在整合分散的工作流程，通过AI技术提升工作效率。它将GitHub项目、Zotero论文、思源笔记、腾讯会议等工具整合到一个统一的平台中。

## ✨ 核心功能

### 👨‍💻 项目开发
- GitHub 账号登录和项目聚合
- 代码提交分析和历史追踪
- 本地/远程项目快速切换
- 项目进展自动总结

### 📚 论文阅读
- Zotero 集成和论文同步
- 论文摘要自动生成
- 与项目笔记智能关联
- 阅读进度追踪

### 📝 想法记录
- 思源笔记快速跳转/检索/添加
- 笔记内容AI扩展
- 聚合到项目中心
- 结构化研究记录

### 🧠 AI 辅助
- 项目总结和进展分析
- 代码生成/解释/优化建议
- 文献提炼和关键信息提取
- 会议纪要自动生成

### 📞 协作会议
- 腾讯会议提醒和连接
- 会议录音转文字
- 纪要自动生成
- 任务同步和跟进

### 📂 项目中台
- 自动聚合项目相关内容
- 智能关联算法
- 统一的工作视图
- 数据可视化展示

## 🛠 技术架构

### 前端框架
- **Flutter 3.16+** - 跨平台UI框架
- **Material Design 3** - 现代化设计系统
- **flutter_bloc** - 状态管理
- **go_router** - 路由管理

### 后端服务
- **Dart isolate** - 异步任务处理
- **Isar** - 高性能本地数据库
- **Dio + Retrofit** - 网络请求和API集成

### AI集成
- **OpenAI GPT-4** - 智能对话和内容生成
- **Whisper API** - 语音转文字
- **自定义Prompt模板** - 场景化AI应用

### 第三方集成
- **GitHub API** - 项目管理和代码分析
- **Zotero API** - 论文库同步
- **思源笔记API** - 笔记管理
- **腾讯会议** - 会议集成

## 📱 应用截图

### 仪表板
- 项目概览和统计
- 快捷操作入口
- 最近活动展示
- 智能提醒

### 项目中心
- GitHub项目聚合
- 代码提交分析
- 项目关联内容
- AI总结报告

### AI助手
- 多模态对话
- 代码解释优化
- 论文摘要生成
- 会议纪要提取

## 🚀 快速开始

### 环境要求
- Flutter 3.16+
- Dart 3.2+
- iOS 12.0+ / Android 6.0+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/your-username/flowmind.git
cd flowmind
```

2. **安装依赖**
```bash
flutter pub get
```

3. **配置API密钥**
编辑 `lib/core/constants/app_constants.dart` 文件，填入你的API密钥：
```dart
static const String githubClientId = 'your_github_client_id';
static const String zoteroApiKey = 'your_zotero_api_key';
static const String openaiApiKey = 'your_openai_api_key';
```

4. **运行应用**
```bash
flutter run
```

### 开发模式
```bash
# 生成代码
flutter packages pub run build_runner build

# 热重载开发
flutter run --hot

# 构建发布版本
flutter build apk
flutter build ios
```

## 📁 项目结构

```
flowmind/
├── lib/
│   ├── core/                    # 核心功能
│   │   ├── constants/           # 常量定义
│   │   ├── errors/              # 错误处理
│   │   ├── network/             # 网络层
│   │   ├── storage/             # 存储层
│   │   └── utils/               # 工具类
│   ├── data/                    # 数据层
│   │   ├── datasources/         # 数据源
│   │   ├── models/              # 数据模型
│   │   └── repositories/        # 仓储层
│   ├── domain/                  # 业务逻辑层
│   │   ├── entities/            # 实体
│   │   ├── repositories/        # 仓储接口
│   │   └── usecases/            # 用例
│   ├── presentation/            # 表现层
│   │   ├── blocs/               # 状态管理
│   │   ├── pages/               # 页面
│   │   ├── widgets/             # 组件
│   │   └── themes/              # 主题
│   ├── features/                # 功能模块
│   │   ├── auth/                # 认证模块
│   │   ├── dashboard/           # 仪表板
│   │   ├── projects/            # 项目中心
│   │   ├── papers/              # 论文阅读
│   │   ├── notes/               # 笔记管理
│   │   ├── ai_assistant/        # AI助手
│   │   └── meetings/            # 会议管理
│   └── main.dart                # 应用入口
├── assets/                      # 静态资源
├── test/                        # 测试文件
└── pubspec.yaml                 # 依赖配置
```

## 🔧 开发计划

### 第1周 - 项目初始化 ✅
- [x] Flutter项目创建和配置
- [x] 依赖包管理和版本锁定
- [x] 项目结构搭建
- [x] 基础UI主题配置
- [x] OAuth2认证框架搭建

### 第2周 - 核心功能开发 ✅
- [x] Isar数据库模型设计和实现
- [x] GitHub API集成
- [x] Zotero本地数据库同步
- [x] 基础路由系统

### 第3周 - AI模块集成 ✅
- [x] OpenAI API集成
- [x] Prompt模板系统
- [x] 异步任务处理
- [x] 结果缓存机制

### 第4周 - 功能模块完善 🔄
- [ ] 项目聚合页面
- [ ] 思源笔记API集成
- [ ] 腾讯会议集成
- [ ] 数据关联算法

### 第5周 - UI优化和测试 📋
- [ ] Material Design 3主题完善
- [ ] 响应式布局优化
- [ ] 性能优化
- [ ] 单元测试编写

### 第6周 - 打包发布 📋
- [ ] 应用打包配置
- [ ] 错误监控集成
- [ ] 用户反馈系统
- [ ] 发布准备

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [OpenAI](https://openai.com/) - AI服务提供商
- [GitHub](https://github.com/) - 代码托管平台
- [Zotero](https://www.zotero.org/) - 文献管理工具
- [思源笔记](https://b3log.org/siyuan/) - 知识管理工具

## 📞 联系我们

- 项目主页：https://github.com/your-username/flowmind
- 问题反馈：https://github.com/your-username/flowmind/issues
- 邮箱：your-email@example.com

---

**FlowMind** - 让工作更智能，让生活更高效 🚀
