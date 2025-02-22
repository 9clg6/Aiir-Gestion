import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

/// [Request]
@CopyWith()
class Request with EquatableMixin {
  /// Name of the request
  final String? name;

  /// Destination of the request
  final String? destination;

  /// Description of the request
  final String? description;

  /// Date of the request
  final DateTime? date;

  /// Parameters of the request
  final Map<String, String>? parameters;

  /// Constructor
  /// @param name: Name of the request
  /// @param destination: Destination of the request
  /// @param description: Description of the request
  /// @param date: Date of the request
  Request({
    this.name,
    this.destination,
    this.description,
    this.date,
    this.parameters,
  });

  /// Empty request
  ///
  factory Request.initiale() => Request();

  @override
  List<Object?> get props => [
        name,
        destination,
        description,
        date,
        parameters,
      ];
}
