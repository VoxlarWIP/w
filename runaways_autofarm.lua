--[[
    AutoEscape - Upgraded Script
    Configs:
        getgenv().config = "AutoEscape"           -> Runs pure AutoEscape (place 117311404196294)
        getgenv().config = "MoneyFarmAutoEscape"  -> AutoEscape + loot/sell loop (place 117311404196294)
    
    On place 118418618261207 -> Lobby auto-click logic runs instead.
    Any other place           -> Nothing runs.
--]]

-- ─────────────────────────────────────────────────
-- CONFIG RESOLUTION
-- ─────────────────────────────────────────────────
local ACTIVE_CONFIG       = tostring(getgenv().config or "AutoEscape")
local AUTOESCAPE_PLACE    = "117311404196294"
local LOBBY_PLACE         = "118418618261207"
local CURRENT_PLACE       = tostring(game.PlaceId)

-- ─────────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────────
getgenv().Services = {
    Players             = game:GetService("Players"),
    Workspace           = game:GetService("Workspace"),
    RunService          = game:GetService("RunService"),
    TweenService        = game:GetService("TweenService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService          = game:GetService("GuiService"),
    ReplicatedStorage   = game:GetService("ReplicatedStorage"),
    TeleportService     = game:GetService("TeleportService"),
}

game:GetService("ContentProvider"):PreloadAsync({})
if not game:IsLoaded() then game.Loaded:Wait() end

getgenv().LocalPlayer = getgenv().Services.Players.LocalPlayer
if not getgenv().LocalPlayer.Character then
    getgenv().LocalPlayer.CharacterAdded:Wait()
end

-- ─────────────────────────────────────────────────
-- PAUSE DETECTION (shared)
-- ─────────────────────────────────────────────────
getgenv().GamePaused = false
local pauseLastStep = tick()
getgenv().Services.RunService.Heartbeat:Connect(function()
    local now = tick()
    getgenv().GamePaused = (now - pauseLastStep) > 0.5
    pauseLastStep = now
end)

local function waitForUnpause()
    while getgenv().GamePaused do task.wait(0.05) end
end

-- ─────────────────────────────────────────────────
-- SHARED HELPERS
-- ─────────────────────────────────────────────────
local function patchPrompt(prompt)
    if not prompt then return end
    pcall(function()
        prompt.MaxActivationDistance = 1000
        prompt.RequiresLineOfSight   = false
    end)
end

local function firePrompt(prompt)
    if not prompt then return end
    patchPrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
        return
    end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration)
        prompt:InputHoldEnd()
    end)
end

