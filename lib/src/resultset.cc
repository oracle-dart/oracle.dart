// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "resultset.h"

#include "metadata.h"
#include "lob.h"
#include "helpers.h"
#include <occi.h>
#include <vector>

namespace occi = oracle::occi;

void OracleResultSet_finalizer(void * isolate_callback_data,
                               Dart_WeakPersistentHandle handle,
                               void* peer) {
    delete (std::shared_ptr<ResultSet> *)peer;
}

void OracleResultSet_getColumnListMetadata(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs_sp = getThis<std::shared_ptr<ResultSet>>(args);
    std::vector<occi::MetaData> data;

    try {
        data = rs_sp->get()->resultSet->getColumnListMetaData();
    } CATCH_SQL_EXCEPTION
        
    Dart_Handle list = Dart_NewList(data.size());

    for (unsigned int i = 0; i < data.size(); i++) {
        auto *ora_md = new occi::MetaData(data[i]);
        auto md = new Metadata(*rs_sp, ora_md);
        auto md_sp = new std::shared_ptr<Metadata>(md);

        Dart_Handle dart_md = NewInstanceWithPeer("ColumnMetadata", md_sp);

        Dart_NewWeakPersistentHandle(dart_md,
                                     (void *)md_sp,
                                     sizeof(md_sp),
                                     OracleMetadata_Finalizer);

        Dart_ListSetAt(list, i, dart_md);
    }

    Dart_SetReturnValue(args, list);

    Dart_ExitScope();
}

void OracleResultSet_cancel(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;

    try {
        rs->cancel();
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getBFile(Dart_NativeArguments args) {

}

void OracleResultSet_getBlob(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
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

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
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

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
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

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
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

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
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

void OracleResultSet_getDate(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
    int64_t index = getDartArg<int64_t>(args, 1);

    try {
        occi::Date date = rs->getDate(index);
        Dart_SetReturnValue(args, NewDateTimeFromOracleDate(date));
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleResultSet_getTimestamp(Dart_NativeArguments args) {
    Dart_EnterScope();
    
    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
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

    auto rs = getThis<std::shared_ptr<ResultSet>>(args)->get()->resultSet;
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
