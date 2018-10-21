-- pfWM - pfWindowManager

-- pfWM:CreateWindow(name, width, height, show, fixed)
-- name: frame name
-- width: width
-- height: height
-- show: shown by default
-- fixed: not resizable

-- window:SetFocus()
-- window:Maximize()
-- window:Minimize()
-- window:AddFrame()

pfWM = { config = {} }

-- setup default vars
pfWM.config.spacing = 5
pfWM.config.color1 = {  0,  0,  0, .5 } -- background
pfWM.config.color2 = { .2, .2, .2,  1 }  -- border
pfWM.config.color3 = { .2,  1, .8,  1 }  -- hover

pfWM.config.backdrop = {
  bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0,
  edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}

pfWM.config.font = "Fonts\\ARIALN.TTF"
pfWM.config.fontmono = "Fonts\\ARIALN.TTF"
pfWM.config.fontsize = 10
pfWM.config.fontsizemono = 10
pfWM.config.fontopts = "NORMAL"

pfWM.config.modkey = IsControlKeyDown

local function MouseHandler(button, frame, force)
  if frame.max then return end

  if force or ( pfWM.config.modkey() and button == "LeftButton") then
    frame:StartMoving()
  elseif pfWM.config.modkey() and button == "RightButton" and frame:IsResizable() then
    frame:StartSizing()
  else
    frame:SetFocus()
  end
end

local function AddFrame(self, frame, setparent)
  frame:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
  frame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
  if setparent then frame:SetParent(self) end
end

local function AddEvent(self, event, func)
  self["_" .. event] = self[event]
  self[event] = function(a1,a2,a3,a4,a5,a6,a7,a8,a9)

    local env = {}
    setmetatable(env, {__index = getfenv(0)})
    env.event = event
    setfenv(func, env)

    func(a1,a2,a3,a4,a5,a6,a7,a8,a9)
    self["_" .. event](a1,a2,a3,a4,a5,a6,a7,a8,a9)
  end
end

local function SetFocus(self)
  self:Raise()
  self.title:Raise()
end

local function Maximize(self)
  -- prevent fixed windows from being maximized
  if not self:IsResizable() then return end

  -- if minimized, restore window and exit
  if not self:IsShown() then self:Minimize() return end

  -- frame: window decoration frame
  if not self.max then
    self.max = true
    self.width = self:GetWidth()
    self.height = self:GetHeight()

    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", nil, "TOPLEFT", -2, -4)
    self:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", -1, 1)
    self:SetWidth(GetScreenWidth()*UIParent:GetScale())
    self:SetHeight(GetScreenHeight()*UIParent:GetScale())
    self:SetBackdropBorderColor(0,0,0,0)
  else
    self.max = nil
    self:ClearAllPoints()
    self:SetPoint("CENTER", 0, 0)
    self:SetWidth(self.width)
    self:SetHeight(self.height)
    self:SetBackdropBorderColor(unpack(pfWM.config.color2))
  end
end

local function Minimize()
  if self:IsShown() then
    self:Hide()
  else
    self:Show()
  end
end


