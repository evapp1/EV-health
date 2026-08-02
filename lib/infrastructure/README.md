# Infrastructure boundary

Concrete adapters implement domain and application ports here. Infrastructure
owns platform plugins, storage mapping, protocol handling, vehicle-profile
loading, battery-engine implementations, report rendering, and diagnostics. It
must not own product navigation or widget state.
