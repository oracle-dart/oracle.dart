# oracle: Oracle database access support for Dart
Provides Oracle database access support for Dart via an API that is similar to
OCCI.

## Installation

**Dependencies**

- GCC
- Oracle SDK (libs and header files)
- Environment variable `ORACLE_HOME` set to the root of your Oracle libraries


**Instructions**

1. Add `oracle` to your dependencies list in your `pubspec.yaml` file.

  ```yaml
  dependencies:
    oracle: any
  dev_dependencies:
    grinder: any
  ```

2. Run `pub get` to download Dart dependencies
3. Run `pub run grind` to build the binaries for your platform

If grind succeeds you should be good to go. If it fails you may need to check
your system dependencies or environment variables

## Features
Dart garbage collected OCCI wrappers for many commonly used classes. 

Support for:
- Basic types (strings, numbers, etc...)
- Date and Timestamps as Dart `DateTime` type
- BLOBs
- CLOBs
- BFiles

## License
Free as in freedom softwares.

LGPL v3. See COPYING and COPYING.LESSER.

## Usage

### High level convenience
```
todo?
```

### Low level OCCI wrapping
```dart
import 'package:oracle/oracle.dart' as oracle;

oracle.Environment env = new oracle.Environment();
oracle.Connection conn = env.createConnection("username", "password", "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.1.1)(PORT=1521))(CONNECT_DATA=(SID=XE)))"); 
oracle.Statement stmt = conn.createStatement("INSERT INTO test_table (test_int INT) VALUES (:bind)");
stmt.setInt(1, 12);
stmt.execute();
stmt = conn.createStatement("SELECT test_int from test_table");
oracle.ResultSet results = stmt.executeQuery();
results.next(1);
int i = results.getInt(1);
print(i) // 12
// garbage collection will cleanup
```

## API

Being developed.

## Development Instructions

```bash
# Set environment variables
$ export DART_SDK=/path/to/dart-sdk
$ export PATH=$PATH:$DART_SDK/bin
$ export ORACLE_HOME=/usr/lib/oracle/12.1/client64/lib

# Get dependencies and setup grinder
$ cd oracle.dart
$ pub get
$ pub global activate grinder

# To build
$ grind

# To unit test
$ export DB_USERNAME=username
$ export DB_PASSWORD=password
$ export DB_CONN_STR="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SID=XE)))"
$ grind test
```
