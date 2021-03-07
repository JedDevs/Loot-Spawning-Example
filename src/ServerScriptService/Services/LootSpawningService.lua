local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local Util = require(ReplicatedStorage.Modules.Utilities)
local Knit = require(ReplicatedStorage.Knit)
local Thread = require(Knit.Util.Thread)

--[[
    Name: LootSpawningService
    Purpose: Spawn Items
    By: @Teotcd
]]

local LootSpawningService = Knit.CreateService {
    Name = "LootSpawningService";
    Client = {};

    Areas = {"Area1", "Area2", "Area3"};
    Items = ServerStorage:WaitForChild("Items")
}

local ItemTable = {
    ["Area1"] = {"Item1", "Item2"},
    ["Area2"] = {"Item2"},
    ["Area3"] = {"Item1", "Item3", "Item4"}
}

local DEFAULT_RARITY_LEVEL = 1
local RARITY_ATTRIBUTE_NAME = "Rarity"
local TOOL_HANDLE_NAME = "HandleInactive" -- roblox tool workaround (disable pickup on touch)
local RARITY_RANGE = {1, 10}

function LootSpawningService:FindRandom(possibleItems)
    local rarityTable = {}
    local raritySum = 0

    for _, itemName in ipairs(possibleItems) do
        local rarityNum = self.Items[itemName] and self.Items[itemName]:GetAttribute(RARITY_ATTRIBUTE_NAME)
		rarityNum = Util.flipNumInRange(RARITY_RANGE, rarityNum or DEFAULT_RARITY_LEVEL)

		raritySum += rarityNum
        table.insert(rarityTable, rarityNum)
    end

	local ranNum = math.random() * raritySum

	for i, v in ipairs(rarityTable) do
		if ranNum < v then
			return possibleItems[i]
		end
		ranNum -= v
	end
end

local RayParams = RaycastParams.new()
RayParams.IgnoreWater = true
RayParams.FilterType = Enum.RaycastFilterType.Blacklist

function LootSpawningService:CreateItem(area: string, location: CFrame, player: Player?)
    assert(ItemTable[area] and location, "No items exist for this area or no location provided")

    local itemName = self:FindRandom(ItemTable[area])
    local newModel = LootSpawningService.Items[itemName]:Clone()

    newModel.Parent = (player and player.Character) or workspace
    CollectionService:AddTag(newModel, "Item")

    RayParams.FilterDescendantsInstances = newModel:GetChildren()
    local result = workspace:Raycast(location.Position, Vector3.new(0,-100,0), RayParams)

    if (not player or not player.Character) and result then
        local placePos = Vector3.new(result.Position.X, result.Position.Y + (newModel[TOOL_HANDLE_NAME].Size.Y / 2), result.Position.Z)
        newModel[TOOL_HANDLE_NAME].CFrame = CFrame.new(placePos)
    end
end

function LootSpawningService:ChestInteract(prompt, player)
    if not CollectionService:HasTag(prompt.Parent, "Chest") or not table.find(self.Areas, prompt.Parent.Name) then
        return warn("invalid chestObject")
    end

    prompt.Enabled = false
    local chestObject = prompt.Parent
    local chestMaterial = chestObject.Material

    self:CreateItem(chestObject.Name, chestObject.CFrame, player)
    chestObject.Material = Enum.Material.ForceField

    Thread.Delay(2, function()
        prompt.Enabled = true
        chestObject.Material = chestMaterial
    end)
end


function LootSpawningService:KnitStart()
    local function addInteraction(chestObj, promptInstance)
        if not chestObj or not table.find(self.Areas, chestObj.Name) then return end
    
        local prompt = promptInstance or script.ProximityPrompt:Clone()
        prompt.Parent = chestObj
    end

    -- chest
    for _, chestObj in ipairs(CollectionService:GetTagged("Chest")) do
        addInteraction(chestObj, chestObj:FindFirstChildOfClass("ProximityPrompt"))
    end
    CollectionService:GetInstanceAddedSignal("Chest"):Connect(addInteraction)

    ProximityPromptService.PromptTriggered:Connect(function(...)
        self:ChestInteract(...)
    end)

    -- Loop through all areas, spawning random items
    for _, area in ipairs(self.Areas) do
        CollectionService:GetInstanceAddedSignal(area):Connect(function()
            self:CreateItem(area)
        end)

        local spawnLocations = CollectionService:GetTagged(area)
        for _, location in next, spawnLocations do
            self:CreateItem(area, location.CFrame)
        end
    end
end

return LootSpawningService