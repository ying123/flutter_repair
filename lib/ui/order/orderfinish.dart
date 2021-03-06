import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_refresh/flutter_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:repair_project/entity/order.dart';
import 'package:repair_project/entity/qoinfo.dart';
import 'package:repair_project/http/HttpUtils.dart';
import 'package:repair_project/http/api_request.dart';
import 'package:repair_project/ui/order/bottom_bar_helper.dart';
import 'package:repair_project/ui/order/order_assess.dart';
import 'package:repair_project/ui/order/order_detail_bean/orders.dart';
import 'package:repair_project/ui/order/order_details.dart';
import 'package:repair_project/ui/order/order_list_bean/page.dart';
import 'package:repair_project/ui/order/rfqorderdetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderFinish extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OrderFinishState();
  }
}

class OrderFinishState extends State<OrderFinish>
    with AutomaticKeepAliveClientMixin {
  int nowPage = 1;
  int limit = 5;
  int total = 0;
  List<Orders> _finishedOrders = [];

  @override
  void initState() {
    getFinishedOrder(nowPage, limit);
    super.initState();
  }

  //已完成订单列表
  Future<void> getFinishedOrder(int nowPage, int limit) async {
    Page page = await ApiRequest().getOrderListForDiffType(context,nowPage, limit, "four"); //"four" represents for 已完成
    if(mounted){
      setState(() {
        _finishedOrders.addAll(page.orders);
        total = page.total;
      });
      print(total);
    }
  }

  //下拉刷新
  Future<Null> onHeaderRefresh() {
    return new Future.delayed(new Duration(seconds: 2), () {
      setState(() {
        nowPage = 1;
        limit = 5;
        _finishedOrders.clear();
        getFinishedOrder(nowPage, limit);
      });
    });
  }

  //上拉加载更多
  Future<Null> onFooterRefresh() {
    return new Future.delayed(new Duration(seconds: 2), () {
      setState(() {
        nowPage += 1;
        //limit += 5;
        if (_finishedOrders.length > total) {
          Fluttertoast.showToast(msg: "没有更多的订单了");
        } else {
          getFinishedOrder(nowPage, limit);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        //color: Colors.grey[200],
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Refresh(
            onFooterRefresh: onFooterRefresh,
            onHeaderRefresh: onHeaderRefresh,
            child: ListView.builder(
                  itemCount: _finishedOrders.length==0? 1:_finishedOrders.length,
                  itemBuilder: (context, index) {
                    if(_finishedOrders.length==0){
                      return Center(child: Text("暂无相关数据~"),);
                    }
                    var finishOrder = _finishedOrders[index];
                    return Padding(
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                onTap: () => Navigator.push(context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return OrderDetails(orderId: finishOrder.id);
                                        })),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding:
                                        EdgeInsets.only(top: 5, bottom: 20),
                                        child: Text(finishOrder.description, style: TextStyle(fontSize: 18, color: Colors.black))),
                                    Text("#" + finishOrder.type, style: TextStyle(color: Colors.lightBlue),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 5, bottom: 5),
                                        child: Text(finishOrder.createTime, style: TextStyle(color: Colors.grey))),
                                    Divider(
                                      height: 2,
                                      color: Colors.grey,
                                    ),
                                    Align(
                                        alignment: FractionalOffset.bottomRight,
                                        child: finishOrder.orderState==35?
                                            BottomBarHelper().buildWaitingForFeedbackButton(context, finishOrder.orderNumber, finishOrder.id):
                                            BottomBarHelper().buildStatusButton("已评价")
                                        )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                  })

    ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
