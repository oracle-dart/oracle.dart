// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#pragma once

#include <dart_api.h>
#include <occi.h>
#include <iostream>

#include "connection.h"

namespace occi = oracle::occi;

struct Statement {
    std::shared_ptr<Connection> conn;
    occi::Statement *stmt;

    Statement(std::shared_ptr<Connection> conn, std::string sql) : conn(conn) {
        stmt = conn.get()->conn->createStatement(sql);
    }

    ~Statement() {
        //printf("in ~Statement\n");
        conn.get()->conn->terminateStatement(stmt);
    }
};

void OracleStatement_finalizer(void* isolate_callback_data,
                               Dart_WeakPersistentHandle handle,
                               void* peer);

void OracleStatement_getSql(Dart_NativeArguments arguments);
void OracleStatement_setSql(Dart_NativeArguments arguments);
void OracleStatement_setPrefetchRowCount(Dart_NativeArguments args);
void OracleStatement_execute(Dart_NativeArguments arguments);
void OracleStatement_executeQuery(Dart_NativeArguments arguments);
void OracleStatement_executeUpdate(Dart_NativeArguments arguments);
void OracleStatement_getResultSet(Dart_NativeArguments arguments);
void OracleStatement_status(Dart_NativeArguments arguments);
void OracleStatement_setBytes(Dart_NativeArguments arguments);
void OracleStatement_setString(Dart_NativeArguments arguments);
void OracleStatement_setNum(Dart_NativeArguments arguments);
void OracleStatement_setInt(Dart_NativeArguments arguments);
void OracleStatement_setDouble(Dart_NativeArguments arguments);
void OracleStatement_setNumber(Dart_NativeArguments arguments);
void OracleStatement_setDate(Dart_NativeArguments arguments);
void OracleStatement_setTimestamp(Dart_NativeArguments arguments);
