
import 'package:flutter/material.dart';

import 'package:throwback/models/picture_message.dart';
import 'package:throwback/models/contact.dart';

import 'package:throwback/pages/chat_page.dart';
import 'package:throwback/pages/chats_list.dart';
import 'package:throwback/pages/landing_page.dart';
import 'package:throwback/pages/picture_chat.dart';

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
      Contact peer = settings.arguments;
      return MaterialPageRoute(builder: (context) => ChatPage(peer: peer));
      break;
    case Routes.picture_chat:
      PictureMessage message = settings.arguments;
      return MaterialPageRoute(builder: (context) => PictureChat(pictureMessage: message));
      break;
  };
}
