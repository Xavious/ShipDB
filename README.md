# ShipDB

**A comprehensive ship tracking and docking history system, Mudlet package, for Legends of the Jedi**

ShipDB automatically captures ship information when you locate vessels in-game, maintaining both a master ship registry and complete docking history. Track ship movements, filter by any criteria, and analyze patterns across all your discoveries.

---

## Features

### 📊 Dual View System
- **Ships View**: Master registry showing latest known location of each ship
- **History View**: Complete docking records with full movement history

### 🔍 Powerful Search & Filter
- **Real-time search box** with instant filtering
- **Click any field** to filter by that value
- **Command-line filtering** via `shipdb filter <text>`
- Works across all fields: type, name, owner, planet, dock, time

### 📈 Flexible Sorting
- **Click column headers** to sort by any field
- **Toggle sort direction** with repeated clicks
- **Command-line sorting** via `shipdb sort <column>`
- Sorts by: type, name, owner, planet, dock, time

### 📝 Docking History
- **Automatic recording** of every ship lookup
- **Per-ship history** - Click a ship name to view complete docking history
- **All history view** - See every docking record across all ships
- **Character segmentation** - Each character maintains separate records

### 🎯 Interactive UI
- **Clickable fields** for instant filtering
- **Right-click menus** with contextual actions
- **View toggles** to switch between Ships and History
- **Record counts** showing filtered/total results
- **Dark theme** UI matching Mudlet aesthetics

### 🗑️ Data Management
- **Delete ships** from master registry
- **Delete individual docking records** from history
- **Character-isolated** databases for privacy
- **Persistent storage** across sessions

---

## Installation

1. Download the latest `ShipDB.mpackage` from [Releases](../../releases)
2. In Mudlet, go to **Package Manager**
3. Click **Install** and select the downloaded `.mpackage` file
4. The package will auto-load on character login

---

## Usage

### Window Controls

```
showships          Show the ship database window
hideships          Hide the ship database window
```

### Search & Filter

```
shipdb filter <text>      Filter ships/records by any text
shipdb clear              Clear all active filters
```

**Examples:**
```
shipdb filter freighter   Show only Freighters
shipdb filter bob         Show Bob's ships
shipdb filter coruscant   Show ships on Coruscant
```

### Sorting

```
shipdb sort <column>      Sort by column name
```

**Supported columns:** `type`, `name`, `owner`, `planet`, `dock`, `time`

**Examples:**
```
shipdb sort name          Sort alphabetically by ship name
shipdb sort planet        Sort by planet location
shipdb sort time          Sort by discovery time
```

### Updates

```
shipdb update             Check for package updates
```

ShipDB automatically checks for updates when the package loads. Use this command to manually check for updates at any time.

### Debug Mode

```
shipdbdebug 1             Enable debug logging
shipdbdebug 0             Disable debug logging
```

### Help

```
shipdb help               Show command reference
```

---

## Interactive Features

### Ships View

| Action | Result |
|--------|--------|
| **Click column header** | Sort by that column |
| **Click ship type/owner/planet/dock** | Filter to show only matching ships |
| **Click ship name** | View that ship's docking history |
| **Right-click ship name** | Show menu: View History / Locate / Delete |

### History View

| Action | Result |
|--------|--------|
| **Click column header** | Sort by that column |
| **Click any field** | Filter to show matching records |
| **Right-click ship name** | Show menu: Filter / Delete Record |
| **Search box** | Filter history records in real-time |

### View Toggles

- **Ships** button: Switch to master ship list
- **History** button: Switch to all docking records
- **Clear** button: Remove active filters (stays in current view)

---

## How It Works

### Automatic Capture

When you look up a ship in-game:
1. **Ship data is parsed** from game output
2. **Master registry is updated** (or new ship added)
3. **Docking record is created** with timestamp
4. **Window refreshes** to show new information

### Data Storage

**Ships Table:**
- One entry per unique ship
- Shows latest known location
- Character-segmented

**Docking Records Table:**
- One entry per ship lookup
- Complete movement history
- Timestamp for each sighting

### Character Isolation

Each character maintains separate ship databases. Switching characters automatically loads that character's data.

---

## Database Schema

### Ships Table
```lua
{
  character = "",    -- Character name
  name = "",         -- Ship name
  type = "",         -- Ship type (Freighter, Warship, etc.)
  owner = "",        -- Ship owner
  planet = "",       -- Current planet location
  dock = "",         -- Current dock location
  time = ""          -- Last seen timestamp
}
```

