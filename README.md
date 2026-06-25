# PrisVagt Danmark v4.0

Flutter Android/PWA-version med ny brændstof-fane.

## Nyt i v4.0

- Ny **Brændstof**-fane
- Benzin 95, Diesel og Benzin 100
- Demo-stationer med priser, afstand og opdateringstid
- Billigste station lige nu
- Favoritstationer
- Klargjort til live brændstof-API
- Android-permissions til internet og lokation
- Rettet Gradle wrapper URL til `services.gradle.org`
- Rettet indkøbsliste-layout, så teksten vises vandret
- Beholder prisvagter, tilbud, indkøbsliste, budget, historik, statistik, scanner og profil

## Test i Android Studio / PowerShell

Kør fra projektmappen:

```bash
flutter clean
flutter pub get
flutter run
```

Hvis Android-licenser mangler:

```bash
flutter doctor --android-licenses
```

## Live brændstofpriser

`lib/services/fuel_price_service.dart` bruger demo-data nu, så appen kan testes med det samme.

Når du får API-adgang, skal live-kaldet kobles på her:

```dart
FuelPriceService.fetchNearbyStations()
```

Næste naturlige trin er v4.1:

- Rigtig API-adapter til brændstofdata
- GPS-position fra telefonen
- Kort/navigation til tankstation
- Prisalarm for benzin/diesel
- Gem favoritstationer permanent
