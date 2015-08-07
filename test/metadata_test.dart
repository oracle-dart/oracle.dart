import 'dart:io';
import 'package:oracle/oracle.dart' as oracle;
import 'package:test/test.dart';
import 'package:collection/equality.dart';

main() {
  var username;
  var password;
  var connString;
  var con;
  var metadata;

  setUp(() {
    username = Platform.environment['DB_USERNAME'];
    password = Platform.environment['DB_PASSWORD'];
    connString = Platform.environment['DB_CONN_STR'];

    con = new oracle.Connection(username, password, connString);
    con.execute("BEGIN EXECUTE IMMEDIATE 'DROP TABLE metadata_test'; EXCEPTION WHEN OTHERS THEN NULL; END;");
    con.execute("CREATE TABLE metadata_test ( test_int int, test_string varchar(255))");
    
    con.execute("INSERT into metadata_test (test_int) VALUES (NULL)");
    var rs = con.executeQuery('SELECT test_int, test_string from metadata_test');
    metadata = rs.getColumnListMetadata();

    assert(metadata.length == 2);
  }); 

  tearDown((){
    var stmt = con.createStatement("DROP TABLE metadata_test");
    stmt.execute();
    con.commit();
  });

  group('Metadata', () {
    test('getString', () {
    });
  });
}
