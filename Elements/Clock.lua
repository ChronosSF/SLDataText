local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db
local realmName = GetCVar("realmName")

local MODNAME = "Clock"
local Clock = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Clock)
	end
end

local options
local function getOptions()
	if not options then
		options = {
			type = "group",
			name = L["Clock"],
			arg = MODNAME,
			get = optGetter,
			set = optSetter,
			args = {
				genHeader = {
					type = "header",
					name = L["GenClkSet"],
					order = 1,
				},
				enabled = {
					type = "toggle",
					name = L["Enabled"],
					desc = L["EnabledDesc"],
					get = function() return SLDataText:GetModuleEnabled(MODNAME) end,
					set = function(info, value)
						SLDataText:SetModuleEnabled(MODNAME, value)
						if ( SLDataText:GetModuleEnabled(MODNAME) ) then
							Clock:PLAYER_ENTERING_WORLD()
						end
					end,
					order = 25,
				},
				hideGameTime = {
					type = "toggle",
					name = L["HideGT"],
					desc = L["HideGTDesc"],
					order = 50,
				},
				isServerTime = {
					type = "toggle",
					name = L["SST"],
					desc = L["SSTDesc"],
					order = 75,
				},
				s24Hour = {
					type = "toggle",
					name = L["ST24Hour"],
					desc = L["ST24HourDesc"],
					order = 100,
				},
				hideTooltip = {
					type = "toggle",
					name = L["HideTT"],
					desc = L["HideTTDesc"],
					order = 125,
				},
				noCombatHide = {
					type = "toggle",
					name = L["SIC"],
					desc = L["SICDesc"],
					order = 150,
				},
				clkFormDesc = {
					type = "description",
					name = L["ClkFormDescLong"],
					width = "double",
					order = 175,
				},
				clockFormat = {
					type = "input",
					name = L["ClkFormat"],
					desc = L["ClkFormatDesc"],
					width = "double",
					order = 200,
				},
				showMeridiem = {
					type = "toggle",
					name = L["Meridiem"],
					desc = L["MeridiemDesc"],
					order = 225,
				},
				pulse = {
					type = "toggle",
					name = L["InvPulse"],
					desc = L["InvPulseDesc"],
					order = 250,
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
						SLDataText:RefreshModule(Clock)
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Clock", UIParent, BackdropTemplateMixin and "BackdropTemplate") end
	if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate") end
	if ( not self.pulse ) then self.pulse = CreateFrame("Frame", nil, self.frame, BackdropTemplateMixin and "BackdropTemplate") end
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end

	f:SetScript("OnUpdate", function(self, elapsed)
		int = int - elapsed
		if ( int <= 0 ) then
			Clock:Refresh()
			int = 1
		end
	end)
	self.button:SetScript("OnClick", function()
		if ( IsShiftKeyDown() ) then
			ToggleCalendar()
		else
			ToggleTimeManager()
		end
	end)

	SLDataText:RefreshModule(self)
end

function Clock:PLAYER_ENTERING_WORLD()
	local enabled = SLDataText:GetModuleEnabled(MODNAME)
	if ( enabled ) then
		if ( TimeManagerClockButton and TimeManagerClockButton:IsShown() ) then TimeManagerClockButton:Hide() end
		if ( db.hideGameTime ) then
			if ( GameTimeFrame and GameTimeFrame:IsShown() ) then GameTimeFrame:Hide() end
		end
	end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Clock:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			pulse = false,
			hideGameTime = false,
			clockFormat = "%I:%M",
			showMeridiem = true,
			isServerTime = false,
			s24Hour = false,
			hideTooltip = false,
			noCombatHide = false,
			fontFace = "Arial Narrow",
			useGlobalFont = true,
			fontSize = 12,
			useGlobalFontSize = true,
			justify = "CENTER",
			anchorPoint = "CENTER",
			anchor = "Minimap",
			anchorFrom = "BOTTOM",
			offX = 0,
			offY = -14,
			strata = "BACKGROUND",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Clock:OnEnable()
	if ( TimeManagerClockButton and TimeManagerClockButton:IsShown() ) then TimeManagerClockButton:Hide() end
	if ( db.hideGameTime ) then
		if ( GameTimeFrame and GameTimeFrame:IsShown() ) then GameTimeFrame:Hide() end
	end
	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Clock:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnUpdate", nil)
	self.button:SetScript("OnClick", nil)
	if ( TimeManagerClockButton and not TimeManagerClockButton:IsShown() ) then TimeManagerClockButton:Show() end
	if ( db.hideGameTime ) then
		if ( GameTimeFrame and not GameTimeFrame:IsShown() ) then GameTimeFrame:Show() end
	end
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

local function getGameTime()
	local serTime, serAMPM
	local hour, min = GetGameTime()
	if ( db.s24Hour ) then
		if ( min < 10 ) then min = format("%s%s", "0", min) end
		serAMPM = ""
		serTime = format("%s:%s", hour, min)
	else
		if ( min < 10 ) then min = format("%s%s", "0", min) end
		if ( tonumber(hour) > 11 ) then serAMPM = "pm" else serAMPM = "am" end
		if ( tonumber(hour) == 0 ) then
			hour = hour + 12
		elseif ( tonumber(hour) > 12 ) then
			hour = hour - 12
		end
		serTime = format("%s:%s", hour, min)
	end
	return serTime, serAMPM
end

local function convertSecondstoTime(value)
	local hours, minues, seconds
	hours = floor(value/3600)
	minutes = floor((value-(hours*3600))/60)
	seconds = floor(value - ((hours * 3600) + (minutes * 60)))

	if ( hours > 0 ) then
		if ( minutes < 10 ) then minutes = format("0%d", minutes) end
		if ( seconds < 10 ) then seconds = format("0%d", seconds) end
		return format("%s:%s:%s", hours, minutes, seconds)
	elseif ( minutes > 0 ) then
		if ( minutes < 10 ) then minutes = format("0%d", minutes) end
		if ( seconds < 10 ) then seconds = format("0%d", seconds) end
		return format("%s:%s", minutes, seconds)
	else
		if ( seconds < 10 ) then seconds = format("0%d", seconds) end
		return format("%s", seconds)
	end
end

local pulseDown = true
local function invitePulse(self, invites)
	self.pulse:SetBackdrop({
		bgFile = "Interface\\Addons\\SLDataText\\Media\\Pulse.tga", tile = false,
		insets = { left = 0, top = 0, right = 0, bottom = 0 },
	})
	self.pulse:SetAllPoints(self.frame)

	if ( invites == 0 ) then
		if ( self.pulse:IsShown() ) then self.pulse:Hide() end
		self.pulse:SetScript("OnUpdate", nil)
	else
		if ( not self.pulse:IsShown() ) then self.pulse:Show() end
		self.pulse:SetFrameLevel(0)
		self.pulse:SetScript("OnUpdate", function(self, elapsed)
			local step = abs(1/30)
			if ( self:GetAlpha() == 1 ) then
				pulseDown = true
				self:SetAlpha(self:GetAlpha()-step)
			elseif ( self:GetAlpha() == 0 ) then
				pulseDown = false
				self:SetAlpha(self:GetAlpha()+step)
			else
				if ( pulseDown ) then
					self:SetAlpha(self:GetAlpha()-step)
				else
					self:SetAlpha(self:GetAlpha()+step)
				end
			end
		end)
	end
end

function Clock:Refresh()
	local locTime, locAMPM = date(db.clockFormat), date("%p")
	local serTime, serAMPM = getGameTime()
	if ( not db.showMeridiem ) then locAMPM = "" else locAMPM = string.lower(locAMPM) end
	local caltext = date("%b %d (%a)")
	local WGTime = select(5, GetWorldPVPAreaInfo(1)) or nil
	if ( WGTime ~= nil ) then
		WGTime = convertSecondstoTime(WGTime)
	else
		WGTime = L["No Wintergrasp Time Available"]
	end
	local TBTime = select(5, GetWorldPVPAreaInfo(2)) or nil
	if ( TBTime ~= nil ) then
		TBTime = convertSecondstoTime(TBTime)
	else
		TBTime = L["No Tol Barad Time Available"]
	end
	if ( db.pulse ) then
		local invites = C_Calendar.GetNumPendingInvites()
		invitePulse(self, invites)
	end

	if ( SLDataText.db.profile.locked and not db.hideTooltip ) then
		self.button:EnableMouse(true)
		self.button:SetScript("OnEnter", function(this)
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
			GameTooltip:AddLine(format("|cff%s%s|r", SLDataText.ttColors["HEADER"], L["Time Info"]))
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(format("|cff%s%s|r", SLDataText.ttColors["LINEHEAD"], L["Realm Time:"]), format("%s%s", serTime, serAMPM), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(format("|cff%s%s|r", SLDataText.ttColors["LINEHEAD"], L["Local Time:"]), format("%s%s", locTime, locAMPM), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(format("|cff%s%s|r", SLDataText.ttColors["LINEHEAD"], L["Date:"]), caltext, 1, 1, 1, 1, 1, 1)
			GameTooltip:AddLine(" ")
			if ( WGTime ~= nil ) then
				GameTooltip:AddDoubleLine(format("|cff%s%s|r", SLDataText.ttColors["LINEHEAD"], L["WGTimer:"]), format("%s", WGTime), 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddLine(format("|cff%s%s|r", SLDataText.ttColors["LINEHEAD"], L["No Wintergrasp Time Available"]))
			end
			if ( TBTime ~= nil ) then
				GameTooltip:AddDoubleLine(format("|cff%s%s|r", SLDataText.ttColors["LINEHEAD"], L["TBTimer:"]), format("%s", TBTime), 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddLine(format("|cff%s%s|r", SLDataText.ttColors["LINEHEAD"], L["No Tol Barad Time Available"]))
			end
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["ClkHint1"])
			GameTooltip:AddLine(L["ClkHint2"])
			GameTooltip:Show()
		end)
		self.button:SetScript("OnLeave", function()
			if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
		end)
	else
		self.button:EnableMouse(false)
		self.button:SetScript("OnEnter", nil)
		self.button:SetScript("OnLeave", nil)
	end

	local color = SLDataText:GetColor()
	if ( db.isServerTime ) then
		self.string:SetFormattedText("%s|cff%s%s|r", serTime, color, serAMPM)
	else
		self.string:SetFormattedText("%s|cff%s%s|r", locTime, color, locAMPM)
	end

	SLDataText:UpdateModule(self)
end

--[[ WORKING TIME ESCAPES
%a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%M	minute (48) [00-59]
%m	month (09) [01-12]
%p	either "am" or "pm" (pm)
%S	second (10) [00-61]
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character `%´
]]