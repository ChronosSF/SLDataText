-- SLDataText Copyright (c) 2008 - 2013 Jeff "Taffu" Fancher <jdfancher@gmail.com> All rights reserved.
-- This is a Fan-Edition Update by Karaswa

local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local tab = LibStub("Tablet-2.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "FriendList"
local FriendList = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local fList, fOnline
local classColors = nil

--[[ CLASS COLORS ]]--
local classColors = {}
local class_clr_tbl = {}
local class_game,class_localized

FillLocalizedClassList(class_clr_tbl) -- fill temporary table with MALE class names
for class_game,class_localized in pairs(class_clr_tbl) do -- create localized MALE color strings
	classColors[class_localized] = "|c"..RAID_CLASS_COLORS[class_game].colorStr
end


FillLocalizedClassList(class_clr_tbl, true) -- fill temporary table with FEMALE class names
for class_game,class_localized in pairs(class_clr_tbl) do
	classColors[class_localized] = "|c"..RAID_CLASS_COLORS[class_game].colorStr
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
		SLDataText:RefreshModule(FriendList)
	end
end

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["FriendList"],
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
						FriendList:PLAYER_ENTERING_WORLD()
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
					SLDataText:RefreshModule(FriendList)
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

local function buildPopup(self)
	self.popup:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = false,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, top = 4, right = 4, bottom = 4 },
	})
	self.popup:SetBackdropColor(0, 0, 0, 1)
	if ( not self.popup.name ) then self.popup.name = self.popup:CreateFontString(nil, "OVERLAY") end
	if ( not self.popup.note ) then self.popup.note = self.popup:CreateFontString(nil, "OVERLAY") end
	if ( not self.popup.button ) then self.popup.button = CreateFrame("Button", nil, self.popup, "UIPanelButtonTemplate") end
	-- Use default fonts
	self.popup.name:SetFont("Fonts\\FRIZQT__.ttf", 16)
	self.popup.name:SetJustifyH("LEFT")
	self.popup.name:SetWidth(256)
	self.popup.note:SetFont("Fonts\\FRIZQT__.ttf", 12)
	self.popup.note:SetJustifyH("LEFT")
	self.popup.note:SetWidth(256)
	-- Setup the frame
	self.popup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self.popup:SetWidth(268)
	self.popup:SetHeight(84)
	self.popup.name:SetPoint("TOPLEFT", self.popup, "TOPLEFT", 6, -6)
	self.popup.note:SetPoint("TOPLEFT", self.popup.name, "BOTTOMLEFT", 0, -8)
	-- Setup the close button
	self.popup.button:SetPoint("BOTTOM", self.popup, "BOTTOM", 0, 6)
	self.popup.button:SetWidth(100)
	self.popup.button:SetHeight(20)
	self.popup.button:RegisterForClicks("LeftButtonUp")
	self.popup.button:SetText("Close")
	self.popup.button:SetScript("OnClick", function()
	self.popup:Hide()
	end)
end

local function buildModule(self)
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_FriendList", UIParent) end -- The frame
	if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string
	if ( not self.popup ) then self.popup = CreateFrame("Frame", nil, UIParent) end -- Note popup frame

	-- Set scripts/etc.
	self.button:SetScript("OnClick", function()
		if ( IsShiftKeyDown() ) then
			ToggleFriendsFrame(1)
		end
	end)

	buildPopup(self)
	FriendList:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function FriendList:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function FriendList:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			secText = L["Friends:"],
			ttPoint = "CENTER",
			ttfPoint = "TOP",
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
			offY = 40,
			strata = "BACKGROUND",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

--[[ ENABLE MODULE AND SHOW ]]--
function FriendList:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("FRIENDLIST_UPDATE", "Refresh")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", "Refresh")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", "Refresh")
	buildModule(self)
	if ( self.popup:IsShown() ) then self.popup:Hide() end
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

--[[ DISABLE MODULE AND HIDE ]]--
function FriendList:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("FRIENDLIST_UPDATE")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self.button:SetScript("OnClick", nil)
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

--[[ POPUP FOR SHIFT-KEY ACTION ]]--
local function initPopup(name)
	local cname, note
	for _, val in ipairs(fList) do
		if ( val[9] == name ) then
			cname, note = val[1], val[8]
		end
	end
	FriendList.popup.name:SetText(cname)
	FriendList.popup.note:SetText(note)
	FriendList.popup:Show()
end


