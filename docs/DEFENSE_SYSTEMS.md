# Verteidigungssystem — Architektur-Referenz

Dieses Dokument beschreibt die in Godot 4.3 (GDScript) umgesetzte, modulare Verteidigungsgebäude-Architektur. Es ergänzt `docs/GAME_DESIGN.md` (Gesamtkonzept) um die technischen Details der Implementierung. Umgesetzt wurde ausschließlich die Verteidigung — keine vollständigen Gegnerwellen, keine Forschung, keine Ressourcenketten/Produktion. Diese Systeme sind über klar abgegrenzte Schnittstellen (Strom, Munition, Reparatur, Zielerfassung) vorbereitet, aber bewusst als Stubs implementiert.

## Lokales Öffnen & Testen

Diese Session konnte Godot nicht selbst ausführen (Netzwerk-Policy blockiert den Download in der Remote-Umgebung) — die Verifikation muss lokal erfolgen:

1. Godot 4.3+ installieren, Projekt öffnen (Ordner mit `project.godot` auswählen).
2. `demo/defense_test_scene.tscn` öffnen und **Play** drücken (oder F6 für "aktuelle Szene ausführen").
3. Manuell prüfen (siehe Checkliste unten): Bauen über das Baumenü links, Gebäude anklicken für das Info-Panel rechts, Testgegner mit den Zifferntasten **1–4** am Kartenrand spawnen (1=klein, 2=mittel, 3=schwer, 4=fliegend).
4. Für die reinen Logik-Tests (ohne Szene, ohne Grafik):
   ```
   godot --headless --script res://tests/run_tests.gd
   ```
   Gibt `PASS`/`FAIL` pro Testfall aus und beendet sich mit Exit-Code 0 (alles bestanden) oder 1 (Fehler vorhanden).

### Manuelle Checkliste (Demo-Szene)

- Wände lenken Testgegner in den vorgegebenen Korridor (Zifferntaste 1 am Kartenrand spawnen, Weg Richtung Nexus beobachten).
- Stachelfeld-Reihe verlangsamt kleine/mittlere Gegner stark, schwere kaum (Taste 1 vs. Taste 3 durchs Stachelfeld schicken, Tempo vergleichen).
- Automatisches Tor blockiert nur im geschlossenen Zustand und öffnet/schließt abhängig von Gegner-Alarm bzw. Strom.
- MG und Autokanone bekämpfen Bodenziele; leichte Flak bekämpft ausschließlich Flugziele (Taste 4).
- Fliegender Testgegner (Taste 4) ignoriert sämtliche Bodenhindernisse vollständig (fliegt geradewegs, nicht über den Korridor gezwungen).
- Mörser feuert nur, wenn der Wachturm ein Ziel erfasst hat (Sensor-Abhängigkeit, `requires_sensor_link`).
- Reparaturstation heilt die vorbeschädigte Wand in ihrem Radius sichtbar über Zeit.
- Schutzwall vor dem Demo-Generator zeigt erhöhte frontale Schadensresistenz.
- Baumenü zeigt Gebäude nach Unterkategorie gruppiert; Datenreferenzen ohne Szene (Stubs) erscheinen deaktiviert.

## Ordnerstruktur

```
autoload/            Singletons: BuildingRegistry, NavigationManager, PowerGridService,
                      SupplyService, SensorNetwork
scripts/
  defense_enums.gd    Alle Enums/Konstanten (DefenseEnums)
  resources/          Daten-Resource-Klassen (DefenseBuildingData + Unterklassen)
  components/         Wiederverwendbare Node-Komponenten (Health, Armor, Power, Ammo, ...)
  base/               DefenseBuilding-Klassenhierarchie
  util/               Statische Hilfsfunktionen (DamageCalculator, TargetPriority)
  enemy_stub/         Minimaler Test-Gegner (kein Wellensystem, keine KI)
scenes/
  defense/passive/    generic_obstacle (wiederverwendet) + automatic_gate, spike_field
  defense/active/     generic_weapon/generic_sensor/generic_support (wiederverwendet)
  defense/projectile/ Ein generisches, datengetriebenes Projektil
  enemy/              enemy_stub.tscn, enemy_spawner.tscn (Debug)
  ui/                 build_menu, placement_preview, building_info_panel
data/defense/         .tres-Datenressourcen: passive/, active/weapons|sensors|support/
demo/                 defense_test_scene.tscn + .gd (siehe oben)
tests/                Headless-GDScript-Tests ohne externes Addon
```

## Datengetriebenes Prinzip

Jedes Verteidigungsgebäude ist eine `.tres`-Ressource (`DefenseBuildingData` oder Unterklasse: `PassiveDefenseData`, `WeaponData`, `SensorData`, `SupportData`) unter `res://data/defense/`. `BuildingRegistry` scannt dieses Verzeichnis rekursiv beim Start und indiziert alle Gebäude nach ID, Kategorie und Unterkategorie — **ein neues Gebäude hinzuzufügen bedeutet: eine neue `.tres`-Datei anlegen**, kein Code muss geändert werden.

