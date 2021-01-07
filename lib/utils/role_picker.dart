import 'package:flutter/material.dart';
import 'package:mydeca_web/utils/theme.dart';

class RolePicker extends StatefulWidget {

  List<String> initialRoles = [];
  Function onChanged;
  String maxAssignable = "";

  RolePicker(this.initialRoles, this.onChanged, this.maxAssignable);

  @override
  _RolePickerState createState() => _RolePickerState(this.initialRoles, this.onChanged, this.maxAssignable);
}

class _RolePickerState extends State<RolePicker> {

  List<String> initialRoles = [];
  List<String> roles = [];
  List<Widget> roleWidgetList = [];
  Map<String, bool> rolesMap = {};
  Function(List<String> list) onChanged;
  String maxAssignable = "";

  _RolePickerState(this.initialRoles, this.onChanged, this.maxAssignable);

  @override
  void initState() {
    super.initState();
    roleColors.forEach((key, value) {
      setState(() {
        roles.add(key);
      });
    });
    roles.reversed.forEach((element) {
      setState(() {
        initialRoles.contains(element) ? rolesMap[element] = true : rolesMap[element] = false;
      });
    });
  }

  void returnList() {
    List<String> list = [];
    rolesMap.keys.forEach((key) {
      if (rolesMap[key]){
        list.add(key);
      }
    });
    onChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        children: [
          new Text("Select your roles below:"),
          new Column(
            children: roles.map((e) => new Visibility(
              visible: maxAssignable == "" || (roles.indexOf(maxAssignable) >= roles.indexOf(e)),
              child: new ListTile(
                title: new Text(e),
                leading: Icon(rolesMap[e] ? Icons.check_box : Icons.check_box_outline_blank, color: mainColor,),
                onTap: () {
                  setState(() {
                    rolesMap[e] = !rolesMap[e];
                  });
                  returnList();
                },
              ),
            )).toList(),
          )
        ],
      ),
    );
  }
}
