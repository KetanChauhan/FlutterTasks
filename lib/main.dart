import 'package:flutter/material.dart';
import 'package:flutter_tasks/ui/tasklist.dart';

void main() {
  runApp(FlutterTasksApp());
}

class FlutterTasksApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tasks',
      theme: ThemeData.light().copyWith(primaryColor: Colors.blue, accentColor: Colors.pink),
      darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.blue, accentColor: Colors.pink),
      themeMode: ThemeMode.system,
      home: TaskListPage(title: 'Flutter Tasks'),
    );
  }
}
