shipdb = shipdb or {}

-- Configuration
shipdb.config = shipdb.config or {
  -- Debug settings
  debug_mode = 0,

  -- Sort settings
  sort_by = "name",
  sort_by_invert = -1,

  -- Search/filter settings
  search_filter = "",

  -- View state settings
  view_mode = "ships",      -- "ships" or "history"
  history_ship = nil,       -- Ship name when viewing history

  -- Database settings
  db_name = "shipdatabase",

  -- UI dimensions
  ui = {
    window = {
      width = "72%",
      height = "50%",
      x = "-72%",
      y = "0%",
      title = "shipdb",
      titleColor = "white"
    },
    console = {
      x = "0%",
      y = "12%",
      width = "100%",
      height = "88%",
      font_size = 8,
      color = "black",
      autoWrap = true,
      scrollBar = true
    },
    search_label = {
      x = "0%",
      y = "3%",
      width = "9%",
      height = "8.55%",
      font_size = 10
    },
    search = {
      x = "9%",
      y = "3%",
      width = "25%",
      height = "8.55%",
      font_size = 10
    },
    clear_button = {
      x = "34%",
      y = "3%",
      width = "6%",
      height = "8.55%",
      font_size = 10
    },
    toggle_ships = {
      x = "41%",
      y = "3%",
      width = "7%",
      height = "8.55%",
      font_size = 10
    },
    toggle_history = {
      x = "48%",
      y = "3%",
      width = "7%",
      height = "8.55%",
      font_size = 10
    },
    info_label = {
      x = "56%",
      y = "3%",
      width = "44%",
      height = "8.55%",
      font_size = 10
    },
    button = {
      fontSize = 10,
      size = 20,
      padding = 10
    }
  },

  -- Column widths
  columns = {
    type = 35,
    name = 25,
    owner = 35,
    planet = 25,
    dock = 45,
    time = 20
  },

  -- Column colors (cecho format)
  colors = {
    type = "<cyan>",
    name = "<cyan>",
    owner = "<red>",
    planet = "<purple>",
    dock = "<yellow>",
    time = "<white>"
  },

  -- Table settings
  table = {
    formatType = "c",
    printHeaders = false,
    headCharacter = "",
    footCharacter = "",
    edgeCharacter = "",
    rowSeparator = "-",
    separator = "|",
    autoEcho = true,
    autoEchoConsole = "shipdb_console",
    autoClear = true,
    allowPopups = true,
    separateRows = true,
    title = "shipdb",
    titleColor = "red",
    printTitle = false
  },

  -- Styles (QSS)
  styles = {
    adjLabel = [[
  border: 1px solid rgb(32,34,37);
  background-color: rgb(54, 57, 63);
]],
    button = [[
  QLabel{ border-radius: 25px; background-color: rgba(41,43,47,100%)}
  QLabel::hover{ background-color: rgba(51,54,60,100%);}
  color: rgb(216,217,218)
]],
    menuButton = [[
  QLabel{ background-color: rgba(32,34,37,100%);}
  QLabel::hover{ background-color: rgba(40,43,46,100%);}
]],
    input = [[
  QPlainTextEdit{
    border: 1px solid rgb(32,34,37);
    background-color: rgb(64,68,75);
    font: bold 12pt "Arial";
    color: rgb(255,255,255);
  }
]],
    label = [[
  border: 1px solid rgb(32,34,37);
  background-color: rgb(47,49,54);
  font: bold 20pt "Arial";
  color: rgb(0,0,0);
  qproperty-alignment: 'AlignVCenter|AlignRight';
]]
  }
}

-- Maintain backward compatibility with old config access patterns
shipdb.debug_mode = shipdb.config.debug_mode
shipdb.sort_by = shipdb.config.sort_by
shipdb.sort_by_invert = shipdb.config.sort_by_invert

-- Initialize database
shipdb.db = db:create(shipdb.config.db_name, {
  ships = {
    character = "",           -- Character name
    name = "",               -- Ship name
    type = "",               -- Ship type
    owner = "",              -- Ship owner
    planet = "",             -- Planet location
    dock = "",               -- Dock information
    time = ""                -- Timestamp of discovery
  },
  docking_records = {
    character = "",           -- Character name (part of composite key)
    name = "",               -- Ship name (part of composite key)
    type = "",               -- Ship type (denormalized)
    owner = "",              -- Ship owner (denormalized)
    planet = "",             -- Planet location at this sighting
    dock = "",               -- Dock location at this sighting
    time = ""                -- Timestamp of this sighting
  }
})

