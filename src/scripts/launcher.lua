-- ============================================================================
-- ShipdDB Plugin Registration
-- ============================================================================

-- Register ShipDB with the plugin dock
function shipdb.registerPlugin()
  if not (lotj and lotj.plugin and lotj.plugin.dock and lotj.plugin.dock.register) then 
    return 
  end

  lotj.plugin.dock.register("@PKGNAME@", {
  icon = getMudletHomeDir() .. '/@PKGNAME@/shipdb_icon.png',
  hoverIcon = getMudletHomeDir() .. '/@PKGNAME@/shipdb_icon_hover.gif',
  onClick = function()
    if shipdb.container.hidden then
      shipdb.show()
    else
      shipdb.hide()
    end
  end
  })
end

shipdb.registerPlugin()

-- Register event handler to clean up when package is uninstalled
registerAnonymousEventHandler("sysUninstallPackage", function(_, packageName)
  if packageName == "@PKGNAME@" then
      shipdb.hide()
      shipdb = nil
  end
end)