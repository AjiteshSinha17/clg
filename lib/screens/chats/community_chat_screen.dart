import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/chat_media.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../screens/roommates/roommate_detail_screen.dart';
import '../../services/community_chat_service.dart';
import '../../services/download_service.dart';
import '../../services/storage_service.dart';
import '../../utils/read_file_bytes.dart';
import '../../utils/timestamp_utils.dart';
import '../../widgets/full_screen_image_viewer.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({super.key});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CommunityChatService _service = CommunityChatService();
  final StorageService _storageService = StorageService();
  bool _uploading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    _messageController.clear();
    try {
      await _service.sendMessage(content);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<Uint8List?> _readStreamToBytes(Stream<List<int>> stream) async {
    try {
      final builder = BytesBuilder();
      await for (final chunk in stream) {
        builder.add(chunk);
      }
      return builder.toBytes();
    } catch (_) {
      return null;
    }
  }

  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded),
              title: const Text('Downloaded Documents'),
              onTap: () {
                Navigator.pop(context);
                _showDownloads();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await _storageService.uploadCommunityChatImage(
        CommunityChatService.globalRoomId,
        auth.FirebaseAuth.instance.currentUser!.uid,
        bytes,
        fileName: file.name,
      );
      await _service.sendMediaMessage('image', url, fileName: file.name);
      _scrollToBottom();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickAndSendPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null) return;

    final platformFile = result.files.single;
    Uint8List? bytes = platformFile.bytes;
    if (bytes == null && platformFile.path != null) {
      bytes = await readFileBytes(platformFile.path);
    }
    if (bytes == null && platformFile.readStream != null) {
      bytes = await _readStreamToBytes(platformFile.readStream!);
    }
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not read file')));
      }
      return;
    }

    setState(() => _uploading = true);
    try {
      final url = await _storageService.uploadCommunityChatPdf(
        CommunityChatService.globalRoomId,
        auth.FirebaseAuth.instance.currentUser!.uid,
        bytes,
        fileName: platformFile.name,
      );
      await _service.sendMediaMessage('pdf', url, fileName: platformFile.name);
      _scrollToBottom();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PDF sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showDownloads() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Community downloads',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ChatMedia>>(
                stream: _service.getMediaStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('No files shared in community yet'),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final media = list[index];
                      return ListTile(
                        leading: Icon(
                          media.type == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          color: AppTheme.paletteViolet,
                        ),
                        title: Text(media.fileName),
                        subtitle: Text(media.senderName),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () =>
                              _downloadFile(media.fileUrl, media.fileName),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url, String fileName) async {
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid file URL')));
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Downloading...')));
    }

    final success = await DownloadService().downloadAndOpenFile(url, fileName);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download file. Please try again.'),
        ),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  void _openImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _openUserProfile(String userId) async {
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || !mounted) return;

    if (userId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is you. Open your profile tab to edit.'),
        ),
      );
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User profile not found')));
        return;
      }
      final user = User.fromFirestore(doc);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RoommateDetailScreen(profile: user)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showMessageOptions(Message message) {
    if (message.isDeleted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == MessageType.text)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit message'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditMessageDialog(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              title: const Text(
                'Delete for everyone',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteMessageConfirm(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMessageDialog(Message message) {
    final editController = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new content'),
          minLines: 1,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty && newContent != message.content) {
                final navContext = Navigator.of(context);
                final scaffoldContext = ScaffoldMessenger.of(context);
                navContext.pop();
                try {
                  await _service.editMessage(message.id, newContent);
                } catch (e) {
                  scaffoldContext.showSnackBar(
                    SnackBar(content: Text('Failed to edit message: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessageConfirm(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete for everyone?'),
        content: const Text(
          'This message will be deleted for everyone in community chat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final navContext = Navigator.of(context);
              final scaffoldContext = ScaffoldMessenger.of(context);
              navContext.pop();
              try {
                await _service.deleteMessageForEveryone(message.id);
              } catch (e) {
                scaffoldContext.showSnackBar(
                  SnackBar(content: Text('Failed to delete message: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
    final colorScheme = Theme.of(context).colorScheme;
    if (currentUserId == null) {
      return const Center(child: Text('Please login to view community chat'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (_uploading)
            LinearProgressIndicator(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
              color: colorScheme.primary,
            ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _service.getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = m.senderId == currentUserId;
                    return _CommunityBubble(
                      message: m,
                      isMe: isMe,
                      onOpenUrl: _openUrl,
                      onOpenImage: _openImage,
                      onDownloadFile: _downloadFile,
                      onTapSender: () => _openUserProfile(m.senderId),
                      onLongPress: () => _showMessageOptions(m),
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface
            : colorScheme.surfaceContainer,
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file_rounded, color: colorScheme.primary),
              onPressed: _uploading ? null : _showAttachOptions,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Share with community...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _uploading ? null : _send,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: colorScheme.onPrimary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Future<void> Function(String) onOpenUrl;
  final void Function(String) onOpenImage;
  final Future<void> Function(String url, String fileName) onDownloadFile;
  final VoidCallback? onTapSender;
  final VoidCallback onLongPress;

  const _CommunityBubble({
    required this.message,
    required this.isMe,
    required this.onOpenUrl,
    required this.onOpenImage,
    required this.onDownloadFile,
    this.onTapSender,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? (isDark ? colorScheme.primaryContainer : colorScheme.primary)
        : colorScheme.surfaceContainerHigh;

    final textColor = isMe
        ? (isDark ? colorScheme.onPrimaryContainer : colorScheme.onPrimary)
        : colorScheme.onSurface;

    final bubble = GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              InkWell(
                onTap: onTapSender,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                      backgroundImage: message.senderAvatarUrl.isNotEmpty
                          ? NetworkImage(message.senderAvatarUrl)
                          : null,
                      child: message.senderAvatarUrl.isEmpty
                          ? Text(
                              message.senderName.isNotEmpty
                                  ? message.senderName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            if (message.isDeleted)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block_rounded,
                    size: 14,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'This message was deleted',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )
            else ...[
              if (message.type == MessageType.image && message.fileUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => onOpenImage(message.fileUrl!),
                        child: Image.network(
                          message.fileUrl!,
                          width: 220,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 220,
                            height: 120,
                            child: Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        onPressed: () => onDownloadFile(
                          message.fileUrl!,
                          message.fileName ?? 'image.jpg',
                        ),
                        tooltip: 'Download image',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                )
              else if (message.type == MessageType.pdf && message.fileUrl != null)
                InkWell(
                  onTap: () => onOpenUrl(message.fileUrl!),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.picture_as_pdf_rounded,
                        color: textColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message.fileName ?? 'document.pdf',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        onPressed: () => onDownloadFile(
                          message.fileUrl!,
                          message.fileName ?? 'document.pdf',
                        ),
                        tooltip: 'Download PDF',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  message.content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (message.isEdited && !message.isDeleted)
                  Text(
                    '(edited) ',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: textColor.withValues(alpha: 0.55),
                    ),
                  ),
                Text(
                  formatMessageTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }
}
