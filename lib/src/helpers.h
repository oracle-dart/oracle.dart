// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#pragma once

#include <dart_api.h>
#include <utility>
#include <stdexcept>
#include <memory>
#include <occi.h>

#define Dart_This(args) HandleError(Dart_GetNativeArgument(args, 0))

#define CATCH_SQL_EXCEPTION \
    catch (oracle::occi::SQLException e) { \
        HandleError(Dart_ThrowException(NewDartExceptionFromOracleException(e))); \
    }

Dart_Handle GetDartLibrary(const char*);

Dart_Handle HandleError(Dart_Handle handle);

Dart_Handle NewInstanceWithPeer(const char *class_name, void *peer);

bool nullArg(Dart_NativeArguments args, int index);

Dart_Handle NewDateTimeFromOracleTimestamp(oracle::occi::Timestamp ts);
oracle::occi::Timestamp NewOracleTimestampFromDateTime(Dart_Handle dateTime);

Dart_Handle NewDateTimeFromOracleDate(oracle::occi::Date date);
oracle::occi::Date NewOracleDateFromDateTime(Dart_Handle dateTime);

Dart_Handle NewByteDataFromOracleBytes(oracle::occi::Bytes bytes);
oracle::occi::Bytes NewOracleBytesFromByteData(Dart_Handle byteData);

Dart_Handle NewDartExceptionFromOracleException(oracle::occi::SQLException e);

template<typename T>
T* getPeer(Dart_NativeArguments args, int index){
    T* p;
    auto dh = HandleError(Dart_GetNativeArgument(args, index));
    HandleError(Dart_GetPeer(dh, (void **)&p));
    return p;
}

template<typename T, typename R>
std::pair<T*, R*>* getAddressPair(Dart_NativeArguments args, int index){
    return getPeer<std::pair<T*,R*>>(args, index);
}

template<typename T>
T* getThis(Dart_NativeArguments args){
    T *t;
    Dart_GetPeer(Dart_This(args), (void **)&t);
    return t;
}

void printDartToString(Dart_Handle dh);

template<typename T>
T getDartArg(Dart_NativeArguments args, int index);

template<typename P, typename C>
Dart_Handle newInstance(P* parent, C* child){
    //std::unique_ptr<std::pair<P*, C*>> ptr(std::make_pair(parent, child));
    auto ptr = new std::pair<P*, C*>(parent, child);
    const char *name;
    if(std::is_same<C, oracle::occi::ResultSet>::value)
        name = "ResultSet";
    if(std::is_same<C, oracle::occi::Statement>::value)
        name = "Statement";
    if(std::is_same<C, oracle::occi::Connection>::value)
        name = "Connection";
    if(std::is_same<C, oracle::occi::Blob>::value)
        name = "Blob";
    if(std::is_same<C, oracle::occi::Clob>::value)
        name = "Clob";
    Dart_Handle dh = HandleError(NewInstanceWithPeer(name, ptr));
    return dh;
}
