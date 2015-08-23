import 'dart:io';
import 'package:oracle/oracle.dart' as oracle;
import 'package:test/test.dart';
import 'package:collection/equality.dart';

main() {
  var username;
  var password;
  var connString;
  var env;
  var con;

  setUp(() {
    username = Platform.environment['DB_USERNAME'];
    password = Platform.environment['DB_PASSWORD'];
    connString = Platform.environment['DB_CONN_STR'];

    env = new oracle.Environment();
    con = env.createConnection(username, password, connString);
    var stmt = con.createStatement(
        "BEGIN EXECUTE IMMEDIATE 'DROP TABLE test_table'; EXCEPTION WHEN OTHERS THEN NULL; END;");
    stmt.execute();
    con.commit();
    stmt = con.createStatement(
        "CREATE TABLE test_table ( test_int int, test_string varchar(255), test_date DATE, test_blob BLOB, test_clob CLOB, test_clob2 CLOB, test_num NUMBER)");
    stmt.execute();
    con.commit();
    stmt = con.createStatement(
        "INSERT INTO test_table (test_int,test_string,test_date,test_blob, test_clob,test_clob2,test_num) VALUES (:b1, :b2, :b3, EMPTY_BLOB(), EMPTY_CLOB(), EMPTY_CLOB(),:b4)");
    stmt.setInt(1, 34);
    stmt.setString(2, "hello world");
    stmt.setDate(3, new DateTime(2012, 12, 19, 34, 35, 36));
    stmt.setNum(4, 12000000000000000000000000000000000009);
    stmt.execute();
    con.commit();
  });
  tearDown(() {
    var stmt = con.createStatement("DROP TABLE test_table");
    stmt.execute();
    con.commit();
  });
  test('get Result Set', () {
    var con = env.createConnection(username, password, connString);
    var stmt = con.execute(
        'SELECT test_int FROM test_table where test_date=:bind', {
      ':bind': new DateTime(2012, 12, 19, 34, 35, 36)
    });
    var rs = stmt.getResultSet();
    rs.next(1);
    expect(rs.get(1), equals(34));
  });
  test('create connection', () {
    var con = new oracle.Connection(username, password, connString);
    var stmt = con.execute('SELECT test_int FROM test_table');
    var rs = stmt.getResultSet();
    rs.next(1);
    expect(rs.get(1), equals(34));
  });
  test('change password', () {
    try {
      con.execute('CREATE USER foo IDENTIFIED BY "bar"');
      con.execute('GRANT CREATE SESSION to foo');
      var con2 = env.createConnection('foo', 'bar', connString);

      expect(() => con2.changePassword('bar', 'bar2'), returnsNormally);
      con2.terminate();

      expect(() => con2 = env.createConnection('foo', 'bar2', connString),
          returnsNormally);

      con2.terminate();
    } catch (e) {
      expect("", equals("FAILURE IN CHANGEPASSWORD TEST"));
    } finally {
      con.execute('DROP USER foo');
    }
  });
  test('get connection properties', () {
    expect(con.getConnectionString(), equals(connString));
    expect(con.getUsername(), equals(username));
  });
  test('test blob', () {
    List<int> bloblist = [2, 4, 6, 8, 10];
    var stmt =
        con.createStatement("SELECT test_blob FROM test_table FOR UPDATE");
    var results = stmt.executeQuery();
    results.next(1);
    oracle.Blob bl = results.getBlob(1);
    bl.write(5, bloblist, 1);
    con.commit();
    stmt = con.createStatement("SELECT test_blob FROM test_table");
    results = stmt.executeQuery();
    results.next(1);
    var dbblob = results.getBlob(1);
    expect(dbblob.length(), equals(5));
    var rlist = dbblob.read(5, 1);
    expect(rlist, equals(bloblist));
  });
  test('test blob trim', () {
    List<int> bloblist = [2, 4, 6, 8, 10];
    var stmt =
        con.createStatement("SELECT test_blob FROM test_table FOR UPDATE");
    var results = stmt.executeQuery();
    results.next(1);
    oracle.Blob bl = results.getBlob(1);
    bl.write(5, bloblist, 1);
    con.commit();
    results = stmt.executeQuery();
    results.next(1);
    bl = results.getBlob(1);
    bl.trim(2);
    con.commit();
    stmt = con.createStatement("SELECT test_blob FROM test_table");
    results = stmt.executeQuery();
    results.next(1);
    var dbblob = results.getBlob(1);
    expect(dbblob.length(), equals(2));
    var rlist = dbblob.read(2, 1);
    expect(rlist, equals([2, 4]));
  });
  test('test blob append', () {
    List<int> bloblist = [2, 4];
    var stmt =
        con.createStatement("SELECT test_blob FROM test_table FOR UPDATE");
    var results = stmt.executeQuery();
    results.next(1);
    oracle.Blob bl = results.getBlob(1);
    bl.write(2, bloblist, 1);
    con.commit();
    results = stmt.executeQuery();
    results.next(1);
    bl = results.getBlob(1);
    oracle.Blob bl2 = results.getBlob(1);
    bl.append(bl2);
    stmt = con.createStatement("SELECT test_blob FROM test_table");
    results = stmt.executeQuery();
    results.next(1);
    var dbblob = results.getBlob(1);
    expect(dbblob.length(), equals(4));
    var rlist = dbblob.read(4, 1);
    expect(rlist, equals([2, 4, 2, 4]));
  });
  test('test clob', () {
    var stmt =
        con.createStatement("SELECT test_clob FROM test_table FOR UPDATE");
    var results = stmt.executeQuery();
    results.next(1);
    oracle.Clob cl = results.getClob(1);
    cl.write(10, "teststring", 1);
    con.commit();
    stmt = con.createStatement("SELECT test_clob FROM test_table");
    results = stmt.executeQuery();
    results.next(1);
    var dbblob = results.getClob(1);
    expect(dbblob.length(), equals(10));
    var rlist = dbblob.read(10, 1);
    expect(rlist, equals("teststring"));
  });

  test('test clob copy', () {
    var stmt =
        con.createStatement("SELECT test_clob FROM test_table FOR UPDATE");
    var results = stmt.executeQuery();
    results.next(1);
    oracle.Clob cl = results.getClob(1);
    cl.write(10, "teststring", 1);
    con.commit();
    stmt = con.createStatement(
        "SELECT test_clob, test_clob2 FROM test_table FOR UPDATE");
    results = stmt.executeQuery();
    results.next(1);
    cl = results.getClob(1);
    oracle.Clob cl2 = results.getClob(2);
    cl2.copy(cl, 4);
    con.commit();
    stmt = con.createStatement("SELECT test_clob2 FROM test_table");
    results = stmt.executeQuery();
    results.next(1);
    var dbblob = results.getClob(1);
    expect(dbblob.length(), equals(4));
    var rlist = dbblob.read(4, 1);
    expect(rlist, equals("test"));
  });
  test('test clob trim', () {
    var stmt =
        con.createStatement("SELECT test_clob FROM test_table FOR UPDATE");
    var results = stmt.executeQuery();
    results.next(1);
    oracle.Clob cl = results.getClob(1);
    cl.write(10, "teststring", 1);
    con.commit();
    results = stmt.executeQuery();
    results.next(1);
    cl = results.getClob(1);
    cl.trim(4);
    con.commit();
    stmt = con.createStatement("SELECT test_clob FROM test_table");
    results = stmt.executeQuery();
    results.next(1);
    var dbblob = results.getClob(1);
    expect(dbblob.length(), equals(4));
    var rlist = dbblob.read(4, 1);
    expect(rlist, equals("test"));
  });
  test('test clob append', () {
    var stmt =
        con.createStatement("SELECT test_clob FROM test_table FOR UPDATE");
    var results = stmt.executeQuery();
    results.next(1);
    oracle.Clob cl = results.getClob(1);
    cl.write(10, "teststring", 1);
    con.commit();
    results = stmt.executeQuery();
    results.next(1);
    cl = results.getClob(1);
    oracle.Clob cl2 = results.getClob(1);
    cl.append(cl2);
    stmt = con.createStatement("SELECT test_clob FROM test_table");
    results = stmt.executeQuery();
    results.next(1);
    var dbblob = results.getClob(1);
    expect(dbblob.length(), equals(20));
    var rlist = dbblob.read(20, 1);
    expect(rlist, equals("teststringteststring"));
  });

  test('test select', () {
    var stmt = con.createStatement("SELECT * FROM test_table");
    var results = stmt.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(34));
    expect(results.getString(2), equals("hello world"));
    expect(results.getDate(3).toString(),equals(new DateTime(2012, 12, 19, 34, 35, 36).toString()));
    expect(results.getNum(7), equals(12000000000000000000000000000000000009));
  });
  test('test status', () {
    var stmt = con.createStatement("SELECT test_int from test_table");
    expect(stmt.status(), equals(oracle.StatementStatus.PREPARED));
    var res = stmt.execute();
    expect(res, equals(oracle.StatementStatus.RESULT_SET_AVAILABLE));
    res = stmt.status();
    expect(res, equals(oracle.StatementStatus.RESULT_SET_AVAILABLE));
    stmt = con.createStatement("UPDATE test_table set test_int=2");
    res = stmt.execute();
    expect(res, equals(oracle.StatementStatus.UPDATE_COUNT_AVAILABLE));
    res = stmt.status();
    expect(res, equals(oracle.StatementStatus.UPDATE_COUNT_AVAILABLE));
  });
  test('test update', () {
    var sql = 'UPDATE test_table set test_int=:bind';
    var sql2 = 'SELECT * FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.setInt(1, 2);
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(2));
    stmt.setInt(1, 1);
    stmt.execute();
    con.commit();
    results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(1));
  });
  test('test insert nulls', () {
    var sql =
        'UPDATE test_table set test_int=:b1, test_string=:b2, test_date=:b3, test_blob=null, test_clob=null,test_num=:b4';
    var sql2 = 'SELECT * FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.setInt(1, null);
    stmt.setString(2, null);
    stmt.setDate(3, null);
    stmt.setNum(4, null);
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(null));
    expect(results.getString(2), equals(null));
    expect(results.getDate(3), equals(null));
    expect(results.getBlob(4), equals(null));
    expect(results.getClob(5), equals(null));
    expect(results.getNum(7), equals(null));
  });
  test('test insert dynamic', () {
    var sql =
        'UPDATE test_table set test_int=:b1, test_string=:b2, test_date=:b3';
    var sql2 = 'SELECT * FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.setDynamic(1, 10);
    stmt.setDynamic(2, "hello");
    stmt.setDate(3, new DateTime(2000, 11, 11, 31, 31, 31));
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(10));
    expect(results.getString(2), equals("hello"));
    expect(results.getDate(3), equals(new DateTime(2000, 11, 11, 31, 31, 31)));
  });
  test('test bind', () {
    var sql = 'UPDATE test_table set test_string=:b2, test_int=:b3';
    var sql2 = 'SELECT test_int, test_string FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.bind(":b3", 10);
    stmt.bind(":b2", "hello");
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(10));
    expect(results.getString(2), equals("hello"));
  });
  test('test tricky bind', () {
    var sql = "UPDATE test_table set test_string=':b3', test_int=:b3";
    var sql2 = 'SELECT test_int, test_string FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.bind(":b3", 10);
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(10));
    expect(results.getString(2), equals(":b3"));
  });
  test('test double bind', () {
    var sql = "UPDATE test_table set test_string=:b3, test_int=:b3";
    var sql2 = 'SELECT test_int, test_string FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.bind(":b3", 10);
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(10));
    expect(results.getString(2), equals("10"));
  });
  test('test bind escaped quote', () {
    var sql = "UPDATE test_table set test_string=''':b3''', test_int=:b3";
    var sql2 = 'SELECT test_int, test_string FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.bind(":b3", 10);
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(10));
    expect(results.getString(2), equals("':b3'"));
  });
  test('test bind number argument', () {
    var sql = "UPDATE test_table set test_string=:b2, test_int=:b3";
    var sql2 = 'SELECT test_int, test_string FROM test_table';
    var stmt = con.createStatement(sql);
    var stmt2 = con.createStatement(sql2);
    stmt.bind(":b3", 10);
    stmt.bind(1, "11");
    stmt.execute();
    con.commit();
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(10));
    expect(results.getString(2), equals("11"));
  });
  test('test get', () {
    var stmt = con.createStatement("SELECT * FROM test_table");
    stmt.setPrefetchRowCount(12);
    var results = stmt.executeQuery();
    results.next(1);
    expect(results.get(1), equals(34));
    expect(results.get(2), equals("hello world"));
    expect(results.get(3).toString(),
        equals(new DateTime(2012, 12, 19, 34, 35, 36).toString()));
    results.cancel();
    expect(results.get(1), equals(34));
  });
  test('test next', () {
    var stmt = con.createStatement("SELECT test_int FROM test_table");
    var results = stmt.executeQuery();
    results.next();
    expect(results.get(1), equals(34));
  });
  test('test execute with map', () {
    var sql = "UPDATE test_table set test_string=:b2, test_int=:b3";
    var sql2 = 'SELECT test_int, test_string FROM test_table';
    var stmt = con.execute(sql, {1: "11", ':b3': 10});
    var stmt2 = con.createStatement(sql2);
    var results = stmt2.executeQuery();
    results.next(1);
    expect(results.getNum(1), equals(10));
    expect(results.getString(2), equals("11"));
  });
  test('test row', () {
    var stmt = con.createStatement("SELECT * FROM test_table");
    var results = stmt.executeQuery();
    results.next(1);
    var row = results.row();
    expect(row['TEST_INT'], equals(34));
    expect(row['TEST_NUM'], equals(12000000000000000000000000000000000009));
    expect(row['TEST_STRING'], equals("hello world"));
    expect(row['TEST_DATE'].toString(),
        equals(new DateTime(2012, 12, 19, 34, 35, 36).toString()));
  });
}
