# AGENTS.md — MyCRM Projektübersicht für KI-Assistenten

> Diese Datei wird fortlaufend gepflegt. Wenn du Änderungen vornimmst, die das Verhalten, die Architektur oder die Konventionen des Projekts betreffen, aktualisiere die relevanten Abschnitte.

---

## Stack

| Schicht | Technologie |
|---|---|
| Framework | Flutter (Dart) |
| UI-Bibliothek | shadcn_ui (`ShadCard`, `ShadTabs`, `ShadSelect`, `ShadButton`, `ShadInputFormField`, `ShadBreadcrumb`, `ShadProgress`) |
| Icons | `LucideIcons` (aus shadcn_ui) |
| Backend | PocketBase (self-hosted) |
| PocketBase SDK | `pocketbase: ^0.22.0` mit `AsyncAuthStore` |
| Auth-Persistenz | `flutter_secure_storage` (kein `encryptedSharedPreferences`) |
| Navigation | `go_router` mit `ShellRoute` |
| Theme-Persistenz | `shared_preferences` |
| Env-Variablen | `flutter_dotenv` — Datei `.env` im Root, in `pubspec.yaml` als Asset registriert |
| Mail-Links | `url_launcher` |

---

## Authentifizierung

- Einziger Nutzer ist ein PocketBase-**Superuser** (`_superusers`-Collection).
- `AuthService` ist ein Singleton (`AuthService.instance`) in `lib/services/auth_service.dart`.
- Login-Ablauf: `ConnectingPage` → prüft Token → falls kein Token: `tryEnvLogin()` mit `.env`-Werten (`EMAIL`, `PASSWORD`) → sonst `LoginPage`.
- Nach explizitem Logout wird das `.env`-Auto-Login unterdrückt, bis wieder ein manueller Login erfolgt.
- `.env`-Keys: `BASE_URL`, `EMAIL`, `PASSWORD`.

---

## Projektstruktur

```
lib/
  main.dart                   # MyCrmApp, Theme-Toggle, AnnotatedRegion für System-Nav-Bar
  router.dart                 # GoRouter, ShellRoute, alle Routen
  services/
    auth_service.dart
  navigation/
    navigation_tree.dart      # NavigationItem-Baum, BreadcrumbSegment, breadcrumbsForRoute()
  components/
    app_drawer/               # Seitenmenü mit NavigationTree
    app_toast/                # AppToast.showSuccess / showError
  pages/
    connecting_page.dart
    login/
    home/                     # Dashboard: Aufgaben-Liste (todo-Collection)
    settings/
    search/                   # Suche auf statischen Platzhalterdaten
    customers/                # Liste + Detail (Tabs: Allgemein / Akte)
    inquiries/                # Liste + Read-only Detail
    invoices/                 # Liste mit Suche, direction wird im Frontend ignoriert
    contracts/                # Liste + Read-only Detail
  data/
    models/                   # customer.dart, inquiry.dart, invoice.dart, contract.dart, todo_item.dart
    services/                 # customers_service.dart, inquiries_service.dart, invoices_service.dart, contracts_service.dart, todos_service.dart
```

---

## Navigation & Routing

- Neue Seiten brauchen drei Einträge:
  1. **Route** in `router.dart` (innerhalb des `ShellRoute`)
  2. **NavigationItem** in `navigation_tree.dart` → `navigationTree`
  3. **Breadcrumb-Regel** in `breadcrumbsForRoute()` in `navigation_tree.dart` (nur nötig bei Unterrouten wie `/customers/:id`)

- Nav-Reihenfolge: Suche (`/search`) → Dashboard (`/home`) → Verträge (`/contracts`) → Kontakte → Anfragen → Rechnungen

---

## UI-Konventionen

- **Theme**: `ShadNeutralColorScheme` (nicht Slate — zu bläulich).
- **Leer-Zustände**: Zentriertes Icon + Text, kein Button außer auf Fehlerseiten.
- **Fehler-Zustände**: `Text('Fehler beim Laden')` + Fehlermeldung + `ShadButton.outline` mit `LucideIcons.refreshCw`.
- **Listen**: `ListView.separated` mit `ShadCard`-Items, `padding: EdgeInsets.all(16)`, `SizedBox(height: 8)` als Separator.
- **Pull-to-Refresh**: `RefreshIndicator` um die gesamte Liste.
- **Formulare**: `ShadInputFormField` ohne Card-Wrapper, PLZ-Feld 160px breit, PLZ+Ort immer nebeneinander in einer `Row`.
- **isDirty-Pattern**: TextEditingController-Listener vergleichen Texte gegen gespeicherte Ursprungswerte; Save-Button ist `null` (disabled) solange nicht dirty.
- **Save-Button**: Immer als `_SaveBar` am unteren Rand, ausgeblendet wenn ein Tab aktiv ist, der kein Editieren erlaubt (z.B. Akte-Tab).
- **E-Mail-Links**: `GestureDetector` → `launchUrl(Uri.parse('mailto:...'))` via `url_launcher`.

---

## PocketBase Collections (bekannt)

| Collection | Felder | Besonderheiten |
|---|---|---|
| `_superusers` | — | Einzige Auth-Collection |
| `customers` | `name`, `street`, `zip` (number), `town` | PATCH via `CustomersService.update()` |
| `inquiries` | `name`, `subject`, `email`, `message`, `created`, `customer` (relation) | Read-only im UI |
| `invoices` | `title`, `total` (number), `direction` (enum: `incoming`/`outbounding`), `created`, `customer` (relation) | Frontend wertet `direction` nicht mehr aus; Liste ist ungefiltert mit Suche |
| `contracts` | `keyword` (text), `is_active` (bool), `amount` (number), `customer` (relation) | Read-only im UI; in Akte-Tab sichtbar |
| `todo` | `keyword` (text), `is_finished` (bool) | Nur im Dashboard; kein Hinzufügen im Frontend, nur Abhaken |

---

## Bekannte Stolperfallen

- `encryptedSharedPreferences: true` crasht auf manchen Android-Geräten → **nicht verwenden**.
- `LucideIcons.mailQuestion` existiert nicht → `LucideIcons.mail` verwenden.
- `ShadTabs` nutzt `content:` im `ShadTab`, nicht ein `children:`-Map auf `ShadTabs`.
- PocketBase-Enum für Ausgangsrechnungen heißt `outbounding` (nicht `outgoing`).
- `import 'package:flutter/services.dart'` für `SystemUiOverlayStyle` → nur mit `show SystemUiOverlayStyle` importieren, sonst Redundanz-Warning.
