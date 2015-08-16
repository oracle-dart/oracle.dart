// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "resultset.h"

#include "metadata.h"
#include "lob.h"
#include "helpers.h"
#include <occi.h>
#include <vector>

namespace occi = oracle::occi;

void OracleResultSet_Finalizer(void * isolate_callback_data,
                               Dart_WeakPersistentHandle handle,
                               void* peer) {
    Dart_EnterScope();

    auto p = (std::pair<occi::Statement *, occi::ResultSet *> *)peer;
    p->first->closeResultSet(p->second);

    Dart_ExitScope();
}

void OracleResultSet_getColumnListMetadata(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    std::vector<occi::MetaData> data;

    try {
        data = rs->getColumnListMetaData();
    } CATCH_SQL_EXCEPTION
        
    Dart_Handle list = Dart_NewList(data.size());

    for (unsigned int i = 0; i < data.size(); i++) {
        occi::MetaData *md = new occi::MetaData(data[i]);
        Dart_Handle mdata = NewInstanceWithPeer("ColumnMetadata", (void *)md);

        Dart_SetPeer(mdata, (void *)md);
        Dart_NewWeakPersistentHandle(mdata,
                                     (void *)md,
                                     sizeof(md),
                                     OracleMetadata_Finalizer);

        Dart_ListSetAt(list, i, mdata);
    }

    Dart_SetReturnValue(args, list);

    Dart_ExitScope();
}

void OracleResultSet_cancel(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);

    try {
        rs->cancel();
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getBFile(Dart_NativeArguments args) {

}

void OracleResultSet_getBlob(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        if(rs->isNull(index)){
            Dart_SetReturnValue(args, Dart_Null());
            Dart_ExitScope();
            return;
        }
        occi::Blob blob = rs->getBlob(index);
        occi::Blob* heapblob = new occi::Blob(blob);

        Dart_Handle dh = newInstance<void, occi::Blob>(0, heapblob);
        Dart_NewWeakPersistentHandle(dh, heapblob, sizeof(heapblob), lob_finalizer<occi::Blob>);
        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getClob(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        if(rs->isNull(index)){
            Dart_SetReturnValue(args, Dart_Null());
            Dart_ExitScope();
            return;
        }
        occi::Clob clob = rs->getClob(index);
        occi::Clob* heapclob = new occi::Clob(clob);

        Dart_Handle dh = newInstance<void, occi::Clob>(0, heapclob);
        Dart_NewWeakPersistentHandle(dh, heapclob, sizeof(heapclob), lob_finalizer<occi::Clob>);
        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getBytes(Dart_NativeArguments args) {

}

void OracleResultSet_getString(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        if(rs->isNull(index)){
            Dart_SetReturnValue(args, Dart_Null());
            Dart_ExitScope();
            return;
        }
        std::string s = rs->getString(index);
        Dart_Handle dh = HandleError(Dart_NewStringFromCString(s.c_str()));

        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getInt(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        occi::Number n = rs->getNumber(index);
        return Dart_SetReturnValue(args,
                                   n.isNull()
                                   ? Dart_Null()
                                   : HandleError(Dart_NewInteger((int)n)));

    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getDouble(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        occi::Number n = rs->getNumber(index);
        return Dart_SetReturnValue(args,
                                   n.isNull()
                                   ? Dart_Null()
                                   : HandleError(Dart_NewDouble((double)n)));
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getNum(Dart_NativeArguments args) {
    OracleResultSet_getDouble(args);
}

//TODO add support for timezones
void OracleResultSet_getDate(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    occi::Date date;
    try {
        if(rs->isNull(index)){
            Dart_SetReturnValue(args, Dart_Null());
            Dart_ExitScope();
            return;
        }
        date = rs->getDate(index);
    } CATCH_SQL_EXCEPTION

    int year;
    unsigned int month;
    unsigned int day;
    unsigned int hour;
    unsigned int min;
    unsigned int seconds;
    date.getDate(year, month, day, hour, min, seconds);

    std::vector<Dart_Handle> dargs;
    dargs.push_back(Dart_NewInteger(year));
    dargs.push_back(Dart_NewInteger(month));
    dargs.push_back(Dart_NewInteger(day));
    dargs.push_back(Dart_NewInteger(hour));
    dargs.push_back(Dart_NewInteger(min));
    dargs.push_back(Dart_NewInteger(seconds));

    Dart_Handle lib = GetDartLibrary("dart:core");
    Dart_Handle type = HandleError(Dart_GetType(lib, Dart_NewStringFromCString("DateTime"), 0, NULL));
    Dart_Handle obj = HandleError(Dart_New(type, Dart_Null(), 6, &dargs[0]));

    Dart_SetReturnValue(args, obj);
    Dart_ExitScope();
}

void OracleResultSet_getTimestamp(Dart_NativeArguments args) {
    Dart_EnterScope();
    
    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        occi::Timestamp ts = rs->getTimestamp(index);
        Dart_SetReturnValue(args, NewDateTimeFromOracleTimestamp(ts));
    } CATCH_SQL_EXCEPTION;

    Dart_ExitScope();
}

void OracleResultSet_getRowID(Dart_NativeArguments args) {

}

//return true if more data exists
void OracleResultSet_next(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<occi::ResultSet>(args);
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        occi::ResultSet::Status st = rs->next(index); 
        Dart_SetReturnValue(args,
                            st == occi::ResultSet::DATA_AVAILABLE
                            ? Dart_True()
                            : Dart_False());
    } CATCH_SQL_EXCEPTION


    Dart_ExitScope();
}
