local ABS = ActionBarSaver
local L = ABS.locals

--Borrowed from Atlas, thanks Dan!
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
 end

function ABS:OptionsToggle(cat)
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory(cat)
	end
end

function ABS:OptionsMenuInitialize()
    local info
	for i,_ in ipairs(ABS.charDB.Specs) do
		info = {
			text = ABS:GetSpecInfo(i),
			func = function() ABS:OpenOptions(this:GetID()) end,
		}
			UIDropDownMenu_AddButton(info)
	end
end

function ABS:UpdateProfileSelect()
	local num = 0
	local text
	local firstID
		for i, _ in ABS:PairsByKeys(self.db.sets[self.class]) do
			if not text then 
				text = i
				firstID = 1
			end
			num = num + 1
			if self.selectedProfile and i == self.selectedProfile then
				text = i
				firstID = num
				break
			end
		end
	if firstID == 1 then num = 1 end
	self.selectedProfile = text
	UIDropDownMenu_SetSelectedID(self.options.profileSelection, num)
	UIDropDownMenu_SetText(self.options.profileSelection, text)
end

function ABS:OpenOptions(id)
	local spec = self.charDB.Specs[id]
	UIDropDownMenu_SetSelectedID(self.options.specMenu, id)
	local num, text = 1, "No Selection"
	if spec then
		if spec and spec[1] ~= "No Selection" and spec[1] ~= "specDefault" then
			for i, _ in pairs(self.db.sets[self.class]) do
				num = num + 1
				if i == spec[1] then
					text = spec[1]
					break
				end
			end
		elseif spec[1] == "specDefault" then
			num = 2
			text = "Spec Default"
		else
			num = 1
		end
		self.options.autoSave:SetChecked(spec[2])
	end
	UIDropDownMenu_SetSelectedID(self.options.profileSelectionSpec, num)
	UIDropDownMenu_SetText(self.options.profileSelectionSpec, text)


	ABS:UpdateProfileSelect()

	UIDropDownMenu_SetText(self.options.specMenu, self:GetSpecInfo(id))

	self.options.checkCount:SetChecked(self.db.checkCount)
	self.options.macro:SetChecked(self.db.macro)
	self.options.restoreRank:SetChecked(self.db.restoreRank)
	
	self.options.specNum = id
end

function ABS:CreateOptionsUI()
	self.options = {}
--Creates the options frame and all its assets
	local options = self.options
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	options.frame = {}

	------------------------------ Main Panel ------------------------------
	options.frame.panel = CreateFrame("FRAME", "ActionBarSaverOptionsFrame", UIParent, nil)
    	local fstring = options.frame.panel:CreateFontString(options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("Action Bar Saver Settings")
		fstring:SetPoint("TOPLEFT", 30, -15)
		options.frame.panel.name = "ActionBarSaver"
		InterfaceOptions_AddCategory(options.frame.panel)

	options.checkCount = CreateFrame("CheckButton", nil, options.frame.panel, "UICheckButtonTemplate")
	options.checkCount:SetPoint("TOPLEFT", 30, -60)
	options.checkCount.lable = options.checkCount:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.checkCount.lable:SetJustifyH("LEFT")
	options.checkCount.lable:SetPoint("LEFT", 30, 0)
	options.checkCount.lable:SetText("Check item")
	options.checkCount:SetScript("OnClick", function() self.db.checkCount = not self.db.checkCount end)
	options.checkCount:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Toggles checking if you have the item in your inventory before restoring it, use if you have disconnect issues when restoring.") end)
    options.checkCount:SetScript("OnLeave", function() GameTooltip:Hide() end)

	options.macro = CreateFrame("CheckButton", "ActionBarSaver_Options_ShowOnMouseOver", options.frame.panel, "UICheckButtonTemplate")
	options.macro:SetPoint("TOPLEFT", 30, -95)
	options.macro.lable = options.macro:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.macro.lable:SetJustifyH("LEFT")
	options.macro.lable:SetPoint("LEFT", 30, 0)
	options.macro.lable:SetText("Restore macro")
	options.macro:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Attempts to restore macros that have been deleted for a profile.") end)
    options.macro:SetScript("OnLeave", function() GameTooltip:Hide() end)
	options.macro:SetScript("OnClick", function() self.db.macro = not self.db.macro end)

	options.restoreRank = CreateFrame("CheckButton", nil, options.frame.panel, "UICheckButtonTemplate")
	options.restoreRank:SetPoint("TOPLEFT", 380, -60)
	options.restoreRank.lable = options.restoreRank:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.restoreRank.lable:SetJustifyH("LEFT")
	options.restoreRank.lable:SetPoint("LEFT", 30, 0)
	options.restoreRank.lable:SetText("Restore rank")
	options.restoreRank:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Toggles if ABS should restore the highest rank of the spell, or the one saved originally.") end)
    options.restoreRank:SetScript("OnLeave", function() GameTooltip:Hide() end)
	options.restoreRank:SetScript("OnClick", function() self.db.options.restoreRank = not self.db.options.restoreRank end)
	
	options.hideMinimap = CreateFrame("CheckButton", nil, options.frame.panel, "UICheckButtonTemplate")
	options.hideMinimap:SetPoint("TOPLEFT", 380, -95)
	options.hideMinimap.lable = options.hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.hideMinimap.lable:SetJustifyH("LEFT")
	options.hideMinimap.lable:SetPoint("LEFT", 30, 0)
	options.hideMinimap.lable:SetText("Hide Minimap Icon")
	options.hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)
	options.hideMinimap:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Hides the minimap button.") end)
    options.hideMinimap:SetScript("OnLeave", function() GameTooltip:Hide() end)

