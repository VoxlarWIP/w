loadstring(game:HttpGet("https://raw.githubusercontent.com/VoxlarWIP/p/refs/heads/main/Keysystem%20V6.luau"))()

getgenv().Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/refs/heads/main/Oxidelib.lua"))()

getgenv().Window = getgenv().Library:CreateWindow({
	Name             = "PerplexWare",
	BrandSubtitle    = "Bloxstrike",
	Size             = UDim2.fromOffset(700, 490),
	ToggleKey        = Enum.KeyCode.RightControl,
	LoadingAnimation = true,
	LoadingText      = "PerplexWare",
	LoadingSubtitle  = "Loading...",
	LoadingFooter    = "https://dsc.gg/perplexware/",
})

getgenv().Players         = game:GetService("Players")
getgenv().RunService      = game:GetService("RunService")
getgenv().UserInputService = game:GetService("UserInputService")
getgenv().TweenService    = game:GetService("TweenService")
getgenv().ContextActionSvc = game:GetService("ContextActionService")
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().Workspace       = game:GetService("Workspace")
getgenv().Lighting        = game:GetService("Lighting")

getgenv().LocalPlayer  = getgenv().Players.LocalPlayer
getgenv().Camera       = getgenv().Workspace.CurrentCamera
getgenv().CharFolder   = getgenv().Workspace:WaitForChild("Characters", 10)

getgenv().Settings = {
	SilentEnabled    = false,
	SilentWallbang   = false,
	SilentFOV        = 130,
	SilentHitPart    = "Head",
	SilentTeamCheck  = true,
	SilentUseFOV     = false,

	Aimbot           = false,
	AimbotFOV        = 70,
	AimbotHitPart    = "Head",
	AimbotTeamCheck  = true,
	AimbotWallCheck  = true,
	AimbotFOVCircle  = true,

	Ragebot          = false,
	RageDelay        = 0.01,
	RageHitPart      = "Head",
	RageVisibleCheck = true,
	RageTeamCheck    = true,
	RageWallCheck    = false,

	Triggerbot       = false,
	TriggerDelay     = 0.01,

	Hitbox           = false,
	HitboxSize       = 7,
	HitboxTransparency = 0,

	NoRecoil         = false,
	NoSpread         = false,
	Firerate         = false,
	FirerateValue    = 0.01,

	AntiFlash        = false,
	AntiSmoke        = false,

	BhopEnabled      = false,
	SpeedEnabled     = false,
	SpeedMultiplier  = 1.5,
	InfiniteJumpEnabled = false,
	NoClipEnabled    = false,
	AntiAFKEnabled   = false,
	FreeMouseFocus   = false,

	InfiniteAmmo     = false,
	InstantReload    = false,
	InstantScope     = false,

	NativeAimAssist  = false,
	NativeAimStrength = 100,
	NoFlinch         = false,
	AutoSpectate     = false,

	CustomGloves     = false,

	SpinbotEnabled   = false,
	SpinSpeed        = 50,
	AntiAimEnabled   = false,
	JitterEnabled    = false,
	FakeLagEnabled   = false,
	FakeLagAmount    = 3,

	ESP              = false,
	ESPBoxType       = "2D",
	ESPMaxDistance   = 2000,
	ESPTeamColors    = true,
	ESPLineThickness = 1,
	ESPTextSize      = 13,
	ESPBox           = true,
	ESPBoxFilled     = false,
	ESPBoxOutline    = true,
	ESPBoxColor      = Color3.fromRGB(255, 255, 255),
	ESPName          = false,
	ESPNameColor     = Color3.fromRGB(255, 255, 255),
	ESPHealth        = false,
	ESPDistance      = false,
	ESPDistanceColor = Color3.fromRGB(200, 200, 200),
	ESPTracer        = false,
	ESPTracerColor   = Color3.fromRGB(255, 255, 255),
	ESPTracerFrom    = "Bottom",
	ESPSkeleton      = false,
	ESPSkeletonColor = Color3.fromRGB(200, 200, 200),

	ChamsEnabled     = false,
	ChamsColor       = Color3.fromRGB(200, 200, 200),
	ChamsTransparency = 0.5,
	ChamsMaterial    = Enum.Material.ForceField,
	RainbowChams     = false,
	GlowEnabled      = false,
	GlowColor        = Color3.fromRGB(255, 255, 255),
	GlowTransparency = 0.3,

	FullbrightEnabled = false,
	NoFogEnabled     = false,
	CustomFOV        = false,
	FOVValue         = 70,
	CustomAmbient    = false,
	AmbientColor     = Color3.fromRGB(255, 255, 255),

	SkinChangerEnabled = false,
	CustomKnifeEnabled = false,
	SelectedKnife    = "Butterfly Knife",
}

getgenv().SilentTarget  = nil
getgenv().AimbotTarget  = nil
getgenv().RageTarget    = nil
getgenv().HitboxSafe    = false

getgenv().SilentFOVCircle = Drawing.new("Circle")
getgenv().SilentFOVCircle.Filled       = false
getgenv().SilentFOVCircle.Thickness    = 1
getgenv().SilentFOVCircle.NumSides     = 64
getgenv().SilentFOVCircle.Color        = Color3.fromRGB(220, 220, 220)
getgenv().SilentFOVCircle.Transparency = 1
getgenv().SilentFOVCircle.Visible      = false
getgenv().SilentFOVCircle.Position     = getgenv().Camera.ViewportSize / 2

getgenv().AimbotCircle = Drawing.new("Circle")
getgenv().AimbotCircle.Thickness    = 1.5
getgenv().AimbotCircle.NumSides     = 100
getgenv().AimbotCircle.Radius       = getgenv().Settings.AimbotFOV
getgenv().AimbotCircle.Color        = Color3.fromRGB(150, 150, 150)
getgenv().AimbotCircle.Transparency = 0.3
getgenv().AimbotCircle.Filled       = false
getgenv().AimbotCircle.Visible      = false
getgenv().AimbotCircle.Position     = getgenv().Camera.ViewportSize / 2

getgenv().RayParams = RaycastParams.new()
getgenv().RayParams.FilterType   = Enum.RaycastFilterType.Exclude
getgenv().RayParams.IgnoreWater  = true

getgenv().FrameCounter = 0

getgenv().EspData = {}
getgenv().ChamsData = {}

getgenv().FirerateObjs   = {}
getgenv().OriginalFirerate = {}
getgenv().SendFunc          = nil
getgenv().GetCurrentEquipped = nil
getgenv().EquippedWeapon    = nil

getgenv().SpinAngle = 0

getgenv().KnifeOffsets = {
	Karambit            = CFrame.new(0, -1.5, 1.5),
	["Butterfly Knife"] = CFrame.new(0, -1.5, 1.5),
	["M9 Bayonet"]      = CFrame.new(0, -1.5, 1),
	["Flip Knife"]      = CFrame.new(0, -1.5, 1.25),
	["Gut Knife"]       = CFrame.new(0, -1.5, 0.5),
}

getgenv().KnifeModelInstance    = nil
getgenv().KnifeAnimator         = nil
getgenv().KnifeEquipAnim        = nil
getgenv().KnifeIdleAnim         = nil
getgenv().KnifeSwing1           = nil
getgenv().KnifeSwing2           = nil
getgenv().KnifeSwing3           = nil
getgenv().KnifeIsEquipped       = false
getgenv().KnifeIsInspecting     = false
getgenv().KnifeIsAttacking      = false
getgenv().KnifeLastAttackTime   = 0
getgenv().KnifeAttackCooldown   = 1

getgenv().InspectActionName  = "PerplexInspectKnife"
getgenv().AttackActionName   = "PerplexAttackKnife"

getgenv().SkinNames      = {}
getgenv().SkinDropdowns  = {}
getgenv().SkinSelected   = {}
getgenv().SkinWear       = "Factory New"

getgenv().CTWeapons = {
	["USP-S"]    = true,
	["Five-SeveN"] = true,
	MP9          = true,
	FAMAS        = true,
	["M4A1-S"]   = true,
	M4A4         = true,
	AUG          = true,
}

getgenv().TWeapons = {
	P250              = true,
	["Desert Eagle"]  = true,
	["Dual Berettas"] = true,
	Negev             = true,
	P90               = true,
	Nova              = true,
	XM1014            = true,
	AWP               = true,
	["SSG 08"]        = true,
}

getgenv().KnifeNames = {
	Karambit          = true,
	["Butterfly Knife"] = true,
	["M9 Bayonet"]    = true,
	["Flip Knife"]    = true,
	["Gut Knife"]     = true,
	["T Knife"]       = true,
	["CT Knife"]      = true,
}

getgenv().GloveNames = {
	["Sports Gloves"] = true,
}

getgenv().ExcludedSkins = {
	["HE Grenade"]       = true,
	["Incendiary Grenade"] = true,
	Molotov              = true,
	["Smoke Grenade"]    = true,
	Flashbang            = true,
	["Decoy Grenade"]    = true,
	C4                   = true,
	["CT Glove"]         = true,
	["T Glove"]          = true,
}

getgenv().SkinApplyDelay = 0.1
getgenv().SkinsAsset     = nil
pcall(function()
	getgenv().SkinsAsset = getgenv().ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skins")
end)

getgenv().BoneLinks = {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
}

