# Game Design Dokument

Status: Frühe Konzeptphase. Dieses Dokument hält die grundlegenden Design-Entscheidungen fest, die vor jeglicher Implementierung getroffen wurden. Es ist als lebendes Dokument gedacht — Ergänzungen und Änderungen sind erwartet, sobald Prototyping neue Erkenntnisse liefert.

## 1. Grundidee

Eine Verschmelzung aus Tower Defense und Automatisierungs-/Fabrikbauspielen (Factorio, Satisfactory, Mindustry). Rohstoffe abbauen, verarbeiten, automatisieren und die daraus entstehende Basis gegen Wellen von Gegnern verteidigen — alles auf **einer gemeinsamen Karte**, kein getrenntes Fabrik- und Verteidigungsgebiet. Bauplatz ist eine zentrale, umkämpfte Ressource: Platz für Förderbänder konkurriert direkt mit Platz für Geschütze und Wälle.

## 2. Narrativer Rahmen

Die Spielfigur(en) sind auf einem fremden Planeten gestrandet. Im Zentrum der Basis steht der **Nexus**, ein Gerät, das als Kommunikationsmittel dient, um ein Rettungsschiff zu organisieren. Der Nexus benötigt dafür enorme und stetig wachsende Mengen an Energie.

Das Problem: Die vom Nexus ausgestrahlte Energie/das Signal lockt gleichzeitig feindliche Kreaturen/Wesen an, die den Nexus zu zerstören versuchen. Wird der Nexus zerstört, ist das Spiel vorbei.

Ob am Ende tatsächlich Rettung erfolgt, bleibt bewusst offen (mögliche narrative Ambivalenz — wird später im Rahmen des Writings entschieden, hat keinen Einfluss auf die Kernmechanik). Der mechanische Sieg (Nexus erreicht Ziel-Energieniveau) bleibt davon unabhängig klar definiert.

## 3. Kernschleife (Core Loop)

```
Ressourcen abbauen → verarbeiten → Energie erzeugen → Nexus versorgen
        ↑                                                    │
        │                                                    ▼
  Fabrik ausbauen ←── Forschung freigeschaltet ←── Energiedurchsatz steigt
        │                                                    │
        └── Verteidigung braucht Munition/Strom/Reparatur ←──┤
                                                               ▼
                                                    Signal wird lauter
                                                               │
                                                               ▼
                                                  stärkere/klügere Gegner
```

Der Loop ist selbstverstärkend: Mehr Produktion → mehr Energie → schnellerer Fortschritt, aber auch stärkere Bedrohung → mehr Bedarf an Verteidigung → mehr Produktion für Munition/Ersatzteile.

### Dark Start (wichtiger Pacing-Mechanismus)

Solange der Nexus **nicht** eingeschaltet ist:
- Keine Forschung möglich.
- Keine Gegner greifen an (kein Signal, keine Bedrohung).

Das Einschalten des Nexus ist ein bewusster, dramatischer Moment — der eigentliche Startschuss des Spiels. Davor: drucklose Tutorial-/Aufbauphase (erste Förderer, erste Schmelze, erste Dampfmaschine). Danach: Forschungstempo und Bedrohungsstärke sind beide direkt an den Energiedurchsatz gekoppelt.

### Kein fixer Zeitrahmen

Ein Playthrough hat keine feste Länge. Fortschritt ist an den Energiedurchsatz gebunden, den der Spieler selbst erzeugt — kein externer Wellentimer. Ein vorsichtiger Spieler bekommt eine langsamere, sanftere Eskalation; ein Spieler, der aggressiv hochfährt, kommt schneller voran, muss dafür aber auch früher stärkere Wellen bestehen. Die Schwierigkeit skaliert sich dadurch selbst, spielergetrieben.

## 4. Gegner-Eskalation

Bedrohung kommt von außen (nicht von der Karte selbst generiert). Eskalation ist an den Energiebedarf/-durchsatz des Nexus gekoppelt, nicht an eine reine Zeit-Uhr.

Progression der Gegner-Taktiken (gestufte Eskalation, kein echtes Machine-Learning geplant — vordesignte, nach Schwellenwerten freigeschaltete Verhaltens-Tiers):

