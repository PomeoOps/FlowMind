import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/themes/app_theme.dart';
import '../services/ai_service.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/quick_prompt_widget.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = GetIt.instance<AIService>();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentContext = '';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      content: '你好！我是FlowMind的AI助手，可以帮助你：\n\n'
          '• 📚 生成论文摘要\n'
          '• 💻 解释和优化代码\n'
          '• 📝 扩展笔记内容\n'
          '• 📅 生成会议纪要\n'
          '• 🔍 分析项目进展\n\n'
          '请告诉我你需要什么帮助？',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearChat,
            tooltip: '清空对话',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickPrompts(),
          Expanded(
            child: _buildChatList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          QuickPromptWidget(
            icon: Icons.article,
            label: '论文摘要',
            onTap: () => _showPaperSummaryDialog(),
          ),
          const SizedBox(width: 12),
          QuickPromptWidget(
            icon: Icons.code,
            label: '代码解释',
            onTap: () => _showCodeExplanationDialog(),
          ),
          const SizedBox(width: 12),
          QuickPromptWidget(
            icon: Icons.note,
            label: '笔记扩展',
            onTap: () => _showNoteExpansionDialog(),
          ),
          const SizedBox(width: 12),
          QuickPromptWidget(
            icon: Icons.video_call,
            label: '会议纪要',
            onTap: () => _showMeetingMinutesDialog(),
          ),
          const SizedBox(width: 12),
          QuickPromptWidget(
            icon: Icons.analytics,
            label: '项目总结',
            onTap: () => _showProjectSummaryDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ChatMessageWidget(
          message: message,
          onRetry: message.isUser ? null : () => _retryMessage(index),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入你的问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.chat(
        message: message,
        context: _currentContext,
      );

      setState(() {
        _messages.add(ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content: '抱歉，处理你的请求时出现了错误：$e',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空所有对话记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    // TODO: 实现AI设置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置功能开发中...')),
    );
  }

  Future<void> _retryMessage(int index) async {
    if (index <= 0 || index >= _messages.length) return;

    final userMessage = _messages[index - 1];
    if (!userMessage.isUser) return;

    setState(() {
      _messages.removeAt(index);
      _isLoading = true;
    });

    try {
      final response = await _aiService.chat(
        message: userMessage.content,
        context: _currentContext,
      );

      setState(() {
        _messages.add(ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content: '重试失败：$e',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _showPaperSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生成论文摘要'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '论文标题',
                hintText: '请输入论文标题',
              ),
              onChanged: (value) => _currentContext = '论文标题：$value',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '论文摘要',
                hintText: '请输入论文摘要内容',
              ),
              maxLines: 5,
              onChanged: (value) => _currentContext += '\n摘要：$value',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.text = '请为这篇论文生成详细的摘要分析';
              _sendMessage();
            },
            child: const Text('生成摘要'),
          ),
        ],
      ),
    );
  }

  void _showCodeExplanationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('代码解释'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '编程语言',
                hintText: '如：Python, JavaScript, Dart',
              ),
              onChanged: (value) => _currentContext = '语言：$value',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '代码内容',
                hintText: '请输入需要解释的代码',
              ),
              maxLines: 8,
              onChanged: (value) => _currentContext += '\n代码：$value',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.text = '请解释这段代码的功能，并指出可能的优化点';
              _sendMessage();
            },
            child: const Text('解释代码'),
          ),
        ],
      ),
    );
  }

  void _showNoteExpansionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('笔记扩展'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '笔记标题',
                hintText: '请输入笔记标题',
              ),
              onChanged: (value) => _currentContext = '标题：$value',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '笔记内容',
                hintText: '请输入需要扩展的笔记内容',
              ),
              maxLines: 6,
              onChanged: (value) => _currentContext += '\n内容：$value',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.text = '请将这段笔记扩展为结构化的研究记录';
              _sendMessage();
            },
            child: const Text('扩展笔记'),
          ),
        ],
      ),
    );
  }

  void _showMeetingMinutesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生成会议纪要'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '会议标题',
                hintText: '请输入会议标题',
              ),
              onChanged: (value) => _currentContext = '会议：$value',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '会议内容',
                hintText: '请输入会议录音转写内容',
              ),
              maxLines: 8,
              onChanged: (value) => _currentContext += '\n内容：$value',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.text = '请根据会议内容生成会议纪要';
              _sendMessage();
            },
            child: const Text('生成纪要'),
          ),
        ],
      ),
    );
  }

  void _showProjectSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('项目总结'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '项目名称',
                hintText: '请输入项目名称',
              ),
              onChanged: (value) => _currentContext = '项目：$value',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '项目信息',
                hintText: '请输入项目相关信息（提交记录、笔记等）',
              ),
              maxLines: 6,
              onChanged: (value) => _currentContext += '\n信息：$value',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.text = '请根据项目信息生成进展总结';
              _sendMessage();
            },
            child: const Text('生成总结'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
} 