import 'package:flutter_test/flutter_test.dart';

import 'db_cache_store_test.dart' as db_store_test;
import 'file_cache_store_test.dart' as file_store_test;
import 'mem_cache_store_test.dart' as mem_store_test;
import 'backup_cache_store_test.dart' as backup_store_test;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  db_store_test.main();
  file_store_test.main();
  mem_store_test.main();
  backup_store_test.main();
}
