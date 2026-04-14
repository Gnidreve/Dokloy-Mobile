# AGENTS.md — Dokploy Mobile

> **PFLICHTLEKTÜRE & PFLEGEVERPFLICHTUNG**
> Diese Datei ist der verbindliche Einstiegspunkt für jeden Agent, der an diesem Projekt arbeitet.
> Sie muss nach jeder signifikanten Änderung (neue Features, Architekturentscheidungen, Patterns, bekannte Probleme) aktualisiert werden.
> Kein Agent darf Arbeit beginnen ohne diese Datei gelesen zu haben.

---

## Was ist dieses Projekt?

Flutter-App als mobiler Client für [Dokploy](https://dokploy.com) — eine selbst-gehostete Deployment-Plattform (vergleichbar mit Vercel/Heroku).

Ziel: 1:1 Port der mobilen Webversion (visuell + funktional), strukturell angelehnt an Svelte-Projekte (pages-basiert).

---

## Technologie-Stack

| Was | Womit |
|---|---|
| Framework | Flutter (Dart) |
| UI-Komponenten | `shadcn_ui ^0.53.5` — **ausschließlich** ShadCN-Komponenten verwenden |
| Icons | `LucideIcons.*` aus `shadcn_ui` — **kein** `Icons.*` (Material) |
| Routing | `go_router ^14.0.0` |
| SVG | `flutter_svg` (via `shadcn_ui` re-exportiert, nur in `router.dart` direkt importiert) |
| HTTP | `http ^1.2.2` |
| Env-Konfiguration | `flutter_dotenv ^5.1.0` — Datei `.env` im Root |
| Lokale Preferences | `shared_preferences ^2.5.3` — Theme-Persistenz |
| Theme | `ShadSlateColorScheme` (light + dark) |

---

## Projektstruktur

```
lib/
├── api/
│   ├── index.dart             # EINZIGER öffentlicher SDK-Einstiegspunkt (DokployApi)
│   ├── _client.dart           # Shared API-Client
│   ├── models.dart            # Uebergreifender Barrel + shared Models
│   ├── deployment/            # deployment.all + deployment.queueList
│   ├── project/               # project.all
│   ├── user/                  # user.*
│   └── user_store.dart        # Static holder für eingeloggten User
├── pages/
│   ├── connecting_page.dart       # Splash + Init-Call (außerhalb ShellRoute)
│   ├── connection_error_page.dart # Error + Retry (außerhalb ShellRoute)
├── components/
│   ├── app_drawer/
│   │   └── app_drawer.dart    # Seitennavigation + Account-Popover + Theme-Toggle
│   ├── button/button.dart     # Re-export: ShadButton
│   ├── card/card.dart         # Re-export: ShadCard
│   ├── badge/badge.dart       # Re-export: ShadBadge
│   ├── input/input.dart       # Re-export: ShadInput
│   ├── dropdown/dropdown.dart # Re-export: ShadSelect, ShadOption
│   └── modal/modal.dart       # Re-export: ShadDialog, ShadSheet
├── navigation/
│   └── navigation_tree.dart   # Navigationsdaten + breadcrumbsForRoute()
├── pages/
│   ├── projects/
│   │   ├── projects_page.dart         # Projektliste mit Filter/Sort + API
│   │   └── project_detail_page.dart   # Projektdetail, Environment, Service, Tabs
│   ├── services/general/              # Typ-spezifische General-Seiten fuer Services
│   ├── deployments/deployments_page.dart # Echte Deployment- und Queue-Tabellen via API
│   ├── schedules/schedules_page.dart
│   ├── remote_servers/remote_servers_page.dart
│   ├── monitoring/            # Platzhalter
│   ├── docker/                # Platzhalter
│   ├── swarm/                 # Platzhalter
│   ├── requests/              # Platzhalter
│   ├── web_server/            # Statisches Domain-Formular ohne API-Anbindung
│   ├── ssh_keys/              # Statischer Empty State + schließbares Modal ohne Inputs
│   ├── ai/                    # Leere Unterseite
│   ├── git/                   # Leere Unterseite
│   ├── registry/              # Statischer Empty State im Dokploy-Stil
│   ├── s3_destinations/       # Statischer Empty State im Dokploy-Stil
│   ├── certificates/          # Statischer Empty State im Dokploy-Stil
│   ├── cluster/               # Leere Unterseite
│   ├── notifications/         # Statischer Empty State im Dokploy-Stil
│   └── profile/               # Platzhalter
├── main.dart                  # ShadApp.router, ThemeMode aus System oder Preferences, dotenv.load
├── router.dart                # createRouter(), ShellRoute, Breadcrumbs, alle Routen
└── theme.dart                 # Zentrale Theme-Definitionen
```

---

## Konfiguration (.env)

```env
BASE_URL=http://dein-server:3000
API_KEY=dein-api-key
```

Die `.env` Datei liegt im Root und ist als Flutter-Asset registriert. Sie wird in `main()` via `dotenv.load()` geladen — **vor** `runApp()`.

---

## Routing

Router wird via `createRouter({themeMode, onToggleTheme})` instanziiert (keine globale Variable mehr).

### Routen-Struktur

```
/projects                                                → ProjectsPage
/projects/:projectId                                     → ProjectDetailPage (redirect → default Environment)
/projects/:projectId/environments/:environmentId         → EnvironmentDetailPage
/projects/:projectId/environments/:eid/services/:sid     → ServiceDetailPage (Tab: general)
/projects/:projectId/environments/:eid/services/:sid/:tab → ServiceDetailPage (Tab: tab)
/deployments
/monitoring
/schedules
/traefik
/docker
/swarm
/requests
/web-server
/ssh-keys
/ai
/git
/registry
/s3-destinations
/certificates
/cluster
/notifications
/profile
/remote-servers
```

Alle Routen sind in einem `ShellRoute` mit `_ShellWrapper` (AppBar + Drawer).

### AppBar

- Leading: `LucideIcons.panelLeft` → öffnet Drawer
- Title: `_Breadcrumbs` — statisch für Top-Level-Routen, `_ProjectBreadcrumbs` (mit API-Call) für `/projects/*`
- `_EnvironmentDropdown` in Breadcrumbs wechselt zwischen Environments eines Projekts

---

## Navigation / Drawer

**Datei:** [lib/navigation/navigation_tree.dart](lib/navigation/navigation_tree.dart)

Die Navigationsdaten sind deklarativ als `const navigationTree` definiert:
- `NavigationGroup` → Gruppen-Label (z.B. "Delivery", "Platform")
- `NavigationSection` → optionaler Unterabschnitt
- `NavigationItem` → Label, Route, LucideIcon

Der `AppDrawer` iteriert über `navigationTree` und rendert `_NavItem` (ShadButton.ghost) mit Active-Highlighting via `colorScheme.accent`.

### Account-Popover (Footer)

Tippen auf den Footer öffnet via `ShadPopoverController` ein Menü nach oben mit:
- Account-Info (Name, Mail)
- Theme-Toggle (moon/sun)
- Schnelllinks
- Log out

`Profile` ist nicht mehr als normaler Sidebar-Eintrag sichtbar und wird nur noch ueber das User-Menue erreicht.

### Theme Toggle

- `main.dart` hält den Theme-State lokal
- Beim ersten Start wird das Theme aus `platformBrightness` des Systems abgeleitet
- Wenn bereits eine lokale Preference gespeichert ist, überschreibt diese den Systemwert beim App-Start
- Theme-Wechsel werden in `SharedPreferences` persistiert
- `main.dart` übergibt `onToggleTheme` an `createRouter` und `AppDrawer`

---

## App-Start / Init-Flow

Beim App-Start landet der Router auf `/connecting` → `ConnectingPage`.

```
App start
  └─ /connecting → ConnectingPage
        ├─ fetchUser() (5s timeout)
        │     ├─ OK  → UserStore.current = user → go('/projects')
        │     └─ ERR → UserStore.lastError = msg → go('/connection-error')
        └─ /connection-error → ConnectionErrorPage
              └─ Retry → go('/connecting')  (startet von vorne)
```

- `ConnectingPage` und `ConnectionErrorPage` liegen **außerhalb** des `ShellRoute` (kein Drawer, keine AppBar)
- Beide Pages liegen direkt in `lib/pages/` (nicht in einem Unterordner)
- Der Timeout ist **5 Sekunden** via `.timeout(const Duration(seconds: 5))`
- `UserStore.lastError` enthält den Fehlertext für die Error-Page

---

## UserStore

**Datei:** [lib/api/user_store.dart](lib/api/user_store.dart)

Einfacher static holder — kein Package, kein Stream.

```dart
UserStore.current   // User? — nach erfolgreichem Init gesetzt
UserStore.lastError // String? — Fehlertext des letzten fehlgeschlagenen Versuchs
UserStore.clear()   // reset
```

`AppDrawer` liest `UserStore.current` direkt für Initials, displayName und E-Mail.

---

## API-Schicht — SDK-Architektur

> **Pflichtlektüre für jeden Agent, der API-Endpoints anfasst.**

### Einstiegspunkt

```dart
import 'package:dokploy_mobile/api/index.dart';

final api = DokployApi();
await api.user.get();
await api.user.createApiKey(name: 'CLI');
await api.project.all();
await api.project.find(projectId);
```

### Dateistruktur — Konvention ist Gesetz

```
lib/api/
├── _client.dart          # ApiClient (get/post) + ApiException — nie direkt importieren
├── index.dart            # EINZIGER öffentlicher Einstiegspunkt — DokployApi { user, project, deployment, service, ... }
├── models.dart           # Shared Models + Re-Exports der Domaenen-Modelle
├── user_store.dart       # Static holder für eingeloggten User
├── deployment/
│   ├── index.dart        # DeploymentApi
│   ├── models.dart       # Deployment + DeploymentQueueItem
│   ├── all.dart
│   └── queueList.dart
├── service/
│   ├── index.dart        # ServiceApi
│   └── one.dart          # Dynamischer .one-Endpoint fuer serviceartige Slugs
├── project/
│   ├── index.dart        # ProjectApi
│   ├── models.dart       # Project + ProjectEnvironment + ProjectService
│   └── all.dart
├── user/
│   ├── index.dart        # UserApi
│   ├── models.dart       # User
│   ├── get.dart
│   └── ...
├── {slug}/               # Ordnername = URL-Slug (z.B. "user" für /api/user.*)
│   ├── index.dart        # {Slug}Api-Klasse — exponiert alle Methoden als Instanzmethoden
│   ├── get.dart          # Eine Datei pro Endpoint-Methode
│   ├── getPermissions.dart
│   ├── createApiKey.dart
│   └── ...
```

### Konvention: Dateiname = Methoden-Teil der URL

Die Dokploy-API folgt dem Muster `/api/{slug}.{method}`.  
**Ordner** = `{slug}`, **Datei** = `{method}.dart`.

| URL | Datei |
|---|---|
| `GET /api/user.get` | `lib/api/user/get.dart` |
| `POST /api/user.createApiKey` | `lib/api/user/createApiKey.dart` |
| `GET /api/project.all` | `lib/api/project/all.dart` |

> Dateinamen sind bewusst camelCase (nicht snake_case), weil sie 1:1 den URL-Methoden-Namen entsprechen. Der Dart-Linter warnt — das ist bekannt und akzeptiert.

### Konvention: Erste Zeile in jeder Methoden-Datei

Jede Methoden-Datei beginnt mit einem Kommentar, der HTTP-Verb, optionale Query-Parameter und ggf. das Response-Shape dokumentiert:

```dart
// GET
// oder:
// POST { name: string }
// oder:
// GET ?appName=string → { cpu: number, memory: number }
```

Wenn der Agent eine neue Methoden-Datei anlegt: **immer** diesen Kommentar in Zeile 1 schreiben.  
Wenn der Nutzer eine leere Datei anlegt: der Kommentar in Zeile 1 ist das Signal — daraus Implementierung ableiten.

### Konvention: Funktionsname in Methoden-Dateien

Der Name der exportierten Top-Level-Funktion lautet `{slug}{Method}` (camelCase):

```dart
// lib/api/user/getPermissions.dart
Future<Map<String, dynamic>> userGetPermissions(ApiClient client) async { ... }

// lib/api/project/all.dart
Future<List<Project>> projectAll(ApiClient client) async { ... }
```

### Konvention: index.dart ist immer der Bundler

Wenn eine neue Methoden-Datei in einem Slug-Ordner erstellt wird:

1. Methoden-Datei implementieren (Funktion + Kommentar in Zeile 1)
2. **Immer** `{slug}/index.dart` aktualisieren:
   - Import hinzufügen
   - Delegierende Instanzmethode in der `{Slug}Api`-Klasse ergänzen
3. Falls ein **neuer Slug-Ordner** (neues `{slug}/`) entsteht:
   - `{slug}/index.dart` mit `{Slug}Api`-Klasse anlegen
   - **`lib/api/index.dart`** updaten: Import + `late final {slug} = {Slug}Api(_client)` in `DokployApi`

Kein Agent darf eine Methoden-Datei hinzufügen ohne den Bundler zu aktualisieren.

### Shared HTTP-Client

`lib/api/_client.dart` — **nicht direkt in Pages oder Widgets importieren**.  
Nur `{slug}/index.dart` und Methoden-Dateien dürfen `_client.dart` importieren.

```dart
class ApiClient {
  Future<dynamic> get(String path, {Duration timeout}) async { ... }
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Duration timeout}) async { ... }
}
```

- `BASE_URL` + `API_KEY` kommen aus `.env` via `flutter_dotenv`
- `BASE_URL` wird normalisiert (fehlende Scheme, trailing slash, quoted strings)
- HTTP-Fehler → `ApiException(message)`
- Timeout default: 10s (user.get verwendet 5s)

### Fehlerbehandlung

Alle API-Fehler sind `ApiException` (aus `lib/api/_client.dart`, re-exportiert von `lib/api/index.dart`).  
`DokployApiException` existiert nicht mehr — wurde durch `ApiException` ersetzt.

### Modelle

```
Project
  ├── id, name, description, createdAt, serviceCount
  └── List<ProjectEnvironment>
        ├── id, name, isDefault, serviceCount
        └── List<ProjectService>
              └── id, name, sourceKey, type, status?

User
  └── id, email, firstName, lastName, image?
        computed: displayName, initials

Deployment
  └── id, serviceName, projectName, environmentName, serverName, title, type, status, createdAt

DeploymentQueueItem
  └── id, serviceName, projectName, environmentName, serverName, title, type, state, timestamp
```

`Project.fromJson` / `ProjectEnvironment.fromJson` parsen die Dokploy-API-Response inkl. aller Service-Typen (Application, Compose, MariaDB, Mongo, MySQL, Postgres, Redis). `ProjectService.sourceKey` enthaelt dabei den originalen API-Key wie `redis`, `postgres` oder `compose`.
`ProjectService.endpointSlug` normalisiert dabei API-Sonderfaelle wie `applications` → `application`, damit `api.service.oneForProjectService(service)` den passenden `.one`-Endpoint automatisch treffen kann.

### Aktuell implementierte Slugs

| Slug | Klasse | Methoden |
|---|---|---|
| `user` | `UserApi` | `get`, `update`, `getPermissions`, `createApiKey`, `deleteApiKey`, `getInvitations`, `sendInvitation`, `generateToken`, `getMetricsToken`, `getContainerMetrics`, `getUserByToken`, `checkUserOrganizations`, `createUserWithCredentials`, `assignPermissions`, `remove`, `session` |
| `project` | `ProjectApi` | `all`, `find(id)` *(find = lokal, kein eigener Endpoint)* |
| `deployment` | `DeploymentApi` | `all`, `queueList` |
| `service` | `ServiceApi` | `one(slug, id)`, `oneForProjectService(service)` |

---

## Error Handling — Kindness Silent Errors

> **Pflicht für jeden Agent, der mit API-Calls oder Nutzeraktionen arbeitet.**

Keine Exception darf lautlos verschwinden. Kein `catch (e) {}` ohne Feedback an den Nutzer.

### Toast-System

**Datei:** [lib/components/app_toast/app_toast.dart](lib/components/app_toast/app_toast.dart)

```dart
AppToast.showSuccess(context, title: 'Saved', subtitle: 'Optional detail.');
AppToast.showError(context, title: 'Could not save', subtitle: e.toString());
```

**Verhalten:**
- Slides von oben rein, geht nach oben wieder raus
- Per Swipe nach oben manuell wegwischbar
- Auto-dismiss nach 4 Sekunden
- X-Button zum manuellen Schließen
- Nur ein Toast gleichzeitig (neuer Toast ersetzt alten)

**Design:**
- **Success:** Card-Background, grünes `LucideIcons.circleCheck`-Icon, Titel fett, Untertitel muted
- **Error:** `colorScheme.destructive` (rot) Background, weißes `LucideIcons.circleX`-Icon, Titel + Untertitel in `destructiveForeground`

### Wo Toasts hingehören

| Situation | Was anzeigen |
|---|---|
| API-Call erfolgreich (Mutation) | `showSuccess` mit kurzem Titel |
| API-Call fehlgeschlagen | `showError` mit Titel + `e.toString()` als Subtitle |
| Validierungsfehler (Client-side) | `showError` ohne API-Call |
| Reines Laden von Daten (GET ohne Aktion) | Kein Toast — Fehler im UI inline zeigen |

### Dirty Flag Pattern

Für Formulare mit Save-Button gilt:

1. Initial-Werte beim `initState` in `_initialX`-Variablen speichern
2. `bool get _isDirty` vergleicht alle Controller-Texte gegen Initial-Werte
3. Controller bekommen je einen `addListener(_onChanged)` → `setState(() {})`
4. Save-Button: `onPressed: _isDirty && !_isSaving ? _save : null`
5. Nach erfolgreichem Save: Initial-Werte auf aktuelle Werte setzen, relevante Controller leeren, `UserStore` aktualisieren

```dart
bool get _isDirty =>
    _name.text != _initialName ||
    _password.text.isNotEmpty;
```

---

## Assets

- `lib/assets/app-icon.svg` — App-Logo (monochrom, ein File für Light+Dark via `ColorFilter.mode(..., BlendMode.srcIn)`)
- `lib/assets/enviroments/` — Service-Icons fuer Environment-Karten; Dateinamen werden zur Laufzeit gegen `ProjectService.sourceKey` normalisiert gematcht, damit neue Dateien ohne Codeaenderung automatisch auftauchen
- `lib/assets/` — gesamtes Verzeichnis als Flutter-Asset registriert
- `.env` — ebenfalls als Asset registriert

---

## Design-Regeln (nicht verhandelbar)

- **Kein** `Icons.*` — immer `LucideIcons.*`
- **Kein** `MaterialApp` / `MaterialButton` / `Card` etc. — immer `ShadApp`, `ShadButton`, `ShadCard` etc.
- **Kein** hardcodiertes Styling (Colors, Padding, Fonts) — Theme-driven via `ShadTheme.of(context)`
- Textgrößen immer via `ShadTheme.of(context).textTheme.*` (h2, h3, h4, p, muted, small, large)
- Pages enthalten Layout + Composition, keine komplexe Logik
- Components in `/components`, page-spezifische Widgets als private Klassen (`_Xyz`) in der jeweiligen Page

---

## Bekannte Probleme / offene Punkte

- **Performance:** `api.project.find(id)` ruft intern `api.project.all()` auf (kein dedizierter GET-Endpoint per ID). Bedeutet: Breadcrumbs + ProjectDetailPage + EnvironmentDetailPage + ServiceDetailPage machen je einen separaten API-Call auf dieselbe Liste. Caching fehlt.
- **Navbar-Struktur:** Navigation wurde von "Home/Settings"-Flat-Struktur auf "Delivery/Observability/Platform/Preferences"-Gruppierung umgestellt — noch nicht final abgestimmt
- **Viele Platzhalter-Pages:** monitoring, docker, swarm, requests, web_server, profile — nur "coming soon"
- **State Management:** Kein Package (Riverpod/Bloc) — ThemeNotifier via InheritedNotifier reicht aktuell; bei wachsender Komplexität evaluieren
- **ShadProgress Splash:** Angefragt aber noch nicht implementiert
- **`ServiceDetailPage`:** Tab-Inhalte sind noch Platzhalter (nur Tab-Label wird gezeigt)
- **`General`-Tab unter Services:** rendert jetzt typ-spezifische Seiten fuer `applications`, `mariadb`, `mongo`, `mysql`, `postgres`, `redis` und `compose`
- **Environment-Service-Karten:** zeigen Status jetzt als farbigen Punkt oben rechts statt Badge und laden Typ-Icons dynamisch aus `lib/assets/enviroments/`
- **`_ProjectBreadcrumbs`** macht einen eigenen API-Call für den Projektnamen in der AppBar — selbes Cache-Problem wie oben
