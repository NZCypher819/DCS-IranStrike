do
--create an instance of the IADS
redIADS = SkynetIADS:create('IRAN')

---debug settings remove from here on if you do not wan't any output on what the IADS is doing by default
--local iadsDebug = redIADS:getDebugSettings()
--iadsDebug.IADSStatus = true
--iadsDebug.radarWentDark = true
--iadsDebug.contacts = true
--iadsDebug.radarWentLive = true
--iadsDebug.noWorkingCommmandCenter = false
--iadsDebug.ewRadarNoConnection = false
--iadsDebug.samNoConnection = false
--iadsDebug.jammerProbability = true
--iadsDebug.addedEWRadar = true --modified
--iadsDebug.hasNoPower = false
--iadsDebug.harmDefence = true
--iadsDebug.samSiteStatusEnvOutput = true
--iadsDebug.earlyWarningRadarStatusEnvOutput = true
--iadsDebug.commandCenterStatusEnvOutput = true
---end remove debug ---

--add all units with unit name beginning with 'EW' to the IADS:
redIADS:addEarlyWarningRadarsByPrefix('EW')

--add all groups begining with group name 'SAM' to the IADS:
redIADS:addSAMSitesByPrefix('SAM')

	-- SAM Site Initiation
	--redIADS:addSAMSite('SAM-SA2-001')
	--redIADS:addSAMSite('SAM-SA10-001')


--add a command center:
commandCenter = StaticObject.getByName('Command-Center')
redIADS:addCommandCenter(commandCenter)
commandCenter2 = StaticObject.getByName('Command-Center2')
redIADS:addCommandCenter(commandCenter2)

---we add a K-50 AWACs, manually. This could just as well be automated by adding an 'EW' prefix to the unit name:
--redIADS:addEarlyWarningRadar('AWACS-E3A-001')

--add a power source and a connection node for this EW radar:
--local powerSource = StaticObject.getByName('Power-Source-EW-Center3')
--local connectionNodeEW = StaticObject.getByName('Connection-Node-EW-Center3')
--redIADS:getEarlyWarningRadarByUnitName('EW-Center3'):addPowerSource(powerSource):addConnectionNode(connectionNodeEW)

--add a connection node to this SA-2 site, and set the option for it to go dark, if it looses connection to the IADS:
--local connectionNode = Unit.getByName('Command-Center')
--redIADS:getSAMSiteByGroupName('SAM-SA2-001'):addConnectionNode(connectionNode):setAutonomousBehaviour(SkynetIAD SAbstractRadarElement.AUTONOMOUS_STATE_DARK)

--this SA-2 site will go live at 70% of its max search range:
--redIADS:getSAMSiteByGroupName('SAM-SA-2'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(70)

--all SA-10 sites shall act as EW sites, meaning their radars will be on all the time:
--redIADS:getSAMSitesByNatoName('SA-10'):setActAsEW(true)

--set the sa15 as point defence for the SA-10 site, we set it to always react to a HARM so we can demonstrate the point defence mechanism in Skynet
--local sa15 = redIADS:getSAMSiteByGroupName('SAM-SA-15-point-defence-SA-10')
--redIADS:getSAMSiteByGroupName('SAM-SA-10'):addPointDefence(sa15):setHARMDetectionChance(100):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)


--set this SA-11 site to go live 70% of max range of its missiles (default value: 100%), its HARM detection probability is set to 50% (default value: 70%)
--redIADS:getSAMSiteByGroupName('SAM-SA-11'):setGoLiveRangeInPercent(70):setHARMDetectionChance(50)

--this SA-6 site will always react to a HARM being fired at it:
--redIADS:getSAMSiteByGroupName('SAM-SA-6'):setHARMDetectionChance(100)

--set this SA-11 site to go live at maximunm search range (default is at maximung firing range):
--redIADS:getSAMSiteByGroupName('SAM-SA-11-2'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)

--activate the radio menu to toggle IADS Status output
redIADS:addRadioMenu()

-- activate the IADS
redIADS:activate()	

--add the jammer
--local jammer = SkynetIADSJammer:create(Unit.getByName('jammer-emitter'), redIADS)
--jammer:masterArmOn()
--jammer:addRadioMenu()

---some special code to remove the jammer aircraft if player is not flying with it in formation, has nothing to do with the IADS:
--local hornet = Unit.getByName('Hornet SA-11-2 Attack')
--if hornet == nil then
--	Unit.getByName('jammer-emitter'):destroy()
--	jammer:removeRadioMenu()
--end
--end special code

------setup blue IADS:
--blueIADS = SkynetIADS:create('UAE')
--blueIADS:addSAMSitesByPrefix('BLUE-SAM')
--blueIADS:addEarlyWarningRadarsByPrefix('BLUE-EW')
--blueIADS:activate()
--blueIADS:addRadioMenu()

--local iadsDebug = blueIADS:getDebugSettings()
--iadsDebug.IADSStatus = true
--iadsDebug.contacts = true

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