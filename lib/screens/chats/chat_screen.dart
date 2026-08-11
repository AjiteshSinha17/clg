import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
          decoration: const InputDecoration(
            hintText: 'Enter new content',
          ),
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
                Navigator.pop(context);
                try {
                  await _chatService.editMessage(
                    widget.chatId,
                    message.id,
                    newContent,
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to edit message: $e')),
                    );
                  }
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
          'This message will be deleted for everyone in this chat.',
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
              Navigator.pop(context);
              try {
                await _chatService.deleteMessageForEveryone(
                  widget.chatId,
                  message.id,
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete message: $e')),
                  );
                }
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.surfaceContainer,
                      backgroundImage: widget.otherUser.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.otherUser.avatarUrl)
                              as ImageProvider
                          : null,
                      child: widget.otherUser.avatarUrl.isEmpty
                          ? Text(
                              widget.otherUser.name.isNotEmpty
                                  ? widget.otherUser.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.otherUser.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.folder_open_rounded,
                        color: colorScheme.primary,
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
      body: Column(
        children: [
          if (_uploading)
            LinearProgressIndicator(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
              color: colorScheme.primary,
            ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 2.5,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: colorScheme.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Say hi to ${widget.otherUser.name}!',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
                      onLongPress: () => _showMessageOptions(message),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface
            : colorScheme.surfaceContainer,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Attachment Button
            GestureDetector(
              onTap: _uploading ? null : _showAttachOptions,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkAquaticBg : colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.goldenBorder : colorScheme.primary,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.attach_file_rounded,
                  color: isDark ? AppTheme.softBeige : colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Text Field Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkContainerHigh : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.goldenBorder.withValues(alpha: 0.2)
                        : colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppTheme.darkOnSurfaceVariant
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.softBeige : colorScheme.onSurface,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send Button
            GestureDetector(
              onTap: _uploading ? null : _sendMessage,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkAquaticBg : colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.goldenBorder : Colors.transparent,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.goldenBorder : colorScheme.primary)
                          .withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: isDark ? AppTheme.softBeige : colorScheme.onPrimary,
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

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Future<void> Function(String) onOpenUrl;
  final void Function(String) onOpenImage;
  final Future<void> Function(String url, String fileName) onDownloadFile;
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onOpenUrl,
    required this.onOpenImage,
    required this.onDownloadFile,
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

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
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
            color: bubbleColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  // Image
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
                  // PDF
                  else if (message.type == MessageType.pdf &&
                      message.fileUrl != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () => onOpenUrl(message.fileUrl!),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              color: textColor,
                              size: 22,
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
                            const SizedBox(width: 4),
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
                      ),
                    )
                  // Text
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
                    if (message.isEdited && !message.isDeleted) ...[
                      Text(
                        '(edited) ',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: textColor.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
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
        ),
      ),
    );
  }
}
