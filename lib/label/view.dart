import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/datastruct/sparsearray.dart';
import 'package:flutter_render_world/gesture/callback.dart';
import 'package:flutter_render_world/render/renderview.dart';
import 'package:flutter_render_world/label/layout_compat.dart';

///View以及View的子类，并非是真正参与渲染的节点，真正参与渲染的节点是RenderVue
///没有直接使用RenderVue，而额外设计一套View的目的有如下
///1.延时渲染：
///我们在书写页面时，手写需要书写布局，然后在书写布局时，我们希望它绝对的轻量，不希望占用过多内存，
///只有在真正参与渲染时，才将RenderVue创建出来，所以设计了[View.createRenderVue]方法
///
/// 2.作为View的接口限制，这样可以更好的将渲染机制与具体业务分离开
///
/// 3.
class ID extends SparseKey<ID>{
  static final ID NO_ID = ID('no_id');
  String name;

  ID(this.name);

  bool operator < (ID key) => value < key.value;

  bool operator > (ID key) => value > key.value;

  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ID &&
      this.name == other.name;
  }


  @override
  int get hashCode => name.hashCode;

  int get value => name.hashCode;
}

abstract class LayoutParams{
}

class View<T extends LayoutParams> {
  SizeSpec widthSpec;
  SizeSpec heightSpec;
  Color background;
  EdgeInsets padding = EdgeInsets.all(0.0);
  EdgeInsets margin = EdgeInsets.all(0.0);
  Border border;
  BorderRadius borderRadius;
  T layoutParams;
  LayoutGravity contentGravity;

  RenderBox createRenderBox() => null;
  OnClickListener clickListener;
  OnTouchEventListener touchListener;
  ID id = ID.NO_ID;
  RenderVue _renderVue;

  RenderVue get renderVue => _renderVue??=createRenderVue();

  View(this.widthSpec, this.heightSpec);

  RenderVue createRenderVue() => RenderVue(this);

  void invalidate() => _renderVue?.markNeedsPaint();

  void requestLayout() => _renderVue?.markNeedsLayout();

  View findViewById(ID id) {
    if (this.id != ID.NO_ID && this.id == id) {
      return this;
    }
    return findViewTraversal(id);
  }

  View findViewTraversal(ID id) => null;
}

abstract class ViewGroup<T extends LayoutParams> extends View{
  List<View<T>> children;

  int get childCount => children.length;

  ViewGroup(SizeSpec width, SizeSpec height): children = List(), super(width, height);

  View findViewTraversal(ID id) {
    View find = super.findViewTraversal(id);
    if (find != null) {
      return find;
    }
    for(View view in children) {
      print('findViewTraversal:${view.toString()}');
      View result = view.findViewById(id);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  void addChild(View child){
    children.add(child);
    (renderVue as RenderVueGroup).add(child.renderVue);
  }

  View removeChildAt(int index) {
    View child = children.removeAt(index);
    if (child != null) {
      renderVue.dropChild(child.renderVue);
      return child;
    }
    return null;
  }

  View removeLast() {
    return removeChildAt(childCount - 1);
  }

  void removeChild(View view) {
    if (view == null) {
      return;
    }
    for (int i = 0, n = childCount; i< n; i++) {
      View child = children[i];
      if (child == view) {
        (renderVue as RenderVueGroup).remove(child.renderVue);
        children.removeAt(i);
        break;
      }
    }
  }

  void removeAll() {
    while(children.isNotEmpty) {
      removeLast();
    }
  }
}