shipdb.container = Adjustable.Container:new({
  name = "shipdb_container",
  titleTxtColor = shipdb.config.ui.window.titleColor,
  titleText = shipdb.config.ui.window.title,
  width = shipdb.config.ui.window.width,
  height = shipdb.config.ui.window.height,
  x = shipdb.config.ui.window.x,
  y = shipdb.config.ui.window.y,
  adjLabelstyle = shipdb.config.styles.adjLabel,
  buttonstyle = shipdb.config.styles.menuButton,
  buttonFontSize = shipdb.config.ui.button.fontSize,
  buttonsize = shipdb.config.ui.button.size,
  padding = shipdb.config.ui.button.padding
})

-- Create search label
shipdb.search_label = Geyser.Label:new({
  name = "shipdb_search_label",
  x = shipdb.config.ui.search_label.x,
  y = shipdb.config.ui.search_label.y,
  width = shipdb.config.ui.search_label.width,
  height = shipdb.config.ui.search_label.height,
  fontSize = shipdb.config.ui.search_label.font_size
}, shipdb.container)

shipdb.search_label:setStyleSheet([[
  background-color: rgba(47, 49, 54, 100%);
  border: 1px solid rgb(32, 34, 37);
  color: rgb(216, 217, 218);
  font-size: 10pt;
  font-weight: bold;
  qproperty-alignment: 'AlignCenter';
]])
shipdb.search_label:echo("Search:")

-- Create search box
shipdb.search_box = Geyser.CommandLine:new({
  name = "shipdb_search_box",
  x = shipdb.config.ui.search.x,
  y = shipdb.config.ui.search.y,
  width = shipdb.config.ui.search.width,
  height = shipdb.config.ui.search.height,
  fontSize = shipdb.config.ui.search.font_size
}, shipdb.container)

-- Set up search box behavior
shipdb.search_box:setAction(function(input)
  shipdb.config.search_filter = input:lower()
  shipdb.updateWindow()
end)

-- Create clear button
shipdb.clear_button = Geyser.Label:new({
  name = "shipdb_clear_button",
  x = shipdb.config.ui.clear_button.x,
  y = shipdb.config.ui.clear_button.y,
  width = shipdb.config.ui.clear_button.width,
  height = shipdb.config.ui.clear_button.height,
  fontSize = shipdb.config.ui.clear_button.font_size
}, shipdb.container)

shipdb.clear_button:setStyleSheet([[
  QLabel {
    background-color: rgba(64, 68, 75, 100%);
    border: 1px solid rgb(32, 34, 37);
    border-radius: 3px;
    color: rgb(255, 255, 255);
    font-size: 10pt;
    font-weight: bold;
    qproperty-alignment: 'AlignCenter';
  }
  QLabel:hover {
    background-color: rgba(80, 85, 95, 100%);
    border: 1px solid rgb(100, 105, 115);
  }
]])
shipdb.clear_button:echo("Clear")
shipdb.clear_button:setClickCallback(function()
  shipdb.clearSearch()
end)

-- Create Ships toggle button
shipdb.toggle_ships = Geyser.Label:new({
  name = "shipdb_toggle_ships",
  x = shipdb.config.ui.toggle_ships.x,
  y = shipdb.config.ui.toggle_ships.y,
  width = shipdb.config.ui.toggle_ships.width,
  height = shipdb.config.ui.toggle_ships.height,
  fontSize = shipdb.config.ui.toggle_ships.font_size
}, shipdb.container)

shipdb.toggle_ships:echo("Ships")
shipdb.toggle_ships:setClickCallback(function()
  shipdb.viewShips()
end)

-- Create History toggle button
shipdb.toggle_history = Geyser.Label:new({
  name = "shipdb_toggle_history",
  x = shipdb.config.ui.toggle_history.x,
  y = shipdb.config.ui.toggle_history.y,
  width = shipdb.config.ui.toggle_history.width,
  height = shipdb.config.ui.toggle_history.height,
  fontSize = shipdb.config.ui.toggle_history.font_size
}, shipdb.container)

