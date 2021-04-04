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
  Future<TagsResponse> tags;
  bool isUpdate = false;
  RefreshDataCall refreshDataCall;
  bool isProcessing = false;

  _TaskCreatePageState(this.task, this.isUpdate, this.refreshDataCall);


  @override
  void initState() {
    super.initState();
    //refreshTasks();
    tags = dataService.fetchTags();
  }

  void refreshTasks(){
      print('refreshTasks');
    //tasks = dataService.fetchTasks();
    setState((){tags = DataService().fetchTags();});
    //setState((){});
  }

  void updateName(String name){
    task.name = name;
    setState((){});
  }

  void updateIsDone(bool isDone){
    task.isDone = isDone;
    setState((){});
  }

  void updateTag(Tag tag, bool isSelected){
    if(isSelected){
      if(!task.tags.any((t) => t.id==tag.id)){
        task.tags.add(tag);
      }
    }else{
      if(task.tags.any((t) => t.id==tag.id)){
        task.tags.removeWhere((t) => t.id==tag.id);
      }
    }
    setState((){});
  }

  void createTask(BuildContext context){
    setState((){isProcessing = true;});
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
      setState((){isProcessing = false;});
    });
  }

  void updateTask(BuildContext context){
    setState((){isProcessing = true;});
    dataService.updateTask(task).then((operationResponse) {
      print('createTask done '+operationResponse.toString());
      if(operationResponse.success){
        showMessage(context, 'Task updated');
        Navigator.of(context).pop();
        refreshDataCall();
      }else{
        showMessage(context, 'Error occured');
      }
      setState((){isProcessing = false;});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Text(isUpdate ? 'Update Task' : 'Create Task'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              if(!isProcessing){
                isUpdate ? updateTask(context) : createTask(context);
              }
            },
            color: isProcessing ? Colors.black12 : Colors.white,
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
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Text('Tags'),),
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: getTagSelectView(),),
            ],
          ),
          TableRow(
            children: <Widget>[
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Text('Is completed'),),
              Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Checkbox(value: task.isDone, onChanged: updateIsDone, activeColor: Theme.of(context).accentColor,),),
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
    );
  }

  Widget getTagSelectView(){
    return FutureBuilder<TagsResponse>(
      future: this.tags,
      builder: (context, snapshot) {
        List<Tag> tagsToShow;
        Widget getListItem(BuildContext context, Tag tag) {

          updateTagSelection(bool isSelected){
            updateTag(tag, isSelected);
          }
          return Container(
            child: Container(
              padding: EdgeInsets.all(5),
              child: FilterChip(
                  selectedColor: HexColor(tag.color),
                  backgroundColor: HexColor('#33'+tag.color.split('#')[1]),
                  visualDensity: VisualDensity.compact,
                  label: Text(tag.name, style: TextStyle(color: Colors.white),), 
                  selected: task.tags.any((t) => t.id==tag.id),
                  onSelected: updateTagSelection,
                ),
            ),
          );
        }
        if(snapshot.connectionState!=ConnectionState.none && snapshot.connectionState!=ConnectionState.waiting) {
          if (snapshot.hasData) {
            if(snapshot.data.success){
              if(snapshot.data.tags.length>0){
                tagsToShow = snapshot.data.tags;
                return Wrap(
                  children: [
                    for(Tag tag in tagsToShow) getListItem(context, tag),
                  ]
                );
              }else{
                return Text("No Tags");
              }
            }else{
              return Text("Error occured while getting tags");
            }
          } else if (snapshot.hasError) {
            return Text('Error occured ${snapshot.error}');
          }
        }
        return CircularProgressIndicator();
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