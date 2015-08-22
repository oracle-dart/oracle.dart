// Copyright 2015, Austin Cummings, Chris Lucas, Michael Loveridge
// This file is part of oracle.dart, and is released under LGPL v3.

#pragma once

#include <dart_api.h>


void OracleBlob_append(Dart_NativeArguments args);
void OracleBlob_write(Dart_NativeArguments args);
void OracleBlob_read(Dart_NativeArguments args);
void OracleBlob_copy(Dart_NativeArguments args);
void OracleBlob_length(Dart_NativeArguments args);
void OracleBlob_trim(Dart_NativeArguments args);
