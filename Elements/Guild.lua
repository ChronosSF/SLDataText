local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local tab = LibStub("Tablet-2.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "GuildList"
local GuildList = SLDataText:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local gList, gOnline
local classColors = nil
do
	local locale = GetLocale()
	if ( not classColors ) then
		if ( locale == "enUS" ) then
			classColors = {
				["Death Knight"] = "|cffc41f3b",
				["Druid"] = "|cffff7d0a",
				["Hunter"] = "|cffabd473",
				["Mage"] = "|cff69ccf0",
				["Paladin"] = "|cfff58cba",
				["Priest"] = "|cffffffff",
				["Rogue"] = "|cfffff569",
				["Shaman"] = "|cff2459ff",
				["Warlock"] = "|cff9482ca",
				["Warrior"] = "|cffc79c6e",
				["Monk"] = "|cff00ff96",
--				//FAN-UPDATE Karaswa (Monk added)
			}
		elseif ( locale == "deDE" ) then
			classColors = {
				["Todesritter"] = "|cffc41f3b",
				["Druide"] = "|cffff7d0a",
				["J\195\164ger"] = "|cffabd473",
				["Magier"] = "|cff69ccf0",
				["Paladin"] = "|cfff58cba",
				["Priester"] = "|cffffffff",
				["Schurke"] = "|cfffff569",
				["Schamane"] = "|cff2459ff",
				["Hexenmeister"] = "|cff9482ca",
				["Krieger"] = "|cffc79c6e",
				["Druidin"] = "|cffff7d0a",
				["J\195\164gerin"] = "|cffabd473",
				["Magierin"] = "|cff69ccf0",
				["Paladin"] = "|cfff58cba",
				["Priesterin"] = "|cffffffff",
				["Schurkin"] = "|cfffff569",
				["Schamanin"] = "|cff2459ff",
				["Hexenmeisterin"] = "|cff9482ca",
				["Kriegerin"] = "|cffc79c6e",
				["M\195\182nch"] = "|cff00ff96",
--				//FAN-UPDATE Karaswa (Monk added)
			}
		elseif ( locale == "frFR" ) then
			classColors = {
				["Chaman"] = "|cff2459ff",
				["Chamane"] = "|cff2459ff",
				["Chasseur"] = "|cffabd473",
				["Chasseresse"] = "|cffabd473",
				["Chevalier de la mort"] = "|cffc41f3b",
				["D�moniste"] = "|cff9482ca",
				["Druide"] = "|cffff7d0a",
				["Druidesse"] = "|cffff7d0a",
				["Guerrier"] = "|cffc79c6e",
				["Guerri�re"] = "|cffc79c6e",
				["Mage"] = "|cff69ccf0",
				["Paladin"] = "|cfff58cba",
				["Pr�tre"] = "|cffffffff",
				["Pr�tresse"] = "|cffffffff",
				["Voleur"] = "|cfffff569",
				["Voleuse"] = "|cfffff569",
				["Moine"] = "|cff00ff96",	--//FAN-UPDATE Karaswa (Monk added)
			}
		elseif ( locale == "esES" ) then
			classColors = {
				["Death Knight"] = "|cffc41f3b",
				["Druid"] = "|cffff7d0a",
				["Cazador"] = "|cffabd473",
				["Mage"] = "|cff69ccf0",
				["Paladin"] = "|cfff58cba",
				["Sacerdote"] = "|cffffffff",
				["Granuja"] = "|cfffff569",
				["Shaman"] = "|cff2459ff",
				["Warlock"] = "|cff9482ca",
				["Guerrero"] = "|cffc79c6e",
				["Monje"] = "|cff00ff96",	--//FAN-UPDATE Karaswa (Monk added)
			}
		elseif ( locale == "zhCN" ) then
			classColors = {
				["死亡骑士"] = "|cffc41f3b",
				["德鲁伊"] = "|cffff7d0a",
				["猎人"] = "|cffabd473",
				["法师"] = "|cff69ccf0",
				["圣骑士"] = "|cfff58cba",
				["牧师"] = "|cffffffff",
				["潜行者"] = "|cfffff569",
				["萨满祭司"] = "|cff2459ff",
				["术士"] = "|cff9482ca",
				["战士"] = "|cffc79c6e",
			}
		elseif ( locale == "zhTW" ) then
			classColors = {
				["死亡騎士"] = "|cffc41f3b",
				["德魯伊"] = "|cffff7d0a",
				["獵人"] = "|cffabd473",
				["法師"] = "|cff69ccf0",
				["聖騎士"] = "|cfff58cba",
				["牧師"] = "|cffffffff",
				["盜賊"] = "|cfffff569",
				["薩滿"] = "|cff2459ff",
				["術士"] = "|cff9482ca",
				["戰士"] = "|cffc79c6e",
			}
		end
	end
end

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(GuildList)
	end
end

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["GuildList"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenFLSet"],
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
						GuildList:PLAYER_ENTERING_WORLD()
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
				order = 250,
			},
			ttPoint = {
				type = "select",
				name = L["TTAnch"],
				desc = L["TTAnchDesc"],
				values = pointTable,
				width = "double",
				order = 300,
			},
			ttfPoint = {
				type = "select",
				name = L["AnchTTFrom"],
				desc = L["AnchTTFromDesc"],
				values = pointTable,
				width = "double",
				order = 350,
			},
			secText = {
				type = "input",
				name = L["SecText"],
				desc = L["SecTextDesc"],
				width = "double",
				order = 400,
			},
			useGlobalFont = {
				type = "toggle",
				name = L["UseGblFont"],
				desc = L["UseGblFontDesc"],
				order = 450,
			},
			useGlobalFontSize = {
				type = "toggle",
				name = L["UseGblFSize"],
				desc = L["UseGblFSizeDesc"],
				order = 500,
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
					SLDataText:RefreshModule(GuildList)
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_GuildList", UIParent) end -- The frame
	if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string

	-- Set scripts/etc.
	self.button:SetScript("OnClick", function()
		if ( IsShiftKeyDown() ) then
			ToggleFriendsFrame(3)
		end
	end)

	GuildList:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function GuildList:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function GuildList:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			secText = L["Guild:"],
			ttPoint = "CENTER",
			ttfPoint = "TOP",
			ttSize = 1.0,
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
			offY = 60,
			strata = "BACKGROUND",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function GuildList:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("GUILD_ROSTER_UPDATE", "Refresh")
	self.updatetimer = self:ScheduleRepeatingTimer(function() GuildRoster() end,11)
	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function GuildList:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self.button:SetScript("OnClick", nil)
	self:CancelTimer(self.updatetimer)
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

local function clickFunc(name)
	if ( not name ) then return end
	if ( IsAltKeyDown() ) then
		InviteUnit(name)
	else
		SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
	end
end

local function updateTablet()
	if ( IsInGuild() and gOnline > 0 ) then
		GuildRoster()
		local header = tab:AddCategory()
		local gname, _, _ = GetGuildInfo("player")
		local gmotd = GetGuildRosterMOTD()
		header:AddLine('text', gname, 'size', 14)
		header:AddLine('text', gmotd, 'wrap', true)

		local col = {}
		tinsert(col, L["Name"])
		tinsert(col, L["Level"])
		tinsert(col, L["Area"])
		tinsert(col, L["Rank"])
		tinsert(col, L["Notes"])
		if( CanViewOfficerNote() ) then
			tinsert(col, L["Officer Note"])
		end
		local cat = tab:AddCategory("columns", #col)
		local header = {}
		for i = 1, #col do
			if i == 1 then
				header['text'] = col[i]
				header['justify'] = "CENTER"
			else
				header['text'..i] = col[i]
				header['justify'..i] = "CENTER"
			end
		end
		cat:AddLine(header)
		local nameslot = #col+1
		for _, val in ipairs(gList) do
			local line = {}
			for i = 1, #col do
				if i == 1 then
					line['text'] = val[i]
					line['justify'] = "LEFT"
					line['func'] = function() clickFunc(val[7]) end
				else
					line['text'..i] = val[i]
					line['justify'..i] = "CENTER"
					line['text'..i..'R'] = 1
					line['text'..i..'G'] = 1
					line['text'..i..'B'] = 1
				end
			end
			cat:AddLine(line)
		end

		tab:SetHint(L["GLHint"])
	end
end

-- Main update, used to refresh your modules data
function GuildList:Refresh()
	local notinguild
	if(not IsInGuild()) then
		notinguild=true
		self:CancelTimer(self.updatetimer)
		local guildonline = 0
		local color = SLDataText:GetColor()
		self.string:SetFormattedText("|cff%s%s|r %d", color, db.secText or L["Guild:"], guildonline)
		return
	elseif(IsInGuild() and notinguild==true) then
		self.updatetimer = self:ScheduleRepeatingTimer(function() GuildRoster() end,11)
	end
	-- Gather your data
	gList = nil
	local guildonline = 0
	-- Total Online Guildies
	for i = 0, GetNumGuildMembers() do
--      local name, rank, _, lvl, class, zone, note, offnote, online, status = GetGuildRosterInfo(i)
		local name, rank, rankIndex, lvl, class, zone, note, offnote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, repStanding = GetGuildRosterInfo(i);
		if ( online and CanViewOfficerNote() ) then
			-- If they're online, we'll add them to our guild table
			if ( not gList or gList == nil ) then gList = {} end
			local classColor = classColors[class]
			local cname
			if ( status == 0 ) then
				cname = format("%s%s|r", classColor, name)
			else
				if ( status == 1 ) then
					status = "<AFK>"
				elseif ( status == 2 ) then
					status = "<DND>"
				end
				cname = format("%s %s%s|r", status, classColor, name)
			end
			local gPrelist = { cname, lvl, zone, rank, note, offnote, name }
			tinsert(gList, gPrelist)
			guildonline = guildonline + 1
		elseif( online ) then
			if ( not gList or gList == nil ) then gList = {} end
			local classColor = classColors[class]
			local cname
			if ( status == 0 ) then
				cname = format("%s%s|r", classColor, name)
			else
				if ( status == 1 ) then
					status = "<AFK>"
				elseif ( status == 2 ) then
					status = "<DND>"
				end
				cname = format("%s %s%s|r", status, classColor, name)
			end
			local gPrelist = { cname, lvl, zone, rank, note, " ", name }
			tinsert(gList, gPrelist)
			guildonline = guildonline + 1
		end
	end

	if ( not tab:IsRegistered(self.button) ) then
		tab:Register(self.button,
			"children", function()
				updateTablet()
			end,
			"point", function()
				return db.ttPoint
			end,
			"relativePoint", function()
				return db.ttfPoint
			end,
			"maxHeight", 500,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end

	if ( tab:IsRegistered(self.button) ) then
		tab:SetColor(self.button, 0, 0, 0)
		tab:SetTransparency(self.button, 0.75)
		tab:SetFontSizePercent(self.button, 1.0)
	end

	gOnline = guildonline
	if ( SLDataText.db.profile.locked and not db.hideTooltip and gOnline > 0 ) then
		self.button:SetScript("OnEnter", function() if ( tab:IsRegistered(self.button) ) then tab:Open(self.button) end end)
	else
		self.button:SetScript("OnEnter", nil)
	end

	-- Here we fetch the color, determine any display options, and set the value of the module data
	local color = SLDataText:GetColor()
	self.string:SetFormattedText("|cff%s%s|r %d", color, db.secText or L["Guild:"], guildonline)

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end