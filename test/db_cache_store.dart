import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

import './common_store.dart' as common_store_test;

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    return '.dart_tool';
  });
  const channelx = MethodChannel('com.tekartik.sqflite');
  channelx.setMockMethodCallHandler((MethodCall methodCall) async {
    print('method: ${methodCall.method} -> ${methodCall.arguments}');
    if (methodCall.method == 'getDatabasesPath') {
      return join('.dart_tool', 'test');
    }
  });
  // setMockDatabaseFactory(mockDatabaseFactory);
  var store = DbCacheStore();
  common_store_test.runMain('Common DB store tests', store);
}
