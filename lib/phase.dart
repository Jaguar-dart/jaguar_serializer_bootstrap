library jaguar.serializer.bootstrap.phase;

import 'dart:io';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

import 'package:jaguar_serializer/generator/hook/make_serializer/make_serializer.dart';

Phase bootstrapPhase(String projectName) {
    return new Phase()
        ..addAction(
            new SerializerBootstrapBuilder(projectName),
            new InputSet(projectName, ["jaguar/serializer.yaml"]));
}
