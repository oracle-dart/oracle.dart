import 'dart:io';
import 'package:grinder/grinder.dart';

main(args) => grind(args);

final cFiles = [
  'occi_extension',
  'helpers',
  'connection',
  'resultset',
  'statement',
  'bfile',
  'environment',
  'blob',
  'clob',
  'metadata',
];

getCompiler() {
  var compilerList = ['clang', 'gcc'];

  for (var c in compilerList) {
    if (Process.runSync('which', [c]).exitCode == 0) {
      return c;
    }
  }
}

@DefaultTask()
build() {
  final oracleHome = Platform.environment['ORACLE_HOME'];
  if (oracleHome == null) {
    throw new Exception('Environment variable ORACLE_HOME must be set');
  }
  final oracleIncludes = oracleHome.replaceFirst('lib', 'include').replaceFirst('lib', '');

  print('ORACLE_HOME=$oracleHome');
  print('ORACLE INCLUDES=$oracleIncludes');

  var args = cFiles.map((x) => 'lib/src/$x.cc').toList();
  args.addAll(['-std=c++0x', '-Wall', '-fPIC', '-rdynamic','-shared', '-I${sdkDir.path}/include', '-I$oracleIncludes', '-Ilib/src/', '-DDART_SHARED_LIB', '-L$oracleHome', '-Wl,-R$oracleHome', '-olib/src/libocci_extension.so', '-locci', '-lclntsh']);

  run(getCompiler(), arguments: args);
}

@Task()
clean() {
  delete(getFile('lib/src/libocci_extension.so'));
  defaultClean();
}

@Task()
@Depends(build)
test() {
  new PubApp.local('test').run([]);
}
