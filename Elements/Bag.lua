local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "Bag"
local Bag = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Bag)
	end
end

local options
local function getOptions()
	if not options then
		options = {
			type = "group",
			name = L["Bag"],
			arg = MODNAME,
			get = optGetter,
			set = optSetter,
			args = {
				genHeader = {
					type = "header",
					name = L["GenBagSet"],
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
							Bag:PLAYER_ENTERING_WORLD()
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
				showRemaining = {
					type = "toggle",
					name = L["ShowRemSpace"],
					desc = L["ShowRemSpaceDesc"],
					order = 200,
				},
				showTotal = {
					type = "toggle",
					name = L["ShowTotSpace"],
					desc = L["ShowTotSpaceDesc"],
					order = 300,
				},
				hideAmmo = {
					type = "toggle",
					name = L["HAmmo"],
					desc = L["HAmmoDesc"],
					order = 350,
				},
				dispHeader = {
					type = "header",
					name = L["DispSet"],
					order = 400,
				},
				secText = {
					type = "input",
					name = L["SecText"],
					desc = L["SecTextDesc"],
					width = "double",
					order = 450,
				},
				useGlobalFont = {
					type = "toggle",
					name = L["UseGblFont"],
					desc = L["UseGblFontDesc"],
					order = 500,
				},
				useGlobalFontSize = {
					type = "toggle",
					name = L["UseGblFSize"],
					desc = L["UseGblFSizeDesc"],
					order = 550,
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
						SLDataText:RefreshModule(Bag)
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Bag", UIParent, BackdropTemplateMixin and "BackdropTemplate") end
	if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end

	self.button:SetScript("OnClick", function() OpenAllBags() end)

	Bag:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Bag:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Bag:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			showRemaining = false,
			showTotal = true,
			hideAmmo = false,
			secText = L["Bag:"],
			hideTooltip = false,
			noCombatHide = false,
			useGlobalFont = true,
			fontFace = "Arial Narrow",
			useGlobalFontSize = true,
			fontSize = 12,
			justify = "CENTER",
			anchorPoint = "CENTER",
			anchor = "UIParent",
			anchorFrom = "CENTER",
			offX = 200,
			offY = 0,
			strata = "BACKGROUND",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Bag:OnEnable()
	buildModule(self)
	self:RegisterEvent("BAG_UPDATE", "Refresh")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "Refresh")
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Bag:OnDisable()
	self:UnregisterEvent("BAG_UPDATE")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self.button:SetScript("OnClick", nil)
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

local function checkSubType(subType)
	local typeOk
	if ( subType == L["Quiver"] or subType == L["Ammo Pouch"] or subType == L["Soul Bag"] ) then
		typeOk = true
	else
		typeOk = false
	end
	return typeOk
end

function Bag:Refresh()
	local freeSlots, totalSlots = 0, 0
	local hasAmmoBag = false
	local ammoCount = 0
	for i = 0, 4 do
		local slots, slotsTotal = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
		if ( i >= 1 ) then
			local bagLink = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
			if ( bagLink ) then
				local subType = select(7, GetItemInfo(bagLink))
				if ( checkSubType(subType) ) then -- If ammo bag, we don't count and just setup the Ammo
					hasAmmoBag = true
					--// START
					--// FAN-UPDATE Karaswa (Soul Shards are gone with 5.0)
					--[[
					if ( select(2, UnitClass("player")) == "WARLOCK" ) then
						ammoCount = GetItemCount(6265)
					else
						local ammoSlotId = GetInventorySlotInfo("ammoSlot")
						ammoCount = GetInventoryItemCount("player", ammoSlotId)
					end
					]]--
					local ammoSlotId = GetInventorySlotInfo("ammoSlot")
					ammoCount = GetInventoryItemCount("player", ammoSlotId)
					--// END
				else -- Not ammo bag of some type, we count slots like normal
					freeSlots =  freeSlots + slots
					totalSlots = totalSlots + slotsTotal
				end
			end
		else -- Backpack, we count slots
			freeSlots =  freeSlots + slots
			totalSlots = totalSlots + slotsTotal
		end
		if ( not hasAmmoBag ) then
			--// START
			--// FAN-UPDATE Karaswa (Soul Shards are gone with 5.0)
			--[[
			if ( select(2, UnitClass("player")) == "WARLOCK" ) then
				ammoCount = GetItemCount(6265)
			else
				local slotID, _ = GetInventorySlotInfo("AmmoSlot")
				local count = GetInventoryItemCount("player", slotID)
				local itemLink = GetInventoryItemLink("player", slotID)
				if ( itemLink ~= nil and ( count ~= nil and count > 0 ) ) then
					ammoCount = count
				end
			end
			]]--
			local slotID, _ = GetInventorySlotInfo("AmmoSlot")
			local count = GetInventoryItemCount("player", slotID)
			local itemLink = GetInventoryItemLink("player", slotID)
			if ( itemLink ~= nil and ( count ~= nil and count > 0 ) ) then
				ammoCount = count
			end
			--// END
		end
	end
	local usedSlots = totalSlots - freeSlots
	if ( SLDataText.db.profile.locked and not db.hideTooltip ) then
		self.button:EnableMouse(true)
		self.button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:AddLine("|cffffff00" .. L["Bag Data"] .."|r")
			GameTooltip:AddLine(" ", 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Total:"], totalSlots, 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Used:"], usedSlots, 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Remaining:"], freeSlots, 1, 1, 1, 1, 1, 1)
			if ( ammoCount > 0 ) then
				GameTooltip:AddDoubleLine(L["Ammo:"], ammoCount, 1, 1, 1, 1, 1, 1)
			end
			GameTooltip:Show()
		end)
		self.button:SetScript("OnLeave", function()
			if ( GameTooltip:IsShown() ) then
				GameTooltip:Hide()
			end
		end)
	else
		self.button:EnableMouse(true)
		self.button:SetScript("OnEnter", nil)
		self.button:SetScript("OnLeave", nil)
	end
	local bagCount
	if ( db.showTotal and db.showRemaining ) then
		if ( db.hideAmmo or ammoCount == 0 ) then bagCount = format("%s/%s", freeSlots, totalSlots) else bagCount = format("%s/%s (%s)", freeSlots, totalSlots, ammoCount) end
	elseif ( db.showTotal and not db.showRemaining ) then
		if ( db.hideAmmo or ammoCount == 0 ) then bagCount = format("%s/%s", usedSlots, totalSlots) else bagCount = format("%s/%s (%s)", usedSlots, totalSlots, ammoCount) end
	elseif ( not db.showTotal and db.showRemaining ) then
		if ( db.hideAmmo or ammoCount == 0 ) then bagCount = format("%s", freeSlots) else bagCount = format("%s (%s)", freeSlots, ammoCount) end
	elseif ( not db.showTotal and not db.showRemaining ) then
		if ( db.hideAmmo or ammoCount == 0 ) then bagCount = format("%s", usedSlots) else bagCount = format("%s (%s)", usedSlots, ammoCount) end
	end

	local color = SLDataText:GetColor()
	self.string:SetFormattedText("|cff%s%s|r %s", color, db.secText or L["Bag:"], bagCount)

	SLDataText:UpdateModule(self)
end