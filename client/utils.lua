local Utils = {}
local spawnedPeds, spawnedPedCount = {}, 0
local target = exports.ox_target

---**`client`**
---@param data Blip
---@return number
function Utils.createBlip(data)
    local coords = data.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, data.sprite)
    SetBlipColour(blip, data.color or 0)
    SetBlipScale(blip, data.scale or 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(data.label)
    EndTextCommandSetBlipName(blip)

    return blip
end

---**`client`**
---@param data Ped
---@return number?
function Utils.spawnPed(data)
    local model = lib.requestModel(data.model)
    if not model then return end

    local coords = data.coords
    local entity = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, true)

    local animation = data.animation
    local animationDict, animationName = animation?.dict, animation?.name
    if animationDict then
        lib.requestAnimDict(animationDict)
        TaskPlayAnim(entity, animationDict, animationName, 8.0, -8.0, -1, animation?.flag, 0, false, false, false)
    elseif animationName then
        TaskStartScenarioInPlace(entity, animationName, 0, true)
    end

    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    spawnedPedCount += 1
    spawnedPeds[spawnedPedCount] = entity

    return entity
end

---**`client`**
---@param ped Ped
---@param options OxTargetEntity|OxTargetEntity[]
function Utils.createInteractablePed(ped, options)
    local coords = ped.coords
    return lib.points.new({
        coords = coords.xyz,
        distance = 50,
        onEnter = function(self)
            if self.entity then return end

            local entity = Utils.spawnPed(ped)
            if not entity then return end

            target:addLocalEntity(entity, options)

            self.entity = entity
        end,
        onExit = function(self)
            local entity = self.entity
            if not entity then return end

            target:removeLocalEntity(entity)

            Utils.deleteEntity(entity)

            self.entity = nil
        end
    })
end

---**`client`**
---@param event string
---@param fn function
function Utils.onNet(event, fn)
    RegisterNetEvent(event, function(...)
        if source == '' then return end

        fn(...)
    end)
end

---**`client`**
---@param entity number
function Utils.deleteEntity(entity)
    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for _, entity in pairs(spawnedPeds) do
        Utils.deleteEntity(entity)
    end
end)

return Utils
