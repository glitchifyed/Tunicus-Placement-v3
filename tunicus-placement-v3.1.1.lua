--[[
	Written by Tunicus
	V2 Made 20/10/2017 - tunicus (date format: dd/mm/yy)
	V3 Made 13/11/2021 - glitchifyed
	V3.1.1 Made 15/7/2022 - glitchifyed
	Modified by glitchifyed (V3-V3.1.1)
	V2 Model link: https://www.roblox.com/library/1122124371
	V3.1.1 Model link: https://www.roblox.com/library/7980966840
	V2 Youtube Tutorial: https://www.youtube.com/watch?v=8PKDBTBUTOc (V2 tutorial, some things in the video have slight modifications when being used)
	Updated Youtube Tutorial: potentially coming soon
	Developer Forum post: https://devforum.roblox.com/t/read-solution-first-tunicus-grid-placement-module-v3-open-source/1547553
	V3+ Github: https://github.com/glitchifyed/Tunicus-Placement-v3
	Giving credit is optional (would be a nice thing to do though. make sure to credit both tunicus and glitchifyed)
	
	
	V3.1.1 Changelog
		- Placing non-hydraulic items on platforms should now be possible without the item colliding with nothing
	
	V3.1 Changelog (continued by glitchifyed)
		- Placing items on top of platforms should now work better than before
		- Fixed issues with the grid size not being 3
		- Made changes to legs so that they will presumably be rotated correctly on top of platforms. Also made them more accurate
		- Updated the server code (refer to the .rbxl file on Github). Now you cna place a platform with items on top
		- Note: when placing a platform with items on it you may need to hover off the base and back on for the Y positions to be correct. Eventually I do want to fix this but I've spent too long on V3.1 already
	
	V3 Changelog (continued by glitchifyed)
		- Now supports hydraulic items (model attributes such as minHeight, maxHeight, height etc)
		- Now supports platform items. Platforms are compatible on all platforms. Make sure you have a part in your platform item called "platform". (items you place that can have other items on top of them, including placement on multiple platforms!!!)
		- Automatically adjusting hydraulic item legs (any part named "leg" that is parented to a model named legs inside the object model will adjust to the object's custom height. Every part inside the legs model that isn't named "leg" will stay where they were before)
		- Fade in/out grid, custom grid color
		- Customisable selection boxes
		- Hold mouse to place (with HOLD_TO_PLACE setting)
		- An option to disable placement wobble
		- An option to hide the core gui when placement is initialised
		- Easily customisable keybinds with full Xbox controller/gamepad support
		- Small change to plane:enable(): - plane:enable(array models, Instance previewObject, bool prealigned) *NOT COMPATIBLE WITH V2, BE SURE TO EDIT!*
			- first argument is an array of items to place. Their positions and rotations relative to eachother designate their spacing when multi-placing
			- second argument is an instance that determines the parent of the placement objects
			- third argument is whether the array of items is already positioned according to the rotation of the plane
		- Because of platforms this module will NOT support rotations that aren't at an increment of 90 degrees.
	
	V2 Changelog
		- Now aligns to any plane (designated by baseplate rotation)
		- Rotation tweening
		- Multi-place
		- Touch compatibility (for positioning)
		- plane.stateChanged signal for implementing custom changes during item collision or loading
		- plane:setLoading(bool loading)
		 	- when set to true, locks the model in place and prevents further placing (useful for waiting for remote function responses)
			- set to false to disable
		- plane:enable(array models, bool prealigned) *NOT COMPATIBLE WITH V1, BE SURE TO EDIT!*
			- first argument is an array of items to place. Their positions and rotations relative to eachother designate their spacing when multi-placing
			- second argument is whether the array of items is already positioned according to the rotation of the plane
			
	Usage instructions
		This is a barebones module intended for placement handling ONLY, inventory management and alike are up to the developer. The goal here is initiate placement,
			and if the user places the item, return the location they placed it at
		
		To start with, require the module in a local script(obviously). I recommend placing it somewhere where it won't be reset on player death
			local placement = require(moduleObject)
			
		Now to create your placement object, you'll need 3 things
			Plane - Placement surfaces are designated as planes and are represented by a rectangular part
			Obstacles - A model or some other holder where all of the currently placed items are stored. Items here are expected to be models and have a primary part
			Grid Size - Size of your grid in studs, most sandbox tycoons use 3 (the plane's x and z size must be divisible by the grid size!)
		
		Once you have these three arguments, create your placement object
			local object = placement.new(plane, obstacles, grid)
			
		Now to initiate placement, you'll need an item. Items must be models, have a primary part, and their x and z size must be evenly divisible by your grid size
		For the sake of flexibility, the only properties affected during placement are Hitbox.Color, Hitbox.Transparency, Hitbox.Anchored, Hitbox.CanCollide, and the model's CFrame
		If you want other placement properties, such as the model being transparent or CanCollide false, it's your responsibility to set that prior to placement
		
		Now to initiate placement, call the enable method on your object with the model(s) as the argument in the form of an array (the model should probably be a clone)
			local onObjectPlaced = object:enable({models}, modelParent, prealigned)
			
		You'll notice I'm storing the result as a variable, this is because the enable function returns a signal that fires whenever the item is successfully placed. In order to detect this, use the connect function,
			as you would any other signal such as Part.Touched or Player.PlayerAdded
			
				onObjectPlaced:connect(function(array CFrames) -- The array returns the CFrames of each of the models in the same order they were provided in the models table
					print(location)	
				end)
		
		If you kept the above code though, placement would continue. I can't stress this enough, this module is strictly for placement handling, YOU are responsible for the rest. First of all, when the user places an item,
			you might want to disable placement. 							
			
		To disable placement while it's active, do
			object:disable()
		or
			placement.disable()
			
		
		I'd imagine you actually want to place the model itself, and since you're a competent game developer that uses FilteringEnabled, you'll have to do this server sided. Here's some untested sample code to give you
			an idea of what to do
			
			SERVER SCRIPT
					local remoteEvent = Instance.new("RemoteEvent", game:GetService("ReplicatedStorage")
					remoteEvent.Name = "PlacementEvent"
					
					local itemBin = game:GetService("ReplicatedStorage").items -- folder full of all the items in the game				
					local gridSize = 3 -- your grid size here, 3 is an example as many placement systems use 3
					
					remoteEvent.OnServerEvent:connect(function(player, itemName, location, height)
						if [insert inventory and location inside base check here] then
							local item = itemBin[itemName]:clone()
							item.Parent = [insert player's base model here]
							item:PivotTo(location + Vector3.new(0, height, 0) * gridSize))
						end
					end)
				
			LOCAL SCRIPT
				
					local gridSize = 3
					local obstacles = workspace.Items
					local plane = workspace.Baseplate -- make sure the plane has X and Z sizes that are a multiple of gridSize
				
					local placement = require(moduleObject)
					local object = placement.new(plane, obstacles, gridSize)
					
					local button = guiButton
					local textBox = textBox
					
					local itemBin = game:GetService("ReplicatedStorage").items
					local placementEvent = game:GetService("ReplicatedStorage"):WaitForChild("PlacementEvent")
					
					local itemPlacingFolder = workspace.ItemPlacingFolder
					
					local function endPlacement()
						if (placement.currentPlane) then
							object:disable()
						end
					end				
					
					local function itemPlaced(locations, heights)
						placementEvent:FireServer(placementModel.Name, locations[1], heights[1])
						endPlacement()
					end			
					
					button.MouseButton1Click:connect(function()
						local item = itemBin:FindFirstChild(textBox.Text)
						
						if (item and not placement.currentPlane) then
							object:enable({item:clone()}, itemPlacingFolder) -- if the items are already placed and you're picking them up and moving them you might want to put a true as the third argument
						end
					end)
--]]

--[[
	CONSTANTS (FEEL FREE TO EDIT)
--]]

--// PLACEMENT SETTINGS
local INTERPOLATION = true -- whether placement smoothing is enabled
local WOBBLE_ITEMS = true -- whether items wobble when moving (does nothing if interpolation is false)
local INTERPOLATION_DAMP = .21 -- how fast smoothing is, make it a value [0, 1]
local ROTATION_SPEED = .2 -- rotation tween speed in seconds

local PLACEMENT_COOLDOWN = .1 -- how quickly the user can place (minimum time in seconds between placing items)
local HOLD_TO_PLACE = true -- if the user can hold the place key to place

--// PLACEMENT COLORS, TRANSPARENCY, FADING
local COLLISION_COLOR3 = BrickColor.Red().Color -- color of the hitbox when object collides
local COLLISION_TRANSPARENCY = .5 -- transparency of the hitbox when object collides

local NORMAL_COLOR3 = BrickColor.White().Color -- color of the hitbox
local NORMAL_TRANSPARENCY = .8 -- transparency of the hitbox

local LOAD_COLOR3 = Color3.fromRGB(226, 155, 64) -- color of the hitbox when loading
local LOAD_TRANSPARENCY = .6 -- transparency of the hitbox when loading

local HIT_BOX_FADE_TIME = .5 -- primarypart/selection box fade time in seconds. set to 0 to instantly change/appear

--// SELECTION BOXES
local SELECTION_BOX_TRANSPARENCY = 0 -- selection box transparency. set to 1 for no selection boxes
local SELECTION_BOX_COLOR3 = Color3.new(1, 1, 1) -- selection box color. set to nil for a custom color system (you have to code that yourself)
local SELECTION_BOX_PLACING_THICKNESS = .08 -- selection box thickness on objects the user is placing
local SELECTION_BOX_OBSTACLE_THICKNESS = .05 -- selection box thickness on obstacles

--// GRID SETTINGS
local GRID_TEXTURE = "rbxassetid://5964183792" -- texture of the grid space, set to nil if you don't want a visible grid
local GRID_COLOR3 = Color3.fromRGB(2, 145, 193) -- color of the grid texture
local GRID_TRANSPARENCY = .3 -- the transparency of the grid while placing
local GRID_FADE_TIME = .5 -- the amount of seconds that the grid takes to fade. set to 0 to instantly appear
local TEXTURE_ON_PLATFORMS = true -- if the grid texture is also put on platforms

--// CONTROLS
local OVERRIDE_CONTROLS = false -- whether the keybinds below work or not
local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value--9 -- input priority of default controls

local PLACE_KEYBINDS = {Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2} -- placement keybinds (pc, xbox)
local ROTATE_KEYBINDS = {Enum.KeyCode.R, Enum.KeyCode.ButtonL2} -- rotate keybinds (pc, xbox)
local HYDRAULIC_UP_KEYBINDS = {Enum.KeyCode.One, Enum.KeyCode.ButtonR1} -- hydraulic up keybinds (pc, xbox)
local HYDRAULIC_DOWN_KEYBINDS = {Enum.KeyCode.Two, Enum.KeyCode.ButtonL1} -- hydraulic down keybinds (pc, xbox)
local CANCEL_KEYBINDS = {Enum.KeyCode.Q, Enum.KeyCode.ButtonB} -- cancel placement keybinds (pc, xbox)

--// CORE GUI
local CORE_GUI_DISABLE = {Enum.CoreGuiType.Backpack} -- core gui to disable when placing


--[[
	DO NOT EDIT PAST THESE LINES UNLESS YOU KNOW WHAT YOU'RE DOING - lol i do though
--]]

local module = {}

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local contextActionService = game:GetService("ContextActionService")
local userInputService = game:GetService("UserInputService")

local touch = userInputService.TouchEnabled

local currentPlane
local currentBase
local currentPlatforms
local currentPlatform
local currentInput

local lastPlatforms

local coreInputs = {Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight}

local newHit

local obstacleAdded
local obstacleRemoved

local renderConnection = nil

local cx, cy, cz, cr = 0, 0, 0, 0
local currentObjects = {}
local currentEvent
local currentTextures
local currentPosition = Vector3.new(0, 0, 0)
local ax, az

local currentExtentsX
local currentExtentsZ
local currentYAxis
local currentXAxis
local currentZAxis
local currentAxis

local ox, oy, oz -- do
local dxx, dxy, dxz
local dzx, dzy, dzz

local min = math.min
local max = math.max
local abs = math.abs

local springVelocity = Vector3.new(0, 0, 0)
local springPosition = Vector3.new(0, 0, 0)
local tweenGoalRotation = 0 -- springs arent worth effort for rotation
local tweenStartRotation = 0
local tweenCurrentRotation = 0
local tweenAlpha = 1

local lastRenderCycle = tick()
local lastPlacement = tick()

local placing

local platformSize = game.ReplicatedStorage.platformSize.Value

local function createSelectionBox(model, obstacle)
	for _, obj in pairs(model.PrimaryPart:GetChildren()) do
		if obj:IsA("SelectionBox") then
			obj:Destroy()
		end
	end
	
	if SELECTION_BOX_TRANSPARENCY < 1 then
		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Color3 = SELECTION_BOX_COLOR3

		if HIT_BOX_FADE_TIME > 0 then
			selectionBox.Transparency = 1

			tweenService:Create(selectionBox, TweenInfo.new(HIT_BOX_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = SELECTION_BOX_TRANSPARENCY}):Play()
		else
			selectionBox.Transparency = SELECTION_BOX_TRANSPARENCY
		end

		selectionBox.LineThickness = obstacle and SELECTION_BOX_OBSTACLE_THICKNESS or SELECTION_BOX_PLACING_THICKNESS

		selectionBox.Adornee = model.PrimaryPart
		selectionBox.Parent = model.PrimaryPart
	end
end

local function round(n, to)
	return n % to ~= 0 and (n % to) > to/2 and (n + to - (n % to)) or (n - (n % to))	
end

local function project(px, py, pz)
	px, py, pz = px - ox, py - oy, pz - oz

	return px * dxx + py * dxy + pz * dxz, px * dzx + py * dzy + pz * dzz
end

local function translate(px, pz, r)
	if (r == 0) then
		return px, pz
	elseif (r == 1) then
		return -pz, px
	elseif (r == 2) then
		return -px, -pz
	elseif (r == 3) then
		return pz, -px
	end

	--  or for all angles
	--	r = r * math.pi/2
	--	return math.cos(r) * px - math.sin(r) * pz,  math.sin(r) * px + math.cos(r) * pz	
end

local function angleLerp(a, b, d) -- to avoid angle jump
	local x1, y1 = math.cos(a), math.sin(a)
	local x2, y2 = math.cos(b), math.sin(b)

	return math.atan2(y1 + (y2 - y1) * d, x1 + (x2 - x1) * d)
end

local function calculateExtents(part, cf)
	local cf = cf or part.CFrame

	local edgeA = cf * CFrame.new(-part.Size.X/2, 0, 0)
	local edgeB = cf * CFrame.new(part.Size.X/2, 0, 0)
	local edgeC = cf * CFrame.new(0, 0, part.Size.Z/2)
	local edgeD = cf * CFrame.new(0, 0, -part.Size.Z/2)

	local edgeAx, edgeAz = project(edgeA.X, edgeA.Y, edgeA.Z)
	local edgeBx, edgeBz = project(edgeB.X, edgeB.Y, edgeB.Z)
	local edgeCx, edgeCz = project(edgeC.X, edgeC.Y, edgeC.Z)
	local edgeDx, edgeDz = project(edgeD.X, edgeD.Y, edgeD.Z)

	local extentsX = max(edgeAx, edgeBx, edgeCx, edgeDx) - min(edgeAx, edgeBx, edgeCx, edgeDx)
	local extentsZ = max(edgeAz, edgeBz, edgeCz, edgeDz) - min(edgeAz, edgeBz, edgeCz, edgeDz)

	return round(extentsX, currentPlane.grid), round(extentsZ, currentPlane.grid)
end

local states = {
	neutral = 1;
	collision = 2;
	loading = 3;
}

module.states = states

local function setState(object, state, downward)
	if (object.state and (object.state == state or (object.state > state and not downward))) then
		return
	end

	object.state = state
	
	local stateColor, stateTransparency
	local selectionColor, selectionTransparency = SELECTION_BOX_COLOR3, SELECTION_BOX_TRANSPARENCY
	
	if (state == 1) then
		if (NORMAL_COLOR3) then
			stateColor = NORMAL_COLOR3
		end
		
		if (NORMAL_TRANSPARENCY) then
			stateTransparency = NORMAL_TRANSPARENCY
		end
	elseif (state == 2) then
		if (COLLISION_COLOR3) then
			stateColor = COLLISION_COLOR3
			selectionColor = COLLISION_COLOR3
		end
		
		if (COLLISION_TRANSPARENCY) then
			stateTransparency = COLLISION_TRANSPARENCY
			selectionTransparency = COLLISION_TRANSPARENCY
		end
	elseif (state == 3) then
		if (LOAD_COLOR3) then
			stateColor = LOAD_COLOR3
			selectionColor = LOAD_COLOR3
		end
		
		if (LOAD_TRANSPARENCY) then
			stateTransparency = LOAD_TRANSPARENCY
			selectionTransparency = LOAD_TRANSPARENCY
		end
	end
	
	if stateColor then
		if HIT_BOX_FADE_TIME > 0 then
			tweenService:Create(object.model.PrimaryPart, TweenInfo.new(HIT_BOX_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Color = stateColor}):Play()
			
			if SELECTION_BOX_TRANSPARENCY < 1 then
				tweenService:Create(object.model.PrimaryPart.SelectionBox, TweenInfo.new(HIT_BOX_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Color3 = selectionColor}):Play()
			end
		else
			object.model.PrimaryPart.Color = stateColor
			
			if SELECTION_BOX_TRANSPARENCY < 1 then
				object.model.PrimaryPart.SelectionBox.Color3 = selectionColor
			end
		end
	end
	
	if stateTransparency then
		if HIT_BOX_FADE_TIME > 0 then
			tweenService:Create(object.model.PrimaryPart, TweenInfo.new(HIT_BOX_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = stateTransparency}):Play()
			
			--[[if SELECTION_BOX_TRANSPARENCY < 1 then
				tweenService:Create(object.model.PrimaryPart.SelectionBox, TweenInfo.new(HIT_BOX_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = selectionTransparency}):Play()
			end]]
		else
			object.model.PrimaryPart.Transparency = stateTransparency
			
			--[[if SELECTION_BOX_TRANSPARENCY < 1 then
				object.model.PrimaryPart.SelectionBox.Transparency = selectionTransparency
			end]]
		end
	end

	currentPlane.stateEvent:Fire(object.model, state)
end

--[[
	status
	model
	px, pz, r
	sx, sz
--]]

local function setObjectY(obj)
	obj.model:SetAttribute("y", (obj.model:GetAttribute("height") or 0) + (obj.platformY or 0))
end

local function floatEqual(a, b)
	return (abs(a - b) < .01)
end

local function floatGreater(a, b)
	return (a - b) > .01
end

local function floatLesser(a, b)
	return (b - a) > .01
end

local function floatLesserOrEqual(a, b)
	return (b - a) > .01 or floatEqual(a, b)
end

local function floatGreaterOrEqual(a, b)
	return (a - b) > .01 or floatEqual(a, b)
end

local function obstacleCollision()
	local px, pz = cx, cz

	local collision = false

	for _, model in pairs(currentPlane.obstacles:GetChildren()) do
		if (model.PrimaryPart) then

			local extentsX1, extentsZ1 = calculateExtents(model.PrimaryPart)
			local x1, z1 = project(model.PrimaryPart.Position.X, model.PrimaryPart.Position.Y, model.PrimaryPart.Position.Z)			

			local extentsY1 = model.PrimaryPart.Size.Y

			local y1 = model.PrimaryPart.Position.Y - currentBase.Position.Y - currentBase.Size.Y / 2
			
			--local model_is_platform = model:FindFirstChild("platform") and model.plaform:IsA("BasePart")
			
			for i = 1, #currentObjects do
				local object = currentObjects[i]

				if (not object.collision) then
					local r = (object.r + cr) % 4			

					local x0, z0 = translate(object.px, -object.pz, cr)
					x0 = x0 + px
					z0 = z0 + pz

					local extentsX0, extentsZ0				

					if (r == 1 or r == 3) then
						extentsX0, extentsZ0 = object.sz, object.sx
					else
						extentsX0, extentsZ0 = object.sx, object.sz
					end	

					if not object.model:GetAttribute("y") then
						setObjectY(object)
					end

					local extentsY0 = object.sy
					local y0 = object.model:GetAttribute("y") * currentPlane.grid + extentsY0 / 2
					
					if (floatLesser(x0 - extentsX0/2, x1 + extentsX1/2) and floatGreater(x0 + extentsX0/2, x1 - extentsX1/2) and floatLesser(z0 - extentsZ0/2, z1 + extentsZ1/2) and floatGreater(z0 + extentsZ0/2, z1 - extentsZ1/2) and floatLesser(y0 - extentsY0/2, y1 + extentsY1/2) and floatGreater(y0 + extentsY0/2, y1 - extentsY1/2)) then
						collision = true
						object.collision = true
						setState(object, states.collision)
					end
				end
			end
		end
	end

	for i = 1, #currentObjects do
		local object = currentObjects[i]

		if (not object.collision and object.state == states.collision) then
			setState(object, states.neutral, true)
		else
			object.collision = nil
		end
	end

	return not collision
end

local function inputCapture() -- converts user inputs to 3d position, built in mobile compatibility
	local position
	
	local rayOrigin, rayDirection
	
	if (touch) then
		local camera = workspace.CurrentCamera

		rayOrigin, rayDirection = camera.CFrame.Position, camera.CFrame.LookVector
	else
		rayOrigin, rayDirection = mouse.UnitRay.Origin, mouse.UnitRay.Direction
	end
	
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {currentPlane.base, table.unpack(currentPlatforms)}
	rayParams.FilterType = Enum.RaycastFilterType.Whitelist
	rayParams.IgnoreWater = true
	
	local result = workspace:Raycast(rayOrigin, rayDirection * 999, rayParams)
	
	local hit, p
	
	if result then
		hit, p = result.Instance, result.Position
	end
	
	if not newHit then
		local currentHit = currentPlatform or currentBase

		newHit = hit ~= currentHit and currentHit or nil
	end

	if (hit) then
		position = p

		if hit ~= currentBase then
			currentPlatform = hit
		else
			currentPlatform = nil
		end
	else
		currentPlatform = nil
	end

	return position, cr
end

local resting = false

local function calc(position, rotation, force)
	if (not currentPlane or currentPlane.loading) then
		return
	end

	force = force == true

	local ux, uz

	if (position) then
		ux, uz = project(position.X, position.Y, position.Z)
	else
		ux, uz = ax or 0, az or 0
	end

	local nr = rotation or cr

	local nx = round(ux, currentPlane.grid)
	local nz = round(uz, currentPlane.grid)

	local extentsX, extentsZ = translate(currentExtentsX, currentExtentsZ, nr)
	extentsX = abs(extentsX)
	extentsZ = abs(extentsZ)

	if (floatEqual(extentsX/2 % currentPlane.grid, 0)) then
		nx = nx + currentPlane.grid/2
	end

	if (floatEqual(extentsZ/2 % currentPlane.grid, 0)) then
		nz = nz + currentPlane.grid/2
	end

	nx = nx + currentPlane.offsetX
	nz = nz + currentPlane.offsetZ

	local borderX = currentPlane.size.X/2
	local borderZ = currentPlane.size.Z/2

	ax = ux
	az = uz

	if (nx + extentsX/2 > borderX) then
		nx = nx - (nx + extentsX/2 - borderX)
	elseif (nx - extentsX/2 < -borderX) then
		nx = nx - (nx - extentsX/2 + borderX)
	end

	if (nz + extentsZ/2 > borderZ) then
		nz = nz - (nz + extentsZ/2 - borderZ)
	elseif (nz - extentsZ/2 < -borderZ) then
		nz = nz - (nz - extentsZ/2 + borderZ)
	end

	local unrest = force or nx ~= cx or nz ~= cz or cr ~= nr
	
	local newHitIsntBase = newHit and newHit ~= currentBase
	
	local platformNumber = #currentPlatforms
	
	if not unrest or currentPlatform or newHit or lastPlatforms ~= platformNumber then
		if lastPlatforms ~= platformNumber then
			lastPlatforms = platformNumber
		end
		
		local extentsX1, extentsZ1, x1, z1, px, pz, cr
		
		local currentHit
		
		if currentPlatform or newHitIsntBase then
			currentHit = currentPlatform or newHit
			
			extentsX1, extentsZ1 = calculateExtents(currentHit)
			x1, z1 = project(currentHit.Position.X, currentHit.Position.Y, currentHit.Position.Z)
			px, pz, cr = nx, nz, nr
		end
		
		local yPlatforms = {}
		
		if currentPlatform and currentHit then
			for _, platform in pairs(currentPlatforms) do
				if platform.Position.Y == currentHit.Position.Y then
					table.insert(yPlatforms, platform)
				end
			end
		end
		
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = yPlatforms
		params.FilterType = Enum.RaycastFilterType.Whitelist
		params.IgnoreWater = true
		
		local no_object_on_platforms = true
		
		for _, obj in pairs(currentObjects) do
			if #obj.on_platforms ~= 0 then
				no_object_on_platforms = nil
			end
			
			if not no_object_on_platforms then
				continue
			end
		end
		
		for _, obj in pairs(currentObjects) do
			if not unrest and (INTERPOLATION and Vector3.new(0, obj.yVelocity, 0).magnitude > 0 or (not obj.lastPosition or obj.lastPosition ~= obj.model:GetPivot())) then
				unrest = true
				
				if not INTERPOLATION then
					obj.lastPosition = obj.model:GetPivot()
				end

				break
			end
			
			local platformY = 0

			if currentPlatform and currentHit and no_object_on_platforms then
				local r = (obj.r + cr) % 4			

				local x0, z0 = translate(obj.px, -obj.pz, cr)
				x0 = x0 + px
				z0 = z0 + pz

				local extentsX0, extentsZ0				

				if (r == 1 or r == 3) then
					extentsX0, extentsZ0 = obj.sz, obj.sx
				else
					extentsX0, extentsZ0 = obj.sx, obj.sz
				end
				
				local extentsY0 = obj.sy
				local y0 = obj.model:GetAttribute("y") * currentPlane.grid
				
				local points = {}
				
				for x = x0 - extentsX0 / 2, x0 + extentsX0 / 2 + 0.001, currentPlane.grid / 2 do
					for z = z0 - extentsZ0 / 2, z0 + extentsZ0 / 2 + 0.001, currentPlane.grid / 2 do
						points[Vector3.new(x, 0, z)] = false
					end
				end
				
				local function allPointsInsideAPlatform()
					for point, inside in pairs(points) do
						if not inside then
							return
						end
					end
					
					return true
				end
				
				local pointsInsidePlatform
				
				for _, platform in pairs(yPlatforms) do
					local extentsX2, extentsZ2 = calculateExtents(platform)
					local x2, z2 = project(platform.Position.X, platform.Position.Y, platform.Position.Z)
					
					for point, inside in pairs(points) do
						if not inside then
							if floatLesser(point.X - currentPlane.grid / 2, x2 + extentsX2 / 2) and floatGreater(point.X + currentPlane.grid / 2, x2 - extentsX2 / 2) and floatLesser(point.Z - currentPlane.grid / 2, z2 + extentsZ2 / 2) and floatGreater(point.Z + currentPlane.grid / 2, z2 - extentsZ2 / 2) then
								points[point] = true
							end
						end
						
						pointsInsidePlatform = allPointsInsideAPlatform()
						
						if pointsInsidePlatform then
							break
						end
					end
					
					if pointsInsidePlatform then
						break
					end
				end
				
				if pointsInsidePlatform then
					platformY = (currentHit.Position.Y + platformSize / 2 - currentBase.Position.Y - currentBase.Size.Y / 2) / currentPlane.grid
				end
			end
			
			if newHit then
				newHit = nil
			end
			
			local on_platform_heights = {}
			
			for _, platform in pairs(obj.on_platforms) do
				local platform_y_pos = platform:GetAttribute("y") * currentPlane.grid + platform.platform.Size.Y
				
				if not table.find(on_platform_heights, platform_y_pos) then
					table.insert(on_platform_heights, platform_y_pos)
				end
				
				if #on_platform_heights > 1 then
					break
				end
			end
			
			if #on_platform_heights == 1 then
				obj.model:SetAttribute("on_platform_y", on_platform_heights[1] / currentPlane.grid)
			end
			
			obj.platformY = platformY + (obj.model:GetAttribute("on_platform_y") or 0)
		end
	end

	if (unrest) then
		cx, cz, cr = nx, nz, nr
		resting = false
		currentPosition = (Vector3.new(ox, oy, oz) + currentXAxis * nx + currentZAxis * nz) 
		obstacleCollision()
	end
end

local function render()
	if (resting) then
		return
	end
	
	local objects_are_on_platforms

	for _, object in pairs(currentObjects) do
		if not objects_are_on_platforms and #object.on_platforms ~= 0 then
			objects_are_on_platforms = true
		end

		local legs = object.model:FindFirstChild("legs")

		if legs and legs:IsA("Model") then
			for _, part in pairs(legs:GetChildren()) do
				if part:IsA("BasePart") then
					local distance = part:GetAttribute("distance")
					local og_rot = part:GetAttribute("og_rotation")

					if not distance then
						distance = (object.model.PrimaryPart.Position - part.Position) * Vector3.new(1, 0, 1)

						part:SetAttribute("distance", distance)
					end
				end
			end
		end
	end

	local extra_angle = CFrame.Angles(0, 0, 0)

	if objects_are_on_platforms then
		extra_angle = CFrame.Angles(0, math.rad(90), 0)
	end

	if (INTERPOLATION) then
		local delta = 1/60

		springVelocity = (springVelocity + (currentPosition - springPosition)) * INTERPOLATION_DAMP * 60 * delta
		springPosition += springVelocity

		local extentsX, extentsZ = translate(currentExtentsX, currentExtentsZ, cr)

		local vx, vz = 9 * springVelocity:Dot(currentXAxis)/abs(extentsX), 9 * springVelocity:Dot(currentZAxis)/abs(extentsZ)
		local r

		if (not floatEqual(tweenGoalRotation, cr * math.pi/2)) then
			tweenStartRotation = tweenCurrentRotation
			tweenGoalRotation = cr * math.pi/2
			tweenAlpha = 0
		end

		if (tweenAlpha < 1) then
			tweenAlpha = min(1, tweenAlpha + delta/ROTATION_SPEED)
			tweenCurrentRotation = angleLerp(tweenStartRotation, tweenGoalRotation, 1 - (1 - tweenAlpha)^2)
			r = tweenCurrentRotation
		else
			r = cr * math.pi/2
		end


		local effectAngle = WOBBLE_ITEMS and CFrame.Angles(math.sqrt(abs(vz/100)) * math.sign(vz), 0, math.sqrt(abs(vx/100)) * math.sign(vx)) or CFrame.Angles(0, 0, 0)

		local rotationCFrame = currentAxis * effectAngle * CFrame.Angles(0, r, 0)
		local centerCFrame = rotationCFrame + springPosition

		local objMagStopped = true
		
		for i = 1, #currentObjects do
			local object = currentObjects[i]

			setObjectY(object)

			local y = object.model:GetAttribute("y") * currentPlane.grid

			object.yVelocity = (object.yVelocity + (y - object.yPosition)) * INTERPOLATION_DAMP * 60 * delta
			object.yPosition += object.yVelocity

			if objMagStopped and Vector3.new(0, object.yVelocity, 0).magnitude >= .01 then
				objMagStopped = nil
			end

			local x, z = object.px, object.pz			

			object.model:PivotTo(centerCFrame * CFrame.Angles(0, object.r * math.pi/2, 0) + rotationCFrame * Vector3.new(x, object.sy/2, z) + Vector3.new(0, object.yPosition, 0))
			
			local legs = object.model:FindFirstChild("legs")
			
			if legs and legs:IsA("Model") then
				local cframe = object.model:GetPivot() * CFrame.new(0, -object.sy / 2, 0)
				local height = object.model:GetAttribute("height")
				
				local extra_angle = CFrame.Angles(0, 0, 0)

				if #object.on_platforms ~= 0 then
					extra_angle = CFrame.Angles(0, math.rad(90), 0)
				end
				
				for _, part in pairs(legs:GetChildren()) do
					if part:IsA("BasePart") then
						local distance = part:GetAttribute("distance")
						local og_rot = part:GetAttribute("og_rotation")

						if not distance then
							distance = (object.model.PrimaryPart.Position - part.Position) * Vector3.new(1, 0, 1)
							
							part:SetAttribute("distance", distance)
						end
						
						local partSize
						
						if part.Name == "leg" then
							partSize = Vector3.new(0, object.yPosition - object.platformY * currentPlane.grid - currentBase.Position.Y - currentBase.Size.Y / 2, 0)
							
							part.Size = Vector3.new(part.Size.X, 0, part.Size.Z) + partSize
							part.CFrame = (cframe * extra_angle) * CFrame.new(distance - partSize / 2)
						else
							partSize = Vector3.new(0, object.yPosition - object.platformY * currentPlane.grid - currentBase.Position.Y - currentBase.Size.Y / 2 - part.Size.Y / 2, 0)
							
							part.CFrame = (cframe * extra_angle) * CFrame.new(distance - partSize)
						end
					end
				end
			end
		end		

		if (springVelocity.magnitude < .01 and objMagStopped and tweenAlpha >= 1) then
			resting = true
		end
	else
		local rotationCFrame = currentAxis * CFrame.Angles(0, cr * math.pi/2, 0)		

		for i = 1, #currentObjects do
			local object = currentObjects[i]
			local x, z = object.px, object.pz

			setObjectY(object)

			object.model:PivotTo(rotationCFrame * CFrame.Angles(0, object.r * math.pi/2, 0) + rotationCFrame * Vector3.new(x, object.sy/2, z) + currentPosition + Vector3.new(0, object.model:GetAttribute("y") * currentPlane.grid, 0))
			
			local legs = object.model:FindFirstChild("legs")

			if legs and legs:IsA("Model") then
				local cframe = object.model:GetPivot() - Vector3.new(0, object.sy / 2, 0)
				local height = object.model:GetAttribute("height")
				
				local extra_angle = CFrame.Angles(0, 0, 0)

				if #object.on_platforms ~= 0 then
					extra_angle = CFrame.Angles(0, math.rad(90), 0)
				end
				
				for _, part in pairs(legs:GetChildren()) do
					if part:IsA("BasePart") then
						local distance = part:GetAttribute("distance")

						if not distance then
							distance = (object.model.PrimaryPart.Position - part.Position) * Vector3.new(1, 0, 1)

							part:SetAttribute("distance", distance)
						end

						local partSize

						if part.Name == "leg" then
							partSize = Vector3.new(0, height * currentPlane.grid, 0)

							part.Size = Vector3.new(part.Size.X, 0, part.Size.Z) + partSize
							part.CFrame = (cframe * extra_angle) * CFrame.new(distance - partSize / 2)
						else
							partSize = Vector3.new(0, height * currentPlane.grid - part.Size.Y / 2, 0)

							part.CFrame = (cframe * extra_angle) * CFrame.new(distance - partSize)
						end
					end
				end
			end
		end

		resting = true
	end
end

local function run(display)
	local position, rotation = inputCapture()

	if (position or rotation) then
		calc(position, rotation)
		if (display) then
			render()
		end
	end
end

local function place()
	if (currentPlane and (obstacleCollision()) and (HOLD_TO_PLACE or (tick() - lastPlacement) >= PLACEMENT_COOLDOWN) and not currentPlane.loading) then
		lastPlacement = tick()

		local modelCFrames = {}
		local modelYPositions = {heights = {}, platforms = {}}

		for i = 1, #currentObjects do
			local object = currentObjects[i]
			modelCFrames[i] = currentAxis * CFrame.Angles(0, (object.r + cr) * math.pi/2, 0) +  (currentAxis * CFrame.Angles(0, cr * math.pi/2, 0)) * Vector3.new(object.px, object.sy/2, object.pz) + currentPosition
			modelYPositions.heights[i] = object.model:GetAttribute("height") or 0
			modelYPositions.platforms[i] = object.platformY or 0
		end

		currentEvent:Fire(modelCFrames, modelYPositions)		
	end
end

local function rotate()
	calc(nil, (cr + 1) % 4)
	render()
end

local function heights(x)
	local change = true

	for i, obj in pairs(currentObjects) do
		local model = obj.model

		local oldHeight = model:GetAttribute("height")		
		local height = oldHeight or x
		
		local min = model:GetAttribute("minHeight") or oldHeight or 0
		local max = model:GetAttribute("maxHeight") or oldHeight or 0
		
		height = math.clamp(height + x, min, max)
		
		if oldHeight ~= height then
			obj.newHeight = height

			resting = false
		else
			change = nil
		end
	end

	if change then
		for _, obj in pairs(currentObjects) do
			local model = obj.model

			model:SetAttribute("height", obj.newHeight)

			obj.newHeight = nil
		end
	end
end

local function inputRotate(_, userInputState, inputObject)
	if (currentPlane and userInputState == Enum.UserInputState.End) then
		rotate()
	end
end

local function inputPlace(_, userInputState, inputObject)
	if (currentPlane) then
		--place()
		
		if HOLD_TO_PLACE then
			local wasPlacing = placing
			
			placing = userInputState == Enum.UserInputState.Begin or nil
			
			if placing and not wasPlacing then
				local lastPlacement
				
				repeat
					local now = tick()
					
					if not lastPlacement or now >= lastPlacement + PLACEMENT_COOLDOWN then
						lastPlacement = now
						
						place()
					end
					
					runService.Heartbeat:Wait()
				until not placing
			end
		elseif userInputState == Enum.UserInputState.End then
			place()
		end
	end
end

local function findInput(input, tableOfInputs)
	return table.find(tableOfInputs, input.KeyCode) or table.find(tableOfInputs, input.UserInputType)
end

local function inputHeights(_, userInputState, inputObject)
	if (currentPlane and userInputState == Enum.UserInputState.End) then
		heights((findInput(inputObject, HYDRAULIC_UP_KEYBINDS)) and 1 or -1)
	end
end

local function inputCancel(_, userInputState, inputObject)
	if (currentPlane and userInputState == Enum.UserInputState.End) then
		currentPlane:disable()
	end
end

local function bindInputs()
	if (not currentInput and not OVERRIDE_CONTROLS) then
		currentInput = {}
		
		table.insert(currentInput, userInputService.InputBegan:Connect(function(input, gp)
			if not gp or findInput(input, coreInputs) then
				local state = Enum.UserInputState.Begin
				
				if findInput(input, PLACE_KEYBINDS) then
					inputPlace(_, state, input)
				elseif findInput(input, ROTATE_KEYBINDS) then
					inputRotate(_, state, input)
				elseif findInput(input, HYDRAULIC_UP_KEYBINDS) or findInput(input, HYDRAULIC_DOWN_KEYBINDS) then
					inputHeights(_, state, input)
				elseif findInput(input, CANCEL_KEYBINDS) then
					inputCancel(_, state, input)
				end
			end
		end))
		
		table.insert(currentInput, userInputService.InputEnded:Connect(function(input, gp)
			if not gp or findInput(input, coreInputs) then
				local state = Enum.UserInputState.End

				if findInput(input, PLACE_KEYBINDS) then
					inputPlace(_, state, input)
				elseif findInput(input, ROTATE_KEYBINDS) then
					inputRotate(_, state, input)
				elseif findInput(input, HYDRAULIC_UP_KEYBINDS) or findInput(input, HYDRAULIC_DOWN_KEYBINDS) then
					inputHeights(_, state, input)
				elseif findInput(input, CANCEL_KEYBINDS) then
					inputCancel(_, state, input)
				end
			end
		end))
	end
end

local function unbindInputs()
	if (currentInput and not OVERRIDE_CONTROLS) then
		for _, obj in pairs(currentInput) do
			obj:Disconnect()
		end
		
		currentInput = nil
	end
end

local function createTexture(obj)
	if GRID_TEXTURE and currentTextures then
		local texture = Instance.new("Texture")
		texture.Texture = GRID_TEXTURE
		texture.Face = Enum.NormalId.Top
		texture.StudsPerTileU = currentPlane.grid
		texture.StudsPerTileV = currentPlane.grid
		texture.Color3 = GRID_COLOR3

		if GRID_FADE_TIME > 0 then
			texture.Transparency = 1

			tweenService:Create(texture, TweenInfo.new(GRID_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = GRID_TRANSPARENCY}):Play()
		else
			texture.Transparency = GRID_TRANSPARENCY
		end
		
		table.insert(currentTextures, texture)
		
		texture.Parent = obj
	end
end

local function removeTexture(texture)
	if texture then
		if GRID_FADE_TIME > 0 then
			local gridTween = tweenService:Create(texture, TweenInfo.new(GRID_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 1})
			local connection

			connection = gridTween.Completed:Connect(function()
				connection:Disconnect()

				texture:Destroy()
			end)

			gridTween:Play()
		else
			texture:Destroy()
		end
	end
end

local function enablePlacement(plane, models, previewObject, prealigned)
	if (plane == currentPlane) then
		return
	elseif (currentPlane) then
		currentPlane:disable()
	end

	if (type(models) ~= "table") then
		models = {models}
	end

	lastRenderCycle = tick()

	currentPlane = plane
	currentBase = plane.base
	currentPlatforms = {}
	currentTextures = {}

	for _, obj in pairs(currentPlane.obstacles:GetChildren()) do
		if obj:IsA("Model") and obj.PrimaryPart then
			createSelectionBox(obj, true)
			
			if obj:FindFirstChild("platform") and obj.platform:IsA("BasePart") then
				table.insert(currentPlatforms, obj.platform)
				
				if (TEXTURE_ON_PLATFORMS) then
					createTexture(obj.platform)
				end
			end
		end
	end

	obstacleAdded = currentPlane.obstacles.ChildAdded:Connect(function(obj)
		runService.Heartbeat:Wait()

		if obj:IsA("Model") and obj.PrimaryPart then
			createSelectionBox(obj, true)
			
			if obj:FindFirstChild("platform") and obj.platform:IsA("BasePart") then
				table.insert(currentPlatforms, obj.platform)
				
				if (TEXTURE_ON_PLATFORMS) then
					createTexture(obj.platform)
				end
			end
		end
	end)

	obstacleRemoved = currentPlane.obstacles.ChildRemoved:Connect(function(obj)
		if obj:IsA("Model") and obj.PrimaryPart then
			if obj:FindFirstChild("platform") and obj.platform:IsA("BasePart") then
				table.remove(currentPlatforms, table.find(obj.platform))
			end
		end
	end)

	local planePosition = currentBase.CFrame * Vector3.new(0, currentBase.Size.Y/2, 0)	

	resting = false
	ox, oy, oz = planePosition.X, planePosition.Y, planePosition.Z
	currentXAxis = currentBase.CFrame.rightVector
	currentYAxis = currentBase.CFrame.upVector
	currentZAxis = currentBase.CFrame.lookVector
	currentAxis = CFrame.new(0, 0, 0, currentXAxis.X, currentYAxis.X, -currentZAxis.X, currentXAxis.Y, currentYAxis.Y, -currentZAxis.Y, currentXAxis.Z, currentYAxis.Z, -currentZAxis.Z)
	currentObjects = {}
	dxx, dxy, dxz = currentXAxis.X, currentXAxis.Y, currentXAxis.Z
	dzx, dzy, dzz = currentZAxis.X, currentZAxis.Y, currentZAxis.Z
	cx, cy, cz, cr = 0, 0, 0, 0

	springVelocity = Vector3.new(0, 0, 0)
	springPosition = Vector3.new(0, 0, 0)

	tweenAlpha = 0
	tweenCurrentRotation = 0
	tweenGoalRotation = 0
	tweenStartRotation = 0

	local position, _ = inputCapture()

	if (not position) then
		position = planePosition
	end

	springPosition = position

	do
		local extentsXMin, extentsXMax = 10e10, -10e10
		local extentsZMin, extentsZMax = 10e10, -10e10
		
		local placing_platforms = {}
		
		for _, model in pairs(models) do
			if model:FindFirstChild("platform") and model.platform:IsA("BasePart") then
				table.insert(placing_platforms, model)
			end
		end
		
		for i = 1, #models do
			local model = models[i]
			local object = {}
			object.model = model
			object.yVelocity = 0
			object.yPosition = 0
			object.platformY = 0
			object.on_platforms = {}

			if not model:GetAttribute("y") then
				setObjectY(object)
			end

			local lookVector = object.model.PrimaryPart.CFrame.lookVector	
			local theta
			local px, pz

			if (prealigned) then
				local position = object.model.PrimaryPart.CFrame * Vector3.new(0, -object.model.PrimaryPart.Size.Y/2 , 0)		
				px, pz = project(position.X, position.Y, position.Z)

				theta = math.acos(math.clamp(lookVector:Dot(currentZAxis), -1, 1))
				local cross = lookVector:Cross(currentZAxis)

				if (cross:Dot(currentYAxis) > 0) then
					theta = -theta
				end
				
				local height = object.model:GetAttribute("height") or 0
				
				local y_platform_pos = position.Y - height * currentPlane.grid
				
				local points = {}
				
				local x0, z0 = position.X, position.Z
				local extentsX0, extentsZ0 = calculateExtents(object.model.PrimaryPart)
				
				for x = x0 - extentsX0 / 2, x0 + extentsX0 / 2, currentPlane.grid / 2 do
					for z = z0 - extentsZ0 / 2, z0 + extentsZ0 / 2, currentPlane.grid / 2 do
						table.insert(points, Vector3.new(x, 0, z))
					end
				end
				
				for _, platform in pairs(placing_platforms) do
					if platform == model then
						continue
					end
					
					local is_inside
					
					local platform_pos = platform.platform.Position.Y + platform.platform.Size.Y / 2
					
					if math.abs(y_platform_pos - platform_pos) <= 0.1 then
						local x2, z2 = position.X, position.Z
						local extentsX2, extentsZ2 = calculateExtents(object.model.PrimaryPart)
						
						for _, point in pairs(points) do
							if floatLesser(point.X - currentPlane.grid / 2, x2 + extentsX2 / 2) and floatGreater(point.X + currentPlane.grid / 2, x2 - extentsX2 / 2) and floatLesser(point.Z - currentPlane.grid / 2, z2 + extentsZ2 / 2) and floatGreater(point.Z + currentPlane.grid / 2, z2 - extentsZ2 / 2) then
								is_inside = true
								
								continue
							end
						end
					end
					
					object.platformY = (y_platform_pos - currentBase.Position.Y + currentBase.Size.Y / 2 - (platform:GetAttribute("height") or 0) * currentPlane.grid - platform.platform.Size.Y) / currentPlane.grid
					
					if is_inside then
						table.insert(object.on_platforms, platform)
					end
				end
			else
				px, pz = object.model.PrimaryPart.Position.X, object.model.PrimaryPart.Position.Z
				theta = math.atan2(lookVector.X, lookVector.Z)		
			end

			local x, z = model.PrimaryPart.Size.X, model.PrimaryPart.Size.Z

			object.r = round((theta % (2 * math.pi))/(math.pi/2), 1)

			if (object.r == 1 or object.r == 3) then
				x, z = z, x
			end

			local x1, x2 = px + x/2, px - x/2
			local z1, z2 = pz + z/2, pz - z/2	

			if (x2 < extentsXMin) then
				extentsXMin = x2
			end
			if (x1 > extentsXMax) then
				extentsXMax = x1
			end

			if (z2 < extentsZMin) then
				extentsZMin = z2
			end
			if (z1 > extentsZMax) then
				extentsZMax = z1
			end


			model.PrimaryPart.Transparency = .5
			model.PrimaryPart.Material = Enum.Material.SmoothPlastic
			
			for _, obj in pairs(model:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.Anchored = true
					obj.CanCollide = false
					obj.CastShadow = false
				end
			end
			
			createSelectionBox(model)
			
			setState(object, plane.loading and states.loading or states.neutral)
			
			model.Parent = previewObject
			
			currentObjects[i] = object
		end

		currentExtentsX, currentExtentsZ = round(extentsXMax - extentsXMin, currentPlane.grid), round(extentsZMax - extentsZMin, currentPlane.grid)

		for i = 1, #currentObjects do
			local object = currentObjects[i]
			local px, pz

			if (prealigned) then
				local position = object.model.PrimaryPart.CFrame * Vector3.new(0, -object.model.PrimaryPart.Size.Y/2, 0)		
				px, pz = project(position.X, position.Y, position.Z)
			else
				px, pz = object.model.PrimaryPart.Position.X, object.model.PrimaryPart.Position.Z
			end

			object.px = px - (extentsXMin + extentsXMax)/2
			object.pz = (pz - (extentsZMin + extentsZMax)/2) * (prealigned and -1 or 1)

			object.sx, object.sy, object.sz = object.model.PrimaryPart.Size.X, object.model.PrimaryPart.Size.Y, object.model.PrimaryPart.Size.Z

			local height = object.model:GetAttribute("height") or 0
			
			local min = object.model:GetAttribute("minHeight") or height
			local max = object.model:GetAttribute("maxHeight") or height
			
			height = math.clamp(height, min, max)
			
			if object.model:GetAttribute("height") ~= height then
				object.model:SetAttribute("height", height)
			end
		end
	end

	renderConnection = runService.Heartbeat:Connect(run)
	module.currentPlane = currentPlane
	module.currentObjects = currentObjects
	currentEvent = Instance.new("BindableEvent")
	
	createTexture(currentPlane.base)
	
	for _, gui in pairs(CORE_GUI_DISABLE) do
		game.StarterGui:SetCoreGuiEnabled(gui, false)
	end
	
	bindInputs()

	run(true)

	return currentEvent.Event
end

local function disablePlacement(plane)
	if (currentPlane) then
		renderConnection:disconnect()
		renderConnection = nil
		
		for _, model in pairs(currentPlane.obstacles:GetChildren()) do
			for _, obj in pairs(model.PrimaryPart:GetChildren()) do
				if obj:IsA("SelectionBox") then
					local selectionTween = tweenService:Create(obj, TweenInfo.new(HIT_BOX_FADE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 1})
					local connection

					connection = selectionTween.Completed:Connect(function()
						connection:Disconnect()

						obj:Destroy()
					end)

					selectionTween:Play()
				end
			end
		end
		
		currentPlane = nil
		currentPlatforms = nil
		currentPlatform = nil
		module.currentPlane = nil
		module.currentObjects = nil
		currentEvent:Destroy()
		currentEvent = nil	
		
		lastPlatforms = nil
		newHit = nil

		obstacleAdded:Disconnect()
		obstacleAdded = nil
		obstacleRemoved:Disconnect()
		obstacleRemoved = nil
		
		for _, texture in pairs(currentTextures) do
			removeTexture(texture)
		end
		
		currentTextures = nil

		for i = 1, #currentObjects do
			local object = currentObjects[i]
			object.model:Destroy()
			object.model = nil
			currentObjects[i] = nil
		end

		unbindInputs()

		for _, gui in pairs(CORE_GUI_DISABLE) do
			game.StarterGui:SetCoreGuiEnabled(gui, true)
		end
	end
end

local function setLoading(plane, isLoading)
	if (plane.loading == isLoading) then
		return
	end

	plane.loading = isLoading

	if (plane == currentPlane) then	
		if (isLoading) then
			for i = 1, #currentObjects do
				setState(currentObjects[i], states.loading)
			end
		else
			for i = 1, #currentObjects do
				setState(currentObjects[i], states.neutral, true)
			end

			obstacleCollision()
		end
	end
end

module.new = function(base, obstacles, grid)
	local plane = {}
	plane.base = base
	plane.obstacles = obstacles
	plane.position = base.Position
	plane.size = base.Size

	if (math.floor(.5 + plane.size.X/grid) % 2 == 0) then
		plane.offsetX = -grid/2
	else
		plane.offsetX = 0
	end

	if (math.floor(.5 + plane.size.Z/grid) % 2 == 0) then
		plane.offsetZ = -grid/2
	else
		plane.offsetZ = 0
	end


	plane.stateEvent = Instance.new("BindableEvent")
	plane.stateChanged = plane.stateEvent.Event	

	plane.grid = grid
	plane.enable = enablePlacement
	plane.disable = disablePlacement
	plane.rotate = rotate
	plane.place = place
	plane.setLoading = setLoading

	return plane
end

module.setLoading = setLoading
module.currentPlane = false
module.currentObjects = false

return module