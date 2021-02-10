import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DateTime dateTime;
  CacheControl cacheControll;
  CacheOptions cacheOptions;
  CacheResponse cacheResponse;
  setUp(() {
    dateTime = DateTime.now();
    cacheControll = CacheControl(maxAge: 20000);
    cacheOptions = CacheOptions(policy: CachePolicy.cacheFirst);
    cacheResponse = CacheResponse(
        cacheControl: cacheControll,
        key: 'key',
        date: dateTime.add(Duration(days: 2)),
        content: <int>[],
        responseDate: dateTime,
        expires: dateTime.add(Duration(days: 4)),
        maxStale: dateTime.add(Duration(days: 4)),
        eTag: '',
        url: '',
        priority: CachePriority.normal,
        lastModified: '',
        headers: <int>[]);
  });

  tearDown(() {});

  test('initial state is correct', () {
    expect(cacheControll.maxAge, 20000);
    expect(cacheOptions.policy, CachePolicy.cacheFirst);
    expect(cacheResponse.cacheControl, cacheControll);
  });
}
