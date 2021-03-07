local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core module:
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Component = require(Knit.Util.Component)

-- Load all controllers:
for _,v in ipairs(ReplicatedStorage.Controllers:GetDescendants()) do
    if v:IsA("ModuleScript") then
        require(v)
    end
end

local IGNORE_COMPONENTS = {} --"Ingredient"

-- Load all components:

local function LoadClientComponents()
	for _,v in ipairs(ReplicatedStorage.Components:GetDescendants()) do
		if not v:IsA("ModuleScript") or table.find(IGNORE_COMPONENTS, v.Name) then
			continue
		end

		local vModule = require(v)
		Component.new(vModule.Tag, vModule)
	end
end

-- Start Knit:
Knit.Start():Then(function()
	print("Knit running")
	LoadClientComponents()
end):Catch(function (err)
	warn(err)
end)