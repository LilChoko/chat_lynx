import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDetailScreen extends StatelessWidget {
  final String chatId;

  ChatDetailScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2545),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('chats').doc(chatId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text(
                'Cargando...',
                style: TextStyle(color: Colors.white),
              );
            }
            final chatData = snapshot.data!.data() as Map<String, dynamic>;
            final participants = List<String>.from(chatData['participants']);
            final otherUserId =
                participants.firstWhere((id) => id != currentUserId);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Text(
                    'Cargando...',
                    style: TextStyle(color: Colors.white),
                  );
                }
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final otherUserName = userData['name'] ?? 'Usuario';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'En línea ahora',
                      style: TextStyle(
                        color: Colors.green[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call, color: Colors.white),
            onPressed: () {
              // Acción futura para videollamada
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('chatId', isEqualTo: chatId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar mensajes',
                      style: TextStyle(color: Color(0xFF8A8D91)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay mensajes aún',
                      style: TextStyle(color: Color(0xFF8A8D91)),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>?;
                    final isMe = data?['senderId'] == currentUserId;
                    final fileUrl = data?['fileUrl'];
                    final fileType = data != null && fileUrl != null
                        ? (data['fileType'] ?? 'image')
                        : null;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        padding: fileUrl == null
                            ? EdgeInsets.all(10)
                            : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF0B2545) : Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isMe ? 10 : 0),
                            topRight: Radius.circular(isMe ? 0 : 10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: fileUrl != null
                            ? fileType == 'image'
                                ? _buildImage(fileUrl, context)
                                : fileType == 'video'
                                    ? _buildVideoPlayer(fileUrl)
                                    : Text('Archivo enviado')
                            : Text(
                                data?['text'] ?? '',
                                style: TextStyle(
                                  color:
                                      isMe ? Colors.white : Color(0xFF0B2545),
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildImage(String fileUrl, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(fileUrl: fileUrl),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          fileUrl,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String fileUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: VideoPlayerWidget(fileUrl: fileUrl),
    );
  }

  Future<File?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<String?> _uploadToSupabase(File file, String chatId) async {
    try {
      final fileName =
          'chat_files/$chatId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      await Supabase.instance.client.storage
          .from('chat_files')
          .upload(fileName, file);

      final publicUrl = Supabase.instance.client.storage
          .from('chat_files')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error al subir archivo: $e');
      return null;
    }
  }

  Widget _buildMessageInput(BuildContext context) {
    final _messageController = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Color(0xFF0B2545)),
            onPressed: () async {
              final file = await _pickFile();
              if (file == null) return;

              final fileUrl = await _uploadToSupabase(file, chatId);
              if (fileUrl != null) {
                await FirebaseFirestore.instance.collection('messages').add({
                  'chatId': chatId,
                  'senderId': FirebaseAuth.instance.currentUser!.uid,
                  'fileUrl': fileUrl,
                  'fileType': file.path.endsWith('.mp4') ? 'video' : 'image',
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFF3F4F6),
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF0B2545)),
            onPressed: () async {
              final text = _messageController.text.trim();
              if (text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('messages').add({
                  'chatId': chatId,
                  'senderId': FirebaseAuth.instance.currentUser!.uid,
                  'text': text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String fileUrl;

  VideoPlayerWidget({required this.fileUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.fileUrl,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    )..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        print("Error al inicializar el video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _controller.value.hasError
          ? Center(
              child: Text(
                "Error al reproducir video",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          : _controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              : Center(child: CircularProgressIndicator()),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String fileUrl;

  FullScreenImage({required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Image.network(fileUrl),
      ),
    );
  }
}
