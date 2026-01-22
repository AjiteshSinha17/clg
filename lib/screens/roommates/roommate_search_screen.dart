import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user.dart';
import '../../state/theme_provider.dart';
import '../../widgets/roommate_card.dart';
import '../../config/theme.dart';
import 'roommate_filter_sheet.dart';

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
      // Fetch all users looking for a roommate
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
      // 0. Name Filter
      if (_searchController.text.isNotEmpty) {
        if (!user.name.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        )) {
          return false;
        }
      }

      // 1. City Filter
      if (_cityFilter != null && _cityFilter!.isNotEmpty) {
        if (!user.city.toLowerCase().contains(_cityFilter!.toLowerCase()) &&
            !user.college.toLowerCase().contains(_cityFilter!.toLowerCase())) {
          return false;
        }
      }

      // 2. Area Filter
      if (_areaFilter != null && _areaFilter!.isNotEmpty) {
        if (!user.area.toLowerCase().contains(_areaFilter!.toLowerCase()) &&
            !user.year.toLowerCase().contains(_areaFilter!.toLowerCase())) {
          return false;
        }
      }

      // 3. Interest Filter
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
            _cityFilter =
                filters['college'] as String?; // Reusing college field for city
            _areaFilter =
                filters['year'] as String?; // Reusing year field for area
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
          // Header / Filter Bar
          // Header with Search and Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Roommates',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by name...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.mountainGold
                            : AppTheme.mountainOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                        onPressed: _openFilterSheet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayUsers.isEmpty
                ? Center(
                    child: Text(
                      'No roommates found matching your filters.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: displayUsers.length,
                    itemBuilder: (context, index) {
                      final user = displayUsers[index];
                      return RoommateCard(
                        profile: user,
                        matchScore: 85, // Placeholder score
                        isDark: isDark,
                        onTap: () {
                          // Navigate to detail
                          context.push('/shell/roommate-detail', extra: user);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // Removed FloatingActionButton as requested
    );
  }
}
