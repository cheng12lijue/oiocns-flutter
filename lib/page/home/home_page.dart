import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orginone/component/text_avatar.dart';
import 'package:orginone/component/unified_scaffold.dart';
import 'package:orginone/component/unified_text_style.dart';
import 'package:orginone/util/any_store_util.dart';
import 'package:orginone/util/sys_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../component/unified_colors.dart';
import '../../routers.dart';
import '../../util/hub_util.dart';
import '../../util/string_util.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initPermission(context);

    SysUtil.setStatusBarBright();
    controller.context = context;
    return UnifiedScaffold(
      appBarTitle: _title(context),
      appBarHeight: 10.h + 28.w + 5.h + 28.w + 5.h,
      body: _body,
      bottomNavigationBar: _bottomNavigatorBar,
    );
  }

  initPermission(BuildContext context) async {
    await [Permission.storage, Permission.notification].request();
  }

  Widget _popMenuItem(
    BuildContext context,
    IconData icon,
    String text,
    Function func,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        func();
      },
      child: SizedBox(
        height: 40.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            Container(
              margin: EdgeInsets.only(left: 20.w),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry> _popupMenus(BuildContext context) {
    return [
      PopupMenuItem(
        child: _popMenuItem(
          context,
          Icons.qr_code_scanner,
          "扫一扫",
          () async {
            Get.toNamed(Routers.scanning);
          },
        ),
      ),
      PopupMenuItem(
        child: _popMenuItem(
          context,
          Icons.group_add_outlined,
          "创建群组",
          () {},
        ),
      ),
      PopupMenuItem(
        child: _popMenuItem(
          context,
          Icons.groups_outlined,
          "创建单位",
          () {
            Get.toNamed(Routers.unitCreate);
          },
        ),
      ),
    ];
  }

  Widget _title(BuildContext context) {
    var userName = controller.user.userName;
    var userKeyWord = StringUtil.getPrefixChars(userName, count: 1);
    double x = 0, y = 0;
    return Column(
      children: [
        Container(margin: EdgeInsets.only(top: 10.h)),
        Row(
          children: [
            Expanded(
              child: GetBuilder<HomeController>(
                init: controller,
                builder: (controller) {
                  var spaceName = controller.currentSpace.name;
                  var spaceKeyWord =
                      StringUtil.getPrefixChars(spaceName, count: 1);
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(Routers.spaceChoose);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextAvatar(
                          radius: 28.w,
                          width: 28.w,
                          avatarName: spaceKeyWord,
                          textStyle: text16White,
                          margin: EdgeInsets.only(left: 20.w),
                        ),
                        Container(margin: EdgeInsets.only(left: 10.w)),
                        Text(
                          spaceName,
                          style: text16Bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(margin: EdgeInsets.only(left: 2.w)),
                        const Icon(Icons.arrow_drop_down, color: Colors.black)
                      ],
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                _conn(HubUtil().state, "会话"),
                Container(margin: EdgeInsets.only(top: 2.h)),
                _conn(AnyStoreUtil().state, "存储"),
              ],
            ),
            Container(margin: EdgeInsets.only(left: 10.w)),
            TextAvatar(
              radius: 28.w,
              width: 28.w,
              avatarName: userKeyWord,
              textStyle: text16White,
              margin: EdgeInsets.only(right: 20.w),
            ),
          ],
        ),
        Container(margin: EdgeInsets.only(top: 5.h)),
        Row(children: [
          Container(
            margin: EdgeInsets.only(left: 20.w),
            child: const Icon(Icons.read_more_outlined, color: Colors.black),
          ),
          Expanded(child: Container()),
          Container(
            margin: EdgeInsets.only(left: 10.w),
            child: GestureDetector(
                child: const Icon(Icons.search, color: Colors.black),
                onTap: () {
                  Get.toNamed(Routers.search);
                }),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.w),
            child: GestureDetector(
              child: const Icon(Icons.add, color: Colors.black),
              onPanDown: (position) {
                x = position.globalPosition.dx;
                y = position.globalPosition.dy;
              },
              onTap: () {
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        x - 20.w, y + 20.h, x + 20.w, y + 40.h),
                    items: _popupMenus(context));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.w, right: 20.w),
            child: const Icon(Icons.more_horiz, color: Colors.black),
          ),
        ])
      ],
    );
  }

  Widget _conn(Rx<HubConnectionState> status, String name) {
    return Row(
      children: [
        Obx(() {
          Color color;
          switch (status.value) {
            case HubConnectionState.connecting:
            case HubConnectionState.disconnecting:
            case HubConnectionState.reconnecting:
              color = Colors.yellow;
              break;
            case HubConnectionState.connected:
              color = Colors.greenAccent;
              break;
            default:
              color = Colors.redAccent;
          }
          return Icon(
            Icons.circle,
            size: 10,
            color: color,
          );
        }),
        Container(margin: EdgeInsets.only(left: 5.w)),
        Text(name, style: text10Bold),
      ],
    );
  }

  get _body => GFTabBarView(
      controller: controller.tabController,
      children: controller.tabs.map((e) => e.widget).toList());

  get _bottomNavigatorBar => Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(width: 0.5, color: Colors.black12)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFE8E8E8),
              offset: Offset(8, 8),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: GFTabBar(
          tabBarHeight: 70.h,
          indicatorColor: Colors.blueAccent,
          tabBarColor: UnifiedColors.easyGrey,
          labelColor: Colors.black,
          labelStyle: const TextStyle(fontSize: 12),
          length: controller.tabController.length,
          controller: controller.tabController,
          tabs: controller.tabs.map((e) => e.tab).toList(),
        ),
      );
}
