SLASH_PLACER1 = "/placer"

local frame = CreateFrame("FRAME", "Placer")

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")

local loaded = false
local throttled = false


-- Polymorph
-- Sheep, Pig, Turtle, Black Cat, Rabbit, Monkey, Porcupine, Polar Bear Cub, Direhorn, Bumblebee
local poly = {
	-- Alliance
	["Gloria"] 	= "Sheep",
	["Wes"] 	= "Bumblebee",
	["Prue"] 	= "Polar Bear Cub",
	["See"] 	= "Sheep",
	["Norah"] 	= "Bumblebee",
	["Ki"] 		= "Black Cat",
	["Gunn"] 	= "Pig",
	["Debbie"] 	= "Rabbit",
	["Patricia"]= "Bumblebee",
	["Lum"] 	= "Bumblebee",
	["En"] 		= "Porcupine",
	["Floyd"] 	= "Rabbit",
	-- Horde
	["Aguna"] 	= "Pig",
	["Hazel"] 	= "Black Cat",
	["Zoom"] 	= "Monkey",
	["Bab"] 	= "Black Cat",
	["Joan"] 	= "Direhorn",
	["Arx"] 	= "Sheep",
	["Carolyn"] = "Turtle",
	["Eska"] 	= "Rabbit",
	["Ling"] 	= "Porcupine",
	["Felix"]   = "Rabbit",
}

-- Hex
-- Frog, Compy, Living Honey, Spider, Snake, Cockroach, Skeletal Hatchling, Zandalari Tendonripper, Wicker Mongrel
local hex = {
	-- Alliance
	["Ellika"] = "Living Honey",
	-- Horde
	["Sandy"] 	= "Cockroach",
	["Krosh"] 	= "Frog",
	["Echo"] 	= "Compy",
	["Myu"] 	= "Frog",
	["Flerm"] 	= "Cockroach",
	["Eeo"] 	= "Zandalari Tendonripper",
	["Veka"] 	= "Spider",
	["Zap"] 	= "Snake",
	["Spoon"] 	= "Cockroach",
	["Denzel"] 	= "Cockroach",
	["Chai"] 	= "Frog",
}

-- Treant Form
local treant = {
	["Frango"] = true,
}


