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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListPage(title: 'Flutter Tasks'),
    );
  }
}
