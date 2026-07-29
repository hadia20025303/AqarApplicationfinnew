import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/message_model.dart';
import '../../../models/conversation_model.dart';
import '../../../services/messaging_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final OtherUser otherUser;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  // لإدارة الاشتراك في الرسائل الجديدة (WebSocket أو Stream)
  // سنستخدمه لاحقاً
  // StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    // يمكن تفعيل الاستماع للرسائل الجديدة هنا
    // _startMessageListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // _messageSubscription?.cancel();
    super.dispose();
  }

  /// جلب الرسائل من السيرفر
  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _messagingService.fetchConversationDetail(widget.conversationId);
      if (mounted) {
        setState(() {
          _messages = (data['messages'] as List)
              .map((m) => MessageModel.fromJson(m))
              .toList();
          _isLoading = false;
        });
        // التمرير للأسفل بعد اكتمال البناء
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// التمرير إلى أسفل القائمة
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// إرسال رسالة جديدة
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    try {
      final newMessage = await _messagingService.sendMessage(widget.conversationId, text);
      if (mounted) {
        setState(() {
          _messages.add(newMessage);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال الرسالة: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// (اختياري) الاستماع للرسائل الجديدة عبر WebSocket أو Stream
  // void _startMessageListener() {
  //   _messageSubscription = _messagingService.messageStream.listen((newMsg) {
  //     if (mounted && newMsg.conversation == widget.conversationId) {
  //       setState(() {
  //         _messages.add(newMsg);
  //       });
  //       _scrollToBottom();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.otherUser.avatar != null
                  ? NetworkImage(widget.otherUser.avatar!)
                  : null,
              child: widget.otherUser.avatar == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.otherUser.username,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight),
          onPressed: () => Navigator.pop(context, true), // إرجاع true لتحديث القائمة
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(currentUserId),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList(int? currentUserId) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.goldAccent),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ: $_errorMessage',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMessages,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد رسائل بعد، ابدأ المحادثة!',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.sender == currentUserId;
        return _buildMessageBubble(msg, isMe);
      },
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.goldAccent : AppTheme.fieldBg,
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomLeft: isMe ? const Radius.circular(0) : const Radius.circular(15),
            bottomRight: isMe ? const Radius.circular(15) : const Radius.circular(0),
          ),
        ),
        child: Text(
          msg.messageText,
          style: TextStyle(
            color: isMe ? AppTheme.secondaryDark : AppTheme.textLight,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: AppTheme.fieldBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppTheme.goldAccent,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.secondaryDark),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}