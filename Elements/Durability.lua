local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")
local justTable, strataTable, pointTable = SLDataText.just, SLDataText.strata, SLDataText.point
local db

local MODNAME = "Durability"
local Durability = SLDataText:NewModule(MODNAME, "AceEvent-3.0")

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return db[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		db[key] = value
		SLDataText:RefreshModule(Durability)
	end
end

local options
local function getOptions()
	if not options then options = {
		type = "group",
		name = L["Durability"],
		arg = MODNAME,
		get = optGetter,
		set = optSetter,
		args = {
			genHeader = {
				type = "header",
				name = L["GenDurSet"],
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
						Durability:PLAYER_ENTERING_WORLD()
					end
				end,
				order = 100,
			},
			autoRepair = {
				type = "toggle",
				name = L["AutoRep"],
				desc = L["AutoRepDesc"],
				order = 125,
			},
			useGFunds = {
				type = "toggle",
				name = L["UseGFunds"],
				desc = L["UseGFundsDesc"],
				disabled = function()
					local isTrue
					if ( db.autoRepair ) then isTrue = false else isTrue = true end
					return isTrue
				end,
				order = 150,
			},
			hideTooltip = {
				type = "toggle",
				name = L["HideTT"],
				desc = L["HideTTDesc"],
				order = 175,
			},
			noCombatHide = {
				type = "toggle",
				name = L["SIC"],
				desc = L["SICDesc"],
				order = 200,
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
				order = 350,
			},
			useGlobalFontSize = {
				type = "toggle",
				name = L["UseGblFSize"],
				desc = L["UseGblFSizeDesc"],
				order = 400,
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
					SLDataText:RefreshModule(Durability)
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
	if ( not self.frame ) then self.frame = CreateFrame("Frame", "SLDT_Durability", UIParent) end -- The frame
	-- if ( not self.button ) then self.button = CreateFrame("Button", nil, self.frame) end -- The button (optional)
	if ( not self.string ) then self.string = self.frame:CreateFontString(nil, "OVERLAY") end -- The font string

	-- Set scripts/etc.

	Durability:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Durability:PLAYER_ENTERING_WORLD()
	SLDataText:RefreshModule(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Durability:OnInitialize()
	self.db = SLDataText.db:RegisterNamespace(MODNAME)
	-- Register your modules default settings
	self.db:RegisterDefaults({
		profile = {
			autoRepair = false,
			useGFunds = false,
			secText = L["Armor:"],
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
			offY = 20,
			strata = "BACKGROUND",
		},
	})
	db = self.db.profile

	if ( not self.isMoving ) then self.isMoving = false end
	self:SetEnabledState(SLDataText:GetModuleEnabled(MODNAME))
	SLDataText:RegisterModuleOptions(MODNAME, getOptions)
end

function Durability:OnEnable()
	-- Register any events, and hide elements you don't want shown
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "Refresh")
	self:RegisterEvent("MERCHANT_SHOW", "Merchant")

	buildModule(self)
	if ( not self.frame:IsShown() ) then self.frame:Show() end
end

function Durability:OnDisable()
	-- Unregister any events, nil scripts, and show elements you've hidden
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_SHOW")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if ( self.frame:IsShown() ) then self.frame:Hide() end
end

local slotNameTbl = {
	[1] = { slot = "HeadSlot", name = L["Head"] },
	[2] = { slot = "ShoulderSlot", name = L["Shoulder"] },
	[3] = { slot = "ChestSlot", name = L["Chest"] },
	[4] = { slot = "WaistSlot", name = L["Waist"] },
	[5] = { slot = "WristSlot", name = L["Wrist"] },
	[6] = { slot = "HandsSlot", name = L["Hands"] },
	[7] = { slot = "LegsSlot", name = L["Legs"] },
	[8] = { slot = "FeetSlot", name = L["Feet"] },
	[9] = { slot = "MainHandSlot", name = L["Main Hand"] },
	[10] = { slot = "SecondaryHandSlot", name = L["Off Hand"] },
	[11] = { slot = "RangedSlot", name = L["Ranged"] },
}

local function convertMoney(money)
	local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
	local cash = format("%d|cffffd700g|r %d|cffc7c7cfs|r %d|cffeda55fc|r", gold, silver, copper)
	return cash
end

function Durability:Merchant()
	if ( db.autoRepair ) then
		local canRepair = CanMerchantRepair()
		local repairCost, needRepair = GetRepairAllCost()
		if ( canRepair and needRepair ) then
			local repairCostStr = convertMoney(repairCost)
--			if ( CanGuildBankRepair() and useGFunds ) then
			if ( CanGuildBankRepair() and not useGFunds ) then --// FAN-UPDATE Karaswa (i loved this function and now it WORKS !!!)
				RepairAllItems(1)
				ChatFrame1:AddMessage(format("|cffffff00SLDT Durability|r repaired your equipment for %s (from guild bank)", repairCostStr))
			else
				RepairAllItems()
				ChatFrame1:AddMessage(format("|cffffff00SLDT Durability|r repaired your equipment for %s", repairCostStr))
			end
		end
		self:Refresh()
	end
end

-- Main update, used to refresh your modules data
function Durability:Refresh()
	-- Gather your data
	local slotInfo = { }
	local durability
	local minVal = 100

	for i = 1, 10 do --// FAN-UPDATE Karaswa (Range slot removed)
		if ( not slotInfo[i] ) then tinsert(slotInfo, i, { equip, value, max, perc }) end
		local slotID = GetInventorySlotInfo(slotNameTbl[i].slot)
		local itemLink = GetInventoryItemLink("player", slotID)
		local value, maximum = 0, 0
		if ( itemLink ~= nil ) then
			slotInfo[i].equip = true
			value, maximum = GetInventoryItemDurability(slotID)
		else
			slotInfo[i].equip = false
		end
		if ( slotInfo[i].equip and maximum ~= nil ) then
			slotInfo[i].value = value
			slotInfo[i].max = maximum
			slotInfo[i].perc = floor((slotInfo[i].value/slotInfo[i].max)*100)
		end
	end
	for i = 1, 10 do --// FAN-UPDATE Karaswa (Range slot removed)
		if ( slotInfo[i].equip and slotInfo[i].max ~= nil ) then
			if ( slotInfo[i].perc < minVal ) then minVal = slotInfo[i].perc end
		end
	end

	if ( SLDataText.db.profile.locked and not db.hideTooltip ) then
		self.frame:SetScript("OnEnter", function(this)
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
			GameTooltip:AddLine(format("%s%s|r", "|cffffff00", L["Durability Stats"]))
			GameTooltip:AddLine(" ")
			for i = 1, 10 do --// FAN-UPDATE Karaswa (Range slot removed)
				local durastring
				if ( slotInfo[i].equip and slotInfo[i].max ~= nil ) then
					if ( slotInfo[i].perc <= 50 ) then
						durastring = format("%s%d%%|r", "|cffffff00", slotInfo[i].perc)
					elseif ( slotInfo[i].perc <= 25 ) then
						durastring = format("%s%d%%|r", "|cffff0000", slotInfo[i].perc)
					else
						durastring = format("%d%%", slotInfo[i].perc)
					end
					GameTooltip:AddDoubleLine(slotNameTbl[i].name, durastring, 1, 1, 1, 1, 1, 1)
				end
			end
			GameTooltip:Show()
		end)
		self.frame:SetScript("OnLeave", function()
			if GameTooltip:IsShown() then
				GameTooltip:Hide()
			end
		end)
	else
		self.frame:SetScript("OnEnter", nil)
		self.frame:SetScript("OnLeave", nil)
	end

	-- Here we fetch the color, determine any display options, and set the value of the module data
	local color = SLDataText:GetColor()
	self.string:SetFormattedText("|cff%s%s|r %.0f%%", color, db.secText or L["Armor:"], minVal)

	-- And then update the module for refreshing/resizing text/frame
	SLDataText:UpdateModule(self)
end