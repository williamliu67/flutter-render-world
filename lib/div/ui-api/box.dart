import 'package:flutter_render_world/div/ui-api/touch.dart';
import 'package:flutter_render_world/div/ui-config/box.dart';
import 'package:flutter_render_world/div/ui-config/div.dart';

///RenderBox与Box操作的桥梁
abstract class BoxApi {
  void attachRenderBox() {}

  void detachRenderBox() {}
}

mixin BoxUIApi on BoxApi{

  Box get box => null;

  set box(Box box) {
    ///TODO 更新RenderBox的box
  }

  set visible(Visible visible) => null;
  Visible get visible => Visible.Visible;
}

///代理了RenderBox的事件分发回调
mixin BoxTouchApi on BoxUIApi{

  set onClickListener(ClickListener clickListener) => null;
  get onClickListener => null;

  set onLongClickListener(LongClickListener longClickListener) => null;
  get onLongClickListener => null;

  set onTouchListener(TouchListener touchListener) => null;
  get onTouchListener => null;

  set clickable(bool clickable) => null;
  bool get clickable => true;
}

///RenderBox的对外API，RenderBox封装了对内的
class View extends BoxApi with BoxUIApi, BoxTouchApi {

}

class ViewGroup extends View {
  View findViewById(String id) => null;

  void addChild(DIV child) {}

  void addChildByIndex(int index, DIV child) {}

  void removeChild(DIV child) {}

  void removeChildByIndex(int index) {}

  void removeChildByID(String id) {}

  void removeAll() {}
}

