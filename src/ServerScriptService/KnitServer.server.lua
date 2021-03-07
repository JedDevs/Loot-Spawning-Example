-- KnitServer in ServerScriptService

local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Component = require(Knit.Util.Component)

local Services = script.Parent:WaitForChild("Services")
local Components = script.Parent:WaitForChild("Components")

for _,v in ipairs(Services:GetChildren()) do
    if v:IsA("ModuleScript") then
        local s,e = pcall(function ()
            require(v)
        end)
        
        if not s then
            warn("Failed to load " .. v.Name .. " because: " .. e)
        end
    end
end

local IGNORE_COMPONENTS = {}

-- Load all components:

local function LoadServerComponents()
    for _,v in ipairs(Components:GetDescendants()) do
        if not v:IsA("ModuleScript") or table.find(IGNORE_COMPONENTS, v.Name) then
            continue
        end

        local vModule = require(v)
        Component.new(vModule.Tag, vModule)
    end
end

Knit.Start():Then(function()
    print("Knit running")
    LoadServerComponents()
end):Catch(function (err)
    warn(err)
end)