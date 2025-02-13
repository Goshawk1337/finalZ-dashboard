local ftype = "normal"

local SETTINGS = {
    ["MINIMAP"] = true
}


RegisterNUICallback('exit', function(data, cb)
    setNuiState(false)
    cb('ok')
end)

RegisterNUICallback('getData', function(nuiData, cb)
    local action = nuiData.action
    local data  = nuiData.data

    if action == "fpsChange" then
        fpsChange(data)
    elseif action == "settings" then
        SETTINGS[data.inputValue] = not data.state
    elseif action == "copyID" then
        copyID(data.identifier)
    end

    
    cb('ok')
end)


function fpsChange(fpsType) 
    ftype = fpsType == "reset" and "normal" or fpsType
    if fpsType == "reset" then
        RopeDrawShadowEnabled(true)

        CascadeShadowsSetAircraftMode(true)
        CascadeShadowsEnableEntityTracker(false)
        CascadeShadowsSetDynamicDepthMode(true)
        CascadeShadowsSetEntityTrackerScale(5.0)
        CascadeShadowsSetDynamicDepthValue(5.0)
        CascadeShadowsSetCascadeBoundsScale(5.0)

        SetFlashLightFadeDistance(10.0)
        SetLightsCutoffDistanceTweak(10.0)
        DistantCopCarSirens(true)
        SetArtificialLightsState(false)
    elseif fpsType == "ulow" then
        RopeDrawShadowEnabled(false)

        CascadeShadowsClearShadowSampleType()
        CascadeShadowsSetAircraftMode(false)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetDynamicDepthMode(false)
        CascadeShadowsSetEntityTrackerScale(0.0)
        CascadeShadowsSetDynamicDepthValue(0.0)
        CascadeShadowsSetCascadeBoundsScale(0.0)

        SetFlashLightFadeDistance(0.0)
        SetLightsCutoffDistanceTweak(0.0)
        DistantCopCarSirens(false)
    elseif fpsType == "low" then
        RopeDrawShadowEnabled(false)

        CascadeShadowsClearShadowSampleType()
        CascadeShadowsSetAircraftMode(false)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetDynamicDepthMode(false)
        CascadeShadowsSetEntityTrackerScale(0.0)
        CascadeShadowsSetDynamicDepthValue(0.0)
        CascadeShadowsSetCascadeBoundsScale(0.0)

        SetFlashLightFadeDistance(5.0)
        SetLightsCutoffDistanceTweak(5.0)
        DistantCopCarSirens(false)
    end
end

function copyID(identifier)
    lib.setClipboard(identifier)
    Config.Notify(Config.locales[Config.Language].copiedSuccess, "success")
end

function setNuiState(state)
    SetNuiFocus(state, state)

    SendNUIMessage({
        type = "show",
        enable = state,
    })
end

RegisterCommand(Config.Command.commandName, function()
    if not IsEntityDead(cache.ped) or not IsPauseMenuActive() then
        lib.callback("server:setData", false, function(data)
            setNuiState(true)
            Wait(100)
            SendNUIMessage({
                type = "loadData",
                data = data,
                locales = Config.locales[Config.Language]
            })
        end)
    end
end, false)

RegisterKeyMapping("dashboard", Config.Command.keyMappingDesc, 'keyboard', Config.Command.keyMapping)


CreateThread(function()
    while true do
        DisplayRadar(SETTINGS["MINIMAP"])
	    Wait(0)
    end
end)

