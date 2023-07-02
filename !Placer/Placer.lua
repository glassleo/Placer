local Placer = CreateFrame("FRAME", "Placer")

Placer:RegisterEvent("PLAYER_LOGIN")
Placer:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Placer:RegisterEvent("PLAYER_LEVEL_UP")
Placer:RegisterEvent("TRAIT_CONFIG_UPDATED")
Placer:RegisterEvent("LEARNED_SPELL_IN_TAB")

local loaded = false
local locked = false

local slotNames = {
	------ Left ------
	-- Top
	["N"] = 13,
	["SN"] = 14,
	["R"] = 15,
	["SR"] = 16,
	["CR"] = 17,
	["H"] = 18,
	["SH"] = 19,
	["AE"] = 20,

	-- Middle
	["C"] = 61,
	["SC"] = 62,
	["Q"] = 63,
	["E"] = 64,
	["G"] = 65,
	["SG"] = 66,
	["CG"] = 67,
	["SE"] = 68,

	-- Bottom
	["1"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["V"] = 7,
	["CE"] = 8,

	------ Right ------
	-- Top
	["J"] = 25,
	["SJ"] = 26,
	["CJ"] = 27,
	["AB3"] = 28,
	["AF"] = 29,
	["CF"] = 30,
	["SF"] = 31,
	["F"] = 32,

	-- Middle
	["T"] = 37,
	["ST"] = 38,
	["CT"] = 39,
	["AT"] = 40,
	["CB3"] = 41,
	["SQ"] = 42,
	["SV"] = 43,
	["CV"] = 44,

	-- Bottom
	["F1"] = 49,
	["F2"] = 50,
	["F3"] = 51,
	["F4"] = 52,
	["F5"] = 53,
	["F6"] = 54,
	["CQ"] = 55,
	["="] = 56,

	------ Cat Form ------
	-- Middle
	["C C"] = 109,
	["C SC"] = 110,
	["C Q"] = 111,
	["C E"] = 112,
	["C G"] = 113,
	["C SG"] = 114,
	["C CG"] = 115,
	["C SE"] = 116,

	-- Bottom
	["C 1"] = 73,
	["C 2"] = 74,
	["C 3"] = 75,
	["C 4"] = 76,
	["C 5"] = 77,
	["C 6"] = 78,
	["C V"] = 79,
	["C CE"] = 80,
	
	------ Bear Form ------
	-- Middle
	["B C"] = 85,
	["B SC"] = 86,
	["B Q"] = 87,
	["B E"] = 88,
	["B G"] = 89,
	["B SG"] = 90,
	["B CG"] = 91,
	["B SE"] = 92,

	-- Bottom
	["B 1"] = 97,
	["B 2"] = 98,
	["B 3"] = 99,
	["B 4"] = 100,
	["B 5"] = 101,
	["B 6"] = 102,
	["B V"] = 103,
	["B CE"] = 104,

	------ Dragonriding ------
	-- Soar
	["S 1"] = 145,
	["S 2"] = 146,
	["S 3"] = 147,
	["S 4"] = 148,
	["S 5"] = 149,
	["S 6"] = 150,
	["S V"] = 151,
	["S CE"] = 152,

	-- Dragonriding
	["D 1"] = 121,
	["D 2"] = 122,
	["D 3"] = 123,
	["D 4"] = 124,
	["D 5"] = 125,
	["D 6"] = 126,
	["D V"] = 127,
	["D CE"] = 128,
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

-- /dump GetActionInfo(1)
--! Spell Name to ID
local spellNameToId = {
	-- Death Knight
	["Abomination Limb"] = 383269,
	["Raise Dead"] = 46585,
	["Summon Gargoyle"] = 49206,
	-- Demon Hunter
	["Demon Blades"] = 203555,
	["Elysian Decree"] = 390163,
	["Sigil of Chains"] = 202138,
	["Sigil of Flame"] = 204596,
	["Sigil of Misery"] = 207684,
	["Sigil of Silence"] = 202137,
	["The Hunt"] = 370965,
	["Blade Dance"] = 188499,
	["Chaos Strike"] = 162794,
	-- Druid
	["Adaptive Swarm"] = 391888,
	["Celestial Alignment"] = 194223,
	["Convoke the Spirits"] = 391528,
	["New Moon"] = 274281,
	["Stampeding Roar"] = 106898,
	["Swipe"] = 213764,
	["Thrash"] = 106832,
	["Wild Charge"] = 102401,
	-- Evoker
	["Dream Breath"] = 355936,
	["Eternity Surge"] = 359073,
	["Fire Breath"] = 357208,
	["Spiritbloom"] = 367226,
	-- Hunter
	["Cobra Shot"] = 193455,
	["Death Chakram"] = 375891,
	["Fury of the Eagle"] = 203415,
	["Wailing Arrow"] = 392060,
	["Wildfire Bomb"] = 259495,
	-- Mage
	["Polymorph"] = 118,
	["Radiant Spark"] = 376103,
	["Shifting Power"] = 382440,
	-- Monk
	["Bonedust Brew"] = 386276,
	["Faeline Stomp"] = 388193,
	["Weapons of Order"] = 387184,
	-- Paladin
	["Blessing of the Seasons"] = 388007,
	["Divine Toll"] = 375576,
	["Wake of Ashes"] = 255937,
	["Guardian of Ancient Kings"] = 86659,
	-- Priest
	["Apotheosis"] = 200183,
	["Body and Soul"] = 64129,
	["Holy Word: Salvation"] = 265202,
	["Mindgames"] = 375901,
	["Symbol of Hope"] = 64901,
	-- Rogue
	["Audacity"] = 381845,
	["Blindside"] = 328085,
	["Echoing Reprimand"] = 385616,
	["Flagellation"] = 384631,
	["Sepsis"] = 385408,
	["Serrated Bone Spike"] = 385424,
	["Stealth"] = 1784,
	-- Shaman
	["Earthgrab Totem"] = 51485,
	["Hex"] = 51514,
	["Primal Elementalist"] = 117013,
	["Primordial Wave"] = 375982,
	["Purge"] = 370,
	["Wind Rush Totem"] = 192077,
	-- Warlock
	["Command Demon"] = 119898,
	["Demonic Circle"] = 48018,
	["Demonic Circle: Teleport"] = 48020,
	["Shadow Bolt"] = 686,
	["Soul Rot"] = 386997,
	-- Warrior
	["Annihilator"] = 383916,
	["Blood and Thunder"] = 384277,
	["Devastator"] = 236279,
	["Execute"] = 163201,
	["Fervor of Battle"] = 202316,
	["Spear of Bastion"] = 376079,
}

local function known(spell)
	local spellId
	local exact = false

	if type(spell) == "number" then
		spellId = spell
		exact = true
	else
		if spellNameToId[spell] then
			spellId = spellNameToId[spell]
		elseif spell == "Bladestorm" and GetSpecialization() == 1 then
			spellId = 227847 -- Bladestorm workaround for Arms
		elseif spell == "Death and Decay" then
			if IsPlayerSpell(315442) or IsSpellKnown(315442) then return true end -- Death's Due
			if IsPlayerSpell(152280) or IsSpellKnown(152280) then return true end -- Defile
		else
			spellId = select(7, GetSpellInfo(spell))
		end
	end

	if not spellId then return false end

	return IsPlayerSpell(spellId) or IsSpellKnown(spellId, true)
end

local function spell(slotName, spellName, requiredLevel)
	requiredLevel = requiredLevel or 1
	local level = UnitLevel("player")
	local name = GetUnitName("player", false)
	local realm = GetRealmName()
	local custom = Automagic and Automagic.Characters and Automagic.Characters[name.."-"..realm] or Automagic.Characters[name] or {}
	local slotId = slotNames[slotName]
	local spellId
	if type(spellName) == "number" then
		spellId = spellName
	elseif spellNameToId[spellName] then
		spellId = spellNameToId[spellName]
	else
		spellId = select(7, GetSpellInfo(spellName))
	end
	local actionType, actionDataId, actionSubtype = GetActionInfo(slotId)
	local todo = "place"

	if spellName == "Polymorph" then
		local variants = {
			["Black Cat"] = 61305,
			["Bumblebee"] = 277792,
			["Direhorn"] = 277787,
			["Monkey"] = 161354,
			["Penguin"] = 161355,
			["Pig"] = 28272,
			["Polar Bear Cub"] = 161353,
			["Porcupine"] = 126819,
			["Rabbit"] = 61721,
			["Sheep"] = 118,
			["Turtle"] = 28271,
		}

		spellId = variants[custom["polymorph"] or ""] or variants["Sheep"]

		if not known(spellId) then
			spellId = variants["Sheep"]
		end

		if actionType == "spell" and actionDataId == spellId then
			todo = nil
		end
	elseif spellName == "Hex" then
		local variants = {
			["Cockroach"] = 211015,
			["Compy"] = 210873,
			["Frog"] = 51514,
			["Living Honey"] = 309328,
			["Skeletal Hatchling"] = 269352,
			["Snake"] = 211010,
			["Spider"] = 211004,
			["Wicker Mongrel"] = 277784,
			["Zandalari Tendonripper"] = 277778,
		}

		spellId = variants[custom["hex"] or ""] or variants["Frog"]

		if not known(spellId) then
			spellId = variants["Frog"]
		end

		if actionType == "spell" and actionDataId == spellId then
			todo = nil
		end
	elseif spellName == "Bladestorm" and GetSpecialization() == 1 then
		spellId = 227847

		if actionType == "spell" and (actionDataId == spellId or actionDataId == 389774) then
			todo = nil
		end
	elseif spellName == "Blessing of the Seasons" then
		if actionType == "spell" and (actionDataId == 328622 or actionDataId == 328281 or actionDataId == 328282 or actionDataId == 328620 or actionDataId == 388007 or actionDataId == 388010 or actionDataId == 388011 or actionDataId == 388013) then
			todo = nil
		end
	elseif spellName == "New Moon" then
		if actionType == "spell" and (actionDataId == 274281 or actionDataId == 274282 or actionDataId == 274283) then
			todo = nil
		end
	elseif spellName == "Thrash" then
		if actionType == "spell" and (actionDataId == 106830 or actionDataId == 77758 or actionDataId == 106832) then
			todo = nil
		end
	elseif spellName == "Swipe" then
		if actionType == "spell" and (actionDataId == 213764 or actionDataId == 213771 or actionDataId == 106785 or actionDataId == 202028) then
			todo = nil
		end
	elseif spellName == "Wild Charge" then
		if actionType == "spell" and (actionDataId == 102401 or actionDataId == 49376 or actionDataId == 16979 or actionDataId == 102417 or actionDataId == 102416 or actionDataId == 102383) then
			todo = nil
		end
	elseif spellName == "Stampeding Roar" then
		if actionType == "spell" and (actionDataId == 106898 or actionDataId == 77764 or actionDataId == 77761) then
			todo = nil
		end
	elseif spellName == "Wildfire Bomb" then
		if actionType == "spell" and (actionDataId == 259495 or actionDataId == 270335 or actionDataId == 271045 or actionDataId == 270323) then
			todo = nil
		end
	elseif spellName == "Eternity Surge" then
		if actionType == "spell" and (actionDataId == 382411 or actionDataId == 359073) then
			todo = nil
		end
	elseif spellName == "Fire Breath" then
		if actionType == "spell" and (actionDataId == 382266 or actionDataId == 357208) then
			todo = nil
		end
	elseif spellName == "Execute" then
		if actionType == "spell" and (actionDataId == 163201 or actionDataId == 280735 or actionDataId == 330325 or actionDataId == 5308 or actionDataId == 281000) then
			todo = nil
		end
	elseif spellName == "Spiritbloom" then
		if actionType == "spell" and (actionDataId == 367226 or actionDataId == 382731) then
			todo = nil
		end
	elseif spellName == "Dream Breath" then
		if actionType == "spell" and (actionDataId == 355936 or actionDataId == 382614) then
			todo = nil
		end
	elseif spellName == "Guardian of Ancient Kings" then
		if actionType == "spell" and (actionDataId == 86659 or actionDataId == 212641) then
			todo = nil
		end
	elseif spellName == "Sigil of Flame" then
		if actionType == "spell" and (actionDataId == 204596 or actionDataId == 204513 or actionDataId == 389810) then
			todo = nil
		end
	elseif spellName == "Sigil of Misery" then
		if actionType == "spell" and (actionDataId == 207684 or actionDataId == 202140 or actionDataId == 389813) then
			todo = nil
		end
	elseif spellName == "Celestial Alignment" then
		if actionType == "spell" and (actionDataId == 194223 or actionDataId == 102560) then
			todo = nil
		end
	elseif level >= requiredLevel then
		if actionType == "spell" and spellId and actionDataId == spellId then
			todo = nil
		end
	else
		todo = "clear"
	end

	if todo == "clear" or not known(spellName) then
		-- Clear action button
		PickupAction(slotId)
		ClearCursor()
	elseif todo == "place" then
		-- Place spell
		PickupAction(slotId)
		ClearCursor()

		-- Some spells have multiple spell IDs depending on talents or stance, attempt to pick up any
		-- /dump (select(7, GetSpellInfo("Name")))
		if spellName == "Blessing of the Seasons" then
			spellById(slotId, 328282) -- Blessing of Spring
			spellById(slotId, 328620) -- Blessing of Summer
			spellById(slotId, 328622) -- Blessing of Autumn
			spellById(slotId, 328281) -- Blessing of Winter
		end

		if ZA and ZA.DebugMode then print("Placing " .. slotName .. " (" .. slotId .. ")  ", "Spell: " .. spellId, spellName) end

		-- Place spell
		PickupSpell(spellId)
		PlaceAction(slotId)
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

local function macro(slotName, macroName, requiredSpell)
	local level = UnitLevel("player")
	local slotId = slotNames[slotName]
	local actionType = GetActionInfo(slotId)
	local todo = "place"

	if not requiredSpell or (requiredSpell and known(requiredSpell)) then
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
		if ZA and ZA.DebugMode then print("Placing " .. slotName .. " (" .. slotId .. ")  ", "Macro: " .. macroName) end

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

local function item(slotName, itemName)
	local slotId = slotNames[slotName]
	--empty(slotName) -- Clear previous action bar data

	-- Place item
	PickupItem(itemName)
	PlaceAction(slotId)
	ClearCursor()
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
		["Dracthyr"] = "Tail Swipe",
	}

	if known(racials[race]) then
		spell(slotName, racials[race])
	else
		-- Mercenary
		local placed = false
		for _, spellName in pairs(racials) do
			if known(spellName) then
				spell(slotName, spellName)
				placed = true
			end
		end

		if not placed then
			empty(slotName)
		end
	end
end

local function UpdateBars(event)
	--print(event) -- Debug

	if InCombatLockdown() then
		Placer:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		-- Update Global Pet Macros
		if Automagic then Automagic.UpdatePets() end

		-- Local Variables
		local name = GetUnitName("player", false)
		local realm = GetRealmName()
		local _,class = UnitClass("player")
		local faction = UnitFactionGroup("player")
		local level = UnitLevel("player")
		local spec = GetSpecialization() or 5
		local timewalking = false
		local covenant = C_Covenants and C_Covenants.GetActiveCovenantID() or 0
		--local configID = C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())
		--local loadout = configID and C_Traits.GetConfigInfo(configID).name or "Unknown"
		local custom = Automagic and Automagic.Characters and Automagic.Characters[name.."-"..realm] or Automagic.Characters[name] or {}

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
				EditMacro(i, "C"..mp..mi, "INV_MISC_QUESTIONMARK", "", 1, 1)
			end
		end

		if numCharMacros < 18 then
			for i = 1, (18-numCharMacros) do
				mi = mi + 1
				local mp = "0"
				if mi >= 10 then
					mp = ""
				end
				CreateMacro("C"..mp..mi, "INV_MISC_QUESTIONMARK", "", 1, 1)
			end
		end

		-- Action Bar Data
		if class == "DEATHKNIGHT" then
			--! Death Knight

			if spec == 1 then
				--! Blood Death Knight
				
				------ Macros ------

				-- Rune Strike / Death Coil
				m("C03", nil, "#showtooltip\n/use [mod:shift]Death Coil;Rune Strike")

				-- Death and Decay
				m("C04", nil, "#showtooltip\n/stopspelltarget [mod:shift]\n/use [mod:shift,@player][]Death and Decay")

				-- Mind Freeze
				m("C08", nil, "#showtooltip Mind Freeze\n#showtooltip Mind Freeze\n/stopcasting\n/stopcasting\n/use Mind Freeze")

				-- Gorefiend's Grasp @player
				m("C09", nil, "#showtooltip Gorefiend's Grasp\n/use [@player]Gorefiend's Grasp")

				-- Gorefiend's Grasp @target
				m("C10", 1037260, "#showtooltip Gorefiend's Grasp\n/use [@target]Gorefiend's Grasp")

				-- Wraith Walk
				m("C13", nil, "#showtooltip Wraith Walk\n/use !Wraith Walk")

				
				------ Left ------
				-- Top
				spell("N", "Abomination Limb")
				spell("SN", "Soul Reaper")
				spell("R", "Dark Command")
				spell("SR", "Death Grip")
				macro("CR", "C09", "Gorefiend's Grasp")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Blood Tap")
				spell("SC", "Bonestorm")
				if known("Mark of Blood") then spell("Q", "Mark of Blood") else spell("Q", "Tombstone") end
				spell("E", "Death's Caress")
				spell("G", "Dancing Rune Weapon")
				spell("SG", "Empower Rune Weapon")
				macro("SE", "C08", "Mind Freeze")

				-- Bottom
				spell("1", "Marrowrend")
				spell("2", "Blood Boil")
				macro("3", "C03")
				macro("4", "C04")
				spell("5", "Death Strike")
				if known("Blooddrinker") then spell("6", "Blooddrinker") else spell("6", "Consumption") end
				spell("V", "Rune Tap")
				spell("CE", "Asphyxiate")

				------ Right ------
				-- Top
				spell("AB3", "Anti-Magic Zone")
				empty("AF")
				spell("CF", "Lichborne")
				spell("SF", "Death's Advance")
				macro("F", "C13", "Wraith Walk")

				-- Middle
				spell("T", "Chains of Ice")
				spell("ST", "Blinding Sleet")
				spell("CT", "Control Undead")
				empty("AT")
				macro("CB3", "C10", "Gorefiend's Grasp")
				spell("SQ", "Death Strike")
				macro("SV", "G014", "Raise Dead")
				spell("CV", "Sacrificial Pact")

				-- Bottom
				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				spell("F3", "Death Pact")
				spell("F4", "Vampiric Blood")
				empty("F5")
				empty("F6")
				spell("CQ", "Path of Frost")

			elseif spec == 2 then
				--! Frost Death Knight
				
				------ Macros ------

				-- Frost Strike / Death Coil
				m("C03", nil, "#showtooltip\n/use [help][mod:shift]Death Coil;Frost Strike")

				-- Death and Decay
				m("C04", nil, "#showtooltip\n/stopspelltarget [mod:shift]\n/use [mod:shift,@player][]Death and Decay")

				-- Breath of Sindragosa
				m("C06", nil, "#showtooltip\n/use !Breath of Sindragosa")

				-- Mind Freeze
				m("C08", nil, "#showtooltip Mind Freeze\n#showtooltip Mind Freeze\n/stopcasting\n/stopcasting\n/use Mind Freeze")

				-- Wraith Walk
				m("C13", nil, "#showtooltip Wraith Walk\n/use !Wraith Walk")
				
				
				------ Left ------
				-- Top
				spell("N", "Abomination Limb")
				spell("SN", "Soul Reaper")
				spell("R", "Dark Command")
				spell("SR", "Death Grip")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Horn of Winter")
				spell("SC", "Chill Streak")
				spell("Q", "Frostscythe")
				spell("E", "Howling Blast")
				spell("G", "Frostwyrm's Fury")
				spell("SG", "Empower Rune Weapon")
				macro("SE", "C08", "Mind Freeze")

				-- Bottom
				spell("1", "Rune Strike")
				spell("2", "Remorseless Winter")
				if known("Frost Strike") then macro("3", "C03") else spell("3", "Death Coil") end
				macro("4", "C04")
				spell("5", "Glacial Advance")
				macro("6", "C06", "Breath of Sindragosa")
				spell("V", "Pillar of Frost")
				spell("CE", "Asphyxiate")

				------ Right ------
				-- Top
				spell("AB3", "Anti-Magic Zone")
				empty("AF")
				spell("CF", "Lichborne")
				spell("SF", "Death's Advance")
				macro("F", "C13", "Wraith Walk")

				-- Middle
				spell("T", "Chains of Ice")
				spell("ST", "Blinding Sleet")
				spell("CT", "Control Undead")
				empty("AT")
				empty("CB3")
				spell("SQ", "Death Strike")
				macro("SV", "G014", "Raise Dead")
				spell("CV", "Sacrificial Pact")

				-- Bottom
				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				spell("F3", "Death Pact")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Path of Frost")

			elseif spec == 3 then
				--! Unholy Death Knight
				
				------ Macros ------

				-- Death and Decay
				m("C04", nil, "#showtooltip\n/stopspelltarget [mod:shift]\n/use [mod:shift,@player][]Death and Decay")

				-- Mind Freeze
				m("C08", nil, "#showtooltip Mind Freeze\n#showtooltip Mind Freeze\n/stopcasting\n/stopcasting\n/use Mind Freeze")

				-- Gnaw
				m("C09", 237524, "#showtooltip\n/use [nobtn:2]Gnaw\n/petautocasttoggle [btn:2]Gnaw")

				-- Huddle
				m("C10", 237533, "#showtooltip\n/use Huddle")

				-- Wraith Walk
				m("C13", nil, "#showtooltip Wraith Walk\n/use !Wraith Walk")
				
				
				------ Left ------
				-- Top
				spell("N", "Soul Reaper")
				spell("SN", "Vile Contagion")
				spell("R", "Dark Command")
				spell("SR", "Death Grip")
				macro("CR", "C09", 46584) -- 46584 is permanent Raise Dead
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Unholy Assault")
				spell("SC", "Unholy Blight")
				spell("Q", "Epidemic")
				spell("E", "Outbreak")
				spell("G", "Summon Gargoyle")
				spell("SG", "Empower Rune Weapon")
				macro("SE", "C08", "Mind Freeze")

				-- Bottom
				spell("1", "Rune Strike")
				spell("2", "Scourge Strike")
				spell("3", "Death Coil")
				macro("4", "C04")
				spell("5", "Abomination Limb")
				spell("6", "Apocalypse")
				spell("V", "Dark Transformation")
				spell("CE", "Asphyxiate")

				------ Right ------
				-- Top
				spell("AB3", "Anti-Magic Zone")
				empty("AF")
				spell("CF", "Lichborne")
				spell("SF", "Death's Advance")
				macro("F", "C13", "Wraith Walk")

				-- Middle
				spell("T", "Chains of Ice")
				spell("ST", "Blinding Sleet")
				spell("CT", "Control Undead")
				empty("AT")
				empty("CB3")
				spell("SQ", "Death Strike")
				if not known(46584) then macro("SV", "G014") else spell("SV", "Army of the Dead") end
				spell("CV", "Sacrificial Pact")

				-- Bottom
				spell("F1", "Anti-Magic Shell")
				spell("F2", "Icebound Fortitude")
				spell("F3", "Death Pact")
				empty("F4")
				empty("F5")
				if level < 22 then empty("F6") else macro("F6", "C10", 46584) end
				spell("CQ", "Path of Frost")

			else
				--! Unspecialized Death Knight
				
				------ Macros ------

				-- Death and Decay
				m("C04", nil, "#showtooltip\n/stopspelltarget [mod:shift]\n/use [mod:shift,@player][]Death and Decay")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Dark Command")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				empty("E")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				spell("1", "Rune Strike")
				empty("2")
				spell("3", "Death Coil")
				macro("4", "C04", "Death and Decay")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				spell("CF", "Lichborne")
				spell("SF", "Death's Advance")
				empty("F")

				-- Middle
				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				empty("SQ")
				empty("SV")
				empty("CV")

				-- Bottom
				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "DEMONHUNTER" then
			--! Demon Hunter

			if spec == 1 then
				--! Havoc Demon Hunter
				
				------ Macros ------

				-- Disrupt
				m("C08", nil, "#showtooltip Disrupt\n/stopcasting\n/stopcasting\n/use Disrupt")

				-- Metamorphosis @player
				m("C13", nil, "#showtooltip Metamorphosis\n/use [@player]Metamorphosis")

				-- Metamorphosis
				m("C14", 1344650, "#showtooltip\n/use Metamorphosis")
				
				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Torment")
				spell("SR", "Consume Magic")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Throw Glaive")
				spell("SC", "Essence Break")
				if known("Demon Blades") then empty("Q") else spell("Q", "Felblade") end
				spell("E", "Sigil of Flame")
				macro("G", "C13", "Metamorphosis")
				spell("SG", "Elysian Decree")
				macro("SE", "C08", "Disrupt")

				-- Bottom
				if known("Demon Blades") and known("Felblade") then spell("1", "Felblade") else spell("1", "Demon's Bite") end
				spell("2", "Chaos Strike")
				spell("3", "Blade Dance")
				spell("4", "Immolation Aura")
				spell("5", "Eye Beam")
				if known("Glaive Tempest") then spell("6", "Glaive Tempest") else spell("6", "Fel Barrage") end
				spell("V", "The Hunt")
				spell("CE", "Chaos Nova")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Vengeful Retreat")
				spell("F", "Fel Rush")

				-- Middle
				spell("T", "Imprison")
				spell("ST", "Fel Eruption")
				spell("CT", "Sigil of Misery")
				empty("AT")
				empty("CB3")
				empty("SQ")
				macro("SV", "C14", "Metamorphosis")
				spell("CV", "Spectral Sight")

				-- Bottom
				spell("F1", "Blur")
				spell("F2", "Netherwalk")
				spell("F3", "Darkness")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			elseif spec == 2 then
				--! Vengeance Demon Hunter
				
				------ Macros ------

				-- Disrupt
				m("C08", nil, "#showtooltip Disrupt\n/stopcasting\n/stopcasting\n/use Disrupt")
				
				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Torment")
				spell("SR", "Consume Magic")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Throw Glaive")
				spell("SC", "Fel Devastation")
				spell("Q", "Felblade")
				spell("E", "Sigil of Flame")
				spell("G", "Metamorphosis")
				spell("SG", "Elysian Decree")
				macro("SE", "C08", "Disrupt")

				-- Bottom
				spell("1", "Shear")
				spell("2", "Soul Cleave")
				spell("3", "Demon Spikes")
				spell("4", "Immolation Aura")
				spell("5", "Spirit Bomb")
				spell("6", "Soul Carver")
				spell("V", "The Hunt")
				spell("CE", "Chaos Nova")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Vengeful Retreat")
				spell("F", "Infernal Strike")

				-- Middle
				spell("T", "Imprison")
				spell("ST", "Sigil of Silence")
				spell("CT", "Sigil of Misery")
				empty("AT")
				spell("CB3", "Sigil of Chains")
				empty("SQ")
				empty("SV")
				spell("CV", "Spectral Sight")

				-- Bottom
				spell("F1", "Fiery Brand")
				if known("Soul Barrier") then spell("F2", "Soul Barrier") else spell("F2", "Bulk Extraction") end
				spell("F3", "Darkness")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			else
				--! Unspecialized Demon Hunter
				
				------ Macros ------

				-- Disrupt
				m("C08", nil, "#showtooltip Disrupt\n/stopcasting\n/stopcasting\n/use Disrupt")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Torment")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Throw Glaive")
				empty("SC")
				empty("Q")
				empty("E")
				empty("G")
				empty("SG")
				macro("SE", "C08", "Disrupt")

				-- Bottom
				spell("1", "Demon's Bite")
				spell("2", "Immolation Aura")
				empty("3")
				empty("4")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Fel Rush")

				-- Middle
				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				empty("SQ")
				empty("SV")
				spell("CV", "Spectral Sight")

				-- Bottom
				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "DRUID" then
			--! Druid

			if spec == 1 then
				--! Balance Druid
				
				------ Macros ------

				-- Wrath / Regrowth
				m("C01", nil, "#showtooltip\n/use [help]Regrowth;Wrath")

				-- Starfire / Swiftmend
				m("C02", nil, "#showtooltip\n/use [help]Swiftmend;Starfire")

				-- Starsurge / Wild Growth
				m("C03", nil, "#showtooltip\n/use [help]Wild Growth;Starsurge")

				-- Solar Beam
				m("C06", nil, "#showtooltip Solar Beam\n/stopcasting\n/stopcasting\n/use Solar Beam")

				-- Moonfire / Rejuvenation
				m("C07", nil, "#showtooltip\n/use [help]Rejuvenation;Moonfire")

				-- Skull Bash
				m("C08", nil, "#showtooltip Skull Bash\n/stopcasting\n/stopcasting\n/use [noform:1,noform:2]Bear Form\n/use Skull Bash")

				-- Celestial Alignment / Heart of the Wild
				m("C09", nil, "#showtooltip\n/use [help]Heart of the Wild;Celestial Alignment")

				-- Innervate
				m("C10", nil, "#showtooltip Innervate\n/use [@focus,help,nodead][exists,help,nodead]Innervate")

				-- Growl
				m("C11", nil, "#showtooltip Growl\n/use [noform:1]Bear Form\n/use Growl")

				-- Bear Form
				m("C12", nil, "#showtooltip Bear Form\n/use [noform:1]Bear Form")

				-- Cat Form / Dash
				m("C13", nil, "#showtooltip Dash\n/use [form:2]Dash;Cat Form")

				if known("Moonkin Form") then
					-- Moonkin Form
					m("C14", nil, "#showtooltip Moonkin Form\n/stopcasting\n/stopcasting\n/use [noform:4,nobtn:2]Moonkin Form\n/cancelform [btn:2]")
				else
					-- Caster Form
					m("C14", 461117, "/stopcasting\n/stopcasting\n/cancelform")
				end

				-- Prowl
				m("C15", nil, "#showtooltip\n/cancelaura Travel Form\n/cancelaura [btn:2]Prowl\n/use [nobtn:2]!Prowl")

				-- Flap
				m("C16", nil, "#showtooltip Flap\n/use [form:4]Flap;!Moonkin Form")

				
				------ Left ------
				-- Top
				spell("N", "Force of Nature")
				spell("SN", "Warrior of Elune")
				macro("R", "C11")
				spell("SR", "Soothe")
				spell("CR", "Remove Corruption")
				empty("H")
				macro("SH", "C10", "Innervate")
				racial("AE")

				-- Middle
				if known("New Moon") then spell("C", "New Moon") else spell("C", "Fury of Elune") end
				spell("SC", "Wild Mushroom")
				spell("Q", "Starfall")
				if known("Rejuvenation") then macro("E", "C07") else spell("E", "Moonfire") end
				if known("Heart of the Wild") and known("Celestial Alignment") then macro("G", "C09") elseif known("Heart of the Wild") then spell("G", "Heart of the Wild") else spell("G", "Celestial Alignment") end
				spell("SG", "Convoke the Spirits")
				macro("SE", "C06", "Solar Beam")

				-- Bottom
				macro("1", "C01")
				if known("Swiftmend") then macro("2", "C02") else spell("2", "Starfire") end
				if known("Wild Growth") then macro("3", "C03") else spell("3", "Starsurge") end
				spell("4", "Sunfire")
				spell("5", "Stellar Flare")
				macro("6", "C08", "Skull Bash")
				spell("V", "Astral Communion")
				if known("Incapacitating Roar") then spell("CE", "Incapacitating Roar") else spell("CE", "Mighty Bash") end

				------ Cat Form ------
				-- Middle
				empty("C C")
				empty("C SC")
				spell("C Q", "Swipe")
				if known("Rejuvenation") then macro("C E", "C07") else spell("C E", "Moonfire") end
				spell("C G", "Heart of the Wild")
				spell("C SG", "Convoke the Spirits")
				macro("C SE", "C08", "Skull Bash")

				-- Bottom
				if known("Rake") then spell("C 1", "Rake") elseif known("Thrash") then spell("C 1", "Thrash") else spell("C 1", "Shred") end
				if known("Rake") then spell("C 2", "Thrash") else empty("C 2") end
				if known("Rake") or known("Thrash") then spell("C 3", "Shred") else empty("C 3") end
				spell("C 4", "Rip")
				spell("C 5", "Ferocious Bite")
				spell("C 6", "Maim")
				empty("C V")
				if known("Incapacitating Roar") then spell("C CE", "Incapacitating Roar") else spell("C CE", "Mighty Bash") end

				------ Bear Form ------
				-- Middle
				empty("B C")
				empty("B SC")
				spell("B Q", "Frenzied Regeneration")
				if known("Rejuvenation") then macro("B E", "C07") else spell("B E", "Moonfire") end
				spell("B G", "Heart of the Wild")
				spell("B SG", "Convoke the Spirits")
				macro("B SE", "C08", "Skull Bash")

				-- Bottom
				spell("B 1", "Mangle")
				spell("B 2", "Thrash")
				spell("B 3", "Swipe")
				spell("B 4", "Ironfur")
				empty("B 5")
				empty("B 6")
				empty("B V")
				if known("Incapacitating Roar") then spell("B CE", "Incapacitating Roar") else spell("B CE", "Mighty Bash") end

				------ Right ------
				-- Top
				if known("Mass Entanglement") then spell("AB3", "Mass Entanglement") else spell("AB3", "Ursol's Vortex") end
				spell("AF", "Travel Form")
				spell("CF", "Wild Charge")
				spell("SF", "Stampeding Roar")
				macro("F", "C13")

				-- Middle
				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				spell("CT", "Hibernate")
				empty("AT")
				spell("CB3", "Typhoon")
				spell("SQ", "Regrowth")
				macro("SV", "C14")
				macro("CV", "C15", "Prowl")

				-- Bottom
				spell("F1", "Barkskin")
				macro("F2", "C12")
				spell("F3", "Renewal")
				spell("F4", "Nature's Vigil")
				empty("F5")
				empty("F6")
				if known("Flap") then macro("CQ", "C16", "Moonkin Form") else empty("CQ") end

			elseif spec == 2 then
				--! Feral Druid
				
				------ Macros ------

				-- Wrath / Regrowth
				m("C01", nil, "#showtooltip\n/use [help]Regrowth;Wrath")

				-- Starfire / Swiftmend
				m("C02", nil, "#showtooltip\n/use [help]Swiftmend;Starfire")

				-- Starsurge / Wild Growth
				m("C03", nil, "#showtooltip\n/use [help]Wild Growth;Starsurge")

				-- Rip / Primal Wrath
				m("C04", nil, "#showtooltip\n/use [mod:shift]Primal Wrath;Rip")

				-- Moonfire / Rejuvenation
				m("C07", nil, "#showtooltip\n/use [help]Rejuvenation;Moonfire")

				-- Skull Bash
				m("C08", nil, "#showtooltip Skull Bash\n/stopcasting\n/stopcasting\n/use [noform:1,noform:2]Bear Form\n/use Skull Bash")

				-- Innervate
				m("C10", nil, "#showtooltip Innervate\n/use [@focus,help,nodead][exists,help,nodead]Innervate")

				-- Growl
				m("C11", nil, "#showtooltip Growl\n/use [noform:1]Bear Form\n/use Growl")

				-- Bear Form
				m("C12", nil, "#showtooltip Bear Form\n/use [noform:1]Bear Form")

				-- Cat Form / Dash
				m("C13", nil, "#showtooltip Dash\n/use [form:2]Dash;Cat Form")

				-- Moonkin Form / Flap
				m("C14", nil, "#showtooltip "..( known("Flap") and "[form:4]Flap;" or "" ).."Moonkin Form\n/use "..( known("Flap") and "[form:4]Flap;" or "" ).."!Moonkin Form")

				-- Prowl
				m("C15", nil, "#showtooltip\n/cancelaura Travel Form\n/cancelaura [btn:2]Prowl\n/use [nobtn:2]!Prowl")

				-- Cat Form
				m("C16", nil, "#showtooltip Cat Form\n/use [noform:2,nobtn:2]Cat Form\n/cancelform [btn:2]")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				macro("R", "C11")
				spell("SR", "Soothe")
				spell("CR", "Remove Corruption")
				empty("H")
				macro("SH", "C10", "Innervate")
				racial("AE")

				-- Middle
				spell("C", "Adaptive Swarm")
				empty("SC")
				empty("Q")
				if known("Rejuvenation") then macro("E", "C07") else spell("E", "Moonfire") end
				spell("G", "Heart of the Wild")
				spell("SG", "Convoke the Spirits")
				macro("SE", "C08", "Skull Bash")

				-- Bottom
				macro("1", "C01")
				if known("Swiftmend") and known("Starfire") then macro("2", "C02") elseif known("Swiftmend") then spell("2", "Swiftmend") else spell("2", "Starfire") end
				if known("Wild Growth") and known("Starsurge") then macro("3", "C03") elseif known("Wild Growth") then spell("3", "Wild Growh") else spell("3", "Starsurge") end
				spell("4", "Sunfire")
				empty("5")
				empty("6")
				empty("V")
				if known("Incapacitating Roar") then spell("CE", "Incapacitating Roar") else spell("CE", "Mighty Bash") end

				------ Cat Form ------
				-- Middle
				spell("C C", "Adaptive Swarm")
				spell("C SC", "Feral Frenzy")
				spell("C Q", "Swipe")
				if known("Rejuvenation") then macro("C E", "C07") else spell("C E", "Moonfire") end
				spell("C G", "Berserk")
				spell("C SG", "Convoke the Spirits")
				macro("C SE", "C08", "Skull Bash")

				-- Bottom
				spell("C 1", "Rake")
				spell("C 2", "Thrash")
				spell("C 3", "Shred")
				if known("Rip") and known("Primal Wrath") then macro("C 4", "C04") elseif known("Primal Wrath") then spell("C 4", "Primal Wrath") else spell("C 4", "Rip") end
				spell("C 5", "Ferocious Bite")
				spell("C 6", "Maim")
				spell("C V", "Tiger's Fury")
				if known("Incapacitating Roar") then spell("C CE", "Incapacitating Roar") else spell("C CE", "Mighty Bash") end

				------ Bear Form ------
				-- Middle
				spell("B C", "Adaptive Swarm")
				empty("B SC")
				spell("B Q", "Frenzied Regeneration")
				if known("Rejuvenation") then macro("B E", "C07") else spell("B E", "Moonfire") end
				spell("B G", "Heart of the Wild")
				spell("B SG", "Convoke the Spirits")
				macro("B SE", "C08", "Skull Bash")

				-- Bottom
				spell("B 1", "Mangle")
				spell("B 2", "Thrash")
				spell("B 3", "Swipe")
				spell("B 4", "Ironfur")
				empty("B 5")
				empty("B 6")
				empty("B V")
				if known("Incapacitating Roar") then spell("B CE", "Incapacitating Roar") else spell("B CE", "Mighty Bash") end

				------ Right ------
				-- Top
				if known("Mass Entanglement") then spell("AB3", "Mass Entanglement") else spell("AB3", "Ursol's Vortex") end
				spell("AF", "Travel Form")
				spell("CF", "Wild Charge")
				spell("SF", "Stampeding Roar")
				macro("F", "C13")

				-- Middle
				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				spell("CT", "Hibernate")
				empty("AT")
				spell("CB3", "Typhoon")
				spell("SQ", "Regrowth")
				macro("SV", "C16")
				macro("CV", "C15", "Prowl")

				-- Bottom
				spell("F1", "Barkskin")
				macro("F2", "C12")
				spell("F3", "Survival Instincts")
				spell("F4", "Renewal")
				spell("F5", "Nature's Vigil")
				empty("F6")
				macro("CQ", "C14", "Moonkin Form")

			elseif spec == 3 then
				--! Guardian Druid
				
				------ Macros ------

				-- Wrath / Regrowth
				m("C01", nil, "#showtooltip\n/use [help]Regrowth;Wrath")

				-- Starfire / Swiftmend
				m("C02", nil, "#showtooltip\n/use [help]Swiftmend;Starfire")

				-- Starsurge / Wild Growth
				m("C03", nil, "#showtooltip\n/use [help]Wild Growth;Starsurge")

				-- Moonfire / Rejuvenation
				m("C07", nil, "#showtooltip\n/use [help]Rejuvenation;Moonfire")

				-- Skull Bash
				m("C08", nil, "#showtooltip Skull Bash\n/stopcasting\n/stopcasting\n/use [noform:1,noform:2]Bear Form\n/use Skull Bash")

				-- Innervate
				m("C10", nil, "#showtooltip Innervate\n/use [@focus,help,nodead][exists,help,nodead]Innervate")

				-- Growl
				m("C11", nil, "#showtooltip Growl\n/use [noform:1]Bear Form\n/use Growl")

				-- Bear Form
				m("C12", nil, "#showtooltip Bear Form\n/use [noform:1,nobtn:2]Bear Form\n/cancelform [btn:2]")

				-- Cat Form / Dash
				m("C13", nil, "#showtooltip Dash\n/use [form:2]Dash;Cat Form")

				if known("Moonkin Form") then
					-- Moonkin Form / Flap
					m("C14", nil, "#showtooltip "..( known("Flap") and "[form:4]Flap;" or "" ).."Moonkin Form\n/use "..( known("Flap") and "[form:4]Flap;" or "" ).."!Moonkin Form")
				else
					-- Caster Form
					m("C14", 461117, "/stopcasting\n/stopcasting\n/cancelform")
				end

				-- Prowl
				m("C15", nil, "#showtooltip\n/cancelaura Travel Form\n/cancelaura [btn:2]Prowl\n/use [nobtn:2]!Prowl")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				macro("R", "C11")
				spell("SR", "Soothe")
				spell("CR", "Remove Corruption")
				empty("H")
				macro("SH", "C10", "Innervate")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				if known("Rejuvenation") then macro("E", "C07") else spell("E", "Moonfire") end
				spell("G", "Heart of the Wild")
				spell("SG", "Convoke the Spirits")
				macro("SE", "C08", "Skull Bash")

				-- Bottom
				macro("1", "C01")
				if known("Swiftmend") and known("Starfire") then macro("2", "C02") elseif known("Swiftmend") then spell("2", "Swiftmend") else spell("2", "Starfire") end
				if known("Wild Growth") and known("Starsurge") then macro("3", "C03") elseif known("Wild Growth") then spell("3", "Wild Growh") else spell("3", "Starsurge") end
				spell("4", "Sunfire")
				empty("5")
				empty("6")
				empty("V")
				if known("Incapacitating Roar") then spell("CE", "Incapacitating Roar") else spell("CE", "Mighty Bash") end

				------ Cat Form ------
				-- Middle
				empty("C C")
				empty("C SC")
				spell("C Q", "Swipe")
				if known("Rejuvenation") then macro("C E", "C07") else spell("C E", "Moonfire") end
				spell("C G", "Heart of the Wild")
				spell("C SG", "Convoke the Spirits")
				macro("C SE", "C08", "Skull Bash")

				-- Bottom
				if known("Rake") then spell("C 1", "Rake") elseif known("Thrash") then spell("C 1", "Thrash") else spell("C 1", "Shred") end
				if known("Rake") then spell("C 2", "Thrash") else empty("C 2") end
				if known("Rake") or known("Thrash") then spell("C 3", "Shred") else empty("C 3") end
				spell("C 4", "Rip")
				spell("C 5", "Ferocious Bite")
				spell("C 6", "Maim")
				empty("C V")
				if known("Incapacitating Roar") then spell("C CE", "Incapacitating Roar") else spell("C CE", "Mighty Bash") end

				------ Bear Form ------
				-- Middle
				spell("B C", "Bristling Fur")
				spell("B SC", "Convoke the Spirits")
				spell("B Q", "Frenzied Regeneration")
				if known("Rejuvenation") then macro("B E", "C07") else spell("B E", "Moonfire") end
				spell("B G", "Berserk")
				spell("B SG", "Heart of the Wild")
				macro("B SE", "C08", "Skull Bash")

				-- Bottom
				spell("B 1", "Mangle")
				spell("B 2", "Thrash")
				spell("B 3", "Swipe")
				spell("B 4", "Ironfur")
				spell("B 5", "Maul")
				spell("B 6", "Pulverize")
				spell("B V", "Rage of the Sleeper")
				if known("Incapacitating Roar") then spell("B CE", "Incapacitating Roar") else spell("B CE", "Mighty Bash") end

				------ Right ------
				-- Top
				if known("Mass Entanglement") then spell("AB3", "Mass Entanglement") else spell("AB3", "Ursol's Vortex") end
				spell("AF", "Travel Form")
				spell("CF", "Wild Charge")
				spell("SF", "Stampeding Roar")
				macro("F", "C13")

				-- Middle
				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				spell("CT", "Hibernate")
				empty("AT")
				spell("CB3", "Typhoon")
				spell("SQ", "Regrowth")
				macro("SV", "C12")
				macro("CV", "C15", "Prowl")

				-- Bottom
				spell("F1", "Barkskin")
				spell("F2", "Survival Instincts")
				spell("F3", "Renewal")
				spell("F4", "Nature's Vigil")
				empty("F5")
				empty("F6")
				macro("CQ", "C14", "Moonkin Form")

			elseif spec == 4 then
				--! Restoration Druid

				------ Macros ------

				-- Regrowth / Wrath
				m("C01", nil, "#showtooltip\n/use [help]Regrowth;[harm]"..( known("Moonkin Form") and "[form:4]" or "" ).."Wrath;Regrowth")

				-- Nourish or Swiftmend / Starfire
				m("C02", nil, "#showtooltip\n/use [help]"..( known("Nourish") and "Nourish" or "Swiftmend" )..";[harm]"..( known("Moonkin Form") and "[form:4]" or "" ).."Starfire;"..( known("Nourish") and "Nourish" or "Swiftmend" ).."")

				-- Wild Growth / Starsurge
				m("C03", nil, "#showtooltip\n/use [help]Wild Growth;[harm]"..( known("Moonkin Form") and "[form:4]" or "" ).."Starsurge;Wild Growth")

				-- Lifebloom / Sunfire
				m("C04", nil, "#showtooltip\n/use [help]Lifebloom;[harm]"..( known("Moonkin Form") and "[form:4]" or "" ).."Sunfire;Lifebloom")

				-- Flourish / Heart of the Wild
				m("C06", nil, "#showtooltip\n/use [help]Flourish;"..( known("Moonkin Form") and "[form:4]" or "[harm]" ).."Heart of the Wild;Flourish")

				-- Rejuvenation / Moonfire
				m("C07", nil, "#showtooltip\n/use [help]Rejuvenation;[harm][form:1][form:2]"..( known("Moonkin Form") and "[form:4]" or "" ).."Moonfire;Rejuvenation")

				-- Skull Bash
				m("C08", nil, "#showtooltip Skull Bash\n/stopcasting\n/stopcasting\n/use [noform:1,noform:2]Bear Form\n/use Skull Bash")

				-- Innervate
				m("C10", nil, "#showtooltip Innervate\n/use [@focus,help,nodead][exists,help,nodead][@player]Innervate")

				-- Growl
				m("C11", nil, "#showtooltip Growl\n/use [noform:1]Bear Form\n/use Growl")

				-- Bear Form
				m("C12", nil, "#showtooltip Bear Form\n/use [noform:1]Bear Form")

				-- Cat Form / Dash
				m("C13", nil, "#showtooltip Dash\n/use [form:2]Dash;Cat Form")

				-- Moonkin Form / Flap
				m("C14", nil, "#showtooltip "..( known("Flap") and "[form:4]Flap;" or "" ).."Moonkin Form\n/use "..( known("Flap") and "[form:4]Flap;" or "" ).."!Moonkin Form")

				-- Prowl
				m("C15", nil, "#showtooltip\n/cancelaura Travel Form\n/cancelaura [btn:2]Prowl\n/use [nobtn:2]!Prowl")

				if custom["treant"] and known("Treant Form") then
					-- Treant Form
					m("C16", nil, "#showtooltip Treant Form\n/stopcasting\n/stopcasting\n/use [noform:"..( known("Moonkin Form") and "5" or "4" ).."]!Treant Form")
				else
					-- Caster Form
					m("C16", 461117, "/stopcasting\n/stopcasting\n/cancelform")
				end

				
				------ Left ------
				-- Top
				spell("N", "Cenarion Ward")
				spell("SN", "Nature's Swiftness")
				macro("R", "C11")
				spell("SR", "Soothe")
				spell("CR", "Nature's Cure")
				spell("H", "Ironbark")
				macro("SH", "C10", "Innervate")
				racial("AE")

				-- Middle
				spell("C", "Adaptive Swarm")
				spell("SC", "Overgrowth")
				spell("Q", "Efflorescence")
				macro("E", "C07")
				if known("Flourish") and known("Heart of the Wild") then macro("G", "C06") elseif known("Heart of the Wild") then spell("G", "Heart of the Wild") else spell("G", "Flourish") end
				if known("Convoke the Spirits") then spell("SG", "Convoke the Spirits") elseif known(33891) then spell("SG", "Incarnation: Tree of Life") else empty("SG") end
				macro("SE", "C08", "Skull Bash")

				-- Bottom
				macro("1", "C01")
				if (known("Nourish") or known("Swiftmend")) and known("Starfire") then macro("2", "C02") elseif known("Nourish") then spell("2", "Nourish") else spell("2", "Swiftmend") end
				if known("Wild Growth") and known("Starsurge") then macro("3", "C03") elseif known("Starsurge") then spell("3", "Starsurge") else spell("3", "Wild Growth") end
				if known("Lifebloom") and known("Sunfire") then macro("4", "C04") elseif known("Sunfire") then spell("4", "Sunfire") else spell("4", "Lifebloom") end
				if known("Nourish") then spell("5", "Swiftmend") else empty("5") end
				spell("6", "Invigorate")
				spell("V", "Nature's Vigil")
				if known("Incapacitating Roar") then spell("CE", "Incapacitating Roar") else spell("CE", "Mighty Bash") end

				------ Cat Form ------
				-- Middle
				spell("C C", "Adaptive Swarm")
				empty("C SC")
				spell("C Q", "Swipe")
				macro("C E", "C07")
				spell("C G", "Heart of the Wild")
				spell("C SG", "Convoke the Spirits")
				macro("C SE", "C08", "Skull Bash")

				-- Bottom
				if known("Rake") then spell("C 1", "Rake") elseif known("Thrash") then spell("C 1", "Thrash") else spell("C 1", "Shred") end
				if known("Rake") then spell("C 2", "Thrash") else empty("C 2") end
				if known("Rake") or known("Thrash") then spell("C 3", "Shred") else empty("C 3") end
				spell("C 4", "Rip")
				spell("C 5", "Ferocious Bite")
				spell("C 6", "Maim")
				spell("C V", "Nature's Vigil")
				if known("Incapacitating Roar") then spell("C CE", "Incapacitating Roar") else spell("C CE", "Mighty Bash") end

				------ Bear Form ------
				-- Middle
				spell("B C", "Adaptive Swarm")
				empty("B SC")
				spell("B Q", "Frenzied Regeneration")
				macro("B E", "C07")
				spell("B G", "Heart of the Wild")
				spell("B SG", "Convoke the Spirits")
				macro("B SE", "C08", "Skull Bash")

				-- Bottom
				spell("B 1", "Mangle")
				spell("B 2", "Thrash")
				spell("B 3", "Swipe")
				spell("B 4", "Ironfur")
				empty("B 5")
				empty("B 6")
				spell("B V", "Nature's Vigil")
				if known("Incapacitating Roar") then spell("B CE", "Incapacitating Roar") else spell("B CE", "Mighty Bash") end

				------ Right ------
				-- Top
				if known("Mass Entanglement") then spell("AB3", "Mass Entanglement") else spell("AB3", "Ursol's Vortex") end
				spell("AF", "Travel Form")
				spell("CF", "Wild Charge")
				spell("SF", "Stampeding Roar")
				macro("F", "C13")

				-- Middle
				spell("T", "Cyclone")
				spell("ST", "Entangling Roots")
				spell("CT", "Hibernate")
				empty("AT")
				spell("CB3", "Typhoon")
				spell("SQ", "Regrowth")
				macro("SV", "C16")
				macro("CV", "C15", "Prowl")

				-- Bottom
				spell("F1", "Barkskin")
				macro("F2", "C12")
				spell("F3", "Renewal")
				spell("F4", "Nature's Vigil")
				empty("F5")
				empty("F6")
				macro("CQ", "C14", "Moonkin Form")

			else
				--! Unspecialized Druid

				------ Macros ------

				-- Wrath / Regrowth
				m("C01", nil, "#showtooltip\n/use [help]Regrowth;Wrath")

				-- Growl
				m("C11", nil, "#showtooltip Growl\n/use [noform:1]Bear Form\n/use Growl")

				-- Bear Form
				m("C12", nil, "#showtooltip Bear Form\n/use [noform:1]Bear Form")

				if known("Dash") then
					-- Cat Form / Dash
					m("C13", nil, "#showtooltip Dash\n/use [form:" .. (level >= 8 and "2" or "1") .. "]Dash;Cat Form")
				else
					-- Cat Form
					m("C13", nil, "#showtooltip Cat Form\n/use [noform:" .. (level >= 8 and "2" or "1") .. "]Cat Form")
				end

				-- Caster Form
				m("C16", 461117, "/stopcasting\n/stopcasting\n/cancelform")
				

				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				macro("R", "C11", "Growl")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Moonfire")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				if known("Regrowth") then macro("1", "C01") else spell("1", "Wrath") end
				empty("2")
				empty("3")
				empty("4")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Cat Form ------
				-- Middle
				empty("C C")
				empty("C SC")
				empty("C Q")
				spell("C E", "Moonfire")
				empty("C G")
				empty("C SG")
				empty("C SE")

				-- Bottom
				spell("C 1", "Shred")
				empty("C 2")
				empty("C 3")
				empty("C 4")
				spell("C 5", "Ferocious Bite")
				empty("C 6")
				empty("C V")
				empty("C CE")

				------ Bear Form ------
				-- Middle
				empty("B C")
				empty("B SC")
				empty("B Q")
				spell("B E", "Moonfire")
				empty("B G")
				empty("B SG")
				empty("B SE")

				-- Bottom
				spell("B 1", "Mangle")
				empty("B 2")
				empty("B 3")
				empty("B 4")
				empty("B 5")
				empty("B 6")
				empty("B V")
				empty("B CE")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Travel Form")
				empty("CF")
				empty("SF")
				macro("F", "C13", "Cat Form")

				-- Middle
				empty("T")
				spell("ST", "Entangling Roots")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Regrowth")
				macro("SV", "C16", "Cat Form")
				empty("CV")

				-- Bottom
				spell("F1", "Barkskin")
				macro("F2", "C12", "Bear Form")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "EVOKER" then
			--! Evoker

			if spec == 1 then
				--! Devastation Evoker
				
				------ Macros ------

				-- Quell
				m("C08", nil, "#showtooltip Quell\n/stopcasting\n/stopcasting\n/use Quell")

				-- Verdant Embrace
				m("C10", nil, "#showtooltip Verdant Embrace\n/use [help]Verdant Embrace")

				-- Living Flame Healing
				m("C13", nil, "#showtooltip\n/use [help][@player]Living Flame")
				
				
				------ Left ------
				-- Top
				empty("N")
				spell("SN", "Tip the Scales")
				spell("R", "Emerald Blossom")
				spell("SR", "Unravel")
				spell("CR", "Expunge")
				empty("H")
				spell("SH", "Cauterizing Flame")
				empty("AE")

				-- Middle
				spell("C", "Shattering Star")
				empty("SC")
				spell("Q", "Eternity Surge")
				spell("E", "Fire Breath")
				spell("G", "Dragonrage")
				empty("SG")
				macro("SE", "C08", "Quell")

				-- Bottom
				spell("1", "Living Flame")
				spell("2", "Azure Strike")
				spell("3", "Disintegrate")
				spell("4", "Pyre")
				spell("5", "Firestorm")
				empty("6")
				spell("V", "Deep Breath")
				racial("CE")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Rescue")
				macro("CF", "C10", "Verdant Embrace")
				spell("SF", "Time Spiral")
				spell("F", "Hover")

				-- Middle
				spell("T", "Sleep Walk")
				spell("ST", "Landslide")
				spell("CT", "Oppressing Roar")
				empty("AT")
				spell("CB3", "Wing Buffet")
				macro("SQ", "C13", "Living Flame")
				spell("SV", "Visage")
				spell("CV", "Soar")

				-- Bottom
				spell("F1", "Obsidian Scales")
				spell("F2", "Renewing Blaze")
				spell("F3", "Zephyr")
				empty("F4")
				empty("F5")
				empty("CQ")

			elseif spec == 2 then
				--! Preservation Evoker
				
				------ Macros ------

				-- Verdant Embrace / Azure Strike
				m("C02", nil, "#showtooltip\n/use [harm]Azure Strike;Verdant Embrace")

				-- Echo / Disintegrate
				m("C03", nil, "#showtooltip\n/use [harm]Disintegrate;Echo")

				-- Quell
				m("C08", nil, "#showtooltip Quell\n/stopcasting\n/stopcasting\n/use Quell")

				-- Verdant Embrace
				m("C10", nil, "#showtooltip Verdant Embrace\n/use [help]Verdant Embrace")

				-- Living Flame Healing
				m("C13", nil, "#showtooltip\n/use [help][@player]Living Flame")

				-- Emerald Communion
				m("C14", nil, "#showtooltip\n/use !Emerald Communion")
				
				
				------ Left ------
				-- Top
				empty("N")
				spell("SN", "Tip the Scales")
				empty("R")
				spell("SR", "Unravel")
				spell("CR", "Expunge")
				spell("H", "Time Dilation")
				spell("SH", "Cauterizing Flame")
				empty("AE")

				-- Middle
				spell("C", "Spiritbloom")
				spell("SC", "Emerald Blossom")
				spell("Q", "Dream Breath")
				spell("E", "Fire Breath")
				spell("G", "Stasis")
				macro("SG", "C14", "Emerald Communion")
				macro("SE", "C08", "Quell")

				-- Bottom
				spell("1", "Living Flame")
				if known("Verdant Embrace") then macro("2", "C02") else spell("2", "Azure Strike") end
				if known("Echo") then macro("3", "C03") else spell("3", "Disintegrate") end
				spell("4", "Reversion")
				spell("5", "Temporal Anomaly")
				spell("6", "Dream Flight")
				spell("V", "Deep Breath")
				racial("CE")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Rescue")
				macro("CF", "C10", "Verdant Embrace")
				spell("SF", "Time Spiral")
				spell("F", "Hover")

				-- Middle
				spell("T", "Sleep Walk")
				spell("ST", "Landslide")
				spell("CT", "Oppressing Roar")
				empty("AT")
				spell("CB3", "Wing Buffet")
				macro("SQ", "C13", "Living Flame")
				spell("SV", "Visage")
				spell("CV", "Soar")

				-- Bottom
				spell("F1", "Obsidian Scales")
				spell("F2", "Renewing Blaze")
				spell("F3", "Zephyr")
				spell("F4", "Rewind")
				empty("F5")
				empty("F6")
				empty("CQ")

			else
				--! Unspecialized Evoker
				
				------ Macros ------

				-- Living Flame Healing
				m("C13", nil, "#showtooltip\n/use [help][@player]Living Flame")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Emerald Blossom")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				empty("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Fire Breath")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				spell("1", "Living Flame")
				spell("2", "Azure Strike")
				spell("3", "Disintegrate")
				empty("4")
				empty("5")
				empty("6")
				spell("V", "Deep Breath")
				racial("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Hover")

				-- Middle
				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				spell("CB3", "Wing Buffet")
				macro("SQ", "C13", "Living Flame")
				spell("SV", "Visage")
				spell("CV", "Soar")

				-- Bottom
				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end

		elseif class == "HUNTER" then
			--! Hunter

			if spec == 1 then
				--! Beast Mastery Hunter
				
				------ Macros ------

				-- Kill Command
				m("C02", nil, "#showtooltip Kill Command\n/petattack\n/petassist\n/petattack\n/use Kill Command")

				-- Wailing Arrow
				m("C06", 132170, "#showtooltip\n/use Wailing Arrow")

				-- Counter Shot
				m("C08", nil, "#showtooltip Counter Shot\n/stopcasting\n/stopcasting\n/use Counter Shot")

				-- Growl
				m("C09", 132270, "#showtooltip Growl\n/use [nopet]Command Pet;[nobtn:2]Growl\n/petattack [nobtn:2]\n/petassist [nobtn:2]\n/petattack [nobtn:2]\n/petautocasttoggle [btn:2]Growl")

				-- Aspect of the Turtle
				m("C13", nil, "#showtooltip\n/use !Aspect of the Turtle")

				-- Misdirection
				m("C14", nil, "#showtooltip Misdirection\n/use [@focus,help][help][@pet,exists][]Misdirection")

				-- Mend Pet/Revive Pet
				m("C15", nil, "#showtooltip\n/use [@pet,dead][nopet]Revive Pet;Mend Pet")

				-- Master's Call
				m("C16", 236189, "#showtooltip\n/use [nopet]Command Pet;[help][@player]Master's Call")

				-- Fortitude of the Bear
				m("C17", 571585, "#showtooltip\n/use [nopet]Command Pet;Fortitude of the Bear")
					
				
				------ Left ------
				-- Top
				if known("Stampede") then spell("N", "Stampede") else spell("N", "Death Chakram") end
				spell("SN", "Steel Trap")
				macro("R", "C09")
				spell("SR", "Tranquilizing Shot")
				macro("CR", "G019")
				spell("H", "Hunter's Mark")
				spell("SH", "Sentinel Owl")
				racial("AE")

				-- Middle
				if known("Explosive Shot") then spell("C", "Explosive Shot") else spell("C", "Barrage") end
				if known("A Murder of Crows") then spell("SC", "A Murder of Crows") else spell("SC", "Bloodshed") end
				spell("Q", "Multi-Shot")
				spell("E", "Serpent Sting")
				spell("G", "Bestial Wrath")
				spell("SG", "Aspect of the Wild")
				macro("SE", "C08", "Counter Shot")

				-- Bottom
				if known("Barbed Shot") then spell("1", "Barbed Shot") else spell("1", "Steady Shot") end
				macro("2", "C02", "Kill Command")
				if known("Cobra Shot") and known("Barbed Shot") then spell("3", "Steady Shot") elseif known("Cobra Shot") then empty("3") else spell("3", "Arcane Shot") end
				spell("4", "Kill Shot")
				spell("5", "Dire Beast")
				macro("6", "C06", "Wailing Arrow")
				spell("V", "Call of the Wild")
				if known("Scatter Shot") then spell("CE", "Scatter Shot") else spell("CE", "Binding Shot") end

				------ Right ------
				-- Top
				spell("AB3", "Flare")
				if level < 28 then empty("AF") else macro("AF", "C16") end
				empty("CF")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")

				-- Middle
				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				spell("CT", "Tar Trap")
				spell("AT", "Scare Beast")
				if known("Intimidation") then spell("CB3", "Intimidation") else spell("CB3", "High Explosive Trap") end
				macro("SQ", "C15")
				spell("SV", "Camouflage")
				spell("CV", "Feign Death")

				-- Bottom
				spell("F1", "Exhilaration")
				macro("F2", "C13", "Aspect of the Turtle")
				spell("F3", "Survival of the Fittest")
				if level < 1 then empty("F4") else macro("F4", "C17") end
				empty("F5")
				empty("F6")
				macro("CQ", "C14", "Misdirection")

			elseif spec == 2 then
				--! Marksmanship Hunter
				
				------ Macros ------

				-- Wailing Arrow
				m("C06", 132170, "#showtooltip\n/use Wailing Arrow")

				-- Counter Shot
				m("C08", nil, "#showtooltip Counter Shot\n/stopcasting\n/stopcasting\n/use Counter Shot")

				-- Growl
				m("C09", 132270, "#showtooltip Growl\n/use [nopet]Command Pet;[nobtn:2]Growl\n/petattack [nobtn:2]\n/petassist [nobtn:2]\n/petattack [nobtn:2]\n/petautocasttoggle [btn:2]Growl")

				-- Aspect of the Turtle
				m("C13", nil, "#showtooltip\n/use !Aspect of the Turtle")

				-- Misdirection
				m("C14", nil, "#showtooltip Misdirection\n/use [@focus,help][help][@pet,exists][]Misdirection")

				-- Mend Pet/Revive Pet
				m("C15", nil, "#showtooltip\n/use [@pet,dead][nopet]Revive Pet;Mend Pet")

				-- Master's Call
				m("C16", 236189, "#showtooltip\n/use [nopet]Command Pet;[help][@player]Master's Call")

				-- Fortitude of the Bear
				m("C17", 571585, "#showtooltip\n/use [nopet]Command Pet;Fortitude of the Bear")
				
				
				------ Left ------
				-- Top
				if known("Stampede") then spell("N", "Stampede") else spell("N", "Death Chakram") end
				spell("SN", "Steel Trap")
				macro("R", "C09")
				spell("SR", "Tranquilizing Shot")
				macro("CR", "G019")
				spell("H", "Hunter's Mark")
				spell("SH", "Sentinel Owl")
				racial("AE")

				-- Middle
				if known("Explosive Shot") then spell("C", "Explosive Shot") else spell("C", "Barrage") end
				spell("SC", "Volley")
				spell("Q", "Multi-Shot")
				spell("E", "Serpent Sting")
				spell("G", "Trueshot")
				spell("SG", "Double Tap")
				macro("SE", "C08", "Counter Shot")

				-- Bottom
				spell("1", "Aimed Shot")
				spell("2", "Steady Shot")
				spell("3", "Arcane Shot")
				spell("4", "Kill Shot")
				spell("5", "Rapid Fire")
				macro("6", "C06", "Wailing Arrow")
				spell("V", "Salvo")
				if known("Scatter Shot") then spell("CE", "Scatter Shot") else spell("CE", "Binding Shot") end

				------ Right ------
				-- Top
				spell("AB3", "Flare")
				if level < 28 then empty("AF") else macro("AF", "C16") end
				spell("CF", "Burning Shot")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")

				-- Middle
				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				spell("CT", "Tar Trap")
				spell("AT", "Scare Beast")
				if known("Intimidation") then spell("CB3", "Intimidation") else spell("CB3", "High Explosive Trap") end
				macro("SQ", "C15")
				spell("SV", "Camouflage")
				spell("CV", "Feign Death")

				-- Bottom
				spell("F1", "Exhilaration")
				macro("F2", "C13", "Aspect of the Turtle")
				spell("F3", "Survival of the Fittest")
				if level < 22 then empty("F4") else macro("F4", "C17") end
				empty("F5")
				empty("F6")
				macro("CQ", "C14", "Misdirection")

			elseif spec == 3 then
				--! Survival Hunter
				
				------ Macros ------

				-- Kill Command
				m("C02", nil, "#showtooltip Kill Command\n/petattack\n/petassist\n/petattack\n/use Kill Command")

				-- Muzzle
				m("C08", nil, "#showtooltip Muzzle\n/stopcasting\n/stopcasting\n/use Muzzle")

				-- Growl
				m("C09", 132270, "#showtooltip Growl\n/use [nopet]Command Pet;[nobtn:2]Growl\n/petattack [nobtn:2]\n/petassist [nobtn:2]\n/petattack [nobtn:2]\n/petautocasttoggle [btn:2]Growl")

				-- Aspect of the Turtle
				m("C13", nil, "#showtooltip\n/use !Aspect of the Turtle")

				-- Misdirection
				m("C14", nil, "#showtooltip Misdirection\n/use [@focus,help][help][@pet,exists][]Misdirection")

				-- Mend Pet/Revive Pet
				m("C15", nil, "#showtooltip\n/use [@pet,dead][nopet]Revive Pet;Mend Pet")

				-- Master's Call
				m("C16", 236189, "#showtooltip\n/use [nopet]Command Pet;[help][@player]Master's Call")

				-- Fortitude of the Bear
				m("C17", 571585, "#showtooltip\n/use [nopet]Command Pet;Fortitude of the Bear")
				
				
				------ Left ------
				-- Top
				if known("Stampede") then spell("N", "Stampede") else spell("N", "Death Chakram") end
				spell("SN", "Steel Trap")
				macro("R", "C09")
				spell("SR", "Tranquilizing Shot")
				macro("CR", "G019")
				spell("H", "Hunter's Mark")
				spell("SH", "Sentinel Owl")
				racial("AE")

				-- Middle
				if known("Explosive Shot") then spell("C", "Explosive Shot") else spell("C", "Barrage") end
				empty("SC")
				spell("Q", "Flanking Strike")
				spell("E", "Serpent Sting")
				spell("G", "Coordinated Assault")
				spell("SG", "Spearhead")
				macro("SE", "C08", "Muzzle")

				-- Bottom
				spell("1", "Raptor Strike")
				macro("2", "C02", "Kill Command")
				spell("3", "Wildfire Bomb")
				spell("4", "Kill Shot")
				if known("Carve") then spell("5", "Carve") else spell("5", "Butchery") end
				spell("6", "Fury of the Eagle")
				spell("V", "Aspect of the Eagle")
				if known("Scatter Shot") then spell("CE", "Scatter Shot") else spell("CE", "Binding Shot") end

				------ Right ------
				-- Top
				spell("AB3", "Flare")
				if level < 28 then empty("AF") else macro("AF", "C16") end
				spell("CF", "Harpoon")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")

				-- Middle
				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				spell("CT", "Tar Trap")
				spell("AT", "Scare Beast")
				if known("Intimidation") then spell("CB3", "Intimidation") else spell("CB3", "High Explosive Trap") end
				macro("SQ", "C15")
				spell("SV", "Camouflage")
				spell("CV", "Feign Death")

				-- Bottom
				spell("F1", "Exhilaration")
				macro("F2", "C13", "Aspect of the Turtle")
				spell("F3", "Survival of the Fittest")
				macro("F4", "C17")
				empty("F5")
				empty("F6")
				macro("CQ", "C14", "Misdirection")

			else
				--! Unspecialized Hunter
				
				------ Macros ------

				-- Aspect of the Turtle
				m("C13", nil, "#showtooltip\n/use !Aspect of the Turtle")

				-- Mend Pet/Revive Pet
				m("C15", nil, "#showtooltip\n/use [@pet,dead][nopet]Revive Pet;Mend Pet")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				empty("R")
				empty("SR")
				empty("CR")
				spell("H", "Hunter's Mark")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				empty("E")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				spell("1", "Arcane Shot")
				spell("2", "Steady Shot")
				empty("3")
				empty("4")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				spell("SF", "Disengage")
				spell("F", "Aspect of the Cheetah")

				-- Middle
				spell("T", "Freezing Trap")
				spell("ST", "Wing Clip")
				empty("CT")
				empty("AT")
				empty("CB3")
				if known("Mend pet") then macro("SQ", "C15") else spell("SQ", "Tame Beast") end
				empty("SV")
				spell("CV", "Feign Death")

				-- Bottom
				spell("F1", "Exhilaration")
				macro("F2", "C13", "Aspect of the Turtle")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "MAGE" then
			--! Mage

			if spec == 1 then
				--! Arcane Mage
				
				------ Macros ------

				-- Touch of the Magi
				m("C10", 236222, "#showtooltip\n/use Touch of the Magi")

				-- Counterspell
				m("C08", nil, "#showtooltip Counterspell\n/stopcasting\n/stopcasting\n/use Counterspell")

				-- Ice Block
				m("C13", nil, "#showtooltip\n/use !Ice Block")

				-- Mana Gem
				m("C14", 134132, "#showtooltip\n/use Mana Gem\n/use Conjure Mana Gem")
				
				
				------ Left ------
				-- Top
				spell("N", "Radiant Spark")
				spell("SN", "Presence of Mind")
				spell("R", "Meteor")
				spell("SR", "Spellsteal")
				spell("CR", "Remove Curse")
				if not known("Arcane Orb") then empty("H") else spell("H", "Fire Blast") end
				spell("SH", "Supernova")
				racial("AE")

				-- Middle
				spell("C", "Evocation")
				spell("SC", "Ice Nova")
				spell("Q", "Arcane Explosion")
				spell("E", "Nether Tempest")
				spell("G", "Arcane Surge")
				macro("SG", "C14", "Conjure Mana Gem")
				macro("SE", "C08", "Counterspell")

				-- Bottom
				spell("1", "Arcane Blast")
				spell("2", "Arcane Missiles")
				spell("3", "Arcane Barrage")
				if known("Arcane Orb") then spell("4", "Arcane Orb") else spell("4", "Fire Blast") end
				macro("5", "C10", "Touch of the Magi")
				spell("6", "Shifting Power")
				spell("V", "Rune of Power")
				spell("CE", "Frost Nova")

				------ Right ------
				-- Top
				spell("AB3", "Ring of Frost")
				spell("AF", "Alter Time")
				spell("CF", "Displacement")
				spell("SF", "Ice Floes")
				spell("F", "Blink")

				-- Middle
				spell("T", "Polymorph")
				if known("Slow") then spell("ST", "Slow") else spell("ST", "Frostbolt") end
				spell("CT", "Dragon's Breath")
				spell("AT", "Mass Polymorph")
				spell("CB3", "Blast Wave")
				spell("SQ", "Cone of Cold")
				spell("SV", "Invisibility")
				spell("CV", "Greater Invisibility")

				-- Bottom
				spell("F1", "Prismatic Barrier")
				macro("F2", "C13", "Ice Block")
				spell("F3", "Mirror Image")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Slow Fall")

			elseif spec == 2 then
				--! Fire Mage
				
				------ Macros ------

				-- Counterspell
				m("C08", nil, "#showtooltip Counterspell\n/stopcasting\n/stopcasting\n/use Counterspell")

				-- Ice Block
				m("C13", nil, "#showtooltip\n/use !Ice Block")
				
				
				------ Left ------
				-- Top
				spell("N", "Meteor")
				empty("SN")
				empty("R")
				spell("SR", "Spellsteal")
				spell("CR", "Remove Curse")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Scorch")
				spell("SC", "Ice Nova")
				spell("Q", "Arcane Explosion")
				spell("E", "Living Bomb")
				spell("G", "Combustion")
				empty("SH")
				macro("SE", "C08", "Counterspell")

				-- Bottom
				spell("1", "Fireball")
				spell("2", "Fire Blast")
				spell("3", "Pyroblast")
				spell("4", "Flamestrike")
				spell("5", "Phoenix Flames")
				spell("6", "Shifting Power")
				spell("V", "Rune of Power")
				spell("CE", "Frost Nova")

				------ Right ------
				-- Top
				spell("AB3", "Ring of Frost")
				spell("AF", "Alter Time")
				spell("CF", "Displacement")
				spell("SF", "Ice Floes")
				spell("F", "Blink")

				-- Middle
				spell("T", "Polymorph")
				if known("Slow") then spell("ST", "Slow") else spell("ST", "Frostbolt") end
				spell("CT", "Dragon's Breath")
				spell("AT", "Mass Polymorph")
				spell("CB3", "Blast Wave")
				spell("SQ", "Cone of Cold")
				spell("SV", "Invisibility")
				spell("CV", "Greater Invisibility")

				-- Bottom
				spell("F1", "Blazing Barrier")
				macro("F2", "C13", "Ice Block")
				spell("F3", "Mirror Image")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Slow Fall")

			elseif spec == 3 then
				--! Frost Mage
				
				------ Macros ------

				-- Frostbolt and Pet Attack
				m("C01", nil, "#showtooltip Frostbolt\n/petattack\n/petassist\n/petattack\n/use Frostbolt")

				-- Counterspell
				m("C08", nil, "#showtooltip Counterspell\n/stopcasting\n/stopcasting\n/use Counterspell")

				-- Ice barrier
				m("C12", 135843, "#showtooltip\n/use Ice Barrier")

				-- Ice Block
				m("C13", nil, "#showtooltip\n/use !Ice Block")

				-- Freeze
				m("C10", 1698698, "#showtooltip\n/use Freeze")
				
				
				------ Left ------
				-- Top
				if level < 23 then empty("N") else macro("N", "C10", "Summon Water Elemental") end
				spell("SN", "Ray of Frost")
				spell("R", "Meteor")
				spell("SR", "Spellsteal")
				spell("CR", "Remove Curse")
				spell("H", "Fire Blast")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Comet Storm")
				spell("SC", "Ice Nova")
				spell("Q", "Arcane Explosion")
				spell("E", "Frozen Orb")
				spell("G", "Icy Veins")
				spell("SG", "Glacial Spike")
				macro("SE", "C08", "Counterspell")

				-- Bottom
				if known("Summon Water Elemental") then macro("1", "C01") else spell("1", "Frostbolt") end
				spell("2", "Flurry")
				if known("Ice Lance") then spell("3", "Ice Lance") else spell("3", "Fire Blast") end
				if known("Blizzard") then spell("4", "Blizzard") else spell("4", "Arcane Explosion") end
				spell("5", "Ebonbolt")
				spell("6", "Shifting Power")
				spell("V", "Rune of Power")
				spell("CE", "Frost Nova")

				------ Right ------
				-- Top
				spell("AB3", "Ring of Frost")
				spell("AF", "Alter Time")
				spell("CF", "Displacement")
				spell("SF", "Ice Floes")
				spell("F", "Blink")

				-- Middle
				spell("T", "Polymorph")
				spell("ST", "Slow")
				spell("CT", "Dragon's Breath")
				spell("AT", "Mass Polymorph")
				spell("CB3", "Blast Wave")
				spell("SQ", "Cone of Cold")
				spell("SV", "Invisibility")
				spell("CV", "Greater Invisibility")

				-- Bottom
				macro("F1", "C12", "Ice Barrier")
				macro("F2", "C13", "Ice Block")
				spell("F3", "Mirror Image")
				spell("F4", "Cold Snap")
				empty("F5")
				empty("F6")
				spell("CQ", "Slow Fall")

			else
				--! Unspecialized Mage

				-- Counterspell
				m("C08", nil, "#showtooltip Counterspell\n/stopcasting\n/stopcasting\n/use Counterspell")

				-- Ice Block
				m("C13", nil, "#showtooltip\n/use !Ice Block")
				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				spell("Q", "Arcane Explosion")
				empty("E")
				empty("G")
				empty("SG")
				macro("SE", "C08", "Counterspell")

				-- Bottom
				spell("1", "Frostbolt")
				spell("2", "Fire Blast")
				empty("3")
				empty("4")
				empty("5")
				empty("6")
				empty("V")
				spell("CE", "Frost Nova")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Blink")

				-- Middle
				spell("T", "Polymorph")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				empty("SQ")
				empty("SV")
				empty("CV")

				-- Bottom
				empty("F1")
				macro("F2", "C13", "Ice Block")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Slow Fall")

			end
		elseif class == "MONK" then
			--! Monk

			if spec == 1 then
				--! Brewmaster Monk
				
				------ Macros ------

				-- Tiger Palm / Sothing Mist
				m("C01", nil, "#showtooltip\n/use [help]Soothing Mist;Tiger Palm")

				-- Blackout Kick / Vivify
				m("C03", nil, "#showtooltip\n/use [help]Vivify;Blackout Kick")

				-- Spear Hand Strike
				m("C08", nil, "#showtooltip Spear Hand Strike\n/stopcasting\n/stopcasting\n/use Spear Hand Strike")

				-- Tiger's Lust @player
				m("C13", 571558, "#showtooltip Tiger's Lust\n/use [@player]Tiger's Lust")

				-- Black Ox Statue
				m("C14", nil, "#showtooltip Black Ox Statue\n/targetexact Black Ox Statue\n/use Black Ox Statue")

				
				------ Left ------
				-- Top
				spell("N", "Bonedust Brew")
				spell("SN", "Summon White Tiger Statue")
				spell("R", "Provoke")
				spell("SR", "Crackling Jade Lightning")
				spell("CR", "Detox")
				spell("H", "Black Ox Brew")
				empty("SH")
				racial("AE")

				-- Middle
				if known("Chi Wave") then spell("C", "Chi Wave") else spell("C", "Chi Burst") end
				spell("SC", "Exploding Keg")
				spell("Q", "Spinning Crane Kick")
				spell("E", "Breath of Fire")
				spell("G", "Invoke Niuzao, the Black Ox")
				spell("SG", "Weapons of Order")
				macro("SE", "C08", "Spear Hand Strike")

				-- Bottom
				if known("Soothing Mist") then macro("1", "C01") else spell("1", "Tiger Palm") end
				spell("2", "Rising Sun Kick")
				macro("3", "C03")
				spell("4", "Keg Smash")
				spell("5", "Rushing Jade Wind")
				spell("6", "Purifying Brew")
				spell("V", "Touch of Death")
				spell("CE", "Leg Sweep")

				------ Right ------
				-- Top
				spell("AB3", "Summon Jade Serpent Statue")
				spell("AF", "Tiger's Lust")
				spell("CF", "Clash")
				macro("SF", "C13", "Tiger's Lust")
				spell("F", "Roll")

				-- Middle
				spell("T", "Paralysis")
				spell("ST", "Disable")
				empty("CT")
				macro("AT", "C14", "Summon Black Ox Statue")
				spell("CB3", "Ring of Peace")
				spell("SQ", "Vivify")
				spell("SV", "Transcendence")
				spell("CV", "Transcendence: Transfer")

				-- Bottom
				spell("F1", "Celestial Brew")
				spell("F2", "Fortifying Brew")
				spell("F3", "Diffuse Magic")
				spell("F4", "Dampen Harm")
				spell("F5", "Healing Elixir")
				spell("F6", "Zen Meditation")
				spell("CQ", "Expel Harm")

			elseif spec == 2 then
				--! Mistweaver Monk
				
				------ Macros ------

				-- Sothing Mist / Tiger Palm
				m("C01", nil, "#showtooltip\n/use [harm]Tiger Palm;Soothing Mist")

				-- Envelping Mist / Rising Sun Kick
				m("C02", nil, "#showtooltip\n/use [harm]Rising Sun Kick;Enveloping Mist")

				-- Vivify / Blackout Kick
				m("C03", nil, "#showtooltip\n/use [harm]Blackout Kick;Vivify")

				-- Spear Hand Strike
				m("C08", nil, "#showtooltip Spear Hand Strike\n/stopcasting\n/stopcasting\n/use Spear Hand Strike")

				-- Tiger's Lust @player
				m("C13", 571558, "#showtooltip Tiger's Lust\n/use [@player]Tiger's Lust")

				-- Black Ox Statue
				m("C14", nil, "#showtooltip Black Ox Statue\n/targetexact Black Ox Statue\n/use Black Ox Statue")
				
				
				------ Left ------
				-- Top
				spell("N", "Bonedust Brew")
				spell("SN", "Summon White Tiger Statue")
				spell("R", "Provoke")
				spell("SR", "Crackling Jade Lightning")
				spell("CR", "Detox")
				spell("H", "Life Cocoon")
				spell("SH", "Mana Tea")
				racial("AE")

				-- Middle
				if known("Chi Wave") then spell("C", "Chi Wave") else spell("C", "Chi Burst") end
				spell("SC", "Faeline Stomp")
				spell("Q", "Spinning Crane Kick")
				spell("E", "Renewing Mist")
				if known("Invoke Yu'lon, the Jade Serpent") then spell("G", "Invoke Yu'lon, the Jade Serpent") else spell("G", "Invoke Chi-Ji, the Red Crane") end
				spell("SG", "Thunder Focus Tea")
				macro("SE", "C08", "Spear Hand Strike")

				-- Bottom
				if known("Soothing Mist") then macro("1", "C01") else spell("1", "Tiger Palm") end
				if known("Rising Sun Kick") and known("Enveloping Mist") then macro("2", "C02") elseif known("Rising Sun Kick") then spell("2", "Rising Sun Kick") else spell("2", "Enveloping Mist") end
				macro("3", "C03")
				spell("4", "Essence Font")
				spell("5", "Sheilun's Gift") --spell("5", "Refreshing Jade Wind")
				spell("6", "Zen Pulse")
				spell("V", "Touch of Death")
				spell("CE", "Leg Sweep")

				------ Right ------
				-- Top
				spell("AB3", "Summon Jade Serpent Statue")
				spell("AF", "Tiger's Lust")
				empty("CF")
				macro("SF", "C13", "Tiger's Lust")
				spell("F", "Roll")

				-- Middle
				spell("T", "Paralysis")
				spell("ST", "Disable")
				spell("CT", "Song of Chi-Ji")
				macro("AT", "C14", "Summon Black Ox Statue")
				spell("CB3", "Ring of Peace")
				spell("SQ", "Vivify")
				spell("SV", "Transcendence")
				spell("CV", "Transcendence: Transfer")

				-- Bottom
				if known("Revival") then spell("F1", "Revival") else spell("F1", "Restoral") end
				spell("F2", "Fortifying Brew")
				spell("F3", "Diffuse Magic")
				spell("F4", "Dampen Harm")
				spell("F5", "Healing Elixir")
				empty("F6")
				spell("CQ", "Expel Harm")

			elseif spec == 3 then
				--! Windwalker Monk
				
				------ Macros ------

				-- Tiger Palm / Sothing Mist
				m("C01", nil, "#showtooltip\n/use [help]Soothing Mist;Tiger Palm")

				-- Blackout Kick / Vivify
				m("C03", nil, "#showtooltip\n/use [help]Vivify;Blackout Kick")

				-- Spear Hand Strike
				m("C08", nil, "#showtooltip Spear Hand Strike\n/stopcasting\n/stopcasting\n/use Spear Hand Strike")

				-- Tiger's Lust @player
				m("C13", 571558, "#showtooltip Tiger's Lust\n/use [@player]Tiger's Lust")

				-- Black Ox Statue
				m("C14", nil, "#showtooltip Black Ox Statue\n/targetexact Black Ox Statue\n/use Black Ox Statue")
				
				
				------ Left ------
				-- Top
				spell("N", "Bonedust Brew")
				spell("SN", "Summon White Tiger Statue")
				spell("R", "Provoke")
				spell("SR", "Crackling Jade Lightning")
				spell("CR", "Detox")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				if known("Chi Wave") then spell("C", "Chi Wave") else spell("C", "Chi Burst") end
				spell("SC", "Faeline Stomp")
				spell("Q", "Spinning Crane Kick")
				spell("E", "Whirling Dragon Punch")
				spell("G", "Invoke Xuen, the White Tiger")
				if known("Storm, Earth, and Fire") then spell("SG", "Storm, Earth, and Fire") else spell("SG", "Serenity") end
				macro("SE", "C08", "Spear Hand Strike")

				-- Bottom
				if known("Soothing Mist") then macro("1", "C01") else spell("1", "Tiger Palm") end
				spell("2", "Rising Sun Kick")
				macro("3", "C03")
				spell("4", "Fists of Fury")
				spell("5", "Rushing Jade Wind")
				spell("6", "Strike of the Windlord")
				spell("V", "Touch of Death")
				spell("CE", "Leg Sweep")

				------ Right ------
				-- Top
				spell("AB3", "Summon Jade Serpent Statue")
				spell("AF", "Tiger's Lust")
				spell("CF", "Flying Serpent Kick")
				macro("SF", "C13", "Tiger's Lust")
				spell("F", "Roll")

				-- Middle
				spell("T", "Paralysis")
				spell("ST", "Disable")
				empty("CT")
				macro("AT", "C14", "Summon Black Ox Statue")
				spell("CB3", "Ring of Peace")
				spell("SQ", "Vivify")
				spell("SV", "Transcendence")
				spell("CV", "Transcendence: Transfer")

				-- Bottom
				spell("F1", "Touch of Karma")
				spell("F2", "Fortifying Brew")
				spell("F3", "Diffuse Magic")
				spell("F4", "Dampen Harm")
				empty("F5")
				spell("F6", "Summon Black Ox Statue")
				spell("CQ", "Expel Harm")

			else
				--! Unspecialized Monk
				
				------ Macros ------

				-- Blackout Kick / Vivify
				m("C03", nil, "#showtooltip\n/use [help]Vivify;Blackout Kick")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Provoke")
				spell("SR", "Crackling Jade Lightning")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				spell("Q", "Spinning Crane Kick")
				empty("E")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				spell("1", "Tiger Palm")
				empty("2")
				if known("Vivify") then macro("3", "C03") else spell("3", "Blackout Kick") end
				empty("4")
				empty("5")
				empty("6")
				spell("V", "Touch of Death")
				spell("CE", "Leg Sweep")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				spell("CF", "Roll")
				empty("SF")
				empty("F")

				-- Middle
				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Vivify")
				empty("SV")
				empty("CV")

				-- Bottom
				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Expel Harm")

			end
		elseif class == "PALADIN" then
			--! Paladin

			if spec == 1 then
				--! Holy Paladin

				------ Macros ------

				-- Flash of Light / Crusader Strike
				m("C01", nil, "#showtooltip\n/use [harm]Crusader Strike;Flash of Light")

				-- Holy Light / Judgment
				m("C03", nil, "#showtooltip\n/use [harm]Judgment;Holy Light")

				-- Light of the Martyr / Hammer of Wrath
				m("C04", nil, "#showtooltip\n/use [harm]Hammer of Wrath;Light of the Martyr")

				-- Light of Dawn / Shield of the Righteous
				m("C05", nil, "#showtooltip\n/use [harm,worn:shield]Shield of the Righteous;Light of Dawn")

				-- Bestow Faith / Consecration
				m("C07", nil, "#showtooltip\n/use [help]Bestow Faith;Consecration")

				-- Rebuke
				m("C08", nil, "#showtooltip Rebuke\n/stopcasting\n/stopcasting\n/use Rebuke")

				-- Blessing of Freedom @player
				m("C13", 135878, "#showtooltip Blessing of Freedom\n/use [@player]Blessing of Freedom")

				
				------ Left ------
				-- Top
				empty("N")
				spell("SN", "Divine Favor")
				spell("R", "Hand of Reckoning")
				empty("SR")
				spell("CR", "Cleanse")
				spell("H", "Blessing of Sacrifice")
				empty("SH")
				racial("AE")

				-- Middle
				if known("Light's Hammer") then spell("C", "Light's Hammer") else spell("C", "Holy Prism") end
				spell("SC", "Barrier of Faith")
				spell("Q", "Word of Glory")
				if known("Bestow Faith") then macro("E", "C07") else spell("E", "Consecration") end
				spell("G", "Avenging Wrath")
				spell("SG", "Blessing of the Seasons")
				macro("SE", "C08", "Rebuke")

				-- Bottom
				macro("1", "C01")
				spell("2", "Holy Shock")
				if known("Holy Light") then macro("3", "C03") else spell("3", "Judgment") end
				if known("Light of the Martyr") and known("Hammer of Wrath") then macro("4", "C04") elseif known("Hammer of Wrath") then spell("4", "Hammer of Wrath") else spell("4", "Light of the Martyr") end
				if known("Light of Dawn") then macro("5", "C05") else spell("5", "Shield of the Righteous") end
				spell("6", "Seraphim")
				spell("V", "Divine Toll")
				spell("CE", "Hammer of Justice")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Blessing of Freedom")
				spell("CF", "Rule of Law")
				macro("SF", "C13", "Blessing of Freedom")
				spell("F", "Divine Steed")

				-- Middle
				if known("Repentance") then spell("T", "Repentance") else spell("T", "Blinding Light") end
				empty("ST")
				spell("CT", "Turn Evil")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash of Light")
				spell("SV", "Blessing of Protection")
				empty("CV")

				-- Bottom
				spell("F1", "Divine Protection")
				spell("F2", "Divine Shield")
				spell("F3", "Aura Mastery")
				spell("F4", "Tyr's Deliverance")
				spell("F5", "Beacon of Light")
				spell("F6", "Beacon of Faith")
				spell("CQ", "Lay on Hands")

			elseif spec == 2 then
				--! Protection Paladin

				------ Macros ------

				-- Rebuke
				m("C08", nil, "#showtooltip Rebuke\n/stopcasting\n/stopcasting\n/use Rebuke")

				-- Avenging Wrath
				if name == "Leo" then
					m("C10", nil, "#showtooltip\n/use Avenging Wrath\n/use item:193762")
				else
					m("C10", nil, "#showtooltip\n/use Avenging Wrath")
				end

				-- Blessing of Freedom @player
				m("C13", 135878, "#showtooltip Blessing of Freedom\n/use [@player]Blessing of Freedom")
				
				m("C14", nil, "#showtooltip Blessing of Freedom\n/use [help][@focus,nodead][]Blessing of Freedom")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Hand of Reckoning")
				empty("SR")
				spell("CR", "Cleanse Toxins")
				spell("H", "Blessing of Sacrifice")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Bastion of Light")
				empty("SC")
				spell("Q", "Word of Glory")
				spell("E", "Consecration")
				macro("G", "C10", "Avenging Wrath")
				spell("SG", "Moment of Glory")
				macro("SE", "C08", "Rebuke")

				-- Bottom
				spell("1", "Crusader Strike")
				spell("2", "Avenger's Shield")
				spell("3", "Judgment")
				spell("4", "Hammer of Wrath")
				spell("5", "Shield of the Righteous")
				spell("6", "Seraphim")
				spell("V", "Divine Toll")
				spell("CE", "Hammer of Justice")

				------ Right ------
				-- Top
				empty("AB3")
				macro("AF", "C14", "Blessing of Freedom")
				empty("CF")
				macro("SF", "C13", "Blessing of Freedom")
				spell("F", "Divine Steed")

				-- Middle
				if known("Repentance") then spell("T", "Repentance") else spell("T", "Blinding Light") end
				empty("ST")
				spell("CT", "Turn Evil")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash of Light")
				spell("SV", "Blessing of Protection")
				spell("CV", "Blessing of Spellwarding")

				-- Bottom
				spell("F1", "Ardent Defender")
				spell("F2", "Divine Shield")
				spell("F3", "Guardian of Ancient Kings")
				spell("F4", "Eye of Tyr")
				empty("F5")
				empty("F6")
				spell("CQ", "Lay on Hands")

			elseif spec == 3 then
				--! Retribution Paladin

				------ Macros ------

				-- Templar's Verdict / Shield of the Righteous
				m("C05", nil, "#showtooltip\n/use [worn:shield]Shield of the Righteous;Templar's Verdict")

				-- Divine Storm / Word of Glory
				m("C06", nil, "#showtooltip\n/use [help]Word of Glory;Divine Storm")

				-- Rebuke
				m("C08", nil, "#showtooltip Rebuke\n/stopcasting\n/stopcasting\n/use Rebuke")

				-- Blessing of Freedom @player
				m("C13", 135878, "#showtooltip Blessing of Freedom\n/use [@player]Blessing of Freedom")

				
				------ Left ------
				-- Top
				if known(404834) then empty("N") else spell("N", "Execution Sentence") end
				empty("SN")
				spell("R", "Hand of Reckoning")
				empty("SR")
				spell("CR", "Cleanse Toxins")
				spell("H", "Blessing of Sacrifice")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Wake of Ashes")
				empty("SC")
				if known("Divine Storm") then macro("Q", "C06") else spell("Q", "Word of Glory") end
				if known(404834) then spell("E", "Execution Sentence") else spell("E", "Consecration") end
				spell("G", "Avenging Wrath")
				spell("SG", "Final Reckoning")
				macro("SE", "C08", "Rebuke")

				-- Bottom
				spell("1", "Crusader Strike")
				spell("2", "Blade of Justice")
				spell("3", "Judgment")
				spell("4", "Hammer of Wrath")
				macro("5", "C05")
				spell("6", "Seraphim")
				spell("V", "Divine Toll")
				spell("CE", "Hammer of Justice")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Blessing of Freedom")
				empty("CF")
				macro("SF", "C13", "Blessing of Freedom")
				spell("F", "Divine Steed")

				-- Middle
				if known("Repentance") then spell("T", "Repentance") else spell("T", "Blinding Light") end
				spell("ST", "Hand of Hindrance")
				spell("CT", "Turn Evil")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash of Light")
				spell("SV", "Blessing of Protection")
				empty("CV")

				-- Bottom
				spell("F1", "Divine Protection")
				spell("F2", "Divine Shield")
				spell("F3", "Shield of Vengeance")
				if known("Justicar's Vengeance") then spell("F4", "Justicar's Vengeance") else spell("F4", "Eye for an Eye") end
				empty("F5")
				empty("F6")
				spell("CQ", "Lay on Hands")

			else
				--! Unspecialized Paladin

				------ Macros ------

				-- Crusader Strike / Flash of Light
				m("C01", nil, "#showtooltip\n/use [help]Flash of Light;Crusader Strike")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Hand of Reckoning")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				spell("Q", "Word of Glory")
				spell("E", "Consecration")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				if known("Flash Heal") then macro("1", "C01") else spell("1", "Crusader Strike") end
				empty("2")
				spell("3", "Judgment")
				empty("4")
				spell("5", "Shield of the Righteous")
				empty("6")
				empty("V")
				spell("CE", "Hammer of Justice")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				empty("F")

				-- Middle
				empty("T")
				empty("ST")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash of Light")
				empty("SV")
				empty("CV")

				-- Bottom
				empty("F1")
				spell("F2", "Divine Shield")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "PRIEST" then
			--! Priest

			if spec == 1 then
				--! Discipline Priest
				
				------ Macros ------

				-- Flash Heal / Smite
				m("C01", nil, "#showtooltip\n/use [harm]Smite;Flash Heal")

				-- Power Word: Radiance / Mind Blast
				m("C03", nil, "#showtooltip\n/use [harm]Mind Blast;Power Word: Radiance")

				-- Prayer of Mending / Shadow Word: Death
				m("C04", nil, "#showtooltip\n/use [harm]Shadow Word: Death;Prayer of Mending")

				-- Power Word: Shield / Mindgames
				m("C05", nil, "#showtooltip\n/use [harm]Mindgames;Power Word: Shield")

				-- Renew/Shadow Word: Pain
				m("C07", nil, "#showtooltip\n/use [harm]Shadow Word: Pain;Renew")

				-- Power Infusion
				m("C08", nil, "#showtooltip\n/use [@focus,help,nodead][help,nodead][@player]Power Infusion")

				-- Mind Control
				m("C09", 1718004, "#showtooltip\n/use Mind Control")

				-- Body and Soul - Power Word: Shield @player
				m("C13", 537099, "#showtooltip\n/use [@player]Power Word: Shield")
				
				-- Angelic Feather @player
				m("C14", 537020, "#showtooltip\n/use [@player]Angelic Feather")

				
				------ Left ------
				-- Top
				spell("N", "Holy Nova")
				empty("SN")
				spell("R", "Mind Soothe")
				spell("SR", "Dispel Magic")
				spell("CR", "Purify")
				spell("H", "Pain Suppression")
				spell("SH", "Void Shift")
				racial("AE")

				-- Middle
				spell("C", "Power Word: Solace")
				spell("SC", "Shadow Covenant")
				spell("Q", "Power Word: Life")
				if known("Renew") then macro("E", "C07") else spell("E", "Shadow Word: Pain") end
				spell("G", "Schism")
				macro("SG", "C08", "Power Infusion")
				spell("SE", "Rapture")

				-- Bottom
				macro("1", "C01")
				spell("2", "Penance")
				if known("Power Word: Radiance") then macro("3", "C03") else spell("3", "Mind Blast") end
				if known("Prayer of Mending") and known("Shadow Word: Death") then macro("4", "C04") elseif known("Prayer of Mending") then spell("4", "Prayer of Mending") else spell("4", "Shadow Word: Death") end
				if known("Mindgames") then macro("5", "C05") else spell("5", "Power Word: Shield") end
				if known(110744) then spell("6", "Divine Star") elseif known(120517) then spell("6", "Halo") else empty("6") end
				if known("Mindbender") then spell("V", "Shadowfiend") else macro("V", "G014", "Shadowfiend") end
				spell("CE", "Light's Wrath")

				------ Right ------
				-- Top
				spell("AB3", "Mass Dispel")
				spell("AF", "Power Word: Shield")
				macro("CF", "C13", "Body and Soul")
				spell("SF", "Angelic Feather")
				macro("F", "C14", "Angelic Feather")

				-- Middle
				spell("T", "Void Tendrils")
				spell("ST", "Psychic Scream")
				if known("Dominate Mind") then spell("CT", "Dominate Mind") else macro("CT", "C09", "Mind Control") end
				spell("AT", "Shackle Undead")
				spell("CB3", "Leap of Faith")
				spell("SQ", "Flash Heal")
				empty("SV")
				spell("CV", "Fade")

				-- Bottom
				spell("F1", "Desperate Prayer")
				spell("F2", "Power Word: Barrier")
				spell("F3", "Vampiric Embrace")
				spell("F4", "Evangelism")
				empty("F5")
				empty("F6")
				spell("CQ", "Levitate")

			elseif spec == 2 then
				--! Holy Priest
				
				------ Macros ------
				
				-- Flash Heal / Smite
				m("C01", nil, "#showtooltip\n/use [harm]Smite;Flash Heal")

				-- Heal / Holy Fire
				m("C02", nil, "#showtooltip\n/use [harm]Mind Blast;Heal")

				-- Prayer of Healing / Empyreal Blaze
				m("C03", nil, "#showtooltip\n/use [harm]Empyreal Blaze;Prayer of Healing")

				-- Prayer of Mending / Shadow Word: Death
				m("C04", nil, "#showtooltip\n/use [harm]Shadow Word: Death;Prayer of Mending")

				-- Circle of Healing / Mindgames
				m("C05", nil, "#showtooltip\n/use [harm]Mindgames;Circle of Healing")

				-- Renew/Shadow Word: Pain
				m("C07", nil, "#showtooltip\n/use [harm]Shadow Word: Pain;Renew")

				-- Power Infusion
				m("C08", nil, "#showtooltip\n/use [@focus,help,nodead][help,nodead][@player]Power Infusion")

				-- Mind Control
				m("C09", 1718004, "#showtooltip\n/use Mind Control")

				-- Body and Soul - Power Word: Shield @player
				m("C13", 537099, "#showtooltip\n/use [@player]Power Word: Shield")
				
				-- Angelic Feather @player
				m("C14", 537020, "#showtooltip\n/use [@player]Angelic Feather")

				
				------ Left ------
				-- Top
				spell("N", "Holy Nova")
				spell("SN", "Divine Word")
				spell("R", "Mind Soothe")
				spell("SR", "Dispel Magic")
				spell("CR", "Purify")
				spell("H", "Void Shift")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Holy Word: Serenity")
				spell("SC", "Holy Word: Sanctify")
				spell("Q", "Power Word: Life")
				if known("Renew") then macro("E", "C07") else spell("E", "Shadow Word: Pain") end
				if known("Apotheosis") then spell("G", "Apotheosis") else spell("G", "Holy Word: Salvation") end
				macro("SG", "C08", "Power Infusion")
				spell("SE", "Guardian Spirit")

				-- Bottom
				macro("1", "C01")
				if known("Heal") then macro("2", "C02") else spell("2", "Mind Blast") end
				if known("Prayer of Healing") and known("Empyreal Blaze") then macro("3", "C03") elseif known("Prayer of Healing") then spell("3", "Prayer of Healing") else spell("3", "Empyreal Blaze") end
				if known("Shadow Word: Death") and known("Prayer of Mending") then macro("4", "C04") elseif known("Shadow Word: Death") then spell("4", "Shadow Word: Death") else spell("4", "Prayer of Mending") end
				if known("Circle of Healing") and known("Mindgames") then macro("5", "C05") elseif known("Mindgames") then spell("5", "Mindgames") else spell("5", "Circle of Healing") end
				if known(110744) then spell("6", "Divine Star") elseif known(120517) then spell("6", "Halo") else empty("6") end
				macro("V", "G014", "Shadowfiend")
				spell("CE", "Holy Word: Chastise")

				------ Right ------
				-- Top
				spell("AB3", "Mass Dispel")
				spell("AF", "Power Word: Shield")
				macro("CF", "C13", "Body and Soul")
				spell("SF", "Angelic Feather")
				macro("F", "C14", "Angelic Feather")

				-- Middle
				spell("T", "Shackle Undead")
				spell("ST", "Psychic Scream")
				if known("Dominate Mind") then spell("CT", "Dominate Mind") else macro("CT", "C09", "Mind Control") end
				spell("AT", "Void Tendrils")
				spell("CB3", "Leap of Faith")
				spell("SQ", "Flash Heal")
				spell("SV", "Lightwell")
				spell("CV", "Fade")

				-- Bottom
				spell("F1", "Desperate Prayer")
				spell("F2", "Divine Hymn")
				spell("F3", "Vampiric Embrace")
				spell("F4", "Symbol of Hope")
				empty("F5")
				empty("F6")
				spell("CQ", "Levitate")

			elseif spec == 3 then
				--! Shadow Priest
				
				------ Macros ------

				-- Vampiric Touch / Flash Heal
				m("C01", nil, "#showtooltip\n/use [help]Flash Heal;Vampiric Touch")

				-- Mind Blast / Holy Nova
				m("C03", nil, "#showtooltip\n/use [mod:shift]Holy Nova;Mind Blast")

				-- Shadow Word: Death / Prayer of Mending
				m("C04", nil, "#showtooltip\n/use [help]Prayer of Mending;Shadow Word: Death")

				-- Devouring Plague / Mind Sear
				--m("C05", nil, "#showtooltip\n/use [mod:shift]Mind Sear;Devouring Plague")

				-- Renew/Shadow Word: Pain
				m("C07", nil, "#showtooltip\n/use [help]Renew;Shadow Word: Pain")

				-- Power Infusion
				m("C08", nil, "#showtooltip\n/use [@focus,help,nodead][help,nodead][@player]Power Infusion")

				-- Mind Control
				m("C09", 1718004, "#showtooltip\n/use Mind Control")

				-- Silence
				m("C10", nil, "#showtooltip Silence\n/stopcasting\n/stopcasting\n/use Silence")

				-- Shadowform
				m("C11", nil, "#showtooltip Shadowform\n/cancelaura [btn:2]Shadowform\n/use [nostance,nobtn:2]Shadowform")

				-- Dispersion
				m("C12", nil, "#showtooltip\n/use !Dispersion")

				-- Body and Soul - Power Word: Shield @player
				m("C13", 537099, "#showtooltip\n/use [@player]Power Word: Shield")
				
				-- Angelic Feather @player
				m("C14", 537020, "#showtooltip\n/use [@player]Angelic Feather")

				
				------ Left ------
				-- Top
				spell("N", "Holy Nova")
				empty("SN")
				spell("R", "Mind Soothe")
				spell("SR", "Dispel Magic")
				spell("CR", "Purify Disease")
				spell("H", "Power Word: Life")
				spell("SH", "Void Shift")
				racial("AE")

				-- Middle
				spell("C", "Void Torrent")
				if known(122121) then spell("SC", "Divine Star") elseif known(120644) then spell("SC", "Halo") else empty("SC") end
				spell("Q", "Shadow Crash")
				if known("Renew") then macro("E", "C07") else spell("E", "Shadow Word: Pain") end
				if known(391109) then spell("G", "Dark Ascension") elseif known(228260) then spell("G", "Void Eruption") else empty("G") end
				macro("SG", "C08", "Power Infusion")
				macro("SE", "C10", "Silence")

				-- Bottom
				macro("1", "C01")
				spell("2", "Smite")
				spell("3", "Mind Blast")
				if known("Prayer of Mending") then macro("4", "C04") else spell("4", "Shadow Word: Death") end
				spell("5", "Devouring Plague")
				spell("6", "Mindgames")
				if known("Mindbender") then spell("V", "Shadowfiend") else macro("V", "G014", "Shadowfiend") end
				spell("CE", "Psychic Horror")

				------ Right ------
				-- Top
				spell("AB3", "Mass Dispel")
				spell("AF", "Power Word: Shield")
				macro("CF", "C13", "Body and Soul")
				spell("SF", "Angelic Feather")
				macro("F", "C14", "Angelic Feather")

				-- Middle
				spell("T", "Shackle Undead")
				spell("ST", "Psychic Scream")
				if known("Dominate Mind") then spell("CT", "Dominate Mind") else macro("CT", "C09", "Mind Control") end
				spell("AT", "Void Tendrils")
				spell("CB3", "Leap of Faith")
				spell("SQ", "Flash Heal")
				macro("SV", "C11", "Shadowform")
				spell("CV", "Fade")

				-- Bottom
				spell("F1", "Desperate Prayer")
				macro("F2", "C12", "Dispersion")
				spell("F3", "Vampiric Embrace")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Levitate")

			else
				--! Unspecialized Priest
				
				------ Macros ------

				-- Flash Heal / Smite
				m("C01", nil, "#showtooltip\n/use [help]Flash Heal;Smite")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
		 		empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Shadow Word: Pain")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				if known("Flash Heal") then macro("1", "C01") else spell("1", "Smite") end
				empty("2")
				spell("3", "Mind Blast")
				empty("4")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Power Word: Shield")
				empty("CF")
				empty("SF")
				empty("F")

				-- Middle
				empty("T")
				spell("ST", "Psychic Scream")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Flash Heal")
				empty("SV")
				spell("CV", "Fade")

				-- Bottom
				spell("F1", "Desperate Prayer")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "ROGUE" then
			--! Rogue

			if spec == 1 then
				--! Assassination Rogue
				
				------ Macros ------

				-- Ambush and Cold Blood / Sinister Strike
				m("C01", nil, "#showtooltip [stance:1/2]Ambush;Sinister Strike\n"..(known("Cold Blood") and "/use [stance:1/2]Cold Blood\n" or "").."/use [stance:1/2]Ambush;Sinister Strike")

				if known("Crimson Tempest") then
					-- Eviscerate and Cold Blood / Crimson Tempest
					m("C03", nil, "#showtooltip [mod:shift]Crimson Tempest;Eviscerate\n"..(known("Cold Blood") and "/use [nomod:shift]Cold Blood\n" or "").."/use [mod:shift]Crimson Tempest;Eviscerate")
				else
					-- Eviscerate and Cold Blood
					m("C03", nil, "#showtooltip Eviscerate\n"..(known("Cold Blood") and "/use Cold Blood\n" or "").."/use Eviscerate")
				end

				-- Ambush and Cold Blood
				m("C06", nil, "#showtooltip Ambush\n/use Cold Blood\n/use Ambush")

				-- Stealth
				m("C07", nil, "#showtooltip Stealth\n/cancelaura [btn:2]Stealth;[nocombat]Shadow Dance\n/use [nobtn:2]!Stealth")

				-- Kick
				m("C08", nil, "#showtooltip Kick\n/stopcasting\n/stopcasting\n/use Kick")

				-- Tricks of the Trade
				m("C13", nil, "#showtooltip Tricks of the Trade\n/use [@focus,help][help][]Tricks of the Trade")
				
				
				------ Left ------
				-- Top
				spell("N", "Thistle Tea")
				spell("SN", "Shadow Dance")
				spell("R", "Marked for Death")
				spell("SR", "Shiv")
				if known("Sepsis") then spell("CR", "Sepsis") else spell("CR", "Serrated Bone Spike") end
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Poisoned Knife")
				if known("Blindside") then macro("SC", "C06") else empty("SC") end
				spell("Q", "Fan of Knives")
				spell("E", "Garrote")
				spell("G", "Deathmark")
				spell("SG", "Exsanguinate")
				macro("SE", "C08", "Kick")

				-- Bottom
				macro("1", "C01")
				spell("2", "Rupture")
				spell("3", "Eviscerate")
				spell("4", "Slice and Dice")
				spell("5", "Crimson Tempest") --spell("5", "Kingsbane")
				spell("6", "Echoing Reprimand")
				spell("V", "Indiscriminate Carnage")
				spell("CE", "Kidney Shot")

				------ Right ------
				-- Top
				spell("AB3", "Distract")
				spell("AF", "Shroud of Concealment")
				empty("CF")
				spell("SF", "Shadowstep")
				spell("F", "Sprint")

				-- Middle
				spell("T", "Sap")
				spell("ST", "Blind")
				spell("CT", "Cheap Shot")
				spell("AT", "Gouge")
				empty("CB3")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07", "Stealth")
				spell("CV", "Vanish")

				-- Bottom
				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				empty("F4")
				empty("F5")
				empty("F6")
				macro("CQ", "C13", "Tricks of the Trade")

			elseif spec == 2 then
				--! Outlaw Rogue
				
				------ Macros ------

				-- Ambush and Cold Blood / Sinister Strike
				m("C01", nil, "#showtooltip [stance:1/2]Ambush;Sinister Strike\n"..(known("Cold Blood") and "/use [stance:1/2]Cold Blood\n" or "").."/use [stance:1/2]Ambush;Sinister Strike")

				-- Pistol Shot
				m("C02", 134536, "#showtooltip\n/use Pistol Shot")

				-- Stealth
				m("C07", nil, "#showtooltip Stealth\n/cancelaura [btn:2]Stealth;[nocombat]Shadow Dance\n/use [nobtn:2]!Stealth")

				-- Kick
				m("C08", nil, "#showtooltip Kick\n/stopcasting\n/stopcasting\n/use Kick")

				-- Cold Blood and Blade Rush
				m("C09", nil, "#showtooltip Blade Rush\n/use Cold Blood\n/use Blade Rush")

				-- Tricks of the Trade
				m("C13", nil, "#showtooltip Tricks of the Trade\n/use [@focus,help][help][]Tricks of the Trade")
				
				
				------ Left ------
				-- Top
				spell("N", "Thistle Tea")
				spell("SN", "Shadow Dance")
				spell("R", "Marked for Death")
				spell("SR", "Shiv")
				spell("CR", "Keep it Rolling")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				if known("Audacity") then spell("C", "Ambush") else empty("C") end
				if known("Blade Rush") and known("Cold Blood") then macro("SC", "C09") elseif known("Cold Blood") then spell("SC", "Cold Blood") else spell("SC", "Blade Rush") end
				spell("Q", "Blade Flurry")
				if known("Sepsis") then spell("E", "Sepsis") else spell("E", "Ghostly Strike") end
				spell("G", "Adrenaline Rush")
				if known("Killing Spree") then spell("SG", "Killing Spree") else spell("SG", "Dreadblades") end
				macro("SE", "C08", "Kick")

				-- Bottom
				macro("1", "C01")
				macro("2", "C02", "Pistol Shot")
				spell("3", "Eviscerate")
				spell("4", "Slice and Dice")
				spell("5", "Between the Eyes")
				spell("6", "Echoing Reprimand")
				spell("V", "Roll the Bones")
				spell("CE", "Kidney Shot")

				------ Right ------
				-- Top
				spell("AB3", "Distract")
				spell("AF", "Shroud of Concealment")
				spell("CF", "Grappling Hook")
				spell("SF", "Shadowstep")
				spell("F", "Sprint")

				-- Middle
				spell("T", "Sap")
				spell("ST", "Blind")
				spell("CT", "Cheap Shot")
				spell("AT", "Gouge")
				empty("CB3")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07", "Stealth")
				spell("CV", "Vanish")

				-- Bottom
				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				empty("F4")
				empty("F5")
				empty("F6")
				macro("CQ", "C13", "Tricks of the Trade")

			elseif spec == 3 then
				--! Subtlety Rogue
				
				------ Macros ------

				-- Ambush and Cold Blood / Sinister Strike
				m("C01", nil, "#showtooltip [stance:1/2]Ambush;Sinister Strike\n"..(known("Cold Blood") and "/use [stance:1/2]Cold Blood\n" or "").."/use [stance:1/2]Ambush;Sinister Strike")

				-- Eviscerate / Black Powder
				m("C03", nil, "#showtooltip\n/use [mod:shift]Black Powder;Eviscerate")

				-- Stealth
				m("C07", nil, "#showtooltip Stealth\n/cancelaura [btn:2]Stealth;[nocombat]Shadow Dance\n/use [nobtn:2]!Stealth")

				-- Kick
				m("C08", nil, "#showtooltip Kick\n/stopcasting\n/stopcasting\n/use Kick")

				-- Symbols of Death, Cold Blood, Shadow Dance
				m("C09", nil, "#showtooltip\n"..(known("Symbols of Death") and "/use Symbols of Death\n" or "")..(known("Cold Blood") and "/use Cold Blood\n" or "").."/use [nostance:1,nostance:2]Shadow Dance")

				-- Tricks of the Trade
				m("C13", nil, "#showtooltip Tricks of the Trade\n/use [@focus,help][help][]Tricks of the Trade")
				
				
				------ Left ------
				-- Top
				spell("N", "Thistle Tea")
				if not known("Symbols of Death") then empty("SN") else spell("SN", "Shadow Dance") end
				spell("R", "Marked for Death")
				spell("SR", "Shiv")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Shuriken Toss")
				spell("SC", "Shuriken Tornado")
				spell("Q", "Shuriken Storm")
				spell("E", "Sepsis")
				spell("G", "Shadow Blades")
				spell("SG", "Flagellation")
				macro("SE", "C08", "Kick")

				-- Bottom
				macro("1", "C01")
				spell("2", "Rupture")
				if known("Black Powder") then macro("3", "C03") else spell("3", "Eviscerate") end
				spell("4", "Slice and Dice")
				empty("5", "Secret Technique")
				spell("6", "Echoing Reprimand")
				macro("V", "C09", "Shadow Dance")
				spell("CE", "Kidney Shot")

				------ Right ------
				-- Top
				spell("AB3", "Distract")
				spell("AF", "Shroud of Concealment")
				empty("CF")
				spell("SF", "Shadowstep")
				spell("F", "Sprint")

				-- Middle
				spell("T", "Sap")
				spell("ST", "Blind")
				spell("CT", "Cheap Shot")
				spell("AT", "Gouge")
				empty("CB3")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07", "Stealth")
				spell("CV", "Vanish")

				-- Bottom
				spell("F1", "Feint")
				spell("F2", "Cloak of Shadows")
				spell("F3", "Evasion")
				empty("F4")
				empty("F5")
				empty("F6")
				macro("CQ", "C13", "Tricks of the Trade")

			else
				--! Unspecialized Rogue

				------ Macros ------

				-- Ambush / Sinister Strike
				m("C01", nil, "#showtooltip\n/use [stance:1/2]Ambush;Sinister Strike")

				-- Stealth
				m("C07", nil, "#showtooltip Stealth\n/cancelaura [btn:2]Stealth;[nocombat]Shadow Dance\n/use [nobtn:2]!Stealth")

				-- Kick
				m("C08", nil, "#showtooltip Kick\n/stopcasting\n/stopcasting\n/use Kick")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				empty("E")
				empty("G")
				empty("SG")
				macro("SE", "C08", "Kick")

				-- Bottom
				if known("Ambush") then macro("1", "C01") else spell("1", "Sinister Strike") end
				empty("2")
				spell("3", "Eviscerate")
				spell("4", "Slice and Dice")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Sprint")

				-- Middle
				empty("T")
				empty("ST")
				spell("CT", "Cheap Shot")
				empty("AT")
				empty("CB3")
				spell("SQ", "Crimson Vial")
				macro("SV", "C07", "Stealth")
				empty("CV")

				-- Bottom
				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "SHAMAN" then
			--! Shaman

			if spec == 1 then
				--! Elemental Shaman

				------ Macros ------

				-- Lightning Bolt / Healing Surge
				m("C01", nil, "#showtooltip\n/use [help]Healing Surge;Lightning Bolt")

				-- Chain Lightning / Chain Heal
				m("C03", nil, "#showtooltip\n/use [help]Chain Heal;Chain Lightning")

				-- Wind Shear
				m("C08", nil, "#showtooltip Wind Shear\n/stopcasting\n/stopcasting\n/use Wind Shear")

				if known("Storm Elemental") then
					-- Storm Elemental
					m("C09", known("Primal Elementalist") and 462522 or nil, "#showtooltip\n/use Storm Elemental\n/petassist\n/petattack\n/petattack")
				else
					-- Fire Elemental
					m("C09", known("Primal Elementalist") and 651081 or nil, "#showtooltip\n/use Fire Elemental\n/petassist\n/petattack\n/petattack")
				end

				-- Meteor or Tempest
				m("C10", nil, "#showtooltip\n/use [pet:Fire Elemental]Meteor;[pet:Storm Elemental]Tempest")

				-- Ancestral Guidance / Mana Spring Totem
				m("C14", nil, "#showtooltip\n/use [mod:shift]Mana Spring Totem;Ancestral Guidance")

				
				------ Left ------
				-- Top
				spell("N", "Primordial Wave")
				spell("SN", "Nature's Swiftness")
				spell("R", "Totemic Projection")
				if known("Greater Purge") then spell("SR", "Greater Purge") else spell("SR", "Purge") end
				spell("CR", "Cleanse Spirit")
				spell("H", "Earth Shield")
				spell("SH", "Poison Cleansing Totem")
				racial("AE")

				-- Middle
				spell("C", "Frost Shock")
				if known("Primal Elementalist") then macro("SC", "C10") else spell("SC", "Liquid Magma Totem") end
				spell("Q", "Earthquake")
				spell("E", "Flame Shock")
				spell("G", "Ascendance")
				empty("SG")
				macro("SE", "C08", "Wind Shear")

				-- Bottom
				macro("1", "C01")
				if known("Healing Wave") and known("Lava Burst") then macro("2", "C02") elseif known("Lava Burst") then spell("2", "Lava Burst") else spell("2", "Healing Wave") end
				if known("Chain Heal") and known("Chain Lightning") then macro("3", "C03") elseif known("Chain Lightning") then spell("3", "Chain Lightning") else spell("3", "Chain Heal") end
				spell("4", "Earth Shock")
				spell("5", "Icefury")
				spell("6", "Stormkeeper")
				if known("Fire Elemental") or known("Storm Elemental") then macro("V", "C09") else empty("V") end
				spell("CE", "Capacitor Totem")

				------ Right ------
				-- Top
				if known("Wind Rush Totem") then spell("AB3", "Wind Rush Totem") else spell("AB3", "Earthgrab Totem") end
				empty("AF")
				spell("CF", "Spiritwalker's Grace")
				if known("Spirit Walk") then spell("SF", "Spirit Walk") else spell("SF", "Gust of Wind") end
				spell("F", "Ghost Wolf")

				-- Middle
				if known("Hex") then spell("T", "Hex") else empty("T") end
				spell("ST", "Earthbind Totem")
				spell("CT", "Lightning Lasso")
				empty("AT")
				spell("CB3", "Thunderstorm")
				spell("SQ", "Healing Surge")
				empty("SV")
				spell("CV", "Tremor Totem")

				-- Bottom
				spell("F1", "Astral Shift")
				spell("F2", "Earth Elemental")
				spell("F3", "Healing Stream Totem")
				if known("Ancestral Guidance") and known("Mana Spring Totem") then macro("F4", "C14") elseif known("Mana Spring Totem") then spell("F4", "Mana Spring Totem") else spell("F4", "Ancestral Guidance") end
				if known("Stoneskin Totem") then spell("F5", "Stoneskin Totem") else spell("F5", "Tranquil Air Totem") end
				spell("F6", "Totemic Recall")
				spell("CQ", "Water Walking")

			elseif spec == 2 then
				--! Enhancement Shaman

				------ Macros ------

				-- Stormstrike / Healing Surge
				m("C01", nil, "#showtooltip\n/use [help]Healing Surge;Primal Strike")

				-- Crash Lightning / Chain Heal
				m("C03", nil, "#showtooltip\n/use [help]Chain Heal;Crash Lightning")

				-- Lightning Bolt / Chain Lightning
				m("C05", nil, "#showtooltip\n/use [mod:shift]Chain Lightning;Lightning Bolt")

				-- Wind Shear
				m("C08", nil, "#showtooltip Wind Shear\n/stopcasting\n/stopcasting\n/use Wind Shear")

				-- Ancestral Guidance / Mana Spring Totem
				m("C14", nil, "#showtooltip\n/use [mod:shift]Mana Spring Totem;Ancestral Guidance")

				
				------ Left ------
				-- Top
				spell("N", "Primordial Wave")
				spell("SN", "Nature's Swiftness")
				spell("R", "Totemic Projection")
				if known("Greater Purge") then spell("SR", "Greater Purge") else spell("SR", "Purge") end
				spell("CR", "Cleanse Spirit")
				spell("H", "Earth Shield")
				spell("SH", "Poison Cleansing Totem")
				racial("AE")

				-- Middle
				spell("C", "Frost Shock")
				spell("SC", "Sundering")
				spell("Q", "Fire Nova")
				spell("E", "Flame Shock")
				spell("G", "Ascendance")
				spell("SG", "Doom Winds")
				macro("SE", "C08", "Wind Shear")

				-- Bottom
				spell("1", "Primal Strike")
				spell("2", "Lava Lash")
				spell("3", "Crash Lightning")
				if known("Lava Burst") then spell("4", "Lava Burst") elseif known("Elemental Blast") then spell("4", "Elemental Blast") else spell("4", "Lightning Bolt") end
				if known("Lava Burst") or known("Elemental Blast") then macro("5", "C05") else spell("5", "Chain Lightning") end
				spell("6", "Ice Strike")
				spell("V", "Feral Spirit")
				spell("CE", "Capacitor Totem")

				------ Right ------
				-- Top
				if known("Wind Rush Totem") then spell("AB3", "Wind Rush Totem") else spell("AB3", "Earthgrab Totem") end
				spell("AF", "Spiritwalker's Grace")
				spell("CF", "Feral Lunge")
				if known("Spirit Walk") then spell("SF", "Spirit Walk") else spell("SF", "Gust of Wind") end
				spell("F", "Ghost Wolf")

				-- Middle
				if known("Hex") then spell("T", "Hex") else empty("T") end
				spell("ST", "Earthbind Totem")
				spell("CT", "Lightning Lasso")
				empty("AT")
				spell("CB3", "Thunderstorm")
				spell("SQ", "Healing Surge")
				spell("SV", "Windfury Totem")
				spell("CV", "Tremor Totem")

				-- Bottom
				spell("F1", "Astral Shift")
				spell("F2", "Earth Elemental")
				spell("F3", "Healing Stream Totem")
				if known("Ancestral Guidance") and known("Mana Spring Totem") then macro("F4", "C14") elseif known("Mana Spring Totem") then spell("F4", "Mana Spring Totem") else spell("F4", "Ancestral Guidance") end
				if known("Stoneskin Totem") then spell("F5", "Stoneskin Totem") else spell("F5", "Tranquil Air Totem") end
				spell("F6", "Totemic Recall")
				spell("CQ", "Water Walking")

			elseif spec == 3 then
				--! Restoration Shaman

				------ Macros ------

				-- Healing Surge / Lightning Bolt
				m("C01", nil, "#showtooltip\n/use [harm]Lightning Bolt;Healing Surge")

				-- Healing Wave / Lava Burst
				m("C02", nil, "#showtooltip\n/use [harm]Lava Burst;Healing Wave")

				-- Chain Heal / Chain Lightning
				m("C03", nil, "#showtooltip\n/use [harm]Chain Lightning;Chain Heal")

				-- Ever-Rising Tide / Stormkeeper
				m("C06", nil, "#showtooltip\n/use [harm]Stormkeeper;Ever-Rising Tide")

				-- Riptide / Flame Shock
				m("C07", nil, "#showtooltip\n/use [harm]Flame Shock;Riptide")

				-- Wind Shear
				m("C08", nil, "#showtooltip Wind Shear\n/stopcasting\n/stopcasting\n/use Wind Shear")

				-- Unleash Life / Frost Shock
				m("C09", nil, "#showtooltip\n/use [harm]Frost Shock;Unleash Life")

				-- Mana Tide Totem / Mana Spring Totem
				m("C14", nil, "#showtooltip\n/use [mod:shift]Mana Spring Totem;Mana Tide Totem")

				
				------ Left ------
				-- Top
				spell("N", "Primordial Wave")
				spell("SN", "Nature's Swiftness")
				spell("R", "Totemic Projection")
				if known("Greater Purge") then spell("SR", "Greater Purge") else spell("SR", "Purge") end
				spell("CR", "Purify Spirit")
				spell("H", "Earth Shield")
				spell("SH", "Poison Cleansing Totem")
				racial("AE")

				-- Middle
				if known("Unleash Life") and known("Frost Shock") then macro("C", "C09") elseif known("Frost Shock") then spell("C", "Frost Shock") else spell("C", "Unleash Life") end
				spell("SC", "Wellspring")
				spell("Q", "Downpour")
				if known("Riptide") then macro("E", "C07") else spell("E", "Flame Shock") end
				spell("G", "Spirit Link Totem")
				spell("SG", "Ancestral Guidance")
				macro("SE", "C08", "Wind Shear")

				-- Bottom
				macro("1", "C01")
				if known("Healing Wave") and known("Lava Burst") then macro("2", "C02") elseif known("Lava Burst") then spell("2", "Lava Burst") else spell("2", "Healing Wave") end
				if known("Chain Heal") and known("Chain Lightning") then macro("3", "C03") elseif known("Chain Lightning") then spell("3", "Chain Lightning") else spell("3", "Chain Heal") end
				spell("4", "Healing Rain")
				spell("5", "Healing Stream Totem")
				if known("Ever-Rising Tide") and known("Stormkeeper") then macro("6", "C06") elseif known("Stormkeeper") then spell("6", "Stormkeeper") else spell("6", "Ever-Rising Tide") end
				spell("V", "Ascendance")
				spell("CE", "Capacitor Totem")

				------ Right ------
				-- Top
				if known("Wind Rush Totem") then spell("AB3", "Wind Rush Totem") else spell("AB3", "Earthgrab Totem") end
				empty("AF")
				spell("CF", "Spiritwalker's Grace")
				if known("Spirit Walk") then spell("SF", "Spirit Walk") else spell("SF", "Gust of Wind") end
				spell("F", "Ghost Wolf")

				-- Middle
				if known("Hex") then spell("T", "Hex") else empty("T") end
				spell("ST", "Earthbind Totem")
				spell("CT", "Lightning Lasso")
				empty("AT")
				spell("CB3", "Thunderstorm")
				spell("SQ", "Healing Surge")
				if known("Earthen Wall Totem") then spell("SV", "Earthen Wall Totem") else spell("SV", "Ancestral Protection Totem") end
				spell("CV", "Tremor Totem")

				-- Bottom
				spell("F1", "Astral Shift")
				spell("F2", "Earth Elemental")
				spell("F3", "Healing Tide Totem")
				if known("Mana Tide Totem") and known("Mana Spring Totem") then macro("F4", "C14") elseif known("Mana Spring Totem") then spell("F4", "Mana Spring Totem") else spell("F4", "Mana Tide Totem") end
				if known("Stoneskin Totem") then spell("F5", "Stoneskin Totem") else spell("F5", "Tranquil Air Totem") end
				spell("F6", "Totemic Recall")
				spell("CQ", "Water Walking")

			else
				--! Unspecialized Shaman

				------ Macros ------

				-- Lightning Bolt / Healing Surge
				m("C01", nil, "#showtooltip\n/use [help]Healing Surge;Lightning Bolt")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				empty("R")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Flame Shock")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				if known("Healing Surge") then macro("1", "C01") else spell("1", "Lightning Bolt") end
				spell("2", "Primal Strike")
				empty("3")
				empty("4")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				spell("F", "Ghost Wolf")

				-- Middle
				empty("T")
				spell("ST", "Earthbind Totem")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Healing Surge")
				empty("SV")
				empty("CV")

				-- Bottom
				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "WARLOCK" then
			--! Warlock

			if spec == 1 then
				--! Affliction Warlock

				------ Macros ------

				-- Shadow Bolt
				m("C01", nil, "#showtooltip Shadow Bolt\n/petattack\n/petassist\n/petattack\n/use Shadow Bolt")

				-- Pet Primary
				m("C07", nil, "#showtooltip\n/use [pet:Felhunter/Observer]Spell Lock;[pet:Succubus/Incubus/Shivarra]Seduction;[pet:Voidwalker/Voidlord,nobtn:2]Suffering;[nobtn:2]Command Demon\n/petautocasttoggle [btn:2]Suffering")
				
				-- Pet Secondary
				m("C08", nil, "#showtooltip\n/use [pet:Felhunter/Observer]Devour Magic;[pet:Imp/Fel Imp]Flee;[pet:Succubus/Incubus/Shivarra]Lesser Invisibility;[pet:Voidwalker/Voidlord]Shadow Bulwark;Command Demon")

				
				------ Left ------
				-- Top
				spell("N", "Soul Rot")
				spell("SN", "Amplify Curse")
				spell("R", "Curse of Weakness")
				spell("SR", "Curse of Exhaustion")
				spell("CR", "Curse of Tongues")
				spell("H", "Health Funnel")
				empty("SH")
				racial("AE")

				-- Middle
				macro("C", "C01") -- Shadow Bolt
				spell("SC", "Soul Swap")
				if known("Phantom Singularity") then spell("Q", "Phantom Singularity") else spell("Q", "Vile Taint") end
				spell("E", "Seed of Corruption")
				spell("G", "Summon Darkglare")
				spell("SG", "Summon Soulkeeper")
				macro("SE", "C07")

				-- Bottom
				spell("1", "Corruption")
				spell("2", "Agony")
				spell("3", "Siphon Life")
				spell("4", "Unstable Affliction")
				spell("5", "Malefic Rapture")
				spell("6", "Haunt")
				macro("V", "C08")
				spell("CE", "Shadowfury")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				spell("CF", "Demonic Gateway")
				spell("SF", "Soulburn")
				spell("F", "Burning Rush")

				-- Middle
				spell("T", "Fear")
				spell("ST", "Banish")
				if known("Howl of Terror") then spell("CT", "Howl of Terror") else spell("CT", "Mortal Coil") end
				spell("AT", "Subjugate Demon")
				spell("CB3", "Shadowflame")
				spell("SQ", "Drain Life")
				spell("SV", "Demonic Circle")
				spell("CV", "Demonic Circle: Teleport")

				-- Bottom
				spell("F1", "Unending Resolve")
				spell("F2", "Dark Pact")
				spell("F3", "Soul Tap")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Unending Breath")

			elseif spec == 2 then
				--! Demonology Warlock

				------ Macros ------

				-- Shadow Bolt
				m("C01", nil, "#showtooltip Shadow Bolt\n/petattack\n/petassist\n/petattack\n/use Shadow Bolt")

				-- Pet Primary
				m("C07", nil, "#showtooltip\n/use [pet:Felguard/Wrathguard]Axe Toss;[pet:Felhunter/Observer]Spell Lock;[pet:Succubus/Incubus/Shivarra]Seduction;[pet:Voidwalker/Voidlord,nobtn:2]Suffering;[nobtn:2]Command Demon\n/petautocasttoggle [btn:2]Suffering")
				
				-- Pet Secondary
				m("C08", nil, "/use [pet:Felguard/Wrathguard,nobtn:2]Felstorm;[pet:Felhunter/Observer]Devour Magic;[pet:Imp/Fel Imp]Flee;[pet:Succubus/Incubus/Shivarra]Lesser Invisibility;[pet:Voidwalker/Voidlord]Shadow Bulwark;Command Demon\n/petautocasttoggle [btn:2]Felstorm")

				
				------ Left ------
				-- Top
				spell("N", "Nether Portal")
				spell("SN", "Amplify Curse")
				spell("R", "Curse of Weakness")
				spell("SR", "Curse of Exhaustion")
				spell("CR", "Curse of Tongues")
				spell("H", "Health Funnel")
				spell("SH", "Doom")
				racial("AE")

				-- Middle
				if known("Summon Vilefiend") then spell("C", "Summon Vilefiend") else spell("C", "Soul Strike") end
				spell("SC", "Guillotine")
				spell("Q", "Implosion")
				spell("E", "Power Siphon")
				spell("G", "Summon Demonic Tyrant")
				spell("SG", "Summon Soulkeeper")
				macro("SE", "C07", "Command Demon")

				-- Bottom
				macro("1", "C01")
				spell("2", "Demonbolt")
				spell("3", "Call Dreadstalkers")
				spell("4", "Hand of Gul'dan")
				if known("Bilescourge Bombers") then spell("5", "Bilescourge Bombers") else spell("5", "Demonic Strength") end
				spell("6", "Grimoire: Felguard")
				macro("V", "C08")
				spell("CE", "Shadowfury")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				spell("CF", "Demonic Gateway")
				spell("SF", "Soulburn")
				spell("F", "Burning Rush")

				-- Middle
				spell("T", "Fear")
				spell("ST", "Banish")
				if known("Howl of Terror") then spell("CT", "Howl of Terror") else spell("CT", "Mortal Coil") end
				spell("AT", "Subjugate Demon")
				spell("CB3", "Shadowflame")
				spell("SQ", "Drain Life")
				spell("SV", "Demonic Circle")
				spell("CV", "Demonic Circle: Teleport")

				-- Bottom
				spell("F1", "Unending Resolve")
				spell("F2", "Dark Pact")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Unending Breath")

			elseif spec == 3 then
				--! Destruction Warlock

				------ Macros ------

				-- Shadow Bolt
				m("C02", nil, "#showtooltip Shadow Bolt\n/petattack\n/petassist\n/petattack\n/use Shadow Bolt")

				-- Pet Primary
				m("C07", nil, "#showtooltip\n/use [pet:Felhunter/Observer]Spell Lock;[pet:Succubus/Incubus/Shivarra]Seduction;[pet:Voidwalker/Voidlord,nobtn:2]Suffering;[nobtn:2]Command Demon\n/petautocasttoggle [btn:2]Suffering")
				
				-- Pet Secondary
				m("C08", nil, "#showtooltip\n/use [pet:Felhunter/Observer]Devour Magic;[pet:Imp/Fel Imp]Flee;[pet:Succubus/Incubus/Shivarra]Lesser Invisibility;[pet:Voidwalker/Voidlord]Shadow Bulwark;Command Demon")
				

				------ Left ------
				-- Top
				spell("N", "Soul Fire")
				spell("SN", "Amplify Curse")
				spell("R", "Curse of Weakness")
				spell("SR", "Curse of Exhaustion")
				spell("CR", "Curse of Tongues")
				spell("H", "Health Funnel")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Shadowburn")
				spell("SC", "Channel Demonfire")
				spell("Q", "Cataclysm")
				spell("E", "Havoc")
				spell("G", "Summon Infernal")
				spell("SG", "Summon Soulkeeper")
				macro("SE", "C07", "Command Demon")

				-- Bottom
				spell("1", "Corruption")
				macro("2", "C02")
				spell("3", "Conflagrate")
				spell("4", "Chaos Bolt")
				spell("5", "Rain of Fire")
				spell("6", "Dimensional Rift")
				macro("V", "C08", "Command Demon")
				spell("CE", "Shadowfury")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				spell("CF", "Demonic Gateway")
				spell("SF", "Soulburn")
				spell("F", "Burning Rush")

				-- Middle
				spell("T", "Fear")
				spell("ST", "Banish")
				if known("Howl of Terror") then spell("CT", "Howl of Terror") else spell("CT", "Mortal Coil") end
				spell("AT", "Subjugate Demon")
				spell("CB3", "Shadowflame")
				spell("SQ", "Drain Life")
				spell("SV", "Demonic Circle")
				spell("CV", "Demonic Circle: Teleport")

				-- Bottom
				spell("F1", "Unending Resolve")
				spell("F2", "Dark Pact")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				spell("CQ", "Unending Breath")

			else
				--! Unspecialized Warlock

				------ Macros ------

				-- Shadow Bolt
				m("C01", nil, "#showtooltip Shadow Bolt\n/petattack\n/petassist\n/petattack\n/use Shadow Bolt")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Curse of Weakness")
				empty("SR")
				empty("CR")
				spell("H", "Health Funnel")
				empty("SH")
				racial("AE")

				-- Middle
				empty("C")
				empty("SC")
				empty("Q")
				spell("E", "Corruption")
				empty("G")
				empty("SG")
				empty("SE")

				-- Bottom
				macro("1", "C01")
				empty("2")
				empty("3")
				empty("4")
				empty("5")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				empty("CF")
				empty("SF")
				empty("F")

				-- Middle
				empty("T")
				spell("ST", "Fear")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Drain Life")
				empty("SV")
				empty("CV")

				-- Bottom
				spell("F1", "Unending Resolve")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		elseif class == "WARRIOR" then
			--! Warrior

			if spec == 1 then
				--! Arms Warrior
				
				------ Macros ------

				-- Mortal Strike / Shield Slam
				m("C01", nil, "#showtooltip\n/use [worn:shield]Shield Slam;"..(known("Mortal Strike") and "Mortal Strike" or "Slam"))

				-- Slam / Whirlwind
				m("C04", nil, "#showtooltip\n/use [mod:shift]Whirlwind;Slam")

				-- Pummel
				m("C08", nil, "#showtooltip Pummel\n/stopcasting\n/stopcasting\n/use Pummel")

				if known("Skullsplitter") then
					-- Skullsplitter / Thunder Clap
					m("C05", nil, "#showtooltip\n/use [mod:shift]Thunder Clap;Skullsplitter")
				else
					-- Blood and Thunder
					m("C05", 460957, "#showtooltip\n/use Thunder Clap")
				end

				-- Battle Stance
				m("C13", nil, "#showtooltip Battle Stance\n/use [nostance:"..(known("Defensive Stance") and "2" or "1").."]!Battle Stance")

				-- Defensive Stance / Shield Block
				m("C14", nil, "#showtooltip [stance:1,worn:shield]Shield Block;Defensive Stance\n/use [stance:1,worn:shield]Shield Block;[nostance:1]!Defensive Stance")
				
				
				------ Left ------
				-- Top
				spell("N", "Spear of Bastion")
				empty("SN")
				spell("R", "Taunt")
				if known("Wrecking Throw") then spell("SR", "Wrecking Throw") else spell("SR", "Shattering Throw") end
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Heroic Throw")
				spell("SC", "Sweeping Strikes")
				spell("Q", "Cleave")
				spell("E", "Rend")
				spell("G", "Colossus Smash")
				spell("SG", "Bladestorm")
				macro("SE", "C08", "Pummel")

				-- Bottom
				macro("1", "C01")
				spell("2", "Overpower")
				spell("3", "Execute")
				if not known("Mortal Strike") then spell("4", "Whirlwind") else macro("4", "C04") end
				if known("Blood and Thunder") then macro("5", "C05") else spell("5", "Skullsplitter") end
				spell("6", "Thunderous Roar")
				spell("V", "Avatar")
				spell("CE", "Storm Bolt")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Intervene")
				spell("CF", "Charge")
				spell("SF", "Berserker Rage")
				spell("F", "Heroic Leap")

				-- Middle
				spell("T", "Intimidating Shout")
				spell("ST", "Hamstring")
				spell("CT", "Shockwave")
				spell("AT", "Piercing Howl")
				empty("CB3")
				spell("SQ", "Victory Rush")
				macro("SV", "C13")
				empty("CV")

				-- Bottom
				spell("F1", "Die by the Sword")
				macro("F2", "C14", "Defensive Stance")
				spell("F3", "Rallying Cry")
				spell("F4", "Bitter Immunity")
				empty("F5")
				empty("F6")
				spell("CQ", "Spell Reflection")

			elseif spec == 2 then
				--! Fury Warrior
				
				------ Macros ------

				-- Raging Blow or Bloodthirst / Shield Slam
				m("C01", nil, "#showtooltip\n/use [worn:shield]Shield Slam;"..((known("Annihilator") or not known("Raging Blow")) and "Bloodthirst" or "Raging Blow"))

				-- Pummel
				m("C08", nil, "#showtooltip Pummel\n/stopcasting\n/stopcasting\n/use Pummel")

				-- Berserker Stance
				m("C13", nil, "#showtooltip Berserker Stance\n/use [nostance:"..(known("Defensive Stance") and "2" or "1").."]!Berserker Stance")

				-- Defensive Stance / Shield Block
				m("C14", nil, "#showtooltip [stance:1,worn:shield]Shield Block;Defensive Stance\n/use [stance:1,worn:shield]Shield Block;[nostance:1]!Defensive Stance")
				
				
				------ Left ------
				-- Top
				spell("N", "Spear of Bastion")
				empty("SN")
				spell("R", "Taunt")
				if known("Wrecking Throw") then spell("SR", "Wrecking Throw") else spell("SR", "Shattering Throw") end
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Heroic Throw")
				empty("SC")
				spell("Q", "Whirlwind")
				spell("E", "Onslaught")
				spell("G", "Recklessness")
				spell("SG", "Ravager")
				macro("SE", "C08", "Pummel")

				-- Bottom
				if known("Bloodthirst") then macro("1", "C01") else spell("1", "Slam") end
				if known("Annihilator") or (not known("Raging Blow") and known("Bloodthirst")) then spell("2", "Slam") else spell("2", "Bloodthirst") end
				spell("3", "Execute")
				spell("4", "Rampage")
				spell("5", "Odyn's Fury")
				spell("6", "Thunderous Roar")
				spell("V", "Avatar")
				spell("CE", "Storm Bolt")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Intervene")
				spell("CF", "Charge")
				spell("SF", "Berserker Rage")
				spell("F", "Heroic Leap")

				-- Middle
				spell("T", "Intimidating Shout")
				spell("ST", "Hamstring")
				spell("CT", "Shockwave")
				spell("AT", "Piercing Howl")
				empty("CB3")
				spell("SQ", "Victory Rush")
				macro("SV", "C13")
				empty("CV")

				-- Bottom
				spell("F1", "Enraged Regeneration")
				macro("F2", "C14", "Defensive Stance")
				spell("F3", "Rallying Cry")
				spell("F4", "Bitter Immunity")
				empty("F5")
				empty("F6")
				spell("CQ", "Spell Reflection")

			elseif spec == 3 then
				--! Protection Warrior
				
				------ Macros ------

				-- Shield Slam / Slam
				m("C01", nil, "#showtooltip\n/use [noworn:shield]Slam;Shield Slam")

				-- Pummel
				m("C08", nil, "#showtooltip Pummel\n/stopcasting\n/stopcasting\n/use Pummel")

				-- Challenging Shout
				m("C09", 4067374, "#showtooltip\n/use Challenging Shout")

				-- Defensive Stance
				m("C13", nil, "#showtooltip Defensive Stance\n/use [nostance:1]!Defensive Stance")

				if known("Battle Stance") then
					-- Battle Stance
					m("C14", nil, "#showtooltip Battle Stance\n/use [nostance:2]!Battle Stance")
				else
					-- Cancel Defensive Stance
					m("C14", 132349, "/cancelaura Defensive Stance")
				end
				
				
				------ Left ------
				-- Top
				spell("N", "Spear of Bastion")
				empty("SN")
				spell("R", "Taunt")
				if known("Wrecking Throw") then spell("SR", "Wrecking Throw") else spell("SR", "Shattering Throw") end
				macro("CR", "C09", "Challenging Shout")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Heroic Throw")
				empty("SC")
				spell("Q", "Ignore Pain")
				if known("Blood and Thunder") then empty("E") else spell("E", "Rend") end
				spell("G", "Shield Charge")
				spell("SG", "Ravager")
				macro("SE", "C08", "Pummel")

				-- Bottom
				macro("1", "C01")
				if not known("Revenge") then spell("2", "Devastate") else spell("2", "Revenge") end
				spell("3", "Execute")
				if not known("Thunder Clap") and not known("Devastator") and known("Revenge") then spell("4", "Devastate") else spell("4", "Thunder Clap") end
				spell("5", "Shield Block")
				spell("6", "Thunderous Roar")
				spell("V", "Avatar")
				spell("CE", "Storm Bolt")

				------ Right ------
				-- Top
				empty("AB3")
				spell("AF", "Intervene")
				spell("CF", "Charge")
				spell("SF", "Berserker Rage")
				spell("F", "Heroic Leap")

				-- Middle
				spell("T", "Intimidating Shout")
				spell("ST", "Hamstring")
				spell("CT", "Shockwave")
				spell("AT", "Piercing Howl")
				empty("CB3")
				spell("SQ", "Victory Rush")
				macro("SV", "C13")
				macro("CV", "C14")

				-- Bottom
				spell("F1", "Demoralizing Shout")
				spell("F2", "Last Stand")
				spell("F3", "Rallying Cry")
				spell("F4", "Shield Wall")
				spell("F5", "Spell Block")
				spell("F6", "Bitter Immunity")
				spell("CQ", "Spell Reflection")

			else
				--! Unspecialized Warrior
				
				------ Macros ------

				-- Pummel
				m("C08", nil, "#showtooltip Pummel\n/stopcasting\n/stopcasting\n/use Pummel")

				
				------ Left ------
				-- Top
				empty("N")
				empty("SN")
				spell("R", "Taunt")
				empty("SR")
				empty("CR")
				empty("H")
				empty("SH")
				racial("AE")

				-- Middle
				spell("C", "Heroic Throw")
				empty("SC")
				spell("Q", "Whirlwind")
				empty("E")
				empty("G")
				empty("SG")
				macro("SE", "C08", "Pummel")

				-- Bottom
				if known("Shield Slam") then spell("1", "Shield Slam") else spell("1", "Slam") end
				if known("Shield Slam") then spell("2", "Slam") else empty("2") end
				spell("3", "Execute")
				empty("4")
				spell("5", "Shield Block")
				empty("6")
				empty("V")
				empty("CE")

				------ Right ------
				-- Top
				empty("AB3")
				empty("AF")
				spell("CF", "Charge")
				empty("SF")
				empty("F")

				-- Middle
				empty("T")
				spell("ST", "Hamstring")
				empty("CT")
				empty("AT")
				empty("CB3")
				spell("SQ", "Victory Rush")
				empty("SV")
				empty("CV")

				-- Bottom
				empty("F1")
				empty("F2")
				empty("F3")
				empty("F4")
				empty("F5")
				empty("F6")
				empty("CQ")

			end
		end
		
		--! Dynamic Buttons
		empty("CG") -- Potion
		empty("C CG") -- Potion
		empty("B CG") -- Potion
		empty("J") -- PvP Talent 1
		empty("SJ") -- PvP Talent 2
		empty("CJ") -- PvP Talent 3
		empty("=") -- Nitro Boosts

		--! Dragonriding
		spell("D 1", 372608) -- Surge Forward
		spell("D 2", 372610) -- Skyward Ascent
		spell("D 3", "Whirling Surge")
		empty("D 4")
		spell("D 5", 403092) -- Aerial Halt
		empty("D 6")
		spell("D V", "Bronze Timelock")
		empty("D CE")

		--! Soar
		spell("S 1", 376743) -- Surge Forward
		spell("S 2", 376744) -- Skyward Ascent
		empty("S 3")
		empty("S 4")
		spell("S 5", 403216) -- Aerial Halt
		empty("S 6")
		empty("S V")
		empty("S CE")

	end
