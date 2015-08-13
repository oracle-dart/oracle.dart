import 'dart:io';
import 'package:oracle/oracle.dart' as oracle;
import 'package:test/test.dart';
import 'package:collection/equality.dart';

const MAX_DELTA = 0.0001;

class InsertHelper {
  oracle.Connection _conn;
  oracle.ResultSet _rs;

  InsertHelper(this._conn);
  
  _insertAndFetch(String columnName, Object val) {
    _conn.execute("INSERT INTO resultset_test ($columnName) VALUES (:0)", [val]);

    _rs = _conn.executeQuery("SELECT $columnName FROM resultset_test");
    _rs.next(1);
  }

  insert(String columnType, Object val) {
    switch (columnType) {
      case 'NUMBER':
        _insertAndFetch('test_number', val);
        break;
      case 'INT':
        _insertAndFetch('test_int', val);
        break;
      case 'VARCHAR':
        _insertAndFetch('test_string', val);
        break;
      default:
        throw Exception('Unknown column type $columnType');
    }
  
    return this;
  }

  getInt() => _rs.getInt(1);
  getDouble() => _rs.getDouble(1);
}

main() {
  var username;
  var password;
  var connString;
  var env;
  var con;

  insertIntoColType(String colType, Object val) {
    return new InsertHelper(con).insert(colType, val);
  }

  queryAll() {
    return con.createStatement('SELECT * FROM resultset_test').executeQuery()
      ..next(1);
  }

  // Insert a row of NULL values for nullability testing
  insertNulls() {
    con.execute("INSERT into resultset_test (test_int) VALUES (NULL)");
  }

  setUp(() {
    username = Platform.environment['DB_USERNAME'];
    password = Platform.environment['DB_PASSWORD'];
    connString = Platform.environment['DB_CONN_STR'];
    
    env = new oracle.Environment();
    con = env.createConnection(username, password, connString);
    var stmt = con.createStatement("BEGIN EXECUTE IMMEDIATE 'DROP TABLE resultset_test'; EXCEPTION WHEN OTHERS THEN NULL; END;");
    stmt.execute();
    con.commit();
    stmt = con.createStatement("CREATE TABLE resultset_test ( test_int int, test_string varchar(255), test_date DATE, test_blob BLOB, test_number NUMBER)");
    stmt.execute();
    con.commit();
  }); 
  
  tearDown((){
    var stmt = con.createStatement("DROP TABLE resultset_test");
    stmt.execute();
    con.commit();
  });

  group('ResultSet', () {
    test('getInt with INT', () {
      expect(insertIntoColType('INT', 5).getInt(), equals(5));
    });

    test('getInt with NUMBER', () {
      expect(insertIntoColType('NUMBER', 5).getInt(), equals(5));
    });
    
    test('getInt with NULL', () {
      insertNulls();
      expect(() => queryAll().getInt(1), returnsNormally);
      expect(queryAll().getInt(1), isNull);
    });

    test('getDouble with INT', () {
      expect(insertIntoColType('INT', 5).getDouble(), closeTo(5, MAX_DELTA));
    });

    test('getDouble with NUMBER', () {
      expect(insertIntoColType('NUMBER', 5.1).getDouble(), closeTo(5.1, MAX_DELTA));
    });

    test('getDouble with VARCHAR', () {
      expect(() => insertIntoColType('VARCHAR', 'val').getDouble(), throws);
    });
    
    test('getDouble with NULL', () {
      insertNulls();
      expect(() => queryAll().getDouble(1), returnsNormally);
      expect(queryAll().getDouble(1), isNull);
    });

    test('getColumnListMetadata', () {
      var f = () => con.executeQuery('SELECT test_int, test_string FROM resultset_test').getColumnListMetadata();
      expect(f, returnsNormally);

      var metadataList = f();
      expect(metadataList.length, equals(2));

      for (var md in metadataList) {
        expect(md is oracle.ColumnMetadata, isTrue);
      }
    });
  });
}
