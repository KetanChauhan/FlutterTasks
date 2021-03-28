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
}