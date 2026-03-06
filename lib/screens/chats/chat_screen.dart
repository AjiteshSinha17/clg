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
      // ── AppBar ────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.pureWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.orange.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.darkCard,
                      backgroundImage: widget.otherUser.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.otherUser.avatarUrl)
                                as ImageProvider
                          : null,
                      child: widget.otherUser.avatarUrl.isEmpty
                          ? Text(
                              widget.otherUser.name.isNotEmpty
                                  ? widget.otherUser.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.otherUser.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.orange.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Downloads action
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.folder_open_rounded,
                        color: AppTheme.orange,
                        size: 18,
                      ),
                    ),
                    onPressed: _showDownloads,
                    tooltip: 'Downloads',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ── Body ──────────────────────────────────────────────────────────
      body: Stack(
        children: [
          // Wallpaper background image
          Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
          // Overlay
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          // Chat content
          Column(
            children: [
              if (_uploading)
                LinearProgressIndicator(
                  backgroundColor: AppTheme.orange.withValues(alpha: 0.15),
                  color: AppTheme.orange,
                ),
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _chatService.getMessagesStream(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.orange,
                          strokeWidth: 2.5,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: \${snapshot.error}'));
                    }
                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkCard.withValues(alpha: 0.8)
                                    : AppTheme.pureWhite.withValues(
                                        alpha: 0.85,
                                      ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: isDark
                                    ? AppTheme.clayShadowRecvDark
                                    : AppTheme.clayShadowRecvLight,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 48,
                                    color: AppTheme.orange.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Say hi to \${widget.otherUser.name}!',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attach button
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: AppTheme.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _uploading ? null : _showAttachOptions,
                    borderRadius: BorderRadius.circular(14),
                    splashColor: AppTheme.orange.withValues(alpha: 0.2),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.attach_file_rounded,
                        color: AppTheme.orange,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Text field (clay pill)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.07),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.07,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.35),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button (clay circle)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: _uploading ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.orangeLight, AppTheme.orangeDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.orangeDark.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.10),
                          blurRadius: 2,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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

    final isDark = theme.brightness == Brightness.dark;
    final recvBg = isDark ? AppTheme.darkCard : AppTheme.pureWhite;
    final recvBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1)
        : Border.all(color: Colors.black.withValues(alpha: 0.07), width: 1);

    final sentShadows = AppTheme.clayShadowSent;
    final recvShadows = isDark
        ? AppTheme.clayShadowRecvDark
        : AppTheme.clayShadowRecvLight;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: isMe ? const Radius.circular(22) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(22),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 48 : 12,
          right: isMe ? 12 : 48,
          top: 4,
          bottom: 4,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [AppTheme.orangeLight, AppTheme.orangeDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMe ? null : recvBg,
          borderRadius: radius,
          border: isMe ? null : recvBorder,
          boxShadow: isMe ? sentShadows : recvShadows,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (message.type == MessageType.image && message.fileUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
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
                          color: isMe ? Colors.white70 : AppTheme.orange,
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
              // PDF
              else if (message.type == MessageType.pdf &&
                  message.fileUrl != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppTheme.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => onOpenUrl(message.fileUrl!),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.2)
                                : AppTheme.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: isMe ? Colors.white : AppTheme.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            message.fileName ?? 'document.pdf',
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.87)
                                        : const Color(0xFF1A1A1A)),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.download_rounded,
                            size: 18,
                            color: isMe ? Colors.white70 : AppTheme.orange,
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
                  ),
                )
              // Text
              else
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.87)
                              : const Color(0xFF1A1A1A)),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  formatMessageTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.65)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.40)
                              : Colors.black.withValues(alpha: 0.38)),
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
