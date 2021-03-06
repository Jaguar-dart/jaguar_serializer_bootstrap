library jaguar_serializer_bootstrap.builder;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';

import 'package:jaguar_serializer/serializer.dart';
import 'package:jaguar_serializer/generator/config/config.dart';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';
import 'package:dart_style/src/dart_formatter.dart';

import 'package:source_gen/src/utils.dart';
import 'package:source_gen/src/annotation.dart';

class SerializerBootstrapBuilder extends Builder {
  final String projectName;

  SerializerBootstrapBuilder(this.projectName);

  @override
  Future build(BuildStep buildStep) async {
    AssetId id = buildStep.input.id;
    Map yaml = loadYaml(await buildStep.readAsString(id));
    List<String> serializersFile = yaml[JaguarSerializerConfig.serializersKey];

    List<String> importsAll = [];
    List<String> constructorsAll = [];
    int importAsAll = 1;

    List<String> importsLib = [];
    List<String> constructorsLib = [];
    int importAsLib = 1;

    for (String path in serializersFile) {
      AssetId id = new AssetId(projectName, path);
      Resolver resolver = await buildStep.resolve(id);
      LibraryElement library = resolver.getLibrary(id);
      bool importAll = false;
      bool importLib = false;
      for (Element element in getElementsFromLibraryElement(library)) {
        if (element.metadata.any((md) => matchAnnotation(GenSerializer, md))) {
          if (id.path.startsWith("lib/")) {
            if (!importLib) {
              importsLib.add(
                  "import '${id.path.replaceFirst("lib/", "")}' as _$importAsLib;");
              importLib = true;
            }
            constructorsLib.add(
                "JaguarSerializer.addSerializer(new _$importAsLib.${element.displayName}());");
          } else {
            if (!importAll) {
              importsAll.add("import '${id.path}' as _$importAsAll;");
              importAll = true;
            }
            constructorsAll.add(
                "JaguarSerializer.addSerializer(new _$importAsAll.${element.displayName}());");
          }
        }
      }
      if (importAll) {
        importAsAll++;
      }
      if (importLib) {
        importAsLib++;
      }
      resolver.release();
    }

    if (constructorsLib.isNotEmpty) {
      _bootstrapLib(buildStep, importsLib, constructorsLib);
    }
    if (constructorsAll.isNotEmpty) {
      _bootstrapAll(
          buildStep, importsAll, constructorsAll, constructorsLib.isNotEmpty);
    }
  }

  void _bootstrapAll(BuildStep buildStep, List<String> imports,
      List<String> constructors, bool withLib) {
    StringBuffer buffer = new StringBuffer();
    buffer.writeln(_topHeader);
    buffer.writeln("library $projectName.jaguar.serializer.bootstrap;");

    buffer.writeln("import 'package:jaguar_serializer/serializer.dart';");
    if (withLib) {
      buffer.writeln(
          "import 'package:$projectName/jaguar_serializer.dart' as _lib;");
    }

    imports.forEach((String i) {
      buffer.writeln(i);
    });

    buffer.writeln("void bootstrap() {");
    if (withLib) {
      buffer.writeln("_lib.bootstrap();");
    }

    constructors.forEach((String c) {
      buffer.writeln(c);
    });
    buffer.writeln("}");

    buffer.writeln(_headerLine);
    DartFormatter format = new DartFormatter();

    buildStep.writeAsString(new Asset(
        new AssetId(projectName, "serializer.dart"),
        format.format(buffer.toString())));
  }

  void _bootstrapLib(
      BuildStep buildStep, List<String> imports, List<String> constructors) {
    StringBuffer buffer = new StringBuffer();
    buffer.writeln(_topHeader);

    buffer.writeln("library $projectName.jaguar.serializer.bootstrap.lib;");
    buffer.writeln("import 'package:jaguar_serializer/serializer.dart';");

    imports.forEach((String i) {
      buffer.writeln(i);
    });

    buffer.writeln("void bootstrap() {");
    constructors.forEach((String c) {
      buffer.writeln(c);
    });
    buffer.writeln("}");

    buffer.writeln(_headerLine);
    DartFormatter format = new DartFormatter();

    buildStep.writeAsString(new Asset(
        new AssetId(projectName, "./lib/jaguar_serializer.dart"),
        format.format(buffer.toString())));
  }

  @override
  List<AssetId> declareOutputs(AssetId _) {
    print(_);
    return [
      new AssetId(projectName, "serializer.dart"),
      new AssetId(projectName, "./lib/jaguar_serializer.dart")
    ];
  }

  final _topHeader = '''// GENERATED CODE - DO NOT MODIFY BY HAND

''';

  final _headerLine = '// '.padRight(77, '*');
}
