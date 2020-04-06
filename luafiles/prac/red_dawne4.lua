BASE:I({"Red Dawn Moose Load Start"})
BASE:I({"Airboss Start Up"})
lastupdate = "1508 2 APRIL 2020"

trigger.action.setUserFlag("SSB",100) -- slot blocker active.
Slothandler = EVENTHANDLER:New() -- this sets up our event handler for if people die uses Simple Slot blocker (server side script)
SupportHandler = EVENTHANDLER:New()
Slothandler:HandleEvent(EVENTS.Crash) -- watch for crash, ejection and pilot dead
Slothandler:HandleEvent(EVENTS.Ejection)
Slothandler:HandleEvent(EVENTS.PilotDead)
PlayerBMap = {}
f14airgroup = 64
clients = SET_CLIENT:New():FilterActive(true):FilterStart() -- look at clients

---@param self
--@param Core.Event#EVENTDATA EventData
function Slothandler:OnEventCrash(EventData)
  BASE:E({EventData.IniGroupName})  
end
-- handle our ejection

function Slothandler:OnEventEjection(EventData)
  BASE:E({EventData})
  -- Lock that unit out so it can no longer be used.
  BASE:E({EventData.IniUnitName,"Ejection setting 5 minutes until launch"})
  clients:ForEachClient(function(cli) 
    BASE:E({cli})
    if cli.ClientAlive2 == true then
      cu = cli:GetClientGroupUnit()
      BASE:E({cu})
      cu = cu:GetName()
      BASE:E({cu})
      if cu == EventData.IniUnitName then
        trigger.action.setUserFlag(EventData.IniUnitName,100)
          f14airgroup = f14airgroup - 1
          if f14airgroup > 0 then
            Msgtosend = "Alert, We just Detected the SAR BEACON of " .. EventData.IniUnitName .. ", Unit is no longer avalible for use for 5 Minutes"
            MESSAGE:New(Msgtosend,30,"RIPCORD"):ToAll()
            SCHEDULER:New(nil,function() 
              Msgtosend = "A replacement for unit " .. EventData.IniUnitName .. " is now avalible" 
              trigger.action.setUserFlag(EventData.IniUnitName,0)
              MESSAGE:New(Msgtosend,30,"RIPCORD"):ToAll()
            end,{},(5*60))  
          else
            Msgtosend = "Alert, We just Detected the SAR BEACON of " .. EventData.IniGroupName .. ", Unit is no longer avalible airgroup is out of Airframes"
            MESSAGE:New(Msgtosend,30,"RIPCORD"):ToAll()
          end
      end
     end
   end)    
 end

-- handle a pilot dead.

function Slothandler:OnEventPilotDead(EventData)
  -- Lock that unit out so it can no longer be used.
  BASE:E({EventData.IniGroupName,"Ejection setting 10 minutes until launch"})
  clients:ForEachClient(function(cli) 
    cu = cli:GetClientGroupUnit()
    cu = cu:GetName()
    BASE:E({cu})
    if cu == EventData.IniUnitName then
      trigger.action.setUserFlag(EventData.IniUnitName,100)
        f14airgroup = f14airgroup - 1
        if f14airgroup > 0 then
          Msgtosend = "Alert, We just lost contact with " .. EventData.IniUnitName .. ", Unit is no longer avalible for use for 10 Minutes while we try and find new pilots"
          MESSAGE:New(Msgtosend,30,"RIPCORD"):ToAll()
          SCHEDULER:New(nil,function() 
            Msgtosend = "A replacement for unit " .. EventData.IniUnitName .. " is now avalible" 
            trigger.action.setUserFlag(EventData.IniUnitName,0)
            MESSAGE:New(Msgtosend,30,"RIPCORD"):ToAll()
          end,{},(10*60))  
        else
          Msgtosend = "Alert, We just lost contact with " .. EventData.IniunitName .. ", Unit is no longer avalible airgroup is out of aircraft"
          MESSAGE:New(Msgtosend,30,"RIPCORD"):ToAll()
        end
    end
  end)    
end



-- set up our airboss
  BASE:I("Stennis Airboss")
  AirbossStennis = AIRBOSS:New("USS_Stennis","Mother")

  function AirbossStennis:OnAfterStart(From,Event,To)
  end
  AirbossStennis:SetRecoveryTanker(recoverytanker)
  AirbossStennis:SetMarshalRadio(305)
  AirbossStennis:SetLSORadio(118.30)
  AirbossStennis:SetTACAN(55,"X","STN")
  AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
  AirbossStennis:SetAirbossNiceGuy(true)
  AirbossStennis:SetDespawnOnEngineShutdown(true)
  AirbossStennis:SetMenuRecovery(15,25,false,0)
  AirbossStennis:SetHoldingOffsetAngle(0)
  AirbossStennis:Start()
 
  
  
  -- some stuff for the tankers etc.
  
  message = false
  amessage = false

 
 
