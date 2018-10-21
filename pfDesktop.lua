pfDesktop = { }
pfDesktop_Storage = { }

-- slash cmd
SLASH_PFDE1 = '/pfde'
function SlashCmdList.PFDE(msg, editbox)
end

SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox)
  ReloadUI()
end

pfWM.config.close = "Interface\\AddOns\\pfDesktop\\img\\close"
pfWM.config.minimize = "Interface\\AddOns\\pfDesktop\\img\\min"
pfWM.config.maximize = "Interface\\AddOns\\pfDesktop\\img\\max"
pfWM.config.font = "Interface\\AddOns\\pfDesktop\\fonts\\PT-Sans-Narrow-Bold.ttf"
pfWM.config.fontmono = "Interface\\AddOns\\pfDesktop\\fonts\\Envy-Code-R.ttf"
pfWM.config.modkey = IsControlKeyDown