getgenv().BoneLinksR6 = {
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local function getTerrGroup()
	return getgenv().CharFolder and getgenv().CharFolder:FindFirstChild("Terrorists")
end

local function getCTGroup()
	return getgenv().CharFolder and getgenv().CharFolder:FindFirstChild("Counter-Terrorists")
end

local function getPlayerTeam(player)
	if not getgenv().CharFolder or not player then return nil end
	local t  = getTerrGroup()
	local ct = getCTGroup()
	if t  and t:FindFirstChild(player.Name)  then return "Terrorists" end
	if ct and ct:FindFirstChild(player.Name) then return "Counter-Terrorists" end
	return nil
end

local function getLocalTeamGroup()
	local myTeam = getPlayerTeam(getgenv().LocalPlayer)
	if not myTeam then return nil end
	local t  = getTerrGroup()
	local ct = getCTGroup()
	if myTeam == "Terrorists" then
		return ct
	end
	return t
end

local function getLocalTeamSide()
	local t  = getTerrGroup()
	local ct = getCTGroup()
	if t  and t:FindFirstChild(getgenv().LocalPlayer.Name)  then return "T" end
	if ct and ct:FindFirstChild(getgenv().LocalPlayer.Name) then return "CT" end
	return nil
end

local function isPlayerVisible(targetPart)
	local char = getgenv().LocalPlayer.Character
	if not char then return false end
	getgenv().RayParams.FilterDescendantsInstances = { char }
	local result = getgenv().Workspace:Raycast(
		getgenv().Camera.CFrame.Position,
		targetPart.Position - getgenv().Camera.CFrame.Position,
		getgenv().RayParams
	)
	if result then
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		return model and (getgenv().Players:GetPlayerFromCharacter(model) ~= nil)
	end
	return true
end

local function silentIsVisible(targetPart)
	if getgenv().Settings.SilentWallbang then return true end
	if not targetPart or not targetPart.Parent or not getgenv().Camera then return false end
	getgenv().RayParams.FilterDescendantsInstances = getgenv().LocalPlayer.Character and { getgenv().LocalPlayer.Character } or {}
	local origin = getgenv().Camera.CFrame.Position
	local result = getgenv().Workspace:Raycast(origin, targetPart.Position - origin, getgenv().RayParams)
	if not result then return true end
	local model = result.Instance and result.Instance:FindFirstAncestorOfClass("Model")
	return model and getgenv().Players:GetPlayerFromCharacter(model) ~= nil
end

local function findSilentTarget()
	if not getgenv().Settings.SilentEnabled or not getgenv().Camera or not getgenv().LocalPlayer.Character then
		getgenv().SilentTarget = nil
		return
	end
	local myTeam = getPlayerTeam(getgenv().LocalPlayer)
	local screenCenter = getgenv().Camera.ViewportSize / 2
	local closestDist = math.huge
	local closestPart = nil
	for _, player in next, getgenv().Players:GetPlayers() do
		if player == getgenv().LocalPlayer then continue end
		local char = player.Character
		if not char or char:GetAttribute("Dead") or char:GetAttribute("Invincible") then continue end
		if char.Parent and char.Parent.Name == "Debris" then continue end
		local pTeam  = getPlayerTeam(player)
		local isTeam = myTeam ~= nil and pTeam ~= nil and myTeam == pTeam
		if getgenv().Settings.SilentTeamCheck and isTeam then continue end
		local targetPart = char:FindFirstChild(getgenv().Settings.SilentHitPart) or char:FindFirstChild("Head") or char.PrimaryPart
		if not targetPart then continue end
		local screenPos, onScreen = getgenv().Camera:WorldToViewportPoint(targetPart.Position)
		if onScreen then
			local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
			local maxRadius = getgenv().Settings.SilentUseFOV and getgenv().Settings.SilentFOV or math.huge
			if distFromCenter <= maxRadius and distFromCenter < closestDist then
				if silentIsVisible(targetPart) then
					closestDist = distFromCenter
					closestPart = targetPart
				end
			end
		end
	end
	getgenv().SilentTarget = closestPart
end

local function findAimbotRageTargets()
	local lchar = getgenv().LocalPlayer.Character
	if not lchar or not lchar:FindFirstChild("Head") then return end
	local myTeam = getPlayerTeam(getgenv().LocalPlayer)
	local center = getgenv().Camera.ViewportSize / 2
	local aDist, aClose = math.huge, nil
	local rDist, rClose = math.huge, nil
	local lHeadPos = lchar.Head.Position
	for _, item in pairs(getgenv().Players:GetPlayers()) do
		if item == getgenv().LocalPlayer then continue end
		local char = item.Character
		if not char then continue end
		if char:GetAttribute("Dead") then continue end
		if char:GetAttribute("Invincible") then continue end
		local vTeam  = getPlayerTeam(item)
		local isTeam = myTeam == vTeam
		local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
		if not targetPart then continue end
		local screenPos, onScreen = getgenv().Camera:WorldToViewportPoint(targetPart.Position)
		if getgenv().Settings.Ragebot and not isTeam then
			local rPart = char:FindFirstChild(getgenv().Settings.RageHitPart) or targetPart
			local alive = true
			if getgenv().Settings.RageVisibleCheck and not onScreen then alive = false end
			if alive and getgenv().Settings.RageWallCheck and not isPlayerVisible(rPart) then alive = false end
			if alive then
				local rd = (lHeadPos - rPart.Position).Magnitude
				if rd < rDist then rDist = rd; rClose = rPart end
			end
		end
		if getgenv().Settings.Aimbot and onScreen then
			if not getgenv().Settings.AimbotTeamCheck or not isTeam then
				local ad = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				if ad <= getgenv().Settings.AimbotFOV then
					if not getgenv().Settings.AimbotWallCheck or isPlayerVisible(targetPart) then
						if ad < aDist then aDist = ad; aClose = targetPart end
					end
				end
			end
		end
	end
	getgenv().AimbotTarget = aClose
	getgenv().RageTarget   = rClose
end

getgenv().RunService.RenderStepped:Connect(function()
	getgenv().FrameCounter = getgenv().FrameCounter + 1
	local center = getgenv().Camera.ViewportSize / 2

	getgenv().SilentFOVCircle.Visible = getgenv().Settings.SilentEnabled and getgenv().Settings.SilentUseFOV
	if getgenv().SilentFOVCircle.Visible then
		getgenv().SilentFOVCircle.Position = center
		getgenv().SilentFOVCircle.Radius   = getgenv().Settings.SilentFOV
	end

	getgenv().AimbotCircle.Position = center
	getgenv().AimbotCircle.Radius   = getgenv().Settings.AimbotFOV
	getgenv().AimbotCircle.Visible  = getgenv().Settings.Aimbot and getgenv().Settings.AimbotFOVCircle

	findSilentTarget()

	if (getgenv().FrameCounter % 3) == 0 then
		findAimbotRageTargets()
	end

	if getgenv().Settings.CustomFOV then
		getgenv().Camera.FieldOfView = getgenv().Settings.FOVValue
	end
	if getgenv().Settings.CustomAmbient then
		getgenv().Lighting.Ambient        = getgenv().Settings.AmbientColor
		getgenv().Lighting.OutdoorAmbient = getgenv().Settings.AmbientColor
	end

	if not getgenv().HitboxSafe then return end
	for _, item in pairs(getgenv().Players:GetPlayers()) do
		if item == getgenv().LocalPlayer then continue end
		local char = item.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		if getgenv().Settings.Hitbox and (getPlayerTeam(item) ~= getPlayerTeam(getgenv().LocalPlayer)) then
			hrp.Size         = Vector3.new(getgenv().Settings.HitboxSize, getgenv().Settings.HitboxSize, getgenv().Settings.HitboxSize)
			hrp.Transparency = getgenv().Settings.HitboxTransparency
		elseif hrp.Size.X ~= 2 then
			hrp.Size         = Vector3.new(2, 2, 2)
			hrp.Transparency = 1
		end
	end
end)

getgenv().RunService.Heartbeat:Connect(function()
	local char = getgenv().LocalPlayer.Character
	if not char then return end

	if getgenv().Settings.JitterEnabled then
		local head = char:FindFirstChild("Head")
		if head then
			head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(math.random(-10, 10)), 0)
		end
	end

	if getgenv().Settings.SpeedEnabled then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16 * getgenv().Settings.SpeedMultiplier
		end
	end
end)

getgenv().RunService.RenderStepped:Connect(function(dt)
	local char = getgenv().LocalPlayer.Character
	if not char then return end

	if getgenv().Settings.SpinbotEnabled and getPlayerTeam(getgenv().LocalPlayer) then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			getgenv().SpinAngle = (getgenv().SpinAngle + getgenv().Settings.SpinSpeed * dt) % 360
			hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(getgenv().SpinAngle), 0)
		end
	end

	if getgenv().Settings.KnifeModelInstance and getgenv().Settings.KnifeModelInstance.PrimaryPart then
		if not getgenv().KnifeEquipAnim or not getgenv().KnifeEquipAnim.IsPlaying then
			if not getgenv().KnifeIsInspecting and not getgenv().KnifeIsAttacking then
				if getgenv().KnifeIdleAnim and not getgenv().KnifeIdleAnim.IsPlaying then
					getgenv().KnifeIdleAnim:Play()
				end
			end
		end
		getgenv().Settings.KnifeModelInstance.PrimaryPart.CFrame =
			getgenv().Camera.CFrame * getgenv().KnifeOffsets[getgenv().Settings.SelectedKnife]
	end
end)

getgenv().UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		getgenv().AimbotActive = true
	end
end)
getgenv().UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		getgenv().AimbotActive = false
	end
end)

getgenv().AimbotArmed = false

getgenv().UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		local TRIGGER_ON, TRIGGER_OFF = 0.6, 0.4
		if input.KeyCode == Enum.KeyCode.ButtonR2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
			local pos = input.Position.Z
			if not getgenv().AimbotTriggerHeld and pos >= TRIGGER_ON then
				getgenv().AimbotTriggerHeld = true
			elseif getgenv().AimbotTriggerHeld and pos <= TRIGGER_OFF then
				getgenv().AimbotTriggerHeld = false
			end
		end
	end
end)

task.spawn(function()
	local updateCam = nil
	local hooked = false

	local function resolveUpdateCam()
		if typeof(updateCam) == "function" then return true end
		pcall(function()
			if typeof(getloadedmodules) ~= "function" then return end
			for _, mod in ipairs(getloadedmodules()) do
				local n
				pcall(function() n = mod.Name end)
				if n == "CameraController" then
					local ok, val = pcall(require, mod)
					if ok and type(val) == "table" and typeof(rawget(val, "updateCamera")) == "function" then
						updateCam = val.updateCamera
						return
					end
				end
			end
		end)
		if typeof(updateCam) == "function" then return true end
		pcall(function()
			for _, obj in next, getgc(true) do
				if type(obj) == "table" then
					local c = rawget(obj, "updateCamera")
					if typeof(c) == "function" then
						for _, k in ipairs({ "updateCameraFOV", "weaponKick", "setPerspective" }) do
							if rawget(obj, k) ~= nil then updateCam = c; return end
						end
					end
				end
			end
		end)
		return typeof(updateCam) == "function"
	end

	for _ = 1, 25 do
		if resolveUpdateCam() then break end
		task.wait(1)
	end

	if typeof(updateCam) ~= "function" then return end

	local oldCam
	pcall(function()
		oldCam = hookfunction(updateCam, function(p1, p2, ...)
			local armed = getgenv().AimbotActive and (getgenv().AimbotTriggerHeld or getgenv().AimbotActive)
			if armed and getgenv().Settings.Aimbot and getgenv().AimbotTarget then
				local aimPos
				local okP = pcall(function() aimPos = getgenv().AimbotTarget.Position end)
				if okP and aimPos then
					if typeof(p1) == "CFrame" then
						local okL, look = pcall(CFrame.lookAt, p1.Position, aimPos)
						if okL then return oldCam(look, p2, ...) end
					elseif typeof(p2) == "CFrame" then
						local okL, look = pcall(CFrame.lookAt, p2.Position, aimPos)
						if okL then return oldCam(p1, look, ...) end
					end
				end
			end
			return oldCam(p1, p2, ...)
		end)
		hooked = true
	end)

	if not hooked then
		getgenv().RunService.RenderStepped:Connect(function()
			if not getgenv().AimbotActive then return end
			if not getgenv().Settings.Aimbot then return end
			if not getPlayerTeam(getgenv().LocalPlayer) then return end
			local tgt = getgenv().AimbotTarget
			if not tgt then return end
			local vec = getgenv().Camera:WorldToViewportPoint(tgt.Position)
			local mouse = getgenv().UserInputService:GetMouseLocation()
			local dx = (vec.X - mouse.X) / 3
			local dy = (vec.Y - mouse.Y) / 3
			if mousemoverel then mousemoverel(dx, dy) end
		end)
	end
end)

