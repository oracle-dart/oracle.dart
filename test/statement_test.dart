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
                 (ID int)""");

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
      conn.execute('INSERT INTO stmt_test (id) VALUES (1)');

      var stmt = conn.createStatement('SELECT * FROM stmt_test');
      var results = stmt.executeQuery();
      results.next(1);
      expect(results.getInt(1), equals(1));
    });
  });


  test('Connection(username, password, connString)', () {
    expect(() => new oracle.Connection(username, password, connString), returnsNormally);
  });
}
