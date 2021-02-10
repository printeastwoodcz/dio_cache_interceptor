import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import './common_store_test.dart' as common_store_test;

void main() {
  common_store_test.main('Common DB store tests', DbCacheStore());
}