shipdb.toggle_history:echo("History")
shipdb.toggle_history:setClickCallback(function()
  shipdb.viewAllHistory()
end)

-- Function to update toggle button styles based on active view
function shipdb.updateToggleStyles()
  local active_style = [[
    QLabel {
      background-color: rgba(80, 85, 95, 100%);
      border: 1px solid rgb(100, 105, 115);
      color: rgb(255, 255, 255);
      font-size: 10pt;
      font-weight: bold;
      qproperty-alignment: 'AlignCenter';
    }
  ]]

  local inactive_style = [[
    QLabel {
      background-color: rgba(64, 68, 75, 100%);
      border: 1px solid rgb(32, 34, 37);
      color: rgb(180, 180, 180);
      font-size: 10pt;
      font-weight: bold;
      qproperty-alignment: 'AlignCenter';
    }
    QLabel:hover {
      background-color: rgba(70, 75, 82, 100%);
      border: 1px solid rgb(80, 85, 95);
    }
  ]]

  if shipdb.config.view_mode == "ships" then
    shipdb.toggle_ships:setStyleSheet(active_style)
    shipdb.toggle_history:setStyleSheet(inactive_style)
  else
    shipdb.toggle_ships:setStyleSheet(inactive_style)
    shipdb.toggle_history:setStyleSheet(active_style)
  end
end

-- Initial style update
shipdb.updateToggleStyles()

-- Create info label for messages
shipdb.info_label = Geyser.Label:new({
  name = "shipdb_info_label",
  x = shipdb.config.ui.info_label.x,
  y = shipdb.config.ui.info_label.y,
  width = shipdb.config.ui.info_label.width,
  height = shipdb.config.ui.info_label.height,
  fontSize = shipdb.config.ui.info_label.font_size
}, shipdb.container)

shipdb.info_label:setStyleSheet([[
  background-color: rgba(47, 49, 54, 100%);
  border: 1px solid rgb(32, 34, 37);
  color: rgb(216, 217, 218);
  font-size: 10pt;
  font-style: italic;
  qproperty-alignment: 'AlignVCenter|AlignLeft';
  padding-left: 10px;
]])
shipdb.info_label:echo("")

shipdb.console = Geyser.MiniConsole:new({
  name = "shipdb_console",
  x = shipdb.config.ui.console.x,
  y = shipdb.config.ui.console.y,
  autoWrap = shipdb.config.ui.console.autoWrap,
  color = shipdb.config.ui.console.color,
  scrollBar = shipdb.config.ui.console.scrollBar,
  fontSize = shipdb.config.ui.console.font_size,
  width = shipdb.config.ui.console.width,
  height = shipdb.config.ui.console.height
}, shipdb.container)

-- Filter ships based on search text (case-insensitive, partial match across all fields)
function shipdb.filterShips(ships, searchText)
  if not searchText or searchText == "" then
    return ships
  end

  local filtered = {}
  local search = searchText:lower()

  for _, ship in ipairs(ships) do
    -- Search across all fields
    local searchable = string.format("%s %s %s %s %s %s",
      ship.type:lower(),
      ship.name:lower(),
      ship.owner:lower(),
      ship.planet:lower(),
      ship.dock:lower(),
      ship.time:lower()
    )

    if searchable:find(search, 1, true) then
      table.insert(filtered, ship)
    end
  end

  return filtered
end

-- Switch to ships view
function shipdb.viewShips()
  shipdb.debug("shipdb.viewShips")
  shipdb.config.view_mode = "ships"
  shipdb.config.history_ship = nil
  shipdb.updateToggleStyles()
  shipdb.updateWindow()
end

-- Switch to all history view
function shipdb.viewAllHistory()
  shipdb.debug("shipdb.viewAllHistory")
  shipdb.config.view_mode = "history"
  shipdb.config.history_ship = nil  -- nil means show ALL history
  shipdb.updateToggleStyles()
  shipdb.updateWindow()
end