local function CreateTitleBar(name, parent)
  local frame = CreateFrame("Button", name .. "TitleBar", parent)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
  frame:SetToplevel(true)
  frame:SetHeight(22)

  -- Window Caption
  frame.caption = frame:CreateFontString("Status", "DIALOG", "GameFontNormal")
  frame.caption:SetAllPoints(frame)
  frame.caption:SetFontObject(GameFontWhite)
  frame.caption:SetFont(pfWM.config.font, pfWM.config.fontsize, pfWM.config.fontopts)
  frame.caption:SetJustifyH("LEFT")
  frame.caption:SetJustifyV("CENTER")
  frame.caption:SetText("  " .. name)

  local tex = frame:CreateTexture(nil, "MEDIUM")
  tex:SetPoint("TOPLEFT", 1,-1)
  tex:SetPoint("BOTTOMRIGHT", -1,1)
  tex:SetTexture(1,1,1,1)
  tex:SetGradientAlpha("HORIZONTAL", 0,0,0,.8, 0,0,0,0)

  local tex = frame:CreateTexture(nil, "MEDIUM")
  tex:SetPoint("TOPLEFT", 1,-1)
  tex:SetPoint("BOTTOMRIGHT", -1,1)
  tex:SetTexture(1,1,1,1)
  tex:SetGradientAlpha("HORIZONTAL", 0,0,0,0, 0,0,0,.8)

  local tex = frame:CreateTexture(nil, "BACKGROUND")
  tex:SetPoint("TOPLEFT", 1,-1)
  tex:SetPoint("BOTTOMRIGHT", -1, 1)
  tex:SetTexture(1,1,1,1)
  tex:SetGradientAlpha("VERTICAL", 0,0,0,0, .4,.4,.4,.8)

  frame:SetScript("OnMouseDown",function()
    MouseHandler(arg1, parent, true)
  end)

  frame:SetScript("OnMouseUp",function()
    parent:StopMovingOrSizing()
  end)

  frame:SetScript("OnDoubleClick", function()
    parent:Maximize()
  end)

  -- close
  frame.close = CreateFrame("Button", nil, frame)
  frame.close.tex = frame.close:CreateTexture(nil, "OVERLAY")
  frame.close.tex:SetAllPoints()
  frame.close.tex:SetTexture(pfWM.config.close)
  frame.close.tex:SetVertexColor(.84, .34, .36)
  frame.close:SetPoint("TOPRIGHT", -8, -3)
  frame.close:SetWidth(16)
  frame.close:SetHeight(16)
  frame.close:SetScript("OnClick", function()
    parent:Hide()
  end)

  frame.close:SetScript("OnEnter", function()
    this.tex:SetVertexColor(.8, .47, .49)
  end)

  frame.close:SetScript("OnLeave", function()
    this.tex:SetVertexColor(.84, .34, .36)
  end)

  if parent:IsResizable() then
    -- max
    frame.max = CreateFrame("Button", nil, frame)
    frame.max.tex = frame.max:CreateTexture(nil, "OVERLAY")
    frame.max.tex:SetAllPoints()
    frame.max.tex:SetTexture(pfWM.config.maximize)
    frame.max:SetPoint("TOPRIGHT", -32, -3)
    frame.max:SetWidth(16)
    frame.max:SetHeight(16)
    frame.max:SetScript("OnClick", function()
      parent:Maximize()
    end)

    -- min
    frame.min = CreateFrame("Button", nil, frame)
    frame.min.tex = frame.min:CreateTexture(nil, "OVERLAY")
    frame.min.tex:SetAllPoints()
    frame.min.tex:SetTexture(pfWM.config.minimize)
    frame.min:SetPoint("TOPRIGHT", -56, -3)
    frame.min:SetWidth(16)
    frame.min:SetHeight(16)
    frame.min:SetScript("OnClick", function()
      parent:Minimize()
    end)
  end

  return frame
end

function pfWM:CreateWindow(name, width, height, show, fixed)
  local frame = CreateFrame("Frame", "pfWM" .. name, nil)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  frame:SetPoint("CENTER", 0, 0)
  frame:SetWidth(width)
  frame:SetHeight(height)
  frame:SetBackdrop(pfWM.config.backdrop)
  frame:SetBackdropColor(0,0,0,0)
  frame:SetBackdropBorderColor(unpack(pfWM.config.color2))
  frame:SetMovable(true)

  frame.SetFocus = SetFocus
  frame.Minimize = Minimize
  frame.Maximize = Maximize
  frame.AddFrame = AddFrame
  frame.AddEvent = AddEvent

  if fixed then
    frame:SetResizable(false)
  else
    frame:SetResizable(true)
  end

  frame:SetScript("OnMouseDown",function()
    MouseHandler(arg1, this)
  end)

  frame:SetScript("OnMouseUp",function()
    this:StopMovingOrSizing()
  end)

  frame:SetScript("OnUpdate", function()
    if pfWM.config.modkey() and this.mode ~= "WM_MODE" then
      this.mode = "WM_MODE"
      this.title:Show()
      this:EnableMouse(true)
    elseif not pfWM.config.modkey() and this.mode ~= "DEFAULT_MODE" then
      this.mode = "DEFAULT_MODE"
      this.title:Hide()
      this:StopMovingOrSizing()
      this:EnableMouse(false)
    end
  end)

  frame.movable = frame

  frame.title = CreateTitleBar(name, frame)

  if not show then
    frame:Hide()
    frame.title:Hide()
  end

  return frame
end