--[[ 	options.txtSize = CreateFrame("Button", "ActionBarSaver_Options_TxtSize", options.frame.panel, "UIDropDownMenuTemplate")
	options.txtSize:SetPoint("TOPLEFT", 15, -130)
	options.txtSize.lable = options.txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.txtSize.lable:SetJustifyH("LEFT")
	options.txtSize.lable:SetPoint("LEFT", options.txtSize, 190, 0)
	options.txtSize.lable:SetText("Menu Text Size")
	options.txtSize:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Changes the default text size of map menus.") end)
    options.txtSize:SetScript("OnLeave", function() GameTooltip:Hide() end) ]]

	options.profileSelection = CreateFrame("Button", "ActionBarSaver_Options_profileSelection", options.frame.panel, "UIDropDownMenuTemplate")
	options.profileSelection:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 15, -200)
	options.profileSelection.lable = options.profileSelection:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.profileSelection.lable:SetJustifyH("LEFT")
	options.profileSelection.lable:SetPoint("LEFT", options.profileSelection, 190, 0)
	options.profileSelection.lable:SetText("Profile List")

	options.saveProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.saveProfile:SetSize(130,25)
    options.saveProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 30, -240)
    options.saveProfile:SetText("Save profile")
    options.saveProfile:SetScript("OnClick", function() ABS:SaveProfile(self.selectedProfile) end)

	options.restoreProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.restoreProfile:SetSize(130,25)
    options.restoreProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 160, -240)
    options.restoreProfile:SetText("Restore profile")
    options.restoreProfile:SetScript("OnClick", function() ABS:RestoreProfile(self.selectedProfile) end)

	options.renameProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.renameProfile:SetSize(130,25)
    options.renameProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 290, -240)
    options.renameProfile:SetText("Rename profile")
    options.renameProfile:SetScript("OnClick", function() StaticPopup_Show("ACTIONBARSAVER_RENAME_PROFILE") end)

	options.addProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.addProfile:SetSize(130,25)
    options.addProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 30, -275)
    options.addProfile:SetText("Add profile")
    options.addProfile:SetScript("OnClick", function() StaticPopup_Show("ACTIONBARSAVER_ADD_PROFILE") end)

	options.deleteProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.deleteProfile:SetSize(130,25)
    options.deleteProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 160, -275)
    options.deleteProfile:SetText("Delete Profile")
    options.deleteProfile:SetScript("OnClick", function() StaticPopup_Show("ACTIONBARSAVER_DELETE_PROFILE") end)
	
	------------------------------ Specialization Panel ------------------------------

	options.frame.specPanel = CreateFrame("FRAME", "ActionBarSaverOptionsFramespecPanel", UIParent, nil)
		local fstring = options.frame.specPanel:CreateFontString(options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("Specialization Settings")
		fstring:SetPoint("TOPLEFT", 30, -15)
		options.frame.specPanel.name = "Specializations"
		options.frame.specPanel.parent = "ActionBarSaver"
		InterfaceOptions_AddCategory(options.frame.specPanel)

	options.specMenu = CreateFrame("Button", "ActionBarSaver_Options_SpecMenu", options.frame.specPanel, "UIDropDownMenuTemplate")
    options.specMenu:SetPoint("TOPLEFT", 15, -60)
	options.specMenu.lable = options.specMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.specMenu.lable:SetJustifyH("LEFT")
	options.specMenu.lable:SetPoint("LEFT", options.specMenu, 190, 0)
	options.specMenu.lable:SetText("Select Specialization")
	options.specMenu:SetScript("OnClick", self.Options_UpateDB_OnClick)

	options.profileSelectionSpec = CreateFrame("Button", "ActionBarSaver_Options_profileSelectionSpec", options.frame.specPanel, "UIDropDownMenuTemplate")
	options.profileSelectionSpec:SetPoint("TOPLEFT", options.frame.specPanel, "TOPLEFT", 15, -95)
	options.profileSelectionSpec.lable = options.profileSelectionSpec:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.profileSelectionSpec.lable:SetJustifyH("LEFT")
	options.profileSelectionSpec.lable:SetPoint("LEFT", options.profileSelectionSpec, 190, 0)
	options.profileSelectionSpec.lable:SetText("Auto Load Profile")

	options.autoSave = CreateFrame("CheckButton", nil, options.frame.specPanel, "UICheckButtonTemplate")
	options.autoSave:SetPoint("TOPLEFT", 30, -130)
	options.autoSave.lable = options.autoSave:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.autoSave.lable:SetJustifyH("LEFT")
	options.autoSave.lable:SetPoint("LEFT", 30, 0)
	options.autoSave.lable:SetText("Auto save")
	options.autoSave:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Auto saves the specialization default profile") end)
	options.autoSave:SetScript("OnLeave", function() GameTooltip:Hide() end)
	options.autoSave:SetScript("OnClick", function() self.charDB.Specs[self.options.specNum][2] = not self.charDB.Specs[self.options.specNum][2] end)

	options.saveDefaultProfile = CreateFrame("Button", nil, options.frame.specPanel, "OptionsButtonTemplate")
    options.saveDefaultProfile:SetSize(130,25)
    options.saveDefaultProfile:SetPoint("TOPLEFT", options.frame.specPanel, "TOPLEFT", 30, -170)
    options.saveDefaultProfile:SetText("Save profile")
    options.saveDefaultProfile:SetScript("OnClick", function() ABS:SaveProfile(ABS:GetSpecId(), "charDB") end)
	options.saveDefaultProfile:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Saves the specialization default profile.") end)
    options.saveDefaultProfile:SetScript("OnLeave", function() GameTooltip:Hide() end)

	options.restoreDefaultProfile = CreateFrame("Button", nil, options.frame.specPanel, "OptionsButtonTemplate")
    options.restoreDefaultProfile:SetSize(130,25)
    options.restoreDefaultProfile:SetPoint("TOPLEFT", options.frame.specPanel, "TOPLEFT", 160, -170)
    options.restoreDefaultProfile:SetText("Restore profile")
    options.restoreDefaultProfile:SetScript("OnClick", function() ABS:RestoreProfile(ABS:GetSpecId(), ABS.class, "charDB") end)
	options.restoreDefaultProfile:SetScript("OnEnter", function(frame) self:AddGameTooltip(frame, "Restores the specialization default profile.") end)
    options.restoreDefaultProfile:SetScript("OnLeave", function() GameTooltip:Hide() end)

	end

	ABS:CreateOptionsUI()

	function ABS:OptionsProfileSelectionSpecOnClick(arg1)
		local thisID = this:GetID()
		UIDropDownMenu_SetSelectedID(ABS.options.profileSelectionSpec, thisID)
		ABS.charDB.Specs[ABS.options.specNum][1] = arg1
	end

	function ABS:OptionsProfileSelectionSpecInitialize()
		--Loads the spec list into the favorite1 dropdown menu
		local info
		info = {
			text = "No Selection",
			func = ABS.OptionsProfileSelectionSpecOnClick,
			arg1 = "No Selection",
		}
		UIDropDownMenu_AddButton(info)
		info = {
			text = "Spec Default",
			func = ABS.OptionsProfileSelectionSpecOnClick,
			arg1 = "specDefault",
		}
			UIDropDownMenu_AddButton(info)
		for name,_ in ABS:PairsByKeys(ABS.db.sets[ABS.class]) do
			info = {
						text = name,
						func = ABS.OptionsProfileSelectionSpecOnClick,
						arg1 = name,
					}
						UIDropDownMenu_AddButton(info)
		end
	end

	function ABS:OptionsProfileSelectionOnClick(arg1)
		local thisID = this:GetID()
		UIDropDownMenu_SetSelectedID(ABS.options.profileSelection, thisID)
		ABS.charDB.Specs[ABS.options.specNum][1] = arg1
		ABS.selectedProfile = arg1
	end

	function ABS:OptionsProfileSelectionInitialize()
		--Loads the spec list into the favorite1 dropdown menu
		local info

		for name,_ in ABS:PairsByKeys(ABS.db.sets[ABS.class]) do
			info = {
						text = name,
						func = ABS.OptionsProfileSelectionOnClick,
						arg1 = name,
					}
					UIDropDownMenu_AddButton(info)
		end
	end

	function ABS:OptionsTxtMenuInitialize()
		local info
			for i = 10, 25 do
				info = {
					text = i;
					func = function()
						ABS.db.txtSize = i
						local thisID = this:GetID()
						UIDropDownMenu_SetSelectedID(ABS.db.txtSize, thisID)
					end;
				};
					UIDropDownMenu_AddButton(info)
			end
		end

	function ABS:OptionsDropDownInitialize()
		--Setup for Dropdown menus in the settings
		UIDropDownMenu_Initialize(self.options.specMenu, self.OptionsMenuInitialize)
		UIDropDownMenu_SetSelectedID(self.options.specMenu)
		UIDropDownMenu_SetWidth(self.options.specMenu, 150)

		UIDropDownMenu_Initialize(self.options.profileSelectionSpec, self.OptionsProfileSelectionSpecInitialize)
		UIDropDownMenu_SetSelectedID(self.options.profileSelectionSpec)
		UIDropDownMenu_SetWidth(self.options.profileSelectionSpec, 150)
		
		UIDropDownMenu_Initialize(self.options.profileSelection, self.OptionsProfileSelectionInitialize)
		UIDropDownMenu_SetSelectedID(self.options.profileSelection)
		UIDropDownMenu_SetWidth(self.options.profileSelection, 150)

		ABS:OpenOptions(self:GetSpecId())
	end

function ABS:RenameProfile(old, new)
	new = string.trim(new or "")
	old = string.trim(old or "")

	if( new == old ) then
		self:Print(string.format(L["You cannot rename \"%s\" to \"%s\" they are the same profile names."], old, new))
		return
	elseif( new == "" ) then
		self:Print(string.format(L["No name specified to rename \"%s\" to."], old))
		return
	elseif( self.db.sets[self.class][new] ) then
		self:Print(string.format(L["Cannot rename \"%s\" to \"%s\" a profile already exists for %s."], old, new, (UnitClass("player"))))
		return
	elseif( not self.db.sets[self.class][old] ) then
		self:Print(string.format(L["No profile with the name \"%s\" exists."], old))
		return
	end

	self.db.sets[self.class][new] = CopyTable(self.db.sets[self.class][old])
	self.db.sets[self.class][old] = nil

	self:Print(string.format(L["Renamed \"%s\" to \"%s\""], old, new))
	return true
end

	--[[
StaticPopupDialogs["ACTIONBARSAVER_ADD_NEW_PROFILE"]
Adds new profile
]]
StaticPopupDialogs["ACTIONBARSAVER_ADD_PROFILE"] = {
	text = "Add and save current bars as new profile",
	button1 = "Add Profile",
	button2 = "Cancel",
	OnShow = function(self)
		self:SetFrameStrata("TOOLTIP")
	end,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		if not ABS.db.sets[ABS.class][text] then
			ABS:SaveProfile(text)
		else
			ABS:Print(string.format("Cannot add "..text.." as a profile of that name already exists"))
		end
	end,
	hasEditBox = 1,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

	--[[
StaticPopupDialogs["ACTIONBARSAVER_RENAME_PROFILE"]
Renames current selected profile
]]
StaticPopupDialogs["ACTIONBARSAVER_RENAME_PROFILE"] = {
	text = "Rename the currently selected profile",
	button1 = "Rename Profile",
	button2 = "Cancel",
	OnShow = function(self)
		self:SetFrameStrata("TOOLTIP")
		self.editBox:SetText(ABS.selectedProfile)
	end,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		local success = ABS:RenameProfile(ABS.selectedProfile, text)
		if success then
			ABS.selectedProfile = text
			ABS:UpdateProfileSelect()
		end
	end,
	hasEditBox = 1,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

	--[[
StaticPopupDialogs["ACTIONBARSAVER_RENAME_PROFILE"]
Renames current selected profile
]]
StaticPopupDialogs["ACTIONBARSAVER_DELETE_PROFILE"] = {
	text = "Are you sure you want to delete this proflie?",
	button1 = "Delete Profile",
	button2 = "Cancel",
	OnShow = function(self)
		self:SetFrameStrata("TOOLTIP")
	end,
	OnAccept = function()
		ABS:Print("Deleted saved profile "..ABS.selectedProfile..".")
		ABS.db.sets[ABS.class][ABS.selectedProfile] = nil
		ABS:UpdateProfileSelect()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

