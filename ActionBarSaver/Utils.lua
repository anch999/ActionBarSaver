local ABS = ActionBarSaver

--returns current active spec
function ABS:GetSpecId()
    return SpecializationUtil.GetActiveSpecialization()
end

function ABS:GetSpecInfo(i)
    return SpecializationUtil.GetSpecializationInfo(i)
end

--loads the table of specs by checking if you know the spell for the spec that is associated with it
function ABS:PopulateSpecDB()
    if not self.charDB.Specs then self.charDB.Specs = {} end
    for i,v in ipairs(self.specSpells) do
        if CA_IsSpellKnown(v) and not self.charDB.Specs[i] then
            self.charDB.Specs[i] = {"No Selection", false}
        end
    end
end

--for a adding a divider to dew drop menus 
function ABS:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    self.dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end

function ABS.ACE:AutoLoadTimer()
    local spec = ABS.charDB.Specs[ABS:GetSpecId()]
    if spec[1] ~= "No Selection" and spec[1] ~=  "specDefault" then
        ABS:RestoreProfile(spec[1], ABS.class)
    elseif spec[1] ==  "specDefault" then
        ABS:RestoreProfile(ABS:GetSpecId(), ABS.class, "charDB")
    end
    ABS.specChanged = false
end

function ABS:AddGameTooltip(frame, text)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT", -(frame:GetWidth() / 2), 5)
    GameTooltip:AddLine(text)
    GameTooltip:Show()
end

function ABS:PairsByKeys(t)
    local a = {}
        for n in pairs(t) do
            table.insert(a, n)
        end
    table.sort(a)

    local i = 0
    local iter = function()
        i = i + 1
            if a[i] == nil then
                return nil
            else
                return a[i], t[a[i]]
            end
    end
    return iter
end

