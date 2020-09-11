


import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ap/BottomSheetWidget.dart';
import 'package:flutter_ap/HomeViewModel.dart';
import 'package:flutter_ap/trimmer_view.dart';
import 'package:flutter_ap/video_trimmer/video_trimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';


class DialogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);

    Size mSize = MediaQuery.of(context).size;
    //密度
    double mRatio = MediaQuery.of(context).devicePixelRatio;
    //设备像素
    double width = mSize.width * mRatio;
    double height = mSize.height * mRatio;

//    double height= mq.size.height*mq.devicePixelRatio;
//    double width = mq.size.width*mq.devicePixelRatio;
//    print(
//        'screen height==' + mq.size.height.toString()+" ,pixelRatio =="+mq.devicePixelRatio.toString()+" ,heig=="+height.toString());
//    print(
//        'screen height==' + height.toString()+" ,pixelRatio =="+mq.devicePixelRatio.toString()+" ,width=="+width.toString() +);
    print('screen height==' +
        height.toString() +
        " ,pixelRatio ==" +
        mRatio.toString() +
        " ,width==" +
        width.toString() +
        ", bottom==" +
        MediaQuery.of(context).viewPadding.bottom.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
//            _showDialog(context);

            showDialog(
                barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
                context: context,
                builder: (BuildContext context) {
                  var list = List();
                  list.add('意见与建议');
                  list.add('功能问题');
                  list.add('内容问题');
                  list.add('使用问题');
                  list.add('其他问题');
                  return BottomSheetWidget(
                    list: list,
                    onItemClickListener: (index) async {
                      print("==" + list[index]);
                      Navigator.pop(context);
                    },
                  );
                });
          },
          child: Text('点击显示弹窗'),
        ),
      ),
    );
  }
}

void _showDialog(widgetContext) {
  showCupertinoDialog(
    context: widgetContext,
    builder: (context) {
      return CupertinoAlertDialog(
//        title: Text('确认删除'),
        title: Text('确认删除'),
        content: Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
//                  border: InputBorder.none,

                    focusColor: Colors.orange,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    hintText: 'input wahatever you want',
                    hintStyle:
                    TextStyle(fontSize: 20.0, color: Colors.redAccent),
                    //设置提示文字样式
                    filled: true,
                    fillColor: Colors.transparent),
              ),
            ],
          ),
        ),

        actions: [
          CupertinoDialogAction(
            child: Text('确认'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text('取消'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//主页要展示的内容
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new GridViewState();
}

class GridViewState extends State {
  @override
  Widget build(BuildContext context) => new GridView.count(
      primary: false,
      padding: const EdgeInsets.all(8.0),
      mainAxisSpacing: 8.0,
      //竖向间距
      crossAxisCount: 2,
      //横向Item的个数
      crossAxisSpacing: 8.0,
      //横向间距
      children: buildGridTileList(5));

  List<Widget> buildGridTileList(int number) {
    List<Widget> widgetList = new List();
    for (int i = 0; i < number; i++) {
      widgetList.add(getItemWidget());
    }
    return widgetList;
  }

  String url =
      "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=495625508,"
      "3408544765&fm=27&gp=0.jpg";

  Widget getItemWidget() {
    //BoxFit 可设置展示图片时 的填充方式
    return new Image(image: new NetworkImage(url), fit: BoxFit.cover);
  }
}

class MyHOmeViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ViewModelBuilder<HomeViewModel>.reactive(
        onModelReady: (model) => model.initTitle(),
        builder: (context, model, child) => Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.access_time),
            onPressed: () {
              model.updateTitle();
            },
          ),
          body: Center(
            child: Text(model.title),
          ),
        ),
        viewModelBuilder: () => HomeViewModel());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
