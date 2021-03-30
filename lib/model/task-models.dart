import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Task {
  final int id;
  String name;
  bool isDone;
  DateTime createdOn;
  DateTime modifiedOn;

  Task({@required this.id, this.name, this.isDone, this.createdOn, this.modifiedOn});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      isDone: json['isDone'],
      createdOn: DateTime.parse(json['createdOn']),
      modifiedOn: DateTime.parse(json['modifiedOn']),
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
  void deleteTask(BuildContext context, bool wait);
}

typedef RefreshDataCall = void Function();

enum SortType { default_sort, name_asc, name_desc, created_asc, created_desc, modified_asc, modified_desc, done_asc, done_desc}

extension SortTypeExtension on SortType {

  String get name {
    switch (this) {
      case SortType.default_sort : return "Default";
      case SortType.name_asc : return "Name \u2191";
      case SortType.name_desc : return "Name \u2193";
      case SortType.created_asc : return "Created Date \u2191";
      case SortType.created_desc : return "Created Date \u2193";
      case SortType.modified_asc : return "Modified Date \u2191";
      case SortType.modified_desc : return "Modified Date \u2193";
      case SortType.done_asc : return "Completed \u2191";
      case SortType.done_desc : return "Completed \u2193";
      default: return "";
    }
  }
}