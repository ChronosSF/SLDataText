local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db, charDB

local MODNAME = "Mail"
local Mail = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Mail)
	end
end

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["Mail"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenMailSet"],
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
						Mail:PLAYER_ENTERING_WORLD()
					end
				end,
				order = 50,
			},
			showTotal = {
				type = "toggle",
				name = L["ShowTotal"],
				desc = L["ShowTotalDesc"],
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
					SLDataText:RefreshModule(Mail)
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

local zoned = false
local checked = false
local ignoreTrigger = false
local closeDelay = 5
local lastCheck

function Mail:PLAYER_ENTERING_WORLD()
	zoned = true
	SLDataText:RefreshModule(self)
end

local function buildModule(self)
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Mail", UIParent) end -- The frame
	-- if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string

	-- Set scripts/etc.

end

function Mail:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			showTotal = true,
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
			offY = 40,
			strata = "BACKGROUND",
		},
		char = {
			newmail = 0,
			totalmail = 0,
		},
	})
	db = self.db.profile
	charDB = self.db.char

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Mail:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("MAIL_CLOSED")
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MAIL_INBOX_UPDATE")
	self:RegisterEvent("UPDATE_PENDING_MAIL")

	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Mail:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("MAIL_CLOSED")
	self:UnregisterEvent("MAIL_SHOW")
	self:UnregisterEvent("MAIL_INBOX_UPDATE")
	self:UnregisterEvent("UPDATE_PENDING_MAIL")

	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

function Mail:UPDATE_PENDING_MAIL()
	if ( zoned ) then zoned = false self:Refresh() return end
	if ( lastCheck and ( lastCheck + closeDelay ) > GetTime() ) then ignoreTrigger = true end

	if ( ignoreTrigger ) then
		ignoreTrigger = false
		return
	else
		if ( not self.MailDup ) then self.MailDup = 1 end

		if ( self.MailDup < 2 ) then
			charDB.newmail, charDB.totalmail = charDB.newmail + 1, charDB.totalmail + 1
			if ( checked ) then charDB.totalmail = GetInboxNumItems() + charDB.newmail end
			self.MailDup = self.MailDup + 1
			self:Refresh()
		else
			self.MailDup = 1
		end
	end
end

function Mail:MAIL_INBOX_UPDATE()
	charDB.newmail = 0
	_,charDB.totalmail = GetInboxNumItems()
	self:Refresh()
end

function Mail:MAIL_SHOW()
	checked = true
	self:Refresh()
end

function Mail:MAIL_CLOSED()
	if ( checked ) then checked = false end
	lastCheck = GetTime()
end

function Mail:Refresh()
	-- Gather your data
	local mailcount, mailnote

	if ( db.showTotal ) then
		if ( charDB.totalmail > 0 ) then
			mailcount = format("%d/%d", charDB.newmail, charDB.totalmail)
		else
			mailcount = ""
		end
	else
		if ( charDB.newmail > 0 ) then
			mailcount = format("%d", charDB.newmail)
		else
			mailcount = ""
		end
	end

	if ( HasNewMail() and not checked ) then -- If new mail, not checked
		mailnote = L["New!"]
		mailcount = ""
	elseif ( not HasNewMail() and charDB.totalmail > 0 ) then -- If not new mail, regardless of check state
		if ( db.showTotal ) then
			mailnote = L["Mail:"]
		else
			mailnote = L["No Mail"]
		end
	else -- No mail (New or Total)
		mailnote = L["No Mail"]
	end

	if ( SLDataText.db.profile.locked and not db.hideTooltip and HasNewMail() ) then
		self.frame:SetScript("OnEnter", function(this)
			MinimapMailFrameUpdate()

			local send1, send2, send3 = GetLatestThreeSenders()
			local toolText

			GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
			if( sender1 or sender2 or sender3 ) then
				toolText = HAVE_MAIL_FROM
			else
				toolText = HAVE_MAIL
			end

			if( sender1 ) then
				toolText = toolText.."\n"..sender1
			end
			if( sender2 ) then
				toolText = toolText.."\n"..sender2
			end
			if( sender3 ) then
				toolText = toolText.."\n"..sender3
			end
			GameTooltip:SetText(toolText)
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

	if ( MiniMapMailFrame:IsShown() ) then MiniMapMailFrame:Hide() MiniMapMailFrame.Show = function() end end

	-- Here we fetch the color, determine any display options, and set the value of the module data
	local color = SLDataText:GetColor()
	self.string:SetFormattedText("|cff%s%s|r %s", color, mailnote, mailcount)

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end