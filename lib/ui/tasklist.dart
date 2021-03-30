import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';
import 'package:flutter_tasks/ui/taskcreate.dart';
import 'package:flutter_tasks/ui/taskdetail.dart';
import 'package:flutter_tasks/ui/taskview.dart';

class TaskListPage extends StatefulWidget {
  TaskListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  DataService dataService = DataService();
  Future<TasksResponse> tasks;

  String searchText = '';
  SearchBar searchBar;
  SortType _sortType = SortType.default_sort;

  AppBar _buildAppBar(BuildContext context) {
    return new AppBar(
        title: Text(widget.title),
        actions: [
          searchBar.getSearchAction(context),
          PopupMenuButton<SortType>(
            onSelected: (SortType result) { _sortType = result; refreshTasks();},
            itemBuilder: (BuildContext context) => SortType.values.toList().map((st)=>
                PopupMenuItem<SortType>(
                  value: st,
                  child: Text(st.name),
                )
            ).toList(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              refreshTasks();
            },
          ),
        ]
    );
  }

  List<Task> _sort(SortType sortType, List<Task> givenList){
    print('sort '+sortType.toString());
    if(sortType!=SortType.default_sort){
      givenList = _sort(SortType.default_sort,givenList);
    }
    givenList.sort((a,b){
      switch(sortType){
        case SortType.default_sort : return a.id.compareTo(b.id); break;
        case SortType.name_asc : return a.name.compareTo(b.name); break;
        case SortType.name_desc : return b.name.compareTo(a.name); break;
        case SortType.created_asc : return a.createdOn.compareTo(b.createdOn); break;
        case SortType.created_desc : return b.createdOn.compareTo(a.createdOn); break;
        case SortType.modified_asc : return a.modifiedOn.compareTo(b.modifiedOn); break;
        case SortType.modified_desc : return b.modifiedOn.compareTo(a.modifiedOn); break;
        case SortType.done_asc : return a.isDone==b.isDone ? 0 : (a.isDone ? -1 : 1); break;
        case SortType.done_desc : return a.isDone==b.isDone ? 0 : (b.isDone ? -1 : 1); break;
      }
      return -1;
    });
    return givenList;
  }

  void _search(q){
    setState((){searchText=q.trim().toLowerCase();});
  }

  void _clearSearch([q]){
    setState((){searchText='';});
  }

  _TaskListPageState(){
    searchBar = SearchBar(
        inBar: true,
        setState: setState,
        onChanged: _search,
        onSubmitted: _clearSearch,
        onCleared: _clearSearch,
        onClosed: _clearSearch,
        buildDefaultAppBar: _buildAppBar
    );
  }

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
    print('==build==');
    return Scaffold(
      appBar: searchBar.build(context),
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
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: Colors.white,
      ), 
    );
  }

  Widget getTaskListWidget(BuildContext context){
    return Center(
      child: FutureBuilder<TasksResponse>(
        future: this.tasks,
        builder: (context, snapshot) {
          List<Task> tasksToShow;
          Widget getListItem(BuildContext context, int index) {
            Task t = tasksToShow[index];
            if((searchText.length>0 && t.name.toLowerCase().contains(searchText)) || searchText.length==0){
              return TaskView(t, ()=>{refreshTasks()});
            }else{
              return Container();
            }
          }
          Widget getListItemSeparator(BuildContext context, int index) {
            Task t = tasksToShow[index];
            if((searchText.length>0 && t.name.toLowerCase().contains(searchText)) || searchText.length==0){
              return Divider();
            }else{
              return Container();
            }
          }
          if(snapshot.connectionState!=ConnectionState.none && snapshot.connectionState!=ConnectionState.waiting) {
            if (snapshot.hasData) {
              if(snapshot.data.success){
                if(snapshot.data.tasks.length>0){
                  tasksToShow = _sort(_sortType,snapshot.data.tasks);
                  print('tasksToShow '+tasksToShow.toString());
                  return ListView.separated(
                    itemCount: tasksToShow.length,
                    itemBuilder: getListItem ,
                    separatorBuilder: getListItemSeparator,
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
          return CircularProgressIndicator();
        },
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
  void deleteTask(BuildContext context, bool wait){
    print('deleteTask');
    if(!wait){
      Navigator.of(context).pop();
    }
    dataService.deleteTask(_task).then((operationResponse) {
      print('deleteTask done '+operationResponse.toString());
      if(operationResponse.success==true){
        showMessage(context, 'Task deleted');
        if(wait){
          Navigator.of(context).pop();
        }
        refreshDataCall();
      }else{
        print('Task created error ');
        showMessage(context, 'Error occured');
        if(wait){
          Navigator.of(context).pop();
        }
      }
    });
  }
}