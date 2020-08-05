import 'package:flutter/material.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/module_system/lego.dart';
import 'package:flutter_render_world/module_system/router.dart';
import 'package:flutter_render_world/page/page_view.dart';
import 'package:flutter_render_world/util/state_machine.dart';

///记录当前页面的状态，这些状态主要用来辅助页面管理，
///ps：这些状态与onNewIntent，savedInstance等都没有关系
enum PageState {
	///Page被实例化，做一些初始化的工作，为Page准备一些上下文信息等
	init,
	///初始化工作完成，做一些view的准备工作
	create,
	///Page自身的View已经添加到了ViewTree上，并已经显示
	start,
	///当前Page获取到了焦点，焦点决定事件是否分发
	resume,
	///当前Page失去了焦点，ex：当前Page被Dialog盖住
	pause,
	///当前Page不可见了，即当前Page不在是栈顶
	stop,
	///当前Page销毁了，ex：1.超出页面栈最大数量，被StackManager回收 2.用户手动finish
	destroy,
}

/// 负责管理页面生命周期
mixin PageStateManager {
	StateMachine<PageState> _stateMachine;
	/// 当前页面生命周期
	PageState _state;
	PageLifecycle _pageLifecycle;

	initPageStateManager(PageLifecycle pageLifecycle) {
		_pageLifecycle = pageLifecycle;
		_state = PageState.init;
		_initStateTable();
	}

	_initStateTable() {
		StateTableBuilder<PageState, PageState, List<PageState>> builder = StateTableBuilder<PageState, PageState, List<PageState>>()
			/// 从0-1启动一个页面
			..put(PageState.init, PageState.create, [PageState.create])
			..put(PageState.create, PageState.start, [PageState.start])
			..put(PageState.start, PageState.resume, [PageState.resume])
			/// 页面失去焦点，例如弹出了弹窗
			..put(PageState.resume, PageState.pause, [PageState.pause])
			/// 当前页面由栈顶变为了次栈顶
			..put(PageState.pause, PageState.stop, [PageState.stop])
			/// 超出StackManger的最大Page实例缓存数量时，或者用户手动finish
			..put(PageState.stop, PageState.destroy, [PageState.destroy])
			/// 当弹窗消失时，原栈顶页面的生命周期变化路径
			..put(PageState.pause, PageState.resume, [PageState.resume])
			/// 当栈顶页面出栈时，次栈顶页面的生命周期变化路径
			..put(PageState.stop, PageState.resume, [PageState.start, PageState.resume])
			/// 当启动新页面时，原来栈顶页面的生命周期变化路径
			..put(PageState.resume, PageState.stop, [PageState.pause, PageState.stop])
			/// 用户手动finish掉页面时的生命周期路径
			..put(PageState.create, PageState.destroy, [PageState.start, PageState.resume, PageState.pause, PageState.stop, PageState.destroy])
			..put(PageState.start, PageState.destroy, [PageState.resume, PageState.pause, PageState.stop, PageState.destroy])
			..put(PageState.resume, PageState.destroy, [PageState.pause, PageState.stop, PageState.destroy])
			..put(PageState.pause, PageState.destroy, [PageState.stop, PageState.destroy])
			..put(PageState.stop, PageState.destroy, [PageState.destroy]);

		_stateMachine = StateMachine<PageState>(builder);
	}

	moveToState(PageState target) {
		_stateMachine.moveToState(_state, target, (state) {
			this._state = state;
			switch (state) {
				case PageState.create:
					_pageLifecycle._createInterval();
					break;
				case PageState.start:
					_pageLifecycle._startInterval();
					break;
				case PageState.resume:
					_pageLifecycle._resumeInterval();
					break;
				case PageState.pause:
					_pageLifecycle._pauseInterval();
					break;
				case PageState.stop:
					_pageLifecycle._stopInterval();
					break;
				case PageState.destroy:
					_pageLifecycle._destroyInterval();
					break;
				default:
			}
		});
	}
}

mixin PageLifecycle {
	_createInterval(){
		onCreate();
	}

	_startInterval(){
		onStart();
	}

	_resumeInterval(){
		onResume();
	}

	_pauseInterval(){
		onPause();
	}

	_stopInterval(){
		onStop();
	}

	_destroyInterval(){
		onDestroy();
	}

	void onCreate(){}

	void onStart(){}

	void onResume(){}

	void onPause(){}

	void onStop(){}

	void onDestroy(){}

	onSavedInstancesInterval(Map savedInstances){}

	onRestoreInstancesInterval(Map savedInstances){}
}

mixin StackContextApi {
	RouterContext _context;
	String _recordId;

	start(PageIntent intent) => _context?.start(intent);

	finish() => _context?.finish(_recordId);
}

class Page with PageLifecycle, PageStateManager, StackContextApi{
	PageIntent intent;
	///当前Page的View
	FrameLayout _content = FrameLayout(SizeSpec.matchParent(), SizeSpec.matchParent())
		..background = Colors.transparent;

	Page() {
		initPageStateManager(this);
	}

	init(Context context, String recordId) {
		_context = context;
		_recordId = recordId;
	}

	View get content => _content;

	String get recordId => _recordId;

	onNewIntent(PageIntent intent) {}

	void setContentView(View content) {
		_content.children.add(content);
	}

	View findViewById(ID id) => _content.findViewById(id);
}

class PageRecordItem {
	String recordId;
	PageIntent intent;

	PageRecordItem(this.recordId, this.intent);
}

class PageIntent{
	String router;
	Map params;
	RouterFlag routerFlag;
}

///Page启动模式
enum RouterFlag{
	standard,
	singleTop,
	singleTask,
	singleInstance
}

typedef Page CreatePage();
class PageRouter{
	final String path;
	CreatePage createPage;
	bool export;
	PageRouter(this.path, this.createPage, {this.export = false});
}