local slotNames = {
	["1"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["CE"] = 8,
	["N"] = 13,
	["SN"] = 14,
	["R"] = 15,
	["SR"] = 16,
	["CR"] = 17,
	["H"] = 18,
	["SH"] = 19,
	["AE"] = 20,
	["J"] = 25,
	["SJ"] = 26,
	["CJ"] = 27,
	["AB3"] = 28,
	["AF"] = 29,
	["CF"] = 30,
	["SF"] = 31,
	["F"] = 32,
	["T"] = 37,
	["ST"] = 38,
	["CT"] = 39,
	["AT"] = 40,
	["CB3"] = 41,
	["SQ"] = 42,
	["SV"] = 43,
	["CV"] = 44,
	["F1"] = 49,
	["F2"] = 50,
	["F3"] = 51,
	["F4"] = 52,
	["F5"] = 53,
	["CQ"] = 54,
	["SX"] = 55,
	["X"] = 56,
	["C"] = 61,
	["SC"] = 62,
	["Q"] = 63,
	["E"] = 64,
	["G"] = 65,
	["SG"] = 66,
	["V"] = 67,
	["SE"] = 68,
	-- Bear Form
	["Bear 1"] = 97,
	["Bear 2"] = 98,
	["Bear 3"] = 99,
	["Bear 4"] = 100,
	["Bear 5"] = 101,
	["Bear 6"] = 102,
	["Bear 7"] = 103,
	["Bear CE"] = 104,
	["Bear C"] = 85,
	["Bear SC"] = 86,
	["Bear Q"] = 87,
	["Bear E"] = 88,
	["Bear G"] = 89,
	["Bear SG"] = 90,
	["Bear V"] = 91,
	["Bear SE"] = 92,
	-- Cat Form
	["Cat 1"] = 73,
	["Cat 2"] = 74,
	["Cat 3"] = 75,
	["Cat 4"] = 76,
	["Cat 5"] = 77,
	["Cat 6"] = 78,
	["Cat 7"] = 79,
	["Cat CE"] = 80,
	["Cat C"] = 109,
	["Cat SC"] = 110,
	["Cat Q"] = 111,
	["Cat E"] = 112,
	["Cat G"] = 113,
	["Cat SG"] = 114,
	["Cat V"] = 115,
	["Cat SE"] = 116,
	-- Hidden
	["Hidden 1"] = 9,
	["Hidden 2"] = 10,
}


local function m(name, icon, body)
	if icon == nil then
		icon = "INV_MISC_QUESTIONMARK"
	end
	EditMacro(name, nil, icon, body, 1, 1)
end


local function empty(slotName)
	local slotId = slotNames[slotName]
	PickupAction(slotId)
	ClearCursor()
end

local function spellById(slotId, spellId)
	local actionType, actionDataId, actionSubtype = GetActionInfo(slotId)
	local todo = "place"

	if actionType == "spell" and actionDataId == spellId then
		-- do nothing
	else
		--DEFAULT_CHAT_FRAME:AddMessage("placed "..spellId.." on slot "..slotId)
		-- Place spell
		PickupSpell(spellId)
		PlaceAction(slotId)
		ClearCursor()
	end
end

local function spell(slotName, spellName, requiredLevel)
	requiredLevel = requiredLevel or 1
	local level = UnitLevel("player")
	local slotId = slotNames[slotName]
	local _, _, _, _, _, _, spellId = GetSpellInfo(spellName)
	local actionType, actionDataId, actionSubtype = GetActionInfo(slotId)
	local todo = "place"

	if spellName == "Blessing of the Seasons" then
		if actionType == "spell" and (actionDataId == 328622 or actionDataId == 328281 or actionDataId == 328282 or actionDataId == 328620) then
			todo = nil
		end
	elseif level >= requiredLevel then
		if actionType == "spell" and spellId and actionDataId == spellId then
			todo = nil
		end
	else
		todo = "clear"
	end

	if todo == "place" then
		-- Place spell
		PickupAction(slotId)
		ClearCursor()

		-- Some spells have multiple spell IDs depending on talents or stance, attempt to pick up any
		-- /dump GetSpellInfo("Spell Name")
		if spellName == "Command Pet" then
			spellById(slotId, 272651) -- Always same ID
		elseif spellName == "Wildfire Bomb" then
			spellById(slotId, 259495) -- Always same ID
		elseif spellName == "Wild Charge" then
			spellById(slotId, 102401) -- Always same ID
		elseif spellName == "Honorable Medallion" then
			spellById(slotId, 195710) -- Always same ID
		elseif spellName == "Execute" then
			spellById(slotId, 163201) -- Arms
			spellById(slotId, 5308) -- Fury
		elseif spellName == "Swipe" then
			spellById(slotId, 213771) -- Feral or Guardian spec or affinity
			spellById(slotId, 213764) -- other spec or affinity
			spellById(slotId, 106785) -- Affinity+Cat Form
		elseif spellName == "Thrash" then
			spellById(slotId, 77758) -- Feral or Guardian spec or affinity
			spellById(slotId, 106832) -- other spec or affinity
		elseif spellName == "Moonfire" then
			spellById(slotId, 8921) -- no form
			spellById(slotId, 155625) -- Feral Cat Form
		elseif spellName == "Stampeding Roar" then
			spellById(slotId, 77761) -- Bear Form
			spellById(slotId, 77764) -- Cat Form
			spellById(slotId, 106898) -- no form or other forms
		elseif spellName == "Sigil of Flame" then
			spellById(slotId, 204513) -- Concentrated Sigils
			spellById(slotId, 204596) -- other talents
		elseif spellName == "Sigil of Silence" then
			spellById(slotId, 207682) -- Concentrated Sigils
			spellById(slotId, 202137) -- other talents
		elseif spellName == "Sigil of Misery" then
			spellById(slotId, 202140) -- Concentrated Sigils
			spellById(slotId, 207684) -- other talents
		elseif spellName == "Multi-Shot" then
			spellById(slotId, 240711) -- Sidewinders
			spellById(slotId, 2643) -- Multi-Shot
		elseif spellName == "Shadow Word: Death" then
			spellById(slotId, 199911) -- Reaper of Souls
			spellById(slotId, 32379) -- other talents
		elseif spellName == "Stealth" then
			spellById(slotId, 115191) -- Subterfuge
			spellById(slotId, 1784) -- other talents
		elseif spellName == "Summon Doomguard" then
			spellById(slotId, 157757) -- Grimoire of Supremacy
			spellById(slotId, 18540) -- other talents
		elseif spellName == "Summon Infernal" then
			spellById(slotId, 157898) -- Grimoire of Supremacy
			spellById(slotId, 1122) -- other talents
		elseif spellName == "Guardian of Ancient Kings" then
			spellById(slotId, 86659) -- GetSpellInfo() returns the wrong spell ID, this is the correct one
		elseif spellName == "Void Eruption" then
			spellById(slotId, 228260) -- Void Eruption
		elseif spellName == "Mind Control" then
			spellById(slotId, 605) -- Dominant Mind talent returns wrong spell ID
		elseif spellName == "Soulshape" then
			spellId = 310143
		elseif spellName == "Death and Decay" then
			spellId = 43265
		elseif spellName == "Unstable Affliction" then
			spellById(slotId, 316099) -- Correct ID
		elseif spellName == "Blessing of the Seasons" then
			spellById(slotId, 328282) -- Blessing of Spring
			spellById(slotId, 328620) -- Blessing of Summer
			spellById(slotId, 328622) -- Blessing of Autumn
			spellById(slotId, 328281) -- Blessing of Winter
		end

		-- Place spell
		PickupSpell(spellId)
		PlaceAction(slotId)
		ClearCursor()
	elseif todo == "clear" then
		-- Clear action button
		PickupAction(slotId)
		ClearCursor()
	end
end

local function toy(slotName, toyId, requiredLevel)
	requiredLevel = requiredLevel or 1
	local level = UnitLevel("player")
	local slotId = slotNames[slotName]
	local todo = "place"

	if level < requiredLevel then
		todo = "clear"
	end

	if todo == "place" then
		-- Clear action button
		PickupAction(slotId)
		ClearCursor()

		-- Place toy
		C_ToyBox.PickupToyBoxItem(toyId)
		PlaceAction(slotId)
		ClearCursor()
	elseif todo == "clear" then
		-- Clear action button
		PickupAction(slotId)
		ClearCursor()
	end
end

local function macro(slotName, macroName, requiredLevel)
	requiredLevel = requiredLevel or 1
	local level = UnitLevel("player")
	local slotId = slotNames[slotName]
	local actionType = GetActionInfo(slotId)
	local todo = "place"

	if level >= requiredLevel then
		if actionType == "macro" then
			local actionText = GetActionText(slotId)
			if macroName == actionText then
				todo = nil
			end
		end
	else
		if not actionType then
			todo = nil
		else
			todo = "clear"
		end
	end

	if todo == "place" then
		-- Place macro
		PickupAction(slotId)
		ClearCursor()
		PickupMacro(macroName)
		PlaceAction(slotId)
		ClearCursor()
	elseif todo == "clear" then
		-- Clear action button
		PickupAction(slotId)
		ClearCursor()
	end
end

local function usable(slotName, macroName, inventorySlot)
	local _,class = UnitClass("player")
	local spec = GetSpecialization()
	local role = "dps"
	if (class == "DEATHKNIGHT" and spec == 1) or (class == "DEMONHUNTER" and spec == 2) or (class == "DRUID" and spec == 3) or (class == "MONK" and spec == 1) or (class == "PALADIN" and spec == 2) or (class == "WARRIOR" and spec == 3) then
		role = "tank"
	elseif (class == "DRUID" and spec == 4) or (class == "MONK" and spec == 2) or (class == "PALADIN" and spec == 1) or (class == "PRIEST" and spec ~= 3) or (class == "SHAMAN" and spec == 2) then
		role = "healer"
	end
	local banned = false

	local slotId = slotNames[slotName]

	local itemLink = GetInventoryItemLink("player", inventorySlot)
	local itemSpell = GetItemSpell(itemLink)

	if role == "tank" and itemSpell == "Dusk Powder" then
		banned = true
	elseif role == "tank" and itemSpell == "Gloaming Powder" then
		banned = true
	elseif role == "tank" and itemSpell == "Twilight Powder" then
		banned = true
	end

	if itemSpell and not banned then
		-- Place macro
		print("place", slotName, macroName, itemSpell)
		macro(slotName, macroName)
	else
		print("empty", slotName, itemSpell)
		empty(slotName)
	end
end

local function item(slotName, itemName)
	local slotId = slotNames[slotName]
	--empty(slotName) -- Clear previous action bar data

	-- Place item
	PickupItem(itemName)
	PlaceAction(slotId)
	ClearCursor()
end

local function pvptalent(slotName, talentId)
	local slotId = slotNames[slotName]
	local actionType, actionDataId, actionSubtype = GetActionInfo(slotId)
	local _,_,_,_,_,spellId = GetPvpTalentInfoByID(talentId)
	local todo = "place"

	if actionType == "spell" and actionDataId == spellId then
		-- do nothing
	else
		-- Place PvP talent
		PickupAction(slotId)
		ClearCursor()
		PickupPvpTalent(talentId)
		PlaceAction(slotId)
		ClearCursor()
	end
end

local function racial(slotName)
	local slotId = slotNames[slotName]
	local _,race = UnitRace("player")
	local racials = {
		["BloodElf"] = "Arcane Torrent",
		["Draenei"] = "Gift of the Naaru",
		["DarkIronDwarf"] = "Fireblood",
		["Dwarf"] = "Stoneform",
		["Gnome"] = "Escape Artist",
		["Goblin"] = "Rocket Jump",
		["HighmountainTauren"] = "Bull Rush",
		["Human"] = "Will to Survive",
		["KulTiran"] = "Haymaker",
		["LightforgedDraenei"] = "Light's Judgment",
		["MagharOrc"] = "Ancestral Call",
		["Mechagnome"] = "Hyper Organic Light Originator",
		["Nightborne"] = "Arcane Pulse",
		["NightElf"] = "Shadowmeld",
		["Orc"] = "Blood Fury",
		["Pandaren"] = "Quaking Palm",
		["Scourge"] = "Will of the Forsaken",
		["Tauren"] = "War Stomp",
		["Troll"] = "Berserking",
		["VoidElf"] = "Spatial Rift",
		["Vulpera"] = "Bag of Tricks",
		["Worgen"] = "Darkflight",
		["ZandalariTroll"] = "Regeneratin'",
	}

	if racials[race] then
		spell(slotName, racials[race])
	else
		empty(slotName)
	end
end

local function signature(slotName)
	local _, _, _, _, _, _, kyrian = GetSpellInfo("Summon Steward")
	local _, _, _, _, _, _, nightfae = GetSpellInfo("Soulshape")
	local _, _, _, _, _, _, necrolord = GetSpellInfo("Fleshcraft")
	local _, _, _, _, _, _, venthyr = GetSpellInfo("Door of Shadows")

	if kyrian then
		spell(slotName, "Summon Steward")
	elseif nightfae then
		spell(slotName, "Soulshape")
	elseif necrolord then
		spell(slotName, "Fleshcraft")
	elseif venthyr then
		spell(slotName, "Door of Shadows")
	else
		empty(slotName)
	end
end

local function essence(slotName, kyrianSpell, necrolordSpell, nightfaeSpell, venthyrSpell)
	local covenant = C_Covenants and C_Covenants.GetActiveCovenantID() or 0
	local essence = select(7, GetSpellInfo("Concentrated Flame"))

	if covenant == 1 then
		if kyrianSpell then spell(slotName, kyrianSpell) else empty(slotName) end
	elseif covenant == 4 then
		if necrolordSpell then spell(slotName, necrolordSpell) else empty(slotName) end
	elseif covenant == 3 then
		if nightfaeSpell then spell(slotName, nightfaeSpell) else empty(slotName) end
	elseif covenant == 2 then
		if venthyrSpell then spell(slotName, venthyrSpell) else empty(slotName) end
	elseif essence then
		spell(slotName, "Heart Essence")
	else
		empty(slotName)
	end
end

local function custom(slotName, spellName, requiredLevel)
	requiredLevel = requiredLevel or 1
	local level = UnitLevel("player")
	local slotId = slotNames[slotName]
	local name = UnitName("player")
	local hexId = { ["Frog"] = 51514, ["Compy"] = 210873, ["Spider"] = 211004, ["Snake"] = 211010, ["Cockroach"] = 211015, ["Skeletal Hatchling"] = 269352, ["Zandalari Tendonripper"] = 277778, ["Wicker Mongrel"] = 277784, ["Living Honey"] = 309328, }
	local polyId = { ["Sheep"] = 118, ["Pig"] = 28272, ["Turtle"] = 28271, ["Black Cat"] = 61305, ["Rabbit"] = 61721, ["Monkey"] = 161354, ["Porcupine"] = 126819, ["Penguin"] = 161355, ["Polar Bear Cub"] = 161353, ["Direhorn"] = 277787, ["Bumblebee"] = 277792, }

	if level >= requiredLevel then
		if spellName == "Hex" then
			if hex[name] and IsSpellKnown(hexId[hex[name]]) then
				spellById(slotId, hexId[hex[name]])
			else
				spellById(slotId, hexId["Frog"])
			end
		elseif spellName == "Polymorph" then
			if poly[name] and IsSpellKnown(polyId[poly[name]]) then
				spellById(slotId, polyId[poly[name]])
			else
				spellById(slotId, polyId["Sheep"])
			end
		end
	else
		empty(slotName)
	end
end


local function updateBars()
	if InCombatLockdown() then
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		-- Update Global Pet Macros
		if Automagic then Automagic.UpdatePets() end

		-- CVars
		SetCVar("mapFade", 0)
		SetCVar("whisperMode", "inline")
		SetCVar("autoLootDefault", 1)
		SetCVar("displaySpellActivationOverlays", 0)
		SetCVar("worldPreloadNonCritical", 0)

		-- Local Variables
		local name = UnitName("player")
		local _,class = UnitClass("player")
		local faction = UnitFactionGroup("player")
		local level = UnitLevel("player")
		local spec = GetSpecialization()
		local talent = {}
		local timewalking = false
		local covenant = C_Covenants and C_Covenants.GetActiveCovenantID() or 0

		-- Calculate talents
		for i = 1, 7 do
			local k1, k2, k3 = false, false, false -- Legion talent rings use the 11th return value instead of the 4th
			talent[i] = {}
			_, _, _, talent[i][1], _, _, _, _, _, _, k1 = GetTalentInfo(i, 1, 1)
			if k1 then talent[i][1] = true end
			_, _, _, talent[i][2], _, _, _, _, _, _, k2 = GetTalentInfo(i, 2, 1)
			if k2 then talent[i][2] = true end
			_, _, _, talent[i][3], _, _, _, _, _, _, k3 = GetTalentInfo(i, 3, 1)
			if k3 then talent[i][3] = true end
		end

		-- Timewalking/Party Sync
		if level ~= UnitEffectiveLevel("player") then
			timewalking = true
		end


		-- Replace Character Macros
		local _, numCharMacros = GetNumMacros()
		local mi = 0

		if numCharMacros >= 1 then
			for i = 121, (121+numCharMacros) do
				mi = mi + 1
				local mp = "0"
				if mi >= 10 then
					mp = ""
				end
				EditMacro(i, "C"..mp..mi, "inv_misc_questionmark", "", 1, 1)
			end
		end

		if numCharMacros < 18 then
			for i = 1, (18-numCharMacros) do
				mi = mi + 1
				local mp = "0"
				if mi >= 10 then
					mp = ""
				end
				CreateMacro("C"..mp..mi, "inv_misc_questionmark", "", 1, 1)
			end
		end


		if class == "DEATHKNIGHT" then
			--! Death Knight
			
			-- Mind Freeze
			m("C01", nil, "#showtooltip Mind Freeze\n#showtooltip Mind Freeze\n/stopcasting\n/stopcasting\n/use Mind Freeze")
			-- Wraith Walk
			m("C02", nil, "#showtooltip Wraith Walk\n/use !Wraith Walk")
			-- Gorefiend's Grasp @player
			m("C03", nil, "#showtooltip Gorefiend's Grasp\n/use [@player]Gorefiend's Grasp")
			-- Gorefiend's Grasp @target
			m("C04", 1037260, "#showtooltip Gorefiend's Grasp\n/use [@target]Gorefiend's Grasp")
			-- Leap
			m("C05", 237569, "#showtooltip\n/use Leap")
			-- Huddle
			m("C06", 237533, "#showtooltip\n/use Huddle")
			-- Gnaw
			m("C07", 237524, "#showtooltip\n/use Gnaw")
			-- Sacrificial Pact
			m("C08", 136133, "#showtooltip\n/use [pet]Sacrificial Pact;Raise Dead")

			-- Essence
			essence("N", "Shackle the Unworthy", "Abomination Limb", (spec == 2 and "Death and Decay" or false), "Swarming Mist")

			if spec == 1 then
				--! Blood Death Knight
				spell("1", "Marrowrend")
				spell("2", "Blood Boil")
				spell("3", "Heart Strike")
				spell("4", "Death and Decay")
				spell("5", "Death Strike")
				spell("CE", "Asphyxiate")

				if talent[3][3] then spell("C", "Blood Tap") else empty("C") end
				if talent[7][3] then spell("SC", "Bonestorm") else empty("SC") end
				if talent[1][2] then spell("Q", "Blooddrinker") elseif talent[1][3] then spell("Q", "Tombstone") else empty("Q") end
				spell("E", "Death's Caress")
				spell("G", "Dancing Rune Weapon")
				empty("SG")
				if talent[4][3] then spell("V", "Mark of Blood") else empty("V") end
				macro("SE", "C01") -- Mind Freeze

				spell("R", "Dark Command")
				spell("SR", "Death Grip")
				macro("CR", "C03", 32) -- Gorefiend's Grasp @player
				spell("H", "Death Coil")
				macro("SH", "C04", 32) -- Gorefiend's Grasp @target

				spell("F1", "Rune Tap")
				spell("F2", "Anti-Magic Shell")
				spell("F3", "Icebound Fortitude")
				spell("F4", "Vampiric Blood")
				if talent[6][2] then spell("F5", "Death Pact") else empty("F5") end
				spell("CQ", "Path of Frost")

				spell("T", "Chains of Ice")
				empty("ST")
				spell("CT", "Control Undead")
				empty("AT")
				spell("CB3", "Anti-Magic Zone")
				if talent[2][3] then spell("SQ", "Consumption") else empty("SQ") end
				spell("SV", "Raise Dead")
				spell("CV", "Sacrificial Pact")

				empty("AB3")
				empty("AF")
				spell("CF", "Lichborne")
				spell("SF", "Death's Advance")
				if talent[5][3] then macro("F", "C02") else empty("F") end -- Wraith Walk
			elseif spec == 2 then
				--! Frost Death Knight
				spell("1", "Frost Strike")
				spell("2", "Obliterate")
				spell("3", "Remorseless Winter")
				spell("4", "Frostwyrm's Fury")
				if talent[7][3] then spell("5", "Breath of Sindragosa") else empty("5") end
				if talent[3][2] then spell("CE", "Asphyxiate") elseif talent [3][3] then spell("CE", "Blinding Sleet") else empty("CE") end

				if talent[6][2] then spell("C", "Hypothermic Presence") elseif talent[6][3] then spell("C", "Glacial Advance") else empty("C") end
				if talent[2][3] then spell("SC", "Horn of Winter") else empty("SC") end
				if talent[4][3] then spell("Q", "Frostscythe") else empty("Q") end
				spell("E", "Howling Blast")
				spell("G", "Empower Rune Weapon")
				empty("SG")
				spell("V", "Pillar of Frost")
				macro("SE", "C01") -- Mind Freeze

				spell("R", "Dark Command")
				spell("SR", "Death Grip")
				empty("CR")
				spell("H", "Death Coil")
				if covenant == 3 then empty("SH") else spell("SH", "Death and Decay") end

				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				if talent[5][3] then spell("F3", "Death Pact") else empty("F3") end
				empty("F4")
				empty("F5")
				spell("CQ", "Path of Frost")

				spell("T", "Chains of Ice")
				empty("ST")
				spell("CT", "Control Undead")
				empty("AT")
				spell("CB3", "Anti-Magic Zone")
				spell("SQ", "Death Strike")
				spell("SV", "Raise Dead")
				spell("CV", "Sacrificial Pact")

				empty("AB3")
				empty("AF")
				spell("CF", "Lichborne")
				spell("SF", "Death's Advance")
				if talent[5][2] then macro("F", "C02") else empty("F") end -- Wraith Walk
			elseif spec == 3 then
				--! Unholy Death Knight
				spell("1", "Festering Strike")
				spell("2", "Scourge Strike")
				spell("3", "Death Coil")
				spell("4", "Death and Decay")
				spell("5", "Apocalypse")
				if talent[3][3] then spell("CE", "Asphyxiate") else empty("CE") end

				if talent[4][3] then spell("C", "Soul Reaper") else empty("C") end
				if talent[2][3] then spell("SC", "Unholy Blight") else empty("SC") end
				spell("Q", "Epidemic")
				spell("E", "Outbreak")
				if level < 29 then spell("G", "Raise Dead") elseif talent[7][2] then spell("G", "Summon Gargoyle") elseif talent[7][3] then spell("G", "Unholy Assault") else empty("G") end
				empty("SG")
				spell("V", "Dark Transformation")
				macro("SE", "C01") -- Mind Freeze

				spell("R", "Dark Command")
				spell("SR", "Death Grip")
				macro("CR", "C07", 29) -- Gnaw
				empty("H")
				empty("SH")

				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				if talent[5][3] then spell("F3", "Death Pact") else empty("F3") end
				empty("F4")
				macro("F5", "C06", 29) -- Huddle
				spell("CQ", "Path of Frost")

				spell("T", "Chains of Ice")
				empty("ST")
				spell("CT", "Control Undead")
				macro("AT", "C05", 29) -- Leap
				spell("CB3", "Anti-Magic Zone")
				spell("SQ", "Death Strike")
				spell("SV", "Army of the Dead")
				spell("CV", "Sacrificial Pact")
				

				empty("AB3")
				empty("AF")
				spell("CF", "Lichborne")
				spell("SF", "Death's Advance")
				if talent[5][2] then macro("F", "C02") else empty("F") end -- Wraith Walk
			else
				--! Untalented Death Knight
				empty("1")
				empty("2")
				empty("3")
				empty("4")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				empty("Q")
				empty("E")
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				empty("SQ")
				empty("SV")
				empty("CV")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				empty("F")
			end
		elseif class == "DEMONHUNTER" then
			--! Demon Hunter
			
			-- Felblade/Demon's Bite
			m("C01", nil, "#showtooltip\n/use [talent:1/3,talent:2/3]Felblade;Demon's Bite")
			-- Metamorphosis @player
			m("C02", nil, "#showtooltip Metamorphosis\n/use [@player]Metamorphosis")
			-- Metamorphosis
			m("C03", 1344650, "#showtooltip\n/use Metamorphosis")
			-- Disrupt
			m("C04", nil, "#showtooltip Disrupt\n/stopcasting\n/stopcasting\n/use Disrupt")

			-- Essence
			essence("N", "Elysian Decree", false, "The Hunt", "Sinful Brand")

			if spec == 1 then
				--! Havoc Demon Hunter
				macro("1", "C01") -- Demon's Bite
				spell("2", "Chaos Strike")
				spell("3", "Blade Dance")
				spell("4", "Eye Beam")
				if talent[7][3] then spell("5", "Fel Barrage") else empty("5") end
				spell("CE", "Chaos Nova")

				if talent[1][3] and not talent[2][3] then spell("C", "Felblade") else empty("C") end
				empty("SC")
				if talent[3][3] then spell("Q", "Glaive Tempest") else empty("Q") end
				
				macro("G", "C02") -- Metamorphosis @player
				empty("SG")
				if talent[5][3] then spell("V", "Essence Break") else empty("V") end
				macro("SE", "C04") -- Disrupt
				spell("E", "Immolation Aura")
				spell("R", "Torment")
				spell("SR", "Consume Magic")
				empty("CR")
				spell("H", "Throw Glaive")
				empty("SH")

				spell("F1", "Blur")
				if talent[4][3] then spell("F2", "Netherwalk") else empty("F2") end
				spell("F3", "Darkness")
				empty("F4")
				empty("F5")
				empty("CQ")

				spell("T", "Imprison")
				empty("ST")
				if talent[6][3] then spell("CT", "Fel Eruption") else empty("CT") end
				empty("AT")
				empty("CB3")
				empty("SQ")
				macro("SV", "C03") -- Metamorphosis Leap
				spell("CV", "Spectral Sight")

				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Vengeful Retreat")
				spell("F", "Fel Rush")
			elseif spec == 2 then
				--! Vengeance Demon Hunter
				spell("1", "Shear")
				spell("2", "Soul Cleave")
				spell("3", "Demon Spikes")
				spell("4", "Sigil of Flame")
				if talent[3][3] then spell("5", "Spirit Bomb") else empty("5") end
				spell("CE", "Sigil of Misery")

				if talent[1][3] then spell("C", "Felblade") else empty("C") end
				empty("SC")
				if talent[7][3] then spell("Q", "Bulk Extraction") else empty("Q") end
				spell("E", "Immolation Aura")
				spell("G", "Metamorphosis")
				empty("SG")
				spell("V", "Fel Devastation")
				macro("SE", "C04") -- Disrupt

				spell("R", "Torment")
				spell("SR", "Consume Magic")
				if talent[5][3] then spell("CR", "Sigil of Chains") else empty("CR") end
				spell("H", "Throw Glaive")
				empty("SH")

				spell("F1", "Fiery Brand")
				if talent[6][3] then spell("F2", "Soul Barrier") else empty("F2") end
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				spell("T", "Imprison")
				spell("ST", "Sigil of Silence")
				empty("CT")
				empty("AT")
				empty("CB3")
				empty("SQ")
				empty("SV")
				spell("CV", "Spectral Sight")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Infernal Strike")
			else
				--! Untalented Demon Hunter
				spell("1", "Demon's Bite")
				spell("2", "Chaos Strike")
				spell("3", "Blade Dance")
				spell("4", "Eye Beam")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Immolation Aura")
				empty("G")
				empty("SG")
				empty("V")
				spell("SE", "Disrupt")

				spell("R", "Torment")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				empty("SQ")
				empty("SV")
				spell("CV", "Spectral Sight")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Fel Rush")
			end
		elseif class == "DRUID" then
			--! Druid
			
			-- Wrath/Regrowth
			m("C01", nil, "#showtooltip\n/use [help]Regrowth;[spec:1][spec:2,notalent:3/3][spec:3,notalent:3/3][spec:4,talent:3/1,form:4][harm]Wrath;Regrowth")
			-- Starfire/Swiftmend
			m("C02", nil, "#showtooltip\n/use [spec:1,talent:3/3,help][spec:4,talent:3/1,form:4,help]Swiftmend;[spec:1][spec:4,talent:3/1,stance:4][spec:4,talent:3/1,harm]Starfire;Swiftmend")
			-- Starsurge/Wild Growth
			m("C03", nil, "#showtooltip\n/use [spec:4,talent:3/1,form:4,help]Wild Growth;[spec:1,talent:3/3,help]Wild Growth;[spec:1][spec:4,talent:3/1,form:4][spec:4,talent:3/1,harm]Starsurge;Wild Growth")
			-- Sunfire/Lifebloom
			m("C04", nil, "#showtooltip\n/use [help]Lifebloom;[harm][talent:3/1,stance:4]Sunfire;Lifebloom")
			-- Moonfire/Rake/Rejuvenation
			m("C05", nil, "#showtooltip\n/use [nospec:4,talent:3/3,help]Rejuvenation;[spec:1,talent:3/1,form:2][spec:2,form:2][spec:3,talent:3/2,form:2][spec:4,talent:3/2,form:2]Rake;[harm][spec:3,form:1]Moonfire;[spec:4][nospec:1,nospec:4,talent:3/3]Rejuvenation;Moonfire")
			-- Moonkin Form/Flap
			m("C06", nil, "#showtooltip [spec:1][form:4]Flap;Moonkin Form\n/use [form:4]Flap;!Moonkin Form")
			-- Shred/Moonfire
			m("C07", nil, "#showtooltip\n/use [mod:shift,talent:1/3]Moonfire;Shred")
			-- Innervate
			m("C08", nil, "#showtooltip Innervate\n/use [@focus,help,nodead][exists,help,nodead][spec:4,@player]Innervate")
			-- Solar Beam/Skull Bash
			m("C09", nil, "#showtooltip [spec:1]Solar Beam;Skull Bash\n/stopcasting\n/stopcasting\n/use [spec:1]Solar Beam;[spec:2,noform:1,noform:2]Cat Form;[noform:1,noform:2]Bear Form\n/use [spec:2/3]Skull Bash")
			-- Dash
			m("C10", nil, "#showtooltip Dash\n/use [form:" .. (level >= 8 and "2" or "1") .. "]Dash;Cat Form")
			-- Bear Form
			m("C11", nil, "#showtooltip Bear Form\n/use [noform:1]Bear Form")
			-- Cat Form
			m("C12", nil, "#showtooltip Cat Form\n/use [noform:2]Cat Form")
			-- Caster Form
			m("C13", 461117, "/stopcasting\n/stopcasting\n/cancelform [noform:5]")
			-- Moonkin Form
			m("C14", nil, "#showtooltip Moonkin Form\n/stopcasting\n/stopcasting\n/use [noform:4]Moonkin Form")
			-- Treant Form
			m("C15", nil, "#showtooltip Treant Form\n/stopcasting\n/stopcasting\n/use [nospec:1,talent:3/1,noform:5][nospec:1,notalent:3/1,noform:4][spec:1,noform:5]Treant Form")
			-- Prowl
			m("C16", nil, "#showtooltip\n/cancelaura Travel Form\n/cancelaura [btn:2]Prowl\n/use [nobtn:2]!Prowl")
			-- Wild Charge
			m("C17", nil, "#showtooltip\n/cancelform [help,form]\n/use Wild Charge")
			-- Primal Wrath/Rip
			m("C18", nil, "#showtooltip\n/use [mod:shift,talent:6/3]Primal Wrath;Rip")

			-- Essence
			essence("N", "Kindred Spirits", "Adaptive Swarm", "Convoke the Spirits", "Ravenous Frenzy")

			if spec == 1 then
				--! Balance Druid
				macro("1", "C01")
				macro("2", "C02")
				if level >= 12 then macro("3", "C03") else empty("3") end
				spell("4", "Sunfire")
				if talent[6][3] then spell("5", "Stellar Flare") else empty("5") end
				if talent[4][1] then spell("CE", "Mighty Bash") else empty("CE") end

				if talent[7][2] then spell("C", "Fury of Elune") elseif talent[7][3] then spell("C", "New Moon") else empty("C") end
				macro("SC", "C08", 42) -- Innervate
				spell("Q", "Starfall")
				macro("E", "C05") -- Moonfire/Rejuvenation
				spell("G", "Celestial Alignment")
				if talent[4][3] then spell("SG", "Heart of the Wild") else empty("SG") end
				if talent[1][2] then spell("V", "Warrior of Elune") elseif talent[1][3] then spell("V", "Force of Nature") else empty("V") end
				macro("SE", "C09", 26) -- Solar Beam

				spell("Bear 1", "Mangle")
				if talent[3][2] then spell("Bear 2", "Thrash") else empty("Bear 2") end
				if talent[3][1] then spell("Bear 3", "Swipe") else empty("Bear 3") end
				spell("Bear 4", "Ironfur")
				empty("Bear 5")
				if talent[4][1] then spell("Bear CE", "Mighty Bash") else empty("Bear CE") end

				empty("Bear C")
				macro("Bear SC", "C08", 42) -- Innervate
				if talent[3][2] then spell("Bear Q", "Frenzied Regeneration") else empty("Bear Q") end
				empty("Bear E")
				empty("Bear G")
				if talent[4][3] then spell("Bear SG", "Heart of the Wild") else empty("Bear SG") end
				empty("Bear V")
				macro("Bear SE", "C09", 26) -- Solar Beam

				spell("Cat 1", "Shred")
				if talent[3][1] then spell("Cat 2", "Swipe") else empty("Cat 2") end
				spell("Cat 3", "Ferocious Bite")
				if talent[3][1] then spell("Cat 4", "Rip") else empty("Cat 4") end
				if talent[3][1] then spell("Cat 5", "Maim") else empty("Cat 5") end
				if talent[4][1] then spell("Cat CE", "Mighty Bash") else empty("Cat CE") end

				empty("Cat C")
				macro("Cat SC", "C08", 42) -- Innervate
				if talent[3][2] then spell("Cat Q", "Thrash") else empty("Cat Q") end
				if talent[3][1] then macro("Cat E", "C05") else empty("Cat E") end -- Rake
				empty("Cat G")
				if talent[4][3] then spell("Cat SG", "Heart of the Wild") else empty("Cat SG") end
				empty("Cat V")
				macro("Cat SE", "C09", 26) -- Solar Beam

				spell("R", "Growl")
				spell("SR", "Soothe")
				spell("CR", "Remove Corruption")
				if talent[2][2] then spell("H", "Renewal") else empty("H") end
				spell("SH", "Hibernate")

				spell("F1", "Barkskin")
				macro("F2", "C11") -- Bear Form
				empty("F3")
				empty("F4")
				empty("F5")
				macro("CQ", "C06") -- Flap

				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				if talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				if talent[3][2] then spell("AT", "Incapacitating Roar") else empty("AT") end
				spell("CB3", "Typhoon")
				spell("SQ", "Regrowth")
				if level >= 21 then macro("SV", "C14") else macro("SV", "C13") end -- Moonkin Form
				macro("CV", "C16", 13) -- Prowl

				if talent[3][3] then spell("AB3", "Ursol's Vortex") else empty("AB3") end
				spell("AF", "Travel Form")
				if talent[2][3] then macro("CF", "C17") else empty("CF") end -- Wild Charge
				spell("SF", "Stampeding Roar", 43)
				macro("F", "C10") -- Dash
			elseif spec == 2 then
				--! Feral Druid
				macro("1", "C01")
				if talent[3][1] then spell("2", "Starfire") elseif talent[3][3] then spell("2", "Swiftmend") else empty("2") end
				if talent[3][1] then spell("3", "Starsurge") elseif talent[3][3] then spell("3", "Wild Growth") else empty("3") end
				if talent[3][1] then spell("4", "Sunfire") else empty("4") end
				empty("5")
				if talent[4][1] then spell("CE", "Mighty Bash") else empty("CE") end

				empty("C")
				empty("SC")
				empty("Q")
				macro("E", "C05") -- Moonfire/Rejuvenation
				empty("G")
				if talent[4][3] then spell("SG", "Heart of the Wild") else empty("SG") end
				empty("V")
				macro("SE", "C09", 26) -- Skull Bash

				spell("Bear 1", "Mangle")
				spell("Bear 2", "Thrash", 11)
				if not talent[6][2] then spell("Bear 3", "Swipe") else empty("Bear 3") end
				spell("Bear 4", "Ironfur")
				empty("Bear 5")
				if talent[4][1] then spell("Bear CE", "Mighty Bash") else empty("Bear CE") end

				empty("Bear C")
				empty("Bear SC")
				if talent[3][2] then spell("Bear Q", "Frenzied Regeneration") else empty("Bear Q") end
				empty("Bear E")
				empty("Bear G")
				if talent[4][3] then spell("Bear SG", "Heart of the Wild") else empty("Bear SG") end
				empty("Bear V")
				macro("Bear SE", "C09", 26) -- Skull Bash

				if talent[1][3] then macro("Cat 1", "C07") else spell("Cat 1", "Shred") end
				spell("Cat 2", "Swipe")
				spell("Cat 3", "Ferocious Bite")
				if talent[6][3] then macro("Cat 4", "C18") else spell("Cat 4", "Rip") end
				spell("Cat 5", "Maim")
				if talent[4][1] then spell("Cat CE", "Mighty Bash") else empty("Cat CE") end

				if talent[5][2] then spell("Cat C", "Savage Roar") else empty("Cat C") end
				if talent[7][3] then spell("Cat SC", "Feral Frenzy") else empty("Cat SC") end
				spell("Cat Q", "Thrash", 11)
				macro("Cat E", "C05") -- Rake/Rejuvenation
				spell("Cat G", "Berserk")
				if talent[4][3] then spell("Cat SG", "Heart of the Wild") else empty("Cat SG") end
				spell("Cat V", "Tiger's Fury")
				macro("Cat SE", "C09", 26) -- Skull Bash

				spell("R", "Growl")
				spell("SR", "Soothe")
				spell("CR", "Remove Corruption")
				if talent[2][2] then spell("H", "Renewal") else empty("H") end
				spell("SH", "Hibernate")

				spell("F1", "Barkskin")
				macro("F2", "C11") -- Bear Form
				spell("F3", "Survival Instincts")
				empty("F4")
				empty("F5")
				if talent[3][1] then macro("CQ", "C06") else empty("CQ") end -- Moonkin Form/Flap

				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				if talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				if talent[3][2] then spell("AT", "Incapacitating Roar") else empty("AT") end
				if talent[3][1] then spell("CB3", "Typhoon") else empty("CB3") end
				spell("SQ", "Regrowth")
				macro("SV", "C12") -- Cat Form
				macro("CV", "C16", 13) -- Prowl

				if talent[3][3] then spell("AB3", "Ursol's Vortex") else empty("AB3") end
				spell("AF", "Travel Form")
				if talent[2][3] then macro("CF", "C17") else empty("CF") end -- Wild Charge
				spell("SF", "Stampeding Roar", 43)
				macro("F", "C10") -- Dash
			elseif spec == 3 then
				--! Guardian Druid
				macro("1", "C01")
				if talent[3][1] then spell("2", "Starfire") elseif talent[3][3] then spell("2", "Swiftmend") else empty("2") end
				if talent[3][1] then spell("3", "Starsurge") elseif talent[3][3] then spell("3", "Wild Growth") else empty("3") end
				if talent[3][1] then spell("4", "Sunfire") else empty("4") end
				if talent[4][3] and talent[3][1] then spell("5", "Heart of the Wild") else empty("5") end
				if talent[4][1] then spell("CE", "Mighty Bash") else empty("CE") end

				empty("C")
				empty("SC")
				empty("Q")
				macro("E", "C05") -- Moonfire/Rejuvenation
				empty("G")
				if talent[4][3] then spell("SG", "Heart of the Wild") else empty("SG") end
				empty("V")
				macro("SE", "C09", 26) -- Skull Bash

				spell("Bear 1", "Mangle")
				spell("Bear 2", "Thrash", 11)
				spell("Bear 3", "Swipe")
				spell("Bear 4", "Ironfur")
				spell("Bear 5", "Maul")
				if talent[4][1] then spell("Bear CE", "Mighty Bash") else empty("Bear CE") end

				if talent[1][3] then spell("Bear C", "Bristling Fur") else empty("Bear C") end
				empty("Bear SC")
				spell("Bear Q", "Frenzied Regeneration")
				macro("Bear E", "C05") -- Moonfire/Rejuvenation
				spell("Bear G", "Berserk")
				if talent[4][3] then spell("Bear SG", "Heart of the Wild") else empty("Bear SG") end
				empty("Bear V")
				macro("Bear SE", "C09", 26) -- Skull Bash

				spell("Cat 1", "Shred")
				spell("Cat 2", "Swipe")
				spell("Cat 3", "Ferocious Bite")
				if talent[3][2] then spell("Cat 4", "Rip") else empty("Cat 4") end
				if talent[3][2] then spell("Cat 5", "Maim") else empty("Cat 5") end
				if talent[4][1] then spell("Cat CE", "Mighty Bash") else empty("Cat CE") end

				empty("Cat C")
				empty("Cat SC")
				spell("Cat Q", "Thrash", 11)
				if talent[3][2] then macro("Cat E", "C05") else empty("Cat E") end
				empty("Cat G")
				if talent[4][3] then spell("Cat SG", "Heart of the Wild") else empty("Cat SG") end
				empty("Cat V")
				macro("Cat SE", "C09", 26) -- Skull Bash

				spell("R", "Growl")
				spell("SR", "Soothe")
				spell("CR", "Remove Corruption")
				if talent[2][2] then spell("H", "Renewal") else empty("H") end
				spell("SH", "Hibernate")

				spell("F1", "Barkskin")
				spell("F2", "Survival Instincts")
				if talent[7][3] then spell("F3", "Pulverize") else empty("F3") end
				empty("F4")
				empty("F5")
				if talent[3][1] then macro("CQ", "C06") else empty("CQ") end -- Moonkin Form/Flap

				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				if talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				spell("AT", "Incapacitating Roar")
				if talent[3][1] then spell("CB3", "Typhoon") else empty("CB3") end
				spell("SQ", "Regrowth")
				macro("SV", "C11") -- Bear Form
				macro("CV", "C16", 13) -- Prowl

				if talent[3][3] then spell("AB3", "Ursol's Vortex") else empty("AB3") end
				spell("AF", "Travel Form")
				if talent[2][3] then macro("CF", "C17") else empty("CF") end -- Wild Charge
				spell("SF", "Stampeding Roar", 43)
				macro("F", "C10") -- Dash
			elseif spec == 4 then
				--! Restoration Druid
				macro("1", "C01") -- Regrowth/Wrath
				macro("2", "C02", 11) -- Swiftmend/Starfire
				macro("3", "C03", 34) -- Wild Growth/Starsurge
				if level >= 23 then macro("4", "C04") else spell("4", "Lifebloom") end -- Lifebloom/Sunfire
				if talent[1][2] then spell("5", "Nourish") elseif talent[1][3] then spell("5", "Cenarion Ward") else empty("5") end
				if talent[4][1] then spell("CE", "Mighty Bash") else empty("CE") end

				if talent[6][3] then spell("C", "Overgrowth") else empty("C") end
				macro("SC", "C08", 42) -- Innervate
				spell("Q", "Efflorescence")
				macro("E", "C05") -- Rejuvenation/Moonfire
				if talent[5][3] then spell("G", "Incarnation: Tree of Life") else empty("G") end
				if talent[4][3] then spell("SG", "Heart of the Wild") else empty("SG") end
				spell("V", "Nature's Swiftness")
				spell("SE", "Ironbark")

				spell("Bear 1", "Mangle")
				if talent[3][3] then spell("Bear 2", "Thrash") else empty("Bear 2") end
				if talent[3][2] then spell("Bear 3", "Swipe") else empty("Bear 3") end
				spell("Bear 4", "Ironfur")
				empty("Bear 5")
				if talent[4][1] then spell("Bear CE", "Mighty Bash") else empty("Bear CE") end

				empty("Bear C")
				macro("Bear SC", "C08", 42) -- Innervate
				if talent[3][3] then spell("Bear Q", "Frenzied Regeneration") else empty("Bear Q") end
				empty("Bear E")
				if talent[5][3] then spell("Bear G", "Incarnation: Tree of Life") else empty("Bear G") end
				if talent[4][3] then spell("Bear SG", "Heart of the Wild") else empty("Bear SG") end
				spell("Bear V", "Nature's Swiftness")
				spell("Bear SE", "Ironbark")

				spell("Cat 1", "Shred")
				if talent[3][2] then spell("Cat 2", "Swipe") else empty("Cat 2") end
				spell("Cat 3", "Ferocious Bite")
				if talent[3][2] then spell("Cat 4", "Rip") else empty("Cat 4") end
				if talent[3][2] then spell("Cat 5", "Maim") else empty("Cat 5") end
				if talent[4][1] then spell("Cat CE", "Mighty Bash") else empty("Cat CE") end

				empty("Cat C")
				macro("Cat SC", "C08", 42) -- Innervate
				if talent[3][3] then spell("Cat Q", "Thrash") else empty("Cat Q") end
				if talent[3][2] then macro("Cat E", "C05") else empty("Cat E") end -- Rake
				if talent[5][3] then spell("Cat G", "Incarnation: Tree of Life") else empty("Cat G") end
				if talent[4][3] then spell("Cat SG", "Heart of the Wild") else empty("Cat SG") end
				spell("Cat V", "Nature's Swiftness")
				spell("Cat SE", "Ironbark")

				spell("R", "Growl")
				spell("SR", "Soothe")
				spell("CR", "Nature's Cure")
				if talent[2][2] then spell("H", "Renewal") else empty("H") end
				spell("SH", "Hibernate")

				spell("F1", "Barkskin")
				macro("F2", "C11") -- Bear Form
				spell("F3", "Tranquility")
				if talent[7][3] then spell("F4", "Flourish") else empty("F4") end
				empty("F5")
				if talent[3][1] then macro("CQ", "C06") else empty("CQ") end -- Moonkin Form/Flap

				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				if talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				if talent[3][3] then spell("AT", "Incapacitating Roar") else empty("AT") end
				if talent[3][1] then spell("CB3", "Typhoon") else empty("CB3") end
				spell("SQ", "Regrowth")
				if treant[name] then macro("SV", "C15") else macro("SV", "C13") end -- Treant/Caster Form
				macro("CV", "C16", 13) -- Prowl

				spell("AB3", "Ursol's Vortex")
				spell("AF", "Travel Form")
				if talent[2][3] then macro("CF", "C17") else empty("CF") end -- Wild Charge
				spell("SF", "Stampeding Roar", 43)
				macro("F", "C10") -- Dash
			else
				--! Untalented Druid
				spell("1", "Wrath")
				empty("2")
				empty("3")
				empty("4")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Moonfire", 2)
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				spell("Cat 1", "Shred")
				empty("Cat 2")
				spell("Cat 3", "Ferocious Bite")
				empty("Cat 4")
				empty("Cat 5")
				empty("Cat CE")

				empty("Cat C")
				empty("Cat SC")
				empty("Cat Q")
				empty("Cat E")
				empty("Cat G")
				empty("Cat SG")
				empty("Cat V")
				empty("Cat SE")

				spell("Bear 1", "Mangle")
				empty("Bear 2")
				empty("Bear 3")
				empty("Bear 4")
				empty("Bear 5")
				empty("Bear CE")

				empty("Bear C")
				empty("Bear SC")
				empty("Bear Q")
				empty("Bear E")
				empty("Bear G")
				empty("Bear SG")
				empty("Bear V")
				empty("Bear SE")

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				macro("F2", "C11", 8)
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				empty("T")
				spell("ST", "Entangling Roots")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Regrowth")
				macro("SV", "C13", 5)
				empty("CV")


				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				if level >= 6 then macro("F", "C10") else spell("F", "Cat Form") end
			end

			-- All Druid Specs
			macro("Bear 6", "G026")
			macro("Bear 7", "G027")
			macro("Cat 6", "G026")
			macro("Cat 7", "G027")
		elseif class == "HUNTER" then
			--! Hunter

			-- Counter Shot/Muzzle
			m("C01", nil, "#showtooltip [spec:3]Muzzle;Counter Shot\n/stopcasting\n/stopcasting\n/use [spec:3]Muzzle;Counter Shot")
			-- Growl
			m("C02", 132270, "#showtooltip Growl\n/use [nobtn:2]Growl\n/petautocasttoggle [btn:2]Growl")
			-- Kill Command
			m("C03", nil, "#showtooltip Kill Command\n/petattack\n/petassist\n/use Kill Command")
			-- Misdirection
			m("C04", nil, "#showtooltip Misdirection\n/use [@focus,help][help][@pet,exists][]Misdirection")
			-- Mend Pet/Revive Pet
			m("C05", nil, "#showtooltip\n/use [@pet,dead][nopet]Revive Pet;Mend Pet")
			-- Tranquilizing Shot
			m("C06", 132323, "#showtooltip\n/use Tranquilizing Shot")
			-- Aspect of the Turtle
			m("C07", nil, "#showtooltip\n/use !Aspect of the Turtle")

			-- Essence
			essence("N", "Resonating Arrow", "Death Chakram", "Wild Spirits", "Flayed Shot")

			if spec == 1 then
				--! Beast Mastery Hunter
				if level < 14 then spell("1", "Arcane Shot") else spell("1", "Cobra Shot") end
				if level < 12 then spell("2", "Steady Shot") else spell("2", "Barbed Shot") end
				macro("3", "C03") -- Kill Command
				spell("4", "Kill Shot")
				if talent[2][3] then spell("5", "Chimaera Shot") else empty("5") end
				spell("CE", "Intimidation")

				if talent[6][2] then spell("C", "Barrage") elseif talent[6][3] then spell("C", "Stampede") else empty("C") end
				if talent[1][3] then spell("SC", "Dire Beast") else empty("SC") end
				spell("Q", "Multi-Shot")
				if talent[4][3] then spell("E", "A Murder of Crows") else empty("E") end
				spell("G", "Aspect of the Wild")
				empty("SG")
				spell("V", "Bestial Wrath")
				macro("SE", "C01", 18) -- Counter Shot

				macro("R", "C02") -- Growl
				macro("SR", "C06", 37) -- Tranquilizing Shot
				macro("CR", "G019", 22) -- Pet Ability
				if talent[7][3] then spell("H", "Bloodshed") else empty("H") end
				empty("SH")

				spell("F1", "Exhilaration")
				macro("F2", "C07", 8)-- Aspect of the Turtle
				macro("F3", "G020", 22) -- Exotic Ability
				if talent[3][3] then spell("F4", "Camouflage") else empty("F4") end
				spell("F5", "Aspect of the Chameleon")
				macro("CQ", "C04", 27) -- Misdirection

				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				spell("CT", "Tar Trap")
				spell("AT", "Scare Beast")
				if talent[5][3] then spell("CB3", "Binding Shot") else empty("CB3") end
				macro("SQ", "C05") -- Mend Pet/Revive Pet
				spell("SV", "Command Pet", 22)
				spell("CV", "Feign Death")

				spell("AB3", "Flare")
				spell("AF", "Hunter's Mark")
				empty("CF")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")
			elseif spec == 2 then
				--! Marksmanship Hunter
				spell("1", "Arcane Shot")
				spell("2", "Steady Shot")
				spell("3", "Aimed Shot")
				spell("4", "Kill Shot")
				spell("5", "Rapid Fire")
				spell("CE", "Bursting Shot")

				if talent[2][2] then spell("C", "Barrage") elseif talent[2][3] then spell("C", "Explosive Shot") else empty("C") end
				if talent[7][3] then spell("SC", "Volley") else empty("SC") end
				spell("Q", "Multi-Shot")
				if talent[1][2] then spell("E", "Serpent Sting") elseif talent[1][3] then spell("E", "A Murder of Crows") else empty("E") end
				spell("G", "Trueshot")
				empty("SG")
				if talent[6][3] then spell("V", "Double Tap") else empty("V") end
				macro("SE", "C01", 18) -- Counter Shot

				macro("R", "C02") -- Growl
				macro("SR", "C06", 37) -- Tranquilizing Shot
				macro("CR", "G019", 22) -- Pet Ability
				empty("H")
				empty("SH")

				spell("F1", "Exhilaration")
				macro("F2", "C07", 8)-- Aspect of the Turtle
				empty("F3")
				if talent[3][3] then spell("F4", "Camouflage") else empty("F4") end
				spell("F5", "Aspect of the Chameleon")
				macro("CQ", "C04", 27) -- Misdirection

				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				spell("CT", "Tar Trap")
				spell("AT", "Scare Beast")
				spell("CB3", "Binding Shot")
				spell("SQ", "Mend Pet")
				spell("SV", "Command Pet", 22)
				spell("CV", "Feign Death")

				spell("AB3", "Flare")
				spell("AF", "Hunter's Mark")
				empty("CF")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")
			elseif spec == 3 then
				--! Survival Hunter
				spell("1", "Raptor Strike")
				spell("2", "Wildfire Bomb")
				macro("3", "C03", 11) -- Kill Command
				spell("4", "Kill Shot")
				if talent[6][3] then spell("5", "Flanking Strike") else empty("5") end
				spell("CE", "Intimidation")

				if talent[4][2] then spell("C", "Steel Trap") elseif talent[4][3] then spell("C", "A Murder of Crows") else empty("C") end
				if talent[7][3] then spell("SC", "Chakrams") else empty("SC") end
				spell("Q", "Carve")
				spell("E", "Serpent Sting")
				spell("G", "Coordinated Assault")
				empty("SG")
				spell("V", "Aspect of the Eagle")
				macro("SE", "C01", 18) -- Muzzle

				macro("R", "C02") -- Growl
				macro("SR", "C06", 37) -- Tranquilizing Shot
				macro("CR", "G019", 22) -- Pet Ability
				empty("H")
				empty("SH")

				spell("F1", "Exhilaration")
				macro("F2", "C07", 8)-- Aspect of the Turtle
				empty("F3")
				if talent[3][3] then spell("F4", "Camouflage") else empty("F4") end
				spell("F5", "Aspect of the Chameleon")
				macro("CQ", "C04", 27) -- Misdirection

				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				spell("CT", "Tar Trap")
				spell("AT", "Scare Beast")
				if talent[5][3] then spell("CB3", "Binding Shot") else empty("CB3") end
				macro("SQ", "C05") -- Mend Pet/Revive Pet
				spell("SV", "Command Pet", 22)
				spell("CV", "Feign Death")

				spell("AB3", "Flare")
				spell("AF", "Hunter's Mark")
				spell("CF", "Harpoon")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")
			else
				--! Untalented Hunter
				if level >= 2 then spell("1", "Arcane Shot") else spell("1", "Steady Shot") end
				if level >= 2 then spell("2", "Steady Shot") else empty("2") end
				empty("3")
				empty("4")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				empty("Q")
				empty("E")
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				spell("F1", "Exhilaration")
				macro("F2", "C07", 8)-- Aspect of the Turtle
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				empty("CT")
				empty("AT")
				empty("CB3")
				macro("SQ", "C05") -- Mend Pet/Revive Pet
				spell("SV", "Tame Beast")
				spell("CV", "Feign Death")

				empty("AB3")
				spell("AF", "Hunter's Mark")
				empty("CF")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")
			end
		elseif class == "MAGE" then
			--! Mage

			-- Counterspell
			m("C01", nil, "#showtooltip Counterspell\n/stopcasting\n/stopcasting\n/use Counterspell")
			-- Ice Block
			m("C02", nil, "#showtooltip Ice Block\n/use !Ice Block")
			-- Freeze
			m("C03", 1698698, "#showtooltip\n/use Freeze")
			-- Ice barrier
			m("C04", 135843, "#showtooltip\n/use Ice Barrier")
			-- Mana Gem
			m("C05", 134132, "#showtooltip\n/use Mana Gem\n/use Conjure Mana Gem")

			-- Essence
			essence("N", "Radiant Spark", "Deathborne", "Shifting Power", "Mirrors of Torment")

			if spec == 1 then
				--! Arcane Mage
				spell("1", "Arcane Blast")
				spell("2", "Arcane Missiles")
				spell("3", "Arcane Barrage")
				spell("4", "Touch of the Magi")
				if talent[6][2] then spell("5", "Arcane Orb") elseif talent[6][3] then spell("5", "Supernova") else empty("5") end
				spell("CE", "Frost Nova")

				spell("C", "Evocation")
				macro("SC", "C05", 17) -- Mana Gem
				spell("Q", "Arcane Explosion")
				if talent[4][3] then spell("E", "Nether Tempest") else empty("E") end
				spell("G", "Arcane Power")
				empty("SG")
				spell("V", "Presence of Mind")
				macro("SE", "C01") -- Counterspell

				if talent[3][3] then spell("R", "Rune of Power") else empty("R") end
				spell("SR", "Spellsteal")
				spell("CR", "Remove Curse")
				spell("H", "Fire Blast")
				empty("SH")

				spell("F1", "Prismatic Barrier")
				macro("F2", "C02", 22) -- Ice Block
				spell("F3", "Mirror Image")
				empty("F4")
				empty("F5")
				spell("CQ", "Slow Fall")

				custom("T", "Polymorph")
				spell("ST", "Slow")
				spell("CT", "Frostbolt")
				empty("AT")
				if talent[5][3] then spell("CB3", "Ring of Frost") else empty("CB3") end
				empty("SQ")
				spell("SV", "Time Warp")
				spell("CV", "Invisibility")

				empty("AB3")
				empty("AF")
				spell("CF", "Alter Time")
				empty("SF")
				spell("F", "Blink")
			elseif spec == 2 then
				--! Fire Mage
				spell("1", "Fireball")
				spell("3", "Pyroblast")
				spell("3", "Fire Blast")
				spell("4", "Phoenix Flames")
				if talent[7][3] then spell("5", "Meteor") else empty("5") end
				spell("CE", "Frost Nova")

				spell("C", "Scorch")
				empty("SC")
				spell("Q", "Flamestrike")
				if talent[6][3] then spell("E", "Living Bomb") else empty("E") end
				spell("G", "Combustion")
				empty("SG")
				spell("V", "Dragon's Breath")
				macro("SE", "C01") -- Counterspell

				if talent[3][3] then spell("R", "Rune of Power") else empty("R") end
				spell("SR", "Spellsteal")
				spell("CR", "Remove Curse")
				empty("H")
				spell("SH", "Arcane Explosion")

				spell("F1", "Blazing Barrier")
				macro("F2", "C02", 22) -- Ice Block
				spell("F3", "Mirror Image")
				empty("F4")
				empty("F5")
				spell("CQ", "Slow Fall")

				custom("T", "Polymorph")
				spell("ST", "Frostbolt")
				if talent[2][3] then spell("CT", "Blast Wave") else empty("CT") end
				empty("AT")
				if talent[5][3] then spell("CB3", "Ring of Frost") else empty("CB3") end
				empty("SQ")
				spell("SV", "Time Warp")
				spell("CV", "Invisibility")

				empty("AB3")
				empty("AF")
				spell("CF", "Alter Time")
				empty("SF")
				spell("F", "Blink")
			elseif spec == 3 then
				--! Frost Mage
				spell("1", "Frostbolt")
				spell("2", "Ice Lance")
				spell("3", "Flurry")
				spell("4", "Frozen Orb")
				if talent[6][3] then spell("5", "Comet Storm") else empty("5") end
				spell("CE", "Frost Nova")

				if talent[4][3] then spell("C", "Ebonbolt") else empty("C") end
				empty("SC")
				spell("Q", "Blizzard")
				if talent[1][3] then spell("E", "Ice Nova") else empty("E") end
				spell("G", "Icy Veins")
				empty("SG")
				if talent[7][2] then spell("V", "Ray of Frost") elseif talent[7][3] then spell("V", "Glacial Spike") else empty("V") end
				macro("SE", "C01") -- Counterspell

				if talent[3][3] then spell("R", "Rune of Power") else empty("R") end
				spell("SR", "Spellsteal")
				spell("CR", "Remove Curse")
				spell("H", "Fire Blast")
				spell("SH", "Arcane Explosion")

				macro("F1", "C04", 11) -- Ice Barrier
				macro("F2", "C02", 22) -- Ice Block
				spell("F3", "Mirror Image")
				empty("F4")
				empty("F5")
				spell("CQ", "Slow Fall")

				custom("T", "Polymorph")
				spell("ST", "Cone of Cold")
				if not talent[1][2] then macro("CT", "C03", 23) else empty("CT") end -- Freeze
				empty("AT")
				if talent[5][3] then spell("CB3", "Ring of Frost") else empty("CB3") end
				empty("SQ")
				spell("SV", "Time Warp")
				spell("CV", "Invisibility")

				empty("AB3")
				empty("AF")
				spell("CF", "Alter Time")
				if talent[2][3] then spell("SF", "Ice Floes") else empty("SF") end
				spell("F", "Blink")
			else
				--! Untalented Mage
				spell("1", "Frostbolt")
				spell("2", "Fire Blast")
				empty("3")
				empty("4")
				empty("5")
				spell("CE", "Frost Nova")

				empty("C")
				empty("SC")
				spell("Q", "Arcane Explosion")
				empty("E")
				empty("G")
				empty("SG")
				empty("V")
				if level >= 7 then macro("SE", "C01") else empty("SE") end -- Counterspell

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				spell("CQ", "Slow Fall")

				custom("T", "Polymorph")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				empty("SQ")
				empty("SV")
				empty("CV")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Blink")
			end
		elseif class == "MONK" then
			--! Monk

			-- Soothing Mist/Tiger Palm
			m("C01", nil, "#showtooltip\n/use [harm]Tiger Palm;Soothing Mist")
			-- Enveloping Mist/Rising Sun Kick
			m("C02", nil, "#showtooltip\n/use [harm]Rising Sun Kick;Enveloping Mist")
			-- Vivify/Blackout Kick
			m("C03", nil, "#showtooltip\n/use [harm]Blackout Kick;Vivify")
			-- Spear Hand Strike
			m("C04", nil, "#showtooltip Spear Hand Strike\n/stopcasting\n/stopcasting\n/use Spear Hand Strike")
			-- Provoke Statue
			m("C05", 615340, "#showtooltip Provoke\n/targetexact Black Ox Statue\n/use Provoke\n/targetlasttarget")
			-- Celestial Pet
			m("C06", nil, "#showtooltip\n/petattack\n/petattack\n/use [spec:1]Invoke Niuzao, the Black Ox;[spec:2]Invoke Yu'lon, the Jade Serpent;Invoke Xuen, the White Tiger")
			-- Tiger's Lust @player
			m("C07", 571558, "#showtooltip Tiger's Lust\n/use [@player]Tiger's Lust")
			-- Black Ox Statue
			m("C08", nil, "#showtooltip\n/click [btn:2][nopet]TotemFrameTotem1 RightButton\n/click [btn:2][nopet]TotemFrameTotem2 RightButton\n/click [btn:2][nopet]TotemFrameTotem3 RightButton\n/use [nobtn:2]Summon Black Ox Statue")
			-- Jade Serpent Statue
			m("C09", nil, "#showtooltip\n/click [btn:2]TotemFrameTotem1 RightButton\n/click [btn:2]TotemFrameTotem2 RightButton\n/click [btn:2]TotemFrameTotem3 RightButton\n/use [nobtn:2]Summon Jade Serpent Statue")

			-- Essence
			essence("N", "Weapons of Order", "Bonedust Brew", "Faeline Stomp", "Fallen Order")

			if spec == 1 then
				--! Brewmaster Monk
				spell("1", "Tiger Palm")
				spell("2", "Keg Smash")
				spell("3", "Blackout Kick")
				spell("4", "Purifying Brew")
				if talent[6][2] then spell("5", "Rushing Jade Wind") elseif talent[6][3] then spell("5", "Exploding Keg") else empty("5") end
				spell("CE", "Leg Sweep")

				if talent[1][2] then spell("C", "Chi Wave") elseif talent[1][3] then spell("C", "Chi Burst") else empty("C") end
				empty("SC")
				spell("Q", "Spinning Crane Kick")
				spell("E", "Breath of Fire")
				macro("G", "C06", 42) -- Invoke Niuzao, the Black Ox
				empty("SG")
				if talent[3][3] then spell("V", "Black Ox Brew") else empty("V") end
				macro("SE", "C04", 18) -- Spear Hand Strike

				spell("R", "Provoke")
				if talent[4][2] then macro("SR", "C05") else empty("SR") end -- Provoke Statue
				spell("CR", "Detox")
				spell("H", "Crackling Jade Lightning")
				empty("SH")

				spell("F1", "Celestial Brew")
				spell("F2", "Fortifying Brew")
				if talent[5][2] then spell("F3", "Healing Elixir") elseif talent[5][3] then spell("F3", "Dampen Harm") else empty("F3") end
				empty("F4")
				spell("F5", "Zen Meditation")
				spell("CQ", "Expel Harm")

				spell("T", "Paralysis")
				empty("ST")
				empty("CT")
				empty("AT")
				spell("CB3", "Transcendence")
				spell("SQ", "Vivify")
				if talent[4][2] then macro("SV", "C08") else empty("SV") end -- Summon Black Ox Statue
				spell("CV", "Touch of Death")

				if talent[4][3] then spell("AB3", "Ring of Peace") else empty("AB3") end
				if talent[2][3] then spell("AF", "Tiger's Lust") else empty("AF") end
				spell("CF", "Clash")
				spell("SF", "Transcendence: Transfer")
				spell("F", "Roll")
			elseif spec == 2 then
				--! Mistweaver Monk
				if level >= 17 then macro("1", "C01") else spell("1", "Tiger Palm") end -- Soothing Mist/Tiger Palm
				if level >= 12 then macro("2", "C02") else spell("2", "Rising Sun Kick") end -- Eneveloping Mist/Rising Sun Kick
				macro("3", "C03") -- Vivify/Blackout Kick
				spell("4", "Essence Font")
				if talent[6][2] then spell("5", "Refreshing Jade Wind") else empty("5") end
				spell("CE", "Leg Sweep")

				if talent[1][2] then spell("C", "Chi Wave") elseif talent[1][3] then spell("C", "Chi Burst") else empty("C") end
				if talent[3][3] then spell("SC", "Mana Tea") else empty("SC") end
				spell("Q", "Spinning Crane Kick")
				spell("E", "Renewing Mist")
				spell("G", "Invoke Yu'lon, the Jade Serpent")
				empty("SG")
				spell("V", "Thunder Focus Tea")
				spell("SE", "Life Cocoon")

				spell("R", "Provoke")
				empty("SR")
				spell("CR", "Detox")
				spell("H", "Crackling Jade Lightning")
				empty("SH")

				spell("F1", "Fortifying Brew")
				spell("F2", "Revival")
				if talent[5][1] then spell("F3", "Healing Elixir") elseif talent[5][2] then spell("F3", "Diffuse Magic") elseif talent[5][3] then spell("F3", "Dampen Harm") else empty("F3") end
				empty("F4")
				spell("F5", "Zen Meditation")
				spell("CQ", "Expel Harm")

				spell("T", "Paralysis")
				empty("ST")
				if talent[4][2] then spell("CT", "Song of Chi-Ji") else empty("CT") end
				empty("AT")
				spell("CB3", "Transcendence")
				spell("SQ", "Vivify")
				if talent[6][1] then macro("SV", "C09") else empty("SV") end -- Summon Jade Serpent Statue
				spell("CV", "Touch of Death")

				if talent[4][3] then spell("AB3", "Ring of Peace") else empty("AB3") end
				if talent[2][3] then spell("AF", "Tiger's Lust") else empty("AF") end
				if talent[2][3] then macro("CF", "C07") else empty("F") end
				spell("SF", "Transcendence: Transfer")
				spell("F", "Roll")
			elseif spec == 3 then
				--! Windwalker Monk
				spell("1", "Tiger Palm")
				spell("2", "Rising Sun Kick")
				spell("3", "Blackout Kick")
				spell("4", "Fists of Fury")
				if talent[3][2] then spell("5", "Fist of the White Tiger") elseif talent[3][3] then spell("5", "Energizing Elixir") else empty("5") end
				spell("CE", "Leg Sweep")

				if talent[1][2] then spell("C", "Chi Wave") elseif talent[1][3] then spell("C", "Chi Burst") else empty("C") end
				if talent[6][2] then spell("SC", "Rushing Jade Wind") else empty("SC") end
				spell("Q", "Spinning Crane Kick")
				if talent[7][2] then spell("E", "Whirling Dragon Punch") else empty("E") end
				macro("G", "C06", 42) -- Invoke Xuen, the White Tiger
				empty("SG")
				spell("V", "Storm, Earth, and Fire")
				macro("SE", "C04", 18) -- Spear Hand Strike

				spell("R", "Provoke")
				empty("SR")
				spell("CR", "Detox")
				spell("H", "Crackling Jade Lightning")
				empty("SH")

				spell("F1", "Touch of Karma")
				spell("F2", "Fortifying Brew")
				if talent[5][2] then spell("F3", "Diffuse Magic") elseif talent[5][3] then spell("F3", "Dampen Harm") else empty("F3") end
				empty("F4")
				empty("F5")
				spell("CQ", "Expel Harm")

				spell("T", "Paralysis")
				spell("ST", "Disable")
				empty("CT")
				empty("AT")
				spell("CB3", "Transcendence")
				spell("SQ", "Vivify")
				empty("SV")
				spell("CV", "Touch of Death")

				if talent[4][3] then spell("AB3", "Ring of Peace") else empty("AB3") end
				if talent[2][3] then spell("AF", "Tiger's Lust") else empty("AF") end
				spell("CF", "Flying Serpent Kick")
				spell("SF", "Transcendence: Transfer")
				spell("F", "Roll")
			else
				--! Untalented Monk
				spell("1", "Tiger Palm")
				empty("2")
				spell("3", "Blackout Kick")
				empty("4")
				empty("5")
				spell("CE", "Leg Sweep")

				empty("C")
				empty("SC")
				spell("Q", "Spinning Crane Kick")
				empty("E")
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				empty("R")
				empty("SR")
				empty("CR")
				spell("H", "Crackling Jade Lightning")
				empty("SH")

				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				spell("CQ", "Expel Harm")

				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Vivify")
				empty("SV")
				spell("CV", "Touch of Death")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Roll")
			end
		elseif class == "PALADIN" then
			--! Paladin

			-- Flash of Light/Crusader Strike
			m("C01", nil, "#showtooltip\n/use [harm]Crusader Strike;Flash of Light")
			-- Holy Light/Judgment
			m("C02", nil, "#showtooltip\n/use [harm]Judgment;Holy Light")
			-- Light of the Martyr/Shield of the Righteous
			m("C03", nil, "#showtooltip\n/use [equipped:shield,harm]Shield of the Righteous;Light of the Martyr")
			-- Rebuke
			m("C04", nil, "#showtooltip Rebuke\n/stopcasting\n/stopcasting\n/use Rebuke")
			-- Beacon of Faith/Hammer of Wrath
			m("C05", nil, "#showtooltip\n/use [harm]Hammer of Wrath;[talent:7/2]Beacon of Faith;Hammer of Wrath")

			-- Essence
			essence("N", "Divine Toll", "Vanquisher's Hammer", "Blessing of the Seasons", "Ashen Hallow")

			if spec == 1 then
				--! Holy Paladin
				macro("1", "C01") -- Flash of Light/Crusader Strike
				if level >= 11 then macro("2", "C02") else spell("2", "Judgment") end -- Holy Light/Judgment
				spell("3", "Holy Shock")
				if level >= 46 then macro("4", "C03") else spell("4", "Light of the Martyr") end -- Light of the Martyr/Shield of the Righteous
				spell("5", "Light of Dawn")
				spell("CE", "Hammer of Justice")

				if talent[7][2] then macro("C", "C05") else spell("C", "Hammer of Wrath") end
				spell("SC", "Beacon of Light")
				spell("Q", "Word of Glory")
				spell("E", "Consecration")
				spell("G", "Avenging Wrath")
				empty("SG")
				if talent[5][2] then spell("V", "Holy Avenger") elseif talent[5][3] then spell("V", "Seraphim") else empty("V") end
				if talent[1][2] then spell("SE", "Bestow Faith") elseif talent[1][3] then spell("SE", "Light's Hammer") else empty("SE") end

				spell("R", "Hand of Reckoning")
				empty("SR")
				spell("CR", "Cleanse")
				if talent[2][3] then spell("H", "Holy Prism") else empty("H") end
				empty("SH")

				spell("F1", "Divine Protection")
				spell("F2", "Divine Shield")
				spell("F3", "Aura Mastery")
				if talent[4][3] then spell("F4", "Rule of Law") else empty("F4") end
				empty("F5")
				spell("CQ", "Blessing of Protection")

				if talent[3][2] then spell("T", "Repentance") elseif talent[3][3] then spell("T", "Blinding Light") else empty("T") end
				empty("ST")
				spell("CT", "Turn Evil")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash of Light")
				spell("SV", "Lay on Hands")
				spell("CV", "Blessing of Sacrifice")

				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Blessing of Freedom")
				spell("F", "Divine Steed")
			elseif spec == 2 then
				--! Protection Paladin
				spell("1", "Crusader Strike")
				spell("2", "Avenger's Shield")
				spell("3", "Judgment")
				spell("4", "Shield of the Righteous")
				if talent[2][3] then spell("5", "Moment of Glory") else empty("5") end
				spell("CE", "Hammer of Justice")

				spell("C", "Hammer of Wrath")
				empty("SC")
				spell("Q", "Word of Glory")
				spell("E", "Consecration")
				spell("G", "Avenging Wrath")
				empty("SG")
				if talent[5][2] then spell("V", "Holy Avenger") elseif talent[5][3] then spell("V", "Seraphim") else empty("V") end
				macro("SE", "C04", 27) -- Rebuke

				spell("R", "Hand of Reckoning")
				empty("SR")
				spell("CR", "Cleanse Toxins")
				empty("H")
				empty("SH")

				spell("F1", "Divine Protection")
				spell("F2", "Divine Shield")
				spell("F3", "Guardian of Ancient Kings")
				empty("F4")
				empty("F5")
				spell("CQ", "Blessing of Protection")

				if talent[3][2] then spell("T", "Repentance") elseif talent[3][3] then spell("T", "Blinding Light") else empty("T") end
				empty("ST")
				spell("CT", "Turn Evil")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash of Light")
				spell("SV", "Lay on Hands")
				spell("CV", "Blessing of Sacrifice")

				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Blessing of Freedom")
				spell("F", "Divine Steed")
			elseif spec == 3 then
				--! Retribution Paladin
				spell("1", "Crusader Strike")
				spell("2", "Blade of Justice")
				spell("3", "Judgment")
				spell("4", "Templar's Verdict")
				spell("5", "Wake of Ashes")
				spell("CE", "Hammer of Justice")

				spell("C", "Hammer of Wrath")
				if talent[1][3] then spell("SC", "Execution Sentence") else empty("SC") end
				spell("Q", "Divine Storm")
				spell("E", "Consecration")
				spell("G", "Avenging Wrath")
				empty("SG")
				if talent[5][2] then spell("V", "Holy Avenger") elseif talent[5][3] then spell("V", "Seraphim") else empty("V") end
				macro("SE", "C04", 27) -- Rebuke

				spell("R", "Hand of Reckoning")
				empty("SR")
				spell("CR", "Cleanse Toxins")
				spell("H", "Word of Glory")
				if talent[6][2] then spell("SH", "Justicar's Vengeance") else empty("SH") end

				spell("F1", "Shield of Vengeance")
				spell("F2", "Divine Shield")
				if talent[4][3] then spell("F3", "Eye for an Eye") else empty("F3") end
				empty("F4")
				empty("F5")
				spell("CQ", "Blessing of Protection")

				if talent[3][2] then spell("T", "Repentance") elseif talent[3][3] then spell("T", "Blinding Light") else empty("T") end
				spell("ST", "Hand of Hindrance")
				spell("CT", "Turn Evil")
				empty("AT")
				if talent[7][3] then spell("CB3", "Final Reckoning") else empty("CB3") end
				spell("SQ", "Flash of Light")
				spell("SV", "Lay on Hands")
				spell("CV", "Blessing of Sacrifice")

				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Blessing of Freedom")
				spell("F", "Divine Steed")
			else
				--! Untalented Paladin
				spell("1", "Crusader Strike")
				spell("2")
				spell("3", "Judgment")
				spell("4", "Shield of the Righteous")
				empty("5")
				spell("CE", "Hammer of Justice")

				empty("C")
				empty("SC")
				spell("Q", "Word of Glory")
				spell("E", "Consecration")
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				spell("F2", "Divine Shield")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash of Light")
				spell("SV", "Lay on Hands")
				empty("CV")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				empty("F")
			end
		elseif class == "PRIEST" then
			--! Priest

			-- Flash Heal/Smite/Shadow Mend
			m("C01", nil, "#showtooltip\n/use [spec:2,harm]Smite;[spec:2]Flash Heal;[help]Flash Heal;Smite")
			-- Heal/Holy Fire
			m("C02", nil, "#showtooltip\n/use [harm]Mind Blast;Heal")
			-- Renew/Shadow Word: Pain/Power Word: Shield
			m("C03", nil, "#showtooltip\n/use [nospec:2,help]Power Word: Shield;[spec:2,harm]Shadow Word: Pain;[spec:2]Renew;Shadow Word: Pain")
			-- Silence
			m("C04", nil, "#showtooltip Silence\n/stopcasting\n/stopcasting\n/use Silence")
			-- Angelic Feather/Body and Soul
			m("C05", 537020, "#showtooltip [spec:1,talent:2/3][spec:2]Angelic Feather;Power Word: Shield\n/use [spec:1,talent:2/3,@player][spec:2,@player]Angelic Feather;[@player]Power Word: Shield")
			-- Shadowform
			m("C06", nil, "#showtooltip Shadowform\n/use [nostance]Shadowform")
			-- Power Word: Shield @player
			m("C07", nil, "#showtooltip Power Word: Shield\n/use [@player]Power Word: Shield")
			-- Body and Soul - Power Word: Shield @player
			m("C08", 537099, "#showtooltip\n/use [@player]Power Word: Shield")
			-- Dispersion
			m("C09", nil, "#showtooltip\n/use !Dispersion")
			-- Mind Control
			m("C11", 1718004, "#showtooltip\n/use Mind Control")
			-- Devouring Plague/Searing Nightmare
			m("C12", nil, "#showtooltip\n/use [mod:shift,talent:3/3]Searing Nightmare;Devouring Plague")
			-- Mindbender
			m("C13", 1386549, "#showtooltip\n/use Shadowfiend")
			-- Power Infusion
			m("C14", nil, "#showtooltip\n/use [@focus,help,nodead][help,nodead][@player]Power Infusion")

			-- Essence
			essence("N", "Boon of the Ascended", "Unholy Nova", "Fae Guardians", "Mindgames")

			if spec == 1 then
				--! Discipline Priest
				macro("1", "C01")
				spell("2", "Mind Blast")
				spell("3", "Penance")
				spell("4", "Power Word: Radiance")
				if talent[5][3] then spell("5", "Shadow Covenant") else empty("5") end
				if talent[1][3] then spell("CE", "Schism") else empty("CE") end

				if talent[3][3] then spell("C", "Power Word: Solace") else empty("C") end
				if talent[6][2] then spell("SC", "Divine Star") elseif talent[6][3] then spell("SC", "Halo") else empty("SC") end
				spell("Q", "Mind Sear")
				macro("E", "C03") -- Shadow Word: Pain/Power Word: Shield
				macro("G", "C14", 58) -- Power Infusion
				spell("SG", "Rapture")
				if talent[3][2] then macro("V", "C13") else spell("V", "Shadowfiend") end
				spell("SE", "Pain Suppression")

				spell("R", "Shadow Word: Death", 14)
				spell("SR", "Dispel Magic")
				spell("CR", "Purify")
				spell("H", "Holy Nova")
				empty("SH")

				spell("F1", "Desperate Prayer")
				spell("F2", "Power Word: Barrier")
				if talent[7][3] then spell("F3", "Evangelism") else empty("F3") end
				empty("F4")
				empty("F5")
				spell("CQ", "Levitate")

				spell("T", "Shackle Undead")
				spell("ST", "Psychic Scream")
				macro("CT", "C11", 34) -- Mind Control
				spell("AT", "Mind Soothe")
				if talent[4][3] then spell("CB3", "Shining Force") else empty("CB3") end
				spell("SQ", "Flash Heal")
				macro("SV", "C07") -- Power Word: Shield @player
				spell("CV", "Fade")

				spell("AB3", "Mass Dispel")
				empty("AF")
				spell("CF", "Leap of Faith")
				if talent[2][3] then spell("SF", "Angelic Feather") else empty("SF") end -- Angelic Feather
				if talent[2][1] then macro("F", "C08") elseif talent[2][3] then macro("F", "C05") else empty("F") end -- Body and Soul/Angelic Feather @player
			elseif spec == 2 then
				--! Holy Priest
				macro("1", "C01") -- Flash Heal/Smite
				if level >= 15 then macro("2", "C02") else spell("2", "Mind Blast") end -- Heal/Holy Fire
				spell("3", "Prayer of Healing")
				spell("4", "Prayer of Mending")
				spell("5", "Circle of Healing")
				spell("CE", "Holy Word: Chastise")

				spell("C", "Holy Word: Serenity")
				if talent[6][2] then spell("SC", "Divine Star") elseif talent[6][3] then spell("SC", "Halo") else empty("SC") end
				spell("Q", "Holy Nova")
				if level >= 12 then macro("E", "C03") else spell("E", "Shadow Word: Pain") end -- Renew/Shadow Word: Pain
				spell("V", "Holy Word: Sanctify")
				macro("G", "C14", 58) -- Power Infusion
				empty("SG")
				spell("SE", "Guardian Spirit")

				spell("R", "Shadow Word: Death")
				spell("SR", "Dispel Magic")
				spell("CR", "Purify")
				spell("H", "Power Word: Shield")
				empty("SH")

				spell("F1", "Desperate Prayer")
				spell("F2", "Divine Hymn")
				spell("F3", "Symbol of Hope")
				empty("F4")
				empty("F5")
				spell("CQ", "Levitate")

				spell("T", "Shackle Undead")
				spell("ST", "Psychic Scream")
				macro("CT", "C11", 34) -- Mind Control
				spell("AT", "Mind Soothe")
				if talent[4][3] then spell("CB3", "Shining Force") else empty("CB3") end
				spell("SQ", "Flash Heal")
				if talent[7][2] then spell("SV", "Apotheosis") elseif talent[7][3] then spell("SV", "Holy Word: Salvation") else empty("SV") end
				spell("CV", "Fade")

				spell("AB3", "Mass Dispel")
				empty("AF")
				spell("CF", "Leap of Faith")
				if talent[2][3] then spell("SF", "Angelic Feather") else empty("SF") end -- Angelic Feather
				if talent[2][2] then macro("F", "C08") elseif talent[2][3] then macro("F", "C05") else empty("F") end -- Body and Soul/Angelic Feather @player
			elseif spec == 3 then
				--! Shadow Priest
				if level >= 15 then spell("1", "Vampiric Touch") else spell("1", "Smite") end
				spell("2", "Smite", 15)
				spell("3", "Mind Blast")
				spell("4", "Void Eruption")
				if talent[3][3] then macro("5", "C12") else spell("5", "Devouring Plague") end
				if talent[4][2] then spell("CE", "Psychic Scream") elseif talent[4][3] then spell("CE", "Psychic Horror") else empty("CE") end

				if talent[6][1] then spell("C", "Damnation") elseif talent[6][3] then spell("C", "Void Torrent") else empty("C") end
				if talent[5][3] then spell("SC", "Shadow Crash") else empty("SC") end
				spell("Q", "Mind Sear")
				macro("E", "C03") -- Shadow Word: Pain/Power Word: Shield
				macro("G", "C14", 58) -- Power Infusion
				empty("SG")
				if talent[6][2] then macro("V", "C13") else spell("V", "Shadowfiend") end
				macro("SE", "C04", 29) -- Silence

				spell("R", "Shadow Word: Death", 14)
				spell("SR", "Dispel Magic")
				spell("CR", "Purify Disease")
				empty("H")
				empty("SH")

				spell("F1", "Desperate Prayer")
				macro("F2", "C09", 16) -- Dispersion
				spell("F3", "Vampiric Embrace")
				empty("F4")
				empty("F5")
				spell("CQ", "Levitate")

				spell("T", "Shackle Undead")
				if talent[4][2] then empty("ST") else spell("ST", "Psychic Scream") end
				macro("CT", "C11", 34) -- Mind Control
				spell("AT", "Mind Soothe")
				empty("CB3")
				spell("SQ", "Flash Heal")
				macro("SV", "C06") -- Shadowform
				spell("CV", "Fade")

				spell("AB3", "Mass Dispel")
				if talent[7][3] then spell("AF", "Surrender to Madness") else empty("AF") end
				spell("CF", "Leap of Faith")
				empty("SF")
				if talent[2][1] then macro("F", "C08") else macro("F", "C07") end -- Power Word: Shield @player
			else
				--! Untalented Priest
				spell("1", "Smite")
				spell("2", "Mind Blast")
				empty("3")
				empty("4")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				empty("Q")
				if level >= 4 then macro("E", "C03") else spell("E", "Shadow Word: Pain") end
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				spell("F1", "Fade")
				empty("F2")
				spell("F3", "Desperate Prayer")
				empty("F4")
				empty("F5")
				empty("CQ")

				empty("T")
				spell("ST", "Psychic Scream")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash Heal")
				empty("SV")
				empty("CV")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				empty("F")
			end
		elseif class == "ROGUE" then
			--! Rogue

			-- Sinister Strike/Ambush/Backstab/Shadowstrike
			m("C01", nil, "#showtooltip\n/use [stance:1][stance:2]Ambush;Sinister Strike")
			-- Kidney Shot/Cheap Shot
			m("C02", nil, "#showtooltip\n/use [stance:1][stance:2]Cheap Shot;Kidney Shot")
			-- Tricks of the Trade
			m("C03", nil, "#showtooltip Tricks of the Trade\n/use [@focus,help][help][]Tricks of the Trade")
			-- Kick
			m("C04", nil, "#showtooltip Kick\n/stopcasting\n/stopcasting\n/use Kick")
			-- Pistol Shot
			m("C05", 134536, "#showtooltip\n/use Pistol Shot")
			-- Symbols of Death + Shadow Dance
			m("C06", nil, "#showtooltip Symbols of Death\n/use Symbols of Death\n/use [nostance:1,nostance:2]Shadow Dance\n/use 13")
			-- Stealth
			m("C07", nil, "#showtooltip Stealth\n/cancelaura [btn:2]Stealth;[nocombat]Shadow Dance\n/use [nobtn:2]!Stealth")

			-- Essence
			essence("N", "Echoing Reprimand", "Serrated Bone Spike", "Sepsis", "Flagellation")

			if spec == 1 then
				--! Assassination Rogue
				macro("1", "C01") -- Mutilate/Ambush
				spell("2", "Rupture")
				spell("3", "Eviscerate")
				spell("4", "Slice and Dice")
				if talent[7][3] then spell("5", "Crimson Tempest") else empty("5") end
				spell("CE", "Kidney Shot")

				spell("C", "Shiv")
				if talent[6][3] then spell("SC", "Exsanguinate") else empty("SC") end
				spell("Q", "Fan of Knives")
				spell("E", "Garrote")
				spell("G", "Vendetta")
				empty("SG")
				if talent[3][3] then spell("V", "Marked for Death") else empty("V") end
				macro("SE", "C04") -- Kick

				if talent[1][3] then spell("R", "Ambush") else empty("R") end
				empty("SR")
				empty("CR")
				spell("H", "Poisoned Knife")
				empty("SH")

				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				empty("F4")
				spell("F5", "Shroud of Concealment")
				macro("CQ", "C03", 48) -- Tricks of the Trade

				spell("T", "Sap")
				spell("ST", "Blind")
				spell("CT", "Cheap Shot")
				empty("AT")
				spell("CB3", "Distract")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07") -- Stealth
				spell("CV", "Vanish")

				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Shadowstep")
				spell("F", "Sprint")
			elseif spec == 2 then
				--! Outlaw Rogue
				macro("1", "C01") -- Sinister Strike/Ambush
				macro("2", "C05", 12) -- Pistol Shot
				spell("3", "Eviscerate")
				spell("4", "Slice and Dice")
				if talent[7][2] then spell("5", "Blade Rush") elseif talent[7][3] then spell("5", "Killing Spree") else empty("5") end
				spell("CE", "Kidney Shot")

				spell("C", "Roll the Bones")
				if talent[6][3] then spell("SC", "Dreadblades") else empty("SC") end
				spell("Q", "Blade Flurry")
				spell("E", "Between the Eyes")
				spell("G", "Adrenaline Rush")
				empty("SG")
				if talent[3][3] then spell("V", "Marked for Death") else empty("V") end
				macro("SE", "C04") -- Kick

				empty("R")
				spell("SR", "Shiv")
				empty("CR")
				if talent[1][3] then spell("H", "Ghostly Strike") else empty("H") end
				empty("SH")

				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				empty("F4")
				spell("F5", "Shroud of Concealment")
				macro("CQ", "C03", 48) -- Tricks of the Trade

				spell("T", "Sap")
				spell("ST", "Blind")
				spell("CT", "Cheap Shot")
				spell("AT", "Gouge")
				spell("CB3", "Distract")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07") -- Stealth
				spell("CV", "Vanish")

				empty("AB3")
				empty("AF")
				spell("CF", "Grappling Hook")
				empty("SF")
				spell("F", "Sprint")
			elseif spec == 3 then
				--! Subtlety Rogue
				macro("1", "C01") -- Backstab/Shadowstrike
				spell("2", "Rupture")
				spell("3", "Eviscerate")
				spell("4", "Slice and Dice")
				spell("5", "Black Powder")
				spell("CE", "Kidney Shot")

				macro("C", "C06", 29) -- Symbols of Death
				spell("SC", "Shadow Dance")
				spell("Q", "Shuriken Storm")
				if talent[7][2] then spell("E", "Secret Technique") elseif talent[7][3] then spell("E", "Shuriken Tornado") else empty("E") end
				spell("G", "Shadow Blades")
				empty("SG")
				if talent[3][3] then spell("V", "Marked for Death") else empty("V") end
				macro("SE", "C04") -- Kick

				empty("R")
				spell("SR", "Shiv")
				empty("CR")
				spell("H", "Shuriken Toss")
				empty("SH")

				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				empty("F4")
				spell("F5", "Shroud of Concealment")
				macro("CQ", "C03", 48) -- Tricks of the Trade

				spell("T", "Sap")
				spell("ST", "Blind")
				spell("CT", "Cheap Shot")
				empty("AT")
				spell("CB3", "Distract")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07") -- Stealth
				spell("CV", "Vanish")

				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Shadowstep")
				spell("F", "Sprint")
			else
				--! Untalented Rogue
				if level >= 7 then macro("1", "C01") else spell("1", "Sinister Strike") end -- Sinister Strike/Backstab
				empty("2")
				spell("3", "Eviscerate")
				spell("4", "Slice and Dice")
				empty("5")
				spell("CE", "Cheap Shot")

				empty("C")
				empty("SC")
				empty("Q")
				empty("E")
				empty("G")
				empty("SG")
				empty("V")
				macro("SE", "C04", 6) -- Kick

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				spell("T", "Sap")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07", 3) -- Stealth
				empty("CV")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Sprint")
			end
		elseif class == "SHAMAN" then
			--! Shaman

			-- Healing Surge/Lightning Bolt/Stormstrike
			m("C01", nil, "#showtooltip\n/use [nospec:2,harm]Lightning Bolt;[spec:3][nospec:3,help]Healing Surge;[spec:2]Primal Strike;Lightning Bolt")
			-- Healing Wave/Lava Burst
			m("C02", nil, "#showtooltip\n/use [harm]Lava Burst;Healing Wave")
			-- Chain Heal/Chain Lightning/Crash Lightning
			m("C03", nil, "#showtooltip\n/use [harm,spec:2]Crash Lightning;[harm]Chain Lightning;[spec:3][help]Chain Heal;[spec:2]Crash Lightning;Chain Lightning")
			-- Wind Shear/Earth Shield
			m("C04", nil, "#showtooltip [spec:3,help][nospec:3,talent:3/2,help]Earth Shield;Wind Shear\n/stopcasting\n/stopcasting\n/use [spec:3,help][nospec:3,talent:3/2,help]Earth Shield;Wind Shear")
			-- Riptide/Flame Shock
			m("C05", nil, "#showtooltip\n/use [harm] Flame Shock;Riptide")
			-- Fire Elemental
			m("C06", nil, "#showtooltip\n/use [pet:Earth Elemental]Harden Skin;[pet:Storm Elemental]Eye of the Storm;[pet:Fire Elemental]Meteor;Fire Elemental")
			-- Earth Elemental
			m("C07", nil, "#showtooltip Earth Elemental\n/use [nopet]Earth Elemental")
			-- Reincarnation
			m("C08", nil, "#showtooltip\n/use Reincarnation")
			-- Frost Shock/Crash Lightning
			m("C09", nil, "#showtooltip\n/use [mod:shift]Crash Lightning;Frost Shock")

			-- Essence
			essence("N", "Vesper Totem", "Primordial Wave", "Fae Transfusion", "Chain Harvest")

			if spec == 1 then
				-- Elemental
				macro("1", "C01") -- Lightning Bolt/Healing Surge
				spell("2", "Lava Burst")
				if level >= 24 then macro("3", "C03") else spell("3", "Chain Heal") end -- Chain Lightning/Chain Heal
				spell("4", "Earth Shock")
				if talent[2][2] then spell("5", "Echoing Shock") elseif talent[2][3] then spell("5", "Elemental Blast") else empty("5") end
				spell("CE", "Capacitor Totem")

				spell("C", "Frost Shock")
				if talent[6][3] then spell("SC", "Icefury") else empty("SC") end
				spell("Q", "Earthquake")
				spell("E", "Flame Shock")
				macro("G", "C06", 34) -- Fire Elemental
				if talent[7][3] then spell("SG", "Ascendance") else empty("SG") end
				if talent[7][2] then spell("V", "Stormkeeper") else empty("V") end
				macro("SE", "C04", 12) -- Wind Shear/Earth Shield

				empty("R")
				spell("SR", "Purge")
				spell("CR", "Cleanse Spirit")
				if talent[1][3] then spell("H", "Static Discharge") else empty("H") end
				empty("SH")

				spell("F1", "Astral Shift")
				macro("F2", "C07", 37) -- Earth Elemental
				spell("F3", "Healing Stream Totem")
				if talent[5][2] then spell("F4", "Ancestral Guidance") else empty("F4") end
				macro("F5", "C08") -- Reincarnation
				spell("CQ", "Water Walking")

				custom("T", "Hex", 41)
				spell("ST", "Earthbind Totem")
				empty("CT")
				empty("AT")
				spell("CB3", "Thunderstorm")
				spell("SQ", "Healing Surge")
				if faction == "Alliance" then spell("SV", "Heroism") else spell("SV", "Bloodlust") end
				spell("CV", "Tremor Totem")

				if talent[4][3] then spell("AB3", "Liquid Magma Totem") else empty("AB3") end
				empty("AF")
				if talent[5][3] then spell("CF", "Wind Rush Totem") else empty("CF") end
				spell("SF", "Spiritwalker's Grace")
				spell("F", "Ghost Wolf")
			elseif spec == 2 then
				--! Enhancement Shaman
				macro("1", "C01") -- Stormstrike/Healing Surge
				spell("2", "Lava Lash")
				if level >= 38 then macro("3", "C03") else spell("3", "Chain Heal") end -- Crash Lightning/Chain Heal
				spell("4", "Lightning Bolt")
				spell("5", "Chain Lightning")
				spell("CE", "Capacitor Totem")

				spell("C", "Frost Shock")
				if talent[2][3] then spell("SC", "Ice Strike") else empty("SC") end
				if talent[1][3] then spell("SC", "Elemental Blast") else empty("SC") end
				if talent[4][3] then spell("Q", "Fire Nova") else empty("Q") end
				spell("E", "Flame Shock")
				spell("G", "Feral Spirit")
				if talent[7][2] then spell("SG", "Earthen Spike") elseif talent[7][3] then spell("SG", "Ascendance") else empty("SG") end
				if talent[6][2] then spell("V", "Stormkeeper") elseif talent[6][3] then spell("V", "Sundering") else empty("V") end
				macro("SE", "C04", 12) -- Wind Shear/Earth Shield

				spell("R", "Windfury Totem")
				spell("SR", "Purge")
				spell("CR", "Cleanse Spirit")
				if (talent[7][2] or talent[7][3]) and talent[4][3] then spell("H", "Fire Nova") else empty("H") end
				empty("SH")

				spell("F1", "Astral Shift")
				spell("F2", "Earth Elemental")
				spell("F3", "Healing Stream Totem")
				empty("F4")
				macro("F5", "C08") -- Reincarnation
				spell("CQ", "Water Walking")

				custom("T", "Hex", 41)
				spell("ST", "Earthbind Totem")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Healing Surge")
				if faction == "Alliance" then spell("SV", "Heroism") else spell("SV", "Bloodlust") end
				spell("CV", "Tremor Totem")

				empty("AB3")
				empty("AF")
				if talent[5][2] then spell("CF", "Feral Lunge") elseif talent[5][3] then spell("CF", "Wind Rush Totem") else empty("CF") end
				spell("SF", "Spirit Walk")
				spell("F", "Ghost Wolf")
			elseif spec == 3 then
				--! Restoration Shaman
				macro("1", "C01") -- Lightning Bolt/Healing Surge
				if level >= 27 then macro("2", "C02") else spell("2", "Lava Burst") end -- Healing Wave/Lava Burst
				if level >= 24 then macro("3", "C03") else spell("3", "Chain Heal") end -- Chain Lightning/Chain Heal
				spell("4", "Healing Rain")
				if talent[6][2] then spell("5", "Downpour") else empty("5") end
				spell("CE", "Capacitor Totem")

				spell("C", "Frost Shock")
				if talent[1][3] then spell("SC", "Unleash Life") else empty("SC") end
				if talent[2][3] then spell("Q", "Surge of Earth") else empty("Q") end
				macro("E", "C05") -- Riptide/Flame Shock
				spell("G", "Healing Stream Totem")
				if talent[7][3] then spell("SG", "Ascendance") else empty("SG") end
				if talent[7][2] then spell("V", "Wellspring") else empty("V") end
				macro("SE", "C04", 12) -- Wind Shear/Earth Shield

				spell("R", "Mana Tide Totem")
				spell("SR", "Purge")
				spell("CR", "Purify Spirit")
				empty("H")
				empty("SH")

				spell("F1", "Astral Shift")
				spell("F2", "Earth Elemental")
				spell("F3", "Healing Tide Totem")
				spell("F4", "Spirit Link Totem")
				macro("F5", "C08") -- Reincarnation
				spell("CQ", "Water Walking")

				custom("T", "Hex", 41)
				spell("ST", "Earthbind Totem")
				if talent[3][2] then spell("CT", "Earthgrab Totem") else empty("CT") end
				empty("AT")
				if talent[4][2] then spell("CB3", "Earthen Wall Totem") elseif talent[4][3] then spell("CB3", "Ancestral Protection Totem") else empty("CB3") end
				spell("SQ", "Healing Surge")
				if faction == "Alliance" then spell("SV", "Heroism") else spell("SV", "Bloodlust") end
				spell("CV", "Tremor Totem")

				empty("AB3")
				empty("AF")
				if talent[5][3] then spell("CF", "Wind Rush Totem") else empty("CF") end
				spell("SF", "Spiritwalker's Grace")
				spell("F", "Ghost Wolf")
			else
				--! Untalented Shaman
				spell("1", "Lightning Bolt")
				spell("2", "Primal Strike")
				empty("3")
				empty("4")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Flame Shock")
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				empty("T")
				spell("ST", "Earthbind Totem")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Healing Surge")
				empty("SV")
				empty("CV")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Ghost Wolf")
			end
		elseif class == "WARLOCK" then
			--! Warlock

			-- Pet Primary
			m("C01", nil, "#showtooltip\n/use [pet:Felguard/Wrathguard]Axe Toss;[pet:Felhunter/Observer]Spell Lock;[pet:Succubus/Incubus/Shivarra]Seduction;[pet:Voidwalker/Voidlord,nobtn:2]Suffering;[nobtn:2]Command Demon\n/petautocasttoggle [btn:2]Suffering")
			-- Pet Secondary
			m("C02", nil, "#showtooltip\n/use [pet:Felguard/Wrathguard]Felstorm;[pet:Felhunter/Observer]Devour Magic;[pet:Imp/Fel Imp]Flee;[pet:Succubus/Incubus/Shivarra]Lesser Invisibility;[pet:Voidwalker/Voidlord]Shadow Bulwark;Command Demon")
			-- Emergency Felhunter Interrupt
			m("C03", 136174, "#showtooltip [pet:Felhunter/Observer]Spell Lock;Fel Domination\n/use [pet:Felhunter/Observer]Spell Lock;Fel Domination\n/use [nopet:Felhunter/Observer]Summon Felhunter")

			-- Essence
			essence("N", "Scouring Tithe", "Decimating Bolt", "Soul Rot", "Impending Catastrophe")

			if spec == 1 then
				--! Affliction Warlock
				spell("1", "Shadow Bolt")
				spell("2", "Malefic Rapture")
				spell("3", "Unstable Affliction")
				spell("4", "Agony")
				if talent[6][2] then spell("5", "Haunt") else empty("5") end
				spell("CE", "Shadowfury")

				if talent[4][2] then spell("C", "Phantom Singularity") elseif talent[4][3] then spell("C", "Vile Taint") else empty("C") end
				if talent[2][3] then spell("SC", "Siphon Life") else empty("SC") end
				spell("Q", "Seed of Corruption")
				spell("E", "Corruption")
				spell("G", "Summon Darkglare")
				empty("SG")
				if talent[7][3] then spell("V", "Dark Soul: Misery") else empty("V") end
				macro("SE", "C01", 29) -- Pet Primary

				spell("R", "Curse of Exhaustion")
				spell("SR", "Curse of Weakness")
				spell("CR", "Curse of Tongues")
				spell("H", "Health Funnel")
				spell("SH", "Subjugate Demon")

				spell("F1", "Unending Resolve")
				if talent[3][3] then spell("F2", "Dark Pact") else empty("F2") end
				empty("F3")
				empty("F4")
				empty("F5")
				spell("CQ", "Unending Breath")

				spell("T", "Fear")
				spell("ST", "Banish")
				if talent[5][2] then spell("CT", "Mortal Coil") elseif talent[5][3] then spell("CT", "Howl of Terror") else empty("CT") end
				empty("AT")
				spell("CB3", "Demonic Circle")
				spell("SQ", "Drain Life")
				macro("SV", "C02", 29) -- Pet Secondary
				macro("CV", "C03", 23) -- Emergency Felhunter Interrupt

				empty("AB3")
				empty("AF")
				spell("CF", "Demonic Gateway")
				spell("SF", "Demonic Circle: Teleport")
				if talent[3][2] then spell("F", "Burning Rush") else empty("F") end
			elseif spec == 2 then
				--! Demonology Warlock
				spell("1", "Shadow Bolt")
				spell("2", "Demonbolt")
				spell("3", "Call Dreadstalkers")
				spell("4", "Hand of Gul'dan")
				if talent[1][2] then spell("5", "Bilescourge Bombers") elseif talent[1][3] then spell("5", "Demonic Strength") else empty("5") end
				spell("CE", "Shadowfury")

				if talent[4][2] then spell("C", "Soul Strike") elseif talent[4][3] then spell("C", "Summon Vilefiend") else empty("C") end
				if talent[6][3] then spell("SC", "Grimoire: Felguard") else empty("SC") end
				spell("Q", "Implosion")
				if talent[2][2] then spell("E", "Power Siphon") elseif talent[2][3] then spell("E", "Doom") else empty("E") end
				spell("G", "Summon Demonic Tyrant")
				empty("SG")
				if talent[7][3] then spell("V", "Nether Portal") else empty("V") end
				macro("SE", "C01", 17) -- Pet Primary

				spell("R", "Curse of Exhaustion")
				spell("SR", "Curse of Weakness")
				spell("CR", "Curse of Tongues")
				spell("H", "Health Funnel")
				spell("SH", "Subjugate Demon")

				spell("F1", "Unending Resolve")
				if talent[3][3] then spell("F2", "Dark Pact") else empty("F2") end
				empty("F3")
				empty("F4")
				empty("F5")
				spell("CQ", "Unending Breath")

				spell("T", "Fear")
				spell("ST", "Banish")
				if talent[5][2] then spell("CT", "Mortal Coil") elseif talent[5][3] then spell("CT", "Howl of Terror") else empty("CT") end
				empty("AT")
				spell("CB3", "Demonic Circle")
				spell("SQ", "Drain Life")
				macro("SV", "C02", 10) -- Pet Secondary
				macro("CV", "C03", 23) -- Emergency Felhunter Interrupt

				empty("AB3")
				empty("AF")
				spell("CF", "Demonic Gateway")
				spell("SF", "Demonic Circle: Teleport")
				if talent[3][2] then spell("F", "Burning Rush") else empty("F") end
			elseif spec == 3 then
				--! Destruction Warlock
				if level >= 11 then spell("1", "Immolate") else spell("1", "Corruption") end
				spell("2", "Incinerate")
				spell("3", "Chaos Bolt")
				spell("4", "Conflagrate")
				if talent[4][3] then spell("5", "Cataclysm") else empty("5") end
				spell("CE", "Shadowfury")

				if talent[2][3] then spell("C", "Shadowburn") else empty("C") end
				if talent[1][3] then spell("SC", "Soul Fire") else empty("SC") end
				spell("Q", "Rain of Fire")
				spell("E", "Havoc")
				spell("G", "Summon Infernal")
				empty("SG")
				if talent[7][2] then spell("V", "Channel Demonfire") elseif talent[7][3] then spell("V", "Dark Soul: Instability") else empty("V") end
				macro("SE", "C01", 29) -- Pet Primary

				spell("R", "Curse of Exhaustion")
				spell("SR", "Curse of Weakness")
				spell("CR", "Curse of Tongues")
				spell("H", "Health Funnel")
				spell("SH", "Subjugate Demon")

				spell("F1", "Unending Resolve")
				if talent[3][3] then spell("F2", "Dark Pact") else empty("F2") end
				empty("F3")
				empty("F4")
				empty("F5")
				spell("CQ", "Unending Breath")

				spell("T", "Fear")
				spell("ST", "Banish")
				if talent[5][2] then spell("CT", "Mortal Coil") elseif talent[5][3] then spell("CT", "Howl of Terror") else empty("CT") end
				empty("AT")
				spell("CB3", "Demonic Circle")
				spell("SQ", "Drain Life")
				macro("SV", "C02", 29) -- Pet Secondary
				macro("CV", "C03", 23) -- Emergency Felhunter Interrupt

				empty("AB3")
				empty("AF")
				spell("CF", "Demonic Gateway")
				spell("SF", "Demonic Circle: Teleport")
				if talent[3][2] then spell("F", "Burning Rush") else empty("F") end
			else
				--! Untalented Warlock
				spell("1", "Shadow Bolt")
				empty("2")
				empty("3")
				empty("4")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Corruption")
				empty("G")
				empty("SG")
				empty("V")
				empty("SE")

				spell("R", "Curse of Exhaustion")
				spell("SR", "Curse of Weakness")
				empty("CR")
				spell("H", "Health Funnel")
				empty("SH")

				spell("F1", "Unending Resolve")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				spell("T", "Fear")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Drain Life")
				empty("SV")
				empty("CV")

				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				empty("F")
			end
		elseif class == "WARRIOR" then
			--! Warrior

			-- Pummel
			m("C01", nil, "#showtooltip Pummel\n/stopcasting\n/stopcasting\n/use Pummel")
			-- Charge/Intervene
			m("C02", nil, "#showtooltip\n/use [help]Intervene;Charge")
			-- Challenging Shout
			m("C03", 4067374, "#showtooltip\n/use Challenging Shout")

			-- Essence
			essence("N", "Spear of Bastion", "Conqueror's Banner", "Ancient Aftershock", false)

			if spec == 1 then
				--! Arms Warrior
				spell("1", "Colossus Smash")
				spell("2", "Mortal Strike")
				spell("3", "Execute")
				if level < 12 then spell("4", "Slam") else spell("4", "Overpower") end
				if level < 12 then empty("5") elseif talent[5][3] then spell("5", "Cleave") else spell("5", "Slam") end
				if talent[2][3] then spell("CE", "Storm Bolt") else empty("CE") end

				if talent[1][3] then spell("C", "Skullsplitter") else empty("C") end
				spell("SC", "Sweeping Strikes")
				spell("Q", "Whirlwind")
				if talent[3][3] then spell("E", "Rend") else empty("E") end
				if talent[6][2] then spell("G", "Avatar") elseif talent[6][3] then spell("G", "Deadly Calm") else empty("G") end
				empty("SG")
				spell("V", "Bladestorm")
				macro("SE", "C01") -- Pummel

				spell("R", "Taunt")
				spell("SR", "Shattering Throw")
				macro("CR", "C03", 54)
				spell("H", "Heroic Throw")
				empty("SH")

				spell("F1", "Die by the Sword")
				spell("F2", "Rallying Cry")
				empty("F3")
				empty("F4")
				empty("F5")
				spell("CQ", "Ignore Pain")

				spell("T", "Intimidating Shout")
				spell("ST", "Hamstring")
				spell("CT", "Piercing Howl")
				empty("AT")
				empty("CB3")
				spell("SQ", "Victory Rush")
				if talent[4][3] then spell("SV", "Defensive Stance") else empty("SV") end
				spell("CV", "Spell Reflection")

				empty("AB3")
				empty("AF")
				if level >= 43 then macro("CF", "C02") else spell("CF", "Charge") end
				spell("SF", "Berserker Rage")
				spell("F", "Heroic Leap")
			elseif spec == 2 then
				--! Fury Warrior
				spell("1", "Bloodthirst")
				if level >= 12 then spell("2", "Raging Blow") else spell("2", "Slam") end
				spell("3", "Execute")
				if level >= 19 then spell("4", "Rampage") else spell("4", "Slam") end
				if talent[7][3] then spell("5", "Siegebreaker") else empty("5") end
				if talent[2][3] then spell("CE", "Storm Bolt") else empty("CE") end

				empty("C")
				empty("SC")
				spell("Q", "Whirlwind")
				if talent[3][3] then spell("E", "Onslaught") else empty("E") end
				spell("G", "Recklessness")
				empty("SG")
				if talent[6][2] then spell("V", "Dragon Roar") elseif talent[6][3] then spell("V", "Bladestorm") else empty("V") end
				macro("SE", "C01") -- Pummel

				spell("R", "Taunt")
				spell("SR", "Shattering Throw")
				macro("CR", "C03", 54)
				spell("H", "Heroic Throw")
				empty("SH")

				spell("F1", "Enraged Regeneration")
				spell("F2", "Rallying Cry")
				empty("F3")
				empty("F4")
				empty("F5")
				spell("CQ", "Ignore Pain")

				spell("T", "Intimidating Shout")
				spell("ST", "Hamstring")
				spell("CT", "Piercing Howl")
				empty("AT")
				empty("CB3")
				spell("SQ", "Victory Rush")
				empty("SV")
				spell("CV", "Spell Reflection")

				empty("AB3")
				empty("AF")
				if level >= 43 then macro("CF", "C02") else spell("CF", "Charge") end
				spell("SF", "Berserker Rage")
				spell("F", "Heroic Leap")
			elseif spec == 3 then
				--! Protection Warrior
				spell("1", "Shield Slam")
				if level >= 12 then spell("2", "Revenge") else spell("2", "Slam") end
				spell("3", "Execute")
				spell("4", "Shield Block")
				if level >= 19 then spell("5", "Thunder Clap") else spell("5", "Whirlwind") end
				if talent[2][3] then spell("CE", "Storm Bolt") else empty("CE") end

				empty("C")
				empty("SC")
				spell("Q", "Ignore Pain")
				if talent[1][3] then empty("E") else spell("E", "Devastate") end
				spell("G", "Avatar")
				empty("SG")
				if talent[3][3] then spell("V", "Dragon Roar") else empty("V") end
				macro("SE", "C01") -- Pummel

				spell("R", "Taunt")
				spell("SR", "Shattering Throw")
				macro("CR", "C03", 54)
				spell("H", "Heroic Throw")
				empty("SH")

				spell("F1", "Demoralizing Shout")
				spell("F2", "Last Stand")
				spell("F3", "Shield Wall")
				spell("F4", "Rallying Cry")
				empty("F5")
				empty("CQ")

				spell("T", "Intimidating Shout")
				spell("ST", "Hamstring")
				spell("CT", "Shockwave")
				empty("AT")
				if talent[6][3] then spell("CB3", "Ravager") else empty("CB3") end
				spell("SQ", "Victory Rush")
				empty("SV")
				spell("CV", "Spell Reflection")

				empty("AB3")
				empty("AF")
				if level >= 43 then macro("CF", "C02") else spell("CF", "Charge") end
				spell("SF", "Berserker Rage")
				spell("F", "Heroic Leap")
			else
				--! Untalented Warrior
				spell("1", "Slam")
				spell("2", "Victory Rush")
				spell("3", "Execute")
				empty("4")
				empty("5")
				empty("CE")

				empty("C")
				empty("SC")
				spell("Q", "Whirlwind")
				empty("E")
				empty("G")
				empty("SG")
				empty("V")
				macro("SE", "C01", 7)

				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")

				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("CQ")

				empty("T")
				spell("ST", "Hamstring")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Victory Rush")
				empty("SV")
				empty("CV")

				empty("AB3")
				empty("AF")
				spell("CF", "Charge")
				empty("SF")
				empty("F")
			end
		end


		-- All Classes
		macro("6", "G026") -- Trinket 1
		macro("7", "G027") -- Trinket 2
		signature("SN")
		racial("AE")
		macro("SX", "G029") -- Tonic
		macro("X", "G028") -- Healthstone

		
		-- PvP Talents
		local pvp1, pvp2, pvp3 = false, false, false

		if level >= 20 then
			local i = 0
			for k, v in pairs(C_SpecializationInfo.GetAllSelectedPvpTalentIDs()) do
				i = i + 1
				if i == 1 then
					pvptalent("J", v)
					pvp1 = true
				elseif i == 2 then
					pvptalent("SJ", v)
					pvp2 = true
				elseif i == 3 then
					pvptalent("CJ", v)
					pvp3 = true
				end
			end
		end

		if not pvp1 then empty("J") end
		if not pvp2 then empty("SJ") end
		if not pvp3 then empty("CJ") end
		-----
	end
end

local function updateEquipmentSets()
	local icons = {
		["Timewalking"] = 463446,
		["Alliance_PvP"] = 463448,
		["Horde_PvP"] = 463449,
		["DEATHKNIGHT_Blood"] = 135770,
		["DEATHKNIGHT_Frost"] = 135773,
		["DEATHKNIGHT_Unholy"] = 135775,
		["DEMONHUNTER_Havoc"] = 1247264,
		["DEMONHUNTER_Vengeance"] = 1247265,
		["DRUID_Balance"] = 136096,
		["DRUID_Feral"] = 132115,
		["DRUID_Guardian"] = 132276,
		["DRUID_Restoration"] = 136041,
		["HUNTER_Beast Mastery"] = 461112,
		["HUNTER_Marksmanship"] = 236179,
		["HUNTER_Survival"] = 461113,
		["MAGE_Arcane"] = 135932,
		["MAGE_Fire"] = 135810,
		["MAGE_Frost"] = 135846,
		["MONK_Brewmaster"] = 608951,
		["MONK_Mistweaver"] = 608952,
		["MONK_Windwalker"] = 608953,
		["PALADIN_Holy"] = 135920,
		["PALADIN_Protection"] = 236264,
		["PALADIN_Retribution"] = 135873,
		["PRIEST_Discipline"] = 135940,
		["PRIEST_Holy"] = 237542,
		["PRIEST_Shadow"] = 136207,
		["ROGUE_Assassination"] = 236270,
		["ROGUE_Outlaw"] = 236286,
		["ROGUE_Subtlety"] = 132320,
		["SHAMAN_Elemental"] = 136048,
		["SHAMAN_Enhancement"] = 237581,
		["SHAMAN_Restoration"] = 136052,
		["WARLOCK_Affliction"] = 136145,
		["WARLOCK_Demonology"] = 136172,
		["WARLOCK_Destruction"] = 136186,
		["WARRIOR_Arms"] = 132355,
		["WARRIOR_Fury"] = 132347,
		["WARRIOR_Protection"] = 132341,
	}

	local _,class = UnitClass("player")
	local faction = UnitFactionGroup("player")
	local sets = C_EquipmentSet.GetEquipmentSetIDs()

	if sets then
		for i, id in pairs(sets) do
			local name = C_EquipmentSet.GetEquipmentSetInfo(id)

			if icons[name] then
				C_EquipmentSet.ModifyEquipmentSet(id, name, icons[name])
			elseif icons[class.."_"..name] then
				C_EquipmentSet.ModifyEquipmentSet(id, name, icons[class.."_"..name])
			elseif icons[faction.."_"..name] then
				C_EquipmentSet.ModifyEquipmentSet(id, name, icons[faction.."_"..name])
			end
		end
	end
end

local function eventHandler(self, event)
	if event == "PLAYER_LOGIN" then
		-- Prevent anything from happening before PLAYER_LOGIN has triggered at least once
		loaded = true
	end

	if InCombatLockdown() then
		-- If we are in combat, delay until after combat
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		if event == "PLAYER_REGEN_ENABLED" then
			frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
			updateBars()
		elseif loaded then
			if throttled then
				return
			else
				throttled = true
				C_Timer.After(1, function()
					throttled = false
				end)
			end

			C_Timer.After(1, updateBars)
		end
	end
end
frame:SetScript("OnEvent", eventHandler)

function SlashCmdList.PLACER(msg, editbox)
	if msg == "clear" then
		for i = 1, 120 do
			PickupAction(i)
			ClearCursor()
		end
	else
		updateBars()
		updateEquipmentSets()
	end
end