--[[
	This system allows you to quickly and easily add an interaciton identifier in your own system.

	DOCUMENTATION:
		Interaction.new(part : BasePart, distance : Number?, button : Enum.KeyCode?)
			Interaction.EnteredRange -> Signal : Fired when the interaction UI appears
			Interaction.LeftRange -> Signal : Fired when the interaction UI disappears
			Interaction.InteractedStart -> Signal : Fired when the player presses their finger
			Interaction.InteractedEnd -> Signal : Fired when the player releases their finger/key
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local DEFAULT_BUTTON = Enum.KeyCode.E
local DEFAULT_DISTANCE = 10

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Signal = require(Knit.Util.Signal)
local Maid = require(Knit.Util.Maid)

local Interaction = {}
Interaction.__index = Interaction

------------------------------------------------------------------------------

local function applyProperties(object, properties)
	for name, value in pairs (properties) do
		object[name] = value
	end

	return object
end

------------------------------------------------------------------------------
-- STATIC

local ID = 1

function Interaction.new(part : BasePart, distance : Number?, button : Enum.KeyCode?, billboard: BillboardGui?, iconButton: ImageButton?)
	assert(part, "Part must be defined")
	assert(part:IsA("BasePart"), "Part must be a BasePart")

	local InteractionController = Knit.Controllers.InteractionController

	local self = setmetatable({}, Interaction)
	self._maid = Maid.new()
	self.state = true
	self.ID = ID
	ID += 1

	self.part = part
	self.distance = distance or DEFAULT_DISTANCE
	self.button = button or DEFAULT_BUTTON
	self.billboard = billboard 
	self.iconButton = iconButton 

	self.EnteredRange = Signal.new()
	self.LeftRange = Signal.new()
	self.InteractedStart = Signal.new()
	self.InteractedEnd = Signal.new()

	self.visible = false
	self:CreateBillboard()

	InteractionController:AddInteraction(self)
	self._maid:GiveTask(self.part.AncestryChanged:Connect(function()
        if self.part:IsDescendantOf(game) then return end
        self:Destroy()
    end))

	return self
end

------------------------------------------------------------------------------

-- create the visuals
function Interaction:CreateBillboard()
	self.billboard = self.billboard or applyProperties(Instance.new("BillboardGui"), {
		Size = UDim2.new(2, 0, 2, 0),
		AlwaysOnTop = true,
		Active = true,
		Enabled = self.visible,
		Parent = PlayerGui,
		Adornee = self.part
	})

	self.iconButton = self.iconButton or applyProperties(Instance.new("ImageButton"), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5568566251",
		Active = true,
		Parent = self.billboard
	})

	self.iconButton.MouseButton1Down:Connect(function ()
		self:Press()
	end)

	self.iconButton.MouseButton1Up:Connect(function ()
		self:Release()
	end)
	
	self._maid:GiveTask(self.billboard)
end

-- disable/enable the interaction
function Interaction:SetState(newState)
	self.state = newState
	self:Hide()
end

-- when the user starts to press the button/key
function Interaction:Press()
	if not self.state then
		return
	end
	
	TweenService:Create(self.iconButton, TweenInfo.new(0.1), {Size = UDim2.new(0.8, 0, 0.8, 0)}):Play()
	self.InteractedStart:Fire()
end

-- when the user releases the button/key
function Interaction:Release()
	if not self.state then
		return
	end
	
	TweenService:Create(self.iconButton, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	self.InteractedEnd:Fire()
end

--[[
	Plays the open animation, and sets the visibility
]]
function Interaction:Open()
	if not self.state then
		return
	end

	self.EnteredRange:Fire()
	self.visible = true

	TweenService:Create(self.iconButton, TweenInfo.new(0.6, Enum.EasingStyle.Bounce), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	self.billboard.Enabled = self.visible
end

-- Determines if the UI should play the open animation, and sets the button state to keyboard button
function Interaction:Show()
	if not self.state then
		return
	end

	if not self.visible then
		self:Open()
	end

	self.iconButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
end

-- Determines if the UI should play the open animation, and sets the button state to mouse click
function Interaction:ShowClick()
	if not self.state then
		return
	end

	if not self.visible then
		self:Open()
	end

	self.iconButton.ImageColor3 = Color3.fromRGB(255, 0, 0)
end

-- Animates the UI to hide
function Interaction:Hide()
	if not self.visible then
		return
	end

	self.LeftRange:Fire()
	self.visible = false
	TweenService:Create(self.iconButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 0, 0, 0)}):Play()
	
	delay(0.1, function ()
		self.billboard.Enabled = self.visible
	end)
end

-- removes the interaction
function Interaction:Destroy()
	local InteractionController = Knit.Controllers.InteractionController
	InteractionController:RemoveInteraction(self)
	self._maid:DoCleaning() --Destroy
	setmetatable(self, nil)
end


return Interaction