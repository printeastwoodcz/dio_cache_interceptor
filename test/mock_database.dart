import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/src/constant.dart';
import 'package:sqflite_common/src/database.dart';
import 'package:sqflite_common/src/mixin.dart';

class MockDatabase extends SqfliteDatabaseBase {
  MockDatabase(SqfliteDatabaseOpenHelper openHelper, [String name])
      : super(openHelper, name);

  int version;
  List<String> methods = <String>[];
  List<String> sqls = <String>[];
  List<Map<String, dynamic>> argumentsLists = <Map<String, dynamic>>[];

  @override
  Future<T> invokeMethod<T>(String method, [dynamic arguments]) async {
    // return super.invokeMethod(method, arguments);

    methods.add(method);
    if (arguments is Map) {
      argumentsLists.add(arguments.cast<String, dynamic>());
      if (arguments[paramOperations] != null) {
        final operations =
            arguments[paramOperations] as List<Map<String, dynamic>>;
        for (var operation in operations) {
          final sql = operation[paramSql] as String;
          sqls.add(sql);
        }
      } else {
        final sql = arguments[paramSql] as String;
        sqls.add(sql);

        // Basic version handling
        if (sql?.startsWith('PRAGMA user_version = ') == true) {
          version = int.tryParse(sql.split(' ').last);
        } else if (sql == 'PRAGMA user_version') {
          return <Map<String, dynamic>>[
            <String, dynamic>{'user_version': version}
          ] as T;
        }
      }
    } else {
      argumentsLists.add(null);
      sqls.add(null);
    }
    //devPrint('$method $arguments');
    return null;
  }
}

class MockDatabaseFactory extends SqfliteDatabaseFactoryBase {
  final List<String> methods = <String>[];
  final List<dynamic> argumentsList = <dynamic>[];
  final Map<String, MockDatabase> databases = <String, MockDatabase>{};

  @override
  Future<T> invokeMethod<T>(String method, [dynamic arguments]) {
    methods.add(method);
    argumentsList.add(arguments);
    return null;
  }

  SqfliteDatabase newEmptyDatabase() {
    final helper = SqfliteDatabaseOpenHelper(this, null, OpenDatabaseOptions());
    final db = helper.newDatabase(null);
    return db;
  }

  @override
  SqfliteDatabase newDatabase(
      SqfliteDatabaseOpenHelper openHelper, String path) {
    if (path != null) {
      final existing = databases[path];
      final db = MockDatabase(openHelper, path);
      // Copy version
      db.version = existing?.version;
      // Last replaces
      databases[path] = db;

      return db;
    }
    return MockDatabase(openHelper, path);
  }

  @override
  Future<String> getDatabasesPath() async {
    return join('.dart_tool', 'sqlite', 'test', 'mock');
  }
}

class MockDatabaseFactoryEmpty extends SqfliteDatabaseFactoryBase {
  final List<String> methods = <String>[];

  @override
  Future<T> invokeMethod<T>(String method, [dynamic arguments]) {
    methods.add(method);
    return null;
  }
}

final MockDatabaseFactory mockDatabaseFactory = MockDatabaseFactory();
