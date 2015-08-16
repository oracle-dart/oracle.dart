import 'dart:io';
import 'package:grinder/grinder.dart';

main(args) => grind(args);

@DefaultTask()
build() {
  run('make');
}

@Task()
clean() {
  run('make', arguments: ['clean']);
  defaultClean();
}

@Task()
@Depends(build)
test() {
  new PubApp.local('test').run([]);
}
