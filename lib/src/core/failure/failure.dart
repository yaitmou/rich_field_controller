// Copyright (c) 2024 Younss Ait Mou. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a failure in the application.
///
/// This is an abstract base class for all types of failures that can occur
/// in the application. It extends [Equatable] to allow for easy comparison
/// of failure objects.

/// Represents a failure in the application.
///
/// This is an abstract base class for all types of failures that can occur
/// in the application.
@immutable
class Failure extends Equatable {
  /// Creates a new [Failure] instance with the given [message].
  const Failure(this.message);

  /// A descriptive message explaining the failure.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Represents a failure that occurred due to a server-side issue.
class ServerFailure extends Failure {
  /// Creates a new [ServerFailure] instance with the given [message].
  const ServerFailure(super.message);
}

/// Represents a failure that occurred due to a caching issue.
class CacheFailure extends Failure {
  /// Creates a new [CacheFailure] instance with the given [message].
  const CacheFailure(super.message);
}

/// Represents a failure that occurred due to network connectivity issues.
class NetworkFailure extends Failure {
  /// Creates a new [NetworkFailure] instance with the given [message].
  const NetworkFailure(super.message);
}
