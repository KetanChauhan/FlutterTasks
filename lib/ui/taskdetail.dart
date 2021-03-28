import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';

class TaskDetailPage extends StatelessWidget {
  Task task;

  TaskDetailPage(this.task);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.name),
      ),
      body: getTaskDetailsView(),
    );
  }

  Widget getTaskDetailsView(){
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
              Padding(padding: EdgeInsets.all(10), child: Text('Task', style: TextStyle(fontSize: 25),),),
              Padding(padding: EdgeInsets.all(10), child: Text(task.name, style: TextStyle(fontSize: 25),),),
            ],
          ),
          TableRow(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(10), child: Text('Is completed', style: TextStyle(fontSize: 15),),),
              Padding(padding: EdgeInsets.all(10), 
                child: task.isDone 
                ? Text('Yes', style: TextStyle(fontSize: 15, color: Colors.greenAccent),) 
                : Text('No', style: TextStyle(fontSize: 15),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}