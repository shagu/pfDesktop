local worldframe = pfWM:CreateWindow("World of Warcraft", 500, 500, true, nil)
worldframe:AddFrame(WorldFrame)
worldframe:AddFrame(UIParent)


local maximizeOnLoad = CreateFrame("Frame")
maximizeOnLoad:RegisterEvent("PLAYER_ENTERING_WORLD")
maximizeOnLoad:SetScript("OnEvent", function()
  worldframe:Maximize()
end)

local function OnEvent()
  if this.scale_cache then
    local scale = ( worldframe:GetWidth()/worldframe:GetScale() * this.scale_cache ) / ( GetScreenWidth()*UIParent:GetScale())
    UIParent:SetScale(scale)
  else
    this.scale_cache = floor(UIParent:GetScale()*1000)/1000
  end
end

worldframe:AddEvent("StartMoving", OnEvent)
worldframe:AddEvent("StartSizing", OnEvent)
worldframe:AddEvent("StopMovingOrSizing", OnEvent)

pfDesktop.worldframe = worldframe
