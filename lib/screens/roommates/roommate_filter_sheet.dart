import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_provider.dart';
import '../../config/theme.dart';

class RoommateFilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const RoommateFilterSheet({super.key, required this.onApplyFilters});

  @override
  State<RoommateFilterSheet> createState() => _RoommateFilterSheetState();
}

class _RoommateFilterSheetState extends State<RoommateFilterSheet> {
  String? _selectedCollege;
  String? _selectedYear;
  String? _selectedGender;
  final List<String> _selectedInterests = [];

  final List<String> _colleges = [
    'MIT',
    'Stanford',
    'Harvard',
    'Berkeley',
    'Caltech',
  ];

  final List<String> _years = ['Freshman', 'Sophomore', 'Junior', 'Senior'];

  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  final List<String> _interests = [
    'Sports',
    'Music',
    'Gaming',
    'Reading',
    'Coding',
    'Art',
    'Travel',
    'Cooking',
  ];

  void _applyFilters() {
    final filters = {
      'college': _selectedCollege,
      'year': _selectedYear,
      'gender': _selectedGender,
      'interests': _selectedInterests,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedCollege = null;
      _selectedYear = null;
      _selectedGender = null;
      _selectedInterests.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.asset(
                'assets/images/futuristic_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Glassmorphic Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Roommates',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.mountainOrange,
                            ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Filters
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // College Filter
                        _buildFilterSection(
                          'College',
                          isDark,
                          DropdownButtonFormField<String>(
                            value: _selectedCollege,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: const Text('Select College'),
                            items: _colleges.map((college) {
                              return DropdownMenuItem(
                                value: college,
                                child: Text(college),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCollege = value);
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Year Filter
                        _buildFilterSection(
                          'Year',
                          isDark,
                          DropdownButtonFormField<String>(
                            value: _selectedYear,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: const Text('Select Year'),
                            items: _years.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedYear = value);
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Gender Filter
                        _buildFilterSection(
                          'Gender',
                          isDark,
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: const Text('Select Gender'),
                            items: _genders.map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedGender = value);
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Interests Filter
                        _buildFilterSection(
                          'Interests',
                          isDark,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _interests.map((interest) {
                              final isSelected = _selectedInterests.contains(
                                interest,
                              );
                              return FilterChip(
                                label: Text(interest),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedInterests.add(interest);
                                    } else {
                                      _selectedInterests.remove(interest);
                                    }
                                  });
                                },
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.8),
                                selectedColor: isDark
                                    ? AppTheme.mountainGold.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppTheme.mountainOrange.withValues(
                                        alpha: 0.5,
                                      ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDark ? Colors.white54 : Colors.black26,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, bool isDark, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
