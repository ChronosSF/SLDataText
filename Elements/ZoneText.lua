local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "ZoneText"
local ZoneText = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(ZoneText)
	end
end

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["ZoneText"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenZTSet"],
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
						ZoneText:PLAYER_ENTERING_WORLD()
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
					SLDataText:RefreshModule(ZoneText)
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

local int = 1
local function buildModule(self)
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_ZoneText", UIParent, BackdropTemplateMixin and "BackdropTemplate") end -- The frame
	-- if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string

	-- Set scripts/etc.

	ZoneText:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function ZoneText:PLAYER_ENTERING_WORLD()
	local enabled = SLDataText:GetModuleEnabled(MODNAME)
	if ( enabled ) then
		if ( MinimapZoneTextButton:IsShown() ) then MinimapZoneTextButton:Hide() end
		if ( MinimapBorderTop:IsShown() ) then MinimapBorderTop:Hide() end
		if ( MiniMapWorldMapButton:IsShown() ) then MiniMapWorldMapButton:Hide() end
	end
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function ZoneText:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			hideTooltip = false,
			noCombatHide = true,
			fontFace = "Arial Narrow",
			useGlobalFont = true,
			fontSize = 12,
			useGlobalFontSize = true,
			justify = "CENTER",
			anchorPoint = "CENTER",
			anchor = "Minimap",
			anchorFrom = "TOP",
			offX = 0,
			offY = 12,
			strata = "LOW",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function ZoneText:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("ZONE_CHANGED", "Refresh")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Refresh")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Refresh")
	if ( MinimapZoneTextButton:IsShown() ) then MinimapZoneTextButton:Hide() end
	if ( MinimapBorderTop:IsShown() ) then MinimapBorderTop:Hide() end
	if ( MiniMapWorldMapButton:IsShown() ) then MiniMapWorldMapButton:Hide() end

	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function ZoneText:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_INDOORS")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if ( MinimapZoneTextButton and not MinimapZoneTextButton:IsShown() ) then MinimapZoneTextButton:Show() end
	if ( MinimapBorderTop and not MinimapBorderTop:IsShown() ) then MinimapBorderTop:Show() end
	if ( MiniMapWorldMapButton and not MiniMapWorldMapButton:IsShown() ) then MiniMapWorldMapButton:Show() end

	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

-- Main update, used to refresh your modules data
function ZoneText:Refresh()
	-- Gather your data
	if ( IsAddOnLoaded("Chinchilla") and SLDataText:GetModuleEnabled(self) ) then
		if ( Chinchilla_Location_Frame and Chinchilla_Location_Frame:IsShown() ) then
			Chinchilla_Location_Frame:Hide()
		end
	end

	local zoneName = GetZoneText()
	local subzoneName = GetSubZoneText()
	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo()

	if ( subzoneName == zoneName or subzoneName == "" ) then
		self.string:SetText(zoneName)
	else
		self.string:SetText(subzoneName)
	end

	if ( pvpType == "sanctuary" ) then
		self.string:SetTextColor(0.41, 0.8, 0.94)
	elseif ( pvpType == "arena" ) then
		self.string:SetTextColor(1.0, 0.1, 0.1)
	elseif ( pvpType == "friendly" ) then
		self.string:SetTextColor(0.1, 1.0, 0.1)
	elseif ( pvpType == "hostile" ) then
		self.string:SetTextColor(1.0, 0.1, 0.1)
	elseif ( pvpType == "contested" ) then
		self.string:SetTextColor(1.0, 0.7, 0)
	else
		self.string:SetTextColor(1.0, 0.9294, 0.7607)
	end

	if ( SLDataText.db.profile.locked and not db.hideTooltip ) then
		self.frame:SetScript("OnEnter", function(this)
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR")

			if ( subzoneName == zoneName ) then
				subzoneName = ""
			end
			GameTooltip:AddLine( zoneName, 1.0, 1.0, 1.0 )
			if ( pvpType == "sanctuary" ) then
				GameTooltip:AddLine( subzoneName, 0.41, 0.8, 0.94 )
				GameTooltip:AddLine(SANCTUARY_TERRITORY, 0.41, 0.8, 0.94)
			elseif ( pvpType == "arena" ) then
				GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 )
				GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, 1.0, 0.1, 0.1)
			elseif ( pvpType == "friendly" ) then
				GameTooltip:AddLine( subzoneName, 0.1, 1.0, 0.1 )
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 0.1, 1.0, 0.1)
			elseif ( pvpType == "hostile" ) then
				GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 )
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 1.0, 0.1, 0.1)
			elseif ( pvpType == "contested" ) then
				GameTooltip:AddLine( subzoneName, 1.0, 0.7, 0.0 )
				GameTooltip:AddLine(CONTESTED_TERRITORY, 1.0, 0.7, 0.0)
			else
				GameTooltip:AddLine( subzoneName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b )
			end
			GameTooltip:Show()
		end)
		self.frame:SetScript("OnLeave", function()
			if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
		end)
	else
		self.frame:SetScript("OnEnter", nil)
		self.frame:SetScript("OnLeave", nil)
	end

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end