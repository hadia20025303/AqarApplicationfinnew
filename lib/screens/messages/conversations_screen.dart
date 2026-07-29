import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/conversation_model.dart';
import '../../../services/messaging_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'search_users/search_users_screen.dart';
import 'widgets/conversation_tile.dart';
import 'widgets/messages_empty_state.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessagingService _messagingService = MessagingService();
  late Future<List<ConversationModel>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  /// التحقق من تسجيل الدخول قبل تحميل المحادثات
  void _checkAuthAndLoad() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn) {
      _loadConversations();
    } else {
      // إذا لم يكن مسجلاً، نعرض قائمة فارغة مع رسالة
      _conversationsFuture = Future.value([]);
    }
  }

  /// تحميل المحادثات (بدون setState غير ضروري)
  void _loadConversations() {
    _conversationsFuture = _messagingService.fetchConversations();
  }

  /// فتح شاشة البحث عن مستخدمين
  Future<void> _openSearchUsers() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SearchUsersScreen()),
    );
    // إذا عاد المستخدم بعد بدء محادثة جديدة، نحدّث القائمة
    if (result == true) {
      _loadConversations();
    }
  }

  /// معالجة النقر على محادثة
  Future<void> _handleConversationTap(ConversationModel conv) async {
    // وضع علامة مقروءة وانتظار النتيجة (تحسين)
    await _messagingService.markConversationRead(conv.id);

    // الانتقال إلى شاشة الدردشة
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conv.id,
          otherUser: conv.otherUser,
        ),
      ),
    );

    // تحديث القائمة دائماً بعد العودة (سواء أرسل رسالة أم لا)
    // لكن نمنع التحديث إذا كان السبب هو العودة من شاشة الدردشة بدون تغيير
    // يمكننا تحديثها دائماً، أو استخدام result لتحديد إذا كان هناك تغيير.
    // هنا سنحدث دائماً، لأن قراءة الرسائل قد تغير العداد.
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('الرسائل'),
        backgroundColor: AppTheme.primaryDark,
        actions: [
          IconButton(
            onPressed: _openSearchUsers,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            color: AppTheme.goldAccent,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadConversations();
          // ننتظر حتى يتم تحميل المستقبل (لكننا لا نستخدم await هنا،
          // يمكننا استخدام FutureBuilder لإعادة البناء)
          // بدلاً من ذلك، نستخدم setState لإعادة بناء FutureBuilder
          setState(() {});
        },
        color: AppTheme.goldAccent,
        child: FutureBuilder<List<ConversationModel>>(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.goldAccent),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final conversations = snapshot.data ?? [];

            if (conversations.isEmpty) {
              // إذا كانت القائمة فارغة، نعرض حالة فارغة مع خيار بدء محادثة
              return MessagesEmptyState(onStartSearch: _openSearchUsers);
            }

            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return ConversationTile(
                  conversation: conv,
                  onTap: () => _handleConversationTap(conv),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'حدث خطأ: $error',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _loadConversations();
              setState(() {});
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}