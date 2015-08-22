// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#include "bfile.h"
#include "helpers.h"
#include "lob.h"
#include <occi.h>

namespace occi = oracle::occi;

void OracleBlob_append(Dart_NativeArguments args){
    lob_append<occi::Blob>(args);
}

void OracleBlob_copy(Dart_NativeArguments args){
    lob_copy<occi::Blob>(args);
}

void OracleBlob_length(Dart_NativeArguments args){
    lob_length<occi::Blob>(args);
}

void OracleBlob_trim(Dart_NativeArguments args){
    lob_trim<occi::Blob>(args);
}

//list<bytes> read(int amt, int offset)
void OracleBlob_read(Dart_NativeArguments args){
    lob_read<occi::Blob>(args);
}

//int write(int amt, list<bytes> buf, int offset)
void OracleBlob_write(Dart_NativeArguments args){
    lob_write<occi::Blob>(args);
}
