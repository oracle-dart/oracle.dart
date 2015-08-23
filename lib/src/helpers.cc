// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "helpers.h"

#include <stdio.h>
#include <occi.h>
namespace occi = oracle::occi;

// Ratio between OCI "fractional seconds" (nanoseconds) to milliseconds
const uint64_t OCCI_FS_MS_RATIO = 1E6;

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
    if (ts.isNull()) {
        return Dart_Null();
    }

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
        Dart_NewInteger(fs / OCCI_FS_MS_RATIO)
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

    Dart_Handle microseconds = HandleError(Dart_NewInteger(((tzOffsetHour * 60) + tzOffsetMinute) * 60 * OCCI_FS_MS_RATIO));

    Dart_Handle duration = HandleError(Dart_New(durType,
                                                Dart_NewStringFromCString("_microseconds"),
                                                1,
                                                &microseconds));

    return HandleError(Dart_Invoke(dt,
                                   Dart_NewStringFromCString("subtract"),
                                   1,
                                   &duration));
}

oracle::occi::Timestamp NewOracleTimestampFromDateTime(Dart_Handle dateTime) {
    auto env = oracle::occi::Environment::createEnvironment();
    oracle::occi::Timestamp ts(env);

    if (Dart_IsNull(dateTime)) {
        ts.setNull();
        oracle::occi::Environment::terminateEnvironment(env); 
        return ts;
    }

    int64_t year, month, day, hour, minute, second, fs;

    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("year")), &year));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("month")), &month));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("day")), &day));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("hour")), &hour));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("minute")), &minute));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("second")), &second));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("millisecond")), &fs));
    

    Dart_Handle tzOffset = HandleError(Dart_GetField(dateTime,
                                                   Dart_NewStringFromCString("timeZoneOffset")));

    int64_t tzOffsetInMinutes;
    HandleError(Dart_IntegerToInt64(Dart_GetField(tzOffset, Dart_NewStringFromCString("inMinutes")), &tzOffsetInMinutes));

    int64_t tzOffsetHours = tzOffsetInMinutes / 60;
    int64_t tzOffsetMinutes = tzOffsetInMinutes % 60;

    fs = fs * OCCI_FS_MS_RATIO;

    ts.setDate(year, month, day);
    ts.setTime(hour, minute, second, fs);
    ts.setTimeZoneOffset(tzOffsetHours, tzOffsetMinutes);

    oracle::occi::Environment::terminateEnvironment(env); 
    return ts; 
}

Dart_Handle NewDateTimeFromOracleDate(oracle::occi::Date date) {
    if (date.isNull()) {
        return Dart_Null();
    }
    
    int year;
    unsigned int month;
    unsigned int day;
    unsigned int hour;
    unsigned int min;
    unsigned int seconds;
    date.getDate(year, month, day, hour, min, seconds);

    std::vector<Dart_Handle> dargs = {
        Dart_NewInteger(year),
        Dart_NewInteger(month),
        Dart_NewInteger(day),
        Dart_NewInteger(hour),
        Dart_NewInteger(min),
        Dart_NewInteger(seconds),
    };

    Dart_Handle lib = GetDartLibrary("dart:core");
    Dart_Handle type = HandleError(Dart_GetType(lib, Dart_NewStringFromCString("DateTime"), 0, NULL));
    
    return HandleError(Dart_New(type, Dart_Null(), 6, &dargs[0]));
}

oracle::occi::Date NewOracleDateFromDateTime(Dart_Handle dateTime) {
    if (Dart_IsNull(dateTime)) {
        return oracle::occi::Date();
    }

    int64_t year;
    int64_t month;
    int64_t day;
    int64_t hour;
    int64_t minute;
    int64_t second;

    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("year")), &year));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("month")), &month));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("day")), &day));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("hour")), &hour));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("minute")), &minute));
    HandleError(Dart_IntegerToInt64(Dart_GetField(dateTime, Dart_NewStringFromCString("second")), &second));

    auto env = oracle::occi::Environment::createEnvironment();
    oracle::occi::Date date(env, year, month, day, hour, minute, second);

    oracle::occi::Environment::terminateEnvironment(env);
    return date;
}

Dart_Handle NewDartExceptionFromOracleException(oracle::occi::SQLException e) {
    Dart_Handle oracleDartLibrary =
        GetDartLibrary("package:oracle/src/occi_extension.dart");

    Dart_Handle type = HandleError(
        Dart_GetType(oracleDartLibrary,
                     HandleError(Dart_NewStringFromCString("SqlException")),
                     0,
                     NULL));

    std::vector<Dart_Handle> args = {
        HandleError(Dart_NewInteger(e.getErrorCode())),
        HandleError(Dart_NewStringFromCString(e.getMessage().c_str()))
    };
    
    return Dart_New(type, Dart_Null(), 2, &args[0]);
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
