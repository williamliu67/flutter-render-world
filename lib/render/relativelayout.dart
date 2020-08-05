import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:flutter_render_world/datastruct/pool.dart';
import 'package:flutter_render_world/datastruct/sparsearray.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/render/renderview.dart';

class RenderRelativeLayoutParentData
	extends RenderVueGroupParentData<RelativeLayoutParams> {
	RelativeLayoutParams lp;
	double left = -1.0;
	double right = -1.0;
	double top = -1.0;
	double bottom = -1.0;
}

class RenderRelativeLayout
	extends RenderVueGroup<RenderRelativeLayoutParentData> {
	RelativeLayout relativeLayout;
	DependencyGraph graph;

	///水平方向的ViewRoot
	List<View> sortedHorizontalChildren;

	///垂直方向的ViewRoot
	List<View> sortedVerticalChildren;

	/// 是否需要重新sort子节点，当子view中有子view的依赖发生变化时，需要重新排列
	bool dirtyHierarchy;

	static final List<RelativeRuleType> rulesVertical = [
		RelativeRuleType.toAboveOf, RelativeRuleType.toBelowOf,
		RelativeRuleType.alignTop, RelativeRuleType.alignBottom
	];

	static final List<RelativeRuleType> rulesHorizontal = [
		RelativeRuleType.toLeftOf, RelativeRuleType.toRightOf,
		RelativeRuleType.alignLeft, RelativeRuleType.alignRight,
	];

	///[rulesHorizontalByParent][rulesVerticalByParent]布局优先级
  ///要高于[rulesHorizontal]与[rulesVertical]
  ///如果一个View拥有[rulesHorizontalByParent]中的布局约束，也可以作为ViewRoot
  static final List<RelativeRuleType> rulesHorizontalByParent = [
    RelativeRuleType.alignParentLeft, RelativeRuleType.alignParentRight,
    RelativeRuleType.centerHorizontal,
  ];

  static final List<RelativeRuleType> rulesVerticalByParent = [
    RelativeRuleType.alignParentTop, RelativeRuleType.alignParentBottom,
    RelativeRuleType.centerVertical, RelativeRuleType.centerParent,
  ];

	@override
	RenderRelativeLayoutParentData createDefaultParentData() =>
		RenderRelativeLayoutParentData();

	RenderRelativeLayout(this.relativeLayout)
		: graph = DependencyGraph(),
			super(relativeLayout);

	@override
	Size onMeasure(double width, double height,
		BoxConstraints childBoxConstraints, bool parentUsesChildWidth,
		bool parentUsesChildHeight) {
		if (dirtyHierarchy) {
			dirtyHierarchy = false;
			sortChildren();
		}
		for (View view in sortedHorizontalChildren) {
			applyHorizontalSizeRules(view, childBoxConstraints);
		}
		for (View view in sortedVerticalChildren) {
      applyVerticalSizeRules(view, childBoxConstraints);
    }
    ///遍历过上面的循环，所有的View的位置都可以确定了
    double widthTemp = 0.0;
    double heightTemp = 0.0;
    RenderVue child = firstChild;
		while(child != null) {
		  RenderRelativeLayoutParentData data = child.parentData;
		  double minWidth;
		  double maxWidth;
      double minHeight;
      double maxHeight;
		  if (data.left >= 0 && data.right >= 0) {
        minWidth = maxWidth = data.right - data.left;
      } else if (data.left < 0 && data.right < 0) {
        minWidth = childBoxConstraints.minWidth;
        maxWidth = childBoxConstraints.maxWidth;
      } else if (data.left < 0) {
        minWidth = 0;
        maxWidth = data.right;
      } else {
        minWidth = 0;
        maxWidth = childBoxConstraints.maxWidth - data.left;
      }

      if (data.top >= 0 && data.bottom >= 0) {
        minHeight = maxHeight = data.bottom - data.top;
      } else if (data.top < 0 && data.bottom < 0) {
        minHeight = childBoxConstraints.minHeight;
        maxHeight = childBoxConstraints.maxHeight;
      } else if (data.top < 0) {
        minHeight = 0;
        maxHeight = data.bottom;
      } else {
        minHeight = 0;
        maxHeight = childBoxConstraints.maxHeight - data.top;
      }
      BoxConstraints constraints = BoxConstraints(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);
      child.layout(constraints, parentUsesSize: true);
      Size childSize = child.size;

      Offset offset = Offset.zero;
      if (data.left >= 0) {
        offset += Offset(data.left, 0);
      } else if (data.right >= 0) {
        offset += Offset(data.right - childSize.width, 0);
      }
      if (data.top >= 0) {
        offset += Offset(0, data.top);
      } else if (data.bottom >= 0) {
        offset += Offset(0, data.bottom - childSize.height);
      }
      data.offset = offset;
      widthTemp = math.max(widthTemp, childSize.width);
      heightTemp = math.max(heightTemp, childSize.height);
		  child = data.nextSibling;
    }
		return Size(widthTemp, heightTemp);
	}

	/// 排列子view，找出依赖树
	void sortChildren() {
		graph.clear();
		for (View view in relativeLayout.children) {
			graph.add(view);
		}
		sortedVerticalChildren = graph.getSortedViews(rulesVertical);
		sortedHorizontalChildren = graph.getSortedViews(rulesHorizontal);
	}

	void applyHorizontalSizeRules(View view, BoxConstraints constraints) {
		RelativeLayoutParams lp = view.layoutParams;
		List<RelativeRule> rules = lp.rules;
		RenderVue child = view.renderVue;
		RenderRelativeLayoutParentData data = child.parentData;
		double left = -1;
		double right = -1;
		for (RelativeRule rule in rules) {
		  if (rule.isVertical) {
		    continue;
      }
      View anchorView = getRelatedView(view, rule);
      if (anchorView == null) {
      	///TODO 没有依赖任何View，需要计算起left与right
	      if (rule.ruleType == RelativeRuleType.alignParentLeft) {
	      	left = view.margin.left;
	      } else if (rule.ruleType == RelativeRuleType.alignParentRight) {
	      	right = constraints.maxWidth - view.margin.right;
	      } else if (rule.ruleType == RelativeRuleType.centerHorizontal
		      || rule.ruleType == RelativeRuleType.centerParent) {

	      }
        continue;
      }
      RenderVue anchorVue = anchorView.renderVue;
      RenderRelativeLayoutParentData anchorData = anchorVue.parentData;
      ///TODO 此时的anchorVue还没有
      if(rule.ruleType == RelativeRuleType.toLeftOf) {
        right = anchorData.left - anchorView.margin.left - view.margin.right;
      } else if (rule.ruleType == RelativeRuleType.toRightOf) {
        left = anchorData.right + anchorView.margin.right + view.margin.left;
      } else if (rule.ruleType == RelativeRuleType.alignLeft) {
        left = anchorData.left;
      } else if (rule.ruleType == RelativeRuleType.alignRight) {
        right = anchorData.right;
      }
    }
		if (left == -1 && right == -1) {
			left = view.margin.left;
		}
		///遍历完改View的所有限制条件，这个View的水平大小以及位置就可以定位了
    data.left = left;
    data.right = right;
    child.parentData = data;
	}

	void applyVerticalSizeRules(View view, BoxConstraints constraints) {
    RelativeLayoutParams lp = view.layoutParams;
    List<RelativeRule> rules = lp.rules;
    RenderVue child = view.renderVue;
    RenderRelativeLayoutParentData data = child.parentData;
    double top = -1;
    double bottom = -1;
    for (RelativeRule rule in rules) {
      if (rule.isHorizontal) {
        continue;
      }
      View anchorView = getRelatedView(view, rule);
      if (anchorView == null) {
        continue;
      }
      RenderVue anchorVue = anchorView.renderVue;
      RenderRelativeLayoutParentData anchorData = anchorVue.parentData;
      if(rule.ruleType == RelativeRuleType.toAboveOf) {
        top = anchorData.top - anchorView.margin.top - view.margin.bottom;
      } else if (rule.ruleType == RelativeRuleType.toBelowOf) {
        top = anchorData.bottom + anchorView.margin.bottom + view.margin.top;
      } else if (rule.ruleType == RelativeRuleType.alignTop) {
        top = anchorData.top;
      } else if (rule.ruleType == RelativeRuleType.alignBottom) {
        bottom = anchorData.bottom;
      }
    }
    data.top = top;
    data.bottom = bottom;
    child.parentData = data;
  }

	View getRelatedView(View view, RelativeRule rule) {
		ID id = rule.id;
		if (id != ID.NO_ID) {
			Node node = graph.keyNodes.get(id);
			if (node != null) {
				return node.view;
			}
		}
		return null;
	}

	@override
	void markNeedsLayout() {
		dirtyHierarchy = true;
		super.markNeedsLayout();
	}
}

