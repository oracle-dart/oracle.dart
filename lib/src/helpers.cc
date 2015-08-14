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

Dart_Handle NewDateTimeFromOracleTimestamp(oracle::occi::Timestamp ts) {
    Dart_Handle lib = GetDartLibrary("dart:core");
    Dart_Handle dtType = HandleError(Dart_GetType(lib, Dart_NewStringFromCString("DateTime"), 0, NULL));
    Dart_Handle durType = HandleError(Dart_GetType(lib, Dart_NewStringFromCString("Duration"), 0, NULL));

    int year, tzOffsetHour, tzOffsetMinute;
    unsigned int month, day, hour, minute, second, fs;

    ts.getDate(year, month, day);
    ts.getTime(hour, minute, second, fs);
    ts.getTimeZoneOffset(tzOffsetHour, tzOffsetMinute);

    // Construct the DateTime object as UTC
    std::vector<Dart_Handle> dtArgs = {
        Dart_NewInteger(year),
        Dart_NewInteger(month),
        Dart_NewInteger(day),
        Dart_NewInteger(hour),
        Dart_NewInteger(minute),
        Dart_NewInteger(second),
        Dart_NewInteger(fs / 1E6) // assuming fractional seconds are nanoseconds
    };

    Dart_Handle dt = HandleError(Dart_New(dtType,
                                          Dart_NewStringFromCString("utc"),
                                          7,
                                          &dtArgs[0]));


    // Handle the offset by creating a Duration object and adding
    // it to the created DateTime object
    std::vector<Dart_Handle> durArgs = {
        Dart_NewInteger(0) /* days */,
        Dart_NewInteger(tzOffsetHour),
        Dart_NewInteger(tzOffsetMinute)
    };

    Dart_Handle microseconds = HandleError(Dart_NewInteger(((tzOffsetHour * 60) + tzOffsetMinute) * 60 * 1e6));

    Dart_Handle duration = HandleError(Dart_New(durType,
                                                Dart_NewStringFromCString("_microseconds"),
                                                1,
                                                &microseconds));

    return HandleError(Dart_Invoke(dt,
                                   Dart_NewStringFromCString("subtract"),
                                   1,
                                   &duration));
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
