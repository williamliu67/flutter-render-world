import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/render/renderview.dart';

class RenderScrollLayoutParentData extends RenderVueGroupParentData<ScrollViewLayoutParams>{
	@override
	ScrollViewLayoutParams createDefaultLayoutParams() => ScrollViewLayoutParams();
}

class RenderScrollLayout extends RenderVueGroup<RenderScrollLayoutParentData>{
	ScrollView scrollView;

	RenderScrollLayout(ScrollView scrollView): super(scrollView) {
		checkChildCount();
	}

	@override
	RenderScrollLayoutParentData createDefaultParentData() => RenderScrollLayoutParentData();

	@override
  Size onMeasure(double width, double height, BoxConstraints childBoxConstraints, bool parentUsesChildWidth, bool parentUsesChildHeight) {
    return super.onMeasure(width, height, childBoxConstraints, parentUsesChildWidth, parentUsesChildHeight);
  }

  void checkChildCount() {
		if (childCount > 1) {
			throw Exception('ScrollView只允许有一个子View');
		}
  }
}