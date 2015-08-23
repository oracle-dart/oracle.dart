import 'dart:io';
import 'package:oracle/oracle.dart' as oracle;
import 'package:test/test.dart';
import 'package:collection/equality.dart';
import 'helpers.dart';

const MAX_DELTA = 0.0001;

class InsertHelper {
  oracle.Connection _conn;
  oracle.ResultSet _rs;

  InsertHelper(this._conn);

  _insertAndFetch(String columnName, Object val) {
    _conn.execute("INSERT INTO resultset_test ($columnName) VALUES ('$val')");

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
      case 'CLOB':
        _insertAndFetch('test_clob', val);
        break;
      case 'BLOB':
        _insertAndFetch('test_blob', val);
        break;
      case 'FLOAT':
        _insertAndFetch('test_float', val);
        break;
      default:
        throw Exception('Unknown column type $columnType');
    }

    return this;
  }

  getInt() => _rs.getInt(1);
  getDouble() => _rs.getDouble(1);
  getTimestamp() => _rs.getTimestamp(1);
  getString() => _rs.getString(1);
  getBlob() => _rs.getBlob(1);
  getClob() => _rs.getClob(1);
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

  insertValidRow() {
    con.execute("""INSERT INTO resultset_test
                (test_int,
                 test_string,
                 test_date,
                 test_blob,
                 test_clob,
                 test_float,
                 test_number)

                VALUES(5,
                       'test',
                       to_date('1988-11-07 01:02:03', 'YYYY-MM-DD HH:MI:SS'),
                       '42010203',
                       'test',
                       '5.5',
                       '10.10')""");
  }

  setUp(() {
    if (con == null) {
      username = Platform.environment['DB_USERNAME'];
      password = Platform.environment['DB_PASSWORD'];
      connString = Platform.environment['DB_CONN_STR'];

      env = new oracle.Environment();
      con = env.createConnection(username, password, connString);
    }

    var stmt = con.createStatement(
        "BEGIN EXECUTE IMMEDIATE 'DROP TABLE resultset_test'; EXCEPTION WHEN OTHERS THEN NULL; END;");
    stmt.execute();
    con.commit();
    stmt = con.createStatement("""CREATE TABLE resultset_test
                               (test_int int,
                                test_string varchar(255),
                                test_date DATE,
                                test_blob BLOB,
                                test_clob CLOB,
                                test_float FLOAT,
                                test_number NUMBER,
                                test_ts TIMESTAMP,
                                test_tstz TIMESTAMP WITH TIME ZONE)""");
    stmt.execute();
    con.commit();

    // ensure timezone is always UTC
    con.execute("ALTER SESSION SET time_zone = 'UTC'");
  });

  tearDown(() {
    var stmt = con.createStatement("DROP TABLE resultset_test");
    stmt.execute();
    con.commit();
  });

  group('ResultSet', () {
    group('.getString', () {
      test('with VARCHAR', () {
        expect(insertIntoColType('VARCHAR', 'foobar').getString(), 'foobar');
      });

      test('with CLOB', () {
        // OCCI returns an empty string when getString is called on a CLOB
        expect(insertIntoColType('CLOB', 'foobar').getString(), '');
      });

      test('with NUMBER', () {
        expect(insertIntoColType('NUMBER', 5).getString(), '5');
      });

      test('with FLOAT', () {
        expect(insertIntoColType('FLOAT', 5.1).getString(), '5.1');
      });

      test('with INT', () {
        expect(insertIntoColType('INT', 5).getString(), '5');
      });

      test('with NULL', () {
        insertNulls();
        var f = () => queryAll().getString(1);
        expect(f, returnsNormally);
        expect(f(), isNull);
      });
    });

    group('.getInt', () {
      test('with INT', () {
        expect(insertIntoColType('INT', 5).getInt(), equals(5));
      });

      test('with NUMBER', () {
        expect(insertIntoColType('NUMBER', 5).getInt(), equals(5));
      });

      test('with NULL', () {
        insertNulls();
        expect(() => queryAll().getInt(1), returnsNormally);
        expect(queryAll().getInt(1), isNull);
      });

      test('with unconvertable type', () {
        insertValidRow();
        var rs = con.executeQuery('SELECT test_date from resultset_test');
        rs.next();
        expect(() => rs.getInt(1), throwsSqlException(932));
      });
    });

    group('.getDouble', () {
      test('with INT', () {
        expect(insertIntoColType('INT', 5).getDouble(), closeTo(5, MAX_DELTA));
      });

      test('with NUMBER', () {
        expect(insertIntoColType('NUMBER', 5.1).getDouble(),
            closeTo(5.1, MAX_DELTA));
      });

      test('with VARCHAR', () {
        expect(() => insertIntoColType('VARCHAR', 'val').getDouble(), throws);
      });

      test('with NULL', () {
        insertNulls();
        expect(() => queryAll().getDouble(1), returnsNormally);
        expect(queryAll().getDouble(1), isNull);
      });

      test('with unconvertable type', () {
        insertValidRow();
        var rs = con.executeQuery('SELECT test_date from resultset_test');
        rs.next();
        expect(() => rs.getDouble(1), throws);
      });
    });

    group('.getTimestamp', () {
      test('with TIMESTAMP (UTC)', () {
        con.execute("ALTER SESSION SET time_zone = 'UTC'");
        con.execute("INSERT INTO resultset_test (test_ts) "
            "VALUES (to_timestamp('1988-11-07 01:02:03', 'YYYY-MM-DD HH:MI:SS'))");
        var rs = con.executeQuery('SELECT test_ts from resultset_test');
        rs.next(1);

        expect(
            rs.getTimestamp(1), equals(new DateTime.utc(1988, 11, 7, 1, 2, 3)));
      });

      test('with TIMESTAMP (EST/GMT-5)', () {
        con.execute("ALTER SESSION SET time_zone = 'EST'");
        con.execute("INSERT INTO resultset_test (test_ts) "
            "VALUES (to_timestamp('1988-11-07 05:02:03', 'YYYY-MM-DD HH:MI:SS'))");
        var rs = con.executeQuery('SELECT test_ts from resultset_test');
        rs.next(1);

        // expected time should be 5 hours ahead
        expect(rs.getTimestamp(1),
            equals(new DateTime.utc(1988, 11, 7, 10, 2, 3)));
      });

      test('with TIMESTAMP (PRC/UTC+8)', () {
        con.execute("ALTER SESSION SET time_zone = 'PRC'");
        con.execute("INSERT INTO resultset_test (test_ts) "
            "VALUES (to_timestamp('1988-11-07 05:02:03', 'YYYY-MM-DD HH:MI:SS'))");
        var rs = con.executeQuery('SELECT test_ts from resultset_test');
        rs.next(1);

        // expected time should be 8 hours behind
        expect(rs.getTimestamp(1),
            equals(new DateTime.utc(1988, 11, 6, 21, 2, 3)));
      });

      test('with TIMESTAMP WITH TIME ZONE (UTC)', () {
        con.execute("INSERT INTO resultset_test (test_tstz) "
            "VALUES (to_timestamp_tz('1988-11-07 01:02:03 +0:00', 'YYYY-MM-DD HH:MI:SS TZH:TZM'))");
        var rs = con.executeQuery('SELECT test_tstz from resultset_test');
        rs.next(1);

        expect(
            rs.getTimestamp(1), equals(new DateTime.utc(1988, 11, 7, 1, 2, 3)));
      });

      test('with TIMESTAMP WITH TIME ZONE (EST/GMT-5)', () {
        con.execute("INSERT INTO resultset_test (test_tstz) "
            "VALUES (to_timestamp_tz('1988-11-07 05:02:03 -5:00', 'YYYY-MM-DD HH:MI:SS TZH:TZM'))");
        var rs = con.executeQuery('SELECT test_tstz from resultset_test');
        rs.next(1);

        // expected time should be 5 hours ahead
        expect(rs.getTimestamp(1),
            equals(new DateTime.utc(1988, 11, 7, 10, 2, 3)));
      });

      test('with TIMESTAMP WITH TIME ZONE (PRC/UTC+8)', () {
        con.execute("INSERT INTO resultset_test (test_tstz) "
            "VALUES (to_timestamp_tz('1988-11-07 05:02:03 +8:00', 'YYYY-MM-DD HH:MI:SS TZH:TZM'))");
        var rs = con.executeQuery('SELECT test_tstz from resultset_test');
        rs.next(1);

        // expected time should be 8 hours behind
        expect(rs.getTimestamp(1),
            equals(new DateTime.utc(1988, 11, 6, 21, 2, 3)));
      });

      test('with subseconds', () {
        con.execute("INSERT INTO resultset_test (test_ts) "
            "VALUES (to_timestamp('1988-11-07 05:02:03.123', 'YYYY-MM-DD HH:MI:SS.FF'))");
        var rs = con.executeQuery('SELECT test_ts from resultset_test');
        rs.next(1);

        expect(rs.getTimestamp(1),
            equals(new DateTime.utc(1988, 11, 7, 5, 2, 3, 123)));
      });

      test('with NULL', () {
        insertNulls();
        var f = () => queryAll().getTimestamp(1);
        expect(f, returnsNormally);
        expect(f(), isNull);
      });

      test('with unconvertable type', () {
        insertValidRow();
        var rs = con.executeQuery('SELECT test_int from resultset_test');
        rs.next();
        expect(() => rs.getTimestamp(1), throws);
      });
    });

    group('.getDate', () {
      test('with DATE', () {
        con.execute("""INSERT INTO resultset_test (test_date) VALUES
                    (to_date('1988-11-07 01:02:03', 'YYYY-MM-DD HH:MI:SS'))""");

        var rs = con.executeQuery('SELECT test_date FROM resultset_test')
          ..next(1);

        expect(rs.getDate(1), new DateTime(1988, 11, 7, 1, 2, 3));
      });

      test('with NULL', () {
        insertNulls();
        var f = () => queryAll().getDate(1);
        expect(f, returnsNormally);
        expect(f(), isNull);
      });

      test('with unconvertable type', () {
        insertValidRow();
        var rs = con.executeQuery('SELECT test_int from resultset_test');
        rs.next();
        expect(() => rs.getDate(1), throws);
      });
    });

    group('.getBlob', () {
      test('with BLOB', () {
        // insert as hex string
        var blob = insertIntoColType('BLOB', "010203").getBlob();

        expect(blob.length(), 3);
        expect(blob.read(3, 1), [1, 2, 3]);
      });

      test('with unconvertable type', () {
        insertValidRow();
        var rs = con.executeQuery('SELECT test_int from resultset_test');
        rs.next();

        expect(() => rs.getBlob(1), throws);
      });

      test('with NULL', () {
        insertNulls();
        var f = () => queryAll().getBlob(1);
        expect(f, returnsNormally);
        expect(f(), isNull);
      });
    });

    group('.getClob', () {
      test('with CLOB', () {
        var expected = "string";
        var clob = insertIntoColType('CLOB', expected).getClob();

        expect(clob.length(), equals(expected.length));
        expect(clob.read(expected.length, 1), expected);
      });

      test('with unconvertable type', () {
        insertValidRow();
        var rs = con.executeQuery('SELECT test_int from resultset_test');
        rs.next();

        expect(() => rs.getClob(1), throws);
      });

      test('with NULL', () {
        insertNulls();
        var f = () => queryAll().getClob(1);
        expect(f, returnsNormally);
        expect(f(), isNull);
      });
    });

    test('getColumnListMetadata', () {
      var f = () => con
          .executeQuery('SELECT test_int, test_string FROM resultset_test')
          .getColumnListMetadata();
      expect(f, returnsNormally);

      var metadataList = f();
      expect(metadataList.length, equals(2));

      for (var md in metadataList) {
        expect(md is oracle.ColumnMetadata, isTrue);
      }
    });
  });
}
