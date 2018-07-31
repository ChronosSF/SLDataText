local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "Coords"
local Coords = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Coords)
	end
end

local options
local function getOptions()
	if ( not options ) then options = {
		type = "group",
		name = L["Coords"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenCorSet"],
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
						Coords:PLAYER_ENTERING_WORLD()
					end
				end,
				order = 50,
			},
			noCombatHide = {
				type = "toggle",
				name = L["SIC"],
				desc = L["SICDesc"],
				order = 100,
			},
			precision = {
				type = "range",
				name = L["Prec"],
				desc = L["PrecDesc"],
				min = 0, max = 2, step = 1,
				width = "double",
				order = 200,
			},
			dispHeader = {
				type = "header",
				name = L["DispSet"],
				order = 275,
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
					SLDataText:RefreshModule(Coords)
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
local f
local function buildModule(self)
	if ( not f ) then f = CreateFrame("Frame") end
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Coords", UIParent) end
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end

	f:SetScript("OnUpdate", function(self, elapsed)
		int = int - elapsed
		if ( int <= 0 ) then
			Coords:Refresh()
			int = 1
		end
	end)

	Coords:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Coords:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Coords:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			precision = 0,
			noCombatHide = true,
			fontFace = "Arial Narrow",
			useGlobalFont = true,
			fontSize = 10,
			useGlobalFontSize = false,
			justify = "CENTER",
			anchorPoint = "CENTER",
			anchor = "Minimap",
			anchorFrom = "BOTTOM",
			offX = 0,
			offY = 28,
			strata = "LOW",
		},
	})
	db = self.db.profile
	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Coords:OnEnable()
	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Coords:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnUpdate", nil)
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

function Coords:Refresh()
	local mapID = C_Map.GetBestMapForUnit("player")
	local pos, posX, posY
	if (not mapID) then
		posX = 0
		posY = 0
	else
		pos = C_Map.GetPlayerMapPosition(mapID, "player")
		if (not pos) then
			posX = 0
			posY = 0
		else
			posX, posY = C_Map.GetPlayerMapPosition(mapID, "player"):GetXY()
		end
	end
	local displayX, displayY
	if (not posX) then displayX = 0 else displayX = posX * 100 end
	if (not posY) then displayY = 0 else displayY = posY * 100 end
	self.string:SetFormattedText("%."..self.db.profile.precision.."f, %."..self.db.profile.precision.."f", displayX, displayY)
	SLDataText:UpdateModule(self)
end