--[[ LEFT MOUSE KLICK ACTIONS ON PLAYER IN FRIENDLIST ]]--
local function clickFunc(faction,client,realid,name,realm,preid)
local p_realm = GetRealmName()
local p_efac, p_lfac = UnitFactionGroup("player")
	if ( not name ) then return end

	-- Alt-Key Action: Invite
	if ( IsAltKeyDown() ) then
		if(realm == "") then
			InviteUnit(name)
		else
			InviteUnit(name.."-"..realm)
		end

	-- Shift-key Action: Information
	elseif ( IsShiftKeyDown() ) then
		initPopup(name)

	-- Normal Klick Action: If not WoW or same Realm then B.Net-Whisper otherwise Char-Whisper
	else
		if(preid == "") then
			SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
		else
			if(client=="WoW" and realm == p_realm and faction == p_lfac) then
				SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
			else
				local name = realid..":"..preid
				SetItemRef( "BNplayer:"..name, ("|HBNplayer:%1$s|h[%1$s]|h"):format(name), "LeftButton" )
			end
		end
	end
end

--[[ TABLE FOR SHOWING PLAYERS IN FRIENDLIST AND DATA FOR MOUSE CLICK ACTION ]]--
local function updateTablet()
	if ( fOnline > 0 ) then
		ShowFriends()
		local header = tab:AddCategory()
		header:AddLine('text', L["Friend List"], 'size', 14)

		local col = {}
		tinsert(col, L["Name"])
		tinsert(col, L["Level"])
		tinsert(col, L["Class"])
		tinsert(col, L["Area"])
		tinsert(col, L["Faction"])
		tinsert(col, L["Game"])

		local cat = tab:AddCategory("columns", #col)
		local header = {}
		for i = 1, #col do
			if ( i == 1 ) then
				header['text'] = col[i]
				header['justify'] = "CENTER"
			else
				header['text'..i] = col[i]
				header['justify'..i] = "CENTER"
			end
		end
		cat:AddLine(header)
		for _, val in ipairs(fList) do
			local line = {}
			for i = 1, #col do
				if ( i == 1 ) then
					line['text'] = val[i]
					line['justify'] = "LEFT"
--                  line['func'] = function() clickFunc(val[7],val[9]) end
					line['func'] = function() clickFunc(val[5],val[6],val[7],val[9],val[10],val[11]) end
				elseif ( i == 3 ) then
					line['text'..i] = val[i]
					line['justify'..i] = "CENTER"
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
		tab:SetHint(L["FLHint"])
	end
end

-- Main update, used to refresh your modules data
function FriendList:Refresh()
	-- Gather your data
	fList = nil
	local friendsonline = 0
	local pfaction = UnitFactionGroup("player")
	local numBNetTotal, numBNetOnline = BNGetNumFriends()

	for i = 1, GetNumFriends() do
		local name, lvl, class, area, online, status, note = GetFriendInfo(i)
		if ( online ) then
			friendsonline = friendsonline + 1
			if ( not fList or fList == nil ) then fList = {} end
			local classColor = classColors[class]
			class = format("%s%s|r", classColor, class)

			local cname
			if ( status == "" and name ) then
				cname = format("%s%s|r", classColor, name)
			elseif ( name ) then
				cname = format("%s %s%s|r", status, classColor, name)
			end

--          tinsert(fList, { cname, lvl, class, area, pfaction, "WoW", name, note, "" })
			tinsert(fList, { cname, lvl, class, area, pfaction, "WoW", "", note, name, "", "" })
--			tinsert(fList, { cname, lvl, class, area, faction, client, realname, note, name, realmName })
		end
	end

--	for t = 1, BNGetNumFriends() do   //FAN-UPDATE Karaswa
	for t = 1, numBNetOnline do
--      local BNid,BNfirstname,BNlastname,toonname, toonid, client, online, lastonline,isafk, isdnd, broadcast, note = BNGetFriendInfo(t) //FAN-UPDATE Karaswa
		local BNid, presenceName, battleTag, isBattleTagPresence, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note, isRIDFriend, messageTime, canSoR = BNGetFriendInfo(t)

		if(not toonname) then
			toonname = "blub"
		end
--[[
		local nToons = BNGetNumFriendToons( friendId ) ;
		if (nToons > 1) then
			for toonIndx=1,nToons do
				local hasFocus, toonName, client, realmName, faction, race, class, guild, zoneName, level, gameText = BNGetFriendToonInfo( friendId, toonIdx ) ;
			end
		end
		]]

		if ( online and client=="WoW") then
--			_,name, _, realmName, _, faction, race, class, guild, area, lvl = BNGetToonInfo(toonid) //FAN-UPDATE Karaswa
			hasFocus, name, client, realmName, realmID, faction, race, class, guild, area, lvl, gameText, broadcastText, broadcastTime, isOnline, presenceID = BNGetToonInfo(toonid);
			friendsonline = friendsonline + 1
			if ( not fList or fList == nil ) then fList = {} end
			local classColor = classColors[class]
			if ( not classColor) then
				classColor = "|cffffffff"
			end
			class = format("%s%s|r", classColor, class)
			local cname
--			local realname = format("%s %s", BNfirstname, BNlastname)
			local realname = presenceName
			if(realmName==GetRealmName()) then
				if ( not isafk and not isdnd and name ) then
					cname = format("%s%s (%s)|r", classColor, name, realname)
				elseif (isafk and name ) then
					cname = format("%s %s%s (%s)|r", "AFK", classColor, name, realname)
				elseif(isdnd and name) then
					cname = format("%s %s%s (%s)|r", "DND", classColor, name, realname)
				end
			else
				if ( not isafk and not isdnd and name ) then
					cname = format("%s%s-%s (%s)|r", classColor, name, realmName, realname)
				elseif (isafk and name ) then
					cname = format("%s %s%s-%s (%s)|r", "AFK", classColor, name, realmName, realname)
				elseif(isdnd and name) then
					cname = format("%s %s%s-%s (%s)|r", "DND", classColor, name, realmName, realname)
				end
			end
--			if(faction=="0") then //FAN-UPDATE Karaswa
--				faction = "Horde"
--			else
--				faction = "Alliance"
--			end
			tinsert(fList, { cname, lvl, class, area, faction, client, realname, note, name, realmName, presenceID })
		elseif( online and client=="S2" ) then
--			_,name, _, realmName, faction, race, class, guild, area, lvl, gametext = BNGetToonInfo(toonid)
			hasFocus, name, clientblizz, realmName, realmID, faction, race, class, guild, area, lvl, gameText, broadcastText, broadcastTime, isOnline, presenceID = BNGetToonInfo(toonid);
			client = "SC2"
			friendsonline = friendsonline + 1
			if ( not fList or fList == nil ) then fList = {} end
			local cname
--			local realname = format("%s %s", BNfirstname, BNlastname)
			local realname = presenceName
			if ( not isafk and not isdnd and toonname ) then
				cname = format("|cff00FF00%s (%s)|r",toonname, realname)
			elseif (isafk and toonname ) then
				cname = format("|cffffffff%s %s (%s)|r", "AFK", toonname, realname)
			elseif(isdnd and toonname) then
				cname = format("|cffffffff%s %s (%s)|r", "DND", toonname, realname)
			end

--			tinsert(fList, { cname, "", "", gametext, "", client, realname, note })
			tinsert(fList, { cname, "", "", gameText, "", client, realname, note, name, realmName, presenceID })
		elseif( online and client=="D3" ) then
--			_,name, _, realmName, faction, race, class, guild, area, lvl, gametext = BNGetToonInfo(toonid)
			hasFocus, name, clientblizz, realmName, realmID, faction, race, class, guild, area, lvl, gameText, broadcastText, broadcastTime, isOnline, presenceID = BNGetToonInfo(toonid);
			--client = "D3"
			friendsonline = friendsonline + 1
			if ( not fList or fList == nil ) then fList = {} end
			local cname
--			local realname = format("%s %s", BNfirstname, BNlastname)
			local realname = presenceName
			if ( not isafk and not isdnd and toonname ) then
				cname = format("|cffff00cc%s (%s)|r",toonname, realname)
			elseif (isafk) then
				--cname = format("|cffffffff%s %s (%s)|r", "AFK "..toonname, realname)
				cname = format("|cffff00ccAFK "..toonname.." ("..realname..")|r")
			elseif(isdnd and toonname) then
				cname = format("|cffff00cc%s %s (%s)|r", "DND "..toonname, realname)
			end

--			tinsert(fList, { cname, "", "", gametext, "", client, realname, note })
			tinsert(fList, { cname, "", "", gameText, "", client, realname, note, name, realmName, presenceID })
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

	fOnline = friendsonline
	if ( SLDataText.db.profile.locked and not db.hideTooltip and fOnline > 0 ) then
		self.button:SetScript("OnEnter", function() if ( tab:IsRegistered(self.button) ) then tab:Open(self.button) end end)
	else
		self.button:SetScript("OnEnter", nil)
	end

	-- Here we fetch the color, determine any display options, and set the value of the module data
	local color = SLDataText:GetColor()
	self.string:SetFormattedText("|cff%s%s|r %d", color, db.secText or L["Friends:"], friendsonline)

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end