import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/models.dart/picture_message.dart';
import 'package:throwback/auth_model.dart';

// wrap in sending dialog widget
// get image from wherever then move to send

enum MessageType{
  url, 
  camera,
  file
}

Future createNewMessage(MessageType type, BuildContext context){

  switch(type){
    case MessageType.url: 
      return _createUrlMessage();
      break; 
    
    case MessageType.camera:
      return _createCameraMessage();
      break;

    case MessageType.file:
      return _createFileMessage();
      break;
  }
}

  Future _createFileMessage() async {
    return ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    // File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    // if (imageFile != null) {
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return SendDialog(image: imageFile, sendMessage: this.onSendMessage);
    //     }
    //   );
    // }
  }

  Future _createUrlMessage() async{
    // todo fetch image from url and send
    // TextEditingController urlFieldController = TextEditingController();
    // return showDialog(
    //   context: context,
    //   child: urlDialog(urlFieldController, context)
    // ) ?? Future<void>.value();
    return Future<void>.value();
  }

  Future _createCameraMessage() async{
    // todo get picture from camera
    return ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 70);
  }

  Widget urlDialog(TextEditingController urlFieldController, BuildContext context){
    return AlertDialog(
        content: Column(
          children: <Widget>[
            TextField(
              controller: urlFieldController,
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Upload"),
            onPressed: () {
              print(urlFieldController.text);
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            child: Text("Cancel"),
            onPressed: () { Navigator.of(context).pop(true); }
          )
      ],
    );
  }