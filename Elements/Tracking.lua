local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "Tracking"
local Tracking = SLDataText:NewModule(MODNAME, "AceEvent-3.0")


local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Tracking)
	end
end

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["Tracking"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenTrackSet"],
				order = 25,
			},
			enabled = {
				type = "toggle",
				name = L["Enabled"],
				desc = L["EnabledDesc"],
				get = function() return SLDataText:GetModuleEnabled(MODNAME) end,
				set = function(info, value)
					SLDataText:SetModuleEnabled(MODNAME, value)
					if ( SLDataText:GetModuleEnabled(MODNAME) ) then
						Tracking:PLAYER_ENTERING_WORLD()
					end
				end,
				order = 50,
			},
			hideTooltip = {
				type = "toggle",
				name = L["HideTT"],
				desc = L["HideTTDesc"],
				order = 100,
			},
			noCombatHide = {
				type = "toggle",
				name = L["SIC"],
				desc = L["SICDesc"],
				order = 150,
			},
			dispHeader = {
				type = "header",
				name = L["DispSet"],
				order = 200,
			},
			useGlobalFont = {
				type = "toggle",
				name = L["UseGblFont"],
				desc = L["UseGblFontDesc"],
				order = 300,
			},
			useGlobalFontSize = {
				type = "toggle",
				name = L["UseGblFSize"],
				desc = L["UseGblFSizeDesc"],
				order = 350,
			},
			fontFace = {
				type = "select",
				name = L["Font"],
				desc = L["FontDesc"],
				disabled = function()
					local isTrue
					if ( db.useGlobalFont ) then isTrue = true else isTrue = false end
					return isTrue
				end,
				values = media:List("font"),
				get = function()
					for k, v in pairs(media:List("font")) do
						if db.fontFace == v then
							return k
						end
					end
				end,
				set = function(_, font)
					local list = media:List("font")
					db.fontFace = list[font]
					SLDataText:RefreshModule(Tracking)
				end,
				width = "double",
				order = 600,
			},
			fontSize = {
				type = "range",
				name = L["FontSize"],
				desc = L["FontSizeDesc"],
				disabled = function()
					local isTrue
					if ( db.useGlobalFontSize ) then isTrue = true else isTrue = false end
					return isTrue
				end,
				min = 6, max = 36, step = 1,
				width = "double",
				order = 650,
			},
			posHeader = {
				type = "header",
				name = L["LaySet"],
				order = 700,
			},
			justify = {
				type = "select",
				name = L["TextJust"],
				desc = L["TextJustDesc"],
				values = justTable,
				width = "double",
				order = 750,
			},
			anchor = {
				type = "input",
				name = L["ParFrm"],
				desc = L["ParFrmDesc"],
				get = function() return db.anchor end,
				width = "double",
				order = 800,
			},
			anchorFrom = {
				type = "select",
				name = L["AnchFrom"],
				desc = L["AnchFromDesc"],
				values = pointTable,
				get = function() return db.anchorFrom end,
				width = "double",
				order = 900,
			},
			offX = {
				type = "input",
				name = L["XOff"],
				desc = L["XOffDesc"],
				get = function() return tostring(db.offX) end,
				width = "double",
				order = 1000,
			},
			offY = {
				type = "input",
				name = L["YOff"],
				desc = L["YOffDesc"],
				get = function() return tostring(db.offY) end,
				width = "double",
				order = 1100,
			},
			strata = {
				type = "select",
				name = L["Strata"],
				desc = L["StrataDesc"],
				values = strataTable,
				width = "double",
				order = 1600,
			},
		},
	}
	end

	return options
end

local function buildModule(self)
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Tracking", UIParent, BackdropTemplateMixin and "BackdropTemplate") end -- The frame
	if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string
	if ( not self.menu ) then -- The dropdown menu
		self.menu = CreateFrame("Frame", nil, self.button, UIDropDownMenuTemplate)
		-- Setup Menu Basics
		self.menu:SetClampedToScreen(true)
		self.menu:SetID(1)
		self.menu:SetScript("OnLoad", function() MiniMapTrackingDropDown_OnLoad() end)
	end

	-- Set scripts/etc.
	self.button:SetScript("OnClick", function()
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self.button, 0, 5)
	end)

	Tracking:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Tracking:PLAYER_ENTERING_WORLD()
	local enabled = SLDataText:GetModuleEnabled(MODNAME)
	if ( enabled ) then
		if ( MiniMapTracking and MiniMapTracking:IsShown() ) then MiniMapTracking:Hide() end
	end
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Tracking:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			hideTooltip = false,
			noCombatHide = true,
			fontFace = "Arial Narrow",
			useGlobalFont = true,
			fontSize = 10,
			useGlobalFontSize = false,
			iconSize = 16,
			justify = "CENTER",
			anchorPoint = "CENTER",
			anchor = "Minimap",
			anchorFrom = "BOTTOM",
			offX = 0,
			offY = 16,
			strata = "LOW",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Tracking:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING", "Refresh")
	if ( MiniMapTracking and MiniMapTracking:IsShown() ) then MiniMapTracking:Hide() end

	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Tracking:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("MINIMAP_UPDATE_TRACKING")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if ( MiniMapTracking and not MiniMapTracking:IsShown() ) then MiniMapTracking:Show() end
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

-- Main update, used to refresh your modules data
function Tracking:Refresh()
	-- Gather your data
	local name, active, category
	local count = GetNumTrackingTypes()
	if ( SLDataText.db.profile.locked and not db.hideTooltip ) then
		self.button:EnableMouse(true)
		self.button:SetScript("OnEnter", function(this)
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
			GameTooltip:AddLine("|cffffff00"..L["Tracking"].."|r", 1, 1, 1)
			for id = 1, count do
				name, _, active, category = GetTrackingInfo(id)
				if ( active ) then
					GameTooltip:AddLine(name, 1, 1, 1)
				end
			end
			GameTooltip:Show()
		end)
		self.button:SetScript("OnLeave", function()
			if ( GameTooltip:IsShown() ) then
				GameTooltip:Hide()
			end
		end)
	else
		self.button:EnableMouse(true)
		self.button:SetScript("OnEnter", nil)
		self.button:SetScript("OnLeave", nil)
	end

	-- Here we fetch the color, determine any display options, and set the value of the module data
	self.string:SetText(L["Tracking"])
	if ( not self.string:IsShown() ) then self.string:Show() end

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end