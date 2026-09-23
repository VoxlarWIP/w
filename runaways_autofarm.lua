local ok, cfg = pcall(function() return getgenv().config end)
local ACTIVE_CONFIG = (ok and cfg) or "AutoEscape"

local EXPERIENCE_RUNAWAYS    = "117311404196294"
local EXPERIENCE_LOBBY       = "118418618261207"

local COUNTDOWN_DURATION        = 125
local SILENT_COUNTDOWN_DURATION = 200
local LOOT_COLLECT_RANGE        = 15
local LOOT_SEARCH_RANGE         = 750
local ANTI_BACKWARD_THRESHOLD   = -1
local FORWARD_STEP              = Vector3.new(0, 0, 100)
local UNDERGROUND_OFFSET        = Vector3.new(0, 120, 0)
local PLATFORM_FLOOR_OFFSET     = Vector3.new(0, 3, 0)
local LAUNCH_HEIGHT             = Vector3.new(0, 500, 0)

local LOBBY_CLICK_DELAY      = 2
local MINUS_CLICKS           = 7
local MINUS_CLICK_INTERVAL   = 0.2 / 7
local MINUS_X_OFFSET         = 40
local GUI_CLICK_RELEASE_WAIT = 0.03
local REPLAY_CLICK_DELAY     = 2

local IDLE_TEXTS    = { "Escape Process.", "Escape Process..", "Escape Process..." }
local IDLE_INTERVAL = 0.75

local COLOR_STROKE_LIGHT = Color3.fromRGB(180, 120, 255)
local COLOR_STROKE_DARK  = Color3.fromRGB(30, 0, 60)
local COLOR_TEXT         = Color3.fromRGB(240, 220, 255)

local currentPlaceId = tostring(game.PlaceId)

local Services = {
    Players             = game:GetService("Players"),
    Workspace           = game:GetService("Workspace"),
    RunService          = game:GetService("RunService"),
    TweenService        = game:GetService("TweenService"),
    TeleportService     = game:GetService("TeleportService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService          = game:GetService("GuiService"),
    ReplicatedStorage   = game:GetService("ReplicatedStorage"),
}

local LocalPlayer = Services.Players.LocalPlayer

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

local autoEscapeRunning = false
local gamePaused        = false
local countdownActive   = false
local countdownEndTime  = 0
local screenFound       = false

local pauseLastStep = tick()
Services.RunService.Heartbeat:Connect(function()
    local now   = tick()
    local delta = now - pauseLastStep
    pauseLastStep = now
    gamePaused = delta > 0.5
end)

local function waitForUnpause()
    while gamePaused do
        task.wait(0.05)
    end
end

local function fastTweenCFrame(part, targetCFrame)
    waitForUnpause()
    local tween = Services.TweenService:Create(
        part,
        TweenInfo.new(0.001, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { CFrame = targetCFrame }
    )
    tween:Play()
    tween.Completed:Wait()
end

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

local function clickGui(gui, xOffset)
    local pos   = gui.AbsolutePosition
    local size  = gui.AbsoluteSize
    local inset = Services.GuiService:GetGuiInset()

    local x = pos.X + size.X / 2 + (xOffset or 0)
    local y = pos.Y + size.Y / 2 + inset.Y

    Services.VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(GUI_CLICK_RELEASE_WAIT)
    Services.VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function waitForGuiLoaded(guiObject, timeout)
    local elapsed  = 0
    local interval = 0.05
    while elapsed < (timeout or 10) do
        if guiObject and guiObject.AbsoluteSize.X > 0 and guiObject.AbsoluteSize.Y > 0 then
            return true
        end
        task.wait(interval)
        elapsed += interval
    end
    return false
end

local function runReplaySequence()
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        task.wait(REPLAY_CLICK_DELAY)
        local endFrame = playerGui:WaitForChild("EndFrame")
        local frame    = endFrame:WaitForChild("Frame")
        local replay   = frame:WaitForChild("Replay")
        if waitForGuiLoaded(replay) then
            while true do
                clickGui(replay)
                task.wait()
            end
        end
    end)
end

local screenGui, countdownFrame, countdownLabel

local function buildCountdownUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "EscapeCountdownGui"
    screenGui.ResetOnSpawn   = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder   = 9999
    screenGui.IgnoreGuiInset = true
    screenGui.Parent         = playerGui

    countdownFrame = Instance.new("Frame")
    countdownFrame.Name                   = "CountdownFrame"
    countdownFrame.Size                   = UDim2.fromOffset(260, 52)
    countdownFrame.Position               = UDim2.new(0.5, -130, 0, 18)
    countdownFrame.BackgroundColor3       = Color3.fromRGB(12, 0, 28)
    countdownFrame.BackgroundTransparency = 0.18
    countdownFrame.BorderSizePixel        = 0
    countdownFrame.ZIndex                 = 9999
    countdownFrame.Parent                 = screenGui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent       = countdownFrame

    local outerStroke = Instance.new("UIStroke")
    outerStroke.Color     = COLOR_STROKE_DARK
    outerStroke.Thickness = 4
    outerStroke.Parent    = countdownFrame

    local innerFrame = Instance.new("Frame")
    innerFrame.Name                   = "InnerBorder"
    innerFrame.Size                   = UDim2.new(1, -6, 1, -6)
    innerFrame.Position               = UDim2.fromOffset(3, 3)
    innerFrame.BackgroundTransparency = 1
    innerFrame.BorderSizePixel        = 0
    innerFrame.ZIndex                 = 9999
    innerFrame.Parent                 = countdownFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 8)
    innerCorner.Parent       = innerFrame

    local innerStroke = Instance.new("UIStroke")
    innerStroke.Color     = COLOR_STROKE_LIGHT
    innerStroke.Thickness = 2
    innerStroke.Parent    = innerFrame

    countdownLabel = Instance.new("TextLabel")
    countdownLabel.Name                   = "CountdownLabel"
    countdownLabel.Size                   = UDim2.new(1, 0, 1, 0)
    countdownLabel.BackgroundTransparency = 1
    countdownLabel.TextColor3             = COLOR_TEXT
    countdownLabel.TextSize               = 20
    countdownLabel.Font                   = Enum.Font.GothamBold
    countdownLabel.Text                   = IDLE_TEXTS[1]
    countdownLabel.TextXAlignment         = Enum.TextXAlignment.Center
    countdownLabel.TextYAlignment         = Enum.TextYAlignment.Center
    countdownLabel.ZIndex                 = 9999
    countdownLabel.Parent                 = countdownFrame

    local labelStroke = Instance.new("UIStroke")
    labelStroke.Color     = COLOR_STROKE_DARK
    labelStroke.Thickness = 2
    labelStroke.Parent    = countdownLabel