end

local function UpdateEquipmentSets()
	local icons = {
		["Timewalking"] = 463446,
		["Speed"] = 965900,
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
		["EVOKER_Augmentation"] = 5198700,
		["EVOKER_Devastation"] = 4511811,
		["EVOKER_Preservation"] = 4511812,
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

	if TalentLoadoutsExGUI and TalentLoadoutsExGUI[class] then
		for s, t in pairs(TalentLoadoutsExGUI[class]) do
			for i, d in pairs(t) do
				local name = d.name or ""
				if strsub(name, 0, 3) == "2H " or strsub(name, 0, 3) == "DW " then
					name = strsub(name, 4)
				end

				if name == "Dungeons" then
					TalentLoadoutsExGUI[class][s][i].icon = 463447
				elseif name == "Timewalking" then
					TalentLoadoutsExGUI[class][s][i].icon = 463446
				elseif name == "Arena" then
					TalentLoadoutsExGUI[class][s][i].icon = 1322720
				elseif name == "Battlegrounds" then
					TalentLoadoutsExGUI[class][s][i].icon = 236352
				elseif name == "Solo" then
					TalentLoadoutsExGUI[class][s][i].icon = 1322721
				end
			end
		end
	end
end

Placer:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" and not loaded then
		-- Delay the first load
		C_Timer.After(0.5, function()
			loaded = true
			UpdateBars(event)
		end)
	end

	if loaded then
		if event == "PLAYER_REGEN_ENABLED" then
			Placer:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end

		if not locked then
			locked = true

			C_Timer.After(0.5, function()
				locked = false
				UpdateBars(event)
			end)
		end
	end
end)

SLASH_PLACER1 = "/placer"
function SlashCmdList.PLACER(msg, editbox)
	if msg == "clear" then
		for i = 1, 120 do
			PickupAction(i)
			ClearCursor()
		end
	elseif msg == "debug" then
		for i = 1, 1000000 do
			if IsSpellKnown(i) then
				local name, rank, icon, castTime, minRange, maxRange, spellID = GetSpellInfo(i)
				print(i, name)
				-- 376280 /use Hunting Cmpanion
				-- 384522 /use Blessing of Ohn'ara
			end
		end
	else
		UpdateBars("SLASH_PLACER")
		UpdateEquipmentSets()
	end
end