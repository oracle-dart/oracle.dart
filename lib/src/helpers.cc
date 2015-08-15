// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "helpers.h"

#include <stdio.h>
#include <occi.h>
namespace occi = oracle::occi;

Dart_Handle GetDartLibrary(const char* libName) {
    Dart_Handle libraryUrl = HandleError(Dart_NewStringFromCString(libName));
    Dart_Handle library = HandleError(Dart_LookupLibrary(libraryUrl));
    return library;
}

Dart_Handle NewInstanceWithPeer(const char *class_name, void *peer) {
    Dart_Handle className = HandleError(Dart_NewStringFromCString(class_name));

    Dart_Handle oracleDartLibrary =
        GetDartLibrary("package:oracle/src/occi_extension.dart");

    Dart_Handle type = HandleError(
        Dart_GetType(oracleDartLibrary,
                     className,
                     0,
                     NULL));

    Dart_Handle constructorName = HandleError(Dart_NewStringFromCString("_"));

    Dart_Handle obj = HandleError(Dart_New(type, constructorName, 0, NULL));

    HandleError(Dart_SetPeer(obj, peer));
    return obj;
}



void printDartToString(Dart_Handle dh) {
    char *tostr;
    Dart_StringToCString(Dart_ToString(dh), (const char **)&tostr);

    printf("%s\n", tostr);
}

Dart_Handle HandleError(Dart_Handle handle) {
    if (Dart_IsError(handle)) Dart_PropagateError(handle);
    return handle;
}

bool nullArg(Dart_NativeArguments args, int index){
    Dart_Handle dh = HandleError(Dart_GetNativeArgument(args, index));
    return Dart_IsNull(dh);
}

template<>
std::string getDartArg<std::string>(Dart_NativeArguments args, int index){
    Dart_Handle stringhandle = HandleError(Dart_GetNativeArgument(args, index));
    char *c;
    HandleError(Dart_StringToCString(stringhandle, (const char**)&c));
    return std::string{c};
}
template<>
int64_t getDartArg<int64_t>(Dart_NativeArguments args, int index){
    Dart_Handle inthandle = HandleError(Dart_GetNativeArgument(args, index));
    int64_t i = 0;
    HandleError(Dart_IntegerToInt64(inthandle, &i));
    return i;
}

template<>
double getDartArg<double>(Dart_NativeArguments args, int index){
    Dart_Handle inthandle = HandleError(Dart_GetNativeArgument(args, index));
    double i = 0;
    HandleError(Dart_DoubleValue(inthandle, &i));
    return i;
}

template<>
Dart_Handle getDartArg<Dart_Handle>(Dart_NativeArguments args, int index){
    return HandleError(Dart_GetNativeArgument(args, index));
}
