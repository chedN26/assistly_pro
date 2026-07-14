# Firebase Setup — Assistly Pro

This app ships with two repository implementations (Mock and Firebase),
switched by a single flag. Firebase mode requires a real Firebase
project, which this development environment does not have access to —
so this document walks through the steps to connect one yourself, plus
a checklist to verify everything works once you do.

## 1. Prerequisites

- A Google account and a [Firebase project](https://console.firebase.google.com/)
  (create a new one, or use an existing one).
- The Firebase CLI and FlutterFire CLI:
  ```bash
  npm install -g firebase-tools
  firebase login
  dart pub global activate flutterfire_cli
  ```

## 2. Enable Firestore and Authentication

In the Firebase Console, for your project:

1. **Build > Firestore Database > Create database** — start in production
   mode (the security rules below cover access control).
2. **Build > Authentication > Get started > Sign-in method > Email/Password**
   — enable it.
3. **Build > Authentication > Users > Add user** — create the manager
   account you'll log in with (e.g. `manager@yourcompany.com` / a
   password). This replaces the old hardcoded `admin` / `admin123` demo
   credentials — the Login page's "Username" field now expects this
   email address.

## 3. Generate `lib/firebase_options.dart`

From the project root:

```bash
flutterfire configure
```

Select your Firebase project and the platforms this app targets (Web,
Android). This **overwrites** the placeholder `lib/firebase_options.dart`
with your project's real values.

## 4. Deploy the Firestore security rules

```bash
firebase deploy --only firestore:rules
```

(Or paste the contents of `firestore.rules` into Firestore Database >
Rules in the console.)

## 5. Run the app

`kUseFirebase` in `lib/core/constants/app_config.dart` is already set to
`true`. Just run:

```bash
flutter pub get
flutter run -d chrome   # or your target device
```

The `employees`, `clients`, `employee_hours`, and `client_payments`
collections will be created automatically as you add data through the
UI. The `settings/default` document self-seeds on first read with the
same defaults the Mock data used (Tools 10%, Misc 3%, Owner Share 5%).

## 6. Switching back to Mock data

For local development or a demo without Firebase configured, set:

```dart
// lib/core/constants/app_config.dart
const bool kUseFirebase = false;
```

No other code changes are needed — this is the entire point of the
repository pattern used throughout the app.

## 7. Manual verification checklist

Once connected, walk through each of these and confirm the change is
visible in the Firebase Console (Firestore Database tab):

- [ ] **Login** with your Firebase Auth email/password → lands on Dashboard.
- [ ] **Add Employee** → new document appears in `employees`.
- [ ] **Edit Employee** → document fields update in place.
- [ ] **Deactivate Employee** → `status` field changes to `"Inactive"`.
- [ ] **Add Hours** (Employee Details) → new document in `employee_hours`
      with the correct `employeeId`.
- [ ] **Add Client** → new document in `clients`.
- [ ] **Edit / Deactivate Client** → same as Employee, in `clients`.
- [ ] **Add Payment** (Client Details) → new document in `client_payments`.
- [ ] **Dashboard** cards and charts reflect the data you just entered.
- [ ] **Settings** → change a percentage, Save → Dashboard numbers update
      immediately (no navigation required).
- [ ] **Logout** → returns to Login; navigating back to a protected route
      (e.g. typing `/dashboard` in the URL) redirects to Login again.

## Known simplification

`AuthProvider`'s session is still purely in-memory for the running app
instance (unchanged from Phase 2) — it does not listen to Firebase's
`authStateChanges()` stream, so a full page reload while logged in will
return you to the Login page even though Firebase itself still
considers you signed in. Wiring that up is a reasonable future
enhancement but was out of this phase's scope ("Preserve Provider
architecture… Keep all UI unchanged").
