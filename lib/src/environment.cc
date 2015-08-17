// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "environment.h"
#include "helpers.h"

#include "connection.h"

#include <memory>
#include <iostream>

void OracleEnvironment_finalizer(void* isolate_callback_data,
                                Dart_WeakPersistentHandle handle,
                                void* peer) {
    //printf("in OracleEnvironment_finalizer\n");
    delete (std::shared_ptr<Environment> *)peer;
}

void OracleEnvironment_init(Dart_NativeArguments args) {
    Dart_EnterScope();

    try {
        auto env = new std::shared_ptr<Environment>(new Environment());

        Dart_Handle dh = Dart_This(args);

        Dart_NewWeakPersistentHandle(dh,
                                     env,
                                     sizeof(env),
                                     OracleEnvironment_finalizer);

        HandleError(Dart_SetPeer(dh, env)); // TODO: dont do handle error
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}

void OracleEnvironment_createConnection(Dart_NativeArguments args) {
    Dart_EnterScope();

    std::shared_ptr<Environment> *env;
    Dart_GetPeer(Dart_This(args), (void **)&env);

    std::string username = getDartArg<std::string>(args, 1);
    std::string password = getDartArg<std::string>(args, 2);
    std::string connStrg = getDartArg<std::string>(args, 3);

    try {
        auto conn = new std::shared_ptr<Connection>(new Connection(*env, username, password, connStrg));

        Dart_Handle dh = NewInstanceWithPeer("Connection", (void *)conn);
        Dart_NewWeakPersistentHandle(dh, conn, sizeof(conn), OracleConnection_finalizer);

        Dart_SetReturnValue(args, dh);
    } CATCH_SQL_EXCEPTION

    Dart_ExitScope();
}
