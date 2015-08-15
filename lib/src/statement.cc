// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "statement.h"
#include "helpers.h"

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

    auto statement = getThis<occi::Statement>(args);
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

    auto statement = getThis<std::shared_ptr<Statement>>(args)->get()->stmt;

    try {
        occi::ResultSet* rs = statement->executeQuery();

        auto dh = NewInstanceWithPeer("ResultSet", rs);
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

void OracleStatement_setBlob(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<occi::Statement>(args);
    int64_t index = getDartArg<int64_t>(args, 1);
    auto blob = getPeer<occi::Blob>(args, 2);

    try {
        statement->setBlob(index, *blob);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleStatement_setClob(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto statement = getThis<occi::Statement>(args);
    int64_t index = getDartArg<int64_t>(args, 1);
    auto blob = getPeer<occi::Clob>(args, 2);

    try {
        statement->setClob(index, *blob);
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
    if(nullArg(args,2)){
        try{
            statement->setNull(index, occi::OCCIDATE);
        } CATCH_SQL_EXCEPTION
    }else{
        auto dartdate = getDartArg<Dart_Handle>(args, 2);

        int64_t year;
        int64_t month;
        int64_t day;
        int64_t hour;
        int64_t minute;
        int64_t second;

        HandleError(Dart_IntegerToInt64(Dart_GetField(dartdate, Dart_NewStringFromCString("year")), &year));
        HandleError(Dart_IntegerToInt64(Dart_GetField(dartdate, Dart_NewStringFromCString("month")), &month));
        HandleError(Dart_IntegerToInt64(Dart_GetField(dartdate, Dart_NewStringFromCString("day")), &day));
        HandleError(Dart_IntegerToInt64(Dart_GetField(dartdate, Dart_NewStringFromCString("hour")), &hour));
        HandleError(Dart_IntegerToInt64(Dart_GetField(dartdate, Dart_NewStringFromCString("minute")), &minute));
        HandleError(Dart_IntegerToInt64(Dart_GetField(dartdate, Dart_NewStringFromCString("second")), &second));

        try {
            //TODO: need to watch that this use of a different environment doesnt cause problems
            //also the environment is destroyed afterwards to prevent leakage. Trivial tests work, has the environment just not overwritten at this time?
            auto env = occi::Environment::createEnvironment();
            occi::Date odate(env, year, month, day, hour, minute, second);
            statement->setDate(index, odate);
            occi::Environment::terminateEnvironment(env);
        } CATCH_SQL_EXCEPTION
    }

    Dart_ExitScope();
}

void OracleStatement_setTimestamp(Dart_NativeArguments args) {

}
