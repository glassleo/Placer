SLASH_PLACER1 = "/placer"

local frame = CreateFrame("FRAME", "Placer")

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")

local loaded = false


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
}

-- Hex
-- Frog, Compy, Spider, Snake, Cockroach, Skeletal Hatchling, Zandalari Tendonripper, Wicker Mongrel
local hex = {
	-- Alliance
	["Octavia"] = "Spider",
	["Tracyanne"]="Frog",
	["Torvald"] = "Cockroach",
	["Pavla"] 	= "Frog",
	["Florence"]= "Wicker Mongrel",
	["Berg"] 	= "Frog",
	["Song"] 	= "Frog",
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


local slotNames = {
	-- Left
	["C"] = 25,
	["N"] = 26,
	["Q"] = 27,
	["E"] = 28,
	["R"] = 29,
	["CR"] = 30,
	["T"] = 31,
	["ST"] = 32,
	["CT"] = 33,
	["CB3"] = 34,
	["CE"] = 35,
	["SE"] = 36,
	["1"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["G"] = 8,
	["SG"] = 9,
	["V"] = 10,
	["SV"] = 11,
	["CV"] = 12,
	-- Middle
	["H"] = 97,
	["SH"] = 98,
	["CC"] = 73,
	["CH"] = 74,
	-- Right
	["AE"] = 37,
	["SR"] = 38,
	["CQ"] = 39,
	["AB3"] = 40,
	["CF"] = 41,
	["SF"] = 42,
	["F"] = 43,
	["F1"] = 13,
	["F2"] = 14,
	["F3"] = 15,
	["F4"] = 16,
	["SQ"] = 17,
	["SX"] = 18,
	["X"] = 19,
	-- Bear Form
	["Bear C"] = 85,
	["Bear N"] = 86,
	["Bear Q"] = 87,
	["Bear E"] = 88,
	["Bear R"] = 89,
	["Bear CR"] = 90,
	["Bear T"] = 91,
	["Bear ST"] = 92,
	["Bear CT"] = 93,
	["Bear CB3"] = 94,
	["Bear CE"] = 95,
	["Bear SE"] = 96,
	["Bear 1"] = 49,
	["Bear 2"] = 50,
	["Bear 3"] = 51,
	["Bear 4"] = 52,
	["Bear 5"] = 53,
	["Bear 6"] = 54,
	["Bear 7"] = 55,
	["Bear G"] = 56,
	["Bear SG"] = 57,
	["Bear V"] = 58,
	["Bear SV"] = 59,
	["Bear CV"] = 60,
	-- Cat Form
	["Cat C"] = 109,
	["Cat N"] = 110,
	["Cat Q"] = 111,
	["Cat E"] = 112,
	["Cat R"] = 113,
	["Cat CR"] = 114,
	["Cat T"] = 115,
	["Cat ST"] = 116,
	["Cat CT"] = 117,
	["Cat CB3"] = 118,
	["Cat CE"] = 119,
	["Cat SE"] = 120,
	["Cat 1"] = 61,
	["Cat 2"] = 62,
	["Cat 3"] = 63,
	["Cat 4"] = 64,
	["Cat 5"] = 65,
	["Cat 6"] = 66,
	["Cat 7"] = 67,
	["Cat G"] = 68,
	["Cat SG"] = 69,
	["Cat V"] = 70,
	["Cat SV"] = 71,
	["Cat CV"] = 72,
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

	if level >= requiredLevel then
		if actionType == "spell" and actionDataId == spellId then
			todo = nil
		end
	else
		todo = "clear"
	end


	if todo == "place" then
		-- Place spell

		-- Some spells have multiple spell IDs depending on talents or stance, attempt to pick up any
		-- Get spell IDs in game, Wowhead usually lists wrong IDs: /dump GetSpellInfo("Thrash")
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
		elseif spellName == "Thrash" then
			spellById(slotId, 77758) -- Feral or Guardian spec or affinity
			spellById(slotId, 106832) -- other spec or affinity
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
			-- Void Eruption is Void Bolt in Voidform
			local _, _, _, _, _, _, spellId2 = GetSpellInfo("Void Bolt")
			PickupSpell(spellId2)
			PlaceAction(slotId)
			ClearCursor()
		end

		-- Place spell
		PickupAction(slotId)
		ClearCursor()
		PickupSpell(spellId)
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
		["Human"] = "Every Man for Himself",
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

local function custom(slotName, spellName)
	local slotId = slotNames[slotName]
	local name,_ = UnitName("player")
	local hexId = { ["Frog"] = 51514, ["Compy"] = 210873, ["Spider"] = 211004, ["Snake"] = 211010, ["Cockroach"] = 211015, ["Skeletal Hatchling"] = 269352, ["Zandalari Tendonripper"] = 277778, ["Wicker Mongrel"] = 277784, }
	local polyId = { ["Sheep"] = 118, ["Pig"] = 28272, ["Turtle"] = 28271, ["Black Cat"] = 61305, ["Rabbit"] = 61721, ["Monkey"] = 161354, ["Porcupine"] = 126819, ["Penguin"] = 161355, ["Polar Bear Cub"] = 161353, ["Direhorn"] = 277787, ["Bumblebee"] = 277792, }

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
end


local function updateBars()
	if InCombatLockdown() then
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		-- CVars
		SetCVar("mapFade", 0)

		-- Local Variables
		local name = UnitName("player")
		local _,class = UnitClass("player")
		local faction = UnitFactionGroup("player")
		local level = UnitLevel("player")
		local spec = GetSpecialization()
		local talent = {}
		local timewalking = false

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


		-- Replace macros
		local _,numMacros = GetNumMacros()
		local mi = 0

		if numMacros >= 1 then
			for i = 121, (121+numMacros) do
				mi = mi + 1
				local mp = "0"
				if mi >= 10 then
					mp = ""
				end
				EditMacro(i, "C"..mp..mi, "inv_misc_questionmark", "", 1, 1)
			end
		end

		if numMacros < 18 then
			for i = 1, (18-numMacros) do
				mi = mi + 1
				local mp = "0"
				if mi >= 10 then
					mp = ""
				end
				CreateMacro("C"..mp..mi, "inv_misc_questionmark", "", 1, 1)
			end
		end


		if class == "DEATHKNIGHT" then
			-- Death Knight Macros
			-----
			-- Mind Freeze
			m("C01", nil, "#showtooltip Mind Freeze\n#showtooltip Mind Freeze\n/stopcasting\n/stopcasting\n/use Mind Freeze")
			-- Wraith Walk
			m("C02", nil, "#showtooltip Wraith Walk\n/use !Wraith Walk")
			-- Gorefiend's Grasp @player
			m("C03", 1037260, "#showtooltip Gorefiend's Grasp\n/use [@player]Gorefiend's Grasp")
			-- Leap
			m("C04", 237569, "#showtooltip\n/use Leap")
			-- Huddle
			m("C05", 136187, "#showtooltip\n/use Huddle")
			-- Gnaw
			m("C06", 237524, "#showtooltip\n/use Gnaw")
			-----
			if spec == 1 then
				-- Blood
				-----
				if talent[1][2] then spell("N", "Blooddrinker") elseif talent[1][3] then spell("N", "Rune Strike") else empty("N") end
				spell("Q", "Blood Boil")
				spell("E", "Death's Caress")
				if talent[7][3] then spell("R", "Bonestorm") else empty("R") end
				empty("SR")
				empty("T")
				empty("ST")
				spell("CT", "Control Undead")
				empty("CB3")
				spell("CE", "Asphyxiate")
				macro("SE", "C01", 62) -- Mind Freeze
				-----
				spell("1", "Dark Command")
				spell("2", "Marrowrend")
				spell("3", "Heart Strike")
				spell("4", "Death and Decay")
				spell("5", "Death Strike")
				spell("G", "Dancing Rune Weapon")
				if talent[4][3] then spell("V", "Rune Tap") else empty("V") end
				if talent[2][3] then spell("SV", "Consumption") else empty("SV") end
				if talent[6][3] then spell("CV", "Mark of Blood") else empty("CV") end
				-----
				-----
				macro("SR", "C03", 64) -- Gorefiend's Grasp @player
				spell("CQ", "Path of Frost")
				spell("AB3", "Gorefiend's Grasp")
				spell("CF", "Death Grip")
				if talent[5][3] then macro("SF", "C02") else empty("SF") end -- Wraith Walk
				spell("F", "Death's Advance")
				-----
				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				spell("F3", "Vampiric Blood")
				if talent[3][3] then spell("F4", "Tombstone") else empty("F4") end
				empty("SQ")
				-----
			elseif spec == 2 then
				-- Frost
				-----
				empty("N")
				if talent[4][3] then spell("Q", "Frostscythe") else empty("Q") end
				spell("E", "Howling Blast")
				if talent[2][3] then spell("R", "Horn of Winter") else empty("R") end
				empty("CR")
				spell("T", "Chains of Ice")
				empty("ST")
				spell("CT", "Control Undead")
				empty("CB3")
				if talent[3][2] then spell("CE", "Asphyxiate") elseif talent[3][3] then spell("CE", "Blinding Sleet") else empty("CE") end
				macro("SE", "C01", 62) -- Mind Freeze
				-----
				spell("1", "Frost Strike")
				spell("2", "Obliterate")
				spell("3", "Remorseless Winter")
				if talent[6][2] then spell("4", "Glacial Advance") elseif talent[6][3] then spell("4", "Frostwyrm's Fury") else empty("4") end
				if talent[7][3] then spell("5", "Breath of Sindragosa") else empty("5") end
				spell("G", "Empower Rune Weapon")
				spell("V", "Pillar of Frost")
				empty("SV")
				empty("CV")
				-----
				-----
				spell("SR", "Dark Command")
				spell("CQ", "Path of Frost")
				empty("AB3")
				spell("CF", "Death Grip")
				if talent[5][2] then macro("SF", "C02") else empty("SF") end -- Wraith Walk
				spell("F", "Death's Advance")
				-----
				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				if talent[5][3] then spell("F3", "Death Pact") else empty("F3") end
				empty("F4")
				spell("SQ", "Death Strike")
				-----
			elseif spec == 3 then
				-- Unholy
				-----
				if talent[4][3] then spell("N", "Soul Reaper") else empty("N") end
				if talent[6][3] then spell("Q", "Epidemic") else empty("Q") end
				spell("E", "Outbreak")
				if talent[2][3] then spell("R", "Unholy Blight") else empty("R") end
				empty("CR")
				spell("T", "Chains of Ice")
				macro("ST", "C06") -- Gnaw
				spell("CT", "Control Undead")
				empty("CB3")
				if talent[3][3] then spell("CE", "Asphyxiate") else empty("CE") end
				macro("SE", "C01", 62) -- Mind Freeze
				-----
				spell("1", "Festering Strike")
				spell("2", "Scourge Strike")
				spell("3", "Death Coil")
				spell("4", "Death and Decay")
				spell("5", "Apocalypse")
				if talent[7][2] then spell("G", "Unholy Frenzy") elseif talent[7][3] then spell("G", "Summon Gargoyle") else empty("G") end
				spell("V", "Dark Transformation")
				spell("SV", "Army of the Dead")
				macro("CV", "C04") -- Leap
				-----
				-----
				spell("SR", "Dark Command")
				spell("CQ", "Path of Frost")
				empty("AB3")
				spell("CF", "Death Grip")
				if talent[5][2] then macro("SF", "C02") else empty("SF") end -- Wraith Walk
				spell("F", "Death's Advance")
				-----
				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				if talent[5][3] then spell("F3", "Death Pact") else empty("F3") end
				macro("F4", "C05") -- Huddle
				spell("SQ", "Death Strike")
				-----
			end
		elseif class == "DEMONHUNTER" then
			-- Demon Hunter Macros
			-----
			-- Felblade/Demon's Bite
			m("C01", nil, "#showtooltip\n/use [talent:1/3,talent:2/2]Felblade;Demon's Bite")
			-- Metamorphosis @player
			m("C02", nil, "#showtooltip Metamorphosis\n/use [@player]Metamorphosis")
			-- Metamorphosis
			m("C03", 1344650, "#showtooltip\n/use Metamorphosis")
			-- Disrupt
			m("C04", nil, "#showtooltip Disrupt\n/stopcasting\n/stopcasting\n/use Disrupt")
			-----
			if spec == 1 then
				-- Havoc
				-----
				spell("N", "Throw Glaive")
				if talent[2][3] then spell("Q", "Immolation Aura") else empty("Q") end
				if talent[5][3] then spell("E", "Dark Slash") else empty("E") end
				if talent[1][3] and not talent[2][2] then spell("R", "Felblade") else empty("R") end
				spell("CR", "Consume Magic")
				spell("T", "Imprison")
				empty("ST")
				if talent[6][3] then spell("CT", "Fel Eruption") else empty("CT") end
				empty("CB3")
				spell("CE", "Chaos Nova")
				macro("SE", "C04") -- Disrupt
				-----
				macro("1", "C01") -- Felblade/Demon's Bite
				spell("2", "Chaos Strike")
				spell("3", "Blade Dance")
				spell("4", "Eye Beam")
				if talent[3][3] then spell("5", "Fel Barrage") else empty("5") end
				if talent[7][3] then spell("G", "Nemesis") else empty("G") end
				macro("V", "C02") -- Metamorphosis @player
				macro("SV", "C03") -- Metamorphosis
				spell("CV", "Spectral Sight")
				-----
				-----
				spell("SR", "Torment")
				empty("CQ")
				empty("AB3")
				empty("CF")
				spell("SF", "Vengeful Retreat")
				spell("F", "Fel Rush")
				-----
				spell("F1", "Blur")
				if talent[4][3] then spell("F2", "Netherwalk") else empty("F2") end
				spell("F3", "Darkness")
				empty("F4")
				empty("SQ")
				-----
			elseif spec == 2 then
				-- Vengeance
				-----
				spell("N", "Throw Glaive")
				spell("Q", "Immolation Aura")
				spell("E", "Sigil of Flame")
				if talent[3][3] then spell("R", "Felblade") else empty("R") end
				spell("CR", "Consume Magic")
				spell("T", "Imprison")
				spell("ST", "Sigil of Misery")
				empty("CT")
				empty("CB3")
				spell("CE", "Sigil of Silence")
				macro("SE", "C04") -- Disrupt
				-----
				spell("1", "Torment")
				spell("2", "Shear")
				spell("3", "Soul Cleave")
				spell("4", "Demon Spikes")
				if talent[6][2] then spell("5", "Spirit Bomb") elseif talent[6][3] then spell("5", "Fel Devastation") else empty("5") end
				spell("G", "Metamorphosis")
				if talent[7][3] then spell("V", "Soul Barrier") else empty("V") end
				empty("SV")
				spell("CV", "Spectral Sight")
				-----
				-----
				empty("SR")
				empty("CQ")
				if talent[5][3] then spell("AB3", "Sigil of Chains") else empty("AB3") end
				spell("CF", "Infernal Strike")
				empty("SF")
				empty("F")
				-----
				spell("F1", "Fiery Brand")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("SQ")
				-----
			end
		elseif class == "DRUID" then
			-- Druid Macros
			-----
			-- Solar Wrath/Regrowth
			m("C01", nil, "#showtooltip\n/use [help]Regrowth;[spec:1][spec:2,talent:3/1][spec:3,talent:3/1][spec:4,talent:3/1,form:4][spec:4,harm]Solar Wrath;Regrowth")
			-- Lunar Strike/Swiftmend
			m("C02", nil, "#showtooltip\n/use [spec:1,talent:3/3,help][spec:4,talent:3/1,form:4,help]Swiftmend;[spec:1][spec:4,talent:3/1,stance:4][spec:4,talent:3/1,harm]Lunar Strike;Swiftmend")
			-- Starsurge/Wild Growth
			m("C03", nil, "#showtooltip\n/use [spec:4,talent:3/1,form:4,help]Wild Growth;[spec:1,talent:3/3,help]Wild Growth;[spec:1][spec:4,talent:3/1,form:4][spec:4,talent:3/1,harm]Starsurge;Wild Growth")
			-- Sunfire/Lifebloom
			m("C04", nil, "#showtooltip\n/use [help]Lifebloom;[harm][talent:3/1,stance:4]Sunfire(Solar);Lifebloom")
			-- Moonfire/Rejuvenation/Rake
			m("C05", nil, "#showtooltip\n/use [nospec:4,talent:3/3,help][spec:4,help]Rejuvenation;[spec:1,form:2,talent:3/1][spec:2,form:2][spec:3/4,form:2,talent:3/2]Rake;[spec:4,harm][form:1][spec:4,talent:3/1,form:4]Moonfire;[spec:4]Rejuvenation;Moonfire")
			-- Innervate @player
			m("C06", 237551, "#showtooltip Innervate\n/use [@player]Innervate")
			-- Innervate
			m("C07", nil, "#showtooltip Innervate\n/use [@focus,help][exists,help]Innervate")
			-- Remove Corruption/Nature's Cure/Soothe
			m("C08", nil, "#showtooltip\n/use [harm]Soothe;[spec:4]Nature's Cure;Remove Corruption")
			-- Solar Beam/Skull Bash
			m("C09", nil, "#showtooltip [spec:1] Solar Beam; Skull Bash\n/stopcasting\n/stopcasting\n/use [spec:1]Solar Beam;[spec:2,noform:1,noform:2]Cat Form;[noform:1,noform:2]Bear Form\n/use [spec:2/3]Skull Bash")
			-- Dash
			m("C10", nil, "#showtooltip Dash\n/use [form:2]Dash;Cat Form")
			-- Bear Form
			m("C11", nil, "#showtooltip Bear Form\n/use [noform:1]Bear Form")
			-- Cat Form
			m("C12", nil, "#showtooltip Cat Form\n/use [noform:2]Cat Form")
			-- Caster Form
			m("C13", 461117, "/stopcasting\n/stopcasting\n/cancelform [noform:4,noform:5]")
			-- Moonkin Form
			m("C14", nil, "#showtooltip Moonkin Form\n/stopcasting\n/stopcasting\n/use [noform:4]Moonkin Form")
			-- Treant Form
			m("C15", nil, "#showtooltip Treant Form\n/use [nospec:1,talent:3/1,noform:5][nospec:1,notalent:3/1,noform:4][spec:1,noform:5]Treant Form")
			-----
			if spec == 1 then
				-- Balance
				-----
				empty("N")
				spell("Q", "Starfall")
				macro("E", "C05", 3) -- Moonfire
				if talent[7][2] then spell("R", "Fury of Elune") elseif talent[7][3] then spell("R", "New Moon") else empty("R") end
				macro("CR", "C08", 22) -- Remove Corruption/Soothe
				spell("T", "Hibernate")
				spell("ST", "Entangling Roots")
				if talent[4][1] then spell("CT", "Mighty Bash") elseif talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				if talent[4][3] then spell("CB3", "Typhoon") else empty("CB3") end
				empty("CE")
				macro("SE", "C09", 80) -- Solar Beam
				-----
				macro("1", "C01") -- Solar Wrath/Regrowth
				macro("2", "C02", 12) -- Lunar Strike/Swiftmend
				macro("3", "C03", 10) -- Starsurge/Wild Growth
				spell("4", "Sunfire")
				if talent[6][3] then spell("5", "Stellar Flare") else empty("5") end
				spell("G", "Celestial Alignment")
				if talent[1][2] then spell("V", "Warrior of Elune") elseif talent[1][3] then spell("V", "Force of Nature") else empty("V") end
				macro("SV", "C14", 20) -- Moonkin Form
				spell("CV", "Prowl")
				-----
				-----
				empty("Bear N")
				if talent[3][2] then spell("Bear Q", "Thrash") else empty("Bear Q") end
				macro("Bear E", "C05") -- Moonfire
				empty("Bear R")
				macro("Bear CR", "C08", 22) -- Remove Corruption/Soothe
				spell("Bear T", "Hibernate")
				spell("Bear ST", "Entangling Roots")
				if talent[4][1] then spell("Bear CT", "Mighty Bash") elseif talent[4][2] then spell("Bear CT", "Mass Entanglement") else empty("Bear CT") end
				if talent[4][3] then spell("Bear CB3", "Typhoon") else empty("Bear CB3") end
				empty("Bear CE")
				macro("Bear SE", "C09", 80) -- Solar Beam
				-----
				spell("Bear 1", "Growl")
				spell("Bear 2", "Mangle")
				if talent[3][1] then spell("Bear 3", "Swipe") else empty("Bear 3") end
				if talent[3][2] then spell("Bear 4", "Ironfur") else empty("Bear 4") end
				if talent[3][2] then spell("Bear 5", "Frenzied Regeneration") else empty("Bear 5") end
				empty("Bear G")
				empty("Bear V")
				if level >= 20 then macro("Bear SV", "C14") else macro("Bear SV", "C13") end -- Moonkin Form
				spell("Bear CV", "Prowl")
				-----
				-----
				spell("Cat N", "Moonfire")
				if talent[3][2] then spell("Cat Q", "Thrash") else empty("Cat Q") end
				if talent[3][1] then macro("Cat E", "C05") elseif talent[3][3] then spell("Cat E", "Rejuvenation") else empty("Cat E") end -- Rake/Rejuvenation
				empty("Cat R")
				macro("Cat CR", "C08", 22) -- Remove Corruption/Soothe
				spell("Cat T", "Hibernate")
				spell("Cat ST", "Entangling Roots")
				if talent[4][1] then spell("Cat CT", "Mighty Bash") elseif talent[4][2] then spell("Cat CT", "Mass Entanglement") else empty("Cat CT") end
				if talent[4][3] then spell("Cat CB3", "Typhoon") else empty("Cat CB3") end
				empty("Cat CE")
				macro("Cat SE", "C09", 80) -- Solar Beam
				-----
				spell("Cat 1", "Shred")
				if talent[3][1] then spell("Cat 2", "Rip") else empty("Cat 2") end
				if talent[3][1] then spell("Cat 3", "Ferocious Bite") else empty("Cat 3") end
				if talent[3][1] then spell("Cat 4", "Swipe") else empty("Cat 4") end
				empty("Cat 5")
				empty("Cat G")
				empty("Cat V")
				if level >= 20 then macro("Cat SV", "C14") else macro("Cat SV", "C13") end -- Moonkin Form
				spell("Cat CV", "Prowl")
				-----
				-----
				empty("SR")
				spell("CQ", "Flap")
				spell("AB3", "Travel Form")
				if talent[2][3] then spell("CF", "Wild Charge") else empty("CF") end
				empty("SF")
				macro("F", "C10", 8) -- Dash
				-----
				spell("F1", "Barkskin")
				macro("F2", "C11", 10) -- Bear Form
				if talent[2][2] then spell("F3", "Renewal") else empty("F3") end
				empty("F4")
				spell("SQ", "Regrowth")
				-----
			elseif spec == 2 then
				-- Feral
				-----
				empty("N")
				empty("Q")
				macro("E", "C05") -- Moonfire
				empty("R")
				macro("CR", "C08", 22) -- Remove Corruption/Soothe
				spell("T", "Hibernate")
				spell("ST", "Entangling Roots")
				if talent[4][1] then spell("CT", "Mighty Bash") elseif talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				if talent[4][3] then spell("CB3", "Typhoon") else empty("CB3") end
				empty("CE")
				macro("SE", "C09", 70) -- Skull Bash
				-----
				macro("1", "C01")
				if talent[3][1] then spell("2", "Lunar Strike") elseif talent[3][3] then spell("2", "Swiftmend") else empty("2") end
				if talent[3][1] then spell("3", "Starsurge") elseif talent[3][3] then spell("3", "Wild Growth") else empty("3") end
				if talent[3][1] then spell("4", "Sunfire(Solar)") else empty("4") end
				empty("5")
				empty("G")
				empty("V")
				macro("SV", "C12") -- Cat Form
				spell("CV", "Prowl")
				-----
				-----
				empty("Bear N")
				spell("Bear Q", "Thrash")
				macro("Bear E", "C05") -- Moonfire
				empty("Bear R")
				macro("Bear CR", "C08", 22) -- Remove Corruption/Soothe
				spell("Bear T", "Hibernate")
				spell("Bear ST", "Entangling Roots")
				if talent[4][1] then spell("Bear CT", "Mighty Bash") elseif talent[4][2] then spell("Bear CT", "Mass Entanglement") else empty("Bear CT") end
				if talent[4][3] then spell("Bear CB3", "Typhoon") else empty("Bear CB3") end
				empty("Bear CE")
				macro("Bear SE", "C09", 70) -- Skull Bash
				-----
				spell("Bear 1", "Growl")
				spell("Bear 2", "Mangle")
				spell("Bear 3", "Swipe")
				if talent[3][2] then spell("Bear 4", "Ironfur") else empty("Bear 4") end
				if talent[3][2] then spell("Bear 5", "Frenzied Regeneration") else empty("Bear 5") end
				empty("Bear G")
				empty("Bear V")
				macro("Bear SV", "C12") -- Cat Form
				spell("Bear CV", "Prowl")
				-----
				-----
				spell("Cat N", "Moonfire")
				spell("Cat Q", "Thrash")
				macro("Cat E", "C05") -- Rake
				if talent[6][2] then spell("Cat R", "Savage Roar") else empty("Cat R") end
				macro("Cat CR", "C08", 22) -- Remove Corruption/Soothe
				spell("Cat T", "Hibernate")
				spell("Cat ST", "Entangling Roots")
				if talent[4][1] then spell("Cat CT", "Mighty Bash") elseif talent[4][2] then spell("Cat CT", "Mass Entanglement") else empty("Cat CT") end
				if talent[4][3] then spell("Cat CB3", "Typhoon") else empty("Cat CB3") end
				spell("Cat CE", "Maim")
				macro("Cat SE", "C09", 70) -- Skull Bash
				-----
				spell("Cat 1", "Shred")
				spell("Cat 2", "Rip")
				spell("Cat 3", "Ferocious Bite")
				spell("Cat 4", "Swipe")
				if talent[7][3] then spell("Cat 5", "Feral Frenzy") elseif talent[6][3] then spell("Cat 5", "Primal Wrath") else empty("Cat 5") end
				spell("Cat G", "Berserk")
				spell("Cat V", "Tiger's Fury")
				spell("Cat SV", "Prowl")
				spell("Cat CV", "Prowl")
				-----
				-----
				if talent[3][1] then macro("SR", "C14") elseif talent[3][3] then macro("SR", "C14") else empty("SR") end -- Moonkin Form/Caster Form
				if talent[3][1] then spell("CQ", "Flap") else empty("CQ") end
				spell("AB3", "Travel Form")
				if talent[2][3] then spell("CF", "Wild Charge") else empty("CF") end
				spell("SF", "Stampeding Roar")
				macro("F", "C10") -- Dash
				-----
				spell("F1", "Survival Instincts")
				macro("F2", "C11") -- Bear Form
				if talent[2][2] then spell("F3", "Renewal") else empty("F3") end
				empty("F4")
				spell("SQ", "Regrowth")
				-----
			elseif spec == 3 then
				-- Guardian
				-----
				empty("N")
				empty("Q")
				macro("E", "C05") -- Moonfire
				empty("R")
				macro("CR", "C08", 22) -- Remove Corruption/Soothe
				spell("T", "Hibernate")
				spell("ST", "Entangling Roots")
				if talent[4][1] then spell("CT", "Mighty Bash") elseif talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				if talent[4][3] then spell("CB3", "Typhoon") else empty("CB3") end
				spell("CE", "Incapacitating Roar")
				macro("SE", "C09", 70) -- Skull Bash
				-----
				macro("1", "C01") -- Solar Wrath/Regrowth
				if talent[3][1] then spell("2", "Lunar Strike") elseif talent[3][3] then spell("2", "Swiftmend") else empty("2") end
				if talent[3][1] then spell("3", "Starsurge") elseif talent[3][3] then spell("3", "Wild Growth") else empty("3") end
				if talent[3][1] then spell("4", "Sunfire(Solar)") else empty("4") end
				empty("5")
				empty("G")
				empty("V")
				macro("SV", "C11") -- Bear Form
				spell("CV", "Prowl")
				-----
				-----
				if talent[1][3] then spell("Bear N", "Bristling Fur") else empty("Bear N") end
				spell("Bear Q", "Thrash")
				macro("Bear E", "C05") -- Moonfire
				spell("Bear R", "Maul")
				macro("Bear CR", "C08", 22) -- Remove Corruption/Soothe
				spell("Bear T", "Hibernate")
				spell("Bear ST", "Entangling Roots")
				if talent[4][1] then spell("Bear CT", "Mighty Bash") elseif talent[4][2] then spell("Bear CT", "Mass Entanglement") else empty("Bear CT") end
				if talent[4][3] then spell("Bear CB3", "Typhoon") else empty("Bear CB3") end
				spell("Bear CE", "Incapacitating Roar")
				macro("Bear SE", "C09", 70) -- Skull Bash
				-----
				spell("Bear 1", "Growl")
				spell("Bear 2", "Mangle")
				spell("Bear 3", "Swipe")
				spell("Bear 4", "Ironfur")
				spell("Bear 5", "Frenzied Regeneration")
				if talent[5][3] then spell("Bear G", "Incarnation: Guardian of Ursoc") else empty("Bear G") end
				if talent[7][2] then spell("Bear V", "Lunar Beam") elseif talent[7][3] then spell("Bear V", "Pulverize") else empty("Bear V") end
				macro("Bear SV", "C11") -- Bear Form
				spell("Bear CV", "Prowl")
				-----
				-----
				spell("Cat N", "Moonfire")
				spell("Cat Q", "Thrash")
				if talent[3][2] then macro("Cat E", "C05") elseif talent[3][3] then spell("Cat E", "Rejuvenation") else empty("Cat E") end -- Rake/Rejuvenation
				empty("Cat R")
				macro("Cat CR", "C08", 22) -- Remove Corruption/Soothe
				spell("Cat T", "Hibernate")
				spell("Cat ST", "Entangling Roots")
				if talent[4][1] then spell("Cat CT", "Mighty Bash") elseif talent[4][2] then spell("Cat CT", "Mass Entanglement") else empty("Cat CT") end
				if talent[4][3] then spell("Cat CB3", "Typhoon") else empty("Cat CB3") end
				spell("Cat CE", "Incapacitating Roar")
				macro("Cat SE", "C09", 70) -- Skull Bash
				-----
				spell("Cat 1", "Shred")
				if talent[3][2] then spell("Cat 2", "Rip") else empty("Cat 2") end
				if talent[3][2] then spell("Cat 3", "Ferocious Bite") else empty("Cat 3") end
				spell("Cat 4", "Swipe")
				empty("Cat 5")
				empty("Cat G")
				empty("Cat V")
				macro("Cat SV", "C11") -- Bear Form
				spell("Cat CV", "Prowl")
				-----
				-----
				if talent[3][1] then macro("SR", "C14") elseif talent[3][3] then macro("SR", "C13") else empty("SR") end -- Moonkin Form/Caster Form
				if talent[3][1] then spell("CQ", "Flap") else empty("CQ") end
				spell("AB3", "Travel Form")
				if talent[2][3] then spell("CF", "Wild Charge") else empty("CF") end
				spell("SF", "Stampeding Roar")
				macro("F", "C10") -- Dash
				-----
				spell("F1", "Barkskin")
				spell("F2", "Survival Instincts")
				empty("F3")
				empty("F4")
				spell("SQ", "Regrowth")
				-----
			elseif spec == 4 then
				-- Restoration
				-----
				macro("N", "C06") -- Innervate @player
				spell("Q", "Efflorescence")
				macro("E", "C05") -- Rejuvenation
				if talent[7][3] then spell("R", "Flourish") else empty("R") end
				macro("CR", "C08") -- Nature's Cure/Soothe
				spell("T", "Hibernate")
				spell("ST", "Entangling Roots")
				if talent[4][1] then spell("CT", "Mighty Bash") elseif talent[4][2] then spell("CT", "Mass Entanglement") else empty("CT") end
				if talent[4][3] then spell("CB3", "Typhoon") else empty("CB3") end
				spell("CE", "Ursol's Vortex")
				spell("SE", "Ironbark")
				-----
				macro("1", "C01") -- Regrowth
				macro("2", "C02") -- Swiftmend
				macro("3", "C03") -- Wilf Growth
				macro("4", "C04") -- Lifebloom
				if talent[1][3] then spell("5", "Cenarion Ward") else empty("5") end
				if talent[5][3] then spell("G", "Incarnation: Tree of Life") else empty("G") end
				empty("V")
				macro("SV", "C13") -- Caster Form
				spell("CV", "Prowl")
				-----
				-----
				empty("Bear N")
				if talent[3][3] then spell("Bear Q", "Thrash") else empty("Bear Q") end
				macro("Bear E", "C05") -- Moonfire
				empty("Bear R")
				macro("Bear CR", "C08") -- Nature's Cure/Soothe
				spell("Bear T", "Hibernate")
				spell("Bear ST", "Entangling Roots")
				if talent[4][1] then spell("Bear CT", "Mighty Bash") elseif talent[4][2] then spell("Bear CT", "Mass Entanglement") else empty("Bear CT") end
				if talent[4][3] then spell("Bear CB3", "Typhoon") else empty("Bear CB3") end
				spell("Bear CE", "Ursol's Vortex")
				spell("Bear SE", "Ironbark")
				-----
				spell("Bear 1", "Growl")
				spell("Bear 2", "Mangle")
				if talent[3][2] then spell("Bear 3", "Swipe") else empty("Bear 3") end
				if talent[3][3] then spell("Bear 4", "Ironfur") else empty("Bear 4") end
				if talent[3][3] then spell("Bear 5", "Frenzied Regeneration") else empty("Bear 5") end
				empty("Bear G")
				empty("Bear V")
				macro("Bear SV", "C13") -- Caster Form
				spell("Bear CV", "Prowl")
				-----
				-----
				spell("Cat N", "Moonfire")
				if talent[3][3] then spell("Cat Q", "Thrash") else empty("Cat Q") end
				if talent[3][2] then macro("Cat E", "C05") else spell("Cat E", "Rejuvenation") end -- Rake/Rejuvenation
				empty("Cat R")
				macro("Cat CR", "C08") -- Nature's Cure/Soothe
				spell("Cat T", "Hibernate")
				spell("Cat ST", "Entangling Roots")
				if talent[4][1] then spell("Cat CT", "Mighty Bash") elseif talent[4][2] then spell("Cat CT", "Mass Entanglement") else empty("Cat CT") end
				if talent[4][3] then spell("Cat CB3", "Typhoon") else empty("Cat CB3") end
				spell("Cat CE", "Ursol's Vortex")
				spell("Cat SE", "Ironbark")
				-----
				spell("Cat 1", "Shred")
				if talent[3][2] then spell("Cat 2", "Rip") else empty("Cat 2") end
				if talent[3][2] then spell("Cat 3", "Ferocious Bite") else empty("Cat 3") end
				if talent[3][2] then spell("Cat 4", "Swipe") else empty("Cat 4") end
				empty("Cat 5")
				empty("Cat G")
				empty("Cat V")
				macro("Cat SV", "C13") -- Caster Form
				spell("Cat CV", "Prowl")
				-----
				-----
				if talent[3][1] then macro("SR", "C14") else empty("SR") end -- Moonkin Form
				if talent[3][1] then spell("CQ", "Flap") else empty("CQ") end
				spell("AB3", "Travel Form")
				if talent[2][3] then spell("CF", "Wild Charge") else empty("CF") end
				empty("SF")
				macro("F", "C10") -- Dash
				-----
				spell("F1", "Barkskin")
				macro("F2", "C11") -- Bear Form
				if talent[2][2] then spell("F3", "Renewal") else empty("F3") end
				spell("F4", "Tranquility")
				spell("SQ", "Regrowth")
				-----
			end

			-- All Druid Specs
			if level >= 120 then spell("Bear C", "Heart Essence") else empty("Bear C") end
			macro("Bear 6", "Trinket 1")
			macro("Bear 7", "Trinket 2")
			macro("Bear SG", "Potion")

			if level >= 120 then spell("Cat C", "Heart Essence") else empty("Cat C") end
			macro("Cat 6", "Trinket 1")
			macro("Cat 7", "Trinket 2")
			macro("Cat SG", "Potion")
			-----
		elseif class == "HUNTER" then
			-- Hunter Macros
			-----
			-- Counter Shot/Muzzle
			m("C01", nil, "#showtooltip [spec:3]Muzzle;Counter Shot\n/stopcasting\n/stopcasting\n/use [spec:3]Muzzle;Counter Shot")
			-- Growl
			m("C02", 132270, "#showtooltip Growl\n/use [nobtn:2]Growl\n/petautocasttoggle [btn:2]Growl")
			-- Kill Command
			m("C03", nil, "#showtooltip Kill Command\n/petattack\n/petassist\n/use Kill Command")
			-- Misdirection
			m("C04", nil, "#showtooltip Misdirection\n/use [@focus,help][help][@pet,exists][]Misdirection")
			-----
			if spec == 1 then
				-- Beast Mastery
				-----
				if talent[1][3] then spell("N", "Dire Beast") else empty("N") end
				spell("Q", "Multi-Shot")
				if talent[4][3] then spell("E", "A Murder of Crows") else empty("E") end
				if talent[7][3] then spell("R", "Spitting Cobra") else empty("R") end
				macro("CR", "Pet Ability", 20)
				spell("T", "Freezing Trap")
				spell("ST", "Concussive Shot")
				spell("CT", "Tar Trap")
				if talent[5][3] then spell("CB3", "Binding Shot") else empty("CB3") end
				spell("CE", "Intimidation")
				macro("SE", "C01", 32) -- Counter Shot
				-----
				spell("1", "Cobra Shot")
				spell("2", "Barbed Shot")
				macro("3", "C03", 10) -- Kill Command
				if talent[2][3] then spell("4", "Chimaera Shot") else empty("4") end
				if talent[6][2] then spell("5", "Barrage") elseif talent[6][3] then spell("5", "Stampede") else empty("5") end
				spell("G", "Aspect of the Wild")
				spell("V", "Bestial Wrath")
				spell("SV", "Command Pet", 38)
				spell("CV", "Feign Death")
				-----
				-----
				macro("SR", "C02", 10) -- Growl
				macro("CQ", "C04", 42) -- Misdirection
				spell("AB3", "Flare")
				empty("CF")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")
				-----
				spell("F1", "Aspect of the Turtle")
				spell("F2", "Exhilaration")
				macro("F3", "Pet Exotic", 20)
				if talent[3][3] then spell("F4", "Camouflage") else empty("F4") end
				spell("SQ", "Revive Pet")
				-----
			elseif spec == 2 then
				-- Marksmanship
				-----
				if talent[4][3] then spell("N", "Hunter's Mark") else empty("N") end
				spell("Q", "Multi-Shot")
				if talent[1][2] then spell("E", "Serpent Sting") elseif talent[1][3] then spell("E", "A Murder of Crows") else empty("E") end
				if talent[2][3] then spell("R", "Explosive Shot") else empty("R") end
				macro("CR", "Pet Ability", 20)
				spell("T", "Freezing Trap")
				spell("ST", "Concussive Shot")
				spell("CT", "Tar Trap")
				spell("CB3", "Bursting Shot")
				if talent[5][3] then spell("CE", "Binding Shot") else empty("CE") end
				macro("SE", "C01", 32) -- Counter Shot
				-----
				spell("1", "Arcane Shot")
				spell("2", "Steady Shot")
				spell("3", "Aimed Shot")
				spell("4", "Rapid Fire")
				if talent[6][2] then spell("5", "Barrage") elseif talent[6][3] then spell("5", "Double Tap") else empty("5") end
				spell("G", "Trueshot")
				if talent[7][3] then spell("V", "Piercing Shot") else empty("V") end
				spell("SV", "Command Pet")
				spell("CV", "Feign Death")
				-----
				-----
				macro("SR", "C02", 10) -- Growl
				macro("CQ", "C04", 42) -- Misdirection
				spell("AB3", "Flare")
				empty("CF")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")
				-----
				spell("F1", "Aspect of the Turtle")
				spell("F2", "Exhilaration")
				empty("F3")
				if talent[3][3] then spell("F4", "Camouflage") else empty("F4") end
				spell("SQ", "Revive Pet")
				-----
			elseif spec == 3 then
				-- Survival
				-----
				empty("N")
				spell("Q", "Carve")
				spell("E", "Serpent Sting")
				if talent[7][3] then spell("R", "Chakrams") else empty("R") end
				macro("CR", "Pet Ability", 20)
				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				spell("CT", "Tar Trap")
				if talent[5][3] then spell("CB3", "Binding Shot") else empty("CB3") end
				spell("CE", "Intimidation")
				macro("SE", "C01", 32) -- Muzzle
				-----
				spell("1", "Raptor Strike")
				spell("2", "Wildfire Bomb")
				macro("3", "C03", 10) -- Kill Command
				if talent[4][2] then spell("4", "Steel Trap") elseif talent[4][3] then spell("4", "A Murder of Crows") else empty("4") end
				if talent[6][3] then spell("5", "Flanking Strike") else empty("5") end
				spell("G", "Coordinated Assault")
				spell("V", "Aspect of the Eagle")
				spell("SV", "Command Pet")
				spell("CV", "Feign Death")
				-----
				-----
				macro("SR", "C02", 10) -- Growl
				macro("CQ", "C04", 42) -- Misdirection
				spell("AB3", "Flare")
				spell("CF", "Harpoon")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")
				-----
				spell("F1", "Aspect of the Turtle")
				spell("F2", "Exhilaration")
				empty("F3")
				if talent[3][3] then spell("F4", "Camouflage") else empty("F4") end
				spell("SQ", "Revive Pet")
				-----
			end
		elseif class == "MAGE" then
			-- Mage Macros
			-----
			-- Counterspell
			m("C01", nil, "#showtooltip Counterspell\n/stopcasting\n/stopcasting\n/use Counterspell")
			-- Remove Curse/Spellsteal
			m("C02", nil, "#showtooltip\n/use [harm]Spellsteal;Remove Curse")
			-- Freeze
			m("C03", 1698698, "#showtooltip\n/use Freeze")
			-- Ice Block
			m("C04", nil, "#showtooltip Ice Block\n/use !Ice Block")
			-----
			if spec == 1 then
				-- Arcane
				-----
				spell("N", "Evocation")
				spell("Q", "Arcane Explosion")
				if talent[6][3] then spell("E", "Nether Tempest") else empty("E") end
				if talent[4][2] then spell("R", "Charged Up") elseif talent[4][3] then spell("R", "Supernova") else empty("R") end
				if level >= 70 then macro("CR", "C02") else spell("CR", "Remove Curse") end -- Remove Curse/Spellsteal
				custom("T", "Polymorph")
				spell("ST", "Slow")
				empty("CT")
				if talent[5][3] then spell("CB3", "Ring of Frost") else empty("CB3") end
				spell("CE", "Frost Nova")
				macro("SE", "C01", 22) -- Counterspell
				-----
				spell("1", "Arcane Blast")
				spell("2", "Arcane Missiles")
				spell("3", "Arcane Barrage")
				spell("4", "Presence of Mind")
				if talent[7][3] then spell("5", "Arcane Orb") else empty("5") end
				spell("G", "Arcane Power")
				if talent[3][2] then spell("V", "Mirror Image") elseif talent[3][3] then spell("V", "Rune of Power") else empty("V") end
				spell("SV", "Time Warp")
				spell("CV", "Greater Invisibility")
				-----
				-----
				empty("SR")
				spell("CQ", "Slow Fall")
				empty("AB3")
				spell("CF", "Displacement")
				empty("SF")
				spell("F", "Blink")
				-----
				spell("F1", "Prismatic Barrier")
				macro("F2", "C04", 50) -- Ice Block
				empty("F3")
				empty("F4")
				empty("SQ")
				-----
			elseif spec == 2 then
				-- Fire
				-----
				spell("N", "Scorch")
				spell("Q", "Flamestrike")
				if talent[6][3] then spell("E", "Living Bomb") else empty("E") end
				if talent[7][3] then spell("R", "Meteor") else empty("R") end
				if level >= 70 then macro("CR", "C02") else spell("CR", "Remove Curse") end -- Remove Curse/Spellsteal
				custom("T", "Polymorph")
				if talent[2][3] then spell("ST", "Blast Wave") else empty("ST") end
				empty("CT")
				if talent[5][3] then spell("CB3", "Ring of Frost") else empty("CB3") end
				spell("CE", "Frost Nova")
				macro("SE", "C01", 22) -- Counterspell
				-----
				spell("1", "Fireball")
				spell("2", "Fire Blast")
				spell("3", "Pyroblast")
				spell("4", "Dragon's Breath")
				if talent[4][3] then spell("5", "Phoenix Flames") else empty("5") end
				spell("G", "Combustion")
				if talent[3][2] then spell("V", "Mirror Image") elseif talent[3][3] then spell("V", "Rune of Power") else empty("V") end
				spell("SV", "Time Warp")
				spell("CV", "Invisibility")
				-----
				-----
				empty("SR")
				spell("CQ", "Slow Fall")
				empty("AB3")
				empty("CF")
				empty("SF")
				spell("F", "Blink")
				-----
				spell("F1", "Blazing Barrier")
				macro("F2", "C04", 50) -- Ice Block
				empty("F3")
				empty("F4")
				empty("SQ")
				-----
			elseif spec == 3 then
				-- Frost
				-----
				if talent[7][2] then spell("N", "Ray of Frost") elseif talent[7][3] then spell("N", "Glacial Spike") else empty("N") end
				spell("Q", "Blizzard")
				if talent[1][3] then spell("E", "Ice Nova") else empty("E") end
				if talent[6][3] then spell("R", "Comet Storm") else empty("R") end
				if level >= 70 then macro("CR", "C02") else spell("CR", "Remove Curse") end -- Remove Curse/Spellsteal
				if level >= 8 then custom("T", "Polymorph") else empty("T") end
				spell("ST", "Cone of Cold")
				if not talent[1][2] then macro("CT", "C03", 32) else empty("CT") end -- Freeze
				if talent[5][3] then spell("CB3", "Ring of Frost") else empty("CB3") end
				spell("CE", "Frost Nova")
				macro("SE", "C01", 22) -- Counterspell
				-----
				spell("1", "Frostbolt")
				spell("2", "Ice Lance")
				if level >= 10 then spell("3", "Flurry") else spell("3", "Fire Blast") end
				spell("4", "Frozen Orb")
				if talent[4][3] then spell("5", "Ebonbolt") else empty("5") end
				spell("G", "Icy Veins")
				if talent[3][2] then spell("V", "Mirror Image") elseif talent[3][3] then spell("V", "Rune of Power") else empty("V") end
				spell("SV", "Time Warp")
				spell("CV", "Invisibility")
				-----
				-----
				empty("SR")
				spell("CQ", "Slow Fall")
				empty("AB3")
				empty("CF")
				if talent[2][3] then spell("SF", "Ice Floes") else empty("SF") end
				spell("F", "Blink")
				-----
				spell("F1", "Ice Barrier")
				macro("F2", "C04", 50) -- Ice Block
				spell("F3", "Cold Snap")
				empty("F4")
				empty("SQ")
				-----
			end
		elseif class == "MONK" then
			-- Monk Macros
			-----
			-- Soothing Mist/Tiger Palm
			m("C01", nil, "#showtooltip\n/use [harm]Tiger Palm;Soothing Mist")
			-- Enveloping Mist/Rising Sun Kick
			m("C02", nil, "#showtooltip\n/use [harm]Rising Sun Kick;Enveloping Mist")
			-- Vivify/Blackout Kick
			m("C03", nil, "#showtooltip\n/use [harm]Blackout Kick;Vivify")
			-- Spear Hand Strike
			m("C04", nil, "#showtooltip Spear Hand Strike\n/stopcasting\n/stopcasting\n/use Spear Hand Strike")
			-- Provoke Statue
			m("C05", 628134, "#showtooltip Provoke\n/targetexact Black Ox Statue\n/use Provoke\n/targetlasttarget")
			-----
			if spec == 1 then
				-- Brewmaster
				-----
				spell("N", "Crackling Jade Lightning")
				if talent[6][2] then spell("Q", "Rushing Jade Wind") elseif talent[6][3] then spell("Q", "Invoke Niuzao, the Black Ox") else empty("Q") end
				spell("E", "Breath of Fire")
				if talent[1][2] then spell("R", "Chi Wave") elseif talent[1][3] then spell("R", "Chi Burst") else empty("R") end
				spell("CR", "Detox")
				spell("T", "Paralysis")
				empty("ST")
				empty("CT")
				if talent[4][2] then spell("CB3", "Summon Black Ox Statue") elseif talent[4][3] then spell("CB3", "Ring of Peace") else empty("CB3") end
				spell("CE", "Leg Sweep")
				macro("SE", "C04", 35) -- Spear Hand Strike
				-----
				spell("1", "Provoke")
				spell("2", "Tiger Palm")
				spell("3", "Keg Smash")
				spell("4", "Blackout Strike")
				spell("5", "Ironskin Brew")
				if talent[3][3] then spell("G", "Black Ox Brew") else empty("G") end
				spell("V", "Purifying Brew")
				if talent[7][2] then spell("SV", "Guard") else empty("SV") end
				spell("CV", "Transcendence")
				-----
				-----
				if talent[4][2] then macro("SR", "C05") else empty("SR") end -- Provoke Statue
				if talent[2][3] then spell("CQ", "Tiger's Lust") else empty("CQ") end
				empty("AB3")
				spell("CF", "Roll")
				spell("SF", "Transcendence: Transfer")
				empty("F")
				-----
				spell("F1", "Expel Harm")
				if talent[5][2] then spell("F2", "Healing Elixir") elseif talent[5][3] then spell("F2", "Dampen Harm") else empty("F2") end
				spell("F3", "Fortifying Brew")
				spell("F4", "Zen Meditation")
				spell("SQ", "Vivify")
				-----
			elseif spec == 2 then
				-- Mistweaver
				-----
				spell("N", "Crackling Jade Lightning")
				spell("Q", "Spinning Crane Kick")
				spell("E", "Renewing Mist")
				if talent[1][2] then spell("R", "Chi Wave") elseif talent[1][3] then spell("R", "Chi Burst") else empty("R") end
				spell("CR", "Detox")
				spell("T", "Paralysis")
				empty("ST")
				empty("CT")
				if talent[4][2] then spell("CB3", "Song of Chi-Ji") elseif talent[4][3] then spell("CB3", "Ring of Peace") else empty("CB3") end
				spell("CE", "Leg Sweep")
				spell("SE", "Life Cocoon")
				-----
				macro("1", "C01") -- Soothing Mist
				macro("2", "C02") -- Enveloping Mist
				macro("3", "C03") -- Vivify
				spell("4", "Essence Font")
				if talent[6][2] then spell("5", "Refreshing Jade Wind") elseif talent[6][3] then spell("5", "Invoke Chi-Ji, the Red Crane") else empty("5") end
				if talent[3][3] then spell("G", "Mana Tea") else empty("G") end
				spell("V", "Thunder Focus Tea")
				if talent[6][1] then spell("SV", "Summon Jade Serpent Statue") else empty("SV") end
				spell("CV", "Transcendence")
				-----
				-----
				spell("SR", "Provoke")
				if talent[2][3] then spell("CQ", "Tiger's Lust") else empty("CQ") end
				empty("AB3")
				spell("CF", "Roll")
				spell("SF", "Transcendence: Transfer")
				empty("F")
				-----
				spell("F1", "Fortifying Brew")
				if talent[5][1] then spell("F2", "Healing Elixir") elseif talent[5][2] then spell("F2", "Diffuse Magic") elseif talent[5][3] then spell("F2", "Dampen Harm") else empty("F2") end
				spell("F3", "Revival")
				empty("F4")
				spell("SQ", "Vivify")
				-----
			elseif spec == 3 then
				-- Windwalker
				-----
				spell("N", "Crackling Jade Lightning")
				spell("Q", "Spinning Crane Kick")
				if talent[7][2] then spell("E", "Whirling Dragon Punch") else empty("E") end
				if talent[1][2] then spell("R", "Chi Wave") elseif talent[1][3] then spell("R", "Chi Burst") else empty("R") end
				spell("CR", "Detox")
				spell("T", "Paralysis")
				spell("ST", "Disable")
				empty("CT")
				if talent[4][3] then spell("CB3", "Ring of Peace") else empty("CB3") end
				spell("CE", "Leg Sweep")
				macro("SE", "C04", 35) -- Spear Hand Strike
				-----
				spell("1", "Tiger Palm")
				spell("2", "Rising Sun Kick")
				spell("3", "Blackout Kick")
				spell("4", "Fists of Fury")
				if talent[3][2] then spell("5", "Fist of the White Tiger") elseif talent[3][3] then spell("5", "Energizing Elixir") else empty("5") end
				spell("G", "Storm, Earth, and Fire")
				if talent[6][2] then spell("V", "Rushing Jade Wind") elseif talent[6][3] then spell("V", "Invoke Xuen, the White Tiger") else empty("V") end
				spell("SV", "Touch of Death")
				spell("CV", "Transcendence")
				-----
				-----
				spell("SR", "Provoke")
				if talent[2][3] then spell("CQ", "Tiger's Lust") else empty("CQ") end
				empty("AB3")
				spell("CF", "Roll")
				spell("SF", "Transcendence: Transfer")
				spell("F", "Flying Serpent Kick")
				-----
				spell("F1", "Touch of Karma")
				if talent[5][2] then spell("F2", "Diffuse Magic") elseif talent[5][3] then spell("F2", "Dampen Harm") else empty("F2") end
				empty("F3")
				empty("F4")
				spell("SQ", "Vivify")
				-----
			end
		elseif class == "PALADIN" then
			-- Paladin Macros
			-----
			-- Flash of Light/Judgment
			m("C01", nil, "#showtooltip\n/use [harm]Judgment;Flash of Light")
			-- Holy Light/Crusader Strike
			m("C02", nil, "#showtooltip\n/use [harm]Crusader Strike;Holy Light")
			-- Bestow Faith/Consecration
			m("C03", nil, "#showtooltip\n/use [talent:1/2,help]Bestow Faith;Consecration")
			-- Rebuke/Judgment
			m("C04", nil, "#showtooltip [spec:1]Judgment;Rebuke\n/stopcasting [nospec:1]\n/stopcasting [nospec:1]\n/use [spec:1,@focus,harm,nodead][spec:1,harm][spec:1,@targettarget,harm][spec:1,@boss1,harm][spec:1]Judgment;Rebuke")
			-----
			if spec == 1 then
				-- Holy
				-----
				macro("N", "C04") -- Judgment
				spell("Q", "Light of Dawn")
				macro("E", "C03") -- Bestow Faith/Consecration
				if talent[2][3] then spell("R", "Rule of Law") else empty("R") end
				spell("CR", "Cleanse")
				if talent[3][2] then spell("T", "Repentance") elseif talent[3][3] then spell("T", "Blinding Light") else empty("T") end
				empty("ST")
				empty("CT")
				empty("CB3")
				spell("CE", "Hammer of Justice")
				empty("SE")
				-----
				macro("1", "C01") -- Flash of Light
				if level >= 25 then macro("2", "C02") else spell("2", "Crusader Strike") end -- Holy Light
				spell("3", "Holy Shock")
				spell("4", "Light of the Martyr")
				if talent[1][3] then spell("5", "Light's Hammer") else empty("5") end
				spell("G", "Avenging Wrath")
				if talent[5][2] then spell("V", "Holy Prism") elseif talent[5][3] then spell("V", "Holy Avenger") else empty("V") end
				spell("SV", "Lay on Hands")
				empty("CV")
				-----
				-----
				spell("SR", "Hand of Reckoning")
				spell("CQ", "Blessing of Protection")
				empty("AB3")
				spell("CF", "Blessing of Sacrifice")
				spell("SF", "Blessing of Freedom")
				spell("F", "Divine Steed")
				-----
				spell("F1", "Divine Protection")
				spell("F2", "Divine Shield")
				spell("F3", "Aura Mastery")
				empty("F4")
				spell("SQ", "Flash of Light")
				-----
			elseif spec == 2 then
				-- Protection
				-----
				empty("N")
				spell("Q", "Avenger's Shield")
				spell("E", "Consecration")
				if talent[2][3] then spell("R", "Bastion of Light") else empty("R") end
				spell("CR", "Cleanse Toxins")
				if talent[3][2] then spell("T", "Repentance") elseif talent[3][3] then spell("T", "Blinding Light") else empty("T") end
				empty("ST")
				empty("CT")
				empty("CB3")
				spell("CE", "Hammer of Justice")
				macro("SE", "C04", 35) -- Rebuke
				-----
				spell("1", "Hand of Reckoning")
				spell("2", "Hammer of the Righteous")
				spell("3", "Judgment")
				spell("4", "Shield of the Righteous")
				spell("5", "Light of the Protector")
				spell("G", "Avenging Wrath")
				if talent[7][3] then spell("V", "Seraphim") else empty("V") end
				spell("SV", "Lay on Hands")
				empty("CV")
				-----
				-----
				empty("SR")
				spell("CQ", "Blessing of Protection")
				empty("AB3")
				spell("CF", "Blessing of Sacrifice")
				spell("SF", "Blessing of Freedom")
				spell("F", "Divine Steed")
				-----
				spell("F1", "Ardent Defender")
				spell("F2", "Divine Shield")
				spell("F3", "Guardian of Ancient Kings")
				if talent[6][3] then spell("F4", "Aegis of Light") else empty("F4") end
				spell("SQ", "Flash of Light")
				-----
			elseif spec == 3 then
				-- Retribution
				-----
				if talent[2][3] then spell("N", "Hammer of Wrath") else empty("N") end
				spell("Q", "Divine Storm")
				if talent[4][2] then spell("E", "Consecration") elseif talent[4][3] then spell("E", "Wake of Ashes") else empty("E") end
				if talent[7][3] then spell("R", "Inquisition") else empty("R") end
				spell("CR", "Cleanse Toxins")
				if talent[3][2] then spell("T", "Repentance") elseif talent[3][3] then spell("T", "Blinding Light") else empty("T") end
				spell("ST", "Hand of Hindrance")
				empty("CT")
				empty("CB3")
				spell("CE", "Hammer of Justice")
				macro("SE", "C04", 35) -- Rebuke
				-----
				spell("1", "Crusader Strike")
				spell("2", "Blade of Justice")
				spell("3", "Judgment")
				spell("4", "Templar's Verdict")
				if talent[1][3] then spell("5", "Execution Sentence") else empty("5") end
				if talent[6][2] then spell("V", "Justicar's Vengeance") elseif talent[6][3] then spell("V", "Word of Glory") else empty("V") end
				spell("G", "Avenging Wrath")
				spell("SV", "Lay on Hands")
				empty("CV")
				-----
				-----
				spell("SR", "Hand of Reckoning")
				spell("CQ", "Blessing of Protection")
				empty("AB3")
				empty("CF")
				spell("SF", "Blessing of Freedom")
				spell("F", "Divine Steed")
				-----
				spell("F1", "Shield of Vengeance")
				spell("F2", "Divine Shield")
				if talent[5][3] then spell("F3", "Eye for an Eye") else empty("F3") end
				empty("F4")
				spell("SQ", "Flash of Light")
				-----
			end
		elseif class == "PRIEST" then
			-- Priest Macros
			-----
			-- Flash Heal/Smite/Shadow Mend
			m("C01", nil, "#showtooltip\n/use [spec:2,harm]Smite;[spec:2]Flash Heal;[help]Flash Heal;Smite")
			-- Shadow Word: Pain/Renew/Holy Fire
			m("C02", nil, "#showtooltip\n/use [spec:1,help][spec:3,help]Power Word: Shield;[spec:2,harm]Holy Fire;[spec:2]Renew;Shadow Word: Pain")
			-- Power Word: Radiance/Schism
			--m("C03", nil, "#showtooltip\n/use [talent:1/3,harm]Schism;Power Word: Radiance")
			-- Silence
			m("C04", nil, "#showtooltip Silence\n/stopcasting\n/stopcasting\n/use Silence")
			-- Dispel Magic/Purify/Purify Disease
			m("C05", nil, "#showtooltip\n/use [harm]DIspel Magic;[spec:3]Purify Disease;Purify")
			-- Angelic Feather/Body and Soul
			m("C06", 537020, "#showtooltip [spec:1,talent:2/3][spec:2]Angelic Feather;Power Word: Shield\n/use [spec:1,talent:2/3,@player][spec:2,@player]Angelic Feather;[@player]Power Word: Shield")
			-- Shadowform
			m("C07", nil, "#showtooltip Shadowform\n/use [nostance]Shadowform")
			-- Power Word: Shield @player
			m("C08", nil, "#showtooltip Power Word: Shield\n/use [@player]Power Word: Shield")
			-- Binding Heal/Heal
			m("C09", nil, "#showtooltip\n/use [mod:shift]Heal;Binding Heal")
			-----
			if spec == 1 then
				-- Discipline
				if talent[1][3] then spell("N", "Schism") else empty("N") end
				spell("Q", "Holy Nova")
				macro("E", "C02", 3) -- Power Word: Shield/Shadow Word: Pain
				if talent[6][2] then spell("R", "Divine Star") elseif talent[6][3] then spell("R", "Halo") else empty("R") end
				if level >= 56 then macro("CR", "C05") else spell("CR", "Purify") end -- Purify/Dispel Magic
				spell("T", "Shackle Undead")
				spell("ST", "Psychic Scream")
				spell("CT", "Mind Control")
				if talent[4][3] then spell("CB3", "Shining Force") else empty("CB3") end
				empty("CE")
				spell("SE", "Pain Suppression")
				-----
				macro("1", "C01") -- Smite/Shadow Mend
				spell("2", "Penance")
				spell("3", "Power Word: Radiance")
				if talent[3][3] then spell("4", "Power Word: Solace") else empty("4") end
				if talent[5][3] then spell("5", "Shadow Covenant") else empty("5") end
				spell("G", "Rapture")
				spell("V", "Shadowfiend")
				empty("SV")
				empty("CV")
				-----
				-----
				empty("SR")
				spell("CQ", "Levitate")
				spell("AB3", "Mass Dispel")
				spell("CF", "Leap of Faith")
				if talent[2][3] then spell("SF", "Angelic Feather") else empty("SF") end
				if talent[2][1] or talent[2][3] then macro("F", "C06") else macro("F", "C08", 8) end -- Angelic Feather/Body and Soul
				-----
				spell("F1", "Fade")
				spell("F2", "Desperate Prayer")
				spell("F3", "Power Word: Barrier")
				if talent[7][3] then spell("F4", "Evangelism") else empty("F4") end
				spell("SQ", "Flash Heal")
				-----
			elseif spec == 2 then
				-- Holy
				spell("N", "Holy Word: Serenity")
				spell("Q", "Holy Nova")
				macro("E", "C02", 12) -- Renew/Holy Fire
				if talent[6][2] then spell("R", "Divine Star") elseif talent[6][3] then spell("R", "Halo") else empty("R") end
				if level >= 56 then macro("CR", "C05") else spell("CR", "Purify") end -- Purify/Dispel Magic
				spell("T", "Shackle Undead")
				spell("ST", "Psychic Scream")
				spell("CT", "Mind Control")
				if talent[4][3] then spell("CB3", "Shining Force") else empty("CB3") end
				spell("CE", "Holy Word: Chastise")
				spell("SE", "Guardian Spirit")
				-----
				macro("1", "C01") -- Flash Heal/Smite
				if talent[5][2] then macro("2", "C09") else spell("2", "Heal") end
				spell("3", "Prayer of Healing")
				spell("4", "Prayer of Mending")
				spell("5", "Holy Word: Sanctify")
				if talent[7][2] then spell("G", "Apotheosis") elseif talent[7][3] then spell("G", "Holy Word: Salvation") else empty("G") end
				if talent[5][3] then spell("V", "Circle of Healing") else empty("V") end
				empty("SV")
				empty("CV")
				-----
				-----
				empty("SR")
				spell("CQ", "Levitate")
				spell("AB3", "Mass Dispel")
				spell("CF", "Leap of Faith")
				if talent[2][3] then spell("SF", "Angelic Feather") else empty("SF") end
				if talent[2][3] then macro("F", "C06") else empty("F") end -- Angelic Feather
				-----
				spell("F1", "Fade")
				spell("F2", "Desperate Prayer")
				spell("F3", "Divine Hymn")
				spell("F4", "Symbol of Hope")
				spell("SQ", "Flash Heal")
				-----
			elseif spec == 3 then
				-- Shadow
				-----
				if talent[5][2] then spell("N", "Shadow Word: Death") elseif talent[5][3] then spell("N", "Shadow Crash") else empty("N") end
				spell("Q", "Mind Sear")
				macro("E", "C02", 3) -- Shadow Word: Pain
				if talent[3][3] then spell("R", "Dark Void") else empty("R") end
				if level >= 56 then macro("CR", "C05") else spell("CR", "Purify Disease") end -- Purify Disease/Dispel Magic
				spell("T", "Shackle Undead")
				spell("ST", "Psychic Scream")
				spell("CT", "Mind Control")
				empty("CB3")
				if talent[4][3] then spell("CE", "Psychic Horror") else empty("CE") end
				macro("SE", "C04", 52) -- Silence
				-----
				if level >= 24 then spell("1", "Vampiric Touch") else spell("1", "Mind Flay") end
				spell("2", "Mind Flay", 24)
				spell("3", "Mind Blast")
				spell("4", "Void Eruption")
				if talent[6][3] then spell("5", "Void Torrent") else empty("5") end
				if talent[7][2] then spell("G", "Dark Ascension") elseif talent[7][3] then spell("G", "Surrender to Madness") else empty("G") end
				spell("V", "Shadowfiend")
				macro("SV", "C07", 12) -- Shadowform
				empty("CV")
				-----
				-----
				empty("SR")
				spell("CQ", "Levitate")
				spell("AB3", "Mass Dispel")
				spell("CF", "Leap of Faith")
				empty("SF")
				if talent[2][1] then macro("F", "C06") else macro("F", "C08") end -- Body and Soul
				-----
				spell("F1", "Fade")
				spell("F2", "Dispersion")
				spell("F3", "Vampiric Embrace")
				empty("F4")
				spell("SQ", "Flash Heal")
				-----
			end
		elseif class == "ROGUE" then
			-- Rogue Macros
			-----
			-- Sinister Strike/Backstab/Ambush/Shadowstrike
			m("C01", nil, "#showtooltip\n/use [spec:2,stance:1][spec:2,stance:2]Ambush;[spec:3,stance:1][spec:3,stance:2]Shadowstrike;[spec:3]Backstab;Sinister Strike")
			-- Kidney Shot/Between the Eyes/Cheap Shot
			m("C02", nil, "#showtooltip\n/use [stance:1][stance:2]Cheap Shot;[spec:2]Between the Eyes;Kidney Shot")
			-- Tricks of the Trade
			m("C03", nil, "#showtooltip Tricks of the Trade\n/use [@focus,help][help][]Tricks of the Trade")
			-- Kick
			m("C04", nil, "#showtooltip Kick\n/stopcasting\n/stopcasting\n/use Kick")
			-- Pistol Shot
			m("C05", 134536, "#showtooltip\n/use Pistol Shot")
			-----
			if spec == 1 then
				-- Assassination
				-----
				spell("N", "Poisoned Knife")
				spell("Q", "Fan of Knives")
				spell("E", "Garrote")
				if talent[7][3] then spell("R", "Crimson Tempest") else empty("R") end
				empty("CR")
				spell("T", "Sap")
				spell("ST", "Blind")
				empty("CT")
				empty("CR")
				empty("CB3")
				if level >= 34 then macro("CE", "C02") else spell("CE", "Cheap Shot") end -- Kidney Shot/Cheap Shot
				macro("SE", "C04", 18) -- Kick
				-----
				if level >= 40 then spell("1", "Mutilate") else spell("1", "Sinister Strike") end
				spell("2", "Rupture")
				if level >= 36 then spell("3", "Envenom") else spell("3", "Eviscerate") end
				if talent[6][2] then spell("4", "Toxic Blade") elseif talent[6][3] then spell("4", "Exsanguinate") else empty("4") end
				if talent[1][3] then spell("5", "Blindside") else empty("5") end
				spell("G", "Vendetta")
				if talent[3][3] then spell("V", "Marked for Death") else empty("V") end
				spell("SV", "Stealth")
				spell("CV", "Vanish")
				-----
				-----
				empty("SR")
				macro("CQ", "C03", 70) -- Tricks of the Trade
				spell("AB3", "Distract")
				empty("CF")
				spell("SF", "Shadowstep")
				spell("F", "Sprint")
				-----
				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				spell("F4", "Shroud of Concealment")
				spell("SQ", "Crimson Vial")
				-----
			elseif spec == 2 then
				-- Outlaw
				-----
				empty("N")
				spell("Q", "Blade Flurry")
				empty("E")
				spell("R", "Roll the Bones")
				empty("CR")
				spell("T", "Sap")
				spell("ST", "Blind")
				empty("CT")
				empty("CR")
				empty("CB3")
				if level >= 20 then macro("CE", "C02") else spell("CE", "Cheap Shot") end -- Between the Eyes/Cheap Shot
				macro("SE", "C04", 18) -- Kick
				-----
				if level >= 22 then macro("1", "C01") else spell("1", "Sinister Strike") end -- Sinister Strike/Ambush
				macro("2", "C05", 10) -- Pistol Shot
				spell("3", "Dispatch")
				if talent[1][3] then spell("4", "Ghostly Strike") else empty("4") end
				if talent[7][2] then spell("5", "Blade Rush") elseif talent[7][3] then spell("5", "Killing Spree") else empty("5") end
				spell("G", "Adrenaline Rush")
				if talent[3][3] then spell("V", "Marked for Death") else empty("V") end
				spell("SV", "Stealth")
				spell("CV", "Vanish")
				-----
				-----
				empty("SR")
				macro("CQ", "C03", 70) -- Tricks of the Trade
				spell("AB3", "Distract")
				spell("CF", "Grappling Hook")
				empty("SF")
				spell("F", "Sprint")
				-----
				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Riposte")
				spell("F4", "Shroud of Concealment")
				spell("SQ", "Crimson Vial")
				-----
			elseif spec == 3 then
				-- Subtlety
				-----
				spell("N", "Shuriken Toss")
				spell("Q", "Shuriken Storm")
				empty("E")
				spell("R", "Shadow Dance")
				empty("CR")
				spell("T", "Sap")
				spell("ST", "Blind")
				empty("CT")
				empty("CR")
				empty("CB3")
				if level >= 34 then macro("CE", "C02") else spell("CE", "Cheap Shot") end -- Kidney Shot/Cheap Shot
				macro("SE", "C04", 18) -- Kick
				-----
				if level >= 12 then macro("1", "C01") else spell("1", "Backstab") end -- Backstab/Shadowstrike
				spell("2", "Nightblade")
				spell("3", "Eviscerate")
				spell("4", "Symbols of Death")
				if talent[7][2] then spell("5", "Secret Technique") elseif talent[7][3] then spell("5", "Shuriken Tornado") else empty("5") end
				spell("G", "Shadow Blades")
				if talent[3][3] then spell("V", "Marked for Death") else empty("V") end
				spell("SV", "Stealth")
				spell("CV", "Vanish")
				-----
				-----
				empty("SR")
				macro("CQ", "C03", 70) -- Tricks of the Trade
				spell("AB3", "Distract")
				empty("CF")
				spell("SF", "Shadowstep")
				spell("F", "Sprint")
				-----
				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				spell("F4", "Shroud of Concealment")
				spell("SQ", "Crimson Vial")
				-----
			end
		elseif class == "SHAMAN" then
			-- Shaman Macros
			-----
			-- Healing Surge/Lightning Bolt
			m("C01", nil, "#showtooltip\n/use [harm]Lightning Bolt;Healing Surge")
			-- Healing Wave/Lava Burst
			m("C02", nil, "#showtooltip\n/use [harm]Lava Burst;Healing Wave")
			-- Chain Heal/Chain Lightning
			m("C03", nil, "#showtooltip\n/use [harm]Chain Lightning;Chain Heal")
			-- Wind Shear
			m("C04", nil, "#showtooltip Wind Shear\n/stopcasting\n/stopcasting\n/use Wind Shear")
			-- Cleanse Spirit/Purify Spirit/Purge
			m("C05", nil, "#showtooltip\n/use [harm]Purge;[spec:3]Purify Spirit;Cleanse Spirit")
			-- Riptide/Flame Shock
			m("C06", nil, "#showtooltip\n/use [harm] Flame Shock;Riptide")
			-- Fire Elemental
			m("C07", nil, "#showtooltip\n/use [pet:Earth Elemental]Harden Skin;[pet:Storm Elemental]Eye of the Storm;[pet:Fire Elemental]Meteor;Fire Elemental")
			-- Earth Elemental
			m("C08", nil, "#showtooltip Earth Elemental\n/use [nopet]Earth Elemental")
			-- Reincarnation
			m("C09", nil, "#showtooltip\n/use Reincarnation")
			-----
			if spec == 1 then
				-- Elemental
				-----
				if talent[6][3] and talent[1][3] then spell("N", "Elemental Blast") elseif talent[4][3] then spell("N", "Liquid Magma Totem") else empty("N") end
				spell("Q", "Earthquake")
				spell("E", "Flame Shock")
				if talent[6][3] then spell("R", "Icefury") elseif talent[1][3] then spell("R", "Elemental Blast") else empty("R") end
				if level >= 63 then macro("CR", "C05") else spell("CR", "Cleanse Spirit") end -- Cleanse Spirit/Purge
				if level >= 42 then custom("T", "Hex") else empty("T") end
				spell("ST", "Earthbind Totem")
				if talent[1][3] and talent[4][3] then spell("CT", "Liquid Magma Totem") else empty("CT") end
				spell("CB3", "Thunderstorm")
				spell("CE", "Capacitor Totem")
				macro("SE", "C04", 18) -- Wind Shear
				-----
				spell("1", "Lightning Bolt")
				spell("2", "Lava Burst")
				spell("3", "Chain Lightning")
				spell("4", "Earth Shock")
				spell("5", "Frost Shock")
				macro("G", "C07", 56) -- Fire Elemental
				if talent[7][2] then spell("V", "Stormkeeper") elseif talent[7][3] then spell("V", "Ascendance") else empty("V") end
				if faction == "Alliance" then spell("SV", "Heroism") else spell("SV", "Bloodlust") end
				if talent[2][3] then spell("CV", "Totem Mastery") else empty("CV") end
				-----
				-----
				empty("SR")
				spell("CQ", "Water Walking")
				spell("AB3", "Tremor Totem")
				if talent[5][3] then spell("CF", "Wind Rush Totem") else empty("CF") end
				empty("SF")
				spell("F", "Ghost Wolf")
				-----
				spell("F1", "Astral Shift")
				macro("F2", "C08", 36) -- Earth Elemental
				if talent[5][2] then spell("F3", "Ancestral Guidance") else empty("F3") end
				empty("F4")
				spell("SQ", "Healing Surge")
				-----
			elseif spec == 2 then
				-- Enhancement
				-----
				spell("N", "Lightning Bolt")
				if talent[6][2] then spell("Q", "Fury of Air") elseif talent[6][3] then spell("Q", "Sundering") else empty("Q") end
				spell("E", "Flametongue")
				spell("R", "Frostbrand")
				if level >= 63 then macro("CR", "C05") else spell("CR", "Cleanse Spirit") end -- Cleanse Spirit/Purge
				if level >= 42 then custom("T", "Hex") else empty("T") end
				spell("ST", "Earthbind Totem")
				empty("CT")
				empty("CB3")
				spell("CE", "Capacitor Totem")
				macro("SE", "C04", 18) -- Wind Shear
				-----
				spell("1", "Rockbiter")
				spell("2", "Lava Lash")
				spell("3", "Stormstrike")
				spell("4", "Crash Lightning")
				if talent[7][2] then spell("5", "Earthen Spike") else empty("5") end
				spell("G", "Feral Spirit")
				if talent[7][3] then spell("V", "Ascendance") else empty("V") end
				spell("SV", "Bloodlust")
				if talent[2][3] then spell("CV", "Totem Mastery") else empty("CV") end
				-----
				-----
				empty("SR")
				spell("CQ", "Water Walking")
				spell("AB3", "Tremor Totem")
				if talent[5][2] then spell("CF", "Feral Lunge") elseif talent[5][3] then spell("CF", "Wind Rush Totem") else empty("CF") end
				spell("SF", "Spirit Walk")
				spell("F", "Ghost Wolf")
				-----
				spell("F1", "Astral Shift")
				spell("F2", "Earth Elemental")
				empty("F3")
				empty("F4")
				spell("SQ", "Healing Surge")
				-----
			elseif spec == 3 then
				-- Restoration
				-----
				if talent[4][2] then spell("N", "Earthen Wall Totem") elseif talent[4][3] then spell("N", "Ancestral Protection Totem") else empty("N") end
				spell("Q", "Healing Rain")
				macro("E", "C06") -- Riptide/Flame Shock
				if talent[1][3] then spell("R", "Unleash Life") else empty("R") end
				if level >= 63 then macro("CR", "C05") else spell("CR", "Purify Spirit") end -- Purify Spirit/Purge
				if level >= 42 then custom("T", "Hex") else empty("T") end
				spell("ST", "Earthbind Totem")
				empty("CT")
				if talent[3][2] then spell("CB3", "Earthgrab Totem") else empty("CB3") end
				spell("CE", "Capacitor Totem")
				macro("SE", "C04", 18) -- Wind Shear
				-----
				macro("1", "C01") -- Healing Surge/Lightning Bolt
				macro("2", "C02") -- Healing Wave/Lava Burst
				macro("3", "C03") -- Chain Heal/Chain Lightning
				if talent[6][2] then spell("4", "Downpour") else empty("4") end
				spell("5", "Healing Stream Totem")
				empty("G")
				if talent[7][2] then spell("V", "Wellspring") elseif talent[7][3] then spell("V", "Ascendance") else empty("V") end
				spell("SV", "Bloodlust")
				if talent[2][3] then spell("CV", "Earth Shield") else empty("CV") end
				-----
				-----
				empty("SR")
				spell("CQ", "Water Walking")
				spell("AB3", "Tremor Totem")
				if talent[5][3] then spell("CF", "Wind Rush Totem") else empty("CF") end
				spell("SF", "Spiritwalker's Grace")
				spell("F", "Ghost Wolf")
				-----
				spell("F1", "Astral Shift")
				spell("F2", "Earth Elemental")
				spell("F3", "Healing Tide Totem")
				spell("F4", "Spirit Link Totem")
				spell("SQ", "Healing Surge")
				-----
			end
		elseif class == "WARLOCK" then
			-- Warlock Macros
			-----
			-- Pet Primary
			m("C01", nil, "#showtooltip\n/use [pet:Felguard]Axe Toss;[pet:Felhunter][pet:Observer]Spell Lock;[pet:Imp][pet:Fel Imp]Flee;[pet:Succubus][pet:Shivarra]Seduction;[pet:Voidwalker][pet:Voidlord]Suffering;Command Demon")
			-- Pet Secondary
			m("C02", nil, "#showtooltip\n/use [pet:Felguard]Felstorm;[pet:Felhunter][pet:Observer]Devour Magic;[pet:Succubus][pet:Shivarra]Lesser Invisibility;[pet:Voidwalker][pet:Voidlord]Shadow Bulwark;[spec:1,talent:6/3][spec:3,talent:6/3]Grimoire of Sacrifice;Command Demon")
			-----
			if spec == 1 then
				-- Affliction
				-----
				if talent[1][3] then spell("N", "Deathbolt") else empty("N") end
				spell("Q", "Seed of Corruption")
				spell("E", "Agony")
				if talent[2][3] then spell("R", "Siphon Life") else empty("R") end
				macro("CR", "C02", 10) -- Pet Secondary
				spell("T", "Fear")
				spell("ST", "Banish")
				spell("CT", "Enslave Demon")
				if talent[5][2] then spell("CB3", "Mortal Coil") else empty("CB3") end
				spell("CE", "Shadowfury")
				macro("SE", "C01", 10) -- Pet Primary
				-----
				spell("1", "Shadow Bolt")
				spell("2", "Unstable Affliction")
				if talent[6][2] then spell("3", "Haunt") elseif talent[4][2] then spell("3", "Phantom Singularity") elseif talent[4][3] then spell("3", "Vile Taint") else empty("3") end
				spell("4", "Corruption")
				if talent[6][2] and talent[4][2] then spell("5", "Phantom Singularity") elseif talent[6][2] and talent[4][3] then spell("5", "Vile Taint") else empty("5") end
				spell("G", "Summon Darkglare")
				if talent[7][3] then spell("V", "Dark Soul: Misery") else empty("V") end
				empty("SV")
				if talent[5][3] then spell("CV", "Demonic Circle") else empty("CV") end
				-----
				-----
				empty("SR")
				spell("CQ", "Unending Breath")
				empty("AB3")
				spell("CF", "Demonic Gateway")
				if talent[5][3] then spell("SF", "Demonic Circle: Teleport") else empty("SF") end
				if talent[3][2] then spell("F", "Burning Rush") else empty("F") end
				-----
				spell("F1", "Unending Resolve")
				if talent[3][3] then spell("F2", "Dark Pact") else empty("F2") end
				empty("F3")
				spell("F4", "Health Funnel")
				spell("SQ", "Drain Life")
				-----
			elseif spec == 2 then
				-- Demonology
				-----
				if talent[4][2] then spell("N", "Soul Strike") elseif talent[4][3] then spell("N", "Summon Vilefiend") else empty("N") end
				spell("Q", "Implosion")
				if talent[2][2] then spell("E", "Power Siphon") elseif talent[2][3] then spell("E", "Doom") else empty("E") end
				if talent[1][2] then spell("R", "Demonic Strength") elseif talent[1][3] then spell("R", "Bilescourge Bombers") else empty("R") end
				macro("CR", "C02") -- Pet Secondary
				spell("T", "Fear")
				spell("ST", "Banish")
				spell("CT", "Enslave Demon")
				if talent[5][2] then spell("CB3", "Mortal Coil") else empty("CB3") end
				spell("CE", "Shadowfury")
				macro("SE", "C01") -- Pet Primary
				-----
				spell("1", "Shadow Bolt")
				spell("2", "Demonbolt")
				spell("3", "Call Dreadstalkers")
				spell("4", "Hand of Gul'dan")
				if talent[7][3] then spell("5", "Nether Portal") else empty("5") end
				spell("G", "Summon Demonic Tyrant")
				if talent[6][3] then spell("V", "Grimoire: Felguard") else empty("V") end
				empty("SV")
				if talent[5][3] then spell("CV", "Demonic Circle") else empty("CV") end
				-----
				-----
				empty("SR")
				spell("CQ", "Unending Breath")
				empty("AB3")
				spell("CF", "Demonic Gateway")
				if talent[5][3] then spell("SF", "Demonic Circle: Teleport") else empty("SF") end
				if talent[3][2] then spell("F", "Burning Rush") else empty("F") end
				-----
				spell("F1", "Unending Resolve")
				if talent[3][3] then spell("F2", "Dark Pact") else empty("F2") end
				empty("F3")
				spell("F4", "Health Funnel")
				spell("SQ", "Drain Life")
				-----
			elseif spec == 3 then
				-- Destruction
				-----
				if talent[2][3] then spell("N", "Shadowburn") else empty("N") end
				spell("Q", "Rain of Fire")
				spell("E", "Havoc")
				if talent[1][3] then spell("R", "Soul Fire") else empty("R") end
				macro("CR", "C02") -- Pet Secondary
				spell("T", "Fear")
				spell("ST", "Banish")
				spell("CT", "Enslave Demon")
				if talent[5][2] then spell("CB3", "Mortal Coil") else empty("CB3") end
				spell("CE", "Shadowfury")
				macro("SE", "C01") -- Pet Primary
				-----
				spell("1", "Immolate")
				if level >= 14 then spell("2", "Incinerate") else spell("2", "Shadow Bolt") end
				spell("3", "Chaos Bolt")
				spell("4", "Conflagrate")
				if talent[4][3] then spell("5", "Cataclysm") else empty("5") end
				spell("G", "Summon Infernal")
				if talent[7][3] then spell("V", "Dark Soul: Instability") else empty("V") end
				empty("SV")
				if talent[5][3] then spell("CV", "Demonic Circle") else empty("CV") end
				-----
				-----
				empty("SR")
				spell("CQ", "Unending Breath")
				if talent[7][2] then spell("AB3", "Channel Demonfire") else empty("AB3") end
				spell("CF", "Demonic Gateway")
				if talent[5][3] then spell("SF", "Demonic Circle: Teleport") else empty("SF") end
				if talent[3][2] then spell("F", "Burning Rush") else empty("F") end
				-----
				spell("F1", "Unending Resolve")
				if talent[3][3] then spell("F2", "Dark Pact") else empty("F2") end
				empty("F3")
				spell("F4", "Health Funnel")
				spell("SQ", "Drain Life")
				-----
			end
		elseif class == "WARRIOR" then
			-- Warrior Macros
			-----
			-- Pummel
			m("C01", nil, "#showtooltip Pummel\n/stopcasting\n/stopcasting\n/cast Pummel")
			-----
			if spec == 1 then
				-- Arms
				-----
				spell("N", "Heroic Throw")
				spell("Q", "Whirlwind")
				if talent[3][3] then spell("E", "Rend") else empty("E") end
				spell("R", "Sweeping Strikes")
				if talent[5][3] then spell("CR", "Cleave") else empty("CR") end
				spell("T", "Intimidating Shout")
				spell("ST", "Hamstring")
				empty("CT")
				empty("CB3")
				if talent[2][3] then spell("CE", "Storm Bolt") else empty("CE") end
				macro("SE", "C01", 24) -- Pummel
				-----
				if level >= 10 then spell("1", "Mortal Strike") else spell("1", "Slam") end
				if talent[3][2] then spell("2", "Whirlwind") elseif level >= 10 then spell("2", "Slam") else spell("2", "Victory Rush") end
				spell("3", "Execute")
				spell("4", "Overpower")
				spell("5", "Bladestorm")
				if talent[6][2] then spell("G", "Avatar") elseif talent[6][3] then spell("G", "Deadly Calm") else empty("G") end
				spell("V", "Colossus Smash")
				if talent[1][3] then spell("SV", "Skullsplitter") else empty("SV") end
				empty("CV")
				-----
				-----
				spell("SR", "Taunt")
				empty("CQ")
				empty("AB3")
				spell("CF", "Heroic Leap")
				spell("SF", "Berserker Rage")
				spell("F", "Charge")
				-----
				spell("F1", "Die by the Sword")
				if talent[4][3] then spell("F2", "Defensive Stance") else empty("F2") end
				spell("F3", "Rallying Cry")
				empty("F4")
				spell("SQ", "Victory Rush")
				-----
			elseif spec == 2 then
				-- Fury
				-----
				spell("N", "Heroic Throw")
				spell("Q", "Whirlwind")
				if talent[3][3] then spell("E", "Furious Slash") else empty("E") end
				empty("R")
				empty("CR")
				spell("T", "Intimidating Shout")
				spell("ST", "Piercing Howl")
				empty("CT")
				empty("CB3")
				if talent[2][3] then spell("CE", "Storm Bolt") else empty("CE") end
				macro("SE", "C01", 24) -- Pummel
				-----
				spell("1", "Bloodthirst")
				spell("2", "Raging Blow")
				spell("3", "Execute")
				spell("4", "Rampage")
				if talent[6][2] then spell("5", "Dragon Roar") elseif talent[6][3] then spell("5", "Bladestorm") else empty("5") end
				spell("G", "Recklessness")
				if talent[7][3] then spell("V", "Siegebreaker") else empty("V") end
				empty("SV")
				empty("CV")
				-----
				-----
				spell("SR", "Taunt")
				empty("CQ")
				empty("AB3")
				spell("CF", "Heroic Leap")
				spell("SF", "Berserker Rage")
				spell("F", "Charge")
				-----
				spell("F1", "Enraged Regeneration")
				spell("F2", "Rallying Cry")
				empty("F3")
				empty("F4")
				spell("SQ", "Victory Rush")
				-----
			elseif spec == 3 then
				-- Protection
				-----
				spell("N", "Heroic Throw")
				spell("Q", "Thunder Clap")
				if talent[6][3] then empty("E") else spell("E", "Devastate") end
				if talent[3][3] then spell("R", "Dragon Roar") else empty("R") end
				empty("CR")
				spell("T", "Intimidating Shout")
				empty("ST")
				empty("CT")
				spell("CB3", "Shockwave")
				if talent[5][3] then spell("CE", "Storm Bolt") else empty("CE") end
				macro("SE", "C01", 24) -- Pummel
				-----
				spell("1", "Taunt")
				spell("2", "Shield Slam")
				
				spell("3", "Revenge")
				spell("4", "Shield Block")
				spell("5", "Ignore Pain")
				spell("G", "Avatar")
				if talent[7][3] then spell("V", "Ravager") else empty("V") end
				spell("SV", "Spell Reflection")
				empty("CV")
				-----
				-----
				empty("SR")
				empty("CQ")
				empty("AB3")
				spell("CF", "Heroic Leap")
				spell("SF", "Berserker Rage")
				if level >= 28 then spell("F", "Intercept") else spell("F", "Charge") end
				-----
				spell("F1", "Demoralizing Shout")
				spell("F2", "Last Stand")
				spell("F3", "Shield Wall")
				spell("F4", "Rallying Cry")
				spell("SQ", "Victory Rush")
				-----
			end
		end


		-- All Classes
		macro("SG", "Potion")
		macro("6", "Trinket 1")
		macro("7", "Trinket 2")

		if not timewalking and faction == "Alliance" and not IsQuestFlaggedCompleted(47956) then
			m("Temp", nil, "#showtooltip\n/placer\n/use To Modernize the Provisioning of Azeroth")
			macro("C", "Temp")
		elseif not timewalking and faction == "Alliance" and not IsQuestFlaggedCompleted(47954) then
			m("Temp", nil, "#showtooltip\n/placer\n/use Surviving Kalimdor")
			macro("C", "Temp")
		elseif not timewalking and faction == "Horde" and not IsQuestFlaggedCompleted(47954) then
			m("Temp", nil, "#showtooltip\n/placer\n/use Walking Kalimdor with the Earthmother")
			macro("C", "Temp")
		elseif not timewalking and faction == "Horde" and not IsQuestFlaggedCompleted(47956) then
			m("Temp", nil, "#showtooltip\n/placer\n/use The Azeroth Campaign")
			macro("C", "Temp")
		elseif not timewalking and level >= 120 and faction == "Alliance" and not IsQuestFlaggedCompleted(54705) then
			m("Temp", 237387, "#showtooltip\n/placer\n/use 7th Legion Scouting Map")
			macro("C", "Temp")
		elseif not timewalking and level >= 120 and faction == "Horde" and not IsQuestFlaggedCompleted(54704) then
			m("Temp", 237387, "#showtooltip\n/placer\n/use Honorbound Scouting Map")
			macro("C", "Temp")
		elseif level >= 120 then
			m("Temp", nil, "")
			spell("C", "Heart Essence")
		else
			m("Temp", nil, "")
			empty("C")
		end
		
		racial("AE")
		macro("SX", "Tonic")
		macro("X", "Healthstone")

		
		-- PvP Talents
		local pvp1, pvp2, pvp3, pvp4 = false, false, false, false

		if level >= 20 then
			local i = 0
			for k, v in pairs(C_SpecializationInfo.GetAllSelectedPvpTalentIDs()) do
				i = i + 1
				if i == 1 then
					spell("CC", "Honorable Medallion")
					pvp1 = true
				elseif i == 2 then
					pvptalent("CH", v)
					pvp2 = true
				elseif i == 3 then
					pvptalent("H", v)
					pvp3 = true
				elseif i == 4 then
					pvptalent("SH", v)
					pvp4 = true
				end
			end
		end

		if not pvp1 then empty("CC") end
		if not pvp2 then empty("CH") end
		if not pvp3 then empty("H") end
		if not pvp4 then empty("SH") end
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
			C_Timer.After(1, updateBars)
		end
	end
end
frame:SetScript("OnEvent", eventHandler)

function SlashCmdList.PLACER(msg, editbox)
	updateBars()
	updateEquipmentSets()
end