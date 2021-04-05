
import 'package:flex_color_picker/flex_color_picker.dart';
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
      leading: ColorIndicator(
        color: HexColor(tag.color),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag.name,),
        ],
      ),
      trailing: Container(
        alignment: Alignment.centerRight,
        width: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(icon: Icon(Icons.edit), tooltip: 'Edit', onPressed: ()=>{tagActions.updateTag(context)},),
            IconButton(icon: Icon(Icons.delete), tooltip: 'Delete', onPressed: ()=>{tagActions.deleteTag(context, false)},)
          ],
        ),
      ),
      onTap: (){},
    );
  }

}