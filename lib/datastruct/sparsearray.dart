import 'dart:math';

abstract class SparseKey<T> {
  bool operator < (T key);

  bool operator > (T key);

  bool operator ==(Object key);
}

class SparseArray<T extends SparseKey, E>{
  List<T> keys;
  List<E> values;
  int _size;
  E deleted;
  bool _garbage = false;

  SparseArray(this.deleted): keys = List(), values = List(), _size = 0;

  E get(T key) => getWithDefault(key, null);

  E getWithDefault(T key, E defaultValue) {
    int i = ContainerHelpers.binarySearch(keys, size, key);
    if (i < 0 || values[i] == deleted) {
      return defaultValue;
    } else {
      return values[i];
    }
  }

  void delete(T key) {
    int i = ContainerHelpers.binarySearch(keys, size, key);
    if (i >= 0) {
      if (values[i] != deleted) {
        values[i] = deleted;
        _garbage = true;
      }
    }
  }

  E deleteReturn(T key) {
    int i = ContainerHelpers.binarySearch(keys, size, key);
    if (i >= 0) {
      if (values[i] != deleted) {
        E old = values[i];
        values[i] = deleted;
        _garbage = true;
        return old;
      }
    }
    return null;
  }

  deleteAt(int index) {
    if (values[index] != deleted) {
      values[index] = deleted;
      _garbage = true;
    }
  }

  deleteAtRange(int index, int size) {
    final int end = min(size, index + size);
    for (int i = index; i < end; i++) {
      deleteAt(i);
    }
  }

  _gc() {
    int n = _size;
    int o = 0;

    for (int i = 0; i < n; i++) {
      Object val = values[i];
      if (val != deleted) {
        if (i != o) {
          keys[o] = keys[i];
          values[o] = val;
          values[i] = null;
        }

        o++;
      }
    }

    _garbage = false;
    _size = o;
  }

  void put(T key, E value) {
    int i = ContainerHelpers.binarySearch(keys, size, key);

    if (i >= 0) {
      values[i] = value;
    } else {
      i = ~i;

      if (i < _size && values[i] == deleted) {
        keys[i] = key;
        values[i] = value;
        return;
      }

      if (_garbage && _size >= keys.length) {
        _gc();

        // Search again because indices may have changed.
        i = ~ContainerHelpers.binarySearch(keys, _size, key);
      }

      keys.add(key);
      values.add(value);
      _size++;
    }
  }

  int get size {
    if (_garbage) {
      _gc();
    }
    return _size;
  }

  T keyAt(int index) {
    if (_garbage) {
      _gc();
    }
    return keys[index];
  }

  E valueAt(int index) {
    if (_garbage) {
      _gc();
    }
    return values[index];
  }

  void setValueAt(int index, E value) {
    if (_garbage) {
      _gc();
    }

    values[index] = value;
  }

  int indexOfKey(T key){
    if (_garbage) {
      _gc();
    }

    return ContainerHelpers.binarySearch(keys, size, key);
  }

  int indexOfValue(E value) {
    if (_garbage) {
      _gc();
    }

    for (int i = 0; i < size; i++) {
      if (values[i] == value) {
        return i;
      }
    }

    return -1;
  }

  void clear() {
    int n = size;
    List<E> values = this.values;

    for (int i = 0; i < n; i++) {
      values[i] = null;
    }

    _size = 0;
    _garbage = false;
  }

  void append(T key, E value) {
    if (size != 0 && (key < keys[size - 1] || key == keys[size - 1])) {
      put(key, value);
      return;
    }

    if (_garbage && size >= keys.length) {
      _gc();
    }

    keys.add(key);
    values.add(value);
    _size++;
  }
}

class ContainerHelpers{
  static int binarySearch<T extends SparseKey>(List<T> array, int size, T value) {
    int lo = 0;
    int hi = size - 1;
    ///二分法
    while (lo <= hi) {
      final int mid = (lo + hi) >> 1;
      final T midVal = array[mid];
      if (midVal < value) {
        lo = mid + 1;
      } else if (midVal > value) {
        hi = mid - 1;
      } else {
        return mid; // value found
      }
    }
    return ~lo; // value not
  }


}