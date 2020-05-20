import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:throwback/models/auth_model.dart';
import 'package:throwback/util/router.dart';

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Throwback',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Helvetica',
      ),
      onGenerateRoute: (RouteSettings settings) { return generateRoute(settings); },
      initialRoute: Routes.root,
    );
  }
}

void main(){
  WidgetsFlutterBinding.ensureInitialized();

  final apiModel = ApiModel();
  apiModel.signInSilently();

  runApp(
    ScopedModel<ApiModel>(
      model: apiModel,
      child: MyApp(),
    )
  );
}