end

local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%d:%02d", mins, secs)
end

local function startCountdown()
    if countdownActive then return end
    countdownActive = true
    countdownEndTime = tick() + COUNTDOWN_DURATION

    task.spawn(function()
        while countdownActive do
            local remaining = math.max(0, math.floor(countdownEndTime - tick()))
            if countdownLabel then
                countdownLabel.Text = "Escaping: " .. formatTime(remaining)
            end
            if remaining <= 0 then
                countdownActive = false
                if countdownLabel then
                    countdownLabel.Text = "Replaying..."
                end
                task.wait(0.5)
                runReplaySequence()
                break
            end
            task.wait(1)
        end
    end)
end

local function startSilentCountdown()
    task.spawn(function()
        task.wait(SILENT_COUNTDOWN_DURATION)

        local character = LocalPlayer.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end

        task.wait(REPLAY_CLICK_DELAY)
        runReplaySequence()
    end)
end

local idleTextIndex = 1
task.spawn(function()
    while true do
        task.wait(IDLE_INTERVAL)
        if not countdownActive and countdownLabel then
            idleTextIndex = (idleTextIndex % #IDLE_TEXTS) + 1
            countdownLabel.Text = IDLE_TEXTS[idleTextIndex]
        end
    end
end)

local function getScreen()
    local map       = Services.Workspace:FindFirstChild("Map")
    local buildings = map and map:FindFirstChild("Buildings")
    local customs   = buildings and buildings:FindFirstChild("CustomsFinal")
    local building  = customs and customs:FindFirstChild("CustomsBuilding")
    local door      = building and building:FindFirstChild("FinalDoor")
    local cmd       = door and door:FindFirstChild("Command")
    return cmd and cmd:FindFirstChild("Screen")
end

local ExcludedLootNames = {
    Gramophone     = true,
    ElectricGuitar = true,
    Radio          = true,
    Computer       = true,
    Console        = true,
    Floodlight     = true,
    TV             = true,
    Turret         = true,
    PropaneTank    = true,
    MetalSheet     = true,
    Plank          = true,
    JerryCan       = true,
    TrashBag       = true,
    LifeBuoy       = true,
    Tire           = true,
}

local function isExcludedLoot(name)
    if not name then return false end
    local query = string.lower(name:gsub("%s+", ""):gsub("_+", ""))
    for key in pairs(ExcludedLootNames) do
        local test = string.lower(key:gsub("%s+", ""):gsub("_+", ""))
        if query == test or string.find(query, test) or string.find(test, query) then
            return true
        end
    end
    return false
end

local function getFlowEvent()
    local flowClient = Services.ReplicatedStorage:FindFirstChild("FlowClient")
    if flowClient then
        local runner = flowClient:FindFirstChild("ClientRunner")
        if runner then
            return runner:FindFirstChild("Function")
        end
    end
    return nil
end

local function getInventoryCount()
    local current, max = 0, 0
    pcall(function()
        local backpackLabel = LocalPlayer.PlayerGui.HudGui.BottomPanel.CashAmount.Backpack
        if backpackLabel and backpackLabel.Text then
            local a, b = backpackLabel.Text:match("(%d+)/(%d+)")
            if a and b then
                current = tonumber(a) or 0
                max     = tonumber(b) or 0
            end
        end
    end)
    return current, max
end

local function isInventoryFull()
    local current, max = getInventoryCount()
    return max > 0 and max <= current
end

local function stopPart(part)
    pcall(function()
        if setnetworkowner then
            setnetworkowner(part)
            return
        end
        part.AssemblyLinearVelocity  = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function pressKey(keyCode)
    Services.VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.01)
    Services.VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function lootNearby(range)
    if isInventoryFull() then return end
    local character  = LocalPlayer.Character
    local hrp        = character and character:FindFirstChild("HumanoidRootPart")
    local lootFolder = Services.Workspace:FindFirstChild("Loot")
    if not hrp or not lootFolder or not getFlowEvent() then return end

    for _, item in pairs(lootFolder:GetChildren()) do
        if isInventoryFull() then return end
        if not isExcludedLoot(item.Name) then
            local part = item.PrimaryPart
                or item:FindFirstChild("Handle")
                or item:FindFirstChildWhichIsA("BasePart")

            if part and (hrp.Position - part.Position).Magnitude <= (range or LOOT_COLLECT_RANGE) then
                pcall(function()
                    getFlowEvent():InvokeServer("Loot", "LootEquip", part)
                end)
            end
        end
    end
end

local function getPawnShopBalance(model)
    local templates = model:FindFirstChild("Templates")
    if templates then templates = templates:FindFirstChild("Template1") end
    if templates then templates = templates:FindFirstChild("PawnCounter") end
    if templates then return templates:FindFirstChild("Balance") end
    return nil
end

local function getCallBellPrompt(instance)
    if not instance then return nil end
    local parent = instance.Parent
    if parent then
        local callBell = parent:FindFirstChild("CallBell")
        if callBell then
            local pp = callBell:FindFirstChildOfClass("ProximityPrompt")
            if not pp then
                pp = callBell:FindFirstChildWhichIsA("ProximityPrompt", true)
            end
            return pp
        end
    end
    return nil
end

local function getNearestPawnShop()
    local character = LocalPlayer.Character
    local hrp       = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local buildings = Services.Workspace:FindFirstChild("Map")
    if buildings then buildings = buildings:FindFirstChild("Buildings") end

    local nearest, nearestDist = nil, math.huge

    if buildings then
        for _, child in pairs(buildings:GetChildren()) do
            if child:IsA("Model") and string.find(string.lower(child.Name), "pawnshop") then
                local balance = getPawnShopBalance(child)
                if balance and balance:IsA("BasePart") then
                    local dist = (hrp.Position - balance.Position).Magnitude
                    if dist < nearestDist then
                        nearest     = balance
                        nearestDist = dist
                    end
                end
            end
        end
    end

    return nearest
end

local moneyFarmSavedCFrame = nil

local function runMoneyFarmLoop()
    task.spawn(function()
        while ACTIVE_CONFIG == "MoneyFarm" do
            task.wait(0.5)

            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then task.wait(1) continue end

            local lootFolder = Services.Workspace:FindFirstChild("Loot")
            local flowEvent  = getFlowEvent()

            if not lootFolder or not flowEvent then task.wait(1) continue end

            if not moneyFarmSavedCFrame then
                moneyFarmSavedCFrame = hrp.CFrame
            end

            local items = {}
            for _, item in pairs(lootFolder:GetChildren()) do
                if not isExcludedLoot(item.Name) then
                    local part = item.PrimaryPart
                        or item:FindFirstChild("Handle")
                        or item:FindFirstChildWhichIsA("BasePart")
                    if part and (moneyFarmSavedCFrame.Position - part.Position).Magnitude <= LOOT_SEARCH_RANGE then
                        table.insert(items, item)
                    end
                end
            end

            if #items > 0 and not isInventoryFull() then
                hum.AutoRotate = false

                for _, item in pairs(items) do
                    if isInventoryFull() then break end

                    local part = item.PrimaryPart
                        or item:FindFirstChild("Handle")
                        or item:FindFirstChildWhichIsA("BasePart")

                    if part then
                        stopPart(part)
                        hrp.CFrame = part.CFrame
                        lootNearby(LOOT_COLLECT_RANGE)

                        local collected = false
                        for _ = 1, 20 do
                            if not item.Parent then collected = true break end
                            if (hrp.Position - part.Position).Magnitude <= 5 then collected = true break end
                            task.wait(0.1)
                        end

                        if collected then
                            task.wait(0.3)
                            lootNearby(LOOT_COLLECT_RANGE)
                            task.wait(0.1)
                        end
                    end
                end

                hum.AutoRotate = true
            end

            local inventoryCount, _ = getInventoryCount()
            if inventoryCount > 0 then
                local pawn = getNearestPawnShop()
                if pawn then
                    local sellTarget = pawn.Position + pawn.CFrame.LookVector * 5
                    hrp.CFrame = CFrame.lookAt(sellTarget, pawn.Position)
                    task.wait(0.2)

                    local inv, _ = getInventoryCount()
                    local stuckCount = 0
                    while inv > 0 do
                        pressKey(Enum.KeyCode.One)
                        pressKey(Enum.KeyCode.X)
                        task.wait(0.02)
                        local newInv, _ = getInventoryCount()
                        if newInv == inv then
                            stuckCount += 1
                            if stuckCount >= 5 then break end
                        else
                            stuckCount = 0
                            inv = newInv
                        end
                    end

                    task.wait(0.2)

                    local bellPrompt = getCallBellPrompt(pawn)
                    if bellPrompt then
                        firePrompt(bellPrompt)
                    else
                        local parent = pawn.Parent
                        if parent then
                            local pp = parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if pp then firePrompt(pp) end
                        end
                    end

                    task.wait(0.2)
                end
            end

            if moneyFarmSavedCFrame then
                hrp.CFrame = moneyFarmSavedCFrame
            end

            task.wait(2)
        end
    end)
end

local function runAutoEscape()
    if autoEscapeRunning then return end

    task.spawn(function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        autoEscapeRunning = true
        screenFound = false

        fastTweenCFrame(hrp, hrp.CFrame + LAUNCH_HEIGHT)
        task.wait(0.05)

        local lastCheck = 0
        local lastPos   = hrp.Position

        local antiBackwardConn = Services.RunService.Heartbeat:Connect(function()
            if screenFound then return end
            local chr  = LocalPlayer.Character
            local root = chr and chr:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local screen = getScreen()
            if screen then
                screenFound = true
                root.AssemblyLinearVelocity = Vector3.zero
                return
            end

            local delta = root.Position - lastPos
            if delta.Z < ANTI_BACKWARD_THRESHOLD then
                root.CFrame = CFrame.new(lastPos) * (root.CFrame - root.CFrame.Position)
                root.AssemblyLinearVelocity = Vector3.zero
            else
                lastPos = root.Position
            end
        end)

        while true do
            local chr  = LocalPlayer.Character
            local root = chr and chr:FindFirstChild("HumanoidRootPart")

            if root then
                if not screenFound then
                    local screen = getScreen()
                    if screen then
                        screenFound = true
                    end
                end

                if screenFound then
                    local screen = getScreen()
                    if screen then
                        local screenCFrame = screen:IsA("BasePart") and screen.CFrame or screen:GetPivot()
                        fastTweenCFrame(root, screenCFrame + Vector3.new(0, 1, 0))
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                else
                    local moved = root.Position + FORWARD_STEP
                    fastTweenCFrame(root, CFrame.new(moved) * (root.CFrame - root.CFrame.Position))
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end

            if tick() - lastCheck >= 0.25 then
                lastCheck = tick()

                local screen = getScreen()

                if screen and root then
                    antiBackwardConn:Disconnect()

                    if not countdownActive then
                        startCountdown()
                    end

                    local screenCFrame = screen:IsA("BasePart") and screen.CFrame or screen:GetPivot()
                    fastTweenCFrame(root, screenCFrame + Vector3.new(0, 1, 0))
                    root.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.1)

                    local cmdBtn = screen.Parent and screen.Parent:FindFirstChild("CommandButton")
                    local prompt = cmdBtn and cmdBtn:FindFirstChild("Prompt")
                    if prompt then
                        prompt = prompt:FindFirstChildOfClass("ProximityPrompt")
                    end

                    if prompt then
                        patchPrompt(prompt)

                        local promptPart = prompt.Parent
                        local promptPos  = (promptPart and promptPart:IsA("BasePart"))
                            and promptPart.Position
                            or screenCFrame.Position
                        local cam = Services.Workspace.CurrentCamera

                        local spamConn = Services.RunService.RenderStepped:Connect(function()
                            local currentRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if not currentRoot then return end
                            cam.CFrame = CFrame.lookAt(currentRoot.Position + Vector3.new(0, 1.5, 0), promptPos)
                            if fireproximityprompt then
                                pcall(fireproximityprompt, prompt)
                            else
                                pcall(function() prompt:InputHoldBegin() end)
                            end
                        end)

                        task.wait(1)
                        spamConn:Disconnect()
                    end

                    local underground = root.Position - UNDERGROUND_OFFSET
                    local platform    = Instance.new("Part")
                    platform.Name         = "EscapePlatform"
                    platform.Size         = Vector3.new(10, 1, 10)
                    platform.CFrame       = CFrame.new(underground - PLATFORM_FLOOR_OFFSET)
                    platform.Anchored     = true
                    platform.CanCollide   = true
                    platform.Transparency = 1
                    platform.Parent       = Services.Workspace

                    local savedWalkSpeed = hum.WalkSpeed
                    hum.WalkSpeed = 0
                    fastTweenCFrame(root, CFrame.new(underground))

                    local lockConn = Services.RunService.Heartbeat:Connect(function()
                        local currentRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not currentRoot then return end
                        currentRoot.CFrame = CFrame.new(underground)
                        currentRoot.AssemblyLinearVelocity  = Vector3.zero
                        currentRoot.AssemblyAngularVelocity = Vector3.zero
                    end)

                    local timer
                    pcall(function()
                        timer = screen.SurfaceGui.Frame.Timer.Time
                    end)

                    while task.wait(0.1) do
                        local heli = Services.Workspace:FindFirstChild("Helicopter", true)
                        if heli then heli:Destroy() end

                        if ACTIVE_CONFIG == "MoneyFarm" then
                            lootNearby(LOOT_COLLECT_RANGE)
                        end

                        if not timer then continue end
                        local timerText = timer.Text
                        if timerText == "" or timerText == "0m 0s" then break end
                    end

                    lockConn:Disconnect()
                    hum.WalkSpeed = savedWalkSpeed
                    if platform then platform:Destroy() end

                    local endCFrame = screen:IsA("BasePart") and screen.CFrame or screen:GetPivot()
                    fastTweenCFrame(root, endCFrame - endCFrame.LookVector * 50)
                    root.AssemblyLinearVelocity = Vector3.zero

                    autoEscapeRunning = false
                    return
                end
            end

            task.wait(0.02)
        end
    end)
