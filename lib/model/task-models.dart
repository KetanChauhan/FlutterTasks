import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Task {
  final int id;
  String name;
  bool isDone;

  Task({@required this.id, this.name, this.isDone});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      isDone: json['isDone'],
    );
  }
  
  factory Task.getDefault(){
    return Task(
      id: -1,
      name: '',
      isDone: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDone': isDone,
    };
  }

  @override
  String toString() {
    return 'Task[ $id, $name, $isDone]';
  }
}

class TasksResponse {
  final bool success;
  List<Task> tasks;

  TasksResponse({this.success, this.tasks});

  factory TasksResponse.fromJson(Map<String, dynamic> js) {
    return TasksResponse(
      success: js['success'],
      tasks: js['tasks'].map((ts) => Task.fromJson(ts)).toList().cast<Task>(),
    );
  }

  @override
  String toString() {
    return 'TasksResponse[ $success, $tasks]';
  }
}

class OperationResponse {
  
  final bool success;
  final int insertedId;
  final String successMessage;
  final String errorMessage;

  OperationResponse({this.success, this.insertedId, this.successMessage, this.errorMessage});

  factory OperationResponse.fromJson(Map<String, dynamic> js) {
    return OperationResponse(
      success: js['success'],
      insertedId: js['insertedId'],
      successMessage: js['successMessage'],
      errorMessage: js['errorMessage'],
    );
  }

  @override
  String toString() {
    return 'OperationResponse[ $success, $insertedId, $successMessage, $errorMessage]';
  }
}

abstract class TaskActions{
  void updateTask(BuildContext context);
  void deleteTask(BuildContext context);
}

typedef RefreshDataCall = void Function();