local function fastTweenCFrame(part, targetCFrame)
    waitForUnpause()
    local tween = getgenv().Services.TweenService:Create(
        part,
        TweenInfo.new(0.001, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { CFrame = targetCFrame }
    )
    tween:Play()
    tween.Completed:Wait()
end

local function pressKey(keyCode)
    getgenv().Services.VirtualInputManager:SendKeyEvent(true,  keyCode, false, game)
    task.wait(0.01)
    getgenv().Services.VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- ─────────────────────────────────────────────────
-- COUNTDOWN UI  (lite purple stroke / very dark purple bg-stroke)
-- Shown at top-center of screen
-- Idle: "Escape Process." / ".." / "..."
-- Active: MM:SS countdown
-- ─────────────────────────────────────────────────
local CountdownUI = {}
do
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name              = "AutoEscapeCountdownUI"
    screenGui.ResetOnSpawn      = false
    screenGui.IgnoreGuiInset    = true
    screenGui.DisplayOrder      = 999
    screenGui.Parent            = getgenv().LocalPlayer:WaitForChild("PlayerGui")

    -- Outer stroke frame (very dark purple)
    local outerFrame = Instance.new("Frame")
    outerFrame.Name                  = "OuterFrame"
    outerFrame.Size                  = UDim2.new(0, 220, 0, 48)
    outerFrame.AnchorPoint           = Vector2.new(0.5, 0)
    outerFrame.Position              = UDim2.new(0.5, 0, 0, 12)
    outerFrame.BackgroundColor3      = Color3.fromRGB(18, 5, 30)   -- very dark purple bg
    outerFrame.BackgroundTransparency = 0.15
    outerFrame.BorderSizePixel       = 0
    outerFrame.Parent                = screenGui

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0, 8)
    outerCorner.Parent       = outerFrame

    local outerStroke = Instance.new("UIStroke")
    outerStroke.Color     = Color3.fromRGB(30, 8, 52)   -- very dark purple stroke
    outerStroke.Thickness = 3
    outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerStroke.Parent    = outerFrame

    -- Inner frame (lite purple stroke)
    local innerFrame = Instance.new("Frame")
    innerFrame.Name                   = "InnerFrame"
    innerFrame.Size                   = UDim2.new(1, -6, 1, -6)
    innerFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    innerFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    innerFrame.BackgroundTransparency = 1
    innerFrame.BorderSizePixel        = 0
    innerFrame.Parent                 = outerFrame

    local innerStroke = Instance.new("UIStroke")
    innerStroke.Color     = Color3.fromRGB(180, 130, 255)   -- lite purple stroke
    innerStroke.Thickness = 1.5
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerStroke.Parent    = innerFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 6)
    innerCorner.Parent       = innerFrame

    -- Label
    local label = Instance.new("TextLabel")
    label.Name                  = "CountdownLabel"
    label.Size                  = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text                  = "Escape Process."
    label.TextColor3            = Color3.fromRGB(210, 180, 255)
    label.TextSize              = 18
    label.Font                  = Enum.Font.GothamBold
    label.TextXAlignment        = Enum.TextXAlignment.Center
    label.TextYAlignment        = Enum.TextYAlignment.Center
    label.Parent                = outerFrame

    local labelStroke = Instance.new("UIStroke")
    labelStroke.Color     = Color3.fromRGB(30, 8, 52)
    labelStroke.Thickness = 1.5
    labelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    labelStroke.Parent    = label

    CountdownUI.Label        = label
    CountdownUI.Frame        = outerFrame
    CountdownUI.Active       = false
    CountdownUI.EndTime      = 0
    CountdownUI._idleDots    = 1
    CountdownUI._idleTick    = tick()

    -- Idle animation loop
    task.spawn(function()
        while true do
            task.wait(0.6)
            if not CountdownUI.Active then
                CountdownUI._idleDots = (CountdownUI._idleDots % 3) + 1
                CountdownUI.Label.Text = "Escape Process" .. string.rep(".", CountdownUI._idleDots)
            end
        end
    end)

    function CountdownUI:StartCountdown(seconds)
        self.Active  = true
        self.EndTime = tick() + seconds
        task.spawn(function()
            while self.Active do
                local remaining = math.max(0, math.floor(self.EndTime - tick()))
                local mins = math.floor(remaining / 60)
                local secs = remaining % 60
                self.Label.Text       = string.format("%d:%02d", mins, secs)
                self.Label.TextColor3 = Color3.fromRGB(255, 100, 100)
                task.wait(0.25)
                if remaining <= 0 then
                    self:StopCountdown()
                    break
                end
            end
        end)
    end

    function CountdownUI:StopCountdown()
        self.Active               = false
        self.Label.TextColor3     = Color3.fromRGB(210, 180, 255)
        self.Label.Text           = "Escape Process."
        self._idleDots            = 1
    end

    function CountdownUI:TimeUp()
        return self.Active and tick() >= self.EndTime
    end
end

-- ─────────────────────────────────────────────────
-- TELEPORT TO NEW EXPERIENCE  (called when countdown hits 0)
-- ─────────────────────────────────────────────────
local function teleportToLobby()
    pcall(function()
        getgenv().Services.TeleportService:Teleport(tonumber(LOBBY_PLACE), getgenv().LocalPlayer)
    end)
end

-- ─────────────────────────────────────────────────
-- LOOT / SELL HELPERS  (from PerplexWare.lua)
-- ─────────────────────────────────────────────────
getgenv().ExcludedLootNames = {
    Gramophone=true, ElectricGuitar=true, Radio=true, Computer=true,
    Console=true, Floodlight=true, TV=true, Turret=true, PropaneTank=true,
    MetalSheet=true, Plank=true, JerryCan=true, TrashBag=true,
    LifeBuoy=true, Tire=true,
}

