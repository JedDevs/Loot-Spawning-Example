local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Knit)
local Maid = require(Knit.Util.Maid)

--[[
    Name: Item
    Purpose: Handle Tool/Item Interaction
    By: @Teotcd
--]]

local Item = {}
Item.__index = Item

Item.Tag = "Item"

local Util = require(ReplicatedStorage.Modules.Utilities)
local ProximityPrompt = script:FindFirstChildOfClass("ProximityPrompt")

local function findOwner(instance)
    return Players:FindFirstChild(instance.Parent.Name) or instance:FindFirstAncestorOfClass("Player")
end

function Item.new(instance)
    local self = setmetatable({}, Item)

    self.handle = instance:WaitForChild("HandleInactive", 1) or instance:FindFirstChildOfClass("BasePart")
    self.interaction = Util.cloneTo(ProximityPrompt, self.handle)

    self._instance = instance
    self._maid = Maid.new()
    

    local owner = findOwner(instance)
    if owner then
        return self, self:Pickup(owner)
    end
    return self, self:Drop()
end

function Item:Pickup(player)
    assert(self.owner == nil, "Item already owned")

    self.owner = player
    self._instance.Parent = player.Backpack

    self.interaction.Enabled = false
    self.handle.Name = "Handle"
end

function Item:Drop()
    self.owner = nil
    self.interaction.Enabled = true
    self.handle.Name = "HandleInactive"
end

function Item:Init()
    ProximityPromptService.PromptTriggered:Connect(function(promptInstance, player)
        if promptInstance ~= self.interaction then return end
        self:Pickup(player)
    end)

    self._instance.AncestryChanged:Connect(function(_, parent)
        if self.owner and (parent == self.owner.Backpack or parent == self.owner.Character) then return end
        self:Drop()
    end)
end

function Item:Destroy()
    self._maid:Destroy()
end


return Item