
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/auth_model.dart';
import 'package:throwback/chats_list.dart';
import 'package:throwback/login.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ApiModel>(
      builder: (context, child, apiModel) {
        return apiModel.isLoggedIn() ? ChatsListPage() : LoginPage();
      }
    );
  }
}
