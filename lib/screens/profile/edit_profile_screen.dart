import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart'; // سنستخدم AuthService المحدث
import '../../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel currentUser;
  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: widget.currentUser.firstName);
    _lastNameController = TextEditingController(text: widget.currentUser.lastName);
    _phoneController = TextEditingController(text: widget.currentUser.phone);
    _descriptionController = TextEditingController(text: widget.currentUser.description);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }


  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

      final success = await _authService.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        avatarPath: _selectedImage?.path,
      );

      if (mounted) {
        if (success) {
          _showSnack('تم تحديث البيانات بنجاح', Colors.green);
          Navigator.pop(context, true); // إرجاع true لتحديث شاشة البروفايل
        } else {
          _showSnack('فشل التحديث، حاول مجدداً', Colors.redAccent);
        }
      }
    } catch (e) {
      _showSnack('حدث خطأ: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.secondaryDark,
        appBar: AppBar(
          title: const Text('تعديل الملف الشخصي', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppTheme.primaryDark,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAvatarPicker(),
                const SizedBox(height: 32),
                _buildTextField(_firstNameController, 'الاسم الأول', Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(_lastNameController, 'اسم العائلة', Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, 'رقم الهاتف', Icons.phone_android_outlined, type: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(_descriptionController, 'نبذة تعريفية', Icons.description_outlined, maxLines: 3),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.fieldBg,
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!) as ImageProvider
              : (widget.currentUser.avatar != null ? NetworkImage(widget.currentUser.avatar!) : null),
          child: _selectedImage == null && widget.currentUser.avatar == null
              ? const Icon(Icons.person, size: 60, color: Colors.white24)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.goldAccent,
              child: Icon(Icons.camera_alt, size: 18, color: AppTheme.secondaryDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: type,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.goldAccent),
        filled: true,
        fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: AppTheme.secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('حفظ التغييرات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}