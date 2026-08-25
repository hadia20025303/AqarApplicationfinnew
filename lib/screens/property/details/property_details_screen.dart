import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// الموديلات والخدمات
import '../../../../models/property_model.dart';
import '../../../../models/conversation_model.dart';
import '../../../../services/property_service.dart';
import '../../../../services/messaging_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../profile/public_profile_screen.dart';
import '../../../../theme/app_theme.dart';



// الويدجتات المكونة للشاشة (تأكد من وجود جميع هذه الأسطر)
import '../../auth/login_screen.dart';
import '../../messages/chat_screen.dart';
import 'widgets/details_image_carousel.dart';
import 'widgets/details_map_view.dart';
import 'widgets/details_owner_card.dart';
import 'widgets/details_quick_info.dart';
import 'widgets/details_residential_grid.dart';
import 'widgets/details_bottom_actions.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final PropertyModel property;
  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PropertyService _propertyService = PropertyService();
  final MessagingService _messagingService = MessagingService();
  final AuthService _authService = AuthService();

  String _ownerName = 'مالك العقار';
  String _ownerPhone = '0500000000';
  String _ownerUsername = '';
  int _ownerId = 0;
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _ownerId = widget.property.ownerId;
    _checkFavoriteStatus();
    _loadOwnerDetails();
  }

  // --- منطق البيانات (Logic) ---

  Future<void> _loadOwnerDetails() async {
    if (widget.property.ownerUsername != null &&
        widget.property.ownerUsername!.isNotEmpty) {
      try {
        final user = await _authService.getPublicProfile(
          widget.property.ownerUsername!,
        );
        if (mounted && user != null) {
          setState(() {
            _ownerName = user.fullName.isNotEmpty ? user.fullName : 'مالك العقار';
            _ownerPhone = user.phone ?? 'رقم غير متوفر';
            _ownerUsername = user.username;
          });
        }
      } catch (e) {
        debugPrint("فشل جلب بيانات المالك");
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      if (mounted) setState(() => _isLoadingFavorite = false);
      return;
    }
    try {
      final isFav = await _propertyService.checkIsFavorite(widget.property.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _isLoadingFavorite = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingFavorite = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      final res = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (res == true) _checkFavoriteStatus();
      return;
    }

    setState(() => _isLoadingFavorite = true);
    try {
      if (_isFavorite) {
        await _propertyService.removeFavorite(widget.property.id);
        setState(() => _isFavorite = false);
        _showSnack('تمت الإزالة من المفضلة', Colors.orange);
      } else {
        await _propertyService.addFavorite(widget.property.id);
        setState(() => _isFavorite = true);
        _showSnack('تمت الإضافة إلى المفضلة', Colors.green);
      }
    } catch (e) {
      _showSnack('حدث خطأ: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoadingFavorite = false);
    }
  }


  Future<void> _callOwner() async {
    // 1. تنظيف رقم الهاتف من أي مسافات زائدة
    String phone = _ownerPhone.trim();

    // 2. التحقق من وجود رقم حقيقي
    if (phone.isEmpty || phone == '0500000000') {
      _showSnack('رقم المالك غير متوفر حالياً', Colors.orange);
      return;
    }

    // 3. بناء الرابط الخاص بتطبيق الهاتف
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      // 4. محاولة فتح تطبيق الاتصال
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showSnack('لا يمكن فتح تطبيق الهاتف على هذا الجهاز', Colors.redAccent);
      }
    } catch (e) {
      _showSnack('حدث خطأ أثناء محاولة الاتصال', Colors.redAccent);
    }
  }

Future<void> _startChat() async {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  if (!auth.isLoggedIn) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return;
  }
  if (auth.user?.id == _ownerId) {
    _showSnack('لا يمكنك مراسلة نفسك', Colors.orange);
    return;
  }

  try {
    final conv = await _messagingService.createConversation(_ownerId);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv.id,
            otherUser: OtherUser(
              id: _ownerId,
              username: _ownerName,
              avatar: null,
            ),
          ),
        ),
      );
    }
  } catch (e) {
    _showSnack('فشل بدء المحادثة', Colors.redAccent);
  }
}

  void _showSnack(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceAndTag(),
                  const SizedBox(height: 12),
                  _buildLocationHeader(),
                  const SizedBox(height: 24),
                  DetailsQuickInfo(
                    area: widget.property.area,
                    categoryLabel: _getCategoryLabel(),
                  ),
                  const SizedBox(height: 24),
                  if (widget.property.location != null)
                    DetailsMapView(
                      lat: widget.property.location?.latitude ?? 0.0,
                      lng: widget.property.location?.longitude ?? 0.0,
                      address: '${widget.property.location!.city}، ${widget.property.location!.region}',
                      onOpenMap: () => _launchMap(),
                    ),
                  const SizedBox(height: 24),
                  if (widget.property.residentialDetails != null)
                    DetailsResidentialGrid(
                      details: widget.property.residentialDetails,
                    ),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  DetailsOwnerCard(
                  name: _ownerName,
                  username: _ownerUsername, // تمرير username
                  onTap: () {
                  if (_ownerUsername.isNotEmpty) {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(username: _ownerUsername),
        ),
      );
    } else {
      _showSnack('لا يمكن عرض الملف الشخصي', Colors.orange);
    }
  },
),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DetailsBottomActions(
        onCall: _callOwner,
        onChat: _startChat,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.primaryDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textLight),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: DetailsImageCarousel(images: widget.property.images),
      ),
      actions: [
        IconButton(
          icon: _isLoadingFavorite
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : AppTheme.goldAccent,
          ),
          onPressed: _isLoadingFavorite ? null : _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppTheme.goldAccent),
          onPressed: () => Share.share("عقار رائع في تطبيق عقار!"),
        ),
      ],
    );
  }

  Widget _buildPriceAndTag() {
    final isSale = widget.property.transactionType == 'sale';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.property.price.toStringAsFixed(0)} \$',
          style: const TextStyle(color: AppTheme.goldAccent, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isSale ? Colors.green : Colors.orange).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSale ? Colors.green : Colors.orange),
          ),
          child: Text(isSale ? 'للبيع' : 'للإيجار', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.goldAccent),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.property.location != null
                ? '${widget.property.location!.city}، ${widget.property.location!.region}'
                : 'الموقع غير محدد',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('وصف العقار', style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.fieldBg, borderRadius: BorderRadius.circular(16)),
          child: Text(widget.property.description, style: const TextStyle(color: Colors.white70, height: 1.5)),
        ),
      ],
    );
  }

  String _getCategoryLabel() {
    switch (widget.property.category) {
      case 'residential': return 'سكني';
      case 'commercial': return 'تجاري';
      case 'land': return 'أرض';
      default: return widget.property.category;
    }
  }

  void _launchMap() {
    final lat = widget.property.location?.latitude ?? 24.7136;
    final lng = widget.property.location?.longitude ?? 46.6753;
    final url = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=15/$lat/$lng');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}