CreateThread(function()
    while true do
        local sleep = 8
        if ftype == "ulow" then
            sleep = 1
            --// Find closest ped and set the alpha
            for ped in GetWorldPeds() do
                if not IsEntityOnScreen(ped) then
                    SetEntityAlpha(ped, 0)
                    SetEntityAsNoLongerNeeded(ped)
                else
                    if GetEntityAlpha(ped) == 0 then
                        SetEntityAlpha(ped, 255)
                    elseif GetEntityAlpha(ped) ~= 210 then
                        SetEntityAlpha(ped, 210)
                    end
                end

                SetPedAoBlobRendering(ped, false)
                Wait(sleep)
            end

            --// Find closest object and set the alpha
            for obj in GetWorldObjects() do
                if not IsEntityOnScreen(obj) then
                    SetEntityAlpha(obj, 0)
                    SetEntityAsNoLongerNeeded(obj)
                else
                    if GetEntityAlpha(obj) == 0 then
                        SetEntityAlpha(obj, 255)
                    elseif GetEntityAlpha(obj) ~= 170 then
                        SetEntityAlpha(obj, 170)
                    end
                end
                Wait(sleep)
            end


            DisableOcclusionThisFrame()
            SetDisableDecalRenderingThisFrame()
            RemoveParticleFxInRange(GetEntityCoords(PlayerPedId()), 10.0)
            OverrideLodscaleThisFrame(0.4)
            SetArtificialLightsState(true)
        elseif ftype == "low" then
            sleep = 1
            for ped in GetWorldPeds() do
                if not IsEntityOnScreen(ped) then
                    SetEntityAlpha(ped, 0)
                    SetEntityAsNoLongerNeeded(ped)
                else
                    if GetEntityAlpha(ped) == 0 then
                        SetEntityAlpha(ped, 255)
                    elseif GetEntityAlpha(ped) ~= 210 then
                        SetEntityAlpha(ped, 210)
                    end
                end
                SetPedAoBlobRendering(ped, false)

                Wait(sleep)
            end

            for obj in GetWorldObjects() do
                if not IsEntityOnScreen(obj) then
                    SetEntityAlpha(obj, 0)
                    SetEntityAsNoLongerNeeded(obj)
                else
                    if GetEntityAlpha(obj) == 0 then
                        SetEntityAlpha(obj, 255)
                    elseif GetEntityAlpha(ped) ~= 210 then
                        SetEntityAlpha(ped, 210)
                    end
                end
                Wait(sleep)
            end

            SetDisableDecalRenderingThisFrame()
            RemoveParticleFxInRange(GetEntityCoords(PlayerPedId()), 10.0)
            OverrideLodscaleThisFrame(0.6)
            SetArtificialLightsState(true)


            OverrideLodscaleThisFrame(0.8)
        else
            sleep = 500
        end
        Wait(sleep)
    end
end)

--// Clear broken thing, disable rain, disable wind and other tiny thing that dont require the frame tick
CreateThread(function()
    while true do
        local sleep = 1500
        if type == "ulow" or type == "low" then
            sleep = 300
            ClearAllBrokenGlass()
            ClearAllHelpMessages()
            LeaderboardsReadClearAll()
            ClearBrief()
            ClearGpsFlags()
            ClearPrints()
            ClearSmallPrints()
            ClearReplayStats()
            LeaderboardsClearCacheData()
            ClearFocus()
            ClearHdArea()
            ClearPedBloodDamage(PlayerPedId())
            ClearPedWetness(PlayerPedId())
            ClearPedEnvDirt(PlayerPedId())
            ResetPedVisibleDamage(PlayerPedId())
            ClearExtraTimecycleModifier()
            ClearTimecycleModifier()
            ClearOverrideWeather()
            ClearHdArea()
            DisableVehicleDistantlights(false)
            DisableScreenblurFade()
            SetRainLevel(0.0)
            SetWindSpeed(0.0)
            Wait(sleep)
        else
            Wait(sleep)
        end
    end
end)






--// Entity Enumerator (https://gist.github.com/IllidanS4/9865ed17f60576425369fc1da70259b2#file-entityiter-lua)
local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(
        function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = { handle = iter, destructor = disposeFunc }
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end
    )
end

function GetWorldObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function GetWorldPeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function GetWorldVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function GetWorldPickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end
