import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

import '../../state/user_provider.dart';
import '../../state/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../config/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  bool _isLoading = false;

  // Personal Info Controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _collegeController = TextEditingController();
  final _branchController = TextEditingController();
  final _yearController = TextEditingController();

  // Roommate Info Controllers
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();

  // State Variables
  XFile? _imageFile;
  XFile? _bannerFile;
  Uint8List? _imageBytes;
  Uint8List? _bannerBytes;
  String? _currentAvatarUrl;
  String? _currentBannerUrl;

  // Roommate Preferences
  bool _isLookingForRoommate = false;
  List<String> _selectedInterests = [];
  String _sleepSchedule = 'flexible';
  double _cleanlinessLevel = 3;
  String _smoking = 'no';
  String _drinking = 'no';
  bool _livesAlone = false;
  String _preferredGender = 'any';

  final List<String> _allInterests = [
    'Travel',
    'Gaming',
    'Music',
    'Coding',
    'Fitness',
    'Reading',
    'Movies',
    'Sports',
    'Cooking',
    'Art',
    'Photography',
    'Dancing',
    'Singing',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio;
      _collegeController.text = user.college;
      _branchController.text = user.branch;
      _yearController.text = user.year;
      _currentAvatarUrl = user.avatarUrl;
      _currentBannerUrl = user.bannerUrl;

      // Roommate Data
      _isLookingForRoommate = user.isLookingForRoommate;
      _cityController.text = user.city;
      _areaController.text = user.area;
      _budgetMinController.text = user.budgetMin > 0
          ? user.budgetMin.toString()
          : '';
      _budgetMaxController.text = user.budgetMax > 0
          ? user.budgetMax.toString()
          : '';
      _selectedInterests = List.from(user.interestTags);
      _sleepSchedule = user.sleepSchedule;
      _cleanlinessLevel = user.cleanlinessLevel.toDouble();
      _smoking = user.smoking;
      _drinking = user.drinking;
      _livesAlone = user.livesAlone;
      _preferredGender = user.preferredGender;
    }
  }

  Future<void> _pickImage(ImageSource source, {bool isBanner = false}) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: isBanner ? 1200 : 800,
        maxHeight: isBanner ? 600 : 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          if (isBanner) {
            _bannerFile = pickedFile;
            _bannerBytes = bytes;
          } else {
            _imageFile = pickedFile;
            _imageBytes = bytes;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? newAvatarUrl;
      String? newBannerUrl;

      // Upload Image if changed
      if (_imageFile != null) {
        newAvatarUrl = await _storageService.uploadProfileImageXFile(
          userProvider.user!.uid,
          _imageFile!,
        );
      }

      if (_bannerFile != null) {
        newBannerUrl = await _storageService.uploadBannerImageXFile(
          userProvider.user!.uid,
          _bannerFile!,
        );
      }

      await userProvider.updateUserProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        college: _collegeController.text.trim(),
        branch: _branchController.text.trim(),
        year: _yearController.text.trim(),
        avatarUrl: newAvatarUrl,
        bannerUrl: newBannerUrl,

        // Roommate Fields
        isLookingForRoommate: _isLookingForRoommate,
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        budgetMin: double.tryParse(_budgetMinController.text) ?? 0,
        budgetMax: double.tryParse(_budgetMaxController.text) ?? 0,
        interestTags: _selectedInterests,
        sleepSchedule: _sleepSchedule,
        cleanlinessLevel: _cleanlinessLevel.toInt(),
        smoking: _smoking,
        drinking: _drinking,
        livesAlone: _livesAlone,
        preferredGender: _preferredGender,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface;
    final subtextColor = isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final cardColor = isDark ? AppTheme.darkContainer : AppTheme.lightContainer;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: surfaceColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.check, color: isDark ? AppTheme.softBeige : AppTheme.lightPrimary),
              onPressed: _submit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner and Avatar Section
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Banner
                  GestureDetector(
                    onTap: () => _showImageSourceSheet(isBanner: true),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        image: _bannerBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_bannerBytes!),
                                fit: BoxFit.cover,
                              )
                            : (_currentBannerUrl != null &&
                                  _currentBannerUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(_currentBannerUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (_bannerFile == null &&
                              (_currentBannerUrl == null ||
                                  _currentBannerUrl!.isEmpty))
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Cover Photo',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.black54,
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Avatar
                  Positioned(
                    bottom: -50,
                    child: GestureDetector(
                      onTap: () => _showImageSourceSheet(isBanner: false),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.2,
                              ),
                              backgroundImage: _imageBytes != null
                                  ? MemoryImage(_imageBytes!)
                                  : (_currentAvatarUrl != null &&
                                        _currentAvatarUrl!.isNotEmpty)
                                  ? NetworkImage(_currentAvatarUrl!)
                                        as ImageProvider
                                  : null,
                              child:
                                  (_imageFile == null &&
                                      (_currentAvatarUrl == null ||
                                          _currentAvatarUrl!.isEmpty))
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60), // Space for Avatar overlap

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSectionHeader('Personal Details', textColor: textColor),
                    _buildTextField(
                      _nameController,
                      'Full Name',
                      Icons.person,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      cardColor: cardColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _bioController,
                      'Bio',
                      Icons.info_outline,
                      maxLines: 3,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      cardColor: cardColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _collegeController,
                      'College Name',
                      Icons.school,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      cardColor: cardColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _branchController,
                            'Branch',
                            Icons.book,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            cardColor: cardColor,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _yearController,
                            'Year',
                            Icons.calendar_today,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            cardColor: cardColor,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Roommate Preferences
                    _buildSectionHeader('Roommate Preferences', textColor: textColor),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Looking for a Roommate?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Turn this on to appear in search results',
                          style: TextStyle(color: subtextColor, fontSize: 13),
                        ),
                        value: _isLookingForRoommate,
                        onChanged: (val) =>
                            setState(() => _isLookingForRoommate = val),
                        activeTrackColor: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                      ),
                    ),

                    if (_isLookingForRoommate) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _cityController,
                              'City',
                              Icons.location_city,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardColor: cardColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              _areaController,
                              'Area',
                              Icons.map,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardColor: cardColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _budgetMinController,
                              'Min Budget',
                              Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardColor: cardColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              _budgetMaxController,
                              'Max Budget',
                              Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardColor: cardColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Interests',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allInterests.map((tag) {
                          final isSelected = _selectedInterests.contains(tag);
                          return FilterChip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF372F37))
                                    : subtextColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInterests.add(tag);
                                } else {
                                  _selectedInterests.remove(tag);
                                }
                              });
                            },
                            backgroundColor: cardColor,
                            selectedColor: AppTheme.paletteViolet.withValues(alpha: 0.25),
                            checkmarkColor: AppTheme.paletteViolet,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.paletteViolet
                                  : (isDark ? Colors.white24 : Colors.black26),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      _buildDropdown(
                        'Sleep Schedule',
                        _sleepSchedule,
                        ['early', 'late', 'flexible'],
                        (v) => setState(() => _sleepSchedule = v!),
                        textColor: textColor,
                        subtextColor: subtextColor,
                        cardColor: cardColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cleanliness Level: ${_cleanlinessLevel.toInt()}/5',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.paletteViolet,
                          thumbColor: AppTheme.paletteViolet,
                          overlayColor: AppTheme.paletteViolet.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _cleanlinessLevel,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _cleanlinessLevel.toInt().toString(),
                          onChanged: (v) => setState(() => _cleanlinessLevel = v),
                        ),
                      ),

                      _buildDropdown(
                        'Smoking',
                        _smoking,
                        ['no', 'occasionally', 'yes'],
                        (v) => setState(() => _smoking = v!),
                        textColor: textColor,
                        subtextColor: subtextColor,
                        cardColor: cardColor,
                        isDark: isDark,
                      ),
                      _buildDropdown(
                        'Drinking',
                        _drinking,
                        ['no', 'occasionally', 'yes'],
                        (v) => setState(() => _drinking = v!),
                        textColor: textColor,
                        subtextColor: subtextColor,
                        cardColor: cardColor,
                        isDark: isDark,
                      ),

                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Do you currently live alone?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              fontSize: 15,
                            ),
                          ),
                          value: _livesAlone,
                          onChanged: (v) => setState(() => _livesAlone = v),
                          activeTrackColor: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                        ),
                      ),

                      _buildDropdown(
                        'Preferred Roommate Gender',
                        _preferredGender,
                        ['any', 'male', 'female'],
                        (v) => setState(() => _preferredGender = v!),
                        textColor: textColor,
                        subtextColor: subtextColor,
                        cardColor: cardColor,
                        isDark: isDark,
                      ),
                    ],

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.paletteViolet,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: textColor.withValues(alpha: 0.3), thickness: 1),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    Color? textColor,
    Color? subtextColor,
    Color? cardColor,
    bool isDark = false,
  }) {
    final labelColor = subtextColor ?? Colors.black54;
    final fill = cardColor ?? Theme.of(context).cardColor;
    final borderColor = isDark
        ? AppTheme.goldenBorder.withValues(alpha: 0.3)
        : Colors.black26;
    final accentIcon = isDark ? AppTheme.softBeige : AppTheme.lightPrimary;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor ?? (isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface), fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w500, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: accentIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? AppTheme.goldenBorder : AppTheme.lightPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (label == 'Full Name' && (value == null || value.isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    Color? textColor,
    Color? subtextColor,
    Color? cardColor,
    bool isDark = false,
  }) {
    final labelColor = subtextColor ?? Colors.black54;
    final fill = cardColor ?? Theme.of(context).cardColor;
    final borderColor = isDark ? Colors.white24 : Colors.black26;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: fill,
        style: TextStyle(color: textColor ?? const Color(0xFF372F37), fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.paletteViolet, width: 2),
          ),
          filled: true,
          fillColor: fill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e.toUpperCase(), style: TextStyle(color: textColor)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showImageSourceSheet({required bool isBanner}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isBanner: isBanner);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isBanner: isBanner);
              },
            ),
          ],
        ),
      ),
    );
  }
}
