// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#pragma once

#include <dart_api.h>
#include <occi.h>

namespace occi = oracle::occi;

struct Environment {
    occi::Environment *env;

    Environment() {
        env = occi::Environment::createEnvironment();
    }

    ~Environment() {
        //printf("in ~Environment\n");
        occi::Environment::terminateEnvironment(env);
    }
};

void OracleEnvironment_init(Dart_NativeArguments args);
void OracleEnvironment_createConnection(Dart_NativeArguments args);
