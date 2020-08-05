import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/render/renderview.dart';
import 'package:flutter_render_world/label/layout_compat.dart';

class RenderWeightLayoutParentData extends RenderVueGroupParentData<WeightLayoutParams>{
   @override
  WeightLayoutParams createDefaultLayoutParams() => WeightLayoutParams(1, xGravity: Gravity.center, yGravity: Gravity.center);
}

class RenderWeightLayout extends RenderVueGroup<RenderWeightLayoutParentData>{
  WeightLayout weightLayout;
  int childWeightSum;

  RenderWeightLayout(this.weightLayout):super(weightLayout){
    childWeightSum = 0;
    for (View view in weightLayout.children) {
      if (view.layoutParams is WeightLayoutParams) {
        childWeightSum += (view.layoutParams as WeightLayoutParams).weight;
      }
    }
  }

  @override
  Size onMeasure(double width, double height, BoxConstraints childBoxConstraints, bool parentUsesChildWidth, bool parentUsesChildHeight) {
    print("RenderWeightLayout onMeasure");
    int direction = weightLayout.direction;
    if (direction == 0) {
      return performLayoutVertical(width, height, childBoxConstraints, parentUsesChildWidth, parentUsesChildHeight);
    } else {
      return performLayoutHorizontal(width, height, childBoxConstraints, parentUsesChildWidth, parentUsesChildHeight);
    }
  }

  Size performLayoutVertical(double width, double height,
      BoxConstraints childBoxConstraints,
      bool parentUsesChildWidth, bool parentUsesChildHeight) {
    double contentHeight = childBoxConstraints.maxHeight;
    Offset parentOffset = Offset.zero;
    if (parentData is ContainerBoxParentData) {
      parentOffset = (parentData as ContainerBoxParentData).offset;
    }
    ///1.挨个遍历子节点，进行测量,计算出子节点的size，以及拥有最大宽度的子节点
    RenderVue child = firstChild;
    double maxChildWidth = 0.0;
    double dy = 0.0;
    while(child != null) {
      RenderWeightLayoutParentData data = child.parentData;
      data.offset = Offset.zero;
      WeightLayoutParams lp = data.lp;
      ///根据weight计算子节点的高度
      double childHeight = lp.weight / childWeightSum * contentHeight;
      child.view.heightSpec = SizeSpec.wrapContent();
      child.layout(childBoxConstraints.copyWith(minHeight: childHeight, maxHeight: childHeight), parentUsesSize: true);
      Size childSize = child.size;
      if (parentUsesChildWidth && childSize.width > maxChildWidth) {
        maxChildWidth = childSize.width;
      }
      dy += childHeight;
      data.offset += parentOffset + Offset(0, dy);
      child = data.nextSibling;
    }
    ///根据子节点中最大的width，计算出WeightLayout的宽度
    if (parentUsesChildWidth) {
      width = maxChildWidth + weightLayout.margin.horizontal + weightLayout.padding.horizontal;
      width = width.clamp(constraints.minWidth, constraints.maxWidth);
    }
    ///2.根据字节的layoutGravity，计算出它的offset
    child = firstChild;
    while(child != null) {
      Size childSize = child.size;
      RenderWeightLayoutParentData data = child.parentData;
      WeightLayoutParams lp = data.lp;
      if (lp.xGravity == Gravity.left) {

      } else if (lp.xGravity == Gravity.center) {
        double xOffset = (width - weightLayout.margin.horizontal - weightLayout.padding.horizontal - childSize.width)/2;
        data.offset += Offset(xOffset, 0);
      } else  if (lp.xGravity == Gravity.right) {
        double xOffset = width - weightLayout.margin.horizontal - weightLayout.padding.horizontal - child.size.width;
        data.offset += Offset(xOffset, 0);
      }
      child = data.nextSibling;
    }
    return Size(width, contentHeight + weightLayout.padding.vertical +
        weightLayout.padding.vertical);
  }

  Size performLayoutHorizontal(double width, double height,
      BoxConstraints childBoxConstraints,
      bool parentUsesChildWidth, bool parentUsesChildHeight) {

    double contentWidth = childBoxConstraints.maxWidth;
    Offset parentOffset = Offset.zero;
    if (parentData is ContainerBoxParentData) {
      parentOffset = (parentData as ContainerBoxParentData).offset;
    }
    ///1.挨个遍历子节点，进行测量,计算出子节点的size，以及拥有最大高度的子节点
    RenderVue child = firstChild;
    double maxChildHeight = 0.0;
    double dx = 0.0;
    while(child != null) {
      RenderWeightLayoutParentData data = child.parentData;
      data.offset = Offset.zero;
      WeightLayoutParams lp = data.lp;
      double childWidth = lp.weight / childWeightSum * contentWidth;
      child.view.widthSpec = SizeSpec.wrapContent();
      child.layout(childBoxConstraints.copyWith(minWidth: childWidth, maxWidth: childWidth), parentUsesSize: true);
      Size childSize = child.size;
      if (parentUsesChildHeight && childSize.height > maxChildHeight) {
        maxChildHeight = childSize.height;
      }
      data.offset += parentOffset + Offset(dx, 0);
      dx += childWidth;
      child = data.nextSibling;
    }
    ///根据子节点中最大的height，计算出WeightLayout的高度
    if (parentUsesChildHeight) {
      height = maxChildHeight + weightLayout.margin.vertical + weightLayout.padding.vertical;
      height = height.clamp(constraints.minHeight, constraints.maxHeight);
    }
    ///2.根据字节的layoutGravity，计算出它的offset
    child = firstChild;
    while(child != null) {
      Size childSize = child.size;
      RenderWeightLayoutParentData data = child.parentData;
      WeightLayoutParams lp = data.lp;
      if (lp.yGravity == Gravity.top) {

      } else if (lp.yGravity == Gravity.center) {
        double yOffset = (height - weightLayout.margin.vertical - weightLayout.padding.vertical - childSize.height)/2;
        data.offset += Offset(0, yOffset);
      } else  if (lp.yGravity == Gravity.bottom) {
        double yOffset = height - weightLayout.margin.vertical - weightLayout.padding.vertical - child.size.height;
        data.offset += Offset(0, yOffset);
      }
      child = data.nextSibling;
    }
    return Size(contentWidth + weightLayout.padding.horizontal +
        weightLayout.padding.horizontal, height);
  }

  @override
  RenderWeightLayoutParentData createDefaultParentData() => RenderWeightLayoutParentData();
}