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

@DefaultTask()
build() {
  final oracleHome = Platform.environment['ORACLE_HOME'];
  final oracleIncludes = oracleHome.replaceFirst('lib', 'include').replaceFirst('lib', '');

  print('ORACLE_HOME=$oracleHome');
  print('ORACLE INCLUDES=$oracleIncludes');

  var gccArgs = cFiles.map((x) => 'lib/src/$x.cc').toList();
  gccArgs.addAll(['-std=c++0x', '-Wall', '-fPIC', '-rdynamic','-shared', '-I${sdkDir.path}/include', '-I$oracleIncludes', '-Ilib/src/', '-DDART_SHARED_LIB', '-L$oracleHome', '-Wl,-R$oracleHome', '-olib/src/libocci_extension.so']);
  gccArgs.addAll(['-locci', '-lclntsh']);

  print(gccArgs);
  run('gcc', arguments: gccArgs);
}

@Task()
clean() {
  for (var f in cFiles) {
    delete(getFile('lib/src/$f.o'));
  }

  delete(getFile('lib/src/libocci_extension.so'));
  delete(getFile('occi_extension.o'));
  defaultClean();
}

@Task()
@Depends(build)
test() {
  new PubApp.local('test').run([]);
}
