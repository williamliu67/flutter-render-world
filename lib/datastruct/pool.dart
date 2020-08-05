class SimplePool<T>{
	final List<T> pool;
	int poolSize = 0;

	SimplePool({int maxSize = -1}): pool = (maxSize == -1 ? List() : List(maxSize));

	T acquire(){
		if (poolSize > 0) {
			final int lastPooledIndex = poolSize - 1;
			T instance = pool[lastPooledIndex];
			pool[lastPooledIndex] = null;
			poolSize--;
			return instance;
		}
		return null;
	}

	bool release(T instance) {
		if (isInPool(instance)) {
			throw Exception("Already in the pool!");
		}
		if (poolSize < pool.length) {
			pool[poolSize] = instance;
			poolSize++;
			return true;
		}
		return false;
	}

	bool isInPool(T instance) {
		for (int i = 0; i < poolSize; i++) {
			if (pool[i] == instance) {
				return true;
			}
		}
		return false;
	}
}