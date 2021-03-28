import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';
import 'package:flutter_tasks/ui/taskcreate.dart';
import 'package:flutter_tasks/ui/taskdetail.dart';

class TaskListPage extends StatefulWidget {
  TaskListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  DataService dataService = DataService();
  Future<TasksResponse> tasks;

  @override
  void initState() {
      print('initState');
    super.initState();
    //refreshTasks();
    tasks = dataService.fetchTasks();
  }

  void refreshTasks(){
      print('refreshTasks');
    //tasks = dataService.fetchTasks();
    setState((){tasks = DataService().fetchTasks();});
    //setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              refreshTasks();
            },
          ),
        ],
      ),
      body: getTaskListWidget(context),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(PageRouteBuilder(
            opaque: true,
            pageBuilder: (BuildContext context, _, __) =>
                TaskCreatePage(Task.getDefault(),false,()=>{refreshTasks()})));
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ), 
    );
  }

  Widget getTaskListWidget(BuildContext context){
    return Center(
      child: FutureBuilder<TasksResponse>(
        future: this.tasks,
        builder: (context, snapshot) {
          Widget getListItem(BuildContext context, int index) {
            return TaskView(snapshot.data.tasks[index], ()=>{refreshTasks()});
          }
          if(snapshot.connectionState!=ConnectionState.none && snapshot.connectionState!=ConnectionState.waiting) {
            if (snapshot.hasData) {
              if(snapshot.data.success){
                if(snapshot.data.tasks.length>0){
                  return ListView.builder(
                    itemCount: snapshot.data.tasks.length,
                    itemBuilder: getListItem ,
                  );
                }else{
                  return Text("No Tasks");
                }
              }else{
                return Text("Error occured");
              }
            } else if (snapshot.hasError) {
              return Text('Error occured ${snapshot.error}');
            }
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
        ),
    );
  }


}

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
    
    Widget getTaskActionsSheet(Task task, TaskActionsImpl taskActions){
      return Container(
        height: 180,
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
                  leading: Icon(Icons.edit,),
                  title: Text('Edit'),
                  onTap: ()=>{taskActions.updateTask(context)},
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red,),
                  title: Text('Delete',style: TextStyle(color: Colors.red),),
                  onTap: ()=>{taskActions.deleteTask(context)},
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
      leading: Checkbox(value: task.isDone, onChanged: updateTask,),
      title: Text(task.name,), 
      trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: showTaskActionSheet,),
      onTap: (){
        Navigator.of(context).push(PageRouteBuilder(
        opaque: true,
        pageBuilder: (BuildContext context, _, __) =>
            TaskDetailPage(task)));
      },
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

class TaskActionsImpl implements TaskActions{
  DataService dataService = DataService();
  Task _task;
  RefreshDataCall refreshDataCall;

  TaskActionsImpl(this._task, this.refreshDataCall);

  void updateTask(BuildContext context){
    print('updateTask');
    Navigator.of(context).pop();
    Navigator.of(context).push(PageRouteBuilder(
        opaque: true,
        pageBuilder: (BuildContext context, _, __) =>
            TaskCreatePage(_task,true,refreshDataCall)));
  }
  void deleteTask(BuildContext context){
    print('deleteTask');
    Navigator.of(context).pop();
    dataService.deleteTask(_task).then((operationResponse) {
      print('deleteTask done '+operationResponse.toString());
      if(operationResponse.success==true){
        showMessage(context, 'Task deleted');
        refreshDataCall();
      }else{
        print('Task created error ');
        showMessage(context, 'Error occured');
      }
    });
  }
}