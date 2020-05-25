import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/models/new_message.dart';
import 'package:throwback/models/auth_model.dart';

class SendDialog extends StatefulWidget {

  //Function sendMessage;
  NewMessage message;

  SendDialog({Key key, @required this.message}) : super(key: key);

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

    _uploadTask = ScopedModel.of<ApiModel>(context).uploadFile(widget.message.imageFile);
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      child: customDialog(widget.message), 
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

  Widget customDialog() {
    return ScopedModelDescendant<ApiModel>(
      builder: (BuildContext context, Widget child, ApiModel apiModel) {    
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  width: double.infinity,
                  child: FittedBox(
                    child: Image(
                      image: FileImage(widget.message.imageFile), 
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
                            Navigator.of(context).pop(false);
                          }
                        }
                      );
                    }),
                    Container(
                      child: _isSendingMessage ? CircularProgressIndicator() : FlatButton(child: Icon(Icons.send), onPressed: () { 
                        widget.message.title = _titleController.text.trim();
                        widget.message.description = _descriptionController.text.trim();
                        sendMessage(widget.message); 
                      }),
                    ),
                  ],
                )
              ]
            )
          )
        );
      });
  }

  void sendMessage(NewMessage message) async {
    setState(() {
      _isSendingMessage = true;
    });
    StorageTaskSnapshot storageTaskSnapshot = await _uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) { // maybe move to cloud functions
      _shouldDelete = false; //don't want to delete the image from firebase if they confirmed sending it
      // widget.sendMessage(downloadUrl, title, description);
      message.imageUrl = downloadUrl;
      ScopedModel.of<ApiModel>(context).sendMessage(message);
      _isSendingMessage = false;
      Navigator.of(context).pop(true);
    }, onError: (err) {
      setState(() {
        _isSendingMessage = false;
        print("Error sending message"); //todo toast
      });
    });
  }
}
