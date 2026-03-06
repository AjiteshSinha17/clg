import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/theme_provider.dart';

import '../../config/theme.dart';
import '../../models/chat_media.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/chat_service.dart';
import '../../services/download_service.dart';
import '../../services/storage_service.dart';
import '../../utils/read_file_bytes.dart';
import '../../utils/timestamp_utils.dart';
import '../../widgets/full_screen_image_viewer.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final User otherUser;

  const ChatScreen({super.key, required this.chatId, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();
  final ScrollController _scrollController = ScrollController();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _chatService.markChatRead(widget.chatId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    try {
      await _chatService.sendMessage(widget.chatId, content);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
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
      final url = await _storageService.uploadChatImage(
        widget.chatId,
        auth.FirebaseAuth.instance.currentUser!.uid,
        bytes,
        fileName: file.name,
      );
      await _chatService.sendMediaMessage(
        widget.chatId,
        'image',
        url,
        fileName: file.name,
      );
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

  // Modified: Added path-based and stream-based fallbacks for reading PDF bytes
  // This fixes the "Could not read file" error on Android
  Future<Uint8List?> _readStreamToBytes(Stream<List<int>> stream) async {
    try {
      final builder = BytesBuilder();
      await for (final chunk in stream) {
        builder.add(chunk);
      }
      return builder.toBytes();
    } catch (e) {
      debugPrint('[ChatScreen] _readStreamToBytes error: $e');
      return null;
    }
  }

  Future<void> _pickAndSendPdf() async {
    try {
      // First attempt: pick with withData (loads bytes into memory)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        withReadStream: true, // Also request read stream as fallback
      );
      if (result == null || result.files.isEmpty || !mounted) return;

      final platformFile = result.files.single;
      final uriOrPath = platformFile.path ?? platformFile.identifier;
      debugPrint(
        '[ChatScreen] PDF picked: name=${platformFile.name}, '
        'size=${platformFile.size}, '
        'path=${platformFile.path}, '
        'identifier=${platformFile.identifier}, '
        'hasBytes=${platformFile.bytes != null}, '
        'hasStream=${platformFile.readStream != null}',
      );

      Uint8List? bytes;

      // Strategy 1: Direct bytes from picker (withData: true)
      if (platformFile.bytes != null && platformFile.bytes!.isNotEmpty) {
        bytes = platformFile.bytes;
        debugPrint(
          '[ChatScreen] Got bytes directly from picker: ${bytes!.length} bytes',
        );
      }

      // Strategy 2: Read from path/URI (Android can return content:// via identifier)
      if (bytes == null && uriOrPath != null && uriOrPath.isNotEmpty) {
        debugPrint('[ChatScreen] Trying to read from path/uri: $uriOrPath');
        bytes = await readFileBytes(uriOrPath);
        if (bytes != null) {
          debugPrint(
            '[ChatScreen] Got bytes from file path: ${bytes.length} bytes',
          );
        } else {
          debugPrint(
            '[ChatScreen] readFileBytes returned null for path/uri: $uriOrPath',
          );
        }
      }

      // Strategy 3: Read from stream (withReadStream: true)
      if (bytes == null && platformFile.readStream != null) {
        debugPrint('[ChatScreen] Trying to read from stream...');
        bytes = await _readStreamToBytes(platformFile.readStream!);
        if (bytes != null) {
          debugPrint(
            '[ChatScreen] Got bytes from stream: ${bytes.length} bytes',
          );
        } else {
          debugPrint('[ChatScreen] _readStreamToBytes returned null');
        }
      }

      // Strategy 4: If all above failed, try picking again without withData
      // (some Android devices need a clean pick without memory loading)
      if (bytes == null) {
        debugPrint(
          '[ChatScreen] All strategies failed. Trying re-pick with path only...',
        );
        final retryResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          withData: false,
          withReadStream: true,
        );
        if (retryResult != null && retryResult.files.isNotEmpty) {
          final retryFile = retryResult.files.single;
          final retryUriOrPath = retryFile.path ?? retryFile.identifier;
          if (retryUriOrPath != null) {
            bytes = await readFileBytes(retryUriOrPath);
            debugPrint(
              '[ChatScreen] Retry path/uri read: ${bytes != null ? "${bytes.length} bytes" : "null"}',
            );
          }
          if (bytes == null && retryFile.readStream != null) {
            debugPrint('[ChatScreen] Retry stream read...');
            bytes = await _readStreamToBytes(retryFile.readStream!);
            debugPrint(
              '[ChatScreen] Retry stream read: ${bytes != null ? "${bytes.length} bytes" : "null"}',
            );
          }
        }
      }

      if (bytes == null || bytes.isEmpty) {
        debugPrint('[ChatScreen] ERROR: All PDF read strategies failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read file. Please try a different PDF.'),
            ),
          );
        }
        return;
      }

      setState(() => _uploading = true);
      final url = await _storageService.uploadChatPdf(
        widget.chatId,
        auth.FirebaseAuth.instance.currentUser!.uid,
        bytes,
        fileName: platformFile.name,
      );
      await _chatService.sendMediaMessage(
        widget.chatId,
        'pdf',
        url,
        fileName: platformFile.name,
      );
      _scrollToBottom();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PDF sent')));
      }
    } catch (e) {
      debugPrint('[ChatScreen] PDF upload error: $e');
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
                'Downloads',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ChatMedia>>(
                stream: _chatService.getMediaStream(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('No files shared in this chat yet'),
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
                        // Modified: Use download service instead of url_launcher
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

  // Modified: Download file using DownloadService instead of just opening URL
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
    final normalizedUrl = DownloadService.normalizeCloudinaryPdfUrl(url);
    final uri = Uri.parse(normalizedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  // Modified: Open image in full-screen viewer instead of url_launcher
  void _openImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
    // Added: Theme-aware wallpaper background
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final bgImage = isDark
        ? 'assets/images/chat_dark_wallpaper.png'
        : 'assets/images/chat_light_wallpaper.png';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.otherUser.avatarUrl)
                  : null,
              child: widget.otherUser.avatarUrl.isEmpty
                  ? Text(
                      widget.otherUser.name.isNotEmpty
                          ? widget.otherUser.name[0].toUpperCase()
                          : '?',
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.otherUser.name)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showDownloads,
            tooltip: 'Downloads',
          ),
        ],
      ),
      // Modified: Wrapped body in Stack with wallpaper background
      body: Stack(
        children: [
          // Wallpaper background image
          Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
          // Subtle overlay to ensure text/bubbles remain readable
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            ),
          ),
          // Chat content on top of wallpaper
          Column(
            children: [
              if (_uploading) const LinearProgressIndicator(),
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _chatService.getMessagesStream(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet. Say hi!',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;
                        return _MessageBubble(
                          message: message,
                          isMe: isMe,
                          onOpenUrl: _openUrl,
                          onOpenImage: _openImage,
                          onDownloadFile: _downloadFile,
                        );
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
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
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _uploading ? null : _sendMessage,
              mini: true,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

// Modified: Added onOpenImage and onDownloadFile callbacks, updated timestamp formatting
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Future<void> Function(String) onOpenUrl;
  final void Function(String) onOpenImage;
  final Future<void> Function(String url, String fileName) onDownloadFile;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onOpenUrl,
    required this.onOpenImage,
    required this.onDownloadFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modified: Image tap now opens in full-screen viewer instead of url_launcher
            if (message.type == MessageType.image && message.fileUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                  // Added: Download button for images
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.download,
                        size: 20,
                        color: isMe
                            ? Colors.white70
                            : theme.colorScheme.primary,
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
                      Icons.picture_as_pdf,
                      color: isMe ? Colors.white : theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.fileName ?? 'document.pdf',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isMe
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Modified: Download button for PDFs (replaces open_in_new icon)
                    IconButton(
                      icon: Icon(
                        Icons.download,
                        size: 18,
                        color: isMe
                            ? Colors.white70
                            : theme.colorScheme.primary,
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isMe
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            const SizedBox(height: 4),
            // Modified: Use shared timestamp formatting, aligned to bottom right
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formatMessageTimestamp(message.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white70
                      : theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
