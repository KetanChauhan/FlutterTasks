import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';
import 'package:flutter_tasks/ui/tagcreate.dart';
import 'package:flutter_tasks/ui/tagview.dart';

class TagListPage extends StatefulWidget {
  RefreshDataCall refreshDataCall;
  TagListPage({Key key, this.title , this.refreshDataCall}) : super(key: key);

  final String title;

  @override
  _TagListPageState createState() => _TagListPageState(refreshDataCall);
}

class _TagListPageState extends State<TagListPage> {
  DataService dataService = DataService();
  RefreshDataCall refreshDataCall;
  Future<TagsResponse> tags;

  _TagListPageState(this.refreshDataCall);

  AppBar _buildAppBar(BuildContext context) {
    return new AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: (){
            Navigator.of(context).pop();
            refreshDataCall();
          },
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              refreshTags();
            },
          ),
        ]
    );
  }


  @override
  void initState() {
      print('initState');
    super.initState();
    //refreshTasks();
    tags = dataService.fetchTags();
  }

  void refreshTags(){
      print('refreshTags');
    //tasks = dataService.fetchTasks();
    setState((){tags = DataService().fetchTags();});
    //setState((){});
  }

  @override
  Widget build(BuildContext context) {
    print('==build==');
    return Scaffold(
      appBar: _buildAppBar(context),
      body: getTagListWidget(context),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(PageRouteBuilder(
            opaque: true,
            pageBuilder: (BuildContext context, _, __) =>
                TagCreatePage(Tag.getDefault(),false,()=>{refreshTags()})));
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: Colors.white,
      ), 
    );
  }

  Widget getTagListWidget(BuildContext context){
    return Center(
      child: FutureBuilder<TagsResponse>(
        future: this.tags,
        builder: (context, snapshot) {
          List<Tag> tagsToShow;
          Widget getListItem(BuildContext context, int index) {
            Tag t = tagsToShow[index];
            return TagView(t, ()=>{refreshTags()});
          }
          Widget getListItemSeparator(BuildContext context, int index) {
            return Divider();
          }
          if(snapshot.connectionState!=ConnectionState.none && snapshot.connectionState!=ConnectionState.waiting) {
            if (snapshot.hasData) {
              if(snapshot.data.success){
                if(snapshot.data.tags.length>0){
                  tagsToShow = snapshot.data.tags;
                  print('tagsToShow '+tagsToShow.toString());
                  return ListView.separated(
                    itemCount: tagsToShow.length,
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

class TagActionsImpl implements TagActions{
  DataService dataService = DataService();
  Tag _tag;
  RefreshDataCall refreshDataCall;

  TagActionsImpl(this._tag, this.refreshDataCall);

  void updateTag(BuildContext context){
    print('updateTag');
    Navigator.of(context).push(PageRouteBuilder(
        opaque: true,
        pageBuilder: (BuildContext context, _, __) =>
            TagCreatePage(_tag,true,refreshDataCall)));
  }
  void deleteTag(BuildContext context, bool wait){
    print('deleteTag');
    dataService.deleteTag(_tag).then((operationResponse) {
      print('deleteTag done '+operationResponse.toString());
      if(operationResponse.success==true){
        showMessage(context, 'Tag deleted');
        if(wait){
          Navigator.of(context).pop();
        }
        refreshDataCall();
      }else{
        print('Tag created error ');
        showMessage(context, 'Error occured');
        if(wait){
          Navigator.of(context).pop();
        }
      }
    });
  }
}