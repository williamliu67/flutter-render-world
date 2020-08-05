import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/render/renderview.dart';

class RenderRouterContainerParentData extends RenderVueGroupParentData<RouterContainerLayoutParams>{
	@override
  RouterContainerLayoutParams createDefaultLayoutParams() => RouterContainerLayoutParams();
}
class RenderRouterContainer extends RenderVueGroup<RenderRouterContainerParentData>{
	RouterContainer routerContainer;

	RenderRouterContainer(this.routerContainer): super(routerContainer) {
		print("RenderRouterContainer");
	}

	@override
	RenderRouterContainerParentData createDefaultParentData() => RenderRouterContainerParentData();

	@override
  void performLayout() {
    super.performLayout();
    print("RenderRouterContainer performLayout");
  }

	@override
	Size onMeasure(double width, double height,
		BoxConstraints childBoxConstraints, bool parentUsesChildWidth,
		bool parentUsesChildHeight) {
		RenderBox child = firstChild;
		double maxChildWidth = 0.0;
		double maxChildHeight = 0.0;
		while(child != null) {
			child.layout(childBoxConstraints, parentUsesSize: true);
			Size childSize = child.size;
			if (parentUsesChildWidth && childSize.width > maxChildWidth) {
				maxChildWidth = childSize.width;
			}
			if (parentUsesChildHeight && childSize.height > maxChildHeight) {
				maxChildHeight = childSize.height;
			}
			RenderRouterContainerParentData data = child.parentData;
			child = data.nextSibling;
		}

		if (parentUsesChildWidth) {
			width = maxChildWidth;
			width = width.clamp(constraints.minWidth, constraints.maxWidth);
		}
		if (parentUsesChildHeight) {
			height = maxChildHeight;
			height = width.clamp(constraints.minHeight, constraints.maxHeight);
		}
		return Size(width, height);
	}

		@override
  onDraw(PaintingContext context, Offset offset) {
    print("draw--------");
    return super.onDraw(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
	  print('position:' + position.toString());
	  bool hit = false;
	  if (firstChild == null) {
	  	return hit;
	  }
	  RenderVue child = lastChild;
	  if (position.dx <0 || position.dy < 0) {
		  return false;
	  }
	  position -= Offset(view.padding.left, view.padding.top);
	  RenderVueGroupParentData data = child.parentData;
	  hit = child.hitTest(result, position: position - data.offset);
	  if (hit) {
		  print('PageContainer hit---->' + child.toString());
	  }
	  return hit;
  }
}