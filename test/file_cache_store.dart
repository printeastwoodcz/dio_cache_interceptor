import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

import './common_store.dart' as common_store_test;

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    return '.';
  });
  final store = FileCacheStore(await getApplicationDocumentsDirectory());
  common_store_test.runMain('Common File store tests', store);
}
