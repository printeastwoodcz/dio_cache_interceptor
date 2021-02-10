import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import './common_store.dart' as common_store_test;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var store = MemCacheStore();
  common_store_test.runMain('Common Mem store tests', store);
}