local function handleWeatherRequest(text, coord, red)
    local currentPressure = coord:GetPressure(0)
    local currentTemperature = coord:GetTemperature()
    local currentWindDirection, currentWindStrengh = coord:GetWind()
    local currentWindDirection1, currentWindStrength1 = coord:GetWind(UTILS.FeetToMeters(1000))
    local currentWindDirection2, currentWindStrength2 = coord:GetWind(UTILS.FeetToMeters(2000))
    local currentWindDirection5, currentWindStrength5 = coord:GetWind(UTILS.FeetToMeters(5000))
    local currentWindDirection10, currentWindStrength10 = coord:GetWind(UTILS.FeetToMeters(10000))
    local weatherString = string.format("Requested weather: Wind from %d@%.1fkts, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentPressure * 0.0295299830714, currentTemperature)
    local weatherString1 = string.format("Wind 1,000ft: Wind from%d@%.1fkts",currentWindDirection1, UTILS.MpsToKnots(currentWindStrength1))
    local weatherString2 = string.format("Wind 2,000ft: Wind from%d@%.1fkts",currentWindDirection2, UTILS.MpsToKnots(currentWindStrength2))
    local weatherString5 = string.format("Wind 5,000ft: Wind from%d@%.1fkts",currentWindDirection5, UTILS.MpsToKnots(currentWindStrength5))
    local weatherString10 = string.format("Wind 10,000ft: Wind from%d@%.1fkts",currentWindDirection10, UTILS.MpsToKnots(currentWindStrength10))
    MESSAGE:New(weatherString, 30, MESSAGE.Type.Information):ToAll()
    MESSAGE:New(weatherString1, 30, MESSAGE.Type.Information):ToAll()
    MESSAGE:New(weatherString2, 30, MESSAGE.Type.Information):ToAll()
    MESSAGE:New(weatherString5, 30, MESSAGE.Type.Information):ToAll()
    MESSAGE:New(weatherString10, 30, MESSAGE.Type.Information):ToAll()
end

------------------------
function markRemoved(Event,EC)
    if Event.text~=nil and Event.text:lower():find("-") then 
    local text = Event.text:lower()
    local text2 = Event.text
    local vec3={y=Event.pos.y, x=Event.pos.x, z=Event.pos.z}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()
    if Event.text:lower():find("-weather") then
      if EC == 2 then
        handleWeatherRequest(text, coord,false)
      else
         handleWeatherRequest(text, coord,true)
      end
    elseif Event.text:lower():find("-ribredsmoke") then
     coord:SmokeRed()
    elseif Event.text:lower():find("-ribbluesmoke") then
      coord:SmokeBlue()
    elseif Event.text:lower():find("-ribgreensmoke") then
      coord:SmokeGreen()
    elseif Event.text:lower():find("-ribflare") then
      coord:FlareRed(math.random(0,360))
      SCHEDULER:New(nil,function() 
      coord:FlareRed(math.random(0,20))
      end,{},30)
    elseif Event.text:lower():find("-ribexplode") then
      MESSAGE:New("Admin command used something is gonna blow up in 10 seconds",15):ToAll()
      coord:Explosion(500,10)
    end
   end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        env.info(string.format("RIB: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_CHANGE then
        -- nothing atm
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
         env.info(string.format("RIB: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markRemoved(Event,Event.coalition)
    end
end


world.addEventHandler(SupportHandler)
 
 
 function playercheck()
   clients:ForEachClient(function(PlayerClient) 
      local PlayerID = PlayerClient.ObjectName
        --PlayerClient:AddBriefing("Welcome to Red Iberia Rob Graham Version: "..version.." \n Last updated:".. lastupdate .." \n POWERED BY MOOSE \n Current Server time is: ".. nowHour .. ":" .. nowminute .."\n Mission Restart time:".. restarttime .. "\n No Blue on Blue is Allowed \n Your current objective is to ".. blueobject .."\n" ..bcomms .. "\n Remember Stores and Aircraft are limited and take time to resupply")
        if PlayerClient:GetGroup() ~= nil then
          local group = PlayerClient:GetGroup()
        end
         if PlayerClient:IsAlive() then
           if PlayerBMap[PlayerID] ~= true then
                PlayerBMap[PlayerID] = true
                MESSAGE:New("Welcome to Red Dawn Episode 4 By Rob Graham \n Last updated:".. lastupdate .." \n POWERED BY MOOSE \n Be aware gettign shot down will result in slot lock and reduction of AC count, 5 minutes for Eject, 10 Minutes for Dead Pilot \n Current AC Count is:" ..f14airgroup .. "",60):ToClient(PlayerClient)
           end    
         else
          if PlayerBMap[PlayerID] ~= false then
                PlayerBMap[PlayerID] = false
          end
       end
    end)
 
 end
 SCHEDULER:New(nil,playercheck,{},1,10)
 
 do
    nowTable = os.date('*t')
    nowYear = nowTable.year
    nowMonth = nowTable.month
    nowDay = nowTable.day
    nowHour = nowTable.hour
    nowminute = nowTable.min
end
 