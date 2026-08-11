import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../models/post.dart';
import '../../../models/comment.dart';
import '../../../state/auth_provider.dart';
import '../../../state/theme_provider.dart';
import '../../../config/theme.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) throw Exception('User not logged in');

      final comment = Comment(
        id: '',
        postId: widget.post.id,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userAvatarUrl: user.photoURL ?? '',
        content: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('comments')
          .add(comment.toFirestore());

      _commentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Comment posted!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Post Details',
          style: TextStyle(
            color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: context.canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Content Glass Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.liquidGlassDecoration(
                        isDark: isDark,
                        radius: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isDark
                                    ? AppTheme.darkContainer
                                    : const Color(0xFFE6F5F3),
                                backgroundImage:
                                    widget.post.userAvatarUrl.isNotEmpty
                                    ? NetworkImage(widget.post.userAvatarUrl)
                                    : null,
                                child: widget.post.userAvatarUrl.isEmpty
                                    ? Icon(
                                        Icons.person_rounded,
                                        color: primaryColor,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.post.userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark
                                            ? AppTheme.darkOnSurface
                                            : AppTheme.lightOnSurface,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(widget.post.timestamp),
                                      style: TextStyle(
                                        color: isDark
                                            ? AppTheme.darkOnSurfaceVariant
                                            : AppTheme.lightOnSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.post.content,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: isDark
                                  ? AppTheme.darkOnSurface
                                  : AppTheme.lightOnSurface,
                            ),
                          ),
                          if (widget.post.imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                widget.post.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 18,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.post.likes}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.darkOnSurface
                                      : AppTheme.lightOnSurface,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Icon(
                                Icons.comment_outlined,
                                size: 18,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.post.comments}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.darkOnSurface
                                      : AppTheme.lightOnSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Comments Header
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.darkOnSurface
                              : AppTheme.lightOnSurface,
                        ),
                      ),
                    ),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('comments')
                          .where('postId', isEqualTo: widget.post.id)
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading comments',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.lightOnSurface,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(color: primaryColor),
                          );
                        }

                        final comments = snapshot.data!.docs
                            .map((doc) => Comment.fromFirestore(doc))
                            .toList();

                        if (comments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No comments yet. Be the first!',
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.darkOnSurfaceVariant
                                      : AppTheme.lightOnSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return _buildCommentItem(comment, isDark, primaryColor);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Comment Input Glass Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurface
                    : Colors.white.withValues(alpha: 0.95),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkContainerHigh : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.goldenBorder.withValues(alpha: 0.2)
                              : const Color(0xFF18D8D0).withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppTheme.softBeige
                              : AppTheme.lightOnSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share with community...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.darkOnSurfaceVariant
                                : AppTheme.lightOnSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSubmitting ? null : _submitComment,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkAquaticBg : primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppTheme.goldenBorder : Colors.transparent,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppTheme.goldenBorder : AppTheme.aquaGlow)
                                .withValues(alpha: isDark ? 0.35 : 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isSubmitting
                          ? Padding(
                              padding: const EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? AppTheme.softBeige : Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: isDark ? AppTheme.softBeige : Colors.white,
                              size: 18,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.liquidGlassDecoration(
        isDark: isDark,
        radius: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDark
                ? AppTheme.darkContainer
                : const Color(0xFFE6F5F3),
            backgroundImage: comment.userAvatarUrl.isNotEmpty
                ? NetworkImage(comment.userAvatarUrl)
                : null,
            child: comment.userAvatarUrl.isEmpty
                ? Icon(Icons.person_rounded, size: 16, color: primaryColor)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(comment.timestamp),
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkOnSurfaceVariant
                        : AppTheme.lightOnSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
