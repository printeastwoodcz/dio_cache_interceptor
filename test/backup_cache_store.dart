import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import './common_store.dart' as common_store_test;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  common_store_test.runMain(
    'Common Backup store tests',
    BackupCacheStore(primary: MemCacheStore(), secondary: DbCacheStore()),
  );
}
