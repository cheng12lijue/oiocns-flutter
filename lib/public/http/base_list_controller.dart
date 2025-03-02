import 'package:flutter/material.dart';
import 'package:orginone/public/http/base_controller.dart';
import 'package:orginone/public/loading/load_status.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../api_resp/page_resp.dart';

abstract class BaseListController<T> extends BaseController {
  /// 列表数据容器
  List<T> dataList = [];

  /// 刷新控制器
  RefreshController refreshController = RefreshController();

  /// 下拉刷新使用
  void onRefresh();

  /// 加载更多使用
  void onLoadMore();

  /// isRefresh true 刷新 false 加载更多
  /// pageResp PageResp
  /// 添加数据&自动判断列表刷新和更多对应的头和脚状态
  void addData(bool isRefresh, PageResp<T> pageResp) {
    if (isRefresh) {
      dataList.clear();
      dataList.addAll(pageResp.result);
      refreshController.refreshCompleted(resetFooterState: true);
      if (dataList.isEmpty) {
        //加载空页面
        updateLoadStatus(LoadStatusX.empty);
        return;
      } else {
        debugPrint("---更新了");
        updateLoadStatus(LoadStatusX.success);
      }

      /// 无更多
      if (dataList.length >= pageResp.total) {
        refreshController.loadComplete();
        refreshController.loadNoData();
      }
    } else {
      dataList.addAll(pageResp.result);
      refreshController.loadComplete();

      /// 无更多
      if (dataList.length >= pageResp.total) {
        refreshController.loadNoData();
      }
    }
    update();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }
}
