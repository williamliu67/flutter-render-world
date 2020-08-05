import 'package:flutter_render_world/page/page.dart';

///限制最大实例个数的栈
class CacheStack<T extends StackInstanceWrapper> {
	int _maxInstances;
	///历史记录
	List<StackRecordWrapper<T>> _history;
	StackRecordWrapperReleaseCallback callback;


	CacheStack(this._maxInstances, this.callback) : _history = List();

	String add(T instance) {
		String recordId = 'RecordID:${_history.length}';
		_history.add(new StackRecordWrapper(recordId, instance));
		if (_history.length > _maxInstances) {
			StackRecordWrapper item = _history[_history.length - 1 - _maxInstances];
			if (callback != null && item.instance != null) {
				callback(item);
			}
			item.instance = null;
		}
		return recordId;
	}

	///根据[recordId]移除栈内对应的record
	StackRecordWrapper<T> remove(String recordId) {
		int index = 0;
		for (StackRecordWrapper record in _history) {
			if (record.recordId == recordId) {
				_history.removeAt(index);
				if (callback != null && record.instance != null) {
					callback(record);
				}
				return record;
			}
			index ++;
		}
		return null;
	}

	StackRecordWrapper<T> removeLast() {
		return _history.removeLast();
	}

	void update(String recordId, T instance) {
		findByRecordId(recordId)?.instance = instance;
	}

	StackRecordWrapper<T> findByRecordId(String recordId) {
		for (StackRecordWrapper<T> record in _history) {
			if (record.recordId == recordId) {
				return record;
			}
		}
		return null;
	}

	void clear() {
		while(_history.isNotEmpty) {
			StackRecordWrapper recordWrapper = removeLast();
			if (callback != null && recordWrapper != null) {
				callback(recordWrapper);
			}
		}
	}

	StackRecordWrapper<T> get top => _history.length > 0 ? _history.last : null;

	StackRecordWrapper indexAt(int index) => _history[index];

	int get count => _history.length;
}

class StackInstanceWrapper{}

class StackRecordWrapper<T extends StackInstanceWrapper> {
	final String recordId;
	T instance;

	StackRecordWrapper(this.recordId, this.instance);
}

typedef StackRecordWrapperReleaseCallback = void Function(StackRecordWrapper record);