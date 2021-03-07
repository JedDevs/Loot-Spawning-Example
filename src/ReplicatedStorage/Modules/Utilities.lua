local Util = {}

Util.u = 0

-- Accurate and easy round function
function Util.round(exact, quantum)
	local quant,frac = math.modf(exact/quantum)
	return quantum * (quant + (frac > 0.5 and 1 or 0))
end

function Util.TweenIt(Object, Changes, Time)
	local TweenService = game:GetService("TweenService")
	local Info = TweenInfo.new(
		Time,
		Enum.EasingStyle.Linear, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- Times repeteated
		false, -- Reversing
		0 -- Time Delay
	)
	return TweenService:Create(Object, Info, Changes)
end

-- Alternate random function
function Util.random(x, y, round)
	return round and math.floor(math.random(x,y)) or math.random(x,y)
end

-- Alternate random function, no better than math.random() but people pretend it is :/
function Util.trueRandom(x,y, integer)
	assert(x < y, "X must be smaller than Y")
	local randomNum = Random.new()

	if integer then
		return randomNum:NextInteger(x,y)
	end
	return randomNum:NextNumber(x, y)
end

function Util.getTrack(animationTracks: table, name: string)
	for _, track in pairs(animationTracks) do
        if track.Name ~= name then continue end
		return track
    end
end

function Util.dictionaryLen(t)
	local n = 0
	for num in pairs(t) do
		n = num
	end
	return n
end

