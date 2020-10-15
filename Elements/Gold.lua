local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db, realmDB

local MODNAME = "Gold"
local Gold = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local dispTbl = {
	["Extended"] = L["Extended"],
	["Full"] = L["Full"],
	["Short"] = L["Short"],
}

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Gold)
	end
end

local getPlayerList = function()
	local list = { }
	for k, v in pairs(realmDB) do
		if ( k ~= UnitName("player") ) then
			tinsert(list, k)
		end
	end
	return list
end

local function otherFaction(f)
	if(f=="Horde") then
		return "Alliance"
	else
		return "Horde"
	end
end

local removeName
local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["Gold"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenGoldSet"],
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
						Gold:PLAYER_ENTERING_WORLD()
					end
				end,
				order = 100,
			},
			hideTooltip = {
				type = "toggle",
				name = L["HideTT"],
				desc = L["HideTTDesc"],
				order = 150,
			},
			noCombatHide = {
				type = "toggle",
				name = L["SIC"],
				desc = L["SICDesc"],
				order = 200,
			},
			reset = {
				type = "execute",
				name = L["Reset"],
				desc = L["ResetDesc"],
				func = function()
					wipe(realmDB)
					realmDB=Gold.db.realm
					realmDB={["Horde"]={},["Alliance"]={},}
				end,
				order = 215,
			},
			dispHeader = {
				type = "header",
				name = L["DispSet"],
				order = 225,
			},
			dispStyle = {
				type = "select",
				name = L["DispStyle"],
				desc = L["GDispStyleDesc"],
				values = dispTbl,
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
					SLDataText:RefreshModule(Gold)
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Gold", UIParent, BackdropTemplateMixin and "BackdropTemplate") end -- The frame
	-- if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string

	-- Set scripts/etc.
	Gold:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Gold:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Gold:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			dispStyle = L["Full"],
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
			offX = 200,
			offY = -40,
			strata = "BACKGROUND",
		},
		realm = {
			[UnitFactionGroup("player")] = {
				[UnitName("player")] = {
					gold = 0,
				},
			},
			[otherFaction(UnitFactionGroup("player"))] = {
			},
		},
	})
	db = self.db.profile
	realmDB = self.db.realm

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Gold:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("PLAYER_MONEY", "Refresh")
	self:RegisterEvent("SEND_MAIL_MONEY_CHANGED", "Refresh")
	self:RegisterEvent("SEND_MAIL_COD_CHANGED", "Refresh")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "Refresh")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "Refresh")

	buildModule(self)
	self:Refresh()
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Gold:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("PLAYER_MONEY")
	self:UnregisterEvent("SEND_MAIL_MONEY_CHANGED")
	self:UnregisterEvent("SEND_MAIL_COD_CHANGED")
	self:UnregisterEvent("PLAYER_TRADE_MONEY")
	self:UnregisterEvent("TRADE_MONEY_CHANGED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

local function convertMoney(money, display)
	local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
	local cash
	if ( display == L["Extended"] ) then
		cash = format("%d |cffffd700"..L["Gold"].."|r %d |cffc7c7cf"..L["Silver"].."|r %d |cffeda55f"..L["Copper"].."|r", gold, silver, copper)
	elseif ( display == L["Full"] ) then
		cash = format("%d|cffffd700g|r %d|cffc7c7cfs|r %d|cffeda55fc|r", gold, silver, copper)
	elseif ( display == L["Short"] ) then
		cash = format("%.1f|cffffd700g|r", gold)
	end
	return cash
end

local loggedOn = true
local sessionGoldStart, sessionGoldEarned = 0, 0

-- Main update, used to refresh your modules data
function Gold:Refresh()
	-- Gather your data
	local money = GetMoney()
	local cash = convertMoney(money, db.dispStyle)
	realmDB[UnitFactionGroup("player")][UnitName("player")].gold = money

	if ( loggedOn ) then
		sessionGoldStart = money
		loggedOn = false
	else
		if ( money - sessionGoldStart ~= 0 ) then
			sessionGoldEarned = money - sessionGoldStart
		end
	end

	if ( SLDataText.db.profile.locked and not db.hideTooltip ) then
		self.frame:SetScript("OnEnter", function(this)
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
			GameTooltip:AddLine("|cffffff00"..L["Gold Stats"].."|r")
			GameTooltip:AddLine("-------------------------", 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Starting Gold"], convertMoney(sessionGoldStart, "Full"), 1, 1, 1, 1, 1, 1)
			if ( sessionGoldEarned ~= 0 ) then
				GameTooltip:AddDoubleLine(L["Current Gold"], cash, 1, 1, 1, 1, 1, 1)
				if ( sessionGoldEarned < 0 ) then
					GameTooltip:AddDoubleLine(L["Gold Earned"], "(-"..convertMoney(sessionGoldEarned, "Full")..")", 1, 1, 1, 1, 1, 1)
				else
					GameTooltip:AddDoubleLine(L["Gold Earned"], convertMoney(sessionGoldEarned, "Full"), 1, 1, 1, 1, 1, 1)
				end
			end

			local lined = false
			for key, val in pairs(realmDB["Horde"]) do
				if ( key ~= UnitName("player") ) then
					if ( not lined ) then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine("|cffffff00"..L["Server Gold"].."|r")
						GameTooltip:AddLine("-------------------------", 1, 1, 1)
						GameTooltip:AddLine("|cffff0000"..L["Horde"].."|r")
						lined = true
					end

					local name, gold = key, 0
					for k, v in pairs(val) do
						gold = v
					end
					GameTooltip:AddDoubleLine(name, convertMoney(gold, "Full"), 1, 1, 1, 1, 1, 1)
				end
			end
			local lined = false
			for key, val in pairs(realmDB["Alliance"]) do
				if ( key ~= UnitName("player") ) then
					if ( not lined ) then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine("|cff0000ff"..L["Alliance"].."|r")
						lined = true
					end

					local name, gold = key, 0
					for k, v in pairs(val) do
						gold = v
					end
					GameTooltip:AddDoubleLine(name, convertMoney(gold, "Full"), 1, 1, 1, 1, 1, 1)
				end
			end

			local totalGold = 0
			local totalGoldH = 0
			local totalGoldA = 0
			for key, val in pairs(realmDB["Horde"]) do
				for k, v in pairs(val) do
					totalGold = totalGold + v
					totalGoldH =totalGoldH + v
				end
			end
			for key, val in pairs(realmDB["Alliance"]) do
				for k, v in pairs(val) do
					totalGold = totalGold + v
					totalGoldA = totalGoldA +v
				end
			end
			if ( totalGold > 0 ) then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("-------------------------", 1, 1, 1)
				GameTooltip:AddDoubleLine(L["Total Gold"], convertMoney(totalGold, "Full"), 1, 1, 1, 1, 1, 1)
				if( totalGoldH > 0 and totalGoldA > 0) then
					GameTooltip:AddDoubleLine(L["Total Gold"].." |cffff0000Horde|r", convertMoney(totalGoldH, "Full"), 1, 1, 1, 1, 1, 1)
					GameTooltip:AddDoubleLine(L["Total Gold"].." |cff0000ffAlliance|r", convertMoney(totalGoldA, "Full"), 1, 1, 1, 1, 1, 1)
				end
			end
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
	-- Color not needed with Gold module
	local font, size = self.string:GetFont()
	if ( font ~= nil ) then
		self.string:SetText(cash)
	end

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end