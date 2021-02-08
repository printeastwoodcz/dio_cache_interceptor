import '../../dio_cache_interceptor.dart';

/// A store saving responses in a dedicated memory LRU map.
///
class MemCacheStore extends CacheStore {
  final _LruMap _cache;

  /// [maxSize]: Total allowed size in bytes (7MB by default)
  /// [maxEntrySize]: Allowed size per entry in bytes (500KB by default).
  ///
  /// To prevent making this store useless, be sure to
  /// respect the following lower-limit rule: maxEntrySize * 5 <= maxSize.
  ///
  MemCacheStore({
    int maxSize = 7340032,
    int maxEntrySize = 512000,
  }) : _cache = _LruMap(maxSize, maxEntrySize);

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) {
    final keys = List<String>();

    _cache.entries.forEach((key, resp) {
      var shouldRemove = resp.value.priority.index <= priorityOrBelow.index;
      if (staleOnly && resp.value.maxStale != null) {
        shouldRemove &= DateTime.now().toUtc().isAfter(resp.value.maxStale);
      }

      if (shouldRemove) {
        keys.add(key);
      }
    });

    keys.forEach((key) => _cache.remove(key));

    return Future.value();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) {
    final resp = _cache.entries[key];
    if (resp == null) return Future.value();
    final maxStale = resp.value.maxStale;

    if (staleOnly &&
        maxStale != null &&
        DateTime.now().toUtc().isBefore(maxStale)) {
      return Future.value();
    }

    _cache.remove(key);

    return Future.value();
  }

  @override
  Future<bool> exists(String key) {
    return Future.value(_cache.entries.containsKey(key));
  }

  @override
  Future<CacheResponse> get(String key) async {
    final resp = _cache[key];
    if (resp == null) return Future.value();

    // Purge entry if stalled
    final maxStale = resp.maxStale;
    if (maxStale != null) {
      if (DateTime.now().toUtc().isAfter(maxStale)) {
        await delete(key);
        return Future.value();
      }
    }

    return Future.value(resp);
  }

  @override
  Future<List<CacheResponse>> getAll() async {
    var items = _cache.entries.values.map((e) => e.value).toList();
    return Future.value(items);
  }

  @override
  Future<void> set(CacheResponse response) {
    _cache.remove(response.key);
    _cache[response.key] = response;

    return Future.value();
  }
}

class _LruMap {
  _Link _head;
  _Link _tail;

  final entries = <String, _Link>{};

  int _currentSize = 0;
  final int maxSize;
  final int maxEntrySize;

  _LruMap(this.maxSize, this.maxEntrySize) {
    assert(maxEntrySize != null);
    assert(maxEntrySize != maxSize);
    assert(maxEntrySize * 5 <= maxSize);
  }

  CacheResponse operator [](String key) {
    final entry = entries[key];
    if (entry == null) return null;

    _moveToHead(entry);
    return entry.value;
  }

  void operator []=(String key, CacheResponse resp) {
    final entrySize = _computeSize(resp);
    // Entry too heavy, skip it
    if (entrySize > maxEntrySize) return;

    final entry = _Link(key, resp, entrySize);

    entries[key] = entry;
    _currentSize += entry.size;
    _moveToHead(entry);

    while (_currentSize > maxSize) {
      assert(_tail != null);
      remove(_tail.key);
    }
  }

  CacheResponse remove(String key) {
    final entry = entries[key];
    if (entry == null) return null;

    _currentSize -= entry.size;
    entries.remove(key);

    if (entry == _tail) {
      _tail = entry.next;
      _tail?.previous = null;
    }
    if (entry == _head) {
      _head = entry.previous;
      _head?.next = null;
    }

    return entry.value;
  }

  void _moveToHead(_Link link) {
    if (link == _head) return;

    if (link == _tail) {
      _tail = link.next;
    }

    if (link.previous != null) {
      link.previous.next = link.next;
    }
    if (link.next != null) {
      link.next.previous = link.previous;
    }

    _head?.next = link;
    link.previous = _head;
    _head = link;
    _tail ??= link;
    link.next = null;
  }

  int _computeSize(CacheResponse resp) {
    var size = resp.content?.length ?? 0;
    size += resp.headers?.length ?? 0;

    return size * 8;
  }
}

class _Link implements MapEntry<String, CacheResponse> {
  _Link next;
  _Link previous;

  final int size;

  @override
  final String key;

  @override
  final CacheResponse value;

  _Link(this.key, this.value, this.size);
}
