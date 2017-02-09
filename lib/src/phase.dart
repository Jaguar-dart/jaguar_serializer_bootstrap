library jaguar.serializer.bootstrap.phase;

import 'package:build/build.dart';
import 'package:jaguar_serializer/generator/config/config.dart';
import 'builder.dart';

Phase bootstrapPhase(String projectName, String configFile) {
  return new Phase()
    ..addAction(new SerializerBootstrapBuilder(projectName),
        new InputSet(projectName, [configFile]));
}

PhaseGroup phaseGroup() {
  PhaseGroup group = new PhaseGroup();

  if (serializer_config.projectName == null) {
    throw "Could not find the project name";
  }

  if (serializer_config.annotations == null) {
    throw "You need to provide one or more api file";
  }

  group.addPhase(bootstrapPhase(serializer_config.projectName, SerializerConfig.config_file));
  return group;
}