-- View docking history for a specific ship
function shipdb.viewShipHistory(shipName)
  shipdb.debug("shipdb.viewShipHistory: " .. shipName)
  shipdb.config.view_mode = "history"
  shipdb.config.history_ship = shipName  -- Set specific ship to filter
  shipdb.config.search_filter = ""  -- Clear any active search
  shipdb.updateToggleStyles()
  shipdb.updateWindow()
end

-- Set filter to a specific value (like clicking a field)
function shipdb.setFilter(value)
  shipdb.debug("shipdb.setFilter: " .. value)
  shipdb.config.search_filter = value:lower()
  -- Don't change view mode - filter works in current view
  shipdb.updateWindow()
end

-- Clear search filter (stay in current view)
function shipdb.clearSearch()
  shipdb.config.search_filter = ""
  -- If in history view and viewing a specific ship, clear that filter too
  if shipdb.config.view_mode == "history" and shipdb.config.history_ship then
    shipdb.config.history_ship = nil  -- Show all history instead of just one ship
  end
  if shipdb.search_box then
    shipdb.search_box:print("")
  end
  shipdb.updateWindow()
end

-- Generic sort function that handles any field
function shipdb.sortBy(field)
  shipdb.debug("shipdb.sortBy: " .. field)
  shipdb.sort_by = field
  shipdb.sort_by_invert = shipdb.sort_by_invert * -1
  shipdb.updateWindow()
end

