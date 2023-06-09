// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.72.1.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;

part 'bridge_definitions.freezed.dart';

abstract class Native {
  Future<List<Position>> layoutGraph(
      {required int numberOfNodes,
      required List<RustEdge> edges,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kLayoutGraphConstMeta;

  /// Adds two floating point numbers `a` and `b` and returns the result.
  ///
  /// # Parameters
  ///
  /// * `a` - The first number to add
  /// * `b` - The second number to add
  ///
  /// # Returns
  ///
  /// The sum of `a` and `b` as a floating point number
  Future<double> add({required double a, required double b, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kAddConstMeta;

  Future<Platform> platform({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kPlatformConstMeta;

  Future<bool> rustReleaseMode({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRustReleaseModeConstMeta;
}

@freezed
class Platform with _$Platform {
  const factory Platform.unknown() = Platform_Unknown;
  const factory Platform.android() = Platform_Android;
  const factory Platform.ios() = Platform_Ios;
  const factory Platform.windows() = Platform_Windows;
  const factory Platform.unix() = Platform_Unix;
  const factory Platform.macOs(
    String field0,
  ) = Platform_MacOS;
  const factory Platform.wasm() = Platform_Wasm;
}

class Position {
  final double x;
  final double y;
  final double z;

  const Position({
    required this.x,
    required this.y,
    required this.z,
  });
}

/// Represents an edge between two vertices in a graph.
///
/// # Fields
///
/// * `from_index` - The index of the vertex this edge originates from
/// * `to_index` - The index of the vertex this edge terminates at
class RustEdge {
  final int fromIndex;
  final int toIndex;

  const RustEdge({
    required this.fromIndex,
    required this.toIndex,
  });
}
