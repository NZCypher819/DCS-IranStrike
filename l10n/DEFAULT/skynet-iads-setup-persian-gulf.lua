do
--create an instance of the IADS
redIADS = SkynetIADS:create('IRAN')

--add all units with unit name beginning with 'EW' to the IADS:
redIADS:addEarlyWarningRadarsByPrefix('EW')

--add all groups begining with group name 'SAM' to the IADS:
redIADS:addSAMSitesByPrefix('SAM')


--add a command center:
commandCenter = StaticObject.getByName('Command-Center')
redIADS:addCommandCenter(commandCenter)
commandCenter2 = StaticObject.getByName('Command-Center2')
redIADS:addCommandCenter(commandCenter2)

--activate the radio menu to toggle IADS Status output
redIADS:addRadioMenu()

-- activate the IADS
redIADS:activate()	

-- ========= Moose A2A Section =========
-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
DetectionSetGroup = SET_GROUP:New()

-- add the MOOSE SET_GROUP to the Skynet IADS, from now on Skynet will update active radars that the MOOSE SET_GROUP can use for EW detection.
redIADS:addMooseSetGroup(DetectionSetGroup)

-- Setup the detection and group targets to a 30km range!
Detection = DETECTION_AREAS:New( DetectionSetGroup, 80000 )

-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )

-- Set 100km as the radius to engage any target by airborne friendlies.
A2ADispatcher:SetEngageRadius(200000) -- 100000 is the default value.

-- Set 200km as the radius to ground control intercept.
A2ADispatcher:SetGciRadius(300000) -- 200000 is the default value.

-- ========= SET RUSSIAN BORDER =========
CCCPBorderZone = ZONE_POLYGON:New( "RED-BORDER", GROUP:FindByName( "RED-BORDER" ) )
A2ADispatcher:SetBorderZone( CCCPBorderZone )


-- ========= SETUP Squadrons =========
A2ADispatcher:SetSquadron( "Kerman", AIRBASE.PersianGulf.Kerman_Airport, { "Kerman-SU27-01", "Kerman-Mg29s-01", "Kerman-Mg21-01"}, 60 )
A2ADispatcher:SetSquadron( "Shiraz", AIRBASE.PersianGulf.Shiraz_International_Airport, { "Base-Shiraz-Su27", "Base-Shiraz-Mg29-1", "Base-Shiraz-Mg21", "Base-Shiraz-MG21-CAP" }, 60 )

A2ADispatcher:SetSquadronGrouping( "Kerman", 2 )
A2ADispatcher:SetSquadronGrouping( "Shiraz", 2 )

A2ADispatcher:SetSquadronGci( "Kerman", 500, 1200 )
A2ADispatcher:SetSquadronGci( "Shiraz", 700, 1200 )

A2ADispatcher:SetSquadronOverhead( "Kerman", 2)
A2ADispatcher:SetSquadronOverhead( "Shiraz", 2)

A2ADispatcher:SetSquadronTakeoffInAir( "Kerman")
A2ADispatcher:SetSquadronTakeoffInAir( "Shiraz")

A2ADispatcher:SetSquadronLanding( "Kerman", AI_A2A_DISPATCHER.Landing.AtRunway )
A2ADispatcher:SetSquadronLanding( "Shiraz", AI_A2A_DISPATCHER.Landing.AtRunway )

-- ========= SET CAP Squadrons ========= 
--Set a grouping by default per 2 airplanes.
A2ADispatcher:SetDefaultGrouping( 2 )

--Set CAP Zones. By Trigger Zone
CAPBunkerZone = ZONE:New( "CAPBunker01" )
CAPZoneEast = ZONE:New( "CAPZoneEast" )

A2ADispatcher:SetSquadronCap( "Shiraz", CAPBunkerZone, 4000, 40000, 300, 800, 350, 1100, "BARO" )
A2ADispatcher:SetSquadronCap( "Kerman", CAPZoneEast, 4000, 40000, 300, 800, 350, 1100, "BARO" )

A2ADispatcher:SetSquadronCapInterval( "Shiraz", 1, 15, 180 )
A2ADispatcher:SetSquadronCapInterval( "Kerman", 1, 5, 120 )

--Display the squadrons on the tarmac. Turned off (by commenting) as they spawn in the air now.
--A2ADispatcher:SetSquadronVisible( "Kerman" )
--A2ADispatcher:SetSquadronVisible( "Shiraz" )

A2ADispatcher:SetSquadronFuelThreshold( "Shiraz", 0.30 ) -- Go RTB when only 20% of fuel remaining in the tank.
A2ADispatcher:SetSquadronFuelThreshold( "Kerman", 0.20 )
A2ADispatcher:SetSquadronTanker( "SquadronName", "RedTanker" )
A2ADispatcher:SetSquadronTanker( "SquadronName", "RedTanker" )

