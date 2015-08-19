// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "connection.h"
#include "helpers.h"

#include "statement.h"

#include <occi.h>

namespace occi = oracle::occi;


void OracleConnection_finalizer(void* isolate_callback_data,
                                Dart_WeakPersistentHandle handle,
                                void* peer) {
    //printf("in OracleConnection_finalizer\n");
    delete (std::shared_ptr<Connection> *)peer;
}

void OracleConnection_commit(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto conn = getThis<std::shared_ptr<Connection>>(args)->get()->conn;

    try {
        conn->commit();
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleConnection_createStatement(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto conn = getThis<std::shared_ptr<Connection>>(args);
    auto sql = getDartArg<std::string>(args, 1);

    try {
        auto stmt = new std::shared_ptr<Statement>(new Statement(*conn, sql));

        Dart_Handle dh = NewInstanceWithPeer("Statement", (void *)stmt);
        Dart_NewWeakPersistentHandle(dh, stmt, sizeof(stmt), OracleStatement_finalizer);

        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION


    Dart_ExitScope();
}

void OracleConnection_rollback(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto conn = getThis<std::shared_ptr<Connection>>(args)->get()->conn;

    try {
        conn->rollback();
    } CATCH_SQL_EXCEPTION


    Dart_ExitScope();
}


void OracleConnection_getUsername(Dart_NativeArguments args){
    Dart_EnterScope();

    std::string s = getThis<std::shared_ptr<Connection>>(args)->get()->username;
    Dart_Handle dh = HandleError(Dart_NewStringFromCString(s.c_str()));
    Dart_SetReturnValue(args, dh);

    Dart_ExitScope();
}

void OracleConnection_getConnectionString(Dart_NativeArguments args){
    Dart_EnterScope();

    std::string s = getThis<std::shared_ptr<Connection>>(args)->get()->connstr;
    Dart_Handle dh = HandleError(Dart_NewStringFromCString(s.c_str()));
    Dart_SetReturnValue(args, dh);

    Dart_ExitScope();
}

void OracleConnection_changePassword(Dart_NativeArguments args){
    Dart_EnterScope();

    auto conn = getThis<std::shared_ptr<Connection>>(args)->get()->conn;
    std::string username  = getThis<std::shared_ptr<Connection>>(args)->get()->username;
    auto oldpass = getDartArg<std::string>(args, 1);
    auto newpass = getDartArg<std::string>(args, 2);

    try {
        conn->changePassword(username, oldpass, newpass);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleConnection_terminate(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto conn = getThis<std::shared_ptr<Connection>>(args)->get();
    try {
        conn->terminate();
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}
