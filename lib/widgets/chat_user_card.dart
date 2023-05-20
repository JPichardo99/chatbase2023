import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbase/api/apis.dart';
import 'package:chatbase/constants.dart';
import 'package:chatbase/helper/my_date_util.dart';
import 'package:chatbase/models/chatUser_model.dart';
import 'package:chatbase/models/message_model.dart';
import 'package:chatbase/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  MessageModel? _message;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: defaultPadding * 0.4,
          vertical: 6,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(user: widget.user)));
            },
            child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list = data
                        ?.map((e) => MessageModel.fromJson(e.data()))
                        .toList() ??
                    [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }

                return ListTile(
                    leading: InstaImageViewer(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: CachedNetworkImage(
                            imageUrl: widget.user.image,
                            height: 50,
                            width: 50,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                              child: CircleAvatar(
                                radius: defaultPadding * 0.3,
                                child: Icon(CupertinoIcons.person),
                              ),
                            ),
                          )),
                    ),
                    title: Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? "Ha enviado una imagen 📷"
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        color: Colors.greenAccent.shade400,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  )
                                ],
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                )));
              },
            )),
      ),
    );
  }
}
