# providers/

`AuthProvider`, `DashboardProvider`, `EmployeeProvider`, `ClientProvider`,
`SettingsProvider` — ChangeNotifier classes that mediate between pages and
repositories. Pages must never call repositories directly.

Populated in: **Authentication phase** (AuthProvider) and **Data Layer
phase** (remaining providers).
