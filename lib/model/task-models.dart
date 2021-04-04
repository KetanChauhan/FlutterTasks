import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Task {
  final int id;
  String name;
  bool isDone;
  List<Tag> tags = [];
  DateTime createdOn;
  DateTime modifiedOn;

  Task({@required this.id, this.name, this.isDone, this.tags, this.createdOn, this.modifiedOn});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      isDone: json['isDone'],
      tags: json['tags'].map((tg) => Tag.fromJson(tg)).toList().cast<Tag>(),
      createdOn: DateTime.parse(json['createdOn']),
      modifiedOn: DateTime.parse(json['modifiedOn']),
    );
  }
  
  factory Task.getDefault(){
    return Task(
      id: -1,
      name: '',
      isDone: false,
      tags: []
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDone': isDone,
      'tags': tags
    };
  }

  @override
  String toString() {
    return 'Task[ $id, $name, $isDone Tags[$tags]]';
  }
}

class Tag {
  final int id;
  String name;
  String color;
  DateTime createdOn;
  DateTime modifiedOn;

  Tag({@required this.id, this.name, this.color, this.createdOn, this.modifiedOn});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdOn: DateTime.parse(json['createdOn']),
      modifiedOn: DateTime.parse(json['modifiedOn']),
    );
  }
  
  factory Tag.getDefault(){
    return Tag(
      id: -1,
      name: '',
      color: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  @override
  String toString() {
    return 'Tag[ $id, $name, $color]';
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

class TagsResponse {
  final bool success;
  List<Tag> tags;

  TagsResponse({this.success, this.tags});

  factory TagsResponse.fromJson(Map<String, dynamic> js) {
    return TagsResponse(
      success: js['success'],
      tags: js['tags'].map((ts) => Tag.fromJson(ts)).toList().cast<Tag>(),
    );
  }

  @override
  String toString() {
    return 'TagsResponse[ $success, $tags]';
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

//enum SortType { default_sort, name_asc, name_desc, created_asc, created_desc, modified_asc, modified_desc, done_asc, done_desc}
enum SortType { default_sort, name, created, modified, done, asc, desc}

extension SortTypeExtension on SortType {

  String get name {
    switch (this) {
      case SortType.default_sort : return "Default";
      case SortType.name : return "Name";
      case SortType.created : return "Created Date";
      case SortType.modified : return "Modified Date";
      case SortType.done : return "Completed";
      case SortType.asc : return "\u2191 Ascending";
      case SortType.desc : return "\u2193 Descending";
      default: return "";
    }
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}