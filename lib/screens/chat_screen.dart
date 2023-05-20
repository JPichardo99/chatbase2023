import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbase/api/apis.dart';
import 'package:chatbase/constants.dart';
import 'package:chatbase/helper/my_date_util.dart';
import 'package:chatbase/models/chatUser_model.dart';
import 'package:chatbase/models/message_model.dart';
import 'package:chatbase/screens/view_user_profile.dart';
import 'package:chatbase/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  final _textController = TextEditingController();
  bool _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: APIs.getAllMessages(widget.user),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const SizedBox();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = data
                            ?.map((e) => MessageModel.fromJson(e.data()))
                            .toList() ??
                        [];
                    if (_list.isNotEmpty) {
                      return ListView.builder(
                          reverse: true,
                          itemCount: _list.length,
                          padding:
                              const EdgeInsets.only(top: defaultPadding * 0.4),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (contex, index) {
                            return MessageCard(message: _list[index]);
                          });
                    } else {
                      return const Center(
                          child: Text(
                        'Comienza a chatear 😁',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ));
                    }
                }
              },
            ),
          ),
          //
          if (_isUploading)
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          //
          _chatInput(),
          // emojiPicker
        ],
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ViewUserProfile(user: widget.user)));
          },
          child: Container(
            child: StreamBuilder(
                stream: APIs.getUserInfo(widget.user),
                builder: ((context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];
                  return Row(children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                          imageUrl: list.isNotEmpty
                              ? list[0].image
                              : widget.user.image,
                          width: 40,
                          height: 40,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                child: CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                              )),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.isNotEmpty ? list[0].name : widget.user.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          /*list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'En linea'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),*/
                          list.isNotEmpty && list[0].isOnline
                              ? 'En linea'
                              : 'Desconectado',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ]);
                })),
          )),
    );
  }
  //

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        filled: false,
                        hintText: 'Escribe un mensaje',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var image in images) {
                          setState(() => _isUploading = true);
                          APIs.sendChatImage(widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.image, size: 20)),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 20)),
                ],
              ),
            ),
          ),
          MaterialButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    APIs.sendFirstMessage(
                        widget.user, _textController.text, Type.text);
                  } else {
                    APIs.sendMessage(
                        widget.user, _textController.text, Type.text);
                  }
                  _textController.clear();
                }
              },
              minWidth: 0,
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
              shape: const CircleBorder(),
              color: Colors.green,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 25,
              ))
        ],
      ),
    );
  }
}