local function isExcludedLoot(name)
    if not name then return false end
    local q = string.lower(name:gsub("%s+",""):gsub("_+",""))
    for k in pairs(getgenv().ExcludedLootNames) do
        local t = string.lower(k:gsub("%s+",""):gsub("_+",""))
        if q == t or string.find(q,t) or string.find(t,q) then return true end
    end
    return false
end

local function getInventoryCount()
    local current, max = 0, 0
    pcall(function()
        local backpackLabel = getgenv().LocalPlayer.PlayerGui.HudGui.BottomPanel.CashAmount.Backpack
        if backpackLabel and backpackLabel.Text then
            local a, b = backpackLabel.Text:match("(%d+)/(%d+)")
            if a and b then current = tonumber(a) or 0; max = tonumber(b) or 0 end
        end
    end)
    return current, max
end

local function isInventoryFull()
    local current, max = getInventoryCount()
    return max > 0 and max <= current
end

local function getFlowEvent()
    local FlowClient = getgenv().Services.ReplicatedStorage:FindFirstChild("FlowClient")
    if FlowClient then
        FlowClient = FlowClient:FindFirstChild("ClientRunner")
        if FlowClient then
            FlowClient = FlowClient:FindFirstChild("Function")
        end
    end
    return FlowClient
end

local function stopPart(part)
    pcall(function()
        if setnetworkowner then setnetworkowner(part); return end
        part.AssemblyLinearVelocity  = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function lootNearby(range)
    if isInventoryFull() then return end
    local Character = getgenv().LocalPlayer.Character
    if Character then Character = Character:FindFirstChild("HumanoidRootPart") end
    local Loot = getgenv().Services.Workspace:FindFirstChild("Loot")
    if not Character or not Loot or not getFlowEvent() then return end
    for _, item in pairs(Loot:GetChildren()) do
        if isInventoryFull() then return end
        if not isExcludedLoot(item.Name) then
            local part = item.PrimaryPart
                or item:FindFirstChild("Handle")
                or item:FindFirstChildWhichIsA("BasePart")
            if part and (Character.Position - part.Position).Magnitude <= (range or 15) then
                pcall(function()
                    getFlowEvent():InvokeServer("Loot","LootEquip",part)
                end)
            end
        end
    end
end

local function getPawnShopBalance(model)
    local t = model:FindFirstChild("Templates")
    if t then t = t:FindFirstChild("Template1") end
    if t then t = t:FindFirstChild("PawnCounter") end
    if t then return t:FindFirstChild("Balance") end
    return nil
end

local function getCallBellPrompt(instance)
    if not instance then return nil end
    local parent = instance.Parent
    if parent then
        local cb = parent:FindFirstChild("CallBell")
        if cb then
            local pp = cb:FindFirstChildOfClass("ProximityPrompt")
                or cb:FindFirstChildWhichIsA("ProximityPrompt",true)
            return pp
        end
    end
    return nil
end

local function getNearestPawnShop()
    local Character = getgenv().LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character = Character.HumanoidRootPart
    else return nil end
    local Map = getgenv().Services.Workspace:FindFirstChild("Map")
    if Map then Map = Map:FindFirstChild("Buildings") end
    local nearest, nearestDist = nil, math.huge
    if Map then
        for _, child in pairs(Map:GetChildren()) do
            if child:IsA("Model") and string.find(string.lower(child.Name),"pawnshop") then
                local bal = getPawnShopBalance(child)
                if bal and bal:IsA("BasePart") then
                    local dist = (Character.Position - bal.Position).Magnitude
                    if dist < nearestDist then nearest = bal; nearestDist = dist end
                end
            end
        end
    end
    return nearest
end

-- ─────────────────────────────────────────────────
-- MONEY FARM LOOP
-- Collects nearby loot, sells when full, resumes when empty.
-- Runs as a co-routine alongside AutoEscape.
-- ─────────────────────────────────────────────────
local MoneyFarmRunning = false

local function startMoneyFarm(hrpRef)
    if MoneyFarmRunning then return end
    MoneyFarmRunning = true
    task.spawn(function()
        while MoneyFarmRunning do
            task.wait(0.5)
            local Character = getgenv().LocalPlayer.Character
            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(1); continue end

            local Loot = getgenv().Services.Workspace:FindFirstChild("Loot")
            if not Loot or not getFlowEvent() then task.wait(1); continue end

            -- Collect phase
            local collected = false
            for _, item in pairs(Loot:GetChildren()) do
                if isInventoryFull() then break end
                if not isExcludedLoot(item.Name) then
                    local part = item.PrimaryPart
                        or item:FindFirstChild("Handle")
                        or item:FindFirstChildWhichIsA("BasePart")
                    if part and (hrp.Position - part.Position).Magnitude <= 750 then
                        stopPart(part)
                        hrp.CFrame = part.CFrame
                        lootNearby(15)
                        local done = false
                        for _ = 1, 20 do
                            if not item.Parent then done = true; break end
                            if (hrp.Position - part.Position).Magnitude <= 5 then done = true; break end
                            task.wait(0.1)
                        end
                        if done then
                            task.wait(0.3); lootNearby(15); task.wait(0.1)
                        end
                        collected = true
                    end
                end
            end

            -- Sell phase (only if we have something)
            local invCount, _ = getInventoryCount()
            if invCount > 0 then
                local pawn = getNearestPawnShop()
                if pawn then
                    local target = pawn.Position + pawn.CFrame.LookVector * 5
                    hrp.CFrame = CFrame.lookAt(target, pawn.Position)
                    task.wait(0.2)
                    local inv = invCount
                    local stuck = 0
                    while inv > 0 do
                        pressKey(Enum.KeyCode.One)
                        pressKey(Enum.KeyCode.X)
                        task.wait(0.02)
                        local newInv, _ = getInventoryCount()
                        if newInv == inv then
                            stuck += 1
                            if stuck >= 5 then break end
                        else
                            inv = newInv; stuck = 0
                        end
                    end
                    task.wait(0.2)
                    local prompt = getCallBellPrompt(pawn)
                    if prompt then
                        firePrompt(prompt)
                    else
                        local parent = pawn.Parent
                        if parent then
                            local pp = parent:FindFirstChildWhichIsA("ProximityPrompt",true)
                            if pp then firePrompt(pp) end
                        end
                    end
                    task.wait(0.2)
                end
            end

            if not collected then task.wait(2) end
        end
    end)
end

local function stopMoneyFarm()
    MoneyFarmRunning = false
end

-- ─────────────────────────────────────────────────
-- AUTO ESCAPE  (with countdown UI)
-- ─────────────────────────────────────────────────
getgenv().AutoEscapeRunning = false

local COUNTDOWN_SECONDS = 2 * 60 + 15   -- 2:15

local function runAutoEscape()
    if getgenv().AutoEscapeRunning then return end

    task.spawn(function()
        local Character = getgenv().LocalPlayer.Character
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        local hum = Character and Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        getgenv().AutoEscapeRunning = true

        -- Start MoneyFarm alongside if config requires it
        if ACTIVE_CONFIG == "MoneyFarmAutoEscape" then
            startMoneyFarm(hrp)
        end

        fastTweenCFrame(hrp, hrp.CFrame + Vector3.new(0, 500, 0))
        task.wait(0.05)

        local lastCheck       = 0
        local lastPos         = hrp.Position
        local antiBackwardConn = getgenv().Services.RunService.Heartbeat:Connect(function()
            local chr  = getgenv().LocalPlayer.Character
            local root = chr and chr:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local delta = (root.Position - lastPos)
            if delta.Z < -1 then
                root.CFrame = CFrame.new(lastPos) * (root.CFrame - root.CFrame.Position)
                root.AssemblyLinearVelocity = Vector3.zero
            else
                lastPos = root.Position
            end
        end)

        while true do
            local chr  = getgenv().LocalPlayer.Character
            local root = chr and chr:FindFirstChild("HumanoidRootPart")
            if root then
                local moved = root.Position + Vector3.new(0, 0, 100)
                fastTweenCFrame(root, CFrame.new(moved) * (root.CFrame - root.CFrame.Position))
                root.AssemblyLinearVelocity = Vector3.zero
            end

            if tick() - lastCheck >= 0.25 then
                lastCheck = tick()
                local Map       = getgenv().Services.Workspace:FindFirstChild("Map")
                local Buildings = Map and Map:FindFirstChild("Buildings")
                local customs   = Buildings and Buildings:FindFirstChild("CustomsFinal")
                local building  = customs and customs:FindFirstChild("CustomsBuilding")
                local door      = building and building:FindFirstChild("FinalDoor")
                local cmd       = door and door:FindFirstChild("Command")
                local screen    = cmd and cmd:FindFirstChild("Screen")

                if screen and root then
                    antiBackwardConn:Disconnect()

                    local screenCFrame = screen:IsA("BasePart") and screen.CFrame or screen:GetPivot()
                    fastTweenCFrame(root, screenCFrame + Vector3.new(0, 1, 0))
                    root.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.1)

                    -- Fire command button prompt
                    local cmdBtn = screen.Parent and screen.Parent:FindFirstChild("CommandButton")
                    local prompt = cmdBtn and cmdBtn:FindFirstChild("Prompt")
                    if prompt then
                        prompt = prompt:FindFirstChildOfClass("ProximityPrompt")
                    end

                    if prompt then
                        patchPrompt(prompt)
                        local promptPart = prompt.Parent
                        local promptPos  = (promptPart and promptPart:IsA("BasePart"))
                            and promptPart.Position or screenCFrame.Position
                        local cam = getgenv().Services.Workspace.CurrentCamera

                        local spamConn = getgenv().Services.RunService.RenderStepped:Connect(function()
                            local currentRoot = getgenv().LocalPlayer.Character
                                and getgenv().LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if not currentRoot then return end
                            cam.CFrame = CFrame.lookAt(currentRoot.Position + Vector3.new(0,1.5,0), promptPos)
                            if fireproximityprompt then
                                pcall(fireproximityprompt, prompt)
                            else
                                pcall(function() prompt:InputHoldBegin() end)
                            end
                        end)
                        task.wait(1)
                        spamConn:Disconnect()
                    end

                    -- Go underground & wait on platform
                    local underground = root.Position - Vector3.new(0, 120, 0)
                    local Platform = Instance.new("Part")
                    Platform.Name         = "EscapePlatform"
                    Platform.Size         = Vector3.new(10, 1, 10)
                    Platform.CFrame       = CFrame.new(underground - Vector3.new(0, 3, 0))
                    Platform.Anchored     = true
                    Platform.CanCollide   = true
                    Platform.Transparency = 1
                    Platform.Parent       = getgenv().Services.Workspace

                    local savedWalk = hum.WalkSpeed
                    hum.WalkSpeed = 0
                    fastTweenCFrame(root, CFrame.new(underground))

                    -- Lock position underground
                    local lockConn = getgenv().Services.RunService.Heartbeat:Connect(function()
                        local currentRoot = getgenv().LocalPlayer.Character
                            and getgenv().LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not currentRoot then return end
                        currentRoot.CFrame = CFrame.new(underground)
                        currentRoot.AssemblyLinearVelocity  = Vector3.zero
                        currentRoot.AssemblyAngularVelocity = Vector3.zero
                    end)

                    -- ── START COUNTDOWN (2:15) ────────────────────────
                    CountdownUI:StartCountdown(COUNTDOWN_SECONDS)

                    local Timer
                    pcall(function()
                        Timer = screen.SurfaceGui.Frame.Timer.Time
                    end)

                    -- Wait loop: game timer OR our own countdown
                    while task.wait(0.1) do
                        local Heli = getgenv().Services.Workspace:FindFirstChild("Helicopter", true)
                        if Heli then Heli:Destroy() end

                        -- Check if countdown hit 0 -> teleport
                        if CountdownUI:TimeUp() then
                            CountdownUI:StopCountdown()
                            lockConn:Disconnect()
                            hum.WalkSpeed = savedWalk
                            if Platform then Platform:Destroy() end
                            stopMoneyFarm()
                            getgenv().AutoEscapeRunning = false
                            teleportToLobby()
                            return
                        end

                        -- Also respect the in-game timer
                        if Timer then
                            local t = Timer.Text
                            if t == "" or t == "0m 0s" then break end
                        end
                    end

                    CountdownUI:StopCountdown()
                    lockConn:Disconnect()
                    hum.WalkSpeed = savedWalk
                    if Platform then Platform:Destroy() end

                    local endCFrame = screen:IsA("BasePart") and screen.CFrame or screen:GetPivot()
                    fastTweenCFrame(root, endCFrame - endCFrame.LookVector * 50)
                    root.AssemblyLinearVelocity = Vector3.zero

                    stopMoneyFarm()
                    getgenv().AutoEscapeRunning = false
                    return
                end
            end

            task.wait(0.02)
        end
    end)
