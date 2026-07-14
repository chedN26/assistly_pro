# repositories/

Abstract repository interfaces (`auth_repository.dart`, `employee_repository.dart`,
`client_repository.dart`, `settings_repository.dart`) that Providers depend on.
Pages never import from `repositories/mock/` or `repositories/firebase/` directly.

Populated in: **Data Layer phase** (interfaces + mock implementations),
**Firebase phase** (Firebase implementations).
