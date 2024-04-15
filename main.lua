local mod = RegisterMod("Lethal League Blaze", 1)

local candymanType = Isaac.GetPlayerTypeByName("Candyman", false) -- Exactly as in the xml. The second argument is if you want the Tainted variant.
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/candyman_hat.anm2") -- Exact path, with the "resources" folder as the root

function mod:GiveCostumesOnInit(player)
    if player:GetPlayerType() ~= candymanType then
        return -- End the function early. The below code doesn't run, as long as the player isn't Candyman.
    end

    player:AddNullCostume(hairCostume)
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.GiveCostumesOnInit)

-- Function to remove rubber cement's costume from character
-- Not perfect, as it is visible in the starting moments of a run before character is controllable
function mod:RemoveCementCostume(player)
    if player.FrameCount ~= 1 then
      return
    end

    if player and player:GetName() == "Candyman" then
        local itemConfig = Isaac.GetItemConfig()
        local itemConfigItem = itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_RUBBER_CEMENT)

        print("Checking if player type is correct: ", player:GetPlayerType(), candymanType)

        if itemConfigItem ~= nil then
            player:RemoveCostume(itemConfigItem)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.RemoveCementCostume)

local jetSkates = Isaac.GetItemIdByName("Jet's Skates")
local jetSkatesSpeed = 0.4

local switchHat = Isaac.GetItemIdByName("Switch's Hat")
local switchHatSpeed = 0.2
local switchHatRange = 80

local ivoryPuppet = Isaac.GetItemIdByName("Ivory Puppet: Retribution")

local ashesAscent = Isaac.GetItemIdByName("Ashes Ascent")
local ashesAscentDamage = 1

local dicePaddle = Isaac.GetItemIdByName("Dice's Paddle")
local dicePaddleSpeed = 0.2
local dicePaddleRange = 120
local dicePaddleShotSpeed = 0.2

local sliceDice = Isaac.GetItemIdByName("Slice Dice")
local sliceUse = 0
function mod:SliceDiceUse()
    local itemPool = Game():GetItemPool()
    local entities = Isaac.GetRoomEntities()
    sliceUse = math.random(1, 6)
    
    for _, entity in ipairs(entities) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType ~= 0 and entity.SubType ~= 668 then
            entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, true)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entity.Position, entity.Velocity, nil)
            itemPool:RemoveCollectible(entity.SubType)
        end
    end

    mod:EvaluateCache()

    return true -- Discharge true, Remove false, ShowAnim true
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.SliceDiceUse, sliceDice)

function mod:EvaluateCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then -- Speed cache
        local itemCount = player:GetCollectibleNum(jetSkates) -- Jet's Skates (speed)
        local speedToAdd = jetSkatesSpeed * itemCount
        player.MoveSpeed = player.MoveSpeed + speedToAdd
        local itemCount = player:GetCollectibleNum(switchHat) -- Switch's Hat (speed)
        local speedToAdd = switchHatSpeed * itemCount
        player.MoveSpeed = player.MoveSpeed + speedToAdd
        local itemCount = player:GetCollectibleNum(dicePaddle) -- Dice's Paddle (speed)
        local speedToAdd = dicePaddleSpeed * itemCount
        player.MoveSpeed = player.MoveSpeed + speedToAdd
        if sliceUse == 1 then
            player.MoveSpeed = player.MoveSpeed - 0.2
        end
    end
    if cacheFlags & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then -- Range cache
        local itemCount = player:GetCollectibleNum(switchHat) -- Switch's Hat (range)
        local rangeToAdd = switchHatRange * itemCount
        player.TearRange = player.TearRange + rangeToAdd
        local itemCount = player:GetCollectibleNum(dicePaddle) -- Dice's Paddle (range)
        local rangeToAdd = dicePaddleRange * itemCount
        player.TearRange = player.TearRange + rangeToAdd
        if sliceUse == 2 then
            player.TearRange = player.TearRange - 20
        end
    end
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then -- Damage cache
        local itemCount = player:GetCollectibleNum(ashesAscent) -- Ashes Ascent (damage)
        local damageToAdd = ashesAscentDamage * itemCount
        player.Damage = player.Damage + damageToAdd
        if sliceUse == 3 then
            player.Damage = player.Damage - 1
        end
    end
    if cacheFlags & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then -- Shot speed cache
        local itemCount = player:GetCollectibleNum(dicePaddle) -- Dice's Paddle (shot speed)
        local shotSpeedToAdd = dicePaddleShotSpeed * itemCount
        player.ShotSpeed = player.ShotSpeed + shotSpeedToAdd
        if sliceUse == 4 then
            player.ShotSpeed = player.ShotSpeed - 0.2
        end
    end
    if cacheFlags & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING then -- Flying cache
        if player:GetCollectibleNum(ashesAscent) >= 1 then
            player.CanFly = true
        end
    end
    if cacheFlags & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY then -- Tear rate cache
        if sliceUse == 5 then
            player.FireDelay = player.FireDelay - 0.5
        end
    end
    if cacheFlags & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then -- Luck cache
        if sliceUse == 6 then
            player.Luck = player.Luck - 1
        end
    end
    sliceUse = 0
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)

function mod:PostAddCollectible(type, charge, FirstTime, slot, VarData, player)
    if type == 735 or type == 736 then -- Ivory Puppet: Retribution or Ashes Ascent (broken hearts)
        Isaac.GetPlayer():AddBrokenHearts(1)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, mod.PostAddCollectible)

-- External Item Description implementations
if EID then
    EID:addCollectible(jetSkates, "{{ArrowUp}} +0.4 Speed")
    EID:addCollectible(switchHat, "{{ArrowUp}} +0.2 Speed#{{ArrowUp}} +2 Range")
    EID:addCollectible(ivoryPuppet, "{{Heart}} +3 Health#{{BrokenHeart}} +1 Broken Heart")
    EID:addCollectible(ashesAscent, "{{ArrowUp}} +1 Damage#Flight#{{BrokenHeart}} +1 Broken Heart")
    EID:addCollectible(dicePaddle, "{{ArrowUp}} +0.2 Speed#{{ArrowUp}} +3 Range#{{ArrowUp}} +0.2 Shot speed")
    EID:addCollectible(sliceDice, "Rerolls all pedestal items in the room#{{ArrowDown}} Decreases a random stat")
end