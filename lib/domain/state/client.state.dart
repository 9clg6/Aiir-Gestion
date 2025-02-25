import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:squirrel/domain/entities/client.entity.dart';

part 'client.state.g.dart';

/// [ClientState]
@CopyWith()
class ClientState with EquatableMixin {
  /// Clients
  final List<Client> clients;

  /// Constructor
  /// @param clients: List<Client>
  ///
  ClientState({
    required this.clients,
  });

  /// Initial
  ///
  factory ClientState.initial() {
    return ClientState(
      clients: [],
    );
  }

  /// Props
  ///
  @override
  List<Object?> get props => [
        clients,
      ];
}
