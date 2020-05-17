
import 'package:flutter/material.dart';
import 'package:throwback/chat_page.dart';
import 'package:throwback/chats_list.dart';
import 'package:throwback/landing_page.dart';
import 'package:throwback/picture_chat.dart';

class PictureChatMessage{
  String messageId;
  String fromId;
  String toId;
  int timestamp;
  String url;
  String title;
  String description;

  PictureChatMessage(this.messageId, this.fromId, this.toId, this.timestamp, this.url, this.title, this.description);
}

class ChatArgs{
  final String myId;
  final String peerId; 
  final String peerName;

  ChatArgs(this.myId, this.peerId, this.peerName);
}

class PictureChatArgs{
  final PictureChatMessage message;

  PictureChatArgs(this.message);
}

class Routes {
  static const String root = '/';
  static const String chats_list = '/chats';
  static const String new_chat = '/chats/add';
  static const String chat_page = '/chats/chat';
  static const String picture_chat = 'chats/chat/picture_chat';
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name){
    case Routes.root:
      return MaterialPageRoute( builder: (context) => LandingPage());
      //return MaterialPageRoute( builder: (context) => SignInPage());
      // break;
    case Routes.chats_list:
      return MaterialPageRoute(builder: (context) => ChatsListPage());
      break;
    case Routes.chat_page:
      ChatArgs args = settings.arguments;
      return MaterialPageRoute(builder: (context) => ChatPage(myId: args.myId, peerId: args.peerId, peerName: args.peerName,));
      break;
    case Routes.picture_chat:
      PictureChatArgs args = settings.arguments;
      return MaterialPageRoute(builder: (context) => PictureChat(pictureMessage: args.message));
      break;
  };
}
