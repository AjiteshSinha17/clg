import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user.dart';
import '../../state/theme_provider.dart';
import '../../widgets/roommate_card.dart';
import 'roommate_filter_sheet.dart';

// Soft orange-white gradient palette
const _softOrange = Color(0xFFFF8C38);
const _softOrangeLight = Color(0xFFFFB870);

class RoommateSearchScreen extends StatefulWidget {
  const RoommateSearchScreen({super.key});

  @override
  State<RoommateSearchScreen> createState() => _RoommateSearchScreenState();
}

class _RoommateSearchScreenState extends State<RoommateSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<User> _users = [];
  bool _isLoading = true;

  // Filter State
  final _searchController = TextEditingController();
  String? _cityFilter;
  String? _areaFilter;
  List<String> _interestFilters = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isLookingForRoommate', isEqualTo: true)
          .get();

      final users = snapshot.docs
          .map((doc) => User.fromFirestore(doc))
          .toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching users: $e');
    }
  }

  List<User> get _filteredUsers {
    return _users.where((user) {
      if (_searchController.text.isNotEmpty) {
        if (!user.name.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        )) {
          return false;
        }
      }
      if (_cityFilter != null && _cityFilter!.isNotEmpty) {
        if (!user.city.toLowerCase().contains(_cityFilter!.toLowerCase()) &&
            !user.college.toLowerCase().contains(_cityFilter!.toLowerCase())) {
          return false;
        }
      }
      if (_areaFilter != null && _areaFilter!.isNotEmpty) {
        if (!user.area.toLowerCase().contains(_areaFilter!.toLowerCase()) &&
            !user.year.toLowerCase().contains(_areaFilter!.toLowerCase())) {
          return false;
        }
      }
      if (_interestFilters.isNotEmpty) {
        final hasInterest = user.interestTags.any(
          (tag) => _interestFilters.contains(tag),
        );
        if (!hasInterest) return false;
      }
      return true;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoommateFilterSheet(
        onApplyFilters: (filters) {
          setState(() {
            _cityFilter = filters['college'] as String?;
            _areaFilter = filters['year'] as String?;
            _interestFilters = (filters['interests'] as List<String>?) ?? [];
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final displayUsers = _filteredUsers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Title with orange underline accent
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Roommates',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 50,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_softOrangeLight, _softOrange],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Search Bar + Filter ─────────────────────────────────────
                Row(
                  children: [
                    // Clay search bar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : _softOrange.withValues(alpha: 0.18),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.30 : 0.07,
                              ),
                              blurRadius: 16,
                              spreadRadius: 0,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(
                                alpha: isDark ? 0.04 : 0.80,
                              ),
                              blurRadius: 0,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() {}),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by name...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.35),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: _softOrange.withValues(alpha: 0.70),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Clay filter button with gradient
                    GestureDetector(
                      onTap: _openFilterSheet,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_softOrangeLight, _softOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _softOrange.withValues(alpha: 0.45),
                              blurRadius: 14,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              blurRadius: 0,
                              spreadRadius: -2,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Grid ──────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _softOrange,
                      ),
                    ),
                  )
                : displayUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                _softOrangeLight.withValues(alpha: 0.15),
                                _softOrange.withValues(alpha: 0.10),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.person_search_rounded,
                            size: 48,
                            color: _softOrange.withValues(alpha: 0.60),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No roommates found',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemCount: displayUsers.length,
                    itemBuilder: (context, index) {
                      final user = displayUsers[index];
                      return RoommateCard(
                        profile: user,
                        matchScore: 85, // Placeholder score
                        isDark: isDark,
                        onTap: () {
                          context.push('/shell/roommate-detail', extra: user);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
