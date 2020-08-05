import 'dart:ui';

import 'package:flutter_render_world/datastruct/cachestack.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/page/page.dart';

class RouterConfig {
	int _maxPageCache;
	List<PageRouter> _routers;

	RouterConfig(this._maxPageCache, this._routers);

	int get maxPageCache => _maxPageCache < 1 ? 1 : _maxPageCache;

	List<PageRouter> get routers => _routers??[];
}

class PageRecordInstanceWrapper extends StackInstanceWrapper {
	Page page;
	PageRecordInstanceWrapper(this.page);
}

///只负责页面栈的管理，与生命周期的切换，不参与状态保存与恢复等逻辑
mixin RouterContext {
	///当前RouterContext的路由表
	Map<String, PageRouter> _routers = Map();
	CacheStack<PageRecordInstanceWrapper> _history;
	Map<String, PageIntent> _intentCaches = Map();
	bool _hasInited = false;
	///启动器分配的PageContainer容器
	RouterContainer _rootView;

	bindRouterContainer(RouterContainer container) {
		_rootView = _rootView??container;
		_rootView.routerContext = this;
	}

	configRouters(RouterConfig routerConfig) {
		if (_hasInited) {
			return;
		}
		_hasInited = true;
		List<PageRouter> routers = routerConfig.routers;
		for (PageRouter router in routers) {
			_routers[router.path] = router;
		}
		_history = CacheStack(routerConfig.maxPageCache, (record) {
			///当有PageRecord超过配置的最大缓存数量时，要释放掉前面的instance
			PageRecordInstanceWrapper instanceWrapper = record.instance;
			print("CacheStack ${instanceWrapper.toString()} is Release！");
			_rootView.removeChild(instanceWrapper?.page?.content);
			instanceWrapper?.page?.moveToState(PageState.destroy);
		});
	}

	destroy() {
		_history.clear();
		_routers.clear();
		_rootView.removeAll();
	}

	void start(PageIntent intent){
		if (!_checkRouterTable(intent)) {
			throw Exception('当前的router[' + intent.router + ']不在注册的路由表中，请先注册');
		}
		if (intent.routerFlag == RouterFlag.standard) {
			_processStartStandard(intent, null);
		} else if (intent.routerFlag == RouterFlag.singleTop) {
			_processStartSingleTop(intent);
		} else if (intent.routerFlag == RouterFlag.singleTask) {
			_processStartSingleTask(intent);
		} else if (intent.routerFlag == RouterFlag.singleInstance) {
			_processStartSingleInstance(intent);
		} else {
			_processStartStandard(intent, null);
		}
	}

	void finish(String recordId) {
		print('$recordId ? ${_history.top?.recordId}');
		bool isTop = _history.top?.recordId == recordId;
		_history.remove(recordId);
		if (!isTop) {
			return;
		}
		bool needReInstance = _history.top?.instance == null;
		if (!needReInstance) {
			_history.top?.instance?.page?.moveToState(PageState.resume);
			print('${_history.top?.instance?.page?.toString()} move to resume');
			return;
		}
		if (_history.top == null) {
			return;
		}
		recordId = _history.top.recordId;
		PageIntent intent = _intentCaches[recordId];
		if (intent == null) {
			return;
		}
		_processStartStandard(intent, recordId);
	}

	bool _checkRouterTable(PageIntent intent) {
		if ((intent.router??"") == "") {
			return false;
		}
		if (!_routers.containsKey(intent.router)) {
			return false;
		}
		return true;
	}

	_processStartStandard(PageIntent intent, String recordId) {
		PageRouter pageRouter = _routers[intent.router];
		Page page = pageRouter.createPage();
		if (page == null) {
			throw Exception('Create Page By PageIntent[$intent] Exception!!!');
		}
		_history.top?.instance?.page?.moveToState(PageState.stop);
		print("${_history.top?.instance?.page?.toString()} move to stop");
		PageRecordInstanceWrapper record = PageRecordInstanceWrapper(page);
		if (recordId == null) {
			recordId = _history.add(record);
		} else {
			_history.update(recordId, record);
		}
		page.init(this, recordId);
		page.moveToState(PageState.create);
		///将页面的ContentView添加到PageContainer容器中
		_rootView.addChild(page.content);
		page.moveToState(PageState.start);
		///新页面获取到了焦点
		page.moveToState(PageState.resume);
	}

	_processStartSingleTop(PageIntent intent) {
		String recordId = _history.top?.recordId;
		if (recordId != null) {
			bool isTop = _intentCaches[recordId].router == intent.router;
			if (isTop) {
				///理论上位于顶部的
				_history.top?.instance?.page?.intent = intent;
				_history.top?.instance?.page?.onNewIntent(intent);
				return;
			}
		}
		_processStartStandard(intent, null);
	}

	_processStartSingleTask(PageIntent intent) {
		///判断是否位于栈顶，位于栈顶的话，不用执行生命周期
		String recordId = _history.top?.recordId;
		if (recordId != null && _intentCaches[recordId].router == intent.router) {
			_history.top.instance.page.onNewIntent(intent);
			return;
		}
		///判断是否位于栈中
		int inStackIndex = -1;
		for (int i = _history.count - 1; i >= 0; i --) {
			bool inStack = _intentCaches[_history.indexAt(i).recordId]?.router == intent.router;
			if (inStack) {
				inStackIndex = i;
				break;
			}
		}

		if(inStackIndex > 0) {
			while (_history.count -1 > inStackIndex) {
				_history.removeLast();
			}
			if (_history.top.instance != null) {
				_history.top.instance.page.intent = intent;
				_history.top.instance.page.onNewIntent(intent);
			} else {
				_processStartStandard(intent, _history.top.recordId);
			}
			return;
		}
		_processStartStandard(intent, null);
	}

	_processStartSingleInstance(PageIntent intent) {

	}
}