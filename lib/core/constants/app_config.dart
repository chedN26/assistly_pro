/// Controls which repository implementations the app uses.
///
/// - `true`  → Firebase-backed repositories (requires a configured
///   Firebase project — see FIREBASE_SETUP.md at the project root).
/// - `false` → in-memory Mock repositories (no setup required; useful
///   for local development, demos, or grading without a configured
///   Firebase project).
///
/// This single flag is the entire "swap Mock for Firebase" step the
/// repository-pattern architecture was designed for since Phase 1 —
/// no Provider or UI changes are ever required to switch it.
const bool kUseFirebase = true;
