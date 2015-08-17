// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#pragma once

#include <dart_api.h>

#include "statement.h"

#include <stdio.h>

namespace occi = oracle::occi;

struct ResultSet {
    std::shared_ptr<Statement> stmt;
    occi::ResultSet *resultSet;

    ResultSet(std::shared_ptr<Statement> stmt,
              occi::ResultSet *resultSet) : stmt(stmt), resultSet(resultSet) {
    }

    ~ResultSet() {
        //printf("In ~ResultSet\n");
        stmt.get()->stmt->closeResultSet(resultSet);
    }
};

void OracleResultSet_finalizer(void * isolate_callback_data,
                               Dart_WeakPersistentHandle handle,
                               void* peer);
void OracleResultSet_getColumnListMetadata(Dart_NativeArguments arguments);
void OracleResultSet_cancel(Dart_NativeArguments arguments);
void OracleResultSet_getBFile(Dart_NativeArguments arguments);
void OracleResultSet_getBlob(Dart_NativeArguments arguments);
void OracleResultSet_getClob(Dart_NativeArguments arguments);
void OracleResultSet_getBytes(Dart_NativeArguments arguments);
void OracleResultSet_getString(Dart_NativeArguments arguments);
void OracleResultSet_getNum(Dart_NativeArguments arguments);
void OracleResultSet_getInt(Dart_NativeArguments arguments);
void OracleResultSet_getDouble(Dart_NativeArguments arguments);
void OracleResultSet_getNumber(Dart_NativeArguments arguments);
void OracleResultSet_getDate(Dart_NativeArguments arguments);
void OracleResultSet_getTimestamp(Dart_NativeArguments arguments);
void OracleResultSet_getRowID(Dart_NativeArguments arguments);
void OracleResultSet_next(Dart_NativeArguments arguments);
