
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/module_system/router.dart';
import 'package:flutter_render_world/render/framelayout.dart';
import 'package:flutter_render_world/render/linearlayout.dart';
import 'package:flutter_render_world/render/relativelayout.dart';
import 'package:flutter_render_world/render/rendercontainer.dart';
import 'package:flutter_render_world/render/scrolllayout.dart';
import 'package:flutter_render_world/render/weightlayout.dart';

class LinearLayoutParams extends LayoutParams{
  Gravity _xGravity;
  Gravity _yGravity;

  LinearLayoutParams({Gravity xGravity, Gravity yGravity}){
    _xGravity = xGravity;
    _yGravity = yGravity;
  }

  Gravity get xGravity => _xGravity??=Gravity.left;
  Gravity get yGravity => _yGravity??=Gravity.top;
}

class LinearLayout<LinearLayoutParams> extends ViewGroup{
  int direction = 0;

  LinearLayout.vertical(SizeSpec width, SizeSpec height)
      : direction = 0, super(width, height);

  LinearLayout.horizontal(SizeSpec width, SizeSpec height)
      : direction = 1, super(width, height);

  @override
  RenderLinearLayout createRenderVue() => RenderLinearLayout(this);
}

class WeightLayoutParams extends LinearLayoutParams{
  int weight;

  WeightLayoutParams(this.weight, {Gravity xGravity, Gravity yGravity})
      : super(xGravity: xGravity, yGravity: yGravity){
    assert(weight > 0);
  }
}

class WeightLayout<WeightLayoutParams> extends ViewGroup{
  int direction = 0;

  WeightLayout.vertical(SizeSpec width, SizeSpec height)
      : direction = 0, super(width, height);

  WeightLayout.horizontal(SizeSpec width, SizeSpec height)
      : direction = 1, super(width, height);

  @override
  RenderWeightLayout createRenderVue() => RenderWeightLayout(this);
}

class FrameLayoutParams extends LayoutParams{
  Gravity _xGravity;
  Gravity _yGravity;

  FrameLayoutParams({Gravity xGravity, Gravity yGravity}){
  _xGravity = xGravity;
  _yGravity = yGravity;
  }

  Gravity get xGravity => _xGravity??=Gravity.left;
  Gravity get yGravity => _yGravity??=Gravity.top;
}

class FrameLayout<T extends FrameLayoutParams> extends ViewGroup{

  FrameLayout(SizeSpec width, SizeSpec height)
      : super(width, height);

  @override
  RenderFrameLayout createRenderVue() => RenderFrameLayout(this);
}

class RelativeLayoutParams extends LayoutParams{
  List<RelativeRule> rules;

  RelativeLayoutParams(this.rules);
}

class RelativeRule{
  RelativeRuleType ruleType;
  ID id;
  RelativeRule.toRightOf(this.id): ruleType = RelativeRuleType.toRightOf;

  RelativeRule.toLeftOf(this.id): ruleType = RelativeRuleType.toLeftOf;

  RelativeRule.toBelowOf(this.id): ruleType = RelativeRuleType.toBelowOf;

  RelativeRule.toAboveOf(this.id): ruleType = RelativeRuleType.toAboveOf;

  RelativeRule.alignLeft(this.id): ruleType = RelativeRuleType.alignLeft;

  RelativeRule.alignRight(this.id): ruleType = RelativeRuleType.alignRight;

  RelativeRule.alignTop(this.id): ruleType = RelativeRuleType.alignTop;

  RelativeRule.alignBottom(this.id): ruleType = RelativeRuleType.alignBottom;

  RelativeRule.alignParentLeft(): id = ID.NO_ID, ruleType = RelativeRuleType.alignParentLeft;

  RelativeRule.alignParentRight(): id = ID.NO_ID, ruleType = RelativeRuleType.alignParentRight;

  RelativeRule.alignParentTop(): id = ID.NO_ID, ruleType = RelativeRuleType.alignParentTop;

  RelativeRule.alignParentBottom(): id = ID.NO_ID, ruleType = RelativeRuleType.alignParentBottom;

  RelativeRule.centerParent(): id = ID.NO_ID, ruleType = RelativeRuleType.centerParent;

  RelativeRule.centerVertical(): id = ID.NO_ID, ruleType = RelativeRuleType.centerVertical;

  RelativeRule.centerHorizontal(): id = ID.NO_ID, ruleType = RelativeRuleType.centerHorizontal;

  bool get isHorizontal => ruleType == RelativeRuleType.toRightOf
    || ruleType == RelativeRuleType.toLeftOf
    || ruleType == RelativeRuleType.alignLeft
    || ruleType == RelativeRuleType.alignRight
    || ruleType == RelativeRuleType.alignParentLeft
    || ruleType == RelativeRuleType.alignParentRight
    || ruleType == RelativeRuleType.centerHorizontal;

  bool get isVertical => ruleType == RelativeRuleType.toBelowOf
    || ruleType == RelativeRuleType.toAboveOf
    || ruleType == RelativeRuleType.alignTop
    || ruleType == RelativeRuleType.alignBottom
    || ruleType == RelativeRuleType.alignParentTop
    || ruleType == RelativeRuleType.alignParentBottom
    || ruleType == RelativeRuleType.centerVertical;
}

enum RelativeRuleType{
  toRightOf, toLeftOf, toBelowOf, toAboveOf,
  alignLeft, alignRight, alignTop, alignBottom,
  alignParentLeft, alignParentRight, alignParentTop, alignParentBottom,
  centerParent, centerVertical, centerHorizontal
}

class  RelativeLayout extends ViewGroup{
  RelativeLayout(SizeSpec width, SizeSpec height): super(width, height);

  @override
  RenderRelativeLayout createRenderVue() => RenderRelativeLayout(this);
}

class RouterContainerLayoutParams extends LayoutParams{}

class RouterContainer<RouterContainerLayoutParams> extends ViewGroup {

  RouterContainer(SizeSpec width, SizeSpec height): super(width, height);

  set routerContext(RouterContext routerContext) {}

  @override
  RenderRouterContainer createRenderVue() => RenderRouterContainer(this);
}

class ScrollViewLayoutParams extends LayoutParams{}

class ScrollView<ScrollViewLayoutParams> extends ViewGroup {

  ScrollView(SizeSpec width, SizeSpec height): super(width, height);

  @override
  RenderScrollLayout createRenderVue() => RenderScrollLayout(this);
}