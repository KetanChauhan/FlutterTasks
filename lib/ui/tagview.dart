
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';
import 'package:flutter_tasks/ui/taglist.dart';

class TagView extends StatefulWidget{
  Tag tag;
  RefreshDataCall refreshDataCall;

  TagView(this.tag, this.refreshDataCall);

  @override
  _TagViewState createState() => _TagViewState(tag, refreshDataCall);
}

class _TagViewState extends State<TagView> {
  DataService dataService = DataService();
  Tag tag;
  RefreshDataCall refreshDataCall;

  _TagViewState(this.tag, this.refreshDataCall);

  @override
  Widget build(BuildContext context) {
    TagActionsImpl tagActions = TagActionsImpl(tag, refreshDataCall);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: HexColor(tag.color),
        child: Text(tag.name.substring(0,1), style: TextStyle(color: Colors.white)),),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag.name,),
        ],
      ),
      trailing: Container(
        width: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(icon: Icon(Icons.edit), onPressed: ()=>{tagActions.updateTag(context)},),
            IconButton(icon: Icon(Icons.delete), onPressed: ()=>{tagActions.deleteTag(context, false)},)
          ],
        ),
      ),
      onTap: (){},
    );
  }

}