1. **Früh**: Kleine, unorganisierte Wellen, simples Frontalrennen auf den Nexus zu.
2. **Mittel**: Gruppentaktik, Aufteilen, Flankieren.
3. **Fortgeschritten**: Einsatz von Fernwaffen.
4. **Spät**: Gezielte Angriffe auf Infrastruktur (Minenbohrer, Energieerzeuger, Stromleitungen) statt blindem Rushen auf den Nexus.
5. **Endgame**: Gegner entwickeln selbst Technologie als Antwort auf Spielerverhalten — z. B. Ballons, um Klippen und Wälle zu überfliegen. Terrain-Barrieren sind dadurch nur früh/mittel im Spiel zuverlässig; im Endgame wird Flugabwehr notwendig, unabhängig davon, wie gut das Terrain sonst abschirmt.

## 5. Ressourcen

### 5.1 Grundstoffe (14, in drei Wichtigkeits-Tiers)

| Tier | Rohstoffe | Charakter |
|---|---|---|
| Tier 0 – Fundament | Eisen, Kupfer, Stein, Wasser | Ab Minute 1 notwendig, ohne die geht nichts |
| Tier 1 – Früh | Kohle, Holz, Erdöl, Schwefel | Einfache Verarbeitung, früh verfügbar |
| Tier 2 – Fortgeschritten | Bauxit, Titan, Lithium, Cobalt, Silber, Uranerz | Setzen bestimmte Technologien zur Verarbeitung voraus |

### 5.2 Verarbeitungstiefe

Wächst über den Spielverlauf:
- **Früh**: einfache Ketten, z. B. 1 Rohprodukt → 2 Zwischenprodukte → 1 Endprodukt.
  Beispiel Eisen: Erzförderer gewinnt Roheisen → Schmelze erzeugt Eisenbarren → Produktionsstätte erzeugt daraus z. B. Eisenplatten oder Eisenkugeln (einfache Munition).
- **Später**: tiefere, verzweigtere Ketten, z. B. 3 Rohprodukte → 6 Zwischenprodukte → 1 Endprodukt + Nebenprodukt für andere Zwecke.

## 6. Energie

- Muss erzeugt, verteilt und gespeichert werden.
- Der Nexus selbst läuft mit Strom — ohne ausreichend Energie ab einem bestimmten Punkt geht nichts mehr.
- Maschinen verbrauchen unterschiedlich viel Strom, abhängig von Stufe/Art.
- Energie kann gespeichert werden (Akkus/Batterien) als Puffer.

### Erzeugungsarten (Progression über Techstufen)

1. **Früh**: Dampfmaschine — Wasser wird in einem Kessel verdampft, treibt eine Turbine an, erzeugt Strom. Verbraucht Wasser + Kohle.
2. **Mittel/Spät** (schrittweise per Forschung freigeschaltet): Solar, Windkraft, Wasserkraft, Geothermal.
3. **Endgame**: Kernreaktoren (Uranerz als Brennstoff).

### Verhalten bei Energie-Engpass (Brownout)

Feste Prioritätsreihenfolge, kein Spielereingriff nötig:

1. **Nexus** hat immer oberste Priorität — er darf nie ausfallen.
2. **Verteidigung** hat Vorrang vor allen anderen Gebäudekategorien.
3. Reicht die Energie trotzdem nicht, werden die **am weitesten vom Nexus entfernten Gebäude** nach und nach abgeschaltet, um Nexus und Verteidigung am Leben zu halten.

Das erzeugt einen strategischen Nebeneffekt: Weit expandierte Außenposten (Abbaustationen etc.) sind bei Energieknappheit zuerst gefährdet — Expansion ist dadurch nicht nur räumlich/verteidigungstechnisch, sondern auch energetisch riskant.

### Nexus-Energiebedarf: nicht drosselbar

Der Energiebedarf des Nexus ist **fest, nicht vom Spieler regulierbar**. Der Nexus muss durchgehend laufen — es gibt keinen "Sicherheitsmodus", der die Bedrohung künstlich reduziert. Das steigende Energiebedarf-Niveau ist eine feste Herausforderung, der sich der Spieler stellen muss, kein Hebel, mit dem man das Tempo drosseln kann.

