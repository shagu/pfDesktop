local panel = CreateFrame("Frame", "panel", nil)
panel:SetFrameStrata("FULLSCREEN_DIALOG")
panel:SetHeight(1)
panel:SetAlpha(0)

panel:SetPoint("BOTTOMLEFT", 0, 0)
panel:SetPoint("BOTTOMRIGHT", 0, 0)
panel:EnableMouse(true)

panel.bg = panel:CreateTexture("panelTexture", "LOW")
panel.bg:SetTexture(.1,.1,.1)
panel.bg:SetAllPoints(panel)

panel.border = panel:CreateTexture("panelTexture", "MEDIUM")
panel.border:SetTexture(.2,.2,.2)
panel.border:SetPoint("TOPLEFT", 0, 1)
panel.border:SetPoint("TOPRIGHT", 0, 1)
panel.border:SetHeight(1)

panel.clock = panel:CreateFontString(nil, "OVERLAY")
panel.clock:SetPoint("RIGHT", -5, 0)
panel.clock:SetFontObject(GameFontWhite)
panel.clock:SetJustifyH("RIGHT")

panel:SetScript("OnUpdate", function()
  this.clock:SetText(date("%H:%M:%S"))

  if pfDesktop.worldframe and pfDesktop.worldframe.max then
    pfDesktop.worldframe:SetPoint("BOTTOM", this, "TOP", 0, 0)

    if MouseIsOver(this, 0, 0, 0, 0) or pfWM.config.modkey() then
      if this:GetHeight() >= 23 then
        this:SetAlpha(.8)
        this:SetHeight(24)
      else
        this:SetHeight(this:GetHeight()+3)
        this:SetAlpha(this:GetAlpha()+.1)
      end
    else
      if this:GetHeight() <= 1 then
        this:SetAlpha(0)
        this:SetHeight(1)
      else
        this:SetHeight(this:GetHeight()-3)
        this:SetAlpha(this:GetAlpha()-.1)
      end
    end
  else
    this:SetAlpha(1)
    this:SetHeight(24)
    return
  end
end)

local appcount = 0
function panel:AddApplication(name, icon, func)
  local app = CreateFrame("Button", nil, panel)
  app:SetAlpha(panel:GetAlpha())
  app:SetScript("OnClick", func)
  app:SetPoint("LEFT", appcount*24, 0)
  app:SetHeight(22)
  app:SetWidth(22)
  app:SetBackdrop(pfWM.config.backdrop)
  app:SetBackdropColor(unpack(pfWM.config.color1))
  app:SetBackdropBorderColor(unpack(pfWM.config.color2))
  app.tex = app:CreateTexture(nil, "OVERLAY")
  app.tex:SetAllPoints()
  app.tex:SetTexture(icon) 
  
  appcount = appcount + 1
end

pfDesktop.panel = panel
