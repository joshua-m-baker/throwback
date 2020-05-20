
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/models/auth_model.dart';
import 'package:throwback/pages/chats_list.dart';
import 'package:throwback/pages/login.dart';

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
