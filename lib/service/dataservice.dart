import 'dart:convert';

import 'package:flutter_tasks/model/task-models.dart';
import 'package:http/http.dart' as http;

class DataService{
  String mainUrl = 'ketan-node-tasks.herokuapp.com';
  
  Future<TasksResponse> fetchTasks() async {
    try{
      final response = await http.get(Uri.https(mainUrl, 'task'));

      print('statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return TasksResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return TasksResponse(success: false);
    }
    return TasksResponse(success: false);
  }

  Future<TaskResponse> fetchTask(int id) async {
    try{
      final response = await http.get(Uri.https(mainUrl, 'task/'+id.toString()));

      print('statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return TaskResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return TaskResponse(success: false);
    }
    return TaskResponse(success: false);
  }

  Future<OperationResponse> createTask(Task task) async {
    try{
      final response = await http.put(
        Uri.https(mainUrl, 'task'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(task)
      );
      
      print('createTask statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return OperationResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return OperationResponse(success: false);
    }
    return OperationResponse(success: false);
  }

  Future<OperationResponse> updateTask(Task task) async {
    try{
      final response = await http.post(
        Uri.https(mainUrl, 'task'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(task)
      );
      
      print('updateTask statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return OperationResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return OperationResponse(success: false);
    }
    return OperationResponse(success: false);
  }

  Future<OperationResponse> deleteTask(Task task) async {
    try{
      final response = await http.delete(
        Uri.https(mainUrl, 'task/'+task.id.toString()));
      
      print('deleteTask statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return OperationResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return OperationResponse(success: false);
    }
    return OperationResponse(success: false);
  }

  Future<TagsResponse> fetchTags() async {
    try{
      final response = await http.get(Uri.https(mainUrl, 'tag'));

      print('statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return TagsResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return TagsResponse(success: false);
    }
    return TagsResponse(success: false);
  }

  Future<TagResponse> fetchTag(int id) async {
    try{
      final response = await http.get(Uri.https(mainUrl, 'tag/'+id.toString()));

      print('statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return TagResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return TagResponse(success: false);
    }
    return TagResponse(success: false);
  }

  Future<OperationResponse> createTag(Tag tag) async {
    try{
      final response = await http.put(
        Uri.https(mainUrl, 'tag'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(tag)
      );
      
      print('createTag statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return OperationResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return OperationResponse(success: false);
    }
    return OperationResponse(success: false);
  }

  Future<OperationResponse> updateTag(Tag tag) async {
    try{
      final response = await http.post(
        Uri.https(mainUrl, 'tag'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(tag)
      );
      
      print('updateTag statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return OperationResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return OperationResponse(success: false);
    }
    return OperationResponse(success: false);
  }

  Future<OperationResponse> deleteTag(Tag tag) async {
    try{
      final response = await http.delete(
        Uri.https(mainUrl, 'tag/'+tag.id.toString()));
      
      print('deleteTag statusCode : ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return OperationResponse.fromJson(jsonDecode(response.body));
      }
    } on Exception catch(_){
        return OperationResponse(success: false);
    }
    return OperationResponse(success: false);
  }

}