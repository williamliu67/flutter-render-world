import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/widgets.dart';
import 'package:flutter_render_world/render/renderview.dart';

class RenderTextView extends RenderVue{
  TextView textView;
  RenderParagraph _paragraph;

  RenderTextView(this.textView):super(textView){
    _paragraph = RenderParagraph(TextSpan(text: textView.message, style: textView.style),
        textDirection: TextDirection.ltr, maxLines: textView.maxLines);
    adoptChild(_paragraph);
  }

  updateContent(){
    _paragraph.text = TextSpan(text: textView.message, style: textView.style);
    markNeedsPaint();
  }

  @override
  Size onMeasure(double width, double height, BoxConstraints childBoxConstraints, bool parentUsesChildWidth, bool parentUsesChildHeight) {
    _paragraph.layout(childBoxConstraints, parentUsesSize: true);
    Size childSize = _paragraph.size;
    if (parentUsesChildWidth) {
      width = childSize.width + view.padding.horizontal;
      width = width.clamp(constraints.minWidth, constraints.maxWidth);
    }
    if (parentUsesChildHeight) {
      height = childSize.height + view.padding.vertical;
      height = height.clamp(constraints.minHeight, constraints.maxHeight);
    }
    return Size(width, height);
  }

  @override
  onDraw(PaintingContext context, Offset offset) {
    offset += Offset(view.padding.left, view.padding.top);
    context.paintChild(_paragraph, offset);
  }

  @override
  bool hitTestSelf(Offset position) {
    bool hit = super.hitTestSelf(position);
    if (hit) {
      if (textView.clickListener != null) {
        textView.clickListener(textView);
        print("text:" + textView.message);
        return true;
      }
    }
    return false;
  }
}