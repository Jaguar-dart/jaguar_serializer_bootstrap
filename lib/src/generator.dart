import 'package:jaguar_serializer_bootstrap/jaguar_serializer_bootstrap.dart';
import 'package:build/build.dart';

void _launchWatch() {
  watch(phaseGroup(), deleteFilesByDefault: true);
}

start(List<String> args) {
  if (args.length > 0) {
    if (args[0] == 'watch') {
      return _launchWatch();
    } else if (args[0] == 'build') {
      return build(phaseGroup(), deleteFilesByDefault: true);
    }
  }
  print('''Usage:
  \tbuild
  \twatch''');
}