function shipdb.sortShips()
  shipdb.debug("shipdb.sortShips")
  -- Check if character name is available
  if not gmcp or not gmcp.Char or not gmcp.Char.Info or not gmcp.Char.Info.name then
    shipdb.debug("ERROR: gmcp.Char.Info.name not available")
    return {}
  end

  shipdb.debug("Fetching ships for character: "..gmcp.Char.Info.name)
  shipdb.debug("Sort by: "..shipdb.sort_by)
  shipdb.debug("Sort invert: "..tostring(shipdb.sort_by_invert))

  -- Fetch ships for current character from database (no ORDER BY for now)
  local sorted_ships = db:fetch(shipdb.db.ships,
    db:eq(shipdb.db.ships.character, gmcp.Char.Info.name)
  )

  -- Ensure we return a table even if fetch fails
  if not sorted_ships then
    shipdb.debug("ERROR: db:fetch returned nil")
    return {}
  end

  shipdb.debug("Fetched "..#sorted_ships.." ships from database")

  -- Sort in Lua
  table.sort(sorted_ships, function(a,b)
    if shipdb.sort_by_invert < 0 then
      return a[shipdb.sort_by] < b[shipdb.sort_by]
    else
      return a[shipdb.sort_by] > b[shipdb.sort_by]
    end
  end)

  return sorted_ships
end

function shipdb.updateWindow()
  shipdb.debug("shipdb.updateWindow")

  -- Check which view mode we're in
  if shipdb.config.view_mode == "history" then
    shipdb.updateHistoryView()
  else
    shipdb.updateShipsView()
  end
end

function shipdb.updateShipsView()
  shipdb.debug("shipdb.updateShipsView")
  local TableMaker = require("ShipDB/ftext").TableMaker
  shipdb.table = TableMaker:new(shipdb.config.table)

  -- Add columns with configured widths and colors
  shipdb.table:addColumn({name = "type", width = shipdb.config.columns.type, textColor = shipdb.config.colors.type})
  shipdb.table:addColumn({name = "name", width = shipdb.config.columns.name, textColor = shipdb.config.colors.name})
  shipdb.table:addColumn({name = "owner", width = shipdb.config.columns.owner, textColor = shipdb.config.colors.owner})
  shipdb.table:addColumn({name = "planet", width = shipdb.config.columns.planet, textColor = shipdb.config.colors.planet})
  shipdb.table:addColumn({name = "dock", width = shipdb.config.columns.dock, textColor = shipdb.config.colors.dock})
  shipdb.table:addColumn({name = "time", width = shipdb.config.columns.time, textColor = shipdb.config.colors.time})
  shipdb.table:addRow({
    {"type", [[shipdb.sortBy("type")]], "sort by type"},
    {"name", [[shipdb.sortBy("name")]], "sort by name"},
    {"owner", [[shipdb.sortBy("owner")]], "sort by owner"},
    {"planet", [[shipdb.sortBy("planet")]], "sort by planet"},
    {"dock", [[shipdb.sortBy("dock")]], "sort by dock"},
    {"time", [[shipdb.sortBy("time")]], "sort by time"}
  })
  local sorted_ships = shipdb.sortShips()
  local total_ships = #sorted_ships

  -- Apply search filter
  local filtered_ships = shipdb.filterShips(sorted_ships, shipdb.config.search_filter)
  local filtered_count = #filtered_ships

  -- Update info label with search results or total count
  if shipdb.config.search_filter ~= "" and filtered_count < total_ships then
    shipdb.info_label:echo(string.format("Showing %d of %d ships", filtered_count, total_ships))
  else
    shipdb.info_label:echo(string.format("%d ships found", total_ships))
  end

  for _, ship in ipairs(filtered_ships) do
    -- Create filter functions for each field
    local filter_type = function() shipdb.setFilter(ship.type) end
    local filter_owner = function() shipdb.setFilter(ship.owner) end
    local filter_planet = function() shipdb.setFilter(ship.planet) end
    local filter_dock = function() shipdb.setFilter(ship.dock) end

    -- Other action functions
    local delete_ship = function() shipdb.deleteShip(ship.name) end
    local locate_ship = function() send("locateship "..ship.name) end
    local view_history = function() shipdb.viewShipHistory(ship.name) end

    shipdb.table:addRow({
      {ship.type, {filter_type}, {"Filter by: " .. ship.type}},
      {ship.name, {view_history, locate_ship, delete_ship}, {"View History", "Locate", "Delete"}},
      {ship.owner, {filter_owner}, {"Filter by: " .. ship.owner}},
      {ship.planet, {filter_planet}, {"Filter by: " .. ship.planet}},
      {ship.dock, {filter_dock}, {"Filter by: " .. ship.dock}},
      ship.time
    })
  end

  shipdb.table:assemble()
end

function shipdb.setDebug()
  shipdb.debug_mode = tonumber(matches[2])
  if shipdb.debug_mode == 1 then
    print("Debugging mode: ON")
  else
    print("Debugging mode: OFF")
  end
end

function shipdb.debug(message)
  if shipdb.debug_mode == 1 then
    print(message)
  end
end

function shipdb.triggerShipLocated()
  shipdb.debug("shipdb.triggerShipLocated")
  local ship = {}
  ship.character = gmcp.Char.Info.name
  ship.type = multimatches[2].type or ""
  ship.name = multimatches[2].name or ""
  ship.owner = multimatches[3].owner or ""
  ship.dock =  multimatches[4].dock or ""
  ship.planet = multimatches[5].planet or ""
  ship.time = getTime(true, "yyyy-MM-dd hh:mm")

  shipdb.debug("Character: "..ship.character)
  shipdb.debug("Ship name: "..ship.name)
  shipdb.debug("Ship type: "..ship.type)

  -- Check if ship already exists
  local existing = db:fetch(shipdb.db.ships, {
    db:eq(shipdb.db.ships.character, ship.character),
    db:eq(shipdb.db.ships.name, ship.name)
  })

  shipdb.debug("Existing ships found: "..tostring(existing and #existing or "nil"))

  local success = false
  local err = nil

  if existing and #existing > 0 then
    -- Update existing ship record
    local existing_ship = existing[1]
    existing_ship.type = ship.type
    existing_ship.owner = ship.owner
    existing_ship.planet = ship.planet
    existing_ship.dock = ship.dock
    existing_ship.time = ship.time
    success, err = db:update(shipdb.db.ships, existing_ship)

    if err then
      shipdb.debug("ERROR updating ship: "..tostring(err))
      cecho("\n[<cyan>ShipDB<reset>] <red>ERROR updating ship:<reset> "..tostring(err).."\n")
    else
      shipdb.debug("Ship updated successfully")
      cecho("\n[<cyan>ShipDB<reset>] Updating <red>"..ship.name.."<reset>. Toggle window display with <yellow>showships<reset> and <yellow>hideships<reset>\n")
    end
  else
    -- Add new ship to database
    success, err = db:add(shipdb.db.ships, ship)

    if err then
      shipdb.debug("ERROR adding ship: "..tostring(err))
      cecho("\n[<cyan>ShipDB<reset>] <red>ERROR adding ship:<reset> "..tostring(err).."\n")
    else
      shipdb.debug("Ship added successfully")
      cecho("\n[<cyan>ShipDB<reset>] Adding <red>"..ship.name.."<reset>. Toggle window display with <yellow>showships<reset> and <yellow>hideships<reset>\n")
    end
  end

  -- Always add a docking record for this sighting
  local docking_record = {
    character = ship.character,
    name = ship.name,
    type = ship.type,
    owner = ship.owner,
    planet = ship.planet,
    dock = ship.dock,
    time = ship.time
  }
  local dock_success, dock_err = db:add(shipdb.db.docking_records, docking_record)

  if dock_err then
    shipdb.debug("ERROR adding docking record: "..tostring(dock_err))
  else
    shipdb.debug("Docking record added successfully")
  end

  -- Debug: Check total ships in database
  local all_ships = db:fetch(shipdb.db.ships)
  if all_ships then
    shipdb.debug("Total ships in database: "..#all_ships)
    for i, s in ipairs(all_ships) do
      shipdb.debug("  Ship "..i..": "..s.name.." ("..s.character..")")
    end
  end

  shipdb.updateWindow()
end

function shipdb.load()
  -- Check if GMCP data is available
  if not gmcp or not gmcp.Char or not gmcp.Char.Info or not gmcp.Char.Info.name then
    shipdb.debug("shipdb.load: GMCP character info not yet available")
    return
  end

  local currentChar = gmcp.Char.Info.name

  -- Load ships for current character
  local ship_count = #db:fetch(shipdb.db.ships, db:eq(shipdb.db.ships.character, currentChar))
  cecho("\n[<cyan>ShipDB<reset>] Loaded <yellow>"..ship_count.."<reset> ships for <red>"..currentChar.."<reset>\n")
  shipdb.updateWindow()
end

function shipdb.showWindow()
  shipdb.debug("shipdb.showWindow")
  shipdb.container:show()
end

function shipdb.hideWindow()
  shipdb.debug("shipdb.hideWindow")
  shipdb.container:hide()
end

function shipdb.deleteShip(shipName)
  local charName = gmcp.Char.Info.name
  -- Find the ship in the database
  local ships = db:fetch(shipdb.db.ships, {
    db:eq(shipdb.db.ships.character, charName),
    db:eq(shipdb.db.ships.name, shipName)
  })

  if ships and #ships > 0 then
    -- Delete the actual ship object (which contains _row_id)
    db:delete(shipdb.db.ships, ships[1])
    cecho(string.format("\n[<cyan>ShipDB<reset>] Deleted ship <red>%s<reset>.\n", shipName))
    shipdb.updateWindow()
  else
    cecho(string.format("\n[<cyan>ShipDB<reset>] Ship <red>%s<reset> not found.\n", shipName))
  end
end

function shipdb.deleteDockingRecord(record)
  -- Delete the docking record object (which contains _row_id)
  db:delete(shipdb.db.docking_records, record)
  cecho(string.format("\n[<cyan>ShipDB<reset>] Deleted docking record for <red>%s<reset> at %s.\n", record.name, record.time))
  shipdb.updateWindow()
end

function shipdb.updateHistoryView()
  local TableMaker = require("ShipDB/ftext").TableMaker
  shipdb.table = TableMaker:new(shipdb.config.table)

  -- Add same columns as main view
  shipdb.table:addColumn({name = "type", width = shipdb.config.columns.type, textColor = shipdb.config.colors.type})
  shipdb.table:addColumn({name = "name", width = shipdb.config.columns.name, textColor = shipdb.config.colors.name})
  shipdb.table:addColumn({name = "owner", width = shipdb.config.columns.owner, textColor = shipdb.config.colors.owner})
  shipdb.table:addColumn({name = "planet", width = shipdb.config.columns.planet, textColor = shipdb.config.colors.planet})
  shipdb.table:addColumn({name = "dock", width = shipdb.config.columns.dock, textColor = shipdb.config.colors.dock})
  shipdb.table:addColumn({name = "time", width = shipdb.config.columns.time, textColor = shipdb.config.colors.time})

  -- Add header row
  shipdb.table:addRow({
    {"type", [[shipdb.sortBy("type")]], "sort by type"},
    {"name", [[shipdb.sortBy("name")]], "sort by name"},
    {"owner", [[shipdb.sortBy("owner")]], "sort by owner"},
    {"planet", [[shipdb.sortBy("planet")]], "sort by planet"},
    {"dock", [[shipdb.sortBy("dock")]], "sort by dock"},
    {"time", [[shipdb.sortBy("time")]], "sort by time"}
  })

  -- Fetch docking records - either for specific ship or all records
  local records
  if shipdb.config.history_ship then
    -- Viewing history for a specific ship
    shipdb.debug("shipdb.updateHistoryView for: " .. shipdb.config.history_ship)
    records = db:fetch(shipdb.db.docking_records, {
      db:eq(shipdb.db.docking_records.character, gmcp.Char.Info.name),
      db:eq(shipdb.db.docking_records.name, shipdb.config.history_ship)
    })
  else
    -- Viewing all history
    shipdb.debug("shipdb.updateHistoryView for: ALL RECORDS")
    records = db:fetch(shipdb.db.docking_records,
      db:eq(shipdb.db.docking_records.character, gmcp.Char.Info.name)
    )
  end

  if not records then
    records = {}
  end

  -- Apply search filter to records
  local total_records = #records
  local filtered_records = shipdb.filterShips(records, shipdb.config.search_filter)
  local filtered_count = #filtered_records

  -- Sort records using the current sort settings
  table.sort(filtered_records, function(a, b)
    if shipdb.sort_by_invert < 0 then
      return a[shipdb.sort_by] < b[shipdb.sort_by]
    else
      return a[shipdb.sort_by] > b[shipdb.sort_by]
    end
  end)

  -- Update info label based on view type
  if shipdb.config.history_ship then
    -- Single ship history
    if #filtered_records > 0 then
      local first_record = filtered_records[1]
      if shipdb.config.search_filter ~= "" and filtered_count < total_records then
        shipdb.info_label:echo(string.format("Docking History: %s (%s) owned by %s - Showing %d of %d records",
          shipdb.config.history_ship, first_record.type, first_record.owner, filtered_count, total_records))
      else
        shipdb.info_label:echo(string.format("Docking History: %s (%s) owned by %s - %d records",
          shipdb.config.history_ship, first_record.type, first_record.owner, #filtered_records))
      end
    else
      shipdb.info_label:echo(string.format("Docking History: %s - No records found", shipdb.config.history_ship))
    end
  else
    -- All history view
    if shipdb.config.search_filter ~= "" and filtered_count < total_records then
      shipdb.info_label:echo(string.format("All Docking History - Showing %d of %d records", filtered_count, total_records))
    else
      shipdb.info_label:echo(string.format("All Docking History - %d records", total_records))
    end
  end

  -- Add each docking record with clickable filters
  for _, record in ipairs(filtered_records) do
    local filter_type = function() shipdb.setFilter(record.type) end
    local filter_name = function() shipdb.setFilter(record.name) end
    local filter_owner = function() shipdb.setFilter(record.owner) end
    local filter_planet = function() shipdb.setFilter(record.planet) end
    local filter_dock = function() shipdb.setFilter(record.dock) end
    local delete_record = function() shipdb.deleteDockingRecord(record) end

    shipdb.table:addRow({
      {record.type, {filter_type}, {"Filter by: " .. record.type}},
      {record.name, {filter_name, delete_record}, {"Filter by: " .. record.name, "Delete Record"}},
      {record.owner, {filter_owner}, {"Filter by: " .. record.owner}},
      {record.planet, {filter_planet}, {"Filter by: " .. record.planet}},
      {record.dock, {filter_dock}, {"Filter by: " .. record.dock}},
      record.time
    })
  end

  shipdb.table:assemble()
end

-- Register event handler for character changes (persistent, not one-shot)
if shipdb.eventid == nil then
  shipdb.eventid = registerAnonymousEventHandler("gmcp.Char.Info", shipdb.load)
  shipdb.debug("Registered event handler for gmcp.Char.Info")
end