import 'package:clockapp/enums.dart';
import 'package:clockapp/views/alarm_page.dart';
import 'package:clockapp/views/clock_page.dart';
import 'package:clockapp/menu_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2F41),
      body: Row(
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: menuItems
                  .map((currentMenuInfo) => buildMenuButton(currentMenuInfo))
                  .toList()),
          VerticalDivider(
            color: Colors.white54,
            width: 1,
          ),
          Expanded(
            child: Consumer<MenuInfo>(
                builder: (BuildContext context, MenuInfo value, child) {
              if (value.menuType == MenuType.clock) {
                return ClockPage();
              } else if (value.menuType == MenuType.alarm) {
                return AlarmPage();
              }
              return Container(
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(text: 'Upcoming After!'),
                    TextSpan(text: value.title)
                  ]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
        builder: (BuildContext context, MenuInfo value, child) {
      // print(value.menuType);
      return TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(32))),
              backgroundColor: currentMenuInfo.menuType == value.menuType
                  ? Colors.black38
                  : Colors.transparent),
          onPressed: () {
            //value.updateMenu se bi rebiuld lai
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);
            menuInfo.updateMenu(currentMenuInfo);
          },
          child: Column(
            children: [
              Image.asset(
                currentMenuInfo.imageSource!,
                scale: 1.5,
              ),
              SizedBox(height: 16),
              Text(
                currentMenuInfo.title!,
                style: TextStyle(color: Colors.white, fontSize: 14),
              )
            ],
          ));
    });
  }
}
