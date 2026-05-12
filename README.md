# toon-weer

A weather app for the [Toon](https://www.eneco.nl/toon/) smart thermostat (Toon 1
and Toon 2 / Nxt). Fork of
[`ToonSoftwareCollective/buienradar`](https://github.com/ToonSoftwareCollective/buienradar)
with a new summary tile, a numeric weather score, Open-Meteo data integration,
configurable refresh intervals, memory-leak fixes and a CI/linting setup.

Currently tracking upstream version **9.0.11** (see `version.txt` / `Changelog.txt`).

---

## Table of contents

-   [What it does](#what-it-does)
-   [Tiles](#tiles)
-   [Screens](#screens)
-   [Data sources](#data-sources)
-   [Settings](#settings)
-   [Comparison with upstream](#comparison-with-upstream)
-   [Repository layout](#repository-layout)
-   [Development](#development)

---

## What it does

`toon-weer` adds Dutch weather information to the Toon home screen and tray:

-   Current temperature, wind, humidity, air pressure and "gevoelstemperatuur"
    (feels-like) for a selected KNMI weather station (Buienradar JSON feed).
-   Rain prediction for the next two hours per lon/lat coordinate, plotted as a
    graph on a tile.
-   A summary tile that combines current conditions with today's or tomorrow's
    min/max temperature, max wind, max UV, total precipitation and a numeric
    weather score.
-   Sunrise / sunset tile for the selected location.
-   A 5-day forecast (icons, min/max temperature, precipitation, weather score)
    on the details screen.
-   A full-screen radar viewer with multiple Buienradar map options (rain,
    pollen, mosquito, BBQ, EU map, hourly/3-hour/24-hour radar, minimum and
    maximum temperature maps, current temperature, wind force, minimum ground
    temperature, motregen).
-   A tray icon that opens the big radar viewer directly.

## Tiles

| Tile                  | Source file           | Description                                                                                                                                                                                     |
| --------------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Weather tile          | `WeerTile.qml`        | Compact tile showing temperature, weather icon, wind (Bft), humidity, air pressure and "gevoelstemperatuur".                                                                                    |
| Summary tile          | `WeerSummaryTile.qml` | **New in fork.** "Now \| today" or "now \| tomorrow" view with current temperature + icon, min/max, max wind, current/max UV, current 5-min rain / total rain, and current / day weather score. |
| Rain prediction tile  | `WeerRegenTile.qml`   | Graph of expected rain over the next N hours (configurable), interpolated from Open-Meteo data into 5-minute slots.                                                                             |
| Sunrise / sunset tile | `WeerSunriseTile.qml` | Sunrise and sunset times for the selected location.                                                                                                                                             |

## Screens

| Screen                 | Source file                         | Description                                                                                                                                                |
| ---------------------- | ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Details                | `WeerDetailsScreen.qml`             | Current conditions, forecast text, 5-day forecast (icons / min-max / precipitation / score), 12-hour strip with hourly weather score, small radar preview. |
| Full forecast text     | `WeerFullWeatherForecastScreen.qml` | Full-screen scrollable weather forecast text.                                                                                                              |
| Weather station picker | `WeerStationScreen.qml`             | Select a KNMI station from the list.                                                                                                                       |
| Lon/Lat editor         | `WeerEditLonLatScreen.qml`          | Set coordinates manually or by tapping the map.                                                                                                            |
| Big radar viewer       | `WeerActualRadarScreen.qml`         | Buienradar radar / specialty maps with the yellow location marker.                                                                                         |
| Tray icon              | `WeerTray.qml`                      | Opens the big radar viewer.                                                                                                                                |
| Menu entry             | `WeerMenu.qml`                      | Adds the app to Toon's menu.                                                                                                                               |

## Data sources

-   **Buienradar JSON feed** — current conditions, station list, 5-day forecast,
    forecast text, radar images.
-   **Buienradar 2-hour rain prediction** — per lon/lat, used for the rain tile
    and big radar overlays.
-   **Open-Meteo** — hourly precipitation, UV index and additional fields used
    for the summary tile and weather score. Hourly precipitation is interpolated
    into 5-minute slots for the rain tile.

## Settings

Settings stored in `/mnt/data/tsc`:

-   Selected weather station (KNMI ID).
-   Longitude / latitude for the rain prediction.
-   Weather refresh interval (configurable).
-   Rain refresh interval (configurable).
-   Rain-prediction hours window (configurable, drives both the tile and the
    summary aggregates).
-   Show today vs. show tomorrow in the summary tile.

## Comparison with upstream

Upstream: [`ToonSoftwareCollective/buienradar`](https://github.com/ToonSoftwareCollective/buienradar)
@ `main` (9.0.11). All upstream features remain present; this fork adds the
rows marked **fork-only** below.

### Feature comparison

| Feature                                               | Upstream `buienradar` | Fork `toon-weer`           |
| ----------------------------------------------------- | --------------------- | -------------------------- |
| Weather tile (temp, wind, humidity, air pressure)     | yes                   | yes                        |
| Sunrise / sunset tile                                 | yes                   | yes                        |
| 2-hour rain prediction tile (Buienradar)              | yes                   | yes, extended              |
| 5-day forecast on details screen                      | yes                   | yes, redesigned            |
| Full radar viewer (rain / pollen / muggen / BBQ / EU) | yes                   | yes                        |
| Tray icon → radar viewer                              | yes                   | yes                        |
| KNMI station picker + lon/lat editor                  | yes                   | yes                        |
| **Summary tile** (now \| today / tomorrow combined)   | —                     | **fork-only**              |
| **Numeric weather score 0–10**                        | —                     | **fork-only**              |
| **Hourly weather score in 12-hour strip**             | —                     | **fork-only**              |
| **5-day forecast: combined min/max row + daily mm**   | basic min/max only    | **fork-only redesign**     |
| **Open-Meteo data feed (UV, hourly precipitation)**   | —                     | **fork-only**              |
| **Rain tile interpolated to 5-minute slots**          | Buienradar only       | **fork-only (Open-Meteo)** |
| **Configurable weather refresh interval**             | fixed 10 min          | **fork-only**              |
| **Configurable rain refresh interval**                | fixed                 | **fork-only**              |
| **Configurable rain-prediction hours window**         | fixed 2 h             | **fork-only**              |
| **"gevoelstemperatuur" label** (was "feelsLikeTemp")  | feelsLikeTemp         | **fork-only rename**       |
| **XHR memory-leak fix** (abort + closure cleanup)     | —                     | **fork-only**              |
| **QML files prefixed `Weer*`** (was `Buienradar*`)    | `Buienradar*`         | **fork-only rename**       |
| Settings stored in `/mnt/data/tsc`                    | yes (since 8.4.3)     | yes                        |

### Tooling / repo comparison

| Item                                          | Upstream | Fork                                  |
| --------------------------------------------- | -------- | ------------------------------------- |
| `README.md`                                   | —        | yes                                   |
| `.pre-commit-config.yaml` (prettier, qmllint) | —        | yes                                   |
| `.prettierrc.json` / `.prettierignore`        | —        | yes                                   |
| GitHub Actions PR linting workflow            | —        | yes (`.github/workflows/pr-lint.yml`) |
| `toon-qml-memory.sh` (QML memory diagnostics) | —        | yes                                   |
| `qmlformat`-formatted QML                     | —        | yes                                   |

### File renames (upstream → fork)

| Upstream                                  | Fork                                |
| ----------------------------------------- | ----------------------------------- |
| `BuienradarApp.qml`                       | `WeerApp.qml`                       |
| `BuienradarTile.qml`                      | `WeerTile.qml`                      |
| `BuienradarDetailsScreen.qml`             | `WeerDetailsScreen.qml`             |
| `BuienradarFullWeatherForecastScreen.qml` | `WeerFullWeatherForecastScreen.qml` |
| `BuienradarActualRadarScreen.qml`         | `WeerActualRadarScreen.qml`         |
| `BuienradarEditLonLatScreen.qml`          | `WeerEditLonLatScreen.qml`          |
| `BuienradarStationScreen.qml`             | `WeerStationScreen.qml`             |
| `BuienradarRegenTile.qml`                 | `WeerRegenTile.qml`                 |
| `BuienradarSunriseTile.qml`               | `WeerSunriseTile.qml`               |
| `BuienradarMenu.qml`                      | `WeerMenu.qml`                      |
| `BuienradarTray.qml`                      | `WeerTray.qml`                      |
| `buienradar.js`                           | `weer.js`                           |
| —                                         | `WeerSummaryTile.qml` (new)         |

## Repository layout

```
.
├── .github/workflows/pr-lint.yml   # PR linting (fork-only)
├── .pre-commit-config.yaml         # prettier + qmllint hooks (fork-only)
├── .prettierrc.json                # prettier config (fork-only)
├── .prettierignore                 # prettier ignores (fork-only)
├── Changelog.txt                   # upstream changelog
├── EditTextLabel4421.qml           # firmware 4.4.21 compatibility helper
├── StationFilterDelegate.qml       # station-list filter delegate
├── WeerActualRadarScreen.qml       # big radar viewer
├── WeerApp.qml                     # main app (data fetching, state)
├── WeerDetailsScreen.qml           # details screen
├── WeerEditLonLatScreen.qml        # lon/lat editor with map
├── WeerFullWeatherForecastScreen.qml
├── WeerMenu.qml                    # menu entry
├── WeerRegenTile.qml               # 2-hour rain tile
├── WeerStationScreen.qml           # station picker
├── WeerSummaryTile.qml             # summary tile (fork-only)
├── WeerSunriseTile.qml             # sunrise/sunset tile
├── WeerTile.qml                    # main weather tile
├── WeerTray.qml                    # tray icon
├── drawables/                      # weather icons (day/night/dim variants)
├── lang/                           # translations
├── qmldir                          # QML module declaration
├── toon-qml-memory.sh              # memory diagnostic script (fork-only)
├── version.txt                     # current version
└── weer.js                         # JS helpers (formatting, score, fetch)
```

## Development

This repo uses `pre-commit` hooks to keep QML and JS consistently formatted.

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

The hooks run `prettier` (JS / YAML / JSON / Markdown), `qmlformat` and
`qmllint` (Qt 6.4.2 is used in CI to avoid Qt 5.15 incompatibilities). The same
checks run on pull requests via `.github/workflows/pr-lint.yml`.

Deployment to a Toon device is unchanged from upstream — install through
ToonStore, or push the contents of this directory to `/qmf/qml/apps/weer/` on
the device.
