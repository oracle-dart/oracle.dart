// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "bfile.h"
#include "helpers.h"
#include "lob.h"
#include <occi.h>

namespace occi = oracle::occi;

void OracleClob_append(Dart_NativeArguments args){
    lob_append<occi::Clob>(args);
}

void OracleClob_copy(Dart_NativeArguments args){
    lob_copy<occi::Clob>(args);
}

void OracleClob_length(Dart_NativeArguments args){
    lob_length<occi::Clob>(args);
}

void OracleClob_trim(Dart_NativeArguments args){
    lob_trim<occi::Clob>(args);
}

//list<bytes> read(int amt, int offset)
void OracleClob_read(Dart_NativeArguments args){
    lob_read<occi::Clob>(args);
}

//int write(int amt, list<bytes> buf, int offset)
void OracleClob_write(Dart_NativeArguments args){
    lob_write<occi::Clob>(args);
}
