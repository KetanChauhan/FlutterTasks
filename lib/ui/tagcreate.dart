import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/task-models.dart';
import 'package:flutter_tasks/service/dataservice.dart';

class TagCreatePage extends StatefulWidget {
  DataService dataService = DataService();
  RefreshDataCall refreshDataCall;
  Tag tag;
  bool isUpdate = false;

  TagCreatePage(Tag tag, bool isUpdate, RefreshDataCall refreshDataCall){
    this.tag = isUpdate ? tag : Tag.getDefault();
    this.isUpdate = isUpdate;
    this.refreshDataCall = refreshDataCall;
  }

  @override
  _TagCreatePageState createState() => _TagCreatePageState(tag, isUpdate, refreshDataCall);
}

class _TagCreatePageState extends State<TagCreatePage> {
  DataService dataService = DataService();
  Tag tag;
  bool isUpdate = false;
  RefreshDataCall refreshDataCall;
  bool isProcessing = false;

  _TagCreatePageState(this.tag, this.isUpdate, this.refreshDataCall);

  void updateName(String name){
    tag.name = name;
    setState((){});
  }

  void updateColorString(String color){
    tag.color = color;
    setState((){});
    print(tag);
  }

  void updateColor(Color color){
    updateColorString(HexColor.fromColor(color).toHex());
  }

  void createTag(BuildContext context){
    if(!_isValidTag()){
      return;
    }
    setState((){isProcessing = true;});
    dataService.createTag(tag).then((operationResponse) {
      print('createTag done '+operationResponse.toString());
      print('createTag done '+operationResponse.success.toString());
      if(operationResponse.success==true){
        print('Tag created ');
        showMessage(context, 'Tag created');
        Navigator.of(context).pop();
        refreshDataCall();
      }else{
        print('Tag created error ');
        showMessage(context, 'Error occured');
      }
      setState((){isProcessing = false;});
    });
  }

  void updateTag(BuildContext context){
    if(!_isValidTag()){
      return;
    }
    setState((){isProcessing = true;});
    dataService.updateTag(tag).then((operationResponse) {
      print('createTag done '+operationResponse.toString());
      if(operationResponse.success){
        showMessage(context, 'Tag updated');
        Navigator.of(context).pop();
        refreshDataCall();
      }else{
        showMessage(context, 'Error occured');
      }
      setState((){isProcessing = false;});
    });
  }

  bool _isValidTag(){
    if(tag.name.trim().isEmpty){
        showMessage(context, 'Please provide name.');
        return false;
    }
    return true;
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
        title: Text(isUpdate ? 'Update Tag' : 'Create Tag'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              if(!isProcessing){
                isUpdate ? updateTag(context) : createTag(context);
              }
            },
            color: isProcessing ? Colors.black12 : Colors.white,
          ),
        ],
      ),
      body: getTagCreateView(),
    );
  }

  Widget getTagCreateView(){
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FractionColumnWidth(0.3),
              1: FractionColumnWidth(0.7),
            },
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Text('Tag Name'),),
                  Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(0),
                    child: TextFormField(onChanged: updateName, initialValue: tag.name,)
                  ),
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
                  Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(10), child: Text('Color'),),
                  Container(alignment: Alignment.centerLeft, padding: EdgeInsets.all(0),
                    child: ColorPicker(
                      pickersEnabled: {ColorPickerType.primary:true,ColorPickerType.accent:false,},
                      enableShadesSelection: true,
                      subheading: Divider(height: 1,),
                      color: HexColor(tag.color),
                      onColorChanged: (Color color) =>
                          updateColor(color),
                    ),
                  ),
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
      ]
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