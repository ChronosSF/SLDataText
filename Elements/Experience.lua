local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "Experience"
local Experience = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Experience)
	end
end

local options
local function getOptions()
	if ( not options ) then options = {
		type = "group",
		name = L["Experience"],
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
						Experience:PLAYER_ENTERING_WORLD()
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
			showRest = {
				type = "toggle",
				name = L["showRest"],
				desc = L["showRestDesc"],
				order = 200,
			},
			showPer = {
				type = "toggle",
				name = L["showPer"],
				desc = L["showPerDesc"],
				order = 210,
			},
			shortXP = {
				type = "toggle",
				name = L["shortXP"],
				desc = L["shortXPDesc"],
				order = 220,
			},
			onlyPer = {
				type = "toggle",
				name = L["onlyPer"],
				desc = L["onlyPerDesc"],
				order = 230,
			},
			dispHeader = {
				type = "header",
				name = L["DispSet"],
				order = 275,
			},
			secText = {
				type = "input",
				name = L["SecText"],
				desc = L["SecTextDesc"],
				width = "double",
				order = 300,
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
					SLDataText:RefreshModule(Experience)
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Experience", UIParent, BackdropTemplateMixin and "BackdropTemplate") end
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end

	f:SetScript("OnUpdate", function(self, elapsed)
		int = int - elapsed
		if ( int <= 0 ) then
			Experience:Refresh()
			int = 1
		end
	end)

	Experience:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Experience:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Experience:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			noCombatHide = true,
			fontFace = "Arial Narrow",
			useGlobalFont = true,
			fontSize = 12,
			useGlobalFontSize = false,
			justify = "CENTER",
			anchorPoint = "CENTER",
			anchor = "UIParent",
			anchorFrom = "CENTER",
			offX = 200,
			offY = -20,
			strata = "BACKGROUND",
		},
	})
	db = self.db.profile
	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Experience:OnEnable()
	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Experience:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnUpdate", nil)
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

function Experience:Refresh()
	local p_level = UnitLevel("player")
	if (p_level < 60) then
		local sec_text = db.secText

		--get data
		local exp_cur = UnitXP("player")
		local exp_max = UnitXPMax("player")
		local exp_rest_num = GetXPExhaustion() or 0
		local exp_rest_id, exp_rest_string, exp_rest_multi = GetRestState()

		--math with data
		local exp_rem = exp_max - exp_cur
		local exp_rest_num_max = exp_max / 2 + exp_max --max rest xp is always 150% of current level regardless of current xp
		local exp_rest_per = (exp_rest_num * 100) / exp_rest_num_max
		local exp_cur_per = (exp_cur * 100) / exp_max


		--round
		function round(num, idp)
			local mult = 10^(idp or 0)
			return math.floor(num * mult + 0.5) / mult
		end

		local exp_rest_per = round(exp_rest_per, 1)
		local exp_cur_per = round(exp_cur_per, 1)

		--over 9000
		if (db.shortXP) then
			if (exp_max > 10000000) then
				exp_max = exp_max/1000000
				exp_max = round(exp_max, 2) .." M"
			elseif (exp_max > 1000000) then
				exp_max = exp_max/1000000
				exp_max = round(exp_max, 3) .." M"
			elseif (exp_max > 100000) then
				exp_max = exp_max/1000
				exp_max = round(exp_max, 0) .. " K"
			end

			if (exp_cur > 10000000) then
				exp_cur = exp_cur/1000000
				exp_cur = round(exp_cur, 2) .." M"
			elseif (exp_cur > 1000000) then
				exp_cur = exp_cur/1000000
				exp_cur = round(exp_cur, 3) .." M"
			elseif (exp_cur > 100000) then
				exp_cur = exp_cur/1000
				exp_cur = round(exp_cur, 0) .. " K"
			end
		end

		--options
		if (db.showRest) then
			exp_rest_per = " (R: "..exp_rest_per.." %%)"
		else
			exp_rest_per = ""
		end

		if (db.showPer and not db.onlyPer) then
			exp_cur_per = "("..exp_cur_per.."%%) "
		elseif (db.onlyPer) then
			exp_cur_per = exp_cur_per.."%%"
		else
			exp_cur_per = ""
		end

		if string.len(sec_text) > 0 then
			local color = SLDataText:GetColor()
			sec_text = "|cff" .. color .. sec_text .. "|r "
		end

		--post it
		if (db.onlyPer) then
			self.string:SetFormattedText(sec_text..exp_cur_per)
		else
			self.string:SetFormattedText(sec_text..exp_cur_per..""..exp_cur.." / "..exp_max .."".. exp_rest_per)
		end

		SLDataText:UpdateModule(self)
	end
end