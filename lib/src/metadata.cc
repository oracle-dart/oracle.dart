// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "metadata.h"

#include <occi.h>

namespace occi = oracle::occi;

void OracleMetadata_Finalizer(void * isolate_callback_data,
                              Dart_WeakPersistentHandle handle,
                              void* peer) {
    delete (occi::MetaData *)peer;
}

void OracleMetadata_getBoolean(Dart_NativeArguments arguments) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString("Not implemented")));
}

void OracleMetadata_getInt(Dart_NativeArguments arguments) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString("Not implemented")));
}

void OracleMetadata_getNumber(Dart_NativeArguments arguments) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString("Not implemented")));
}

void OracleMetadata_getString(Dart_NativeArguments arguments) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString("Not implemented")));
}

void OracleMetadata_getTimeStamp(Dart_NativeArguments arguments) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString("Not implemented")));
}

void OracleMetadata_getUInt(Dart_NativeArguments arguments) {
    Dart_PropagateError(Dart_NewUnhandledExceptionError(
        Dart_NewStringFromCString("Not implemented")));
}
