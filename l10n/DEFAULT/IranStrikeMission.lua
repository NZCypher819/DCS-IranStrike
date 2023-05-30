-- create an instance of the IADS
redIADS = SkynetIADS:create('IRAN')

-- add all units with unit name beginning with 'EW' to the IADS:
redIADS:addEarlyWarningRadarsByPrefix('EW')

-- add all groups beginning with group name 'SAM' to the IADS:
redIADS:addSAMSitesByPrefix('SAM')

--add a command center:
commandCenter = StaticObject.getByName('Command-Center')
redIADS:addCommandCenter(commandCenter)
commandCenter2 = StaticObject.getByName('Command-Center2')
redIADS:addCommandCenter(commandCenter2)

-- activate the IADS
redIADS:activate()

--add resupply for the SAM's
redIADS:addResupply("SAM", 30*60)

-- Initialize A2A Dispatcher
A2ADispatcher = AI_A2A_DISPATCHER:New()

-- Set engagement and GCI radius
A2ADispatcher:SetEngageRadius(200000)
A2ADispatcher:SetGciRadius(300000)

-- Add squadrons
A2ADispatcher:SetSquadron("Kerman", AIRBASE.PersianGulf.Kerman_Airport, {"Kerman-SU27-01", "Kerman-Mg29s-01", "Kerman-Mg21-01"}, 60)

-- Start dispatcher
A2ADispatcher:Start()

-- Setup the airbases
local KermanAirbase = ZoneCommander.Airbase.create("Kerman", AIRBASE.PersianGulf.Kerman_Airport)
local ShirazAirbase = ZoneCommander.Airbase.create("Shiraz", AIRBASE.PersianGulf.Shiraz_International_Airport)

-- Add resupply between the two airbases
KermanAirbase:addResupply(ShirazAirbase)
ShirazAirbase:addResupply(KermanAirbase)

-- Set the coalition of the two airbases to "red"
KermanAirbase:setCoalition("red")
ShirazAirbase:setCoalition("red")

-- Add cargo to the Kerman airbase
KermanAirbase:addCargo("Infantry", 10)
KermanAirbase:addCargo("Supplies", 20)

-- Allow players to spawn a helicopter at the Kerman airbase
KermanAirbase:spawnHelicopter("UH-1H")

-- Set the capture distance of the airbase to 200m
KermanAirbase:setCaptureDistance(200)
