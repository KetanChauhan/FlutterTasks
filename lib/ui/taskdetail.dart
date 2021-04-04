import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';
import 'package:flutter_tasks/ui/tasklist.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatefulWidget {
  Task task;
  RefreshDataCall refreshDataCall;
  TaskActionsImpl taskActions;

  TaskDetailPage(Task task, RefreshDataCall refreshDataCall){
    this.task = task;
    this.refreshDataCall = refreshDataCall;
    taskActions = TaskActionsImpl(task, refreshDataCall);
  }

  _TaskDetailPageState createState() => _TaskDetailPageState(task, refreshDataCall);
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  DataService dataService = DataService();
  Task task;
  RefreshDataCall refreshDataCall;
  TaskActionsImpl taskActions;

  _TaskDetailPageState(this.task, this.refreshDataCall){
    this.task = task;
    this.refreshDataCall = refreshDataCall;
    taskActions = TaskActionsImpl(task, refreshDataCall);
  }

  void toggleTaskDone(){
    bool olderIsDone = task.isDone;
    task.isDone = !olderIsDone;
    setState(() {task;});
    dataService.updateTask(task).then((operationResponse) {
      print('updateTask done '+operationResponse.toString());
      if(!operationResponse.success){
        task.isDone = olderIsDone;
        setState(() {task;});
        showMessage(context, 'Error occured');
      }else{
        refreshDataCall();
      }
    });
    print('updateTask');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          tooltip: 'Close',
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Text(task.name),
      ),
      body: getTaskDetailsView(context),
    );
  }

  Widget getTaskDetailsView(BuildContext context) {
    DateFormat dateFormat = DateFormat("dd-MMM-yyyy HH:mm:ss a");

    return ListView(
      children:[ Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.3),
                1: FractionColumnWidth(0.7),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(10),
                      child: Text('Task', style: TextStyle(fontSize: 25),),),
                    Padding(padding: EdgeInsets.all(10),
                      child: Text(task.name, style: TextStyle(fontSize: 25),),),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Divider(thickness: 1,),
                    Divider(thickness: 1,),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(10), child: Text('Tags',),),
                    Padding(padding: EdgeInsets.all(10), child: Wrap(
                      spacing: 5,
                      children: [
                        for(Tag tag in task.tags) Chip(
                          backgroundColor: HexColor(tag.color),
                          visualDensity: VisualDensity.compact,
                          label: Text(tag.name, style: TextStyle(color: Colors.white),),),
                      ],
                    ),),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(10),
                      child: Text(
                        'Is completed', style: TextStyle(fontSize: 15),),),
                    Padding(padding: EdgeInsets.all(10),
                      child: task.isDone
                          ? Text('Yes', style: TextStyle(
                          fontSize: 15, color: Colors.greenAccent),)
                          : Text('No', style: TextStyle(fontSize: 15),),
                    ),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10), child: Text('Created On',),),
                    Padding(padding: EdgeInsets.all(10),
                      child: Text(dateFormat.format(task.createdOn.toLocal()),),),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10), child: Text('Modified On',),),
                    Padding(padding: EdgeInsets.all(10),
                      child: Text(
                        dateFormat.format(task.modifiedOn.toLocal()),),),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Divider(thickness: 1,),
                    Divider(thickness: 1,),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10), child: Text('Actions',),),
                    Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            task.isDone ? Icons.check_box_outline_blank : Icons
                                .check_box,),
                          title: Text('Mark ${task.isDone
                              ? 'Uncompleted'
                              : 'Completed'}'),
                          onTap: toggleTaskDone,
                        ),
                        ListTile(
                          leading: Icon(Icons.edit,),
                          title: Text('Edit'),
                          onTap: () => {taskActions.updateTask(context)},
                        ),
                        ListTile(
                          leading: Icon(Icons.delete, color: Colors.red,),
                          title: Text(
                            'Delete', style: TextStyle(color: Colors.red),),
                          onTap: () => {taskActions.deleteTask(context, true)},
                        ),
                      ],
                    )
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    Divider(thickness: 1,),
                    Divider(thickness: 1,),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
      ]
    );
  }

}