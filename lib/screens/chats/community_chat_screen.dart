import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/chat_media.dart';
import '../../models/message.dart';
import '../../services/community_chat_service.dart';
import '../../services/storage_service.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickAndSendPdf() async {
    final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf'],
  withData: true,   // REQUIRED
);
    if (result == null || result.files.isEmpty || !mounted) return;

    final platformFile = result.files.single;
    final bytes = platformFile.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
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
                          media.type == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                          color: AppTheme.paletteViolet,
                        ),
                        title: Text(media.fileName),
                        subtitle: Text(media.senderName),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _openUrl(media.fileUrl),
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(child: Text('Please login to view community chat'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showDownloads,
            tooltip: 'Downloads',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_uploading) const LinearProgressIndicator(),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _service.getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = m.senderId == currentUserId;
                    return _CommunityBubble(
                      message: m,
                      isMe: isMe,
                      onOpenUrl: _openUrl,
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _uploading ? null : _showAttachOptions,
              tooltip: 'Attach image or PDF',
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Message the community…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _uploading ? null : _send,
              mini: true,
              backgroundColor: AppTheme.mountainOrange,
              child: const Icon(Icons.send, color: Colors.white),
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

  const _CommunityBubble({
    required this.message,
    required this.isMe,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.mountainOrange : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            if (message.type == MessageType.image && message.fileUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onOpenUrl(message.fileUrl!),
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
              )
            else if (message.type == MessageType.pdf && message.fileUrl != null)
              InkWell(
                onTap: () => onOpenUrl(message.fileUrl!),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: isMe ? Colors.white : theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.fileName ?? 'document.pdf',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isMe ? Colors.white : theme.textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: isMe ? Colors.white70 : theme.colorScheme.primary,
                    ),
                  ],
                ),
              )
            else
              Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isMe ? Colors.white : theme.textTheme.bodyMedium?.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
