import "package:oracle/oracle.dart" as oracle;

const dbUsername = "dart";
const dbPassword = "4c3wxjtFbQdgBo";
const dbConnString = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SID=XE)))";

main() {
  oracle.Environment env = new oracle.Environment();
  oracle.Connection conn = env.createConnection(dbUsername, dbPassword, dbConnString);

  oracle.Statement stmt = conn.createStatement("CREATE TABLE test_table (test_int INT)");
  stmt.execute();

  stmt = conn.createStatement("INSERT INTO test_table (test_int) VALUES (:1)");
  print(stmt.sql);
  stmt.setInt(1, 12);
  stmt.execute();
  stmt = conn.createStatement("SELECT test_int FROM test_table");
  oracle.ResultSet results = stmt.executeQuery();
  results.next(1);
  int i = results.getInt(1);
  print(i);
  assert(i == 12);
}
