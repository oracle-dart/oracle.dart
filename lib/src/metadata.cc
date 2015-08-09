// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "helpers.h"
#include "metadata.h"

#include <occi.h>

namespace occi = oracle::occi;

void OracleMetadata_Finalizer(void * isolate_callback_data,
                              Dart_WeakPersistentHandle handle,
                              void* peer) {
    delete (occi::MetaData *)peer;
}

void OracleMetadata_getBoolean(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto metadata = getThis<occi::MetaData>(args);
    auto attrId = (occi::MetaData::AttrId) getDartArg<int64_t>(args, 1);

    try {
        Dart_SetReturnValue(args,
                            metadata->getBoolean(attrId)
                            ? Dart_True()
                            : Dart_False());
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleMetadata_getInt(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto metadata = getThis<occi::MetaData>(args);
    int64_t attrId = getDartArg<int64_t>(args, 1);

    try {
        int val = metadata->getInt((occi::MetaData::AttrId)attrId);
        Dart_SetReturnValue(args, Dart_NewInteger((int64_t)val));
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleMetadata_getNumber(Dart_NativeArguments args) {
    OracleMetadata_getUInt(args);
}

void OracleMetadata_getString(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto metadata = getThis<occi::MetaData>(args);
    int64_t attrId = getDartArg<int64_t>(args, 1);

    try {
        std::string str = metadata->getString((occi::MetaData::AttrId)attrId);
        Dart_SetReturnValue(args, Dart_NewStringFromCString(str.c_str()));
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleMetadata_getTimeStamp(Dart_NativeArguments args) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString("Not implemented")));
}

void OracleMetadata_getUInt(Dart_NativeArguments args) {
    Dart_EnterScope();

    auto metadata = getThis<occi::MetaData>(args);
    int64_t attrId = getDartArg<int64_t>(args, 1);

    try {
        unsigned int val = metadata->getUInt((occi::MetaData::AttrId)attrId);
        Dart_SetReturnValue(args, Dart_NewIntegerFromUint64((uint64_t)val));
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}