function Util.flipNumInRange(range: Array, num: number)
	assert(#range == 2, "range must have two elements: min, max")
    return (range[1] + range[2]) - num
end

function Util.orderNumberedDict(d: Dictionary)
	local newDict = {}

	
end

function Util.bubbleSort(t: table)
	local copy = table.unpack(t)
	local function check(i, v)
		local nextNum = copy[i+1]
		if nextNum and (nextNum < v) then
			copy[i] = nextNum
			copy[i + 1] = v

			return true
		end
	end

	local changeMade
	repeat
		changeMade = false
		for i, v in next, copy do
			changeMade = check(i, v) or changeMade
		end
	until changeMade == false

	return copy
end

-- Find the length of a simple table
function Util.len(t) -- t = table
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	return n
end

-- Create a shallow copy of a 1 level table
function Util.shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

-- Create a deep copy of a dictionary
function Util.deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = Util.deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

-- find nearest number in a table
function Util.findNearest(table, number)
	local smallestSoFar, smallestIndex
	for i, y in ipairs(table) do
		if not smallestSoFar or (math.abs(number-y) < smallestSoFar) then
			smallestSoFar = math.abs(number-y)
			smallestIndex = i
		end
	end
	return smallestIndex, table[smallestIndex]
end

function Util.MasslessModel(model, boolean)
	assert(model:IsA("Model", "'model' provided was not a model"))
	assert(type(boolean) == "boolean", "'boolean' provided was not a boolean (true/false)")

	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Massless = boolean
		end
	end
end

function Util.anchorModel(model, boolean)
	assert(model:IsA("Model", "'model' provided was not a model"))
	assert(type(boolean) == "boolean", "'boolean' provided was not a boolean (true/false)")

	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Anchored = boolean
		end
	end
end

function Util.canCollide(model, boolean)
	assert(model:IsA("Model", "'model' provided was not a model"))
	assert(type(boolean) == "boolean", "'boolean' provided was not a boolean (true/false)")

	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = boolean
		end
	end
end

function Util.getNearest(part, array, ignoreList: Array)
	local nearest = {math.huge, nil}

	for _,v in ipairs(array) do
		if v:IsA("BasePart") and (v.Position - part.Position).Magnitude < nearest[1] then
			if v == part or table.find(ignoreList, v) then continue end
			nearest = {(v.Position - part.Position).Magnitude, v}
		end
		if v:IsA("Model") and (v.PrimaryPart.Position - part.Position).Magnitude < nearest[1] then
			if v.PrimaryPart == part or table.find(ignoreList, v.PrimaryPart) or table.find(ignoreList, v) then continue end
			nearest = {(v.PrimaryPart.Position - part.Position).Magnitude, v}
		end
	end
	return nearest[2]
end

local visible = {[true] = 0, [false] = 1}
function Util.isVisible(model, boolean)
	if not model:IsA("Model") then return warn("'model' provided was not a model") end
	assert(type(boolean) == "boolean", "'boolean' provided was not a boolean (true/false)")

	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = visible[boolean]
		end
	end
end

-- FindFirstDescendantOfClass
function Util.FindFirstDescendantOfClass(object: Instance, class: string)
	for _,v in pairs(object:GetDescendants()) do
		if v:IsA(class) then
			return v
		end
	end
	return nil, warn("Couldn't find descendant")
end

-- FindFirstDescendant (with name)
function Util.FindFirstDescendant(object: Instance, name: string)
	for _,v in pairs(object:GetDescendants()) do
		if v.Name == name then
			return v
		end
	end
	return nil, warn("Couldn't find descendant")
end

-- Ease of use Instance creation
function Util.InstanceNew(type: any, parent, name: string, position): any
	local v = Instance.new(type)
	v.Parent = parent
	v.Name = name or type

	if v:IsA("BasePart") then
		if typeof(position) == "CFrame" then
			v.CFrame = position
		else
			v.CFrame = CFrame.new(position)
		end
	end

	return v
end

function Util.raycastParams(filterDescendantsInstances: table, filterType: any, ignoreWater: boolean, collisionGroup: optional)
	local params = RaycastParams.new()

	if type(filterType) == "string" then
		params.FilterType = Enum.RaycastFilterType[filterType] or filterType
	else
		params.FilterType = filterType
	end

	params.FilterDescendantsInstances = filterDescendantsInstances
	params.IgnoreWater = ignoreWater or true

	if collisionGroup then
		params.CollisionGroup = collisionGroup
	end
	return params
end

-- Ease of use Bounding adddition
function Util.CreateBounding(instance: Model, anchor: boolean, modelCF: boolean, setPrimary: boolean, overrideOld: boolean)
    assert(instance:IsA("Model"), "Can not create a bounding for 'non-Model' objects")
    
    local boundingBox = instance:FindFirstChild("BoundingBox")
    
    if not boundingBox or overrideOld then
		local _, size = instance:GetBoundingBox()
		local pos = instance:GetModelCFrame().p

		if boundingBox then
			boundingBox.Parent = workspace
			_, size = instance:GetBoundingBox()
			pos = instance:GetModelCFrame().p
			boundingBox.Parent = instance
		end

		if not modelCF then
			local primaryPart = Util.findPrimaryPart(instance)
			pos = primaryPart.Position
		end

        boundingBox = boundingBox or Util.InstanceNew("Part", instance, "BoundingBox", pos)
		boundingBox.CFrame = CFrame.new(pos)
		boundingBox.Size = size
	end

	boundingBox.CanCollide, boundingBox.Anchored = false, anchor or false
    boundingBox.Transparency = 1

	if setPrimary then
		instance.PrimaryPart = boundingBox
	end
    return boundingBox
end

-- Ease of use Weld creation
function Util.weldTo(from: Instance, to: Instance, parent: any?, name: string?)
	local weld = Instance.new("WeldConstraint")
	weld.Parent = parent or from
	weld.Name = name or "WeldConstraint"

	weld.Part0 = from
	weld.Part1 = to

	return weld
end

function Util.cloneTo(object: any, parent: Instance?): any
	local v = object:Clone()
	v.Parent = parent or v.Parent
	return v
end

-- Easily find the first child with relevant name
function Util.findFirstDescendant(object, name)
    for _, v in pairs(object:GetDescendants()) do
        if v.Name ~= name then continue end
        return v
    end
end

-- Returns a table of all BaseParts in a model
function Util.getBaseParts(model)
	if not model:IsA("Model") then return end
	local baseParts = {}

	for _,v in pairs(model:GetDescendants()) do
		if not v:IsA("BasePart") then continue end
		table.insert(baseParts, v)
	end

	return baseParts
end

-- Returns the 'true' PrimaryPart, however many deep
-- If no PrimaryPart exists it chooses a random BasePart - Similar to GetModelCFrame (Depracated)
function Util.findPrimaryPart(model) 
	if not model:IsA("Model") then return end
	local primaryPart = model.PrimaryPart

	if primaryPart == nil then
		local allParts = Util.getBaseParts(model)
		if allParts == nil or #allParts == 0 then
			return warn("No Primary Part and No Base Parts")
		end
		return allParts[math.random(1, #allParts)]
	end

	repeat
		if primaryPart:IsA("Model") then
			primaryPart = primaryPart.PrimaryPart
		end
	until not primaryPart:IsA("Model")

	return primaryPart
end

-- Weld Entire model together, Parent: 'To' or PrimaryPart
function Util.weldModel(model, To)
	local primaryPart = To or Util.findPrimaryPart(model)
	if (not model:IsA("Model") and not model:IsA("Tool")) or not primaryPart then return false end

	local function alreadyWelded(v)
		for _, weld in pairs(primaryPart:GetChildren()) do
			if not weld:IsA("WeldConstraint") then continue end
			if weld.Part0 == v then
				return true
			end
		end
		return false
	end

	for _,v in pairs(model:GetDescendants()) do
		if not v:IsA("BasePart") then continue end
		if alreadyWelded(v) then continue end
		Util.weldTo(v, primaryPart, primaryPart)
	end

	return true
end

-- Ease of use Viewport Frame w/ Item
function Util.CreateViewportItem(Model, FrameSlotWithViewPort)
	local camera = Instance.new("Camera")
	Model.Name = "Model"
    
    camera.Parent = FrameSlotWithViewPort.ViewportFrame
    FrameSlotWithViewPort.ViewportFrame.CurrentCamera = camera

    if Model:IsA("Tool") then
        Model = Model:FindFirstChildOfClass("Model")
    end

    FrameSlotWithViewPort.ViewportFrame.CurrentCamera.CFrame = CFrame.new(0,0,0)
    Model.PrimaryPart.CFrame =  Model.PrimaryPart.CFrame * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
    
    local distance = Util.GetZoom(Model, camera)
    camera.CFrame = CFrame.new(Model.PrimaryPart.Position + (Model.PrimaryPart.CFrame.RightVector * (distance)), Model.PrimaryPart.Position) + Vector3.new(0,0,0)
    Model.Parent = FrameSlotWithViewPort.ViewportFrame

    return FrameSlotWithViewPort.ViewportFrame
end

-- Perfect Camera Distance For Obj
function Util.GetZoom(obj, camera)
    local objSize = obj:GetExtentsSize();
    local radius = objSize.Magnitude*.35
    local halfFOV = math.rad(camera.FieldOfView/2)

    local distance = radius/(math.tan(halfFOV))
    return distance
end

return Util