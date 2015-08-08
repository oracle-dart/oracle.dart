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

class _MetadataAttrs {
  final int _value;

  int get value => _value;

  const _MetadataAttrs(this._value);

  static const ATTR_PTYPE = const _MetadataAttrs(123);
  static const ATTR_TIMESTAMP = const _MetadataAttrs(119);
  static const ATTR_OBJ_ID = const _MetadataAttrs(136);
  static const ATTR_OBJ_NAME = const _MetadataAttrs(134);
  static const ATTR_OBJ_SCHEMA = const _MetadataAttrs(135);
  static const ATTR_OBJID = const _MetadataAttrs(122);
  static const ATTR_NUM_COLS = const _MetadataAttrs(102);
  static const ATTR_LIST_COLUMNS = const _MetadataAttrs(103);
  static const ATTR_REF_TDO = const _MetadataAttrs(110);
  static const ATTR_IS_TEMPORARY = const _MetadataAttrs(130);
  static const ATTR_IS_TYPED = const _MetadataAttrs(131);
  static const ATTR_DURATION = const _MetadataAttrs(132);
  static const ATTR_COLLECTION_ELEMENT = const _MetadataAttrs(227);
  static const ATTR_RDBA = const _MetadataAttrs(104);
  static const ATTR_TABLESPACE = const _MetadataAttrs(126);
  static const ATTR_CLUSTERED = const _MetadataAttrs(105);
  static const ATTR_PARTITIONED = const _MetadataAttrs(106);
  static const ATTR_INDEX_ONLY = const _MetadataAttrs(107);
  static const ATTR_LIST_ARGUMENTS = const _MetadataAttrs(108);
  static const ATTR_IS_INVOKER_RIGHTS = const _MetadataAttrs(133);
  static const ATTR_LIST_SUBPROGRAMS = const _MetadataAttrs(109);
  static const ATTR_NAME = const _MetadataAttrs(4);
  static const ATTR_OVERLOAD_ID = const _MetadataAttrs(125);
  static const ATTR_TYPECODE = const _MetadataAttrs(216);
  static const ATTR_COLLECTION_TYPECODE = const _MetadataAttrs(217);
  static const ATTR_VERSION = const _MetadataAttrs(218);
  static const ATTR_IS_INCOMPLETE_TYPE = const _MetadataAttrs(219);
  static const ATTR_IS_SYSTEM_TYPE = const _MetadataAttrs(220);
  static const ATTR_IS_PREDEFINED_TYPE = const _MetadataAttrs(221);
  static const ATTR_IS_TRANSIENT_TYPE = const _MetadataAttrs(222);
  static const ATTR_IS_SYSTEM_GENERATED_TYPE = const _MetadataAttrs(223);
  static const ATTR_HAS_NESTED_TABLE = const _MetadataAttrs(224);
  static const ATTR_HAS_LOB = const _MetadataAttrs(225);
  static const ATTR_HAS_FILE = const _MetadataAttrs(226);
  static const ATTR_NUM_TYPE_ATTRS = const _MetadataAttrs(228);
  static const ATTR_LIST_TYPE_ATTRS = const _MetadataAttrs(229);
  static const ATTR_NUM_TYPE_METHODS = const _MetadataAttrs(230);
  static const ATTR_LIST_TYPE_METHODS = const _MetadataAttrs(231);
  static const ATTR_MAP_METHOD = const _MetadataAttrs(232);
  static const ATTR_ORDER_METHOD = const _MetadataAttrs(233);
  static const ATTR_DATA_SIZE = const _MetadataAttrs(1);
  static const ATTR_DATA_TYPE = const _MetadataAttrs(2);
  static const ATTR_PRECISION = const _MetadataAttrs(5);
  static const ATTR_SCALE = const _MetadataAttrs(6);
  static const ATTR_TYPE_NAME = const _MetadataAttrs(8);
  static const ATTR_SCHEMA_NAME = const _MetadataAttrs(9);
  static const ATTR_CHARSET_ID = const _MetadataAttrs(31);
  static const ATTR_CHARSET_FORM = const _MetadataAttrs(32);
  static const ATTR_ENCAPSULATION = const _MetadataAttrs(235);
  static const ATTR_IS_CONSTRUCTOR = const _MetadataAttrs(241);
  static const ATTR_IS_DESTRUCTOR = const _MetadataAttrs(242);
  static const ATTR_IS_OPERATOR = const _MetadataAttrs(243);
  static const ATTR_IS_SELFISH = const _MetadataAttrs(236);
  static const ATTR_IS_MAP = const _MetadataAttrs(244);
  static const ATTR_IS_ORDER = const _MetadataAttrs(245);
  static const ATTR_IS_RNDS = const _MetadataAttrs(246);
  static const ATTR_IS_RNPS = const _MetadataAttrs(247);
  static const ATTR_IS_WNDS = const _MetadataAttrs(248);
  static const ATTR_IS_WNPS = const _MetadataAttrs(249);
  static const ATTR_NUM_ELEMS = const _MetadataAttrs(234);
  static const ATTR_LINK = const _MetadataAttrs(111);
  static const ATTR_MIN = const _MetadataAttrs(112);
  static const ATTR_MAX = const _MetadataAttrs(113);
  static const ATTR_INCR = const _MetadataAttrs(114);
  static const ATTR_CACHE = const _MetadataAttrs(115);
  static const ATTR_ORDER = const _MetadataAttrs(116);
  static const ATTR_HW_MARK = const _MetadataAttrs(117);
  static const ATTR_IS_NULL = const _MetadataAttrs(7);
  static const ATTR_POSITION = const _MetadataAttrs(11);
  static const ATTR_HAS_DEFAULT = const _MetadataAttrs(212);
  static const ATTR_LEVEL = const _MetadataAttrs(211);
  static const ATTR_IOMODE = const _MetadataAttrs(213);
  static const ATTR_RADIX = const _MetadataAttrs(214);
  static const ATTR_SUB_NAME = const _MetadataAttrs(10);
  static const ATTR_LIST_OBJECTS = const _MetadataAttrs(261);
  static const ATTR_NCHARSET_ID = const _MetadataAttrs(262);
  static const ATTR_LIST_SCHEMAS = const _MetadataAttrs(263);
  static const ATTR_MAX_PROC_LEN = const _MetadataAttrs(264);
  static const ATTR_MAX_COLUMN_LEN = const _MetadataAttrs(265);
  static const ATTR_CURSOR_COMMIT_BEHAVIOR = const _MetadataAttrs(266);
  static const ATTR_MAX_CATALOG_NAMELEN = const _MetadataAttrs(267);
  static const ATTR_CATALOG_LOCATION = const _MetadataAttrs(268);
  static const ATTR_SAVEPOINT_SUPPORT = const _MetadataAttrs(269);
  static const ATTR_NOWAIT_SUPPORT = const _MetadataAttrs(270);
  static const ATTR_AUTOCOMMIT_DDL = const _MetadataAttrs(271);
  static const ATTR_LOCKING_MODE = const _MetadataAttrs(272);
  static const ATTR_IS_FINAL_TYPE = const _MetadataAttrs(279);
  static const ATTR_IS_INSTANTIABLE_TYPE = const _MetadataAttrs(280);
  static const ATTR_IS_SUBTYPE = const _MetadataAttrs(258);
  static const ATTR_SUPERTYPE_SCHEMA_NAME = const _MetadataAttrs(259);
  static const ATTR_SUPERTYPE_NAME = const _MetadataAttrs(260);
  static const ATTR_FSPRECISION = const _MetadataAttrs(16);
  static const ATTR_LFPRECISION = const _MetadataAttrs(17);
  static const ATTR_IS_FINAL_METHOD = const _MetadataAttrs(281);
  static const ATTR_IS_INSTANTIABLE_METHOD = const _MetadataAttrs(282);
  static const ATTR_IS_OVERRIDING_METHOD = const _MetadataAttrs(283);
  static const ATTR_CHAR_USED = const _MetadataAttrs(285);
  static const ATTR_CHAR_SIZE = const _MetadataAttrs(286);
  static const ATTR_COL_ENC = const _MetadataAttrs(102);
  static const ATTR_COL_ENC_SALT = const _MetadataAttrs(103);
  static const ATTR_TABLE_ENC = const _MetadataAttrs(417);
  static const ATTR_TABLE_ENC_ALG = const _MetadataAttrs(418);
  static const ATTR_TABLE_ENC_ALG_ID = const _MetadataAttrs(419);
}

