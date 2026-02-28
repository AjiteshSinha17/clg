import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../../models/connection_request.dart';
import '../../models/user.dart';
import '../../state/theme_provider.dart';
import '../../config/theme.dart';
import '../../services/connection_service.dart';
import '../../services/chat_service.dart';

class RoommateDetailScreen extends StatefulWidget {
  final User profile;

  const RoommateDetailScreen({super.key, required this.profile});

  @override
  State<RoommateDetailScreen> createState() => _RoommateDetailScreenState();
}

class _RoommateDetailScreenState extends State<RoommateDetailScreen> {
  final ConnectionService _connectionService = ConnectionService();

  String _connectionStatus = 'none';
  bool _loadingStatus = true;
  bool _actionLoading = false;
  ConnectionRequest? _pendingRequestToMe; // when status == pending_received

  @override
  void initState() {
    super.initState();
    _loadConnectionStatus();
  }

  Future<void> _loadConnectionStatus() async {
    setState(() => _loadingStatus = true);
    try {
      final status = await _connectionService.getConnectionStatus(widget.profile.uid);
      ConnectionRequest? pending;
      if (status == 'pending_received') {
        final list = await _connectionService.getPendingRequestsToMe();
        try {
          pending = list.firstWhere((r) => r.fromUserId == widget.profile.uid);
        } catch (_) {
          pending = null;
        }
      }
      if (mounted) {
        setState(() {
          _connectionStatus = status;
          _pendingRequestToMe = pending;
          _loadingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _sendRequest() async {
    setState(() => _actionLoading = true);
    try {
      await _connectionService.sendRequest(widget.profile.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request sent!')),
        );
        _loadConnectionStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _acceptRequest() async {
    final req = _pendingRequestToMe;
    if (req == null) return;
    setState(() => _actionLoading = true);
    try {
      final chatId = await _connectionService.acceptRequest(req.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected! Opening chat.')),
        );
        context.push('/chat/$chatId', extra: widget.profile);
        _loadConnectionStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _rejectRequest() async {
    final req = _pendingRequestToMe;
    if (req == null) return;
    setState(() => _actionLoading = true);
    try {
      await _connectionService.rejectRequest(req.id);
      if (mounted) _loadConnectionStatus();
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final profile = widget.profile;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/images/mountain_dark.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // AppBar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Text(profile.name),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                if (profile.verificationStatus == 'verified')
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.verified, color: Colors.blue),
                  ),
              ],
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glass card
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header avatar + name
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 52,
                                      backgroundImage:
                                          profile.avatarUrl.isNotEmpty
                                              ? NetworkImage(profile.avatarUrl)
                                              : null,
                                      child: profile.avatarUrl.isEmpty
                                          ? Text(
                                              profile.name.isNotEmpty
                                                  ? profile.name[0]
                                                      .toUpperCase()
                                                  : '?',
                                              style:
                                                  const TextStyle(fontSize: 36),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      profile.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile.college.isNotEmpty
                                          ? profile.college
                                          : 'Unknown College',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[400]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bio
                              _buildSectionTitle(context, 'Bio'),
                              Text(
                                profile.bio.isNotEmpty
                                    ? profile.bio
                                    : 'No bio provided.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),

                              // Location & Budget
                              _buildSectionTitle(context, 'Details'),
                              _buildInfoRow(
                                context,
                                Icons.location_on,
                                '${profile.area}, ${profile.city}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.currency_rupee,
                                '₹${profile.budgetMin.toInt()} - ₹${profile.budgetMax.toInt()}',
                              ),
                              const SizedBox(height: 16),

                              // Interests
                              if (profile.interestTags.isNotEmpty) ...[
                                _buildSectionTitle(context, 'Interests'),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: profile.interestTags.map((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      backgroundColor: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Lifestyle
                              _buildSectionTitle(context, 'Lifestyle'),
                              _buildInfoRow(
                                context,
                                Icons.bedtime,
                                'Sleep: ${profile.sleepSchedule}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.cleaning_services,
                                'Cleanliness: ${profile.cleanlinessLevel}/5',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.smoking_rooms,
                                'Smoking: ${profile.smoking}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.local_drink,
                                'Drinking: ${profile.drinking}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.home,
                                profile.livesAlone
                                    ? 'Lives Alone'
                                    : 'Looking for place',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildConnectButton(isDark, profile),
    );
  }

  Widget _buildConnectButton(bool isDark, User profile) {
    if (_loadingStatus) {
      return FloatingActionButton.extended(
        onPressed: null,
        label: const Text('Loading...'),
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        backgroundColor: isDark ? AppTheme.mountainGold : AppTheme.mountainOrange,
      );
    }

    if (_connectionStatus == 'accepted') {
      return FloatingActionButton.extended(
        onPressed: _actionLoading ? null : _openChat,
        label: Text(_actionLoading ? 'Opening...' : 'Open Chat'),
        icon: _actionLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.chat),
        backgroundColor: isDark ? AppTheme.mountainGold : AppTheme.mountainOrange,
      );
    }

    if (_connectionStatus == 'pending_sent') {
      return FloatingActionButton.extended(
        onPressed: null,
        label: const Text('Request sent'),
        icon: const Icon(Icons.schedule),
        backgroundColor: Colors.grey,
      );
    }

    if (_connectionStatus == 'pending_received') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _actionLoading ? null : _rejectRequest,
            label: const Text('Reject'),
            icon: const Icon(Icons.close),
            backgroundColor: Colors.grey[700],
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            onPressed: _actionLoading ? null : _acceptRequest,
            label: Text(_actionLoading ? '...' : 'Accept & Chat'),
            icon: _actionLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.chat),
            backgroundColor: isDark ? AppTheme.mountainGold : AppTheme.mountainOrange,
          ),
        ],
      );
    }

    return FloatingActionButton.extended(
      onPressed: _actionLoading ? null : _sendRequest,
      label: Text(_actionLoading ? 'Sending...' : 'Connect & Chat'),
      icon: _actionLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.chat),
      backgroundColor: isDark ? AppTheme.mountainGold : AppTheme.mountainOrange,
    );
  }

  Future<void> _openChat() async {
    final profile = widget.profile;
    setState(() => _actionLoading = true);
    try {
      final chatService = ChatService();
      final chatId = await chatService.createChat(profile.uid);
      if (mounted) context.push('/chat/$chatId', extra: profile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open chat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
