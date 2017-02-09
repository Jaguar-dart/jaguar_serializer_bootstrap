library jaguar.serializer.bootstrap.phase;

import 'package:build/build.dart';
import 'package:jaguar_serializer/generator/config/config.dart';
import 'builder.dart';

Phase bootstrapPhase(String projectName, String configFile) {
  return new Phase()
    ..addAction(new SerializerBootstrapBuilder(projectName),
        new InputSet(projectName, [configFile]));
}

PhaseGroup phaseGroup({String configFileName: jaguarSerializerConfigFile}) {
  JaguarSerializerConfig config =
      new JaguarSerializerConfig(configFileName: configFileName);
  if (config.pubspec.projectName == null) {
    throw "Could not find the project name";
  }

  if (config.serializers == null) {
    throw "You need to provide one or more api file";
  }

  PhaseGroup group = new PhaseGroup();
  group.addPhase(
      bootstrapPhase(config.pubspec.projectName, jaguarSerializerConfigFile));
  return group;
}