11 Gebäude sind vollständig umgesetzt (5 passiv, 6 aktiv/sensor/support), 30 weitere existieren als reine Datenreferenzen (plausible Werte, aber `scene_path` leer oder auf eine generische Szene verweisend) und können später ohne Architekturänderung mit eigenem Verhalten ausgestattet werden.

### Wiederverwendbare Szenen statt Einzel-Szenen pro Gebäude

Fast alle Gebäude teilen sich eine von vier generischen Szenen, die ihr komplettes Verhalten aus der zugewiesenen Resource ableiten:

- `generic_obstacle.tscn` — Wände/Hindernisse (Holzbarrikade, Steinwall, Schutzwall, die meisten passiven Stubs)
- `generic_weapon.tscn` — alle Geschütztypen
- `generic_sensor.tscn` — alle Sensorgebäude
- `generic_support.tscn` — Reparatur-/Unterstützungsgebäude

Nur Gebäude mit echtem einzigartigem Verhalten haben eigene Skripte: `automatic_gate.gd` (Zustandsautomat), `spike_field.gd` (Haltbarkeitsverlust durch überquerende Gegner).

## Klassenhierarchie

```
DefenseBuilding (Node2D)          Fassade: take_damage, request_repair, get_health_percent, get_ui_fields
  PassiveDefenseBuilding          Meldet Passierbarkeit bei NavigationManager an
    AutomaticGate / SpikeField / ProtectiveWall (über generic_obstacle)
  ActiveDefenseBuilding           Legt immer PowerConsumerComponent an
    WeaponBuilding                + Ammo/Heat(falls genutzt)/Targeting/Weapon
    SensorBuilding                + SensorComponent
    SupportDefenseBuilding        + RepairProviderComponent
```

`DefenseBuilding._ready()` erzeugt Komponenten **abhängig davon, welche Felder in der zugewiesenen Resource gesetzt sind** (z. B. `HealthComponent` nur wenn `max_health > 0`), nie anhand von Gebäude-IDs — dadurch bestimmt allein die Datenressource, welche Fähigkeiten ein Gebäude hat.

## Navigation

`NavigationManager` verwaltet drei benannte `AStarGrid2D`-Profile (`ground_small`, `ground_large`, `flying`). Ob und wie ein passives Gebäude ein Profil beeinflusst, steht ausschließlich in `PassiveDefenseData.passability_rules` (Liste von `{profile, solid, weight_scale}`-Dictionaries) — der Navigationscode selbst unterscheidet nie nach Gebäudetyp. Das erlaubt Volle Blockade, größen-selektive Teilverlangsamung (Stachelfeld/Panzersperre) und größen-selektive Unpassierbarkeit (Graben) rein datengetrieben. Fliegende Gegner ignorieren Bodenhindernisse vollständig, weil für sie schlicht nie eine Regel im `flying`-Profil hinterlegt wird.

Belegter Bauplatz (`occupancy`) ist von der Navigations-Passierbarkeit getrennt: **jedes** Gebäude (auch Geschütze/Sensoren) reserviert seine Kacheln, aber nur passive Gebäude beeinflussen zusätzlich das Pathfinding.

## Schnittstellen für Strom, Munition, Reparatur, Zielerfassung

- **Strom** (`PowerGridService`): Autoload-Stub, gewährt aktuell frei Strom, erfasst aber bereits pro Gebäude den tatsächlichen Verbrauch — Grundlage für die im Design-Dokument festgelegte Priorität Nexus > aktive Verteidigung > distanzbasierte Abschaltung.
- **Munition** (`AmmoComponent` + `SupplyService`): lokales Magazin pro Gebäude, Nachschub-Anfrage an einen austauschbaren Stub-Service.
- **Reparatur**: läuft ausschließlich über die `DefenseBuilding`-Fassade (`request_repair`), nie direkt über die Health-Komponente — dadurch können später auch Reparaturdrohnen denselben Aufruf nutzen.
- **Zielerfassung** (`TargetingComponent`, `SensorComponent`, `SensorNetwork`): minimaler Vertrag über die Gruppe `defense_targets` (`is_alive`, `get_target_type`, `take_damage`, `global_position`) — jeder zukünftige echte Gegner muss nur dieser Gruppe beitreten, keine Waffe muss angepasst werden.

## Bekannte Grenzen dieser Version

- Kein Schild-/Störsender-Verhalten (Schildgenerator, Störsender sind reine Datenreferenzen ohne Szene).
- Keine Reparaturdrohnen, keine Feuerlöschmechanik, kein Wartungsdepot-Bonus (alle drei als Datenreferenz ohne Szene vorhanden).
- Kein Nahbereichsabwehrsystem-Ziel (feindliche Projektile sind noch keine eigenständigen `defense_targets`).
- Kein echtes Gegner-KI-/Wellensystem — `EnemyStub` ist ausdrücklich nur ein manueller Test-Dummy.