end

-- ─────────────────────────────────────────────────
-- LOBBY CLICK LOGIC  (place 118418618261207)
-- Waits for images/children to be loaded before VIM clicks
-- ─────────────────────────────────────────────────
local function runLobbyLogic()
    local Players             = getgenv().Services.Players
    local VIM                 = getgenv().Services.VirtualInputManager
    local GuiService          = getgenv().Services.GuiService
    local PlayerGui           = Players.LocalPlayer.PlayerGui

    local function waitForImageLoaded(gui)
        -- If it's an ImageLabel or ImageButton, wait until image is loaded
        if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
            local maxWait = 10
            local elapsed = 0
            while not gui.IsLoaded and elapsed < maxWait do
                task.wait(0.1)
                elapsed += 0.1
            end
        end
    end

    local function clickGui(gui, xOffset)
        -- Wait for image to be loaded if applicable
        waitForImageLoaded(gui)

        local pos   = gui.AbsolutePosition
        local size  = gui.AbsoluteSize
        local inset = GuiService:GetGuiInset()

        local x = pos.X + size.X / 2 + (xOffset or 0)
        local y = pos.Y + size.Y / 2 + inset.Y

        VIM:SendMouseButtonEvent(x, y, 0, true,  game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end

    task.wait(2)

    -- Click PlayNow — wait until it exists
    local Hud = PlayerGui:WaitForChild("Hud", 15)
    if not Hud then return end
    local PlayNow = Hud:WaitForChild("PlayNow", 15)
    if not PlayNow then return end
    clickGui(PlayNow)

    task.wait(2)

    -- Navigate lobby create GUI
    local CreateLobbyGui = PlayerGui:WaitForChild("CreateLobbyGui", 15)
    if not CreateLobbyGui then return end
    local Frame = CreateLobbyGui:WaitForChild("Frame", 10)
    if not Frame then return end
    local Container = Frame:WaitForChild("Container", 10)
    if not Container then return end

    local MaxPlayersFrame = Container:WaitForChild("MaxPlayers", 10)
    if not MaxPlayersFrame then return end
    local FrameInner = MaxPlayersFrame:WaitForChild("Frame", 10)
    if not FrameInner then return end
    local Minus = FrameInner:WaitForChild("Minus", 10)
    if not Minus then return end

    task.wait(0.5)
    for i = 1, 7 do
        clickGui(Minus, 40)
        task.wait(0.2 / 7)
    end

    task.wait(1)

    local Create = Container:WaitForChild("Create", 10)
    if not Create then return end

    while true do
        clickGui(Create)
        task.wait()
    end
end

-- ─────────────────────────────────────────────────
-- ENTRY POINT — dispatch by PlaceId and config
-- ─────────────────────────────────────────────────
if CURRENT_PLACE == LOBBY_PLACE then
    -- We're in the lobby experience -> run lobby auto-click
    task.spawn(runLobbyLogic)

elseif CURRENT_PLACE == AUTOESCAPE_PLACE then
    -- We're in the escape game -> run AutoEscape (with optional MoneyFarm)
    if ACTIVE_CONFIG == "AutoEscape" or ACTIVE_CONFIG == "MoneyFarmAutoEscape" then
        runAutoEscape()
    end

else
    -- Unknown place -> do nothing silently
end

--[[
    ─────────────────────────────────────────────────
    USAGE EXAMPLES (put these before your loadstring):

    -- Pure AutoEscape only:
    getgenv().config = "AutoEscape"
    loadstring(game:HttpGet("loaderherelol"))()

    -- AutoEscape + auto loot/sell MoneyFarm loop:
    getgenv().config = "MoneyFarmAutoEscape"
    loadstring(game:HttpGet("loaderherelol"))()
    ─────────────────────────────────────────────────
]]
getgenv().config = "AutoEscape"
loadstring(game:HttpGet("https://perplexware.vercel.app/runaways_autofarm.lua"))()
