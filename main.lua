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

function mod:EvaluateCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        local itemCount = player:GetCollectibleNum(jetSkates)
        local speedToAdd = jetSkatesSpeed * itemCount
        player.MoveSpeed = player.MoveSpeed + speedToAdd
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)