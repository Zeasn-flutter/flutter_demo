import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',

      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map> imgList=[
    {
      "url":"https://pic2.zhimg.com/v2-848ed6d4e1c845b128d2ec719a39b275_b.jpg"
    },
    {
      "url":"https://pic2.zhimg.com/80/v2-40c024ce464642fcab3bbf1b0a233174_hd.jpg"
    },
    {
      "url":"https://pic4.zhimg.com/80/v2-9cf53967a3825fb27b4199b771cb692b_720w.jpg"
    },
    {
      "url":"https://pic3.zhimg.com/80/v2-130838b9c036021e3656b30b01e55ce2_720w.jpg"
    },
    {
      "url":"https://pic2.zhimg.com/80/v2-552354a50944d5146fdb42dfc692dd51_720w.jpg"
    },
    {
      "url":"http://picture.name/images/2019/01/24/21515938.jpg"
    }
  ];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body:  new Swiper(
        itemBuilder: (BuildContext context,int index){
          return Container(
              width: 300,
              child:AspectRatio(
                  aspectRatio:4.0/3.0,
                  child:Image.network(imgList[index]["url"],fit: BoxFit.cover,)
              )
          );
        },
        itemCount: imgList.length,
        pagination: new SwiperPagination(),//下面的分页小点
//        control: new SwiperControl(),  //左右的那个箭头,在某模拟器中会出现蓝线
      ),
    );
  }
}



//import 'package:flutter/material.dart';
//import 'package:flutter_swiper/flutter_swiper.dart';
//import 'package:frames/widgets/agency/agency_item_widget.dart';
//
//class SplashPage extends SimpleItemWidget {
//  // TODO: implement getBody
//  List imgList = [
//    "https://desk-fd.zol-img.com.cn/t_s1024x768c5/g5/M00/02/00/ChMkJlbKw1eIdabyAASvPG-H6SwAALG1gFD3VQABK9U648.jpg",
//    "https://desk-fd.zol-img.com.cn/t_s1024x768c5/g5/M00/02/00/ChMkJ1bKw1eILNybAAMnVXZZfj0AALG1gFIjKgAAydt911.jpg",
//    "https://desk-fd.zol-img.com.cn/t_s1024x768c5/g5/M00/02/00/ChMkJlbKw1eIe_ACAAS4xbkUZBoAALG1gFLtBUABLjd443.jpg",
//  ];
//
//  SplashPage() : super(null, null);
//
//  @override
//  Widget getBody(SimpleItemState state) {
//
//    return Scaffold(
//      body:
////      Swiper(
////        itemBuilder: (BuildContext context,int index){
////          return Image.network(
////              imgList[index],
////              fit: BoxFit.fitWidth);
////        },
////        itemCount: imgList.length,
////        pagination: SwiperPagination(),
////        control: SwiperControl(),
////      ),
//      Container(
//          width: MediaQuery.of(mContext).size.width,
//          height: 200.0,
//          child: Swiper(
//            itemBuilder: _swiperBuilder,
//            itemCount: imgList.length,
//            pagination: new SwiperPagination(
//                builder: DotSwiperPaginationBuilder(
//                  size: 2,
//                  activeSize: 5,
//                  color: Colors.black54,
//                  activeColor: Colors.white,
//                )),
////            control: new SwiperControl(),
//            scrollDirection: Axis.horizontal,
//            autoplay: true,
//            onTap: (index) => print('点击了第$index个'),
//          )),
//    );
//  }
//
//  Widget _swiperBuilder(BuildContext context, int index) {
//    return (Image.network(
//      imgList[index],
//      fit: BoxFit.fill,
//    ));
//  }
//
//}
