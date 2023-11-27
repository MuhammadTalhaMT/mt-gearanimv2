local playanim = true
local currentGear = 0
local LanimationDict = "veh@driveby@first_person@passenger_rear_right_handed@smg" 
local LanimationName = "outro_90r"
local RanimationDict = "veh@driveby@first_person@passenger_rear_left_handed@smg" 
local RanimationName = "outro_90l"
local animationDuration = Config.animationDuration

function LPlayGearChangeAnimation(gear)
    RequestAnimDict(LanimationDict)
    while not HasAnimDictLoaded(LanimationDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), LanimationDict, LanimationName, 8.0, 1.0, animationDuration, 48, 0, 0, 0, 0)

    Citizen.Wait(animationDuration)
    StopAnimTask(PlayerPedId(), LanimationDict, LanimationName, 1.0)
end

function RPlayGearChangeAnimation(gear)
    RequestAnimDict(RanimationDict)
    while not HasAnimDictLoaded(RanimationDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), RanimationDict, RanimationName, 8.0, 1.0, animationDuration, 48, 0, 0, 0, 0)

    Citizen.Wait(animationDuration)
    StopAnimTask(PlayerPedId(), RanimationDict, RanimationName, 1.0)
end

function OnGearChange(newGear, rhd, blacklist)
if blacklist == false then 
    if newGear ~= currentGear then
        currentGear = newGear
      if rhd == true then 
        RPlayGearChangeAnimation(currentGear)
      else 
        LPlayGearChangeAnimation(currentGear)
      end
    end
end
end

RegisterNetEvent("gearChange")
AddEventHandler("gearChange", OnGearChange)

function DetectGearChange()
    local ped = PlayerPedId()
    local rhd = false
    local vehicle = GetVehiclePedIsIn(ped, false)
    local blacklist = false
    local vehclass = GetVehicleClass(vehicle)
    local vehicleName = GetEntityModel(vehicle)
if vehicle ~= 0 and GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) then
    if vehclass ~= 8 and vehclass ~= 13 and playanim == true then
      for k, v in ipairs(Config.RHDCars) do
        if vehicleName == GetHashKey(v) then
            rhd = true
            break 
        end
      end
      for k, v in ipairs(Config.BlacklistCars) do
        if vehicleName == GetHashKey(v) then
            blacklist = true
            break 
        end
      end
        local newGear = GetVehicleCurrentGear(vehicle)
        if newGear ~= currentGear then
            TriggerEvent("gearChange", newGear, rhd, blacklist)
        end
      end
    else
        if currentGear ~= 0 then
            currentGear = 0
            StopAnimTask(PlayerPedId(), LanimationDict, LanimationName, 1.0)
            StopAnimTask(PlayerPedId(), RanimationDict, RanimationName, 1.0)
            ClearPedTasks(PlayerPedId())
        end
    end
end

Citizen.CreateThread(function()
    while true do
        DetectGearChange()
        Citizen.Wait(100)
    end
end)

function Notify(text)
        SetNotificationTextEntry('STRING')
        AddTextComponentString(text)
        DrawNotification(0,1)
end

RegisterCommand(Config.CommandName, function()

   if playanim == true then 
    Notify("Gear Animation won't be played now")
    playanim = false
   else 
    Notify("Gear Animation will be played now")
    playanim = true  
   end

end)
