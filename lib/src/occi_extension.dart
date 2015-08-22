// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

library oracle.src.occi_extension;

import 'dart-ext:occi_extension';
import 'dart:convert';

class Environment {
  Environment() {
    _init();
  }

  void _init() native 'OracleEnvironment_init';

  Connection createConnection(String username, String password,
      String connStr) native 'OracleEnvironment_createConnection';

  void terminateConnection(Connection conn) => conn.terminate();
}

class Connection {
  String _connectionString;
  String _username;

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
  void _bindMap(Statement stmt, [Map args]){
    if(args == null)
        return;
    for(var key in args.keys){
        stmt.bind(key, args[key]);
    }
  }

  String getUsername() native 'OracleConnection_getUsername';
  String getConnectionString() native 'OracleConnection_getConnectionString';
  String changePassword(String oldpass, String newpass) native 'OracleConnection_changePassword';
  void terminate() native 'OracleConnection_terminate';

  Statement execute(String sql, [dynamic args]) {
    var stmt = createStatement(sql);
    if(args is List)
        _bindArgs(stmt, args);
    else if(args is Map)
        _bindMap(stmt, args);
    stmt.execute();
    return stmt;
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

  ResultSet getResultSet() native 'OracleStatement_getResultSet';

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

  // Set a DATE column
  //
  // Note: Because Oracle's DATE type does not support timezones
  // The timezone information of the given [date] is ignored
  void setDate(int index, DateTime date) native 'OracleStatement_setDate';

  // Set a TIMESTAMP column
  //
  // Note: Because Oracle's TIMESTAMP type is timezone-aware,
  // the timezone of the [timestamp] is used.
  void setTimestamp(
      int index, DateTime timestamp) native 'OracleStatement_setTimestamp';

  void setDynamic(int index, dynamic input){
    if(input is int){
      setInt(index, input);
    } else if(input is double){
      setDouble(index, input);
    }  else if(input is num){
      setNum(index, input);
    }  else if(input is String){
      setString(index, input);
    }  else if(input is DateTime){
      setTimestamp(index, input);
    }else{
      throw("unsupported type");
    }
  }

  bool _inString(String input, int index){
    bool instring = false;
    String watching = "";
    for(int x = 0; x < index; x++){
        if(input[x] == "'" && input.length > x + 1 && input[x+1] == "'"){
            x++;
        }else if(instring){
            if(input[x] == watching)
                instring = false;
        } else if(input[x] == '"' || input[x] == "'"){
            instring = true;
            watching = input[x];
        }
    }
    return instring;
  }

  void bind(dynamic bind, dynamic input){
    if(bind is int || bind is num)
      setDynamic(bind, input);
    else if(bind is String){
      RegExp exp = new RegExp(r"[:][A-Za-z0-9_]+");
      Iterable<Match> matches = exp.allMatches(this.sql);
      int i = 0;
      for(Match m in matches){
        if(!_inString(m.input, m.start)){
            i++;
            if(m.group(0) == bind && !_inString(m.input, m.start)){
              setDynamic(i, input);
            }
        }
      }
    }
    else
        throw("bind name is of unsupported type");
  }
}

class ResultSet {
  ResultSet._();

  List<ColumnMetadata> getColumnListMetadata()
    native 'OracleResultSet_getColumnListMetadata';

  dynamic cancel() native 'OracleResultSet_cancel';

  BFile getBFile(int index) native 'OracleResultSet_getBFile';

  Blob getBlob(int index) native 'OracleResultSet_getBlob';

  Clob getClob(int index) native 'OracleResultSet_getClob';

  dynamic get(int index){
    var md = getColumnListMetadata();
    var x = md[index-1].getDataType();
    switch(x){
      case DataType.CHR:
        return getString(index);
      case DataType.NUM:
        return getNum(index);
      case DataType.BLOB:
        return getBlob(index);
      case DataType.CLOB:
        return getClob(index);
      case DataType.DAT:
        return getDate(index);
    }
    return getString(index);
  }

  List<int> getBytes(int index) native 'OracleResultSet_getBytes';

  String getString(int index) native 'OracleResultSet_getString';

  num getNum(int index) native 'OracleResultSet_getNum';

  int getInt(int index) native 'OracleResultSet_getInt';

