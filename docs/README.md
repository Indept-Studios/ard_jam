# Ghost Hunter

Ein kleines Arcade-Survival-Spiel, entstanden für die [ARD Game Jam 2026](https://itch.io/jam/-ard-game-jam-2026) mit Godot.

## Thema: Body & Mind

> *The physical body and the conscious mind, and the relationship between them.*

Du steuerst einen Körper, der von Geistern verfolgt wird. Bäume schützen den Körper, halten Geister jedoch nicht auf. Wenn lange keine Flask eingesammelt wird, beginnt die sichtbare Verwandlung in den Spiritmode: Der Spieler wird zum Geist, kann durch Bäume laufen und Geister vernichten.

Doch Freiheit hat ihren Preis: Sobald der erste Geist im Spiritmode besiegt wird, erscheint eine lila Ziel-Flask. Sie muss vor Ablauf des Countdowns eingesammelt werden – sonst ist das Spiel vorbei.

## Steuerung

| Taste | Aktion |
| --- | --- |
| `WASD` oder Pfeiltasten | Bewegen |
| `Esc` | Pause öffnen bzw. schließen |

## Spielmechaniken

| Element | Wirkung |
| --- | --- |
| Normale Flasks | Gewähren Tempo, Schild oder eine Spirit Bomb. |
| Speed | Erhöht vorübergehend die Bewegungsgeschwindigkeit. |
| Shield | Schützt den Körper; berührende Geister werden zerstört. |
| Spirit Bomb | Wächst kurz an und vernichtet anschließend Geister im Radius. |
| Spiritmode | Der Spieler wird lila, kann Bäume durchqueren und zerstört nahe Geister. |
| Lila Ziel-Flask | Erscheint nach dem ersten Spirit-Kill. Einsammeln hält den Spiritmode aktiv und erhöht den Bonus. |

## Fortschritt

| Aufgabe | Status |
| --- | :---: |
| Spieler kann sich bewegen | done |
| Spieler kann nicht aus dem Bild laufen | done |
| Objekte können aufgesammelt werden | done |
| Ein Gegnertyp | done |
| Bäume mit Kollision / TileMap | done |
| Punktestand | done |
| Game Over | done |
| Neustart | done |
| Pause-Overlay | done |
| Enemy Spawner und Gegnerwellen | done |
| Mehrere Collectables: Tempo, Schild, Spirit Bomb | done |
| Spiritmode mit Ziel-Flask und Countdown | done |
| Spieler-Sprites und Verwandlungsanimation | done |
| Gegner- und Collectable-Sprites | done |
| Mehrere Baum-Sprites | |
| Score-UI verbessern | |
| Level vergrößern / weiter ausbauen | |
| Partikel und weitere visuelle Effekte | |
| Sound & Musik | |

## Projektstruktur

```text
scenes/       Spiel-, Gegner-, Collectable- und Effekt-Szenen
scripts/      Spiellogik
resources/    Collectable-Definitionen
sprites/      Pixel-Art und Sprite-Sheets
DEBUG/        FPS- und Versionsanzeige
```

## Assets

Die aktuelle Pixel-Art verwendet ein 48 × 48 px Raster. Der Player besitzt eine eigene Transformationsanimation vom blauen Körper zum lila Geist.
