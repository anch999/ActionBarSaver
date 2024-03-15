local ABS = ActionBarSaver

local defIcon = "Interface\\Icons\\inv_misc_book_16"
local icon = LibStub('LibDBIcon-1.0')

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("ActionBarSaver", {
    type = 'data source',
    text = "ActionBarSaver",
    icon = defIcon,
  })

local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function minimap.OnEnter(self)
    GameTooltip:SetOwner(self, 'ANCHOR_NONE')
    GameTooltip:SetPoint(GetTipAnchor(self))
    GameTooltip:ClearLines()
    GameTooltip:AddLine("ActionBarSaver")
    GameTooltip:AddLine("Left click main options")
    GameTooltip:AddLine("Right click specialization options")
    GameTooltip:Show()
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if button == "LeftButton" then
        ABS:OptionsToggle("ActionBarSaver")
    elseif button == "RightButton" then
        ABS:OptionsToggle("Specializations")
    end
end

function ABS:ToggleMinimap()
    local hide = not self.db.minimap
    self.db.minimap = hide
    if hide then
      icon:Hide("ActionBarSaver")
    else
      icon:Show("ActionBarSaver")
    end
end

function ABS:InitializeMinimap()
    if icon then
        self.minimap = {hide = self.db.minimap}
        icon:Register("ActionBarSaver", minimap, self.minimap)
    end
end