end

local function runLobbySequence()
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")

        task.wait(LOBBY_CLICK_DELAY)

        local hud     = playerGui:WaitForChild("Hud")
        local playNow = hud:WaitForChild("PlayNow")

        if waitForGuiLoaded(playNow) then
            clickGui(playNow)
        end

        task.wait(LOBBY_CLICK_DELAY)

        local createLobbyGui = playerGui:WaitForChild("CreateLobbyGui")
        local frame          = createLobbyGui:WaitForChild("Frame")
        local container      = frame:WaitForChild("Container")
        local maxPlayers     = container:WaitForChild("MaxPlayers")
        local maxFrame       = maxPlayers:WaitForChild("Frame")
        local minus          = maxFrame:WaitForChild("Minus")

        task.wait(0.5)

        if waitForGuiLoaded(minus) then
            for _ = 1, MINUS_CLICKS do
                clickGui(minus, MINUS_X_OFFSET)
                task.wait(MINUS_CLICK_INTERVAL)
            end
        end

        task.wait(1)

        local createButton = container:WaitForChild("Create")

        if waitForGuiLoaded(createButton) then
            while true do
                clickGui(createButton)
                task.wait()
            end
        end
    end)
end

buildCountdownUI()

if currentPlaceId == EXPERIENCE_LOBBY then
    runLobbySequence()
elseif currentPlaceId == EXPERIENCE_RUNAWAYS then
    if ACTIVE_CONFIG ~= "MoneyFarm" then
        startSilentCountdown()
    end
    if ACTIVE_CONFIG == "MoneyFarm" then
        runMoneyFarmLoop()
        runAutoEscape()
    else
        runAutoEscape()
    end
end