abstract class _Metadata {
  bool getBoolean(_MetadataAttrs attr) => getBoolean(attr.value);
  int getInt(_MetadataAttrs attr) => getInt(attr.value);
  num getNumber(_MetadataAttrs attr) => getNumber(attr.value);
  String getString(_MetadataAttrs attr) => getString(attr.value);
  DateTime getTimestamp(_MetadataAttrs attr) => getTimestamp(attr.value);
  int getUInt(_MetadataAttrs attr) => getUInt(attr.value);

  int getObjectId() => getInt(_MetadataAttrs.ATTR_OBJID);
  String getObjectName() => getString(_MetadataAttrs.ATTR_OBJ_NAME);
  String getObjectSchema() => getString(_MetadataAttrs.ATTR_OBJ_SCHEMA);
  // TODO: support ATTR_PTYPE
  DateTime getObjectTimestamp() => getTimestamp(_MetadataAttrs.ATTR_TIMESTAMP);

  bool _getBoolean(int attrId) native 'OracleMetadata_getBoolean';

  int _getInt(int attrId) native 'OracleMetadata_getInt';

  num _getNumber(int attrId) native 'OracleMetadata_getNumber';

  String _getString(int attrId) native 'OracleMetadata_getString';

  DateTime _getTimestamp(int attrId) native 'OracleMetadata_getTimestamp';

  int _getUInt(int attrId) native 'OracleMetadata_getUInt';
}

class ColumnMetadata extends _Metadata {
  ColumnMetadata._();

  int getCharUsed() => getInt(_MetadataAttrs.ATTR_CHAR_USED);
  int getCharSize() => getUInt(_MetadataAttrs.ATTR_CHAR_SIZE);
  int getDataSize() => getUInt(_MetadataAttrs.ATTR_DATA_SIZE);
  String getDataType() => getString(_MetadataAttrs.ATTR_DATA_TYPE);
  String getName() => getString(_MetadataAttrs.ATTR_NAME);
  int getPrecision() => getInt(_MetadataAttrs.ATTR_PRECISION);
  int getScale() => getInt(_MetadataAttrs.ATTR_SCALE);
  bool canNull() => getInt(_MetadataAttrs.ATTR_IS_NULL) != 0;
  String getTypeName() => getString(_MetadataAttrs.ATTR_TYPE_NAME);
  String getSchemaName() => getString(_MetadataAttrs.ATTR_SCHEMA_NAME);
  int getCharsetId() => getInt(_MetadataAttrs.ATTR_CHARSET_ID);
  String getCharsetForm() => getString(_MetadataAttrs.ATTR_CHARSET_FORM);
}
