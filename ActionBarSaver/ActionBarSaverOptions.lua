local ABS = ActionBarSaver

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
	if spec[1] ~= "No Selection" and spec[1] ~= "specDefault" then
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

	UIDropDownMenu_SetSelectedID(self.options.profileSelectionSpec, num)
	UIDropDownMenu_SetText(self.options.profileSelectionSpec, text)


	ABS:UpdateProfileSelect()

	UIDropDownMenu_SetText(self.options.specMenu, self:GetSpecInfo(id))

	self.options.checkCount:SetChecked(self.db.checkCount)
	self.options.macro:SetChecked(self.db.macro)
	self.options.restoreRank:SetChecked(self.db.restoreRank)
	self.options.autoSave:SetChecked(spec[2])
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

	options.editProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.editProfile:SetSize(130,25)
    options.editProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 290, -240)
    options.editProfile:SetText("Edit profile")
    options.editProfile:SetScript("OnClick", function()  end)

	options.addProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.addProfile:SetSize(130,25)
    options.addProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 30, -275)
    options.addProfile:SetText("Add profile")
    options.addProfile:SetScript("OnClick", function()  end)

	options.deleteProfile = CreateFrame("Button", nil, options.frame.panel, "OptionsButtonTemplate")
    options.deleteProfile:SetSize(130,25)
    options.deleteProfile:SetPoint("TOPLEFT", options.frame.panel, "TOPLEFT", 160, -275)
    options.deleteProfile:SetText("Delete Profile")
    options.deleteProfile:SetScript("OnClick", function()
		self.db.sets[self.class][self.selectedProfile] = nil
		ABS:UpdateProfileSelect()
	end)

	
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
	------------------------------ Panel 3 ------------------------------

	--[[ options.hideMenu = CreateFrame("CheckButton", nil, options.frame.panel, "UICheckButtonTemplate")
	options.hideMenu:SetPoint("TOPLEFT", 30, -60)
	options.hideMenu.lable = options.hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.hideMenu.lable:SetJustifyH("LEFT")
	options.hideMenu.lable:SetPoint("LEFT", 30, 0)
	options.hideMenu.lable:SetText("Hide Main Menu")
	options.hideMenu:SetScript("OnClick", function()
		if self.db.hideMenu then
			SpecMenuFrame:Show()
			self.db.hideMenu = false
		else
			SpecMenuFrame:Hide()
			self.db.hideMenu = true
		end
	end)

	options.onlyShowOnMouseOver = CreateFrame("CheckButton", "ActionBarSaver_Options_ShowOnMouseOver", options.frame.panel, "UICheckButtonTemplate")
	options.onlyShowOnMouseOver:SetPoint("TOPLEFT", 30, -95)
	options.onlyShowOnMouseOver.lable = options.onlyShowOnMouseOver:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.onlyShowOnMouseOver.lable:SetJustifyH("LEFT")
	options.onlyShowOnMouseOver.lable:SetPoint("LEFT", 30, 0)
	options.onlyShowOnMouseOver.lable:SetText("Only show menu button on mouse over")
	options.onlyShowOnMouseOver:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 5)
        GameTooltip:AddLine("Only shows the main menu button on mouse over")
        GameTooltip:Show()
    end)
    options.onlyShowOnMouseOver:SetScript("OnLeave", function() GameTooltip:Hide() end)
	options.onlyShowOnMouseOver:SetScript("OnClick", function()
		if self.db.ShowMenuOnHover then
			SpecMenuFrame_Menu:Show()
            SpecMenuFrame_Favorite:Show()
            SpecMenuFrame.icon:Show()
			SpecMenuFrame.Text:Show()
			self.db.ShowMenuOnHover = false
		else
			SpecMenuFrame_Menu:Hide()
            SpecMenuFrame_Favorite:Hide()
            SpecMenuFrame.icon:Hide()
			SpecMenuFrame.Text:Hide()
			self.db.ShowMenuOnHover = true
		end

	end)

	options.autoMenu = CreateFrame("CheckButton", nil, options.frame.panel, "UICheckButtonTemplate")
	options.autoMenu:SetPoint("TOPLEFT", 30, -130)
	options.autoMenu.lable = options.autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	options.autoMenu.lable:SetJustifyH("LEFT")
	options.autoMenu.lable:SetPoint("LEFT", 30, 0)
	options.autoMenu.lable:SetText("Auto open menu of mouse over")
	options.autoMenu:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 5)
        GameTooltip:AddLine("Auto opens the menu when you mouse over the button. \nHolding alt will open the enchant specs menu")
        GameTooltip:Show()
    end)
    options.autoMenu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	options.autoMenu:SetScript("OnClick", function() self.db.options.autoMenu = not self.db.options.autoMenu end) ]]

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

--[[ 		UIDropDownMenu_Initialize(self.options.txtSize, self.OptionsTxtMenuInitialize)
		UIDropDownMenu_SetSelectedID(self.options.txtSize)
		UIDropDownMenu_SetText(self.options.txtSize, self.db.txtSize)
		UIDropDownMenu_SetWidth(self.options.txtSize, 150) ]]

		UIDropDownMenu_Initialize(self.options.profileSelectionSpec, self.OptionsProfileSelectionSpecInitialize)
		UIDropDownMenu_SetSelectedID(self.options.profileSelectionSpec)
		UIDropDownMenu_SetWidth(self.options.profileSelectionSpec, 150)
		
		UIDropDownMenu_Initialize(self.options.profileSelection, self.OptionsProfileSelectionInitialize)
		UIDropDownMenu_SetSelectedID(self.options.profileSelection)
		UIDropDownMenu_SetWidth(self.options.profileSelection, 150)

		ABS:OpenOptions(self:GetSpecId())
	end

	InterfaceOptionsFrame:HookScript("OnShow", function()
		if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
		if InterfaceOptionsFrame and ABS.options.frame.panel:IsVisible() then
			ABS:OpenOptions(ABS:GetSpecId())
		end
	end)