// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

library oracle.src.occi_extension;

import 'dart-ext:occi_extension';

class Environment {
  Environment() {
    _init();
  }

  void _init() native 'OracleEnvironment_init';

  Connection createConnection(String username, String password,
      String connStr) native 'OracleEnvironment_createConnection';
}

class Connection {
  String _connectionString;
  String _username;

  String get connectionString => _connectionString;

  String get username => _username;

  factory Connection(String username, String password, String connString) {
    var env = new Environment();
    return env.createConnection(username, password, connString);
  }

  Connection._();

  void _bindArgs(Statement stmt, [List<Object> args]) {
    if (args == null) {
      return;
    }

    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      var param_i = i + 1;

      switch (arg.runtimeType) {
        case String:
          stmt.setString(param_i, arg);
          break;
        case int:
          stmt.setInt(param_i, arg);
          break;
        case double:
          stmt.setDouble(param_i, arg);
          break;
        case DateTime:
          // TODO: Will setTimestamp work on a DATETIME column?
          stmt.setTimestamp(param_i, arg);
          break;
      }
    }
  }

  void execute(String sql, [List<Object> args]) {
    var stmt = createStatement(sql);
    _bindArgs(stmt, args);
    stmt.execute();
  }

  ResultSet executeQuery(String sql, [List<Object> args]) {
    var stmt = createStatement(sql);
    _bindArgs(stmt, args);
    return stmt.executeQuery();
  }

  void commit() native 'OracleConnection_commit';

  void rollback() native 'OracleConnection_rollback';

  Statement createStatement(
      String sql) native 'OracleConnection_createStatement';
}
enum StatementStatus {
  UNPREPARED,
  PREPARED,
  RESULT_SET_AVAILABLE,
  UPDATE_COUNT_AVAILABLE,
  NEEDS_STREAM_DATA,
  STREAM_DATA_AVAILABLE
}

class Statement {
  Statement._();

  String get sql native 'OracleStatement_getSql';

  void set sql(String newSql) native 'OracleStatement_setSql';

  void setPrefetchRowCount(
      int val) native 'OracleStatement_setPrefetchRowCount';

  int _execute() native 'OracleStatement_execute';

  StatementStatus execute() => StatementStatus.values[_execute()];

  ResultSet executeQuery() native 'OracleStatement_executeQuery';

  int executeUpdate() native 'OracleStatement_executeUpdate';

  int _status() native 'OracleStatement_status';

  StatementStatus status() => StatementStatus.values[_status()];

  void setBlob(int index, Blob blob) native 'OracleStatement_setBlob';

  void setClob(int index, Clob clob) native 'OracleStatement_setClob';

  void setBytes(int index, List<int> bytes) native 'OracleStatement_setBytes';

  void setString(int index, String string) native 'OracleStatement_setString';

  void setNum(int index, num number) native 'OracleStatement_setNum';

  void setInt(int index, int integer) native 'OracleStatement_setInt';

  void setDouble(int index, double daable) native 'OracleStatement_setDouble';

  void setDate(int index, DateTime date) native 'OracleStatement_setDate';

  void setTimestamp(
      int index, DateTime timestamp) native 'OracleStatement_setTimestamp';
}

class ResultSet {
  ResultSet._();

  List<ColumnMetadata> getColumnListMetadata()
    native 'OracleResultSet_getColumnListMetadata';

  dynamic cancel() native 'OracleResultSet_cancel';

  BFile getBFile(int index) native 'OracleResultSet_getBFile';

  Blob getBlob(int index) native 'OracleResultSet_getBlob';

  Clob getClob(int index) native 'OracleResultSet_getClob';

  List<int> getBytes(int index) native 'OracleResultSet_getBytes';

  String getString(int index) native 'OracleResultSet_getString';

  num getNum(int index) native 'OracleResultSet_getNum';

  int getInt(int index) native 'OracleResultSet_getInt';

  double getDouble(int index) native 'OracleResultSet_getDouble';

  DateTime getDate(int index) native 'OracleResultSet_getDate';

  DateTime getTimestamp(int index) native 'OracleResultSet_getTimestamp';

  dynamic getRowID() native 'OracleResultSet_getRowID';

  bool next(int numberOfRows) native 'OracleResultSet_next';
}

class BFile {
  List<int> get bytes native 'OracleBFile_getBytes';
}

class Blob {
  Blob(Connection c) {
    assert(c != null);
    _init(c);
  }
  Blob._();
  void _init(c) native 'OracleBlob_create';

  Blob.fromBytes(List<int> bytes) {
    // _initSetBytes(bytes);
  }
  void append(Blob b) native 'OracleBlob_append';

  void copy(Blob b) native 'OracleBlob_copy';

  int length() native 'OracleBlob_length';

  void trim(int length) native 'OracleBlob_trim';

  List<int> read(int amount, int offset) native 'OracleBlob_read';

  int write(int amount, List<int> buffer, int offset) native 'OracleBlob_write';

  //List<int> asBytes() native 'OracleBlob_asBytes';

  //void _initSetBytes(List<int> bytes) native 'OracleBlob_initSetBytes';
}

class Clob {
  Clob(Connection c) {
    assert(c != null);
    _init(c);
  }
  Clob._();
  void _init(c) native 'OracleClob_create';

  Clob.fromBytes(List<int> bytes) {
    // _initSetBytes(bytes);
  }
  void append(Clob b) native 'OracleClob_append';

  void copy(Clob b) native 'OracleClob_copy';

  int length() native 'OracleClob_length';

  void trim(int length) native 'OracleClob_trim';

  List<int> read(int amount, int offset) native 'OracleClob_read';

  int write(int amount, List<int> buffer, int offset) native 'OracleClob_write';
}

abstract class Metadata {
  bool getBoolean(int attrId) native 'OracleMetadata_getBoolean';
  
  int getInt(int attrId) native 'OracleMetadata_getInt';
  
  num getNumber(int attrId) native 'OracleMetadata_getNumber';
  
  String getString(int attrId) native 'OracleMetadata_getString';
  
  DateTime getTimestamp(int attrId) native 'OracleMetadata_getTimestamp';
  
  int getUInt(int attrId) native 'OracleMetadata_getUInt';
}

class ColumnMetadata extends Metadata {
  ColumnMetadata._();
}
