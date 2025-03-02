import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orginone/component/unified_text_style.dart';

class IndexBar extends StatelessWidget {
  List<String> mData;
  int mCurrentIndex = -1;

  void Function(String str, int index, bool touchUp) indexBarCallBack;

  IndexBar({Key? key, required this.mData, required this.indexBarCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      color: Colors.transparent,
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onVerticalDragDown: (DragDownDetails detail) {
          int i = detail.localPosition.dy ~/ 20.h;
          print("--->滑动开始$i");
          _updateSelectIndex(i, false);
        },
        onVerticalDragUpdate: (DragUpdateDetails detail) {
          int i = detail.localPosition.dy ~/ 20.h;
          print('---> 拖动了$i');
          _updateSelectIndex(i, false);
        },
        onVerticalDragEnd: (DragEndDetails detail) {
          print("--->滑动结束i");
          _updateSelectIndex(-1, true);
        },
        onTapUp: (TapUpDetails detail) {
          _updateSelectIndex(-1, true);
        },
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: mData.length,
            itemBuilder: (context, index) {
              return Container(
                height: 20.h,
                width: 30.w,
                color: Colors.black12,
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      mData[index],
                      style: text12,
                    )),
              );
            }),
      ),
    );
  }

  /// 只有和上次选择不同且在范围之内的才有效
  _updateSelectIndex(int i, bool touchUp) {
    if (touchUp) {
      indexBarCallBack("", -1, touchUp);
    } else if (mCurrentIndex != i && i >= 0 && i < mData.length) {
      mCurrentIndex = i;
      indexBarCallBack(mData[mCurrentIndex], mCurrentIndex, touchUp);
    }
  }
}
