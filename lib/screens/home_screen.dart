import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chatbase/api/apis.dart';
import 'package:chatbase/constants.dart';
import 'package:chatbase/models/chatUser_model.dart';
import 'package:chatbase/screens/settings/settings_screen.dart';
import 'package:chatbase/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    APIs.getSelInfo();

    // for active status user
    // resume => active
    // pause => inactive
    // setting active status
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
          onWillPop: () {
            if (_isSearching) {
              setState(() {
                _isSearching = !_isSearching;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
              appBar: AppBar(
                leading: const Icon(CupertinoIcons.home),
                title: _isSearching
                    ? TextField(
                        decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            hintText: 'Nombre, Email, ...',
                            hintStyle: TextStyle(color: Colors.white)),
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 0.5,
                            color: Colors.white),
                        onChanged: (val) {
                          _searchList.clear();
                          for (var i in _list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(val.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
                              _searchList.add(i);
                              setState(() {
                                _searchList;
                              });
                            }
                          }
                        },
                      )
                    : const Text('Chatbase'),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                      icon: Icon(_isSearching
                          ? CupertinoIcons.clear_circled_solid
                          : Icons.search)),
                  IconButton(
                    onPressed: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SettingsScreen(user: APIs.me)));
                    }),
                    icon: const Icon(Icons.more_vert),
                  )
                ],
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: FloatingActionButton(
                  onPressed: (() {
                    _addChatUserDialog();
                  }),
                  child: const Icon(Icons.add_comment_rounded),
                ),
              ),
              body: StreamBuilder(
                  stream: APIs.getMyUsersId(),
                  builder: ((context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        return StreamBuilder(
                          stream: APIs.getAllUsers(
                              snapshot.data?.docs.map((e) => e.id).toList() ??
                                  []),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                              //return const Center(child: Text('😔😔😔😔'));
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                _list = data
                                        ?.map(
                                            (e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                    [];
                                if (_list.isNotEmpty) {
                                  return ListView.builder(
                                      itemCount: _isSearching
                                          ? _searchList.length
                                          : _list.length,
                                      padding: const EdgeInsets.only(
                                          top: defaultPadding * 0.4),
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (contex, index) {
                                        return ChatUserCard(
                                            user: _isSearching
                                                ? _searchList[index]
                                                : _list[index]);
                                        //return Text('Name: ${_list[index]}');
                                      });
                                } else {
                                  return const Center(
                                      child: Text(
                                    'Comienza a chatear con Chatbase 😁',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                    ),
                                  ));
                                }
                            }
                          },
                        );
                    }
                  })))),
    );
  }

  // add new message
  void _addChatUserDialog() {
    String email = '';

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
                    Icons.person_add_alt_1_outlined,
                    size: 20,
                  ),
                  Text(' Añadir contacto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Popins',
                      ))
                ],
              ),

              //content
              content: TextFormField(
                style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Popins',
                    fontWeight: FontWeight.w400),
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Ingresa el email',
                    prefixIcon: const Icon(Icons.email_outlined),
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

                //add button
                MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    headerAnimationLoop: false,
                                    animType: AnimType.topSlide,
                                    title: 'Error',
                                    desc: 'El usuario o el correo no existe',
                                    btnOkOnPress: () {})
                                .show();
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Añadir',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Popins',
                          fontWeight: FontWeight.w300),
                    ))
              ],
            ));
  }
}