/// 依赖树
class DependencyGraph {
	///所有的view节点，不考虑是否拥有ID
	List<Node> nodes = List();

	/// 所有拥有ID的Node
	SparseArray<ID, Node> keyNodes = SparseArray(Node.acquire(null));

	/// 不依赖其他node的节点集合
	List<Node> roots = List();

	void clear() {
		final List<Node> nodes = this.nodes;
		final int count = nodes.length;

		for (int i = 0; i < count; i++) {
			nodes[i].release();
		}
		nodes.clear();
		keyNodes.clear();
		roots.clear();
	}

	void add(View view) {
		ID id = view.id;
		Node node = Node.acquire(view);

		if (id != ID.NO_ID) {
			keyNodes.put(id, node);
		}

		nodes.add(node);
	}

	List<View> getSortedViews(List<RelativeRuleType> typeFilters) {
		List<View> sorted = List();
		List<Node> roots = findRoots(typeFilters);

		int index = 0;
		Node node;
		while (roots.isNotEmpty && (node = roots?.removeLast()) != null) {
			View view = node.view;
			ID key = view.id;
			sorted.add(view);
			index = index + 1;

			/// 依赖当前节点的集合
			Map<Node, DependencyGraph> dependents = node
				.dependents;
			int count = dependents.length;
			List<Node> keys = dependents.keys.toList();
			/// 遍历依赖当前节点的集合，
			for (int i = 0; i < count; i++) {
				Node dependent = keys[i];
				SparseArray<ID, Node> dependencies = dependent.dependencies;
				dependencies.delete(key);
				if (dependencies.size == 0) {
					roots.add(dependent);
				}
			}
			/*if (roots.length > 0) {
				node = roots[roots.length - 1];
			} else {
				node = null;
			}*/
			if (index < sorted.length) {
				throw new Exception(
					"Circular dependencies cannot exist in RelativeLayout");
			}
		}
		return sorted;
	}

