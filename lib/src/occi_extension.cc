// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dart_api.h"
#include "occi.h"

#include "environment.h"
#include "connection.h"
#include "statement.h"
#include "resultset.h"
#include "bfile.h"
#include "blob.h"
#include "clob.h"
#include "metadata.h"

// Forward declaration of ResolveName function.
Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope);

// The name of the initialization function is the extension name followed
// by _Init.
DART_EXPORT Dart_Handle occi_extension_Init(Dart_Handle parent_library) {
    if (Dart_IsError(parent_library)) return parent_library;

    Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName, NULL);
    if (Dart_IsError(result_code)) return result_code;

    return Dart_Null();
}


struct FunctionLookup {
    const char* name;
    Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
    {"OracleEnvironment_init", OracleEnvironment_init},
    {"OracleEnvironment_createConnection", OracleEnvironment_createConnection},
    {"OracleConnection_commit", OracleConnection_commit},
    {"OracleConnection_createStatement", OracleConnection_createStatement},
    {"OracleConnection_rollback", OracleConnection_rollback},
    {"OracleConnection_getUsername", OracleConnection_getUsername},
    {"OracleConnection_getConnectionString", OracleConnection_getConnectionString},
    {"OracleConnection_changePassword", OracleConnection_changePassword},
    {"OracleConnection_terminate", OracleConnection_terminate},
    {"OracleStatement_getSql", OracleStatement_getSql},
    {"OracleStatement_setSql", OracleStatement_setSql},
    {"OracleStatement_setPrefetchRowCount", OracleStatement_setPrefetchRowCount},
    {"OracleStatement_execute", OracleStatement_execute},
    {"OracleStatement_executeQuery", OracleStatement_executeQuery},
    {"OracleStatement_executeUpdate", OracleStatement_executeUpdate},
    {"OracleStatement_getResultSet", OracleStatement_getResultSet},
    {"OracleStatement_status", OracleStatement_status},
    {"OracleStatement_setBytes", OracleStatement_setBytes},
    {"OracleStatement_setString", OracleStatement_setString},
    {"OracleStatement_setNum", OracleStatement_setNum},
    {"OracleStatement_setInt", OracleStatement_setInt},
    {"OracleStatement_setDouble", OracleStatement_setDouble},
    {"OracleStatement_setDate", OracleStatement_setDate},
    {"OracleStatement_setTimestamp", OracleStatement_setTimestamp},
    {"OracleResultSet_getColumnListMetadata", OracleResultSet_getColumnListMetadata},
    {"OracleResultSet_cancel", OracleResultSet_cancel},
    {"OracleResultSet_getBFile", OracleResultSet_getBFile},
    {"OracleResultSet_getBlob", OracleResultSet_getBlob},
    {"OracleResultSet_getClob", OracleResultSet_getClob},
    {"OracleResultSet_getBytes", OracleResultSet_getBytes},
    {"OracleResultSet_getString", OracleResultSet_getString},
    {"OracleResultSet_getNum", OracleResultSet_getNum},
    {"OracleResultSet_getInt", OracleResultSet_getInt},
    {"OracleResultSet_getDouble", OracleResultSet_getDouble},
    {"OracleResultSet_getDate", OracleResultSet_getDate},
    {"OracleResultSet_getTimestamp", OracleResultSet_getTimestamp},
    {"OracleResultSet_getRowID", OracleResultSet_getRowID},
    {"OracleResultSet_next", OracleResultSet_next},
    {"OracleBFile_getBytes", OracleBFile_getBytes},
    {"OracleBlob_append", OracleBlob_append},
    {"OracleBlob_write", OracleBlob_write},
    {"OracleBlob_read", OracleBlob_read},
    {"OracleBlob_copy", OracleBlob_copy},
    {"OracleBlob_length", OracleBlob_length},
    {"OracleBlob_trim", OracleBlob_trim},
    {"OracleClob_append", OracleClob_append},
    {"OracleClob_write", OracleClob_write},
    {"OracleClob_read", OracleClob_read},
    {"OracleClob_copy", OracleClob_copy},
    {"OracleClob_length", OracleClob_length},
    {"OracleClob_trim", OracleClob_trim},
    {"OracleMetadata_getBoolean", OracleMetadata_getBoolean},
    {"OracleMetadata_getInt", OracleMetadata_getInt},
    {"OracleMetadata_getNumber", OracleMetadata_getNumber},
    {"OracleMetadata_getString", OracleMetadata_getString},
    {"OracleMetadata_getTimestamp", OracleMetadata_getTimestamp},
    {"OracleMetadata_getUInt", OracleMetadata_getUInt},
    {NULL, NULL}};

Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope) {
    if (!Dart_IsString(name)) return NULL;
    Dart_NativeFunction result = NULL;
    Dart_EnterScope();
    const char* cname;
    HandleError(Dart_StringToCString(name, &cname));

    for (int i=0; function_list[i].name != NULL; ++i) {
        if (strcmp(function_list[i].name, cname) == 0) {
            result = function_list[i].function;
            break;
        }
    }
    Dart_ExitScope();
    return result;
}
