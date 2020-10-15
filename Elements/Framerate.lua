local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "Framerate"
local Framerate = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Framerate)
	end
end

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["Framerate"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenFPSSet"],
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
						Framerate:PLAYER_ENTERING_WORLD()
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
			dispHeader = {
				type = "header",
				name = L["DispSet"],
				order = 200,
			},
			secText = {
				type = "input",
				name = L["SecText"],
				desc = L["SecTextDesc"],
				width = "double",
				order = 250,
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
					SLDataText:RefreshModule(Framerate)
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Framerate", UIParent, BackdropTemplateMixin and "BackdropTemplate") end -- The frame
	-- if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string

	-- Set scripts/etc.
	f:SetScript("OnUpdate", function(self, elapsed)
		int = int - elapsed
		if ( int <= 0 ) then
			Framerate:Refresh()
			int = 1
		end
	end)

	Framerate:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Framerate:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Framerate:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			secText = L["fps"],
			noCombatHide = false,
			fontFace = "Arial Narrow",
			useGlobalFont = true,
			fontSize = 12,
			useGlobalFontSize = true,
			justify = "CENTER",
			anchorPoint = "CENTER",
			anchor = "UIParent",
			anchorFrom = "CENTER",
			offX = -200,
			offY = 20,
			strata = "BACKGROUND",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Framerate:OnEnable()
	-- Register any events, and hide elements you don't want shown
	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Framerate:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnUpdate", nil)
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

-- Main update, used to refresh your modules data
function Framerate:Refresh()
	-- Gather your data
	local fps = GetFramerate()

	-- Here we fetch the color, determine any display options, and set the value of the module data
	local color = SLDataText:GetColor()
	self.string:SetFormattedText("%d|cff%s%s|r", floor(fps), color, db.secText or L["fps"])

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end