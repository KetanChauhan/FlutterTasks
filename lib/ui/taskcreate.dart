import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';

class TaskCreatePage extends StatefulWidget {
  DataService dataService = DataService();
  RefreshDataCall refreshDataCall;
  Task task;
  bool isUpdate = false;

  TaskCreatePage(Task task, bool isUpdate, RefreshDataCall refreshDataCall){
    this.task = isUpdate ? task : Task.getDefault();
    this.isUpdate = isUpdate;
    this.refreshDataCall = refreshDataCall;
  }

  @override
  _TaskCreatePageState createState() => _TaskCreatePageState(task, isUpdate, refreshDataCall);
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  DataService dataService = DataService();
  Task task;
  bool isUpdate = false;
  RefreshDataCall refreshDataCall;

  _TaskCreatePageState(this.task, this.isUpdate, this.refreshDataCall);

  void updateName(String name){
    task.name = name;
    setState((){});
  }

  void updateIsDone(bool isDone){
    task.isDone = isDone;
    setState((){});
  }

  void createTask(BuildContext context){
    dataService.createTask(task).then((operationResponse) {
      print('createTask done '+operationResponse.toString());
      print('createTask done '+operationResponse.success.toString());
      if(operationResponse.success==true){
        print('Task created ');
        showMessage(context, 'Task created');
        Navigator.of(context).pop();
        refreshDataCall();
      }else{
        print('Task created error ');
        showMessage(context, 'Error occured');
      }
    });
  }

  void updateTask(BuildContext context){
    dataService.updateTask(task).then((operationResponse) {
      print('createTask done '+operationResponse.toString());
      if(operationResponse.success){
        showMessage(context, 'Task updated');
        Navigator.of(context).pop();
        refreshDataCall();
      }else{
        showMessage(context, 'Error occured');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Task' : 'Create Task'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Refresh',
            onPressed: () {
              isUpdate ? updateTask(context) : createTask(context);
            },
          ),
        ],
      ),
      body: getTaskCreateView(),
    );
  }

  

  Widget getTaskCreateView(){
    return Container(
      padding: EdgeInsets.all(10),
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.3),
          1: FractionColumnWidth(0.7),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[
          TableRow(
            children: <Widget>[
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Text('Task'),),
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), 
                child: TextFormField(onChanged: updateName, initialValue: task.name,)
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Text('Is completed'),),
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Checkbox(value: task.isDone, onChanged: updateIsDone,),),
            ],
          ),
        ],
      ),
    );
  }
}

void showMessage(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}