  double getDouble(int index) native 'OracleResultSet_getDouble';

  // Get a [DateTime] at a given [index]
  //
  // Note: This method will return a [DateTime] with the local timezone
  // **without** performing any timezone offset calculation
  DateTime getDate(int index) native 'OracleResultSet_getDate';


  // Get a [DateTime] at a given [index]
  //
  // Note: This method will return a [new DateTime.utc]. If timezone information
  // is provided by Oracle, the UTC offset will be used.
  DateTime getTimestamp(int index) native 'OracleResultSet_getTimestamp';

  dynamic getRowID() native 'OracleResultSet_getRowID';

  bool next([int numberOfRows=1]) {
      _next(numberOfRows);
  }
      
  bool _next(int numberOfRows) native 'OracleResultSet_next';

  Map<String, dynamic> row(){
    Map<String, dynamic> map = new Map<String, dynamic>();
    List<ColumnMetadata> metadata = getColumnListMetadata();
    for(var x = 0; x < metadata.length; x++){
      map[metadata[x].getName()] = get(x+1);
    }
    return map;
  }

}

class BFile {
  List<int> get bytes native 'OracleBFile_getBytes';
}

class Blob {
  Blob._();

  Blob.fromBytes(List<int> bytes) {
    // _initSetBytes(bytes);
  }
  void append(Blob b) native 'OracleBlob_append';

  void copy(Blob b, int length) native 'OracleBlob_copy';

  int length() native 'OracleBlob_length';

  void trim(int length) native 'OracleBlob_trim';

  List<int> read(int amount, int offset) native 'OracleBlob_read';

  int write(int amount, List<int> buffer, int offset) native 'OracleBlob_write';

  //List<int> asBytes() native 'OracleBlob_asBytes';

  //void _initSetBytes(List<int> bytes) native 'OracleBlob_initSetBytes';
}

class Clob {
  Clob._();

  Clob.fromBytes(List<int> bytes) {
    // _initSetBytes(bytes);
  }
  void append(Clob b) native 'OracleClob_append';

  void copy(Clob b, int length) native 'OracleClob_copy';

  int length() native 'OracleClob_length';

  void trim(int length) native 'OracleClob_trim';

  String read(int amount, int offset) {
      List<int> li = _read_helper(amount, offset);
      return UTF8.decode(li);
  }
  
  List<int> _read_helper(int amount, int offset) native 'OracleClob_read';

  int write(int amount, String str, int offset) {

      List<int> li = UTF8.encode(str);

      return _write_helper(amount, li, offset);
  }
      
  int _write_helper(int amount, List<int> buffer, int offset) native 'OracleClob_write';
}

class DataType {
  final int _value;

  int get value => _value;

  const DataType(this._value);

  static var _map = {
    1: CHR,
    2: NUM,
    3: INT,
    4: FLT,
    5: STR,
    6: VNU,
    7: PDN,
    8: LNG,
    9: VCS,
    10: NON,
    11: RID,
    12: DAT,
    15: VBI,
    21: BFlOAT,
    22: BDOUBLE,
    23: BIN,
    24: LBI,
    68: UIN,
    91: SLS,
    94: LVC,
    95: LVB,
    96: AFC,
    97: AVC,
    100: IBFLOAT,
    101: IBDOUBLE,
    102: CUR,
    104: RDD,
    105: LAB,
    106: OSL,
    108: NTY,
    110: REF,
    112: CLOB,
    113: BLOB,
    114: BFILE,
    115: CFILE,
    116: RSET,
    122: NCO,
    156: VST,
    156: ODT,
    184: DATE,
    185: TIME,
    186: TIME_TZ,
    187: TIMESTAMP,
    188: TIMESTAMP_TZ,
    189: INTERVAL_YM,
    190: INTERVAL_DS,
    232: INTERVAL_LTZ,
  };

  static forNum(int i) => _map[i];

