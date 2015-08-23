// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "statement.h"

#include "helpers.h"
#include "resultset.h"

void OracleStatement_finalizer(void* isolate_callback_data,
                               Dart_WeakPersistentHandle handle,
                               void* peer) {
    delete (std::shared_ptr<Statement> *)peer;
}

void OracleStatement_getSql(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;

    const char* sql = statement->getSQL().c_str();
    Dart_Handle sqlHandle = HandleError(Dart_NewStringFromCString(sql));

    Dart_SetReturnValue(args, sqlHandle);
    Dart_ExitScope();
}

void OracleStatement_setSql(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;
    std::string newSql = getDartArg<std::string>(args, 1);
    statement->setSQL(newSql);

    Dart_ExitScope();
}

void OracleStatement_setPrefetchRowCount(Dart_NativeArguments args){
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;
    int64_t val = getDartArg<int64_t>(args, 1);
    statement->setPrefetchRowCount(val);

    Dart_ExitScope();
}

void OracleStatement_execute(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;

    try {
        //occi::Statement::Status status = statement->execute();
        int res = statement->execute();
        Dart_Handle dh = HandleError(Dart_NewInteger(res));
        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleStatement_status(Dart_NativeArguments args){
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;
    int res = statement->status();
    Dart_Handle dh = HandleError(Dart_NewInteger(res));
    Dart_SetReturnValue(args, dh);

    Dart_ExitScope();
}

void OracleStatement_executeQuery(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto stmt_sp_p = getThis<std::shared_ptr<Statement>>(args);
    auto statement = stmt_sp_p->get()->stmt;

    try {
        occi::ResultSet* oraResultSet = statement->executeQuery();

        auto rs = new ResultSet(*stmt_sp_p, oraResultSet);
        auto rs_sp = new std::shared_ptr<ResultSet>(rs);
        auto dh = NewInstanceWithPeer("ResultSet", rs_sp);

        Dart_NewWeakPersistentHandle(dh,
                                     rs_sp,
                                     sizeof(rs_sp),
                                     OracleResultSet_finalizer);

        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleStatement_executeUpdate(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;

    try {
        int64_t ar = statement->executeUpdate();

        auto dh = HandleError(Dart_NewInteger(ar));
        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();

}

void OracleStatement_getResultSet(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto stmt_sp_p = getThis<std::shared_ptr<Statement>>(args);
    auto statement = stmt_sp_p->get()->stmt;

    try {
        occi::ResultSet* oraResultSet = statement->executeQuery();

        auto rs = new ResultSet(*stmt_sp_p, oraResultSet);
        auto rs_sp = new std::shared_ptr<ResultSet>(rs);
        auto dh = NewInstanceWithPeer("ResultSet", rs_sp);

        Dart_NewWeakPersistentHandle(dh,
                                     rs_sp,
                                     sizeof(rs_sp),
                                     OracleResultSet_finalizer);

        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleStatement_setBytes(Dart_NativeArguments args) {

}

void OracleStatement_setString(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;

    int64_t index = getDartArg<int64_t>(args, 1);
    if(nullArg(args,2)){
        try{
            statement->setNull(index, occi::OCCISTRING);
        } CATCH_SQL_EXCEPTION
    }else{
        auto val = getDartArg<std::string>(args, 2);

        try {
            statement->setString(index, val);
        } CATCH_SQL_EXCEPTION
    }

    Dart_ExitScope();
}

void OracleStatement_setNum(Dart_NativeArguments args) {
    OracleStatement_setDouble(args);
}

void OracleStatement_setInt(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;

    int64_t index = getDartArg<int64_t>(args, 1);

    if(nullArg(args,2)){
        try{
            statement->setNull(index, occi::OCCIINT);
        } CATCH_SQL_EXCEPTION
    }else{
        auto val = getDartArg<int64_t>(args, 2);

        try {
            statement->setInt(index, val);
        } CATCH_SQL_EXCEPTION
    }
    Dart_ExitScope();
}

void OracleStatement_setDouble(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;
    int64_t index = getDartArg<int64_t>(args, 1);
    if(nullArg(args,2)){
        try{
            statement->setNull(index, occi::OCCIDOUBLE);
        } CATCH_SQL_EXCEPTION
    }else{
        auto val = getDartArg<double>(args, 2);

        try {
            statement->setDouble(index, val);
        } CATCH_SQL_EXCEPTION
    }

    Dart_ExitScope();
}

void OracleStatement_setDate(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;
    int64_t index = getDartArg<int64_t>(args, 1);

    auto dartdate = getDartArg<Dart_Handle>(args, 2);

    try {
        statement->setDate(index, NewOracleDateFromDateTime(dartdate));
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleStatement_setTimestamp(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;
    int64_t index = getDartArg<int64_t>(args, 1);
    auto val = getDartArg<Dart_Handle>(args, 2);

    try {
        statement->setTimestamp(index, NewOracleTimestampFromDateTime(val));
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}