getgenv().UserInputService.JumpRequest:Connect(function()
	if not getgenv().Settings.InfiniteJumpEnabled then return end
	if not getPlayerTeam(getgenv().LocalPlayer) then return end
	local char = getgenv().LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

getgenv().RunService.RenderStepped:Connect(function()
	if not getgenv().Settings.BhopEnabled then return end
	if not getgenv().UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
	if not getPlayerTeam(getgenv().LocalPlayer) then return end
	local char = getgenv().LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local st = hum:GetState()
	if st ~= Enum.HumanoidStateType.Jumping and st ~= Enum.HumanoidStateType.Freefall then
		hum.Jump = true
	end
end)

getgenv().RunService.Stepped:Connect(function()
	if not getgenv().Settings.NoClipEnabled then return end
	local char = getgenv().LocalPlayer.Character
	if not char then return end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end)

task.spawn(function()
	while task.wait(60) do
		if getgenv().Settings.AntiAFKEnabled then
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end
	end
end)

task.spawn(function()
	while task.wait(0.2) do
		if getgenv().Settings.AntiFlash then
			local pg = getgenv().LocalPlayer.PlayerGui
			local flash = pg and pg:FindFirstChild("FlashbangEffect")
			if flash then flash:Destroy() end
			local cc = getgenv().Lighting:FindFirstChild("FlashbangColorCorrection")
			if cc then cc:Destroy() end
		end
		if getgenv().Settings.AntiSmoke then
			local debris = getgenv().Workspace:FindFirstChild("Debris")
			if debris then
				for _, v in ipairs(debris:GetChildren()) do
					if string.match(v.Name, "Voxel") then
						v:ClearAllChildren()
						v:Destroy()
					end
				end
			end
		end
	end
end)

pcall(function()
	for _, obj in pairs(getgc(true)) do
		if type(obj) == "table" and rawget(obj, "FireRate") then
			table.insert(getgenv().OriginalFirerate, table.clone(obj))
			table.insert(getgenv().FirerateObjs, obj)
		end
		if type(obj) == "table" and rawget(obj, "setWeaponRecoil") then
			local oldFn
			oldFn = hookfunction(obj.setWeaponRecoil, function(...)
				if getgenv().Settings.NoRecoil then return end
				return oldFn(...)
			end)
		end
		if type(obj) == "function" and (debug.getinfo(obj).name == "calculateRecoilOffset") then
			local oldFn
			oldFn = hookfunction(obj, function(...)
				if getgenv().Settings.NoRecoil then return UDim2.new() end
				return oldFn(...)
			end)
		end
		if type(obj) == "table" and rawget(obj, "weaponKick") then
			local oldKick
			oldKick = hookfunction(obj.weaponKick, function(...)
				if getgenv().Settings.NoRecoil then return end
				return oldKick(...)
			end)
		end
		if type(obj) == "table" and rawget(obj, "getTrueSpread") then
			local oldSpread
			oldSpread = hookfunction(obj.getTrueSpread, function(...)
				local rets = table.pack(oldSpread(...))
				if not getgenv().Settings.NoSpread then return table.unpack(rets, 1, rets.n) end
				for i2 = 1, rets.n do
					local k = typeof(rets[i2])
					if k == "Vector3" then rets[i2] = Vector3.zero
					elseif k == "Vector2" then rets[i2] = Vector2.zero
					elseif k == "number" then rets[i2] = 0 end
				end
				return table.unpack(rets, 1, rets.n)
			end)
		end
		if type(obj) == "function" and (debug.getinfo(obj).name == "Flash") then
			local oldFn
			oldFn = hookfunction(obj, function(...)
				if getgenv().Settings.AntiFlash then return end
				return oldFn(...)
			end)
		end
		if type(obj) == "function" and (debug.getinfo(obj).name == "CreateVoxel") then
			local oldFn
			oldFn = hookfunction(obj, function(...)
				if getgenv().Settings.AntiSmoke then return end
				return oldFn(...)
			end)
		end
		if type(obj) == "table" and rawget(obj, "shoot") then
			if obj.shoot and typeof(obj.shoot) == "function" and (#debug.getupvalues(obj.shoot) == 25) then
				pcall(function()
					getgenv().SendFunc = debug.getupvalue(obj.shoot, 13).Inventory.ShootWeapon.Send
				end)
			end
		end
		if type(obj) == "table" and rawget(obj, "getCurrentEquipped") then
			pcall(function()
				getgenv().GetCurrentEquipped = obj.getCurrentEquipped
			end)
		end
	end
end)

getgenv().KnownWeapons = setmetatable({}, { __mode = "k" })

local function getEquippedWeapon()
	local function shootable(obj)
		return type(obj) == "table"
			and typeof(rawget(obj, "shoot")) == "function"
			and rawget(obj, "Rounds") ~= nil
			and rawget(obj, "IsDestroyed") ~= true
	end

	if getgenv().GetCurrentEquipped then
		local ok, inv = pcall(function()
			return debug.getupvalue(getgenv().GetCurrentEquipped, 1)
		end)
		if ok and type(inv) == "table" then
			local eq = rawget(inv, "CurrentEquipped")
			if shootable(eq) then return eq end
		end
	end

	for obj in pairs(getgenv().KnownWeapons) do
		if rawget(obj, "IsDestroyed") == true then
			getgenv().KnownWeapons[obj] = nil
		elseif rawget(obj, "IsEquipped") == true then
			return obj
		end
	end

	pcall(function()
		for _, obj in next, getgc(true) do
			if shootable(obj) then
				getgenv().KnownWeapons[obj] = true
				if rawget(obj, "IsEquipped") == true then
					getgenv().EquippedWeapon = obj
				end
			end
		end
	end)
	return getgenv().EquippedWeapon
end

getgenv().WeaponReloading = false

local function ensureAmmoLoaded(weapon)
	if type(weapon) ~= "table" then return false end
	local rounds = rawget(weapon, "Rounds")
	if type(rounds) ~= "number" then return true end
	if rounds > 0 then
		getgenv().WeaponReloading = false
		return true
	end
	if not getgenv().WeaponReloading then
		getgenv().WeaponReloading = true
		task.spawn(function()
			pcall(function()
				local reloadFn = rawget(weapon, "reload")
				if typeof(reloadFn) == "function" then reloadFn(weapon) end
			end)
			task.wait(2)
			getgenv().WeaponReloading = false
		end)
	end
	return false
end

task.spawn(function()
	local lastScan = 0
	while task.wait(0.5) do
		pcall(function()
			local w = getgenv().EquippedWeapon
			if w and rawget(w, "IsEquipped") == true and rawget(w, "IsDestroyed") ~= true then
				return
			end
			local now = os.clock()
			if now - lastScan < 1 then return end
			lastScan = now
			getgenv().EquippedWeapon = getEquippedWeapon()
		end)
	end
end)

task.spawn(function()
	while task.wait(getgenv().Settings.RageDelay) do
		if getgenv().Settings.Ragebot and getgenv().RageTarget then
			local w = getgenv().EquippedWeapon
			if w and rawget(w, "IsEquipped") == true and ensureAmmoLoaded(w) then
				pcall(function() w:shoot() end)
			end
		end
	end
end)

task.spawn(function()
	local cachedMouse = nil
	pcall(function() cachedMouse = getgenv().LocalPlayer:GetMouse() end)
	while task.wait(getgenv().Settings.TriggerDelay) do
		if getgenv().Settings.Triggerbot then
			if not cachedMouse then pcall(function() cachedMouse = getgenv().LocalPlayer:GetMouse() end) end
			local mouse = cachedMouse
			if mouse and mouse.Target then
				local char = mouse.Target:FindFirstAncestorOfClass("Model")
				if not char then continue end
				local player = getgenv().Players:GetPlayerFromCharacter(char)
				if not player then continue end
				if char:GetAttribute("Dead") then continue end
				if getPlayerTeam(getgenv().LocalPlayer) == getPlayerTeam(player) then continue end
				local w = getgenv().EquippedWeapon
				if w and rawget(w, "IsEquipped") == true and ensureAmmoLoaded(w) then
					pcall(function() w:shoot() end)
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(0.2) do
		local w = getgenv().EquippedWeapon
		if type(w) ~= "table" then continue end
		pcall(function()
			if getgenv().Settings.InfiniteAmmo then
				local cap = rawget(w, "Capacity")
				local rds = rawget(w, "Rounds")
				if type(cap) == "number" and type(rds) == "number"
					and rds <= math.max(1, math.floor(cap * 0.25))
					and rawget(w, "IsShooting") ~= true then
					w.Rounds = cap
				end
			end
			if getgenv().Settings.InstantReload and rawget(w, "IsReloading") == true then
				w.IsReloading = false
				w.ReloadStartTick = 0
				local cap = rawget(w, "Capacity")
				if type(cap) == "number" then w.Rounds = cap end
			end
			if getgenv().Settings.InstantScope and rawget(w, "ScopeStartTick") ~= nil then
				if w.ScopeStartTick ~= 0 then w.ScopeStartTick = 0 end
			end
		end)
	end
end)

task.spawn(function()
	while task.wait(0.05) do
		pcall(function()
			if getgenv().Settings.Firerate then
				for _, obj in pairs(getgenv().FirerateObjs) do
					pcall(function()
						setreadonly(obj, false)
						rawset(obj, "FireRate", math.max(getgenv().Settings.FirerateValue, 0.01))
						setreadonly(obj, true)
					end)
				end
			else
				for i, obj in pairs(getgenv().FirerateObjs) do
					pcall(function()
						setreadonly(obj, false)
						rawset(obj, "FireRate", (getgenv().OriginalFirerate[i] and getgenv().OriginalFirerate[i].FireRate) or 0.1)
						setreadonly(obj, true)
					end)
				end
			end
		end)
	end
end)

if getgenv().SendFunc then
	local oldSend
	oldSend = hookfunction(getgenv().SendFunc, function(...)
		local args = { ... }
		if args[1] and args[1].Bullets and args[1].Bullets[1]
			and args[1].Bullets[1].Hits and args[1].Bullets[1].Hits[1] then
			if getgenv().Settings.Ragebot and getgenv().RageTarget then
				args[1].Bullets[1].Hits[1].Instance = getgenv().RageTarget
				args[1].Bullets[1].Hits[1].Position = getgenv().RageTarget.Position
			end
		end
		return oldSend(unpack(args))
	end)
end

pcall(function()
	local oldWait
	oldWait = hookfunction(task.wait, function(t)
		if t == 5 then
			getgenv().HitboxSafe = true
			t = 8999999488
		end
		return oldWait(t)
	end)
end)

task.spawn(function()
	if typeof(hookfunction) ~= "function" or typeof(getgc) ~= "function" then return end
	local bulletClass = nil
	for attempt = 1, 45 do
		for _, obj in next, getgc(true) do
			if type(obj) == "table" and typeof(rawget(obj, "_performRaycast")) == "function" and rawget(obj, "getTrueSpread") ~= nil then
				bulletClass = obj
				break
			end
		end
		if bulletClass then break end
		task.wait(0.5)
	end
	if not bulletClass then return end
	local oldRaycast
	oldRaycast = hookfunction(bulletClass._performRaycast, function(...)
		local returns = table.pack(oldRaycast(...))
		local result  = returns[1]
		local silentTarget = getgenv().SilentTarget
		if getgenv().Settings.SilentEnabled and silentTarget and type(result) == "table" then
			pcall(function()
				local hits = rawget(result, "Hits")
				if type(hits) ~= "table" or not silentTarget.Parent then return end
				local aimPos  = silentTarget.Position
				local lastIndex = nil
				for index, hit in pairs(hits) do
					if type(hit) == "table" then
						if lastIndex == nil or index > lastIndex then lastIndex = index end
					end
				end
				local finalHit = lastIndex and hits[lastIndex]
				if type(finalHit) ~= "table" then return end
				finalHit.Instance = silentTarget
				finalHit.Position = aimPos
				if finalHit.Exit ~= nil then finalHit.Exit = false end
				local origin = rawget(result, "Origin")
				if typeof(origin) == "Vector3" then
					local delta  = aimPos - origin
					local length = delta.Magnitude
					if length > 0.001 then
						result.Distance  = length
						result.Direction = delta.Unit
						local unit = delta.Unit
						for index, hit in pairs(hits) do
							if index ~= lastIndex and type(hit) == "table" and typeof(hit.Position) == "Vector3" then
								local along = (hit.Position - origin):Dot(unit)
								if along > length then
									hit.Position = origin + unit * (length * 0.5)
								end
							end
						end
					end
				end
			end)
		end
		return table.unpack(returns, 1, returns.n)
	end)
end)

local function createPlayerESP(player)
	if getgenv().EspData[player] then return end
	local d = {
		Box        = Drawing.new("Square"),
		BoxOutline = Drawing.new("Square"),
		Name       = Drawing.new("Text"),
		HealthBg   = Drawing.new("Square"),
		Health     = Drawing.new("Square"),
		Tracer     = Drawing.new("Line"),
		Distance   = Drawing.new("Text"),
		Skeleton   = {},
	}
	d.BoxOutline.Thickness    = 3
	d.BoxOutline.Filled       = false
	d.BoxOutline.Color        = Color3.new(0, 0, 0)
	d.BoxOutline.Transparency = 1
	d.BoxOutline.Visible      = false
	d.Box.Thickness    = 1.5
	d.Box.Filled       = false
	d.Box.Color        = getgenv().Settings.ESPBoxColor
	d.Box.Transparency = 1
	d.Box.Visible      = false
	d.Name.Size         = 14
	d.Name.Center       = true
	d.Name.Outline      = true
	d.Name.Color        = getgenv().Settings.ESPNameColor
	d.Name.Visible      = false
	d.HealthBg.Thickness    = 1
	d.HealthBg.Filled       = true
	d.HealthBg.Color        = Color3.fromRGB(0, 0, 0)
	d.HealthBg.Transparency = 0.5
	d.HealthBg.Visible      = false
	d.Health.Thickness    = 1
	d.Health.Filled       = true
	d.Health.Color        = Color3.fromRGB(0, 255, 0)
	d.Health.Transparency = 0.5
	d.Health.Visible      = false
	d.Tracer.Thickness    = 1.5
	d.Tracer.Color        = getgenv().Settings.ESPTracerColor
	d.Tracer.Transparency = 0.5
	d.Tracer.Visible      = false
	d.Distance.Size       = 13
	d.Distance.Center     = true
	d.Distance.Outline    = true
	d.Distance.Color      = getgenv().Settings.ESPDistanceColor
	d.Distance.Visible    = false
	for i = 1, 14 do
		local line = Drawing.new("Line")
		line.Thickness    = 1.5
		line.Color        = getgenv().Settings.ESPSkeletonColor
		line.Transparency = 1
		line.Visible      = false
		d.Skeleton[i]     = line
	end
	getgenv().EspData[player] = d
end

local function removePlayerESP(player)
	if not getgenv().EspData[player] then return end
	local d = getgenv().EspData[player]
	d.Box:Remove()
	d.BoxOutline:Remove()
	d.Name:Remove()
	d.HealthBg:Remove()
	d.Health:Remove()
	d.Tracer:Remove()
	d.Distance:Remove()
	for _, line in pairs(d.Skeleton) do line:Remove() end
	getgenv().EspData[player] = nil
end

local function hideAllESPDrawings(d)
	d.Box.Visible       = false
	d.BoxOutline.Visible = false
	d.Name.Visible      = false
	d.HealthBg.Visible  = false
	d.Health.Visible    = false
	d.Tracer.Visible    = false
	d.Distance.Visible  = false
	for _, line in pairs(d.Skeleton) do line.Visible = false end
end

local function updateAllESP()
	local center = getgenv().Camera.ViewportSize / 2
	local myTeam = getPlayerTeam(getgenv().LocalPlayer)
	for player, d in pairs(getgenv().EspData) do
		if not getgenv().Settings.ESP then hideAllESPDrawings(d); continue end
		local char = player.Character
		if not char then hideAllESPDrawings(d); continue end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then hideAllESPDrawings(d); continue end
		local hrp  = char:FindFirstChild("HumanoidRootPart")
		local head = char:FindFirstChild("Head")
		if not hrp or not head then hideAllESPDrawings(d); continue end
		local isTeammate = getPlayerTeam(player) == myTeam
		local boxColor   = isTeammate and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 255, 255)
		local headPos, onScreen = getgenv().Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
		local rootPos = getgenv().Camera:WorldToViewportPoint(hrp.Position)
		if not onScreen then hideAllESPDrawings(d); continue end
		local camDist  = math.floor((getgenv().Camera.CFrame.Position - hrp.Position).Magnitude)
		local height   = math.abs(headPos.Y - rootPos.Y)
		local width    = height * 0.5
		local boxX     = rootPos.X - (width / 2)
		local boxY     = headPos.Y
		if getgenv().Settings.ESPBox then
			if getgenv().Settings.ESPBoxOutline then
				d.BoxOutline.Size     = Vector2.new(width, height)
				d.BoxOutline.Position = Vector2.new(boxX, boxY)
				d.BoxOutline.Visible  = true
			else
				d.BoxOutline.Visible = false
			end
			d.Box.Size     = Vector2.new(width, height)
			d.Box.Position = Vector2.new(boxX, boxY)
			d.Box.Color    = getgenv().Settings.ESPBoxColor
			d.Box.Filled   = getgenv().Settings.ESPBoxFilled
			d.Box.Visible  = true
		else
			d.Box.Visible       = false
			d.BoxOutline.Visible = false
		end
		if getgenv().Settings.ESPHealth then
			local hp   = hum.Health / hum.MaxHealth
			local barX = boxX - 6
			d.HealthBg.Position = Vector2.new(barX, boxY)
			d.HealthBg.Size     = Vector2.new(2, height)
			d.HealthBg.Visible  = true
			d.Health.Position   = Vector2.new(barX, (boxY + height) - (height * hp))
			d.Health.Size       = Vector2.new(2, height * hp)
			d.Health.Color      = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
			d.Health.Visible    = true
		else
			d.HealthBg.Visible = false
			d.Health.Visible   = false
		end
		if getgenv().Settings.ESPName then
			d.Name.Text     = player.Name
			d.Name.Position = Vector2.new(rootPos.X, headPos.Y - 18)
			d.Name.Color    = getgenv().Settings.ESPNameColor
			d.Name.Visible  = true
		else
			d.Name.Visible = false
		end
		if getgenv().Settings.ESPDistance then
			d.Distance.Text     = "[" .. camDist .. "m]"
			d.Distance.Position = Vector2.new(rootPos.X, headPos.Y + height + 2)
			d.Distance.Color    = getgenv().Settings.ESPDistanceColor
			d.Distance.Visible  = true
		else
			d.Distance.Visible = false
		end
		if getgenv().Settings.ESPTracer then
			local fromVec
			if getgenv().Settings.ESPTracerFrom == "Top" then
				fromVec = Vector2.new(center.X, 0)
			elseif getgenv().Settings.ESPTracerFrom == "Middle" then
				fromVec = Vector2.new(center.X, center.Y)
			else
				fromVec = Vector2.new(center.X, getgenv().Camera.ViewportSize.Y)
			end
			d.Tracer.From    = fromVec
			d.Tracer.To      = Vector2.new(rootPos.X, rootPos.Y)
			d.Tracer.Color   = getgenv().Settings.ESPTracerColor
			d.Tracer.Visible = true
		else
			d.Tracer.Visible = false
		end
		if getgenv().Settings.ESPSkeleton then
			local boneSet = (char:FindFirstChild("UpperTorso") and getgenv().BoneLinks) or getgenv().BoneLinksR6
			for i, bone in pairs(boneSet) do
				local p1 = char:FindFirstChild(bone[1])
				local p2 = char:FindFirstChild(bone[2])
				if p1 and p2 and d.Skeleton[i] then
					local v1, on1 = getgenv().Camera:WorldToViewportPoint(p1.Position)
					local v2, on2 = getgenv().Camera:WorldToViewportPoint(p2.Position)
					if on1 and on2 then
						d.Skeleton[i].From    = Vector2.new(v1.X, v1.Y)
						d.Skeleton[i].To      = Vector2.new(v2.X, v2.Y)
						d.Skeleton[i].Color   = getgenv().Settings.ESPSkeletonColor
						d.Skeleton[i].Visible = true
					else
						d.Skeleton[i].Visible = false
					end
				elseif d.Skeleton[i] then
					d.Skeleton[i].Visible = false
				end
			end
		else
			for _, line in pairs(d.Skeleton) do line.Visible = false end
		end
	end
end

local function onPlayerJoined(player)
	if player == getgenv().LocalPlayer then return end
	createPlayerESP(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		removePlayerESP(player)
		createPlayerESP(player)
	end)
end

for _, player in pairs(getgenv().Players:GetPlayers()) do
	onPlayerJoined(player)
end
getgenv().Players.PlayerAdded:Connect(onPlayerJoined)
getgenv().Players.PlayerRemoving:Connect(removePlayerESP)
getgenv().RunService.RenderStepped:Connect(updateAllESP)

getgenv().ChamsCache = setmetatable({}, { __mode = "k" })

task.spawn(function()
	local hadAny = false
	while task.wait(0.5) do
		local enabled = getgenv().Settings.ChamsEnabled
		if not enabled and not hadAny then continue end
		hadAny = enabled
		pcall(function()
			local localTeam = getPlayerTeam(getgenv().LocalPlayer)
			local colour    = getgenv().Settings.ChamsColor
			if getgenv().Settings.RainbowChams then
				colour = Color3.fromHSV(tick() % 10 / 10, 1, 1)
			end
			for _, player in ipairs(getgenv().Players:GetPlayers()) do
				local char = player ~= getgenv().LocalPlayer and player.Character
				if char then
					local hl    = getgenv().ChamsCache[char]
					local pTeam = getPlayerTeam(player)
					local isTeam = pTeam ~= nil and localTeam ~= nil and pTeam == localTeam
					if enabled and not isTeam then
						if not hl or not hl.Parent then
							hl = Instance.new("Highlight")
							hl.Name             = "PerplexChams"
							hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
							hl.FillTransparency  = getgenv().Settings.ChamsTransparency
							hl.OutlineTransparency = 0
							hl.Adornee          = char
							hl.Parent           = char
							getgenv().ChamsCache[char] = hl
						end
						hl.FillColor    = colour
						hl.OutlineColor = colour
						if getgenv().Settings.GlowEnabled then
							hl.FillTransparency    = getgenv().Settings.GlowTransparency
							hl.OutlineTransparency = 0
						else
							hl.FillTransparency    = getgenv().Settings.ChamsTransparency
							hl.OutlineTransparency = 1
						end
					elseif hl then
						hl:Destroy()
						getgenv().ChamsCache[char] = nil
					end
				end
			end
		end)
	end
end)

getgenv().NativeControllers = {}

task.spawn(function()
	local function loadController(name)
		if getgenv().NativeControllers[name] then return getgenv().NativeControllers[name] end
		pcall(function()
			if typeof(getloadedmodules) ~= "function" then return end
			for _, mod in ipairs(getloadedmodules()) do
				local n
				pcall(function() n = mod.Name end)
				if n == name then
					local ok, val = pcall(require, mod)
					if ok and type(val) == "table" then
						getgenv().NativeControllers[name] = val
					end
				end
			end
		end)
		return getgenv().NativeControllers[name]
	end

	local function isDeadNative()
		local spectate = loadController("SpectateController")
		if type(spectate) == "table" and typeof(rawget(spectate, "IsLocalPlayerDead")) == "function" then
			local ok, dead = pcall(function() return spectate:IsLocalPlayerDead() end)
			if ok and type(dead) == "boolean" then return dead end
		end
		local char = getgenv().LocalPlayer.Character
		return char == nil or char:GetAttribute("Dead") == true
	end
	getgenv().ParsaIsDead = isDeadNative

	local function isSpectatingNative()
		local spectate = loadController("SpectateController")
		if type(spectate) == "table" then
			local ok, taking = pcall(function() return spectate:IsTakingOverCamera() end)
			if ok and taking == true then return true end
			local ok2, watched = pcall(function() return spectate:GetPlayer() end)
			if ok2 and typeof(watched) == "Instance" and watched ~= getgenv().LocalPlayer then return true end
		end
		return isDeadNative()
	end
	getgenv().ParsaIsSpectating = isSpectatingNative

	for _ = 1, 30 do
		task.wait(1)
		local assist = loadController("AimAssistController")
		if type(assist) == "table" and typeof(rawget(assist, "SetEnabled")) == "function" then
			local applied = nil
			task.spawn(function()
				while task.wait(0.25) do
					local want = getgenv().Settings.NativeAimAssist
					if want ~= applied then
						applied = want
						pcall(function() assist:SetEnabled(want) end)
					end
				end
			end)
			break
		end
	end

	for _ = 1, 30 do
		task.wait(1)
		local flinch = loadController("HitFlinch")
		if type(flinch) == "table" and typeof(rawget(flinch, "clear")) == "function" then
			task.spawn(function()
				while task.wait() do
					if getgenv().Settings.NoFlinch then
						pcall(function() flinch:clear() end)
					end
				end
			end)
			break
		end
	end

	local wasDead = nil
	task.spawn(function()
		while task.wait(1) do
			if not getgenv().Settings.AutoSpectate then wasDead = false; continue end
			local dead = isDeadNative()
			if dead and not wasDead then
				wasDead = true
				local spectate = loadController("SpectateController")
				if type(spectate) == "table" and typeof(rawget(spectate, "Switch")) == "function" then
					task.wait(1.5)
					if isDeadNative() and getgenv().Settings.AutoSpectate then
						pcall(function() spectate:Switch() end)
					end
				end
			elseif not dead then
				wasDead = false
			end
		end
	end)
end)

task.spawn(function()
	local GuiService = game:GetService("GuiService")
	while task.wait(0.3) do
		if not getgenv().Settings.FreeMouseFocus then continue end
		pcall(function()
			if GuiService.AutoSelectGuiEnabled then
				GuiService.AutoSelectGuiEnabled = false
			end
			if GuiService.SelectedObject ~= nil then
				GuiService.SelectedObject = nil
			end
		end)
	end
end)

local function playSoundAsset(folder, soundName, variant)
	local sounds = getgenv().ReplicatedStorage:FindFirstChild("Sounds")
	if not sounds then return end
	local knifeFolder = sounds:FindFirstChild(getgenv().Settings.SelectedKnife)
	if not knifeFolder then return end
	local sub = knifeFolder:WaitForChild(folder, 5)
	if not sub then return end
	local track = sub:WaitForChild(soundName .. (variant or ""), 5)
	if not track then return end
	local clone = track:Clone()
	clone.Parent = getgenv().Camera
	clone:Play()
	clone.Ended:Once(function() clone:Destroy() end)
	return clone
end

local function applyBoneToModel(weaponAsset, boneTarget, boneSource, boneName, offset)
	local targetBone = getgenv().KnifeModelInstance:FindFirstChild(boneTarget)
	if not targetBone then return end
	local sourcePart = weaponAsset:WaitForChild(boneSource)
	local clone = sourcePart:Clone()
	clone.CanCollide  = false
	clone.Anchored    = false
	clone.CastShadow  = false
	clone.CanTouch    = false
	clone.CanQuery    = false
	clone.Name        = boneName
	clone.Parent      = targetBone
	local motor = Instance.new("Motor6D")
	motor.Part0  = targetBone
	motor.Part1  = clone
	motor.C0     = offset
	motor.Parent = targetBone
end

local function hideKnifeModel(model)
	for _, desc in model:GetDescendants() do
		local isMesh = desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("Texture")
		if isMesh then desc.Transparency = 1 end
	end
end

local function cleanupKnifeModel()
	getgenv().KnifeIsEquipped = false
	getgenv().ContextActionSvc:UnbindAction(getgenv().InspectActionName)
	getgenv().ContextActionSvc:UnbindAction(getgenv().AttackActionName)
	if getgenv().KnifeModelInstance then
		getgenv().KnifeModelInstance:Destroy()
		getgenv().KnifeModelInstance = nil
	end
	getgenv().KnifeAnimator    = nil
	getgenv().KnifeIsInspecting = false
	getgenv().KnifeIsAttacking  = false
end

local function setupKnifeModel(originalKnifeModel)
	if getgenv().KnifeIsEquipped or not getgenv().Settings.CustomKnifeEnabled then return end
	local playerChar = getgenv().LocalPlayer.Character
	if not playerChar then return end
	getgenv().KnifeIsEquipped = true
	local knifeAsset  = getgenv().ReplicatedStorage.Assets.Weapons:WaitForChild(getgenv().Settings.SelectedKnife)
	local knifeOffset = getgenv().KnifeOffsets[getgenv().Settings.SelectedKnife]
	getgenv().KnifeModelInstance = knifeAsset:WaitForChild("Camera"):Clone()
	getgenv().KnifeModelInstance.Name   = getgenv().Settings.SelectedKnife
	getgenv().KnifeModelInstance.Parent = getgenv().Camera
	for _, desc in getgenv().KnifeModelInstance:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.CanCollide  = false
			desc.Anchored    = false
			desc.CastShadow  = false
			desc.CanTouch    = false
			desc.CanQuery    = false
		end
	end
	hideKnifeModel(originalKnifeModel)
	local isT = playerChar.Parent and playerChar.Parent.Name == "Terrorists"
	if isT then
		local tGlove = getgenv().ReplicatedStorage.Assets.Weapons:WaitForChild("T Glove")
		applyBoneToModel(tGlove, "Left Arm",  "Left Arm",  "Glove", CFrame.new(0, 0, -1.5))
		applyBoneToModel(tGlove, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
	else
		local idf     = getgenv().ReplicatedStorage.Assets.Sleeves:WaitForChild("IDF")
		local ctGlove = getgenv().ReplicatedStorage.Assets.Weapons:WaitForChild("CT Glove")
		applyBoneToModel(idf,     "Left Arm",  "Left Arm",  "Sleeve", CFrame.new(0, 0, 0.5))
		applyBoneToModel(ctGlove, "Left Arm",  "Left Arm",  "Glove",  CFrame.new(0, 0, -1.5))
		applyBoneToModel(idf,     "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
		applyBoneToModel(ctGlove, "Right Arm", "Right Arm", "Glove",  CFrame.new(0, 0, -1.5))
	end
	local animCtrl = getgenv().KnifeModelInstance:FindFirstChildOfClass("AnimationController")
		or getgenv().KnifeModelInstance:FindFirstChildOfClass("Animator")
	getgenv().KnifeAnimator = animCtrl:FindFirstChildWhichIsA("Animator") or animCtrl
	local weaponAnims = getgenv().ReplicatedStorage.Assets.WeaponAnimations
		:WaitForChild(getgenv().Settings.SelectedKnife)
		:WaitForChild("CameraAnimations")
	getgenv().KnifeEquipAnim = getgenv().KnifeAnimator:LoadAnimation(weaponAnims:WaitForChild("Equip"))
	getgenv().KnifeIdleAnim  = getgenv().KnifeAnimator:LoadAnimation(weaponAnims:WaitForChild("Idle"))
	getgenv().KnifeSwing1    = getgenv().KnifeAnimator:LoadAnimation(weaponAnims:WaitForChild("Swing1"))
	local sw2 = weaponAnims:WaitForChild("Swing2")
	getgenv().KnifeSwing2    = getgenv().KnifeAnimator:LoadAnimation(sw2)
	getgenv().KnifeSwing3    = getgenv().KnifeAnimator:LoadAnimation(weaponAnims:WaitForChild("Heavy Swing"))
	getgenv().KnifeModelInstance:SetPrimaryPartCFrame(getgenv().Camera.CFrame * CFrame.new(0, -1.5, 5))
	getgenv().TweenService:Create(
		getgenv().KnifeModelInstance.PrimaryPart,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = getgenv().Camera.CFrame * knifeOffset }
	):Play()
	getgenv().KnifeEquipAnim:Play()
	playSoundAsset("Equip", "1")
	local function knifeActionHandler(actionName, inputState)
		if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
		if not getgenv().KnifeIsEquipped or not getgenv().KnifeAnimator then return Enum.ContextActionResult.Pass end
		if actionName == getgenv().InspectActionName then
			if getgenv().KnifeEquipAnim and getgenv().KnifeEquipAnim.IsPlaying then return Enum.ContextActionResult.Pass end
			if getgenv().KnifeIsInspecting or getgenv().KnifeIsAttacking then return Enum.ContextActionResult.Pass end
			getgenv().KnifeIsInspecting = true
			if getgenv().KnifeIdleAnim then getgenv().KnifeIdleAnim:Stop() end
			local inspectAnim = getgenv().KnifeAnimator:LoadAnimation(weaponAnims:WaitForChild("Inspect"))
			inspectAnim:Play()
			inspectAnim.Stopped:Once(function() getgenv().KnifeIsInspecting = false end)
		elseif actionName == getgenv().AttackActionName then
			local now = os.clock()
			if getgenv().KnifeEquipAnim and getgenv().KnifeEquipAnim.IsPlaying then return Enum.ContextActionResult.Pass end
			if now - getgenv().KnifeLastAttackTime < getgenv().KnifeAttackCooldown then return Enum.ContextActionResult.Pass end
			if getgenv().KnifeIsInspecting then
				getgenv().KnifeIsInspecting = false
			end
			getgenv().KnifeIsAttacking    = true
			getgenv().KnifeLastAttackTime = now
			if getgenv().KnifeIdleAnim then getgenv().KnifeIdleAnim:Stop() end
			local swings   = { getgenv().KnifeSwing1, getgenv().KnifeSwing2, getgenv().KnifeSwing3 }
			local chosenSw = swings[math.random(1, #swings)]
			if chosenSw then
				chosenSw:Play()
				chosenSw.Stopped:Once(function() getgenv().KnifeIsAttacking = false end)
			else
				getgenv().KnifeIsAttacking = false
			end
			playSoundAsset("HitOne", "1")
		end
		return Enum.ContextActionResult.Pass
	end
	getgenv().ContextActionSvc:BindAction(getgenv().InspectActionName, knifeActionHandler, false, Enum.KeyCode.F)
	getgenv().ContextActionSvc:BindAction(getgenv().AttackActionName,  knifeActionHandler, false, Enum.UserInputType.MouseButton1)
end

task.spawn(function()
	while task.wait(0.1) do
		local hasKnifeModel = getgenv().Camera:FindFirstChild("T Knife") or getgenv().Camera:FindFirstChild("CT Knife")
		if getgenv().Settings.CustomKnifeEnabled and hasKnifeModel then
			if not getgenv().KnifeIsEquipped then
				setupKnifeModel(hasKnifeModel)
			end
		else
			if getgenv().KnifeIsEquipped then
				cleanupKnifeModel()
			end
		end
	end
end)

local function applySkinToWeapon(weaponContainer)
	if not weaponContainer then return end
	if not getgenv().Settings.SkinChangerEnabled or not getPlayerTeam(getgenv().LocalPlayer) then return end
	local skinName = getgenv().SkinSelected[weaponContainer.Name]
	if not skinName then return end
	pcall(function()
		local skinsRoot = getgenv().SkinsAsset
		if not skinsRoot then return end
		local weaponSkins = skinsRoot:FindFirstChild(weaponContainer.Name)
		if not weaponSkins then return end
		local selectedSkin = weaponSkins:FindFirstChild(skinName)
		if not selectedSkin then return end
		local cameraFolder = selectedSkin:FindFirstChild("Camera")
		if cameraFolder then
			cameraFolder = cameraFolder:FindFirstChild(getgenv().SkinWear)
		end
		if not cameraFolder then return end
		for _, child in getgenv().Camera:GetChildren() do
			if child:FindFirstChild("Left Arm") or child:FindFirstChild("Right Arm") then
				local gloveSkins = skinsRoot:FindFirstChild("Sports Gloves")
				local gloveSelected = gloveSkins and gloveSkins:FindFirstChild(getgenv().SkinSelected["Sports Gloves"])
				local gloveFolder
				if gloveSelected then
					gloveFolder = gloveSelected:FindFirstChild("Camera") and gloveSelected.Camera:FindFirstChild(getgenv().SkinWear)
				end
				if gloveFolder then
					for _, armName in ipairs({ "Left Arm", "Right Arm" }) do
						local armPart   = child:FindFirstChild(armName)
						local glovePart = gloveFolder:FindFirstChild(armName)
						if armPart and glovePart then
							local gloveAttach = armPart:FindFirstChild("Glove")
							if gloveAttach then
								local existingSA = gloveAttach:FindFirstChildOfClass("SurfaceAppearance")
								if existingSA then existingSA:Destroy() end
								local cloned = glovePart:Clone()
								cloned.Name   = "SurfaceAppearance"
								cloned.Parent = gloveAttach
							end
						end
					end
				end
			end
			if not getgenv().GloveNames[weaponContainer.Name] then
				local weaponPart = weaponContainer:FindFirstChild("Weapon")
				if weaponPart then
					for _, desc in weaponPart:GetDescendants() do
						if desc:IsA("BasePart") then
							local skinPart = cameraFolder:FindFirstChild(desc.Name)
							if skinPart then
								local existingSA = desc:FindFirstChildOfClass("SurfaceAppearance")
								if existingSA then existingSA:Destroy() end
								local cloned = skinPart:Clone()
								cloned.Name   = "SurfaceAppearance"
								cloned.Parent = desc
							end
						end
					end
				end
			end
		end
		weaponContainer:SetAttribute("SkinApplied", skinName)
	end)
end

getgenv().Camera.ChildAdded:Connect(function(child)
	if not getgenv().Settings.SkinChangerEnabled or not getPlayerTeam(getgenv().LocalPlayer) then return end
	task.wait(getgenv().SkinApplyDelay)
	applySkinToWeapon(child)
end)

task.spawn(function()
	while task.wait(0.5) do
		if getgenv().Settings.SkinChangerEnabled and getPlayerTeam(getgenv().LocalPlayer) then
			for _, child in getgenv().Camera:GetChildren() do
				local selected = getgenv().SkinSelected[child.Name]
				if selected and child:GetAttribute("SkinApplied") ~= selected then
					applySkinToWeapon(child)
				end
			end
		end
	end
end)

local function registerSkinDropdown(tab, itemName)
	if not getgenv().SkinsAsset then return end
	local skinFolder = getgenv().SkinsAsset:FindFirstChild(itemName)
	if not skinFolder then return end
	local names = {}
	for _, v in skinFolder:GetChildren() do
		table.insert(names, v.Name)
	end
	getgenv().SkinNames[itemName] = names
	if not getgenv().SkinSelected[itemName] then
		getgenv().SkinSelected[itemName] = names[1]
	end
	local dd = tab:AddDropdown({
		Name     = itemName,
		Options  = names,
		Default  = getgenv().SkinSelected[itemName],
		Flag     = "Skin_" .. itemName,
		Callback = function(chosen)
			getgenv().SkinSelected[itemName] = chosen
			for _, child in getgenv().Camera:GetChildren() do
				child:SetAttribute("SkinApplied", nil)
				applySkinToWeapon(child)
			end
		end,
	})
	getgenv().SkinDropdowns[itemName] = getgenv().SkinDropdowns[itemName] or {}
	table.insert(getgenv().SkinDropdowns[itemName], dd)
end

getgenv().CombatTab = getgenv().Window:AddTab({ Name = "Combat", Icon = "crosshair", Subtitle = "Aimbot, silent aim,\ntriggerbot & hitbox" })
getgenv().RageTab   = getgenv().Window:AddTab({ Name = "Rage",   Icon = "zap",       Subtitle = "Spinbot, anti-aim,\nfake lag. Risky!" })
getgenv().SkinsTab  = getgenv().Window:AddTab({ Name = "Skins",  Icon = "swords",    Subtitle = "Knife & weapon\nskin changer" })
getgenv().VisualsTab = getgenv().Window:AddTab({ Name = "Visuals", Icon = "eye",     Subtitle = "ESP, chams, glow\n& world effects" })
getgenv().MiscTab   = getgenv().Window:AddTab({ Name = "Misc",   Icon = "settings",  Subtitle = "Movement, utility\n& server info" })
getgenv().ConfigTab = getgenv().Window:AddTab({ Name = "Config", Icon = "save",      Subtitle = "Save, load\n& reset config" })

local AimbotSub    = getgenv().CombatTab:AddSubTab("Aimbot")
local SilentSub    = getgenv().CombatTab:AddSubTab("Silent Aim")
local RagebotSub   = getgenv().CombatTab:AddSubTab("Ragebot")
local TriggerSub   = getgenv().CombatTab:AddSubTab("Triggerbot")
local HitboxSub    = getgenv().CombatTab:AddSubTab("Hitbox")

AimbotSub:AddSection("Aimbot")
AimbotSub:AddToggle({
	Name        = "Enable Aimbot",
	Description = "Locks aim to nearest enemy in FOV.\nHold right-click to activate.",
	Default     = false,
	Flag        = "Aimbot",
	Callback    = function(v) getgenv().Settings.Aimbot = v end,
})
AimbotSub:AddToggle({
	Name        = "Team Check",
	Description = "Skip teammates.",
	Default     = true,
	Flag        = "AimbotTeamCheck",
	Callback    = function(v) getgenv().Settings.AimbotTeamCheck = v end,
})
AimbotSub:AddToggle({
	Name        = "Wall Check",
	Description = "Only aim at visible enemies.",
	Default     = true,
	Flag        = "AimbotWallCheck",
	Callback    = function(v) getgenv().Settings.AimbotWallCheck = v end,
})
AimbotSub:AddToggle({
	Name        = "Show FOV Circle",
	Description = "Draws aimbot FOV radius.",
	Default     = true,
	Flag        = "AimbotFOVCircle",
	Callback    = function(v) getgenv().Settings.AimbotFOVCircle = v end,
})
AimbotSub:AddSlider({
	Name     = "FOV Radius",
	Min      = 10,
	Max      = 500,
	Default  = 70,
	Suffix   = " px",
	Flag     = "AimbotFOV",
	Callback = function(v) getgenv().Settings.AimbotFOV = v end,
})
AimbotSub:AddDropdown({
	Name     = "Hit Part",
	Options  = { "Head", "HumanoidRootPart", "UpperTorso" },
	Default  = "Head",
	Flag     = "AimbotHitPart",
	Callback = function(v) getgenv().Settings.AimbotHitPart = v end,
})

SilentSub:AddSection("Silent Aim")
SilentSub:AddToggle({
	Name        = "Enable Silent Aim",
	Description = "Hooks _performRaycast to redirect bullets.\nRisky - may get detected.",
	Default     = false,
	Flag        = "SilentEnabled",
	Callback    = function(v) getgenv().Settings.SilentEnabled = v end,
})
SilentSub:AddToggle({
	Name        = "Wallbang",
	Description = "Shoot through walls silently.",
	Default     = false,
	Flag        = "SilentWallbang",
	Callback    = function(v) getgenv().Settings.SilentWallbang = v end,
})
SilentSub:AddToggle({
	Name        = "Team Check",
	Description = "Skip teammates.",
	Default     = true,
	Flag        = "SilentTeamCheck",
	Callback    = function(v) getgenv().Settings.SilentTeamCheck = v end,
})
SilentSub:AddToggle({
	Name        = "Use FOV Limit",
	Description = "Limits silent aim to FOV radius.\nDisabled = no limit.",
	Default     = false,
	Flag        = "SilentUseFOV",
	Callback    = function(v) getgenv().Settings.SilentUseFOV = v end,
})
SilentSub:AddToggle({
	Name        = "Show FOV Circle",
	Description = "Draws the FOV radius circle on screen.",
	Default     = false,
	Flag        = "SilentFOVCircleVisible",
	Callback    = function(v)
		getgenv().Settings.SilentUseFOV = v
	end,
})
SilentSub:AddSlider({
	Name     = "FOV Radius",
	Min      = 10,
	Max      = 500,
	Default  = 130,
	Suffix   = " px",
	Flag     = "SilentFOV",
	Callback = function(v) getgenv().Settings.SilentFOV = v end,
})
SilentSub:AddDropdown({
	Name     = "Hit Part",
	Options  = { "Head", "UpperTorso", "LowerTorso" },
	Default  = "Head",
	Flag     = "SilentHitPart",
	Callback = function(v) getgenv().Settings.SilentHitPart = v end,
})

RagebotSub:AddSection("Ragebot")
RagebotSub:AddToggle({
	Name        = "Enable Ragebot",
	Description = "Auto-shoots at nearest enemy.\nExtremely risky - high ban chance.",
	Default     = false,
	Flag        = "Ragebot",
	Callback    = function(v) getgenv().Settings.Ragebot = v end,
})
RagebotSub:AddToggle({
	Name        = "Visible Check",
	Description = "Only target visible enemies.",
	Default     = true,
	Flag        = "RageVisibleCheck",
	Callback    = function(v) getgenv().Settings.RageVisibleCheck = v end,
})
RagebotSub:AddToggle({
	Name        = "Team Check",
	Description = "Skip teammates.",
	Default     = true,
	Flag        = "RageTeamCheck",
	Callback    = function(v) getgenv().Settings.RageTeamCheck = v end,
})
RagebotSub:AddToggle({
	Name        = "Wall Check",
	Description = "Only target enemies through walls.",
	Default     = false,
	Flag        = "RageWallCheck",
	Callback    = function(v) getgenv().Settings.RageWallCheck = v end,
})
RagebotSub:AddSlider({
	Name     = "Fire Delay",
	Min      = 0,
	Max      = 200,
	Default  = 10,
	Suffix   = " ms",
	Flag     = "RageDelay",
	Callback = function(v) getgenv().Settings.RageDelay = v / 1000 end,
})
RagebotSub:AddDropdown({
	Name     = "Hit Part",
	Options  = { "Head", "HumanoidRootPart" },
	Default  = "Head",
	Flag     = "RageHitPart",
	Callback = function(v) getgenv().Settings.RageHitPart = v end,
})

TriggerSub:AddSection("Triggerbot")
TriggerSub:AddToggle({
	Name        = "Enable Triggerbot",
	Description = "Auto-shoots when crosshair is on enemy.\nRisky - may be detected.",
	Default     = false,
	Flag        = "Triggerbot",
	Callback    = function(v) getgenv().Settings.Triggerbot = v end,
})
TriggerSub:AddSlider({
	Name     = "Trigger Delay",
	Min      = 0,
	Max      = 200,
	Default  = 10,
	Suffix   = " ms",
	Flag     = "TriggerDelay",
	Callback = function(v) getgenv().Settings.TriggerDelay = v / 1000 end,
})

HitboxSub:AddSection("Hitbox Expander")
HitboxSub:AddToggle({
	Name        = "Enable Hitbox",
	Description = "Expands enemy hitboxes.\nRisky - visible to others.",
	Default     = false,
	Flag        = "Hitbox",
	Callback    = function(v) getgenv().Settings.Hitbox = v end,
})
HitboxSub:AddSlider({
	Name     = "Hitbox Size",
	Min      = 1,
	Max      = 20,
	Default  = 7,
	Suffix   = " studs",
	Flag     = "HitboxSize",
	Callback = function(v) getgenv().Settings.HitboxSize = v end,
})
HitboxSub:AddSlider({
	Name     = "Transparency",
	Min      = 0,
	Max      = 10,
	Default  = 0,
	Suffix   = "",
	Flag     = "HitboxTransparency",
	Callback = function(v) getgenv().Settings.HitboxTransparency = v / 10 end,
})

local SpinbotSub  = getgenv().RageTab:AddSubTab("Spinbot")
local AntiAimSub  = getgenv().RageTab:AddSubTab("Anti-Aim")
local FakeLagSub  = getgenv().RageTab:AddSubTab("Fake Lag")
local WeaponSub   = getgenv().RageTab:AddSubTab("Weapons")

SpinbotSub:AddSection("Spinbot")
SpinbotSub:AddToggle({
	Name        = "Enable Spinbot",
	Description = "Spins your character rapidly.\nMakes you hard to hit. Risky!",
	Default     = false,
	Flag        = "SpinbotToggle",
	Callback    = function(v)
		getgenv().Settings.SpinbotEnabled = v
		if v then
			getgenv().Window:Notify({ Title = "Spinbot", Content = "Spinbot activated.", Type = "info", Duration = 2 })
		end
	end,
})
SpinbotSub:AddSlider({
	Name     = "Spin Speed",
	Min      = 1,
	Max      = 100,
	Default  = 50,
	Suffix   = "",
	Flag     = "SpinSpeed",
	Callback = function(v) getgenv().Settings.SpinSpeed = v end,
})

AntiAimSub:AddSection("Anti-Aim")
AntiAimSub:AddToggle({
	Name        = "Enable Anti-Aim",
	Description = "Rotates your hitbox away from enemies.\nRisky!",
	Default     = false,
	Flag        = "AntiAimToggle",
	Callback    = function(v) getgenv().Settings.AntiAimEnabled = v end,
})
AntiAimSub:AddToggle({
	Name        = "Head Jitter",
	Description = "Randomizes head rotation each frame.\nRisky!",
	Default     = false,
	Flag        = "JitterToggle",
	Callback    = function(v) getgenv().Settings.JitterEnabled = v end,
})

FakeLagSub:AddSection("Fake Lag")
FakeLagSub:AddToggle({
	Name        = "Enable Fake Lag",
	Description = "Simulates network lag to confuse enemies.\nRisky - may cause disconnection.",
	Default     = false,
	Flag        = "FakeLagToggle",
	Callback    = function(v) getgenv().Settings.FakeLagEnabled = v end,
})
FakeLagSub:AddSlider({
	Name     = "Lag Amount",
	Min      = 1,
	Max      = 10,
	Default  = 3,
	Suffix   = " ticks",
	Flag     = "FakeLagAmount",
	Callback = function(v) getgenv().Settings.FakeLagAmount = v end,
})

WeaponSub:AddSection("Weapon Modifiers")
WeaponSub:AddToggle({
	Name        = "No Recoil",
	Description = "Removes weapon camera recoil.",
	Default     = false,
	Flag        = "NoRecoil",
	Callback    = function(v) getgenv().Settings.NoRecoil = v end,
})
WeaponSub:AddToggle({
	Name        = "No Spread",
	Description = "Removes bullet spread.",
	Default     = false,
	Flag        = "NoSpread",
	Callback    = function(v) getgenv().Settings.NoSpread = v end,
})
WeaponSub:AddToggle({
	Name        = "Firerate Changer",
	Description = "Changes weapon fire rate.\nRisky - may be detected.",
	Default     = false,
	Flag        = "Firerate",
	Callback    = function(v) getgenv().Settings.Firerate = v end,
})
WeaponSub:AddSlider({
	Name     = "Fire Rate Value",
	Min      = 1,
	Max      = 100,
	Default  = 10,
	Suffix   = " ms",
	Flag     = "FirerateValue",
	Callback = function(v) getgenv().Settings.FirerateValue = v / 1000 end,
})
WeaponSub:AddDivider()
WeaponSub:AddSection("Weapon State")
WeaponSub:AddToggle({
	Name        = "Infinite Ammo",
	Description = "Auto-refills magazine when nearly empty.\nRisky!",
	Default     = false,
	Flag        = "InfiniteAmmo",
	Callback    = function(v) getgenv().Settings.InfiniteAmmo = v end,
})
WeaponSub:AddToggle({
	Name        = "Instant Reload",
	Description = "Skips reload animation instantly.",
	Default     = false,
	Flag        = "InstantReload",
	Callback    = function(v) getgenv().Settings.InstantReload = v end,
})
WeaponSub:AddToggle({
	Name        = "Instant Scope",
	Description = "Removes scope-in delay.",
	Default     = false,
	Flag        = "InstantScope",
	Callback    = function(v) getgenv().Settings.InstantScope = v end,
})
WeaponSub:AddDivider()
WeaponSub:AddSection("Anti-Effect")
WeaponSub:AddToggle({
	Name        = "Anti-Flashbang",
	Description = "Prevents flashbang from blinding you.",
	Default     = false,
	Flag        = "AntiFlash",
	Callback    = function(v) getgenv().Settings.AntiFlash = v end,
})
WeaponSub:AddToggle({
	Name        = "Anti-Smoke",
	Description = "Removes smoke grenade visuals.",
	Default     = false,
	Flag        = "AntiSmoke",
	Callback    = function(v) getgenv().Settings.AntiSmoke = v end,
})

local KnifeSub  = getgenv().SkinsTab:AddSubTab("Knife")
local WeapSkinCT = getgenv().SkinsTab:AddSubTab("CT Weapons")
local WeapSkinT  = getgenv().SkinsTab:AddSubTab("T Weapons")
local GloveSub   = getgenv().SkinsTab:AddSubTab("Gloves")
local OtherSkin  = getgenv().SkinsTab:AddSubTab("Other")

KnifeSub:AddSection("Custom Knife")
KnifeSub:AddToggle({
	Name        = "Enable Custom Knife",
	Description = "Replaces your knife with a custom model.",
	Default     = false,
	Flag        = "CustomKnifeToggle",
	Callback    = function(v)
		getgenv().Settings.CustomKnifeEnabled = v
		if not v then cleanupKnifeModel() end
	end,
})
KnifeSub:AddDropdown({
	Name     = "Selected Knife",
	Options  = { "Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife" },
	Default  = "Butterfly Knife",
	Flag     = "KnifeDropdown",
	Callback = function(v)
		getgenv().Settings.SelectedKnife = v
		if getgenv().KnifeIsEquipped then cleanupKnifeModel() end
	end,
})
KnifeSub:AddDivider()
KnifeSub:AddSection("Knife Skins")
for knifeName in pairs(getgenv().KnifeNames) do
	registerSkinDropdown(KnifeSub, knifeName)
end

KnifeSub:AddSection("Skin Changer")
KnifeSub:AddToggle({
	Name        = "Enable Skin Changer",
	Description = "Applies custom skins to weapons.\nLocal only - only you see them.",
	Default     = false,
	Flag        = "SkinChanger",
	Callback    = function(v)
		getgenv().Settings.SkinChangerEnabled = v
		if v then
			getgenv().Window:Notify({ Title = "Skin Changer", Content = "Enabled.", Type = "success", Duration = 2 })
		end
	end,
})
KnifeSub:AddButton({
	Name     = "Randomize All Skins",
	Primary  = false,
	Callback = function()
		for name, names in pairs(getgenv().SkinNames) do
			if #names > 0 then
				getgenv().SkinSelected[name] = names[math.random(1, #names)]
			end
		end
		for _, child in getgenv().Camera:GetChildren() do
			child:SetAttribute("SkinApplied", nil)
			applySkinToWeapon(child)
		end
		getgenv().Window:Notify({ Title = "Skins", Content = "Randomized all skins.", Type = "success", Duration = 2 })
	end,
})

WeapSkinCT:AddSection("CT Weapons")
for weapName in pairs(getgenv().CTWeapons) do
	registerSkinDropdown(WeapSkinCT, weapName)
end

WeapSkinT:AddSection("T Weapons")
for weapName in pairs(getgenv().TWeapons) do
	registerSkinDropdown(WeapSkinT, weapName)
end

GloveSub:AddSection("Gloves")
GloveSub:AddToggle({
	Name        = "Custom Gloves",
	Description = "Forces custom gloves on your viewmodel.\nLocal only - works with knife model.",
	Default     = false,
	Flag        = "CustomGloves",
	Callback    = function(v)
		getgenv().Settings.CustomGloves = v
		if getgenv().KnifeIsEquipped then cleanupKnifeModel() end
	end,
})
for gloveName in pairs(getgenv().GloveNames) do
	registerSkinDropdown(GloveSub, gloveName)
end

OtherSkin:AddSection("Other Skins")
if getgenv().SkinsAsset then
	for _, child in getgenv().SkinsAsset:GetChildren() do
		local cname = child.Name
		local skip = getgenv().ExcludedSkins[cname] or getgenv().KnifeNames[cname]
			or getgenv().GloveNames[cname] or getgenv().CTWeapons[cname] or getgenv().TWeapons[cname]
		if not skip then
			registerSkinDropdown(OtherSkin, cname)
		end
	end
end

local ESPSub    = getgenv().VisualsTab:AddSubTab("ESP")
local ChamsSub  = getgenv().VisualsTab:AddSubTab("Chams")
local WorldSub  = getgenv().VisualsTab:AddSubTab("World")

ESPSub:AddSection("ESP Master")
ESPSub:AddToggle({
	Name        = "Enable ESP",
	Description = "Shows player info through walls.",
	Default     = false,
	Flag        = "ESPToggle",
	Callback    = function(v) getgenv().Settings.ESP = v end,
})
ESPSub:AddDivider()
ESPSub:AddSection("Box ESP")
ESPSub:AddDropdown({
	Name     = "Box Type",
	Options  = { "2D", "3D", "Corner", "Disabled" },
	Default  = "2D",
	Flag     = "ESPBoxType",
	Callback = function(v)
		getgenv().Settings.ESPBoxType = v
		getgenv().Settings.ESPBox = v ~= "Disabled"
	end,
})
ESPSub:AddToggle({
	Name        = "Show Box",
	Description = "Draws a box around enemies.",
	Default     = true,
	Flag        = "ESPBox",
	Callback    = function(v) getgenv().Settings.ESPBox = v end,
})
ESPSub:AddToggle({
	Name        = "Box Filled",
	Description = "Fills the box with color.",
	Default     = false,
	Flag        = "ESPBoxFilled",
	Callback    = function(v) getgenv().Settings.ESPBoxFilled = v end,
})
ESPSub:AddToggle({
	Name        = "Box Outline",
	Description = "Adds a dark border to the box.",
	Default     = true,
	Flag        = "ESPBoxOutline",
	Callback    = function(v) getgenv().Settings.ESPBoxOutline = v end,
})
ESPSub:AddColorPicker({
	Name     = "Box Color",
	Default  = Color3.fromRGB(255, 255, 255),
	Flag     = "ESPBoxColor",
	Callback = function(v) getgenv().Settings.ESPBoxColor = v end,
})
ESPSub:AddDivider()
ESPSub:AddSection("Health ESP")
ESPSub:AddToggle({
	Name        = "Show Health Bar",
	Description = "Shows a health bar beside the box.",
	Default     = false,
	Flag        = "ESPHealth",
	Callback    = function(v) getgenv().Settings.ESPHealth = v end,
})
ESPSub:AddDivider()
ESPSub:AddSection("Text ESP")
ESPSub:AddToggle({
	Name        = "Show Name",
	Description = "Shows player username above the box.",
	Default     = false,
	Flag        = "ESPName",
	Callback    = function(v) getgenv().Settings.ESPName = v end,
})
ESPSub:AddColorPicker({
	Name     = "Name Color",
	Default  = Color3.fromRGB(255, 255, 255),
	Flag     = "ESPNameColor",
	Callback = function(v) getgenv().Settings.ESPNameColor = v end,
})
ESPSub:AddToggle({
	Name        = "Show Distance",
	Description = "Shows distance in studs below the box.",
	Default     = false,
	Flag        = "ESPDistance",
	Callback    = function(v) getgenv().Settings.ESPDistance = v end,
})
ESPSub:AddColorPicker({
	Name     = "Distance Color",
	Default  = Color3.fromRGB(200, 200, 200),
	Flag     = "ESPDistanceColor",
	Callback = function(v) getgenv().Settings.ESPDistanceColor = v end,
})
ESPSub:AddDivider()
ESPSub:AddSection("Tracers")
ESPSub:AddToggle({
	Name        = "Show Tracers",
	Description = "Draws lines from screen edge to enemies.",
	Default     = false,
	Flag        = "ESPTracer",
	Callback    = function(v) getgenv().Settings.ESPTracer = v end,
})
ESPSub:AddDropdown({
	Name     = "Tracers From",
	Options  = { "Top", "Middle", "Bottom" },
	Default  = "Bottom",
	Flag     = "ESPTracerFrom",
	Callback = function(v) getgenv().Settings.ESPTracerFrom = v end,
})
ESPSub:AddColorPicker({
	Name     = "Tracers Color",
	Default  = Color3.fromRGB(255, 255, 255),
	Flag     = "ESPTracerColor",
	Callback = function(v) getgenv().Settings.ESPTracerColor = v end,
})
ESPSub:AddDivider()
ESPSub:AddSection("Skeleton ESP")
ESPSub:AddToggle({
	Name        = "Show Skeleton",
	Description = "Draws bone lines on enemies.",
	Default     = false,
	Flag        = "ESPSkeleton",
	Callback    = function(v) getgenv().Settings.ESPSkeleton = v end,
})
ESPSub:AddColorPicker({
	Name     = "Skeleton Color",
	Default  = Color3.fromRGB(200, 200, 200),
	Flag     = "ESPSkeletonColor",
	Callback = function(v) getgenv().Settings.ESPSkeletonColor = v end,
})
ESPSub:AddDivider()
ESPSub:AddSection("Render Settings")
ESPSub:AddSlider({
	Name     = "Max Distance",
	Min      = 50,
	Max      = 5000,
	Default  = 2000,
	Suffix   = " studs",
	Flag     = "ESPMaxDistance",
	Callback = function(v) getgenv().Settings.ESPMaxDistance = v end,
})
ESPSub:AddToggle({
	Name        = "Team Colors",
	Description = "Uses team-based colors for T/CT sides.",
	Default     = true,
	Flag        = "ESPTeamColors",
	Callback    = function(v) getgenv().Settings.ESPTeamColors = v end,
})
ESPSub:AddSlider({
	Name     = "Line Thickness",
	Min      = 1,
	Max      = 4,
	Default  = 1,
	Suffix   = " px",
	Flag     = "ESPLineThickness",
	Callback = function(v) getgenv().Settings.ESPLineThickness = v end,
})
ESPSub:AddSlider({
	Name     = "Text Size",
	Min      = 10,
	Max      = 20,
	Default  = 13,
	Suffix   = " pt",
	Flag     = "ESPTextSize",
	Callback = function(v) getgenv().Settings.ESPTextSize = v end,
})

ChamsSub:AddSection("Chams")
ChamsSub:AddToggle({
	Name        = "Enable Chams",
	Description = "Replaces enemy materials to see through walls.\nRisky!",
	Default     = false,
	Flag        = "ChamsToggle",
	Callback    = function(v)
		getgenv().Settings.ChamsEnabled = v
		if v then
			getgenv().Window:Notify({ Title = "Chams", Content = "Chams activated.", Type = "info", Duration = 2 })
		end
	end,
})
ChamsSub:AddColorPicker({
	Name     = "Chams Color",
	Default  = Color3.fromRGB(200, 200, 200),
	Flag     = "ChamsColor",
	Callback = function(v) getgenv().Settings.ChamsColor = v end,
})
ChamsSub:AddSlider({
	Name     = "Chams Transparency",
	Min      = 0,
	Max      = 10,
	Default  = 5,
	Suffix   = "",
	Flag     = "ChamsTransparency",
	Callback = function(v) getgenv().Settings.ChamsTransparency = v / 10 end,
})
ChamsSub:AddDropdown({
	Name     = "Chams Material",
	Options  = { "ForceField", "Neon", "Glass", "Plastic", "Metal" },
	Default  = "ForceField",
	Flag     = "ChamsMaterial",
	Callback = function(v) getgenv().Settings.ChamsMaterial = Enum.Material[v] end,
})
ChamsSub:AddToggle({
	Name        = "Rainbow Chams",
	Description = "Cycles chams through all colors.",
	Default     = false,
	Flag        = "RainbowChams",
	Callback    = function(v) getgenv().Settings.RainbowChams = v end,
})
ChamsSub:AddDivider()
ChamsSub:AddSection("Glow")
ChamsSub:AddToggle({
	Name        = "Enable Glow",
	Description = "Adds a highlight glow to enemies.",
	Default     = false,
	Flag        = "GlowToggle",
	Callback    = function(v)
		getgenv().Settings.GlowEnabled = v
		if v then
			getgenv().Window:Notify({ Title = "Glow", Content = "Glow activated.", Type = "info", Duration = 2 })
		end
	end,
})
ChamsSub:AddColorPicker({
	Name     = "Glow Color",
	Default  = Color3.fromRGB(255, 255, 255),
	Flag     = "GlowColor",
	Callback = function(v) getgenv().Settings.GlowColor = v end,
})
ChamsSub:AddSlider({
	Name     = "Glow Transparency",
	Min      = 0,
	Max      = 10,
	Default  = 3,
	Suffix   = "",
	Flag     = "GlowTransparency",
	Callback = function(v) getgenv().Settings.GlowTransparency = v / 10 end,
})

WorldSub:AddSection("World Effects")
WorldSub:AddToggle({
	Name        = "Fullbright",
	Description = "Maximizes lighting brightness.",
	Default     = false,
	Flag        = "FullbrightToggle",
	Callback    = function(v)
		getgenv().Settings.FullbrightEnabled = v
		if v then
			getgenv().Lighting.Brightness     = 2
			getgenv().Lighting.ClockTime      = 14
			getgenv().Lighting.FogEnd         = 100000
			getgenv().Lighting.GlobalShadows  = false
			getgenv().Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		else
			getgenv().Lighting.Brightness    = 1
			getgenv().Lighting.ClockTime     = 12
			getgenv().Lighting.FogEnd        = 1000
			getgenv().Lighting.GlobalShadows = true
		end
	end,
})
WorldSub:AddToggle({
	Name        = "No Fog",
	Description = "Removes all fog from the world.",
	Default     = false,
	Flag        = "NoFogToggle",
	Callback    = function(v)
		getgenv().Settings.NoFogEnabled = v
		getgenv().Lighting.FogEnd = v and 100000 or 1000
	end,
})
WorldSub:AddToggle({
	Name        = "Custom FOV",
	Description = "Overrides the camera field of view.",
	Default     = false,
	Flag        = "CustomFOVToggle",
	Callback    = function(v) getgenv().Settings.CustomFOV = v end,
})
WorldSub:AddSlider({
	Name     = "FOV Value",
	Min      = 60,
	Max      = 120,
	Default  = 70,
	Suffix   = "°",
	Flag     = "FOVValue",
	Callback = function(v) getgenv().Settings.FOVValue = v end,
})
WorldSub:AddToggle({
	Name        = "Custom Ambient",
	Description = "Overrides the world ambient light color.",
	Default     = false,
	Flag        = "CustomAmbientToggle",
	Callback    = function(v) getgenv().Settings.CustomAmbient = v end,
})
WorldSub:AddColorPicker({
	Name     = "Ambient Color",
	Default  = Color3.fromRGB(255, 255, 255),
	Flag     = "AmbientColor",
	Callback = function(v) getgenv().Settings.AmbientColor = v end,
})

local MovementSub = getgenv().MiscTab:AddSubTab("Movement")
local UtilitySub  = getgenv().MiscTab:AddSubTab("Utility")
local NativeSub   = getgenv().MiscTab:AddSubTab("Native")
local ServerSub   = getgenv().MiscTab:AddSubTab("Server")

MovementSub:AddSection("Movement")
MovementSub:AddToggle({
	Name        = "Bunny Hop",
	Description = "Hold Space to continuously jump.",
	Default     = false,
	Flag        = "BhopToggle",
	Callback    = function(v) getgenv().Settings.BhopEnabled = v end,
})
MovementSub:AddToggle({
	Name        = "Speed Boost",
	Description = "Increases walk speed by multiplier.",
	Default     = false,
	Flag        = "SpeedToggle",
	Callback    = function(v) getgenv().Settings.SpeedEnabled = v end,
})
MovementSub:AddSlider({
	Name     = "Speed Multiplier",
	Min      = 10,
	Max      = 50,
	Default  = 15,
	Suffix   = "x",
	Flag     = "SpeedMultiplier",
	Callback = function(v) getgenv().Settings.SpeedMultiplier = v / 10 end,
})
MovementSub:AddToggle({
	Name        = "Infinite Jump",
	Description = "Jump again while airborne.",
	Default     = false,
	Flag        = "InfiniteJumpToggle",
	Callback    = function(v) getgenv().Settings.InfiniteJumpEnabled = v end,
})
MovementSub:AddToggle({
	Name        = "No Clip",
	Description = "Walk through walls. Risky!",
	Default     = false,
	Flag        = "NoClipToggle",
	Callback    = function(v) getgenv().Settings.NoClipEnabled = v end,
})

UtilitySub:AddSection("Utility")
UtilitySub:AddButton({
	Name     = "Respawn Character",
	Primary  = false,
	Callback = function()
		local char = getgenv().LocalPlayer.Character
		if char then
			char:BreakJoints()
			getgenv().Window:Notify({ Title = "Respawn", Content = "Respawning character...", Type = "info", Duration = 2 })
		end
	end,
})
UtilitySub:AddButton({
	Name     = "Remove Ragdolls",
	Primary  = false,
	Callback = function()
		local count = 0
		for _, desc in pairs(getgenv().Workspace:GetDescendants()) do
			if desc.Name == "Ragdoll" then
				desc:Destroy()
				count = count + 1
			end
		end
		getgenv().Window:Notify({ Title = "Cleanup", Content = "Removed " .. count .. " ragdolls.", Type = "success", Duration = 2 })
	end,
})
UtilitySub:AddDivider()
UtilitySub:AddSection("Anti-AFK")
UtilitySub:AddToggle({
	Name        = "Enable Anti-AFK",
	Description = "Prevents automatic kick for inactivity.",
	Default     = false,
	Flag        = "AntiAFKToggle",
	Callback    = function(v)
		getgenv().Settings.AntiAFKEnabled = v
		if v then
			getgenv().Window:Notify({ Title = "Anti-AFK", Content = "Anti-AFK enabled.", Type = "success", Duration = 2 })
		end
	end,
})

NativeSub:AddSection("Native Controllers")
NativeSub:AddToggle({
	Name        = "Native Aim Assist",
	Description = "Enables game's built-in AimAssistController.",
	Default     = false,
	Flag        = "NativeAimAssist",
	Callback    = function(v) getgenv().Settings.NativeAimAssist = v end,
})
NativeSub:AddSlider({
	Name     = "Aim Strength",
	Min      = 0,
	Max      = 100,
	Default  = 100,
	Suffix   = "%",
	Flag     = "NativeAimStrength",
	Callback = function(v) getgenv().Settings.NativeAimStrength = v end,
})
NativeSub:AddDivider()
NativeSub:AddToggle({
	Name        = "No Flinch",
	Description = "Clears hit flinch animation immediately.",
	Default     = false,
	Flag        = "NoFlinch",
	Callback    = function(v) getgenv().Settings.NoFlinch = v end,
})
NativeSub:AddToggle({
	Name        = "Auto Spectate",
	Description = "Automatically spectates on death.",
	Default     = false,
	Flag        = "AutoSpectate",
	Callback    = function(v) getgenv().Settings.AutoSpectate = v end,
})
NativeSub:AddDivider()
NativeSub:AddSection("Input Fix")
NativeSub:AddToggle({
	Name        = "Fix Gamepad Click Focus",
	Description = "Prevents gamepad from stealing\nmouse click focus in UI.",
	Default     = false,
	Flag        = "FreeMouseFocus",
	Callback    = function(v) getgenv().Settings.FreeMouseFocus = v end,
})

ServerSub:AddSection("Server Info")
ServerSub:AddLabel({ Text = "Server: " .. game.JobId })
ServerSub:AddLabel({ Text = "Players: " .. #getgenv().Players:GetPlayers() .. " / " .. getgenv().Players.MaxPlayers })
ServerSub:AddLabel({ Text = "Ping: " .. math.floor(getgenv().LocalPlayer:GetNetworkPing() * 1000) .. " ms" })
ServerSub:AddDivider()
ServerSub:AddSection("About PerplexWare")
ServerSub:AddParagraph({
	Title = "PerplexWare",
	Text  = "Blox Strike utility hub.\nJoin our Discord: discord.gg/Perplexhub",
})
ServerSub:AddLabel({ Text = "Toggle UI: RightControl" })

local SaveSub = getgenv().ConfigTab:AddSubTab("Config")

SaveSub:AddSection("Configuration")
SaveSub:AddButton({
	Name     = "Save Config",
	Primary  = true,
	Callback = function()
		if getgenv().Library:SaveConfig("Perplex") then
			getgenv().Window:Notify({ Title = "Config", Content = "Saved as Perplex.json", Type = "success", Duration = 3 })
		else
			getgenv().Window:Notify({ Title = "Config", Content = "Save failed.", Type = "error", Duration = 3 })
		end
	end,
})
SaveSub:AddButton({
	Name     = "Load Config",
	Primary  = false,
	Callback = function()
		if getgenv().Library:LoadConfig("Perplex") then
			getgenv().Window:Notify({ Title = "Config", Content = "Loaded Perplex.json", Type = "info", Duration = 3 })
		else
			getgenv().Window:Notify({ Title = "Config", Content = "No config found.", Type = "warning", Duration = 3 })
		end
	end,
})
SaveSub:AddButton({
	Name     = "Reset Config",
	Primary  = false,
	Callback = function()
		getgenv().Library:ResetConfig()
		getgenv().Window:Notify({ Title = "Config", Content = "Reset to defaults.", Type = "info", Duration = 3 })
	end,
})
SaveSub:AddDivider()
SaveSub:AddSection("Keybind")
SaveSub:AddKeybind({
	Name    = "Toggle UI",
	Default = Enum.KeyCode.RightControl,
	Flag    = "UIToggle",
	OnPress = function()
		getgenv().Window:ToggleUI()
	end,
})
SaveSub:AddDivider()
SaveSub:AddSection("Links")
SaveSub:AddParagraph({
	Title = "Discord",
	Text  = "Join our community:\ndiscord.gg/Perplexhub",
})

pcall(function()
	getgenv().Library:LoadConfig("Perplex")
end)

getgenv().Window:Notify({
	Title    = "PerplexWare",
	Content  = "Loaded successfully.\nPress RightControl to toggle UI.",
	Type     = "success",
	Duration = 5,
})