  static const CHR = const DataType(1);
  static const NUM = const DataType(2);
  static const INT = const DataType(3);
  static const FLT = const DataType(4);
  static const STR = const DataType(5);
  static const VNU = const DataType(6);
  static const PDN = const DataType(7);
  static const LNG = const DataType(8);
  static const VCS = const DataType(9);
  static const NON = const DataType(10);
  static const RID = const DataType(11);
  static const DAT = const DataType(12);
  static const VBI = const DataType(15);
  static const BFlOAT = const DataType(21);
  static const BDOUBLE = const DataType(22);
  static const BIN = const DataType(23);
  static const LBI = const DataType(24);
  static const UIN = const DataType(68);
  static const SLS = const DataType(91);
  static const LVC = const DataType(94);
  static const LVB = const DataType(95);
  static const AFC = const DataType(96);
  static const AVC = const DataType(97);
  static const IBFLOAT = const DataType(100);
  static const IBDOUBLE = const DataType(101);
  static const CUR = const DataType(102);
  static const RDD = const DataType(104);
  static const LAB = const DataType(105);
  static const OSL = const DataType(106);
  static const NTY = const DataType(108);
  static const REF = const DataType(110);
  static const CLOB = const DataType(112);
  static const BLOB = const DataType(113);
  static const BFILE = const DataType(114);
  static const CFILE = const DataType(115);
  static const RSET = const DataType(116);
  static const NCO = const DataType(122);
  static const VST = const DataType(156);
  static const ODT = const DataType(156);
  static const DATE = const DataType(184);
  static const TIME = const DataType(185);
  static const TIME_TZ = const DataType(186);
  static const TIMESTAMP = const DataType(187);
  static const TIMESTAMP_TZ = const DataType(188);
  static const INTERVAL_YM = const DataType(189);
  static const INTERVAL_DS = const DataType(190);
  static const INTERVAL_LTZ = const DataType(232);
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

enum ParamType {
  UNKNOWN,
  TABLE,
  VIEW,
  PROCEDURE,
  FUNCTION,
  PACKAGE,
  TYPE,
  SYNONYM,
  SEQUENCE,
  COLUMN,
  ARGUMENT,
  LIST,
  TYPE_ATTRIBUTE,
  TYPE_METHOD,
  TYPE_ARGUMENT,
  TYPE_RESULT,
  SCHEMA,
  DATABASE,
  RULE,
  RULE_SET,
  EVALUATION_CONTEXT,
  TABLE_ALIAS,
  VARIABLE_TYPE,
  NAME_VALUE
}

abstract class _Metadata {
  bool getBoolean(_MetadataAttrs attr) => _getBoolean(attr.value);
  int getInt(_MetadataAttrs attr) => _getInt(attr.value);
  num getNumber(_MetadataAttrs attr) => _getNumber(attr.value);
  String getString(_MetadataAttrs attr) => _getString(attr.value);
  DateTime getTimestamp(_MetadataAttrs attr) => _getTimestamp(attr.value);
  int getUInt(_MetadataAttrs attr) => _getUInt(attr.value);

  int getObjectId() => getUInt(_MetadataAttrs.ATTR_OBJ_ID);
  String getObjectName() => getString(_MetadataAttrs.ATTR_OBJ_NAME);
  String getObjectSchema() => getString(_MetadataAttrs.ATTR_OBJ_SCHEMA);
  ParamType getParamType() => ParamType.values[getInt(_MetadataAttrs.ATTR_PTYPE)];
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

  bool isCharUsed() => getUInt(_MetadataAttrs.ATTR_CHAR_USED) == 1;
  int getCharSize() => getUInt(_MetadataAttrs.ATTR_CHAR_SIZE);
  int getDataSize() => getInt(_MetadataAttrs.ATTR_DATA_SIZE);
  DataType getDataType() =>
    DataType.forNum(getInt(_MetadataAttrs.ATTR_DATA_TYPE));
  String getName() => getString(_MetadataAttrs.ATTR_NAME);
  int getPrecision() => getInt(_MetadataAttrs.ATTR_PRECISION);
  int getScale() => getInt(_MetadataAttrs.ATTR_SCALE);
  bool canNull() => getBoolean(_MetadataAttrs.ATTR_IS_NULL);
  String getTypeName() => getString(_MetadataAttrs.ATTR_TYPE_NAME);
  String getSchemaName() => getString(_MetadataAttrs.ATTR_SCHEMA_NAME);
  //int getCharsetId() => getInt(_MetadataAttrs.ATTR_CHARSET_ID);
  //String getCharsetForm() => getString(_MetadataAttrs.ATTR_CHARSET_FORM);
}
