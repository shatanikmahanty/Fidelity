import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

import '../blocs/menu_provider.dart';

class MenuScreen extends StatefulWidget {
  final List<MenuItem> mainMenu;
  final Function(int) callback;
  final int current;

  MenuScreen(
    this.mainMenu, {
    Key key,
    this.callback,
    this.current,
  });

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  Widget build(BuildContext context) {
    MenuProvider mp = Provider.of<MenuProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (dragEndDetails) {
          if (dragEndDetails.primaryVelocity < 0) {
            ZoomDrawer.of(context).toggle();
            mp.menuOpened(false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xffb38728),
                Color(0xffD2AC47),
                Color(0xfffbf5B7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                !mp.isMenuOpen
                    ? SizedBox()
                    : IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.black,
                          semanticLabel: "Close Menu",
                        ),
                        onPressed: () {
                          ZoomDrawer.of(context).toggle();
                          mp.menuOpened(false);
                        },
                      ),
                Spacer(),
                Selector<MenuProvider, int>(
                  selector: (_, provider) => provider.currentPage,
                  builder: (_, index, __) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ...widget.mainMenu
                          .map((item) => MenuItemWidget(
                                key: Key(item.index.toString()),
                                item: item,
                                callback: widget.callback,
                                selected: index == item.index,
                              ))
                          .toList()
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final Function callback;
  final bool selected;

  const MenuItemWidget(
      {Key key, this.item,this.callback, this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextButton(
        // color: selected ? Colors.white38 : null,
        style: ButtonStyle(
          backgroundColor: selected ? MaterialStateProperty.all<Color>(Colors.white38 ) : null,
        ),
        onPressed: () => callback(item.index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 8,),
              Icon(
                item.icon,
                color: Colors.black,
                size: 24,
              ),
              SizedBox(width: 16,),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final int index;

  const MenuItem(this.title, this.icon, this.index);
}
