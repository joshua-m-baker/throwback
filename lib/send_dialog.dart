import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:throwback/picture_chat.dart';

import 'router.dart';

class SendDialog extends StatefulWidget {

  Function sendMessage;
  File image;

  SendDialog({Key key, @required this.sendMessage, @required this.image}) : super(key: key);

  @override
  _SendDialogState createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog>{
  
  TextEditingController _titleController;
  TextEditingController _descriptionController;
  bool _isSendingMessage;
  StorageUploadTask _uploadTask;
  bool _shouldDelete;

  @override
  void initState(){
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _isSendingMessage = false;
    _shouldDelete = true;

    _uploadTask = uploadFile(widget.image);
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      child: customDialog(widget.image), 
      onWillPop: _onWillPop
    );
  }

  @override
  void dispose() {
    if (!_uploadTask.isComplete){
      _uploadTask.cancel();
    } 
    else if (_shouldDelete) {
      _uploadTask.lastSnapshot.ref.delete();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        content: new Text('Are you sure you want to discard this message?'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  Widget customDialog(File image) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              width: double.infinity,
              child: FittedBox(
                child: Image(
                  image: FileImage(image), 
                ),
                fit: BoxFit.fitWidth
              ),
            ),        
            TextField(
              decoration: InputDecoration(hintText: "Title"),
              controller: _titleController,
            ),
            TextField(
              decoration: InputDecoration(hintText: "Description"),
              controller: _descriptionController,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(child: Text("Cancel"), onPressed: () {
                  _onWillPop().then(
                    (result) {
                      if (result) {
                        Navigator.of(context).pop();
                      }
                    }
                  );
                }),
                Container(
                  child: _isSendingMessage ? CircularProgressIndicator() : FlatButton(child: Icon(Icons.send), onPressed: () { 
                  sendMessage(image, _titleController.text.trim(), _descriptionController.text.trim()); 
                  }),
                ),
              ],
            )
          ]
        )
      )
    );
  }


  Widget sendDialog(File image) {
    return AlertDialog( 
      actions: <Widget>[
        FlatButton(child: Text("Cancel"), onPressed: () {
          _onWillPop().then(
            (result) {
              if (result) {
                Navigator.of(context).pop();
              }
            }
          );
        } ),
        Container(
          child: _isSendingMessage ? CircularProgressIndicator() : FlatButton(child: Icon(Icons.send), onPressed: () { 
          sendMessage(image, _titleController.text.trim(), _descriptionController.text.trim()); 
          }),
        ),
      ],
      title: Text('Send'),
      content: Column(
        children: <Widget>[
          Image.file(image),
          TextField(
            decoration: InputDecoration(hintText: "Title"),
            controller: _titleController,
          ),
          TextField(
            decoration: InputDecoration(hintText: "Description"),
            controller: _descriptionController,
          ),
        ],
      ),
    );
  }

  void sendMessage(File imageFile, String title, String description) async {
    setState(() {
      _isSendingMessage = true;
    });
    StorageTaskSnapshot storageTaskSnapshot = await _uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) { // maybe move to cloud functions
      _shouldDelete = false; //don't want to delete the image from firebase if they confirmed sending it
      widget.sendMessage(downloadUrl, title, description);
      _isSendingMessage = false;
      Navigator.of(context).pop();
    }, onError: (err) {
      setState(() {
        _isSendingMessage = false;
        print("Error sending message"); //todo toast
      });
    });
  }

  StorageUploadTask uploadFile(File imageFile) {
    String fileName = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    return uploadTask; 
  }
}
