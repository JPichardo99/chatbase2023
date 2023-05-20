import 'dart:developer';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbase/api/apis.dart';
import 'package:chatbase/components/background.dart';
import 'package:chatbase/constants.dart';
import 'package:chatbase/models/chatUser_model.dart';
import 'package:chatbase/provider/provider_theme.dart';
import 'package:chatbase/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final ChatUser user;
  SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _image;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    /*void _Logout() async {
      await APIs.auth.signOut().then((value) async {
        await GoogleSignIn().signOut().then((value) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/welcome',
            (Route<dynamic> route) => false,
          );
        });
      });
    }*/

    void _imageUpdateConfirm() {
      APIs.updateProfilePicture(File(_image!));
      Future.delayed(const Duration(milliseconds: 500), () {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                headerAnimationLoop: false,
                animType: AnimType.topSlide,
                title: 'Imagen actualizada',
                desc: 'Tu imagen de perfil ha sido actualizada',
                btnOkOnPress: () {})
            .show();
      });
    }

    void _imageGalery() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        log('image path: ${image.path}');
        setState(() {
          _image = image.path;
        });
        _imageUpdateConfirm();
      }
    }

    void _imageCamera() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (image != null) {
        log('image path: ${image.path}');
        setState(() {
          _image = image.path;
        });
        _imageUpdateConfirm();
      }
    }

    void _selectImage() {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          desc: 'Selecciona el origen',
          headerAnimationLoop: false,
          animType: AnimType.topSlide,
          title: 'Imagen de perfil',
          btnCancelText: 'Camara',
          btnCancelColor: kPrimaryColor,
          btnOkText: 'Galeria',
          btnOkColor: kPrimaryColor,
          btnCancelOnPress: () {
            _imageCamera();
          },
          btnOkOnPress: () {
            _imageGalery();
          }).show();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Configuracion')),
          actions: [
            IconButton(
              onPressed: (() {
                Provider.of<ThemeNotifier>(context, listen: false)
                    .setTheme("light");
              }),
              icon: const Icon(CupertinoIcons.sun_max_fill),
            ),
            IconButton(
              onPressed: (() {
                Provider.of<ThemeNotifier>(context, listen: false)
                    .setTheme("dark");
              }),
              icon: const Icon(Icons.nightlight_rounded),
            )
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: FloatingActionButton(
            onPressed: (() {
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  headerAnimationLoop: false,
                  animType: AnimType.topSlide,
                  title: 'Cerrar sesion',
                  desc: '¿Estas seguro que deseas cerrar sesion?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () async {
                    await APIs.updateActiveStatus(false);
                    await APIs.auth.signOut().then((value) async {
                      await GoogleSignIn().signOut().then((value) {
                        APIs.auth = FirebaseAuth.instance;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/welcome',
                          (Route<dynamic> route) => false,
                        );
                      });
                    });
                  }).show();
            }),
            child: const Icon(Icons.exit_to_app),
          ),
        ),
        body: Background(
            child: SingleChildScrollView(
          child: SafeArea(
            child: Responsive(
              desktop: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 450,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      _image != null
                                          ? CircleAvatar(
                                              radius: 50,
                                              child: Image.file(
                                                File(_image!.toString()),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 50,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      widget.user.image
                                                          .toString()),
                                            ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _selectImage();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.zero,
                                              elevation: 5,
                                            ),
                                            child: Icon(Icons.camera_alt,
                                                size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  widget.user.email,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),
                                ),
                                const SizedBox(height: 30),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onSaved: (val) => APIs.me.name = val ?? '',
                                  validator: (val) =>
                                      val != null && val.isNotEmpty
                                          ? null
                                          : 'El campo es requerido',
                                  initialValue: widget.user.name,
                                  decoration: const InputDecoration(
                                    label: Text('Nombre'),
                                    prefixIcon: Padding(
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      child: Icon(
                                        Icons.person,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onSaved: (val) => APIs.me.about = val ?? '',
                                  validator: (val) =>
                                      val != null && val.isNotEmpty
                                          ? null
                                          : 'El campo es requerido',
                                  initialValue: widget.user.about,
                                  decoration: const InputDecoration(
                                    label: Text('About'),
                                    prefixIcon: Padding(
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      child: Icon(
                                        Icons.abc_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Si el formulario es válido, continuar con el envío
                                      AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          headerAnimationLoop: false,
                                          animType: AnimType.topSlide,
                                          title: 'Actualizacion de datos',
                                          desc:
                                              '¿Estas seguro que deseas actualizar tus datos?',
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {
                                            _formKey.currentState!.save();
                                            APIs.updateUserInfo();
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 500), () {
                                              AwesomeDialog(
                                                      context: context,
                                                      dialogType:
                                                          DialogType.success,
                                                      headerAnimationLoop:
                                                          false,
                                                      animType:
                                                          AnimType.topSlide,
                                                      title:
                                                          'Datos actualizados',
                                                      desc:
                                                          'Tus datos fueron actualizados',
                                                      btnOkOnPress: () {})
                                                  .show();
                                            });
                                          }).show();
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            kPrimaryLightColor),
                                  ),
                                  child: Text("Guardar",
                                      style: TextStyle(
                                          fontFamily: 'Popins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white)),
                                ),
                                const SizedBox(height: defaultPadding),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ****************   mobile version ***************************************
              mobile: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      Spacer(),
                      Expanded(
                        flex: 8,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    _image != null
                                        ? CircleAvatar(
                                            radius: 50,
                                            backgroundImage: FileImage(
                                              File(_image!.toString()),
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 50,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    widget.user.image
                                                        .toString()),
                                          ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: SizedBox(
                                        height: 35,
                                        width: 35,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _selectImage();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.zero,
                                            elevation: 5,
                                          ),
                                          child:
                                              Icon(Icons.camera_alt, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                widget.user.email,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins'),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onSaved: (val) => APIs.me.name = val ?? '',
                                validator: (val) =>
                                    val != null && val.isNotEmpty
                                        ? null
                                        : 'El campo es requerido',
                                initialValue: widget.user.name,
                                decoration: const InputDecoration(
                                  label: Text('Nombre'),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(defaultPadding),
                                    child: Icon(
                                      Icons.person,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onSaved: (val) => APIs.me.about = val ?? '',
                                validator: (val) =>
                                    val != null && val.isNotEmpty
                                        ? null
                                        : 'El campo es requerido',
                                initialValue: widget.user.about,
                                decoration: const InputDecoration(
                                  label: Text('About'),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(defaultPadding),
                                    child: Icon(
                                      Icons.abc_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Si el formulario es válido, continuar con el envío
                                    AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        headerAnimationLoop: false,
                                        animType: AnimType.topSlide,
                                        title: 'Actualizacion de datos',
                                        desc:
                                            '¿Estas seguro que deseas actualizar tus datos?',
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {
                                          _formKey.currentState!.save();
                                          APIs.updateUserInfo();
                                          Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {
                                            AwesomeDialog(
                                                    context: context,
                                                    dialogType:
                                                        DialogType.success,
                                                    headerAnimationLoop: false,
                                                    animType: AnimType.topSlide,
                                                    title: 'Datos actualizados',
                                                    desc:
                                                        'Tus datos fueron actualizados',
                                                    btnOkOnPress: () {})
                                                .show();
                                          });
                                        }).show();
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          kPrimaryLightColor),
                                ),
                                child: Text("Guardar",
                                    style: TextStyle(
                                        fontFamily: 'Popins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ),
                              const SizedBox(height: defaultPadding),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
