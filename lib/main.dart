import 'package:fieldmonitor3/ui/project_list/project_list_main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/bloc/theme_bloc.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';

void main() async {
  runApp(MyApp());
  await Firebase.initializeApp();
  pp('🥦🥦🥦🥦🥦 Firebase has been initialized 🥦🥦🥦🥦');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: themeBloc.newThemeStream,
        builder: (context, snapshot) {
          ThemeData theme = themeBloc.getCurrentTheme();
          pp('🌸 🌸 default theme for the app, index: ${themeBloc.themeIndex}');
          if (snapshot.hasData) {
            pp('🌸 🌸 🌸 🌸 🌸 Setting theme for the app, index: 🌸 ${snapshot.data}');
            theme = themeBloc.getTheme(snapshot.data);
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Field Monitor',
            theme: theme,
            home: ProjectListMain(FIELD_MONITOR),
          );
        });
  }
}
