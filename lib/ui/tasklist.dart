import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';
import 'package:flutter_tasks/ui/taskcreate.dart';
import 'package:flutter_tasks/ui/taskdetail.dart';
import 'package:flutter_tasks/ui/taskview.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isAscending = true;

  AppBar _buildAppBar(BuildContext context) {
    return new AppBar(
        title: Text(widget.title),
        actions: [
          searchBar.getSearchAction(context),
          PopupMenuButton<SortType>(
            icon: Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (SortType result) {
                if(result==SortType.asc){
                  isAscending = true;
                }else if(result==SortType.desc){
                  isAscending = false;
                }else{
                  _sortType = result;
                }
                saveSortPreference();
                refreshTasks();
              },
            itemBuilder: (BuildContext context) => SortType.values.toList().map((st)=>
                PopupMenuItem<SortType>(
                  value: st,
                  child: Text(st.name),
                  textStyle: (st==_sortType || (st==SortType.asc&&isAscending) || (st==SortType.desc&&!isAscending)) ? TextStyle(color: Theme.of(context).accentColor) : Theme.of(context).textTheme.subtitle2,
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
        case SortType.default_sort :
        case SortType.desc :
        case SortType.asc :
          return isAscending ? a.id.compareTo(b.id) : b.id.compareTo(a.id);
        case SortType.name : return isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name); break;
        case SortType.created : return isAscending ? a.createdOn.compareTo(b.createdOn) : b.createdOn.compareTo(a.createdOn); break;
        case SortType.modified : return isAscending ? a.modifiedOn.compareTo(b.modifiedOn) : b.modifiedOn.compareTo(a.modifiedOn); break;
        case SortType.done : return a.isDone==b.isDone ? 0 : (isAscending ? (a.isDone ? -1 : 1) : (b.isDone ? -1 : 1)); break;
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
    initSavedPreferences();
    tasks = dataService.fetchTasks();
  }

  void initSavedPreferences() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sortTypeString = prefs.getString('SortType');
    print('Saved sortTypeString $sortTypeString');
    SortType sortType =
    (sortTypeString!=null && sortTypeString.length>0) ?
      SortType.values.firstWhere((e) => e.toString() == sortTypeString, orElse: ()=> SortType.default_sort)
      : SortType.default_sort;
    _sortType = sortType;
    bool isSortAscending = prefs.getBool('isSortAscending');
    isAscending = isSortAscending!=null ? isSortAscending : true;
    print('Saved sorttype $sortType $isSortAscending');
  }

  void saveSortPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('SortType', _sortType.toString());
    prefs.setBool('isSortAscending', isAscending);
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