import 'dart:io';
import 'package:oracle/oracle.dart' as oracle;
import 'package:test/test.dart';

main() {
  var username;
  var password;
  var connString;

  setUp(() {
    username = Platform.environment['DB_USERNAME'];
    password = Platform.environment['DB_PASSWORD'];
    connString = Platform.environment['DB_CONN_STR'];
  });

  test('simple statement creation', () {
    var sql = 'SELECT super_sql FROM the_oracle_gods';
    oracle.Environment env = new oracle.Environment();
    oracle.Connection conn = env.createConnection(username, password, connString);
    var stmt = conn.createStatement(sql);
    expect(stmt.sql, equals(sql));
  });

  test('statement setSql', () {
    var sql = 'SELECT super_sql FROM the_oracle_gods';
    oracle.Environment env = new oracle.Environment();
    oracle.Connection conn = env.createConnection(username, password, connString);
    var stmt = conn.createStatement(sql);
    expect(stmt.sql, equals(sql));
    var newSql = 'SELECT new_sql FROM the_oracle_gods';
    stmt.sql = newSql;
    expect(stmt.sql, equals(newSql));
  });

  test('statement executeQuery', () {
    var sql = 'SELECT * FROM test';
    oracle.Environment env = new oracle.Environment();
    oracle.Connection conn = env.createConnection(username, password, connString);
    var stmt = conn.createStatement(sql);
    var results = stmt.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(1));
  }, skip: "fails with: 'table or view does not exist'");
  test('statement execute commit', () {
    var sql = 'UPDATE test set ID=:bind';
    var sql2 = 'SELECT * FROM test';
    oracle.Environment env = new oracle.Environment();
    oracle.Connection conn = env.createConnection(username, password, connString);
    var stmt = conn.createStatement(sql);
    var stmt2 = conn.createStatement(sql2);
    stmt.setInt(1, 2);
    stmt.execute();
    conn.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(2));
    stmt.setInt(1, 1);
    stmt.execute();
    conn.commit();
    results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(1));
  }, skip: "fails with: 'table or view does not exist'");

  test('Connection(username, password, connString)', () {
    expect(() => new oracle.Connection(username, password, connString), returnsNormally);
  });
}