	List<Node> findRoots(List<RelativeRuleType> typeFilters) {
		SparseArray<ID, Node> keyNodes = this.keyNodes;
		List<Node> nodes = this.nodes;
		for (Node node in nodes) {
			if (!(node.view.layoutParams is RelativeLayoutParams)) {
				continue;
			}
			RelativeLayoutParams lp = node.view.layoutParams;
			List<RelativeRule> rules = lp.rules;
			int rulesCount = typeFilters.length;

			for (int i = 0; i < rulesCount; i++) {
				RelativeRuleType filter = typeFilters[i];
				for (RelativeRule rule in rules) {
					/// 判断当前的view是否有此种filter类型的
					if (rule.ruleType == filter) {
						ID id = rule.id;
						/// 找出ID对应的view node
						Node dependency = keyNodes.get(id);
						if (dependency == null || dependency == node) {
							continue;
						}
						/// 添加dependency的被依赖者
						dependency.dependents[node] = this;
						/// 为当前node添加依赖
						node.dependencies.put(id, dependency);
					}
				}
			}
		}
		List<Node> roots = List();
		for (Node node in nodes) {
			if (node.dependencies.size == 0) {
				roots.add(node);
			}
		}
		return roots;
	}
}

class Node {
	View view;
	Map<Node, DependencyGraph> dependents;
	SparseArray<ID, Node> dependencies;
	static const int POOL_LIMIT = 100;
	static SimplePool<Node> sPool = SimplePool(maxSize: POOL_LIMIT);

	Node(View view): this.view = view, dependents = Map(), dependencies = SparseArray(null);

	static Node acquire(View view) {
		Node node = sPool.acquire();
		if (node == null) {
			node = new Node(view);
		} else {
			node._flush();
			node.view = view;
		}
		return node;
	}

	release() {
		_flush();
		sPool.release(this);
	}

	_flush() {
		view = null;
		dependents?.clear();
		dependencies?.clear();
	}
}