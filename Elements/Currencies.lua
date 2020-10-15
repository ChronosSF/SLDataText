local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "Currencies"
local Currencies = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Currencies)
	end
end

local currTable = {[0] = L["NoCurr"],}
local registered = {}

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["Currencies"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenCSet"],
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
						Currencies:PLAYER_ENTERING_WORLD()
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
					SLDataText:RefreshModule(Currencies)
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
			savetoname = {
				type = "toggle",
				name = L["SaveName"],
				desc = L["SaveNameDesc"],
				order =655,
			},
			dispname = {
				type = "input",
				name = L["DispName"],
				desc = L["DispNameDesc"],
				get = function() if(db.savetoname) then return db.saveName[currTable[db.dispmode]] else return db.dispname end end,
				set = function(_,v) if(db.savetoname) then db.saveName[currTable[db.dispmode]] = v else db.dispname = v end Currencies:Refresh() end,
				width = "double",
				order = 660,
			},
			dispmode = {
				type = "select",
				name = L["TrackCurr"],
				desc = L["TrackCurrDesc"],
				values = currTable,
				width = "double",
				order = 670,
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Honor", UIParent, BackdropTemplateMixin and "BackdropTemplate") end -- The frame
	--if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string

	-- Set scripts/etc.

	Currencies:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Currencies:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Currencies:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			hideTooltip = false,
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
			offY = 60,
			strata = "BACKGROUND",
			dispname = "",
			dispmode = 0,
			savetoname = true,
			saveName = {
				["Honor Points"] = L["Honor:"],
				["Justice Points"]= L["Justice:"],
				["Conquest Points"] = L["Conquest:"],
			},
		},
	})
	db = self.db.profile
	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Currencies:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "Refresh")
	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Currencies:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

--[[  // FAN-UPDATE Karaswa
local loggedOn = true
local sessionHonorStart, sessionHonorEarned = 0, 0
local sessionJusticeStart, sessionJusticeEarned = 0, 0
local sessionConquestStart, sessionConquestEarned = 0, 0
]]--

-- Main update, used to refresh your modules data
function Currencies:Refresh()
	-- Gather your data
	local curr = {}

	--[[  // FAN-UPDATE Karaswa
	_backup.lua #001
	]]--

	if ( SLDataText.db.profile.locked and not db.hideTooltip ) then
		self.frame:SetScript("OnEnter", function(this)
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR")

			--[[  // FAN-UPDATE Karaswa
			_backup.lua #002
			]]--

--			GameTooltip:AddLine("|cffffffff"..L["Other Currencies"].."|r")
			GameTooltip:AddLine("|cffffffff"..L["Currencies"].."|r")
			GameTooltip:AddLine("-------------------------", 1, 1, 1)


			-- // FAN-UPDATE Karaswa
			local currencySize = C_CurrencyInfo.GetCurrencyListSize()
			for i = 1,currencySize do
--				name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(i)
				name, isHeader, isExpanded, isUnused, isWatched, count, icon, maximum, hasWeeklyLimit, currentWeeklyAmount, unknown = GetCurrencyListInfo(i)

				if (isHeader) then
					L[name] = name
					GameTooltip:AddDoubleLine("|cffffff00"..L[name].."|r", "", 1, 1, 1, 1, 1, 1)
				else
					local current = ""
					if(hasWeeklyLimit) then
						if(currentWeeklyAmount) then
							current = " ("..currentWeeklyAmount..") "
						end
					end
					GameTooltip:AddDoubleLine(name, count..""..current, 1, 1, 1, 1, 1, 1)
				end
			end
			--[[  //  FAN-UPDATE Karaswa
			for currname,currcount in pairs(curr) do
				GameTooltip:AddDoubleLine(currname, currcount, 1, 1, 1, 1, 1, 1)
			end
			]]--

		GameTooltip:Show()
		end)
		self.frame:SetScript("OnLeave", function()
			if ( GameTooltip:IsShown() ) then
				GameTooltip:Hide()
			end
		end)
	else
		self.frame:SetScript("OnEnter", nil)
		self.frame:SetScript("OnLeave", nil)
	end

	-- Here we fetch the color, determine any display options, and set the value of the module data
	local color = SLDataText:GetColor()
	local dname
	local dmode = db.dispmode
	if(not currTable[dmode]) then
		dmode = 0
	end
	if(db.savetoname) then
		dname = db.saveName[currTable[dmode]]
		if(not dname) then dname="" end
	else
		dname = db.dispname
	end
	if(dmode==0) then
		if(dname == "") then dname = L["Currencies"] end
		self.string:SetFormattedText("|cff%s%s|r", color, dname)
	else
		if(dname == "") then cname = currTable[dmode] else cname = dname end
		dval = curr[currTable[dmode]]
	self.string:SetFormattedText("|cff%s%s|r %s", color, cname, dval)
	end
	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end