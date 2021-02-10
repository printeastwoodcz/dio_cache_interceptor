import 'package:flutter_test/flutter_test.dart';

import 'file_cache_store.dart' as file_store_test;
import 'mem_cache_store.dart' as mem_store_test;
import 'models.dart' as models_test;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  file_store_test.main();
  mem_store_test.main();
  models_test.main();
}
