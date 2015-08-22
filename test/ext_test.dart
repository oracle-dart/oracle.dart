import 'dart:io';
import 'package:oracle/oracle.dart';
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

  test('smoke', () {
    Environment env = new Environment();
    Connection conn = env.createConnection(username, password, connString);

    var sql = 'SELECT * FROM BLAH';
    var stmt = conn.createStatement(sql);

    expect(stmt.sql, equals(sql));
  });
}
