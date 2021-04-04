
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';
import 'package:flutter_tasks/ui/taskdetail.dart';
import 'package:flutter_tasks/ui/tasklist.dart';

class TaskView extends StatefulWidget{
  Task task;
  RefreshDataCall refreshDataCall;

  TaskView(this.task, this.refreshDataCall);

  @override
  _TaskViewState createState() => _TaskViewState(task, refreshDataCall);
}

class _TaskViewState extends State<TaskView> {
  DataService dataService = DataService();
  Task task;
  RefreshDataCall refreshDataCall;

  _TaskViewState(this.task, this.refreshDataCall);

  @override
  Widget build(BuildContext context) {
    TaskActionsImpl taskActions = TaskActionsImpl(task, refreshDataCall);

    void updateTask(bool isDone){
      bool olderIsDone = task.isDone;
      task.isDone = isDone;
      setState(() {task;});
      dataService.updateTask(task).then((operationResponse) {
        print('updateTask done '+operationResponse.toString());
        if(!operationResponse.success){
          task.isDone = olderIsDone;
          setState(() {task;});
          showMessage(context, 'Error occured');
        }
      });
      print('updateTask');
    }

    void goToTaskDetails(){
      Navigator.of(context).push(PageRouteBuilder(
          opaque: true,
          pageBuilder: (BuildContext context, _, __) =>
              TaskDetailPage(task, refreshDataCall)));
    }

    Widget getTaskActionsSheet(Task task, TaskActionsImpl taskActions){
      return Container(
        height: 230,
        child: Column(
          children: [
            Container(
              height: 45,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Text('${task.name}', textAlign: TextAlign.start, style: TextStyle(fontSize: 20),),
            ),
            Divider(thickness: 1,),
            Expanded(child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.view_agenda,),
                  title: Text('View'),
                  onTap: (){Navigator.of(context).pop(); goToTaskDetails();},
                ),
                ListTile(
                  leading: Icon(Icons.edit,),
                  title: Text('Edit'),
                  onTap: ()=>{taskActions.updateTask(context)},
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red,),
                  title: Text('Delete',style: TextStyle(color: Colors.red),),
                  onTap: ()=>{taskActions.deleteTask(context, false)},
                ),
              ],))
          ],
        ),
      );
    }

    void showTaskActionSheet(){
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => getTaskActionsSheet(task, taskActions),
      );
    }

    return ListTile(
      leading: Checkbox(value: task.isDone, onChanged: updateTask, activeColor: Theme.of(context).accentColor,),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.name,),
          Container(height: 10,),
          Wrap(
            spacing: 5,
            children: [
              for(Tag tag in task.tags) Chip(
                backgroundColor: HexColor(tag.color),
                visualDensity: VisualDensity.compact,
                label: Text(tag.name, style: TextStyle(color: Colors.white)),),
            ],
          ),
        ],
      ),
      trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: showTaskActionSheet,),
      onTap: goToTaskDetails,
      onLongPress: showTaskActionSheet,
    );
  }

}