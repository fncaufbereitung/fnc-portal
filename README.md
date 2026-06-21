# FNC Portal

Independent Flutter scheduling portal for FNC Autoaufbereitung.

The current version starts with a local role selection for `FNC Admin` or
`Autohaus`. It has no login, registration, account approval, Firebase
Authentication, or required backend configuration.

## Features

- Start screen with FNC Admin and Autohaus roles
- Admin can view all appointments and manage their status
- Autohaus can create requests and see only requests from its current session
- Autohaus companies are stored persistently in Firestore collection
  `autohaeuser`
- Existing Autohaus companies can be selected from a saved list
- Duplicate company names are prevented through normalized document IDs
- Both portals can return to role selection
- Create, view, filter, update and delete appointments in admin mode
- Local in-memory appointment storage with demonstration data
- Status workflow:
  `Angefragt`, `Bestätigt`, `In Arbeit`, `Fertig`, `Abgeholt`, `Abgerechnet`
- Responsive premium German automotive interface
- Android, iOS, Web and Windows Flutter targets
- Firebase Hosting configuration for the compiled PWA

Appointments still reset when the application restarts. Autohaus company names
are persistent in Firestore with the fields `name`, `createdAt` and
`lastUsedAt`.

Deploy the included Firestore rules before using the no-login prototype:

```bash
firebase deploy --only firestore:rules
```

## Development

```bash
flutter pub get
flutter run -d chrome
```

## Production build

```bash
flutter build web --release
firebase deploy --only hosting
```