-- ========= START A2A Dispatcher =========
-- Set Tactical Display for A2A Dispatcher. This effectivily tells you what the dispatcher is up to. 
A2ADispatcher:SetTacticalDisplay(true)
A2ADispatcher:Start()

--test to see which groups are added and removed to the SET_GROUP at runtime by Skynet. This pops up in DCS.log
--function outputNames()
--	env.info("IADS Radar Groups added by Skynet:")
--	env.info(DetectionSetGroup:GetObjectNames())
--end
--mist.scheduleFunction(outputNames, self, 1, 2)
--end test
end


--============================== ZONE COMMANDER =================================
function merge(tbls)
	local res = {}
	for i,v in ipairs(tbls) do
		for i2,v2 in ipairs(v) do
			table.insert(res,v2)
		end
	end
	
	return res
end

function allExcept(tbls, except)
	local tomerge = {}
	for i,v in pairs(tbls) do
		if i~=except then
			table.insert(tomerge, v)
		end
	end
	return merge(tomerge)
end

-- upgrades might be old code....
upgrades = {
	ships = {
		blue = {'blueShip','blueShip','blueShip'},
		red = {'redShipS','redShipS','redShipM','redShipM','redShipL','redShipL'}
	},
	
}

carrier = {
	blue = { "bShip","bShip"},
	red = {}
}

airfield = {
	blue = { "bInfantry", "bArmor", "bSam", "bSam2", "bSam3"},
	red = {"rInfantry", "rArmor", "rSam", "rSam2", "rSam3" }
}

farp = {
	blue = {"bInfantry", "bArmor", "bSam"},
	red = {"rInfantry", "rArmor", "rSam" }
}

regularzone = {
	blue = {"bInfantry", "bArmor", "bSamIR"},
	red = {"rInfantry", "rArmor", "rSamIR" }
}

specialSAM = {
	blue = {"bInfantry", "bSamIR","bInfantry", "bInfantry", "bSamBig" },
	red = {"rInfantry", "rSamIR", "rInfantry", "rInfantry", "rSamBig" }
}

specialKrasnodar = {
	blue = {"bInfantry", "bSamIR","bSam2", "bSam3", "bSamBig", "bSamFinal" },
	red = {"rInfantry", "rSamIR", "rSam2", "rSam3", "rSamBig", "rSamFinal" }
}

convoy = {
	blue = {"bInfantry"},
	red = {"rInfantry", "rInfantry", "rArmor"}
}

cargoSpawns = {
	["Anapa"] = {"c1","c2","c3"},
	["Bravo"] = {"c6","c7"},
	["Krymsk"] = {"c8","c9","c10"},
	["Factory"] = {"c4","c5","c11"},
	["Echo"] = {"c12","c13"}
}

farpSupply = {
	["Bravo"] = {"bravoFuelAndAmmo"},
	["Echo"] = {"echoFuelAndAmmo"}
}

cargoAccepts = {
	anapa = allExcept(cargoSpawns, 'Anapa'),
	bravo =  allExcept(cargoSpawns, 'Bravo'),
	krymsk =  allExcept(cargoSpawns, 'Krymsk'),
	factory =  allExcept(cargoSpawns, 'Factory'),
	echo =  allExcept(cargoSpawns, 'Echo'),
	general = allExcept(cargoSpawns)
}

-- redInfantry, redArmor, redSHORAD, redMERAD, redLORAD, redPD, redSA5, redEWR
-- insInfantry, insArmor, insSHORAD
-- blueInfantry, blueArmor, blueSHORAD, blueMERAD, blueLORAD, bluePD
-- blueShip
-- redShipS, redShipM, redShipL

flavor = {
	kishintl = 'WPT 1\nStart zone',
	hatay = 'WPT 3\n'
}
local filepath = 'U64-IranStrike.0.1.lua'
if lfs then 
	local dir = lfs.writedir()..'Missions/Saves/'
	lfs.mkdir(dir)
	filepath = dir..filepath
	env.info('U64 Iran Strike - Save file path: '..filepath)
end
bc = BattleCommander:new(filepath, 10, 60)
zones = {
	kishintl = ZoneCommander:new({zone='kishintl', side=2, level=1, upgrades=upgrades.minimal, crates={}, flavorText=flavor.kishintl}),
}

zones.incirlik:addGroups({
	GroupCommander:new({name='incirlik-supply-1', mission='supply', targetzone='Hatay'}),
	GroupCommander:new({name='incirlik-supply-2', mission='supply', targetzone='FOB Alpha'}),
	GroupCommander:new({name='incirlik-aleppo-tanker', mission='patrol', targetzone='Aleppo'})
})