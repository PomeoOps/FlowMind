import 'package:flutter/material.dart';
import '../../../presentation/themes/app_theme.dart';
import '../pages/ai_assistant_page.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isUser) const Spacer(),
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppTheme.primaryColor 
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: !message.isUser 
                    ? Border.all(color: AppTheme.dividerColor)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white 
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: message.isUser 
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      if (message.isError) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 16,
                        ),
                      ],
                      if (!message.isUser && onRetry != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onRetry,
                          child: Icon(
                            Icons.refresh,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!message.isUser) const Spacer(),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
} 