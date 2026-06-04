import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'groups_provider.dart';
import 'group_success_screen.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  
  String? _nameError;
  bool _isLoading = false;
  bool _approvalRequired = false;
  String _selectedType = 'Office';
  
  final List<LinearGradient> _presetGradients = [
    const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
    const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]),
    const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
    const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
    const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)]),
  ];
  int _selectedGradientIndex = 0;
  File? _imageFile;

  String _selectedGraphic = 'briefcase';

  final List<Map<String, dynamic>> _presetGraphics = const [
    {'id': 'briefcase', 'icon': Iconsax.briefcase},
    {'id': 'home', 'icon': Iconsax.home_2},
    {'id': 'routing', 'icon': Iconsax.routing},
    {'id': 'coffee', 'icon': Iconsax.coffee},
    {'id': 'shopping_bag', 'icon': Iconsax.shopping_bag},
    {'id': 'car', 'icon': Iconsax.car},
    {'id': 'game', 'icon': Iconsax.game},
    {'id': 'wallet_3', 'icon': Iconsax.wallet_3},
  ];

  IconData _getPresetIconData(String name) {
    switch (name) {
      case 'briefcase':
        return Iconsax.briefcase;
      case 'home':
        return Iconsax.home_2;
      case 'routing':
        return Iconsax.routing;
      case 'coffee':
        return Iconsax.coffee;
      case 'shopping_bag':
        return Iconsax.shopping_bag;
      case 'car':
        return Iconsax.car;
      case 'game':
        return Iconsax.game;
      case 'wallet_3':
        return Iconsax.wallet_3;
      default:
        return Iconsax.element_4;
    }
  }
  
  // Group types with custom icons (no emojis)
  final List<Map<String, dynamic>> _groupTypes = [
    {'name': 'Office', 'icon': Iconsax.briefcase},
    {'name': 'Home', 'icon': Iconsax.home_2},
    {'name': 'Travel', 'icon': Iconsax.routing},
    {'name': 'Other', 'icon': Iconsax.element_4},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Failed to pick image from gallery',
        );
      }
    }
  }

  void _submit() {
    setState(() {
      _nameError = null;
    });

    final name = _nameController.text.trim();
    final company = _companyController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Group Name is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      final newGroup = ref.read(groupsProvider.notifier).createGroup(
        name: name,
        companyName: company.isEmpty ? 'Personal' : company,
        type: _selectedType,
        approvalRequired: _approvalRequired,
        imageUrl: _imageFile != null ? _imageFile!.path : 'preset_icon:$_selectedGraphic',
      );

      setState(() {
        _isLoading = false;
      });

      AppSnackbar.success(
        context,
        'Group "$name" created successfully!',
        showAtTop: true,
      );

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        showDragHandle: false,
        builder: (context) {
          return GroupSuccessSheet(
            groupName: newGroup.name,
            inviteCode: newGroup.inviteCode,
            onClose: () {
              Navigator.pop(context); // Close bottom sheet
            },
          );
        },
      ).then((_) {
        if (mounted) {
          context.pop(); // Pop CreateGroupScreen back to groups list
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      appBar: AppBar(
        title: Text(
          'New Group',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? c.neutral50 : c.neutral900,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 54),
              // ── PREMIUM CIRCULAR PHOTO PICKER ──
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _imageFile == null ? _presetGradients[_selectedGradientIndex] : null,
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: (_imageFile == null
                                      ? _presetGradients[_selectedGradientIndex].colors.first
                                      : Colors.black)
                                  .withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _imageFile == null
                            ? Center(
                                child: Icon(
                                  _getPresetIconData(_selectedGraphic),
                                  color: Colors.white,
                                  size: 38,
                                ),
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? c.primary400 : c.primary600,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? c.background : Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Iconsax.camera_copy,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Theme Presets Selector
              if (_imageFile == null) ...[
                Center(
                  child: SizedBox(
                    height: 38,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(Colors.transparent),
                          trackColor: WidgetStateProperty.all(Colors.transparent),
                          thickness: WidgetStateProperty.all(0),
                          interactive: false,
                        ),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _presetGradients.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedGradientIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGradientIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _presetGradients[index],
                                border: Border.all(
                                  color: isSelected ? (isDark ? c.neutral50 : c.neutral900) : Colors.transparent,
                                  width: isSelected ? 3.0 : 0.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: _presetGradients[index].colors.first.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],

              // Icon Presets Selector
              if (_imageFile == null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Choose an icon graphic:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? c.neutral400 : c.neutral500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    height: 44,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(Colors.transparent),
                          trackColor: WidgetStateProperty.all(Colors.transparent),
                          thickness: WidgetStateProperty.all(0),
                          interactive: false,
                        ),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _presetGraphics.length,
                        itemBuilder: (context, index) {
                          final item = _presetGraphics[index];
                          final isSelected = item['id'] == _selectedGraphic;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGraphic = item['id']!;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? c.primary500.withValues(alpha: 0.15) : c.primary50)
                                    : (isDark ? c.surface2 : Colors.white),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? c.primary400 : c.primary600)
                                      : (isDark ? c.surface3 : c.neutral200),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 18,
                                  color: isSelected
                                      ? (isDark ? c.primary400 : c.primary600)
                                      : (isDark ? c.neutral300 : c.neutral600),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],

              // ── FORM SECTION ──
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form fields directly on background for a premium seamless appearance
                      AppTextField(
                        controller: _nameController,
                        label: 'Group Name',
                        hint: 'e.g. Office Snacks, Lunch Split',
                        errorText: _nameError,
                        prefixIcon: Iconsax.profile_2user,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 22),

                      AppTextField(
                        controller: _companyController,
                        label: 'Company Name (Optional)',
                        hint: 'e.g. Splity HQ, Floor 4',
                        prefixIcon: Iconsax.building,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                      ),

                      const SizedBox(height: 30),

                      // ── CLEAN CATEGORY CHIPS ──
                      Text(
                        'Category',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? c.neutral300 : c.neutral800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _groupTypes.map((type) {
                          final isSelected = _selectedType == type['name'];
                          return AppChip(
                            label: type['name'],
                            isSelected: isSelected,
                            leadingIcon: type['icon'],
                            onTap: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _selectedType = type['name'];
                                    });
                                  },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 48),

                      AppButton(
                        label: 'Create Group',
                        size: AppButtonSize.lg,
                        isFullWidth: true,
                        hasShadow: false,
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
