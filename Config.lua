local SLDataText = LibStub("AceAddon-3.0"):GetAddon("SLDataText")
local L = LibStub("AceLocale-3.0"):GetLocale("SLDataText")
local media = LibStub("LibSharedMedia-3.0")

local function makeSlashCmd(...)
	local global = string.upper(SLDataText:GetName())
	SlashCmdList[global] = function() LibStub("AceConfigDialog-3.0"):Open("SLDataText") end
	for i = 1,select("#",...) do
		local slash = select(i,...)
		setglobal("SLASH_"..global..i,slash)
	end
end

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return SLDataText.db.profile[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		SLDataText.db.profile[key] = value
		SLDataText:Refresh()
	end
end

local options, moduleOptions = nil, {}
local function getOptions()
	if not options then
		options = {
			type = "group",
			name = L["SLDataText"],
			args = {
				general = {
					type = "group",
					name = L["GenSet"],
					guiInline = true,
					get = optGetter,
					set = optSetter,
					args = {
						locked = {
							type = "toggle",
							name = L["LockEle"],
							desc = L["LockEleDesc"],
							order = 100,
						},
						hideInCombat = {
							type = "toggle",
							name = L["HIC"],
							desc = L["HICDesc"],
							order = 200,
						},
					},
				},
				global = {
					type = "group",
					name = L["GblOpts"],
					get = optGetter,
					set = optSetter,
					order = 1,
					args = {
						gblFontHeader = {
							type = "header",
							name = L["GblFontSet"],
							order = 50,
						},
						gFont = {
							type = "select",
							name = L["GblFont"],
							desc = L["GblFontDesc"],
							values = media:List("font"),
							get = function()
								for k, v in pairs(media:List("font")) do
									if SLDataText.db.profile.gFont == v then
										return k
									end
								end
							end,
							set = function(_, font)
								local list = media:List("font")
								SLDataText.db.profile.gFont = list[font]
								SLDataText:Refresh()
							end,
							width = "double",
							order = 100,
						},
						gFontSize = {
							type = "range",
							name = L["GblFontSize"],
							desc = L["GblFontSizeDesc"],
							min = 6, max = 36, step = 1,
							order = 200,
						},
						fontOutline = {
							type = "toggle",
							name = L["GblFontOut"],
							desc = L["GblFontOutDesc"],
							order = 250,
						},
						gColor = {
							type = "input",
							name = L["GblClr"],
							desc = L["GblClrDesc"],
							disabled = function()
								local isTrue
								if ( SLDataText.db.profile.gColorClass ) then isTrue = true else isTrue = false end
								return isTrue
							end,
							order = 300,
						},
						gColorClass = {
							type = "toggle",
							name = L["GblClClr"],
							desc = L["GblClClrDesc"],
							order = 350,
						},
						mIHdr = {
							type = "header",
							name = L["MoreInfo"],
							order = 1000,
						},
						moreInfo = {
							type = "description",
							name = L["MoreInfoDesc"],
							order = 1100,
						},
					},
				},
			},
		}
		for key, val in pairs(moduleOptions) do
			options.args[key] = (type(val) == "function") and val() or val
		end
	end

	return options
end

function SLDataText:BuildConfig()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SLDataText", getOptions)
	makeSlashCmd(L["/sldt"], L["/sldatatext"])
	self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
end

function SLDataText:RegisterModuleOptions(name, optionTbl)
	moduleOptions[name] = optionTbl
end