// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#pragma once

#include <dart_api.h>

#include "environment.h"
#include "helpers.h"

struct Connection {
    std::shared_ptr<Environment> env;
    occi::Connection *conn;
    std::string username;
    std::string connstr;

    Connection(std::shared_ptr<Environment> env,
               std::string username,
               std::string password,
               std::string connStr) : env(env), username{username}, connstr{connStr} {
        conn = env.get()->env->createConnection(username, password, connStr);
    }

    ~Connection() {
        //printf("in ~Connection\n");
        env.get()->env->terminateConnection(conn);
        //printf("Environment use count %ld\n", env.use_count());
    }
};

void OracleConnection_finalizer(void* isolate_callback_data,
                                Dart_WeakPersistentHandle handle,
                                void* peer);
void OracleConnection_init(Dart_NativeArguments arguments);
void OracleConnection_commit(Dart_NativeArguments arguments);
void OracleConnection_createStatement(Dart_NativeArguments arguments);
void OracleConnection_rollback(Dart_NativeArguments arguments);
void OracleConnection_getUsername(Dart_NativeArguments arguments);
void OracleConnection_getConnectionString(Dart_NativeArguments arguments);
