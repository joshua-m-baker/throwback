import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/models/new_message.dart';
import 'package:throwback/models/auth_model.dart';
import 'package:throwback/models/contact.dart';

import 'package:throwback/pages/send_dialog.dart';
import 'package:throwback/pages/message.dart';

class ChatPage extends StatefulWidget {
  final Contact peer;

  ChatPage({Key key, @required this.peer}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController listScrollController = new ScrollController();
  var messagesList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ApiModel>(
        builder: (BuildContext context, Widget child, ApiModel apiModel) {
      return Scaffold(
        appBar: AppBar(
          title: new Text(widget.peer.name),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                buildMessages(context),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createImageMessage,
          child: Icon(Icons.add_photo_alternate),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  // Have builder list be inside dictionary in auth_model
  // Use BLOC model for handling firebase
  // Model for individual chat with person?
  // getMessages takes chatId, postId? if postId not null fetch from that and add to list, otherwise fetch most recent
  Widget buildMessages(BuildContext context) {
    //todo fetch more messages on top of scroll
    return Flexible(
        child: StreamBuilder(
            stream:
                ScopedModel.of<ApiModel>(context).getChats(widget.peer.chatId),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error}');
              } else {
                messagesList = snapshot.data.documents;
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 65),
                  itemBuilder: (context, index) => buildMessage(
                      context,
                      snapshot.data.documents[
                          index]), // TODO separation between different senders (listview separated?)
                  itemCount: snapshot.data.documents.length,
                  reverse: true,
                  controller: listScrollController,
                );
              }
            }));
  }

  void createImageMessage() async {
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (imageFile == null) {
      return;
    }

    NewMessage newMessage = new NewMessage(
        imageFile, null, widget.peer.uid, widget.peer.chatId, '', '');

    showDialog(
        context: context,
        builder: (context) {
          return SendDialog(message: newMessage);
        }).then((value) {
      if (value) {
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        setState(() {});
      }
    });
  }
}
