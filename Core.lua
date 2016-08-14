local SLDataText = LibStub("AceAddon-3.0"):NewAddon("SLDataText", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local broker = LibStub("LibDataBroker-1.1")
local objects = {}
local db

local debugOn = true
local function Debug(msg)
	if ( debugOn ) then
		ChatFrame1:AddMessage(msg)
	end
end

local function fadeIn(frame)
	frame:Show()
	if ( frame:GetAlpha() == 0 ) then
		local step = 0.05
		frame:SetScript("OnUpdate", function(self, elapsed)
			if ( frame:GetAlpha() < 1.0 ) then
				frame:SetAlpha(frame:GetAlpha()+step)
			elseif ( frame:GetAlpha() == 1.0 ) then
				frame:SetScript("OnUpdate", nil)
			end
		end)
	end
end

local function fadeOut(frame)
	if ( frame:GetAlpha() > 0 ) then
		local step = 0.05
		frame:SetScript("OnUpdate", function(self, elapsed)
			if ( frame:GetAlpha() <= 1.0 and frame:GetAlpha() ~= 0 ) then
				frame:SetAlpha(frame:GetAlpha()-step)
			elseif ( frame:GetAlpha() == 0 ) then
				frame:Hide()
				frame:SetScript("OnUpdate", nil)
			end
		end)
	end
end

local function outCombat()
	for key, val in SLDataText:IterateModules() do
		if ( val:IsEnabled() and db.hideInCombat and not val.db.profile.noCombatHide ) then --( val:IsEnabled() and
			fadeIn(val.frame)
		end
	end
end

local function inCombat()
	for key, val in SLDataText:IterateModules() do
		if ( val:IsEnabled() and db.hideInCombat and not val.db.profile.noCombatHide ) then
			fadeOut(val.frame)
		end
	end
end

function SLDataText:GetColor()
	local color
	if ( db.gColorClass ) then
		local class = select(2, UnitClass("player"))
		local classColors = {
			["DEATHKNIGHT"] = "c41f3b",
			["DEMONHUNTER"] = "a330c9",
			["DRUID"] = "ff7d0a",
			["HUNTER"] = "abd473",
			["MAGE"] = "69ccf0",
			["PALADIN"] = "f58cba",
			["PRIEST"] = "ffffff",
			["ROGUE"] = "fff569",
			["SHAMAN"] = "2459ff",
			["WARLOCK"] = "9482ca",
			["WARRIOR"] = "c79c6e",
			["MONK"] = "00ff96", --// FAN-UPDATE Karaswa (Monk added)
		}
		color = classColors[class]
	else
		color = db.gColor
	end
	return color
end

function SLDataText:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("SLDTDB")
	self.db:RegisterDefaults({
		profile = {
			locked = true,
			hideInCombat = false,
			classColored = true,
			gFont = "Arial Narrow",
			gFontSize = 12,
			gColor = "ffffff",
			gColorClass = false,
			modules = {
				['*'] = true,
			},
		},
	})
	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh")
	db = self.db.profile
	self:BuildConfig()
end

function SLDataText:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", outCombat)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", inCombat)

	for key, val in self:IterateModules() do
		if ( self:GetModuleEnabled(key) and not val:IsEnabled() ) then
			self:EnableModule(key)
		end
	end

	for name, obj in broker:DataObjectIterator() do
		tinsert(objects, { name, obj })
		self:SetupObjects(name, obj)
	end
end

function SLDataText:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	for key, val in self:IterateModules() do
		if ( self:GetModuleEnabled(key) and val:IsEnabled() ) then
			self:DisableModule(key)
		end
	end
end

function SLDataText:Refresh()
	db = self.db.profile
	for key, val in self:IterateModules() do
		if ( self:GetModuleEnabled(key) and not val:IsEnabled() ) then
			self:EnableModule(key)
		elseif ( not self:GetModuleEnabled(key) and val:IsEnabled() ) then
			self:DisableModule(key)
		end
		if ( type(val.Refresh) == "function" and val:IsEnabled() ) then
			val:Refresh()
			self:RefreshModule(val)
		end
	end
end

function SLDataText:GetModuleEnabled(module)
	return db.modules[module]
end

function SLDataText:SetModuleEnabled(module, value)
	local old = db.modules[module]
	db.modules[module] = value
	if ( old ~= value ) then
		if ( value ) then
			self:EnableModule(module)
		else
			self:DisableModule(module)
		end
	end
end

local function getFontInfo(module)
	local modDB = module.db.profile
	local font, size
	if ( modDB.useGlobalFont ) then font = media:Fetch("font", db.gFont) else font = media:Fetch("font", modDB.fontFace) end
	if ( modDB.useGlobalFontSize ) then size = db.gFontSize else size = modDB.fontSize end
	return font, size
end

local function TranslateCoords(module, aF, x, y)
	local just = module.db.profile.justify
	local y1, x1
	if      ( aF == "TOP" or aF == "TOPLEFT" or aF == "TOPRIGHT" ) then                               y1 = module.frame:GetHeight()/2; y = y - y1
	elseif  ( aF == "BOTTOM" or aF == "BOTTOMLEFT" or aF == "BOTTOMRIGHT" ) then                      y1 = module.frame:GetHeight()/2; y = y + y1 end
	if      ( just == "RIGHT" and (aF == "TOPRIGHT" or aF == "RIGHT" or aF == "BOTTOMRIGHT") ) then   x = x
	elseif  ( just == "RIGHT" and (aF == "TOPLEFT" or aF == "LEFT" or aF == "BOTTOMLEFT") ) then      x1 = module.frame:GetWidth(); x = x + x1
	elseif  ( just == "RIGHT" and (aF == "CENTER" or aF == "TOP" or aF == "BOTTOM") ) then            x1 = module.frame:GetWidth()/2; x = x + x1
	elseif  ( just == "LEFT" and (aF == "TOPRIGHT" or aF == "RIGHT" or aF == "BOTTOMRIGHT") ) then    x1 = module.frame:GetWidth(); x = x - x1
	elseif  ( just == "LEFT" and (aF == "TOPLEFT" or aF == "LEFT" or aF == "BOTTOMLEFT") ) then       x = x
	elseif  ( just == "LEFT" and (aF == "CENTER" or aF == "TOP" or aF == "BOTTOM") ) then             x1 = module.frame:GetWidth()/2; x = x - x1
	elseif  ( just == "CENTER" and (aF == "TOPLEFT" or aF == "LEFT" or aF == "BOTTOMLEFT") ) then     x1 = module.frame:GetWidth()/2; x = x + x1
	elseif  ( just == "CENTER" and (aF == "TOPRIGHT" or aF == "RIGHT" or aF == "BOTTOMRIGHT") ) then  x1 = module.frame:GetWidth()/2; x = x - x1
	elseif  ( just == "CENTER" and (aF == "CENTER" or aF == "TOP" or aF == "BOTTOM") ) then           x = x end
	return x, y
end

local function MoveFrame(module)
	local modDB = module.db.profile
	module.frame:SetPoint(modDB.justify, modDB.anchor, modDB.anchorFrom, modDB.offX, modDB.offY)
	module.isMoving = true
	if ( not db.locked ) then module.frame:StartMoving() else end
end

local function StopFrame(module)
	local modDB = module.db.profile
	module.frame:StopMovingOrSizing()
	module.isMoving = false
	local aP, _, aF, x, y = module.frame:GetPoint()
	local anchor = module.frame:GetParent():GetName()
	local xoff, yoff = TranslateCoords(module, aF, x, y)
	modDB.anchorPoint, modDB.anchor, modDB.anchorFrom, modDB.offX, modDB.offY = modDB.justify, anchor, aF, floor(xoff), floor(yoff)
end

function SLDataText:UpdateModule(module)
	local modDB = module.db.profile
	local font, size = getFontInfo(module)
	if ( db.fontOutline ) then
		module.string:SetFont(font, size, "OUTLINE")
	else
		module.string:SetFont(font, size)
		module.string:SetShadowColor(0, 0, 0, 1)
		module.string:SetShadowOffset(1.5, -1.5)
	end
	module.frame:SetWidth(module.string:GetWidth())
	module.frame:SetHeight(module.string:GetHeight())
	if ( module.icon and modDB.dispStyle == L["Icon"] ) then -- Has icon (ie. Tracking)
		module.icon:SetWidth(modDB.iconSize)
		module.icon:SetHeight(modDB.iconSize)
		-- Readjust frame
		module.frame:SetWidth(module.icon:GetWidth())
		module.frame:SetHeight(module.icon:GetHeight())
	end
	if ( module.button ) then module.button:SetAllPoints(module.frame) end
end

function SLDataText:RefreshModule(module)
	local modDB = module.db.profile
	module.frame:SetBackdrop({  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, insets = { left = 0, top = 0, right = 0, bottom = 0 }, })
	-- Force update of data & set font and frame size
	self:UpdateModule(module)
	module:Refresh()

	module.frame:EnableMouse(true)
	module.frame:SetFrameStrata(modDB.strata)
	if ( not db.locked ) then
		if ( module.button ) then module.button:EnableMouse(false) end
		module.frame:SetBackdropColor(0, 0, 0, 1)
		module.frame:SetMovable(true)
		module.frame:RegisterForDrag("LeftButton")
		module.frame:SetScript("OnMouseDown", function()
			MoveFrame(module)
		end)
		module.frame:SetScript("OnMouseUp", function()
			StopFrame(module)
		end)
	else
		if ( module.button ) then module.button:EnableMouse(true) end
		module.frame:SetBackdropColor(0, 0, 0, 0)
		module.frame:SetMovable(false)
		module.frame:RegisterForDrag("LeftButton")
		module.frame:SetScript("OnMouseDown", nil)
		module.frame:SetScript("OnMouseUp", nil)
	end
	if ( not module.isMoving ) then
		module.frame:ClearAllPoints()
		module.frame:SetPoint(modDB.justify, modDB.anchor, modDB.anchorFrom, modDB.offX, modDB.offY)
		module.string:ClearAllPoints()
		module.string:SetPoint(modDB.justify, module.frame, modDB.justify, 0, 0)
		if ( module.icon ) then
			module.icon:ClearAllPoints()
			module.icon:SetPoint(modDB.justify, module.frame, modDB.justify, 0, 0)
		end
	end
end

-- Common information
SLDataText.just = { ["LEFT"] = L["Left"], ["CENTER"] = L["Center"], ["RIGHT"] = L["Right"], }
SLDataText.strata = { ["PARENT"] = L["Parent"], ["BACKGROUND"] = L["Background"], ["LOW"] = L["Low"],
					  ["MEDIUM"] = L["Medium"], ["HIGH"] = L["High"], ["DIALOG"] = L["Dialog"], }
SLDataText.point = { ["LEFT"] = L["Left"], ["CENTER"] = L["Center"], ["RIGHT"] = L["Right"], ["BOTTOM"] = L["Bottom"], ["BOTTOMLEFT"] = L["Bottom Left"],
					 ["BOTTOMRIGHT"] = L["Bottom Right"], ["TOP"] = L["Top"], ["TOPLEFT"] = L["Top Left"], ["TOPRIGHT"] = L["Top Right"], }
SLDataText.ttColors = { ["HEADER"] = "ffff00", ["LINEHEAD"] = "ffff88", ["LINERED"] = "ff0000", ["LINEGREEN"] = "00ff00", }

-- Databroker handling
function SLDataText:SetupObjects(name, obj)

end