## 7. Karte & Bauraster

- **Prozedural generiert**, inklusive Ressourcenverteilung.
- **Kachelbasiertes Bauraster**. Beispiele für Gebäude-Footprints:
  - Minenförderer: 2×2 Kacheln
  - Produktionsgebäude: 2×2 Kacheln
  - Nexus: 3×3 Kacheln
- **Natürliches Terrain**: Flüsse, Seen, Klippen — unpassierbar, bilden natürliche Grenzen/Nadelöhre, ähnlich wie Wasser. Reduziert den Bedarf an vollständigen Verteidigungsringen, da "sichere" Flanken durch Terrain entstehen.

### Kartengröße & Ressourcen-Erschöpfung

Die Karte ist **sehr groß, quasi unbegrenzt** (ähnlich Factorios praktisch endloser Welt). Die meisten Rohstoffvorkommen sind **endlich** und erschöpfen sich mit der Zeit — nur wenige Ausnahmen (z. B. Wasser) sind unerschöpflich. Expansion ist dadurch zwingend notwendig, ähnlich wie in Factorio, und erhöht — wie oben beschrieben — sowohl das Bedrohungs- als auch das Energieversorgungsrisiko für die neu erschlossenen Außenbereiche.

## 8. Gebäudekategorien

Fünf Oberkategorien:

1. **Strom** — Energieerzeugung und -speicherung.
2. **Ressourcenabbau** — Förderer für Erze, Holz, Wasser etc.
3. **Verarbeitung & Produktion** — Schmelzen, Craften, Weiterverarbeitung.
4. **Verteidigung** — Wälle/Barrieren, Geschütztürme, Sensorik/Früherkennung, Reparatur. (Konkrete Bausteinliste noch im Detail offen.)
5. **Logistik & Lager** — Transport von Ressourcen zwischen Gebäuden (Förderbänder/Rohre/Drohnen — Mechanik im Detail noch offen) sowie Lagerung.

Verteidigungsgebäude sind selbst Verbraucher im Logistiknetz: Geschütze brauchen Munitionsnachschub und Strom, müssen also wie jede Fabrik ans Logistik- und Stromnetz angeschlossen sein. Ein Geschütz ohne Versorgungslinie ist nutzlos.

## 9. Forschung / Tech-Progression

- Forschung ist **hart an den Nexus gebunden**: Läuft der Nexus nicht, gibt es keine Forschung (Soft Gate, siehe Dark Start).
- Forschungstempo ist an den **Energiedurchsatz** gekoppelt: Mehr Energie = schnellerer Fortschritt bei neuen Technologien, Gebäuden, Waffen.
- Da der Energiebedarf stetig wächst, wird auch die Hürde für weiteren Fortschritt stetig größer — reiner Trade-off zwischen Tempo und Risiko, kein Weg, gleichzeitig sicher und schnell zu sein.

## 10. Scope-Entscheidungen (aktueller Stand)

- **Kein spielbarer Charakter / keine persönliche Ausrüstung** — zumindest fürs Erste. Rein strategische Draufsicht-Steuerung, keine verkörperte Spielfigur. Kann später nachgerüstet werden, ohne die Kernarchitektur zu verändern.
- **2D Top-Down.**
- **Singleplayer only** (fürs Erste — Koop bewusst nicht für den ersten Wurf im Scope).

## 11. Offene Punkte (noch zu klären)

- Konkrete Gebäudeliste innerhalb der Kategorie Verteidigung (Wandtypen, Geschütztypen/Munitionsarten, Sensorik, Reparatur, evtl. Schilde).
- Konkreter Logistik-Mechanismus (Förderbänder vs. Rohre vs. Drohnen vs. direkte Verbindungen).
- Browser vs. Standalone-Anwendung (Technik-Stack noch nicht entschieden).
- Narrative Ausgestaltung des Endes (offen/ambivalent vs. verzweigt) — später im Rahmen des Writings.
