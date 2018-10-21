local function strsplit(delimiter, subject)
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
  return unpack(fields)
end

local function CreateTextPopup(title)
  local f = CreateFrame("Frame")
  f:Hide()
  local t = f:CreateTexture(nil, "BACKGROUND")
  t:SetAllPoints()
  t:SetTexture(0,0,0,.8)

  f.count = 0
  f.maxwidth = 0

  f.title = f:CreateFontString(nil, "OVERLAY")
  f.title:SetPoint("TOPLEFT", 4, -5)
  f.title:SetFontObject(GameFontWhite)
  f.title:SetFont(pfWM.config.font, pfWM.config.fontsize, pfWM.config.fontopts)
  f.title:SetJustifyH("LEFT")
  f.title:SetTextColor(1,.8,.2,1)
  f.title:SetText(title)

  f.lines = {}
  f.AddLine = function(self, text)
    table.insert(self.lines, text)
  end

  f:SetScript("OnShow", function()

    this.maxwidth = this.title:GetStringWidth()

    for id, line in pairs(this.lines) do
      this.count = this.count + 1
      this:SetHeight(30 + pfWM.config.fontsize + 2)
      
      local text = this:CreateFontString(nil, "OVERLAY")
      text:SetFontObject("GameFontWhite")
      text:SetFont(pfWM.config.font, pfWM.config.fontsize, pfWM.config.fontopts)
      text:SetPoint("TOPLEFT", 5, -this.count*(pfWM.config.fontsize+4)-10)
      text:SetText(line)
      this.maxwidth = this.maxwidth > text:GetStringWidth() and this.maxwidth or text:GetStringWidth()
    end 

    f:SetHeight((this.count+1)*(pfWM.config.fontsize+4)+12)
    f:SetWidth(this.maxwidth + 15)

    f.window:SetWidth(f:GetWidth())
    f.window:SetHeight(f:GetHeight())
  end)

  f.window = pfWM:CreateWindow(title, 400, 200, true, true)
  f.window:SetMinResize(160, 60)
  f.window:AddFrame(f, true)
  
  return f
end

local eventmonitor = CreateFrame("Frame", "eventmonitor")
eventmonitor:SetFrameStrata("FULLSCREEN_DIALOG")
eventmonitor.bg = eventmonitor:CreateTexture(nil, "BACKGROUND")
eventmonitor.bg:SetAllPoints()
eventmonitor.bg:SetTexture(0,0,0,.8)
eventmonitor:RegisterAllEvents()
eventmonitor:SetScript("OnEvent", function()
  local count = 0
  local debuglink = "|H" .. event .. ":"
  local append = ""

  for i=1,30 do
    if getglobal("arg" .. i) then
      local text = tostring(getglobal("arg" .. i))
      if text == "" then text = "|cff555555nil|r" end
      text = string.gsub(text, ":",'⬥')
      text = string.gsub(text, "|",'⬦')
      debuglink = debuglink .. text .. ":"
      count = i
    end
  end

  if count > 0 then
    append = "|cff33ffcc" .. debuglink .. "|h[" .. count .. "]|h|r"
  end

  eventmonitor.messages:AddMessage("|cff555555" .. date("%H:%M:%S") .. "|r " .. event .. append .. "\n")
end)

eventmonitor.window = pfWM:CreateWindow("Event Monitor", 400, 200, false)
eventmonitor.window:SetMinResize(160, 60)
eventmonitor.window:AddFrame(eventmonitor, true)

eventmonitor.messages = CreateFrame("ScrollingMessageFrame", nil, eventmonitor)
eventmonitor.messages:SetBackdropColor(0,0,0,.35)
eventmonitor.messages:SetPoint("TOPLEFT", 5, -5)
eventmonitor.messages:SetPoint("BOTTOMRIGHT", -5, 5)
eventmonitor.messages:SetFontObject(GameFontWhite)
eventmonitor.messages:SetFont(pfWM.config.fontmono, pfWM.config.fontsizemono, pfWM.config.fontopts)
eventmonitor.messages:SetMaxLines(150)
eventmonitor.messages:SetJustifyH("LEFT")
eventmonitor.messages:SetFading(false)
eventmonitor.messages:SetScript("OnHyperlinkClick", function()
  local popup
  for num, text in ({ strsplit(":", arg1) }) do
    if num ~= 1 then
      text = string.gsub(text, '⬥', ":")
      text = string.gsub(text, '⬦', "|")

      popup:AddLine("|cff33ffccArgument " .. num -1 .. ":|r|cffffffff " .. text)
    else
      popup = CreateTextPopup(text)
    end
  end

  popup:Show()
  popup.window:SetFocus()
end)

if pfDesktop.panel then
  pfDesktop.panel:AddApplication(
    "Event Monitor", 
    "Interface\\AddOns\\pfDesktop\\icons\\eventmonitor", 
    function() pfDesktop.eventmonitor.window:Show() end
  )
end 

pfDesktop.eventmonitor = eventmonitor
