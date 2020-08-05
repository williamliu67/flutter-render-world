class StateTable<R, C, V> {
	Map<StateKey<R, C>, V> _stateTable;

	StateTable(this._stateTable);

	V get(R r, C c) => _stateTable[StateKey(r, c)];
}

class StateKey<R, C> {
	R r;
	C c;

	StateKey(this.r, this.c);

	bool operator == (Object obj) {
		if (obj is StateKey) {
			return obj.r == r && obj.c == c;
		}
		return false;
	}

	@override
  int get hashCode => 0;
}

class StateTableBuilder<R, C, V> {
	Map<StateKey<R, C>, V> _map;

	StateTableBuilder(): _map = Map();

	put(R r, C c, V v) => _map[StateKey(r, c)] = v;

	StateTable<R, C, V> build() => StateTable(_map);
}

typedef onState<T> = void Function(T state);

class StateMachine<T> {
	StateTable<T, T, List<T>> _table;

	StateMachine(StateTableBuilder<T, T, List<T>> builder): _table = builder.build();

	moveToState(T from, T target, onState<T> callBack) {
		if (from == target) {
			print("$from==$target");
			return;
		}

		List<T> states = _table.get(from, target);
		if (states == null) {
			throw Exception("不能从$from跳到$target");
		}

		for (T state in states) {
			callBack(state);
		}
	}
}