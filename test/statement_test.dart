import 'dart:io';
import 'package:oracle/oracle.dart' as oracle;
import 'package:test/test.dart';

main() {
  var username;
  var password;
  var connString;
  var conn;

  setUp(() {
    if (conn == null) {
      username = Platform.environment['DB_USERNAME'];
      password = Platform.environment['DB_PASSWORD'];
      connString = Platform.environment['DB_CONN_STR'];
      conn = new oracle.Connection(username, password, connString);
    }

    conn.execute("""BEGIN EXECUTE IMMEDIATE 'DROP TABLE stmt_test';
                 EXCEPTION WHEN OTHERS THEN NULL;
                 END;""");

                 conn.execute("""CREATE TABLE stmt_test
                              (test_int int,
                               test_string varchar(255),
                               test_date DATE,
                               test_blob BLOB,
                               test_number NUMBER,
                               test_ts TIMESTAMP,
                               test_tstz TIMESTAMP WITH TIME ZONE)""");

                 conn.execute("ALTER SESSION SET time_zone = 'UTC'");

                 return conn;
  });

  tearDown((){
    conn.execute("DROP TABLE stmt_test");
  });

  group('Statement', () {
    test('createStatement', () {
      var sql = 'SELECT super_sql FROM the_oracle_gods';
      var stmt = conn.createStatement(sql);
      expect(stmt.sql, equals(sql));
    });

    test('setSql', () {
      var sql = 'SELECT super_sql FROM the_oracle_gods';
      var stmt = conn.createStatement(sql);
      expect(stmt.sql, equals(sql));
      var newSql = 'SELECT new_sql FROM the_oracle_gods';
      stmt.sql = newSql;
      expect(stmt.sql, equals(newSql));
    });

    test('executeQuery', () {
      conn.execute('INSERT INTO stmt_test (test_int) VALUES (1)');

      var stmt = conn.createStatement('SELECT test_int FROM stmt_test');
      var results = stmt.executeQuery();
      results.next(1);
      expect(results.getInt(1), equals(1));
    });

    group('setTimestamp', () {
      test('with UTC', () {
        var stmt = conn.createStatement('INSERT INTO stmt_test (test_ts) VALUES (:1)');
        var dt = new DateTime.utc(1988, 11, 7, 1, 2, 3, 5);
        stmt.setTimestamp(1, dt);
        stmt.execute();

        var rs = conn.executeQuery("SELECT TO_CHAR(test_ts, 'YYYY-MM-DD HH:MI:SS.FF TZR') FROM stmt_test")
          ..next(1);

        expect(rs.getString(1), '1988-11-07 01:02:03.005000 +00:00');
      });

      test('with null', () {
        var stmt = conn.createStatement('INSERT INTO stmt_test (test_ts) VALUES (:1)');
        stmt.setTimestamp(1, null);
        expect(() => stmt.execute(), returnsNormally);

        var rs = conn.executeQuery('SELECT test_ts FROM stmt_test')
          ..next(1);

        expect(rs.getTimestamp(1), null);
      });
    });

    group('setDate', () {
      test('with DateTime', () {
        var stmt = conn.createStatement('INSERT INTO stmt_test (test_date) VALUES (:1)');
        var dt = new DateTime.utc(1988, 11, 7, 1, 2, 3, 5);
        stmt.setDate(1, dt);
        stmt.execute();

        var rs = conn.executeQuery("SELECT TO_CHAR(test_date, 'YYYY-MM-DD HH:MI:SS') FROM stmt_test")
          ..next(1);

        expect(rs.getString(1), '1988-11-07 01:02:03');
      });
      
      test('with null', () {
        var stmt = conn.createStatement('INSERT INTO stmt_test (test_date) VALUES (:1)');
        stmt.setDate(1, null);
        stmt.execute();

        var rs = conn.executeQuery("SELECT test_date FROM stmt_test")
          ..next(1);

        expect(rs.getDate(1), null);
      });
    });
  });


  test('Connection(username, password, connString)', () {
    expect(() => new oracle.Connection(username, password, connString), returnsNormally);
  });
}
