// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "helpers.h"
#include <algorithm>
#include <cassert>
#include <occi.h>

namespace occi = oracle::occi;

template <typename T>
void lob_finalizer(void* isolate_callback_data,
                   Dart_WeakPersistentHandle handle,
                   void* peer) {
    delete (T *)peer;
}

template <typename T>
void lob_append(Dart_NativeArguments args){
    Dart_EnterScope();

    auto thislob = getThis<std::pair<occi::Connection*, T*>>(args)->second;
    auto otherlob = getAddressPair<void, T>(args, 1)->second;

    try {
        thislob->append(*otherlob);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

template <typename T>
void lob_copy(Dart_NativeArguments args){
    Dart_EnterScope();

    auto thislob = getThis<std::pair<occi::Connection*, T*>>(args)->second;
    auto otherlob = getAddressPair<void, T>(args, 1)->second;

    int64_t length = getDartArg<int64_t>(args, 2);

    try {
        thislob->copy(*otherlob, length);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

template <typename T>
void lob_length(Dart_NativeArguments args){
    Dart_EnterScope();

    auto lob = getThis<std::pair<occi::Connection*, T*>>(args)->second;

    try {
        int len = lob->length();
        Dart_Handle dh = HandleError(Dart_NewIntegerFromUint64(len));
        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

template <typename T>
void lob_trim(Dart_NativeArguments args){
    Dart_EnterScope();

    auto lob = getThis<std::pair<occi::Connection*, T*>>(args)->second;
    int64_t length = getDartArg<int64_t>(args, 1);

    try {
        lob->trim(length);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

//list<bytes> read(int amt, int offset)
template <typename T>
void lob_read(Dart_NativeArguments args){
    Dart_EnterScope();

    auto lob = getThis<std::pair<occi::Connection*, T*>>(args)->second;
    int64_t amount = getDartArg<int64_t>(args, 1);
    int64_t offset = getDartArg<int64_t>(args, 2);

    try {

        int64_t length = lob->length();
        length = std::min(amount, length);
        std::unique_ptr<uint8_t> buf( new uint8_t(length));

        int rnum = lob->read(amount, buf.get(), length, offset);
        assert(rnum == length);

        Dart_Handle list = HandleError(Dart_NewList(length));
        HandleError(Dart_ListSetAsBytes(list, 0, buf.get(), length));

        Dart_SetReturnValue(args, list);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

//int read(int amt, list<bytes> buf, int offset)
template <typename T>
void lob_write(Dart_NativeArguments args){
    Dart_EnterScope();

    auto lob = getThis<std::pair<occi::Connection*, T*>>(args)->second;
    int64_t amount = getDartArg<int64_t>(args, 1);
    Dart_Handle dartlist = getDartArg<Dart_Handle>(args, 2);
    int64_t offset = getDartArg<int64_t>(args, 3);

    try {

        std::unique_ptr<uint8_t> buf( new uint8_t(amount));
        HandleError(Dart_ListGetAsBytes(dartlist, 0, buf.get(), amount));

        int wnum = lob->write(amount, buf.get(), amount, offset);
        assert(wnum == amount);

        Dart_Handle wrote = HandleError(Dart_NewIntegerFromUint64(wnum));

        Dart_SetReturnValue(args, wrote);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}