### Docking Records Table
```lua
{
  character = "",    -- Character name
  name = "",         -- Ship name
  type = "",         -- Ship type (denormalized)
  owner = "",        -- Ship owner (denormalized)
  planet = "",       -- Planet at time of sighting
  dock = "",         -- Dock at time of sighting
  time = ""          -- Timestamp of sighting
}
```

---

## Configuration

All configuration is centralized in `shipdb.config` at the top of `shipdb.lua`:

### Column Widths
```lua
columns = {
  type = 35,
  name = 25,
  owner = 35,
  planet = 25,
  dock = 45,
  time = 20
}
```

### Window Layout
```lua
ui = {
  window = {
    width = "72%",
    height = "50%",
    x = "-72%",
    y = "0%"
  }
}
```

### Styling

Colors, fonts, and themes can be customized in the `styles` configuration section.

---

## Use Cases

### Tracking Traders
- Monitor which ships frequent specific ports
- Identify regular trade routes
- Track owner movements across planets

### Security Analysis
- Detect unusual ship appearances
- Monitor specific vessels of interest
- Build historical profiles of ship activity

### Intelligence Gathering
- Catalog all discovered vessels
- Map ship distribution by type/owner
- Identify patterns in docking behavior

---

## Troubleshooting

### Ships not appearing after lookup
- Ensure the trigger is capturing ship data (enable debug mode)
- Check that `gmcp.Char.Info.name` is available
- Verify trigger pattern matches your game's output format

### Character switching not working
- Confirm GMCP is enabled in your game
- Check that `gmcp.Char.Info` updates on character change
- Enable debug mode to see character switch events

### UI not displaying properly
- Check that Geyser and Adjustable packages are installed
- Verify window dimensions fit your screen resolution
- Try adjusting `shipdb.config.ui` settings

---

## Development

### Requirements
- Mudlet 4.10+
- GMCP support
- Geyser GUI framework
- Adjustable container support

### File Structure
```
ShipDB/
├── src/
│   ├── scripts/
│   │   └── shipdb.lua          # Main application logic
│   ├── aliases/
│   │   ├── showShips.lua
│   │   ├── hideShips.lua
│   │   ├── shipdbSort.lua
│   │   ├── shipdbFilter.lua
│   │   ├── shipdbClear.lua
│   │   └── shipdbHelp.lua
│   ├── triggers/
│   │   └── shipLocated.lua     # Ship data capture
│   └── resources/
│       └── ftext.lua           # Table formatting library
├── build/
│   └── ShipDB.mpackage   # Compiled package
└── mfile                       # Package metadata
```

### Building

The package is built using [muddler](https://github.com/demonnic/muddler). Source files in `src/` are compiled into `build/ShipDB.mpackage`.

---

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Areas for Enhancement
- Export/import functionality of lists to a datapad?

---

## License

This package is distributed under the MIT License. See LICENSE for details.

---

## Credits

**Author:** Xavious

**Dependencies:** Demonic
- [ftext](https://github.com/demonnic/fText) - Text formatting and table rendering library (MIT License)

---

## Changelog

### Version 1.0.4
- Improved character switching: Prevents unnecessary reloads when gmcp.Char.Info fires
- Added profile reload note in update installation message

### Version 1.0.3
- Added cascade delete: Deleting a ship now also deletes all associated docking records
- Version detection now uses `getPackageInfo()` for accurate tracking
- Removed hardcoded version from config

### Version 1.0.2
- Added pagination system (100 records per page by default)
- Added pagination navigation buttons with visual disabled states
- Added active filter display in info label
- Added automatic update checker on package load
- Added manual update check command (`shipdb update`)
- Added automatic update installation with Geyser popup confirmation
- Fixed help menu text alignment
- Pagination resets when changing views, filters, or sorting

### Version 1.0.1
- Bug fixes and stability improvements

### Version 1.0.0
- Initial release
- Dual Ships/History view system
- Real-time search and filtering
- Clickable field filters
- Automatic docking record capture
- Character-segmented databases
- Command-line aliases
- Interactive help system

---

## Support

For questions, bug reports, or feature requests:
- [Open an issue](../../issues)
- Check the [Wiki](../../wiki) (if available)
- `#scripting` in the Lotj Discord channel

---

**Happy ship tracking!** 🚀
