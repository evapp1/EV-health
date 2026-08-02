# Domain boundary

Immutable entities, value objects, repository ports, and pure policy contracts
belong here. Domain may depend on Dart and core primitives only; it must not
import application, presentation, data, or infrastructure implementations.
