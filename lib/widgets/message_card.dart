import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbase/api/apis.dart';
import 'package:chatbase/helper/my_date_util.dart';
import 'package:chatbase/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

class MessageCard extends StatefulWidget {
  MessageCard({super.key, required this.message});

  final MessageModel message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _ahowBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  // sender or another user message
  Widget _blueMessage() {
    // read status
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding:
                EdgeInsets.all(widget.message.type == Type.image ? 10 : 15),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(134, 99, 181, 248),
              border: Border.all(
                color: const Color.fromARGB(181, 29, 153, 255),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Popins',
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InstaImageViewer(
                      child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                ),
                              ),
                          errorWidget: (context, url, error) => const Icon(
                                Icons.image,
                                size: 70,
                              )),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            MyDateUtil.getFormattedDate(
                context: context, time: widget.message.sent),
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Popins',
            ),
          ),
        ),
      ],
    );
  }

  // our user nessage
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(
              width: 2,
            ),
            Text(
              MyDateUtil.getFormattedDate(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Popins',
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding:
                EdgeInsets.all(widget.message.type == Type.image ? 10 : 15),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(133, 99, 248, 136),
              border: Border.all(
                color: const Color.fromARGB(181, 29, 255, 123),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Popins',
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InstaImageViewer(
                      child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                ),
                              ),
                          errorWidget: (context, url, error) => const Icon(
                                Icons.image,
                                size: 70,
                              )),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _ahowBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              widget.message.type == Type.text
                  ? // copiar texto
                  _OptionItem(
                      icon: const Icon(
                        Icons.copy_all_outlined,
                        color: Colors.blue,
                        size: 18,
                      ),
                      name: 'Copiar texto',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 250), () {
                            AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.success,
                                    headerAnimationLoop: false,
                                    animType: AnimType.topSlide,
                                    title: 'Texto copiado',
                                    desc: 'El texto fue copiado con éxito',
                                    btnOkOnPress: () {})
                                .show();
                          });
                        });
                      })
                  : // copiar texto
                  _OptionItem(
                      icon: const Icon(
                        Icons.download_outlined,
                        color: Colors.blue,
                        size: 18,
                      ),
                      name: 'Descargar imagen',
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'Chatbase')
                              .then((success) {
                            Navigator.pop(context);
                            if (success != null && success) {
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.success,
                                        headerAnimationLoop: false,
                                        animType: AnimType.topSlide,
                                        title: 'Imagen descargada',
                                        desc:
                                            'La imagen fue descargada con éxito',
                                        btnOkOnPress: () {})
                                    .show();
                              });
                            }
                          });
                        } catch (e) {
                          log('Error al descargar imagen: $e');
                        }
                      }),

              const Divider(
                endIndent: 20,
                indent: 20,
              ),

              if (widget.message.type == Type.text && isMe)
                // editar mensaje
                _OptionItem(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: 18,
                    ),
                    name: 'Editar mensaje',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessageUpdateDialog();
                    }),

              // eliminar mensaje
              if (isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                      size: 18,
                    ),
                    name: 'Eliminar mensaje',
                    onTap: () async {
                      try {
                        Navigator.pop(context);
                        await APIs.deleteMessage(widget.message);
                      } catch (error) {
                        // Manejar cualquier error que ocurra durante la eliminación del mensaje
                        print('Error al eliminar el mensaje: $error');
                      }
                    }),
              //  sent time
            ],
          );
        });
  }

  // for edit message
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.message,
                    size: 20,
                  ),
                  Text(' Actualizar mensaje',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Popins',
                      ))
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Popins',
                    fontWeight: FontWeight.w400),
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Popins',
                          fontWeight: FontWeight.w300),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      APIs.updateMessage(widget.message, updatedMsg);
                    },
                    child: const Text(
                      'Atualizar',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Popins',
                          fontWeight: FontWeight.w300),
                    ))
              ],
            ));
  }
}

// for options to long press
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 15, bottom: 20),
          child: Row(
            children: [
              icon,
              Flexible(
                  child: Text('    $name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Popins',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      )))
            ],
          ),
        ));
  }
}
