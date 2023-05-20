import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbase/components/background.dart';
import 'package:chatbase/constants.dart';
import 'package:chatbase/helper/my_date_util.dart';
import 'package:chatbase/models/chatUser_model.dart';
import 'package:chatbase/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

class ViewUserProfile extends StatefulWidget {
  final ChatUser user;
  ViewUserProfile({super.key, required this.user});

  @override
  State<ViewUserProfile> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<ViewUserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(widget.user.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontFamily: 'Poppins'))),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // for adding some space
                const SizedBox(width: 50, height: 30),

                //user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: InstaImageViewer(
                    child: CachedNetworkImage(
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sobre mi: ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      widget.user.about,
                      style: const TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
