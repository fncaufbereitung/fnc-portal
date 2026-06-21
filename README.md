# FNC Portal

Independent Flutter scheduling portal for FNC Autoaufbereitung.

The current version starts with a local role selection for `FNC Admin` or
`Autohaus`. It has no login, registration, account approval, Firebase
Authentication, or required backend configuration.

## Features

- Start screen with FNC Admin and Autohaus roles
- Admin can view all appointments, manage their status and use a weekly view
- Autohaus can create requests and see only requests from its current session
- Autohaus companies are stored persistently in Firestore collection
  `autohaeuser`
- Existing Autohaus companies can be selected from a saved list
- Duplicate company names are prevented through normalized document IDs
- Both portals can return to role selection
- Create, view, filter, update and delete Firestore appointments
- Wunschdatum and Wunschzeit with chronological sorting
- Separate Terminart and Leistung fields
- Admin metrics for today, this week and workflow status
- “Heutige Fahrzeuge” overview
- Status workflow:
  `Angefragt`, `Bestätigt`, `In Arbeit`, `Fertig`, `Abgeholt`, `Abgerechnet`
- Responsive premium German automotive interface
- Android, iOS, Web and Windows Flutter targets
- Firebase Hosting configuration for the compiled PWA

Appointments are stored in Firestore collection `appointments`. Autohaus
company names are persistent in `autohaeuser` with the fields `name`,
`createdAt` and `lastUsedAt`.

Deploy the included Firestore rules before using the no-login prototype:

```bash
firebase deploy --only firestore
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
