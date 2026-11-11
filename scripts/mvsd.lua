local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
while not player do
    task.wait()
    player = Players.LocalPlayer
end

local camera = workspace.CurrentCamera

local fovVisiblePreference = false
local fovRadius = 120
local autoShootEnabled = false
local autoShootAggressiveEnabled = false
local autoShootTargetPart = "Head"
local silentAimManualEnabled = false
local silentAimFovEnabled = false
local silentAimTargetPart = "Head"
local espEnabled = false
local espColor = Color3.fromRGB(255, 255, 255)
local espSettings = { Glow = true }
local KillAllEnabled = false
local hitboxEnabled = false
local hitboxInvisible = false
local hitboxSize = 3.5
local hitboxColor = Color3.fromRGB(255, 0, 0)
local fakeNameEnabled = false
local spoofNameText = "Fake name"
local InvisibilityActive = false

local activeAnimationSet = nil
local originalAnimations = nil
local UIElements = {}

local pxwUpdateTargetFeatures
local pxwRefreshTargetMonitor
local pxwSetAimTarget
local pxwStartAutoShootWorker
local pxwStartSilentAimWorker
local pxwStartEquipWorker
local pxwStartESPWorker
local pxwStartHitboxWorker
local pxwStartAnimationWorker
local pxwStartFOVWorker
local equipGunEnabled = false
local pxwSetInvisibleWorker

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PXWHub_Overlays"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = player:WaitForChild("PlayerGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "PXWESPFolder"
espFolder.Parent = screenGui

getgenv().PXW = { Tabs = {}, Sections = {}, Titles = {}, Counts = {}, Features = {}, Flags = {} }

PXW.Loaded, PXW.Library = pcall(function()
    return loadstring(game:HttpGet("https://pxw-gg.pages.dev/scripts/uisrc.lua"))()
end)

if not PXW.Loaded or not PXW.Library then
    warn("Failed to load the UI library: " .. tostring(PXW.Library))
    return
end

PXW.Library:PreloadIcons("Lucide")

do
    local features = PXW.Features
    PXW.Window = PXW.Library:CreateWindow({
        Title = "PXW | dsc.gg/PerplexWare",
        Version = "Discord | @rainlover.r",
        Icon = "sparkles",
        Style = "OperaGX",
        AutoScale = true,
        Size = Vector2.new(800, 400),
        Scale = 1,
        Folder = "PerplexWare",
        MenuKey = Enum.KeyCode.RightControl,
        Status = "Murder VS Sheriff Duels",
        AdvancedSettings = false,
        Theme = {
            Accent = Color3.fromRGB(17, 17, 17),
            AccentAlt = Color3.fromRGB(70, 70, 70),
            Background = Color3.fromRGB(255, 255, 255),
            Surface = Color3.fromRGB(246, 246, 246),
            SurfaceAlt = Color3.fromRGB(236, 236, 236),
            Outline = Color3.fromRGB(214, 214, 214),
            Text = Color3.fromRGB(12, 12, 12),
            Muted = Color3.fromRGB(110, 110, 110),
            Hover = Color3.fromRGB(230, 230, 230),
            ToggleOn = Color3.fromRGB(17, 17, 17),
            ToggleOff = Color3.fromRGB(200, 200, 200),
            Knob = Color3.fromRGB(255, 255, 255),
            Success = Color3.fromRGB(40, 40, 40),
            Warning = Color3.fromRGB(120, 120, 120),
            Danger = Color3.fromRGB(0, 0, 0),
        },
        OnUnload = function()
            for _, feature in ipairs(features) do
                pcall(function()
                    if feature.Element.Value == true then
                        feature.Element:Set(false)
                    end
                end)
            end
        end,
    })
end

PXW.AddTab = function(key, title, icon)
    PXW.Tabs[key] = PXW.Window:AddTab({ Title = title, Icon = icon })
    PXW.Titles[key] = title
    PXW.Counts[key] = 0
end

PXW.Section = function(key, options)
    options.Side = options.Side or (PXW.Counts[key] % 2 == 0 and "Left" or "Right")
    PXW.Counts[key] = PXW.Counts[key] + 1
    PXW.Sections[key] = PXW.Tabs[key]:AddSection(options)
    return PXW.Sections[key]
end

PXW.FlagName = function(key, text)
    local clean = tostring(text):gsub("[^%w]", "")
    local flag = key .. clean
    local index = 1
    while PXW.Flags[flag] do
        index = index + 1
        flag = key .. clean .. index
    end
    PXW.Flags[flag] = true
    return flag
end

PXW.Refresh = function()
    local grouped, order, total = {}, {}, 0
    for _, feature in ipairs(PXW.Features) do
        if feature.Element.Value == true then
            total = total + 1
            if not grouped[feature.Tab] then
                grouped[feature.Tab] = {}
                table.insert(order, feature.Tab)
            end
            table.insert(grouped[feature.Tab], feature.Name)
        end
    end
    local lines = {}
    for _, key in ipairs(order) do
        table.insert(lines, "<b>" .. PXW.Titles[key] .. "</b>\n" .. table.concat(grouped[key], ", "))
    end
    if total == 0 then
        lines[1] = "No features enabled"
    end
    PXW.CountLabel:SetText("Enabled: " .. total .. " / " .. #PXW.Features)
    PXW.Summary:SetText(table.concat(lines, "\n\n"))
    for key, title in pairs(PXW.Titles) do
        pcall(function()
            PXW.Window:SetBadge(title, grouped[key] and #grouped[key] or 0, "Success")
        end)
    end
end

PXW.Toggle = function(key, options)
    options.Flag = options.Flag or PXW.FlagName(key, options.Text)
    local element = PXW.Sections[key]:AddToggle(options)
    table.insert(PXW.Features, { Tab = key, Name = options.Text, Element = element })
    element:OnChanged(function()
        PXW.Refresh()
    end)
    return element
end

PXW.Slider = function(key, options)
    options.Flag = options.Flag or PXW.FlagName(key, options.Text)
    return PXW.Sections[key]:AddSlider(options)
end

PXW.Dropdown = function(key, options)
    options.Flag = options.Flag or PXW.FlagName(key, options.Text)
    return PXW.Sections[key]:AddDropdown(options)
end

PXW.TextBox = function(key, options)
    options.Flag = options.Flag or PXW.FlagName(key, options.Text)
    return PXW.Sections[key]:AddTextBox(options)
end

PXW.ColorPicker = function(key, options)
    options.Flag = options.Flag or PXW.FlagName(key, options.Text)
    return PXW.Sections[key]:AddColorPicker(options)
end

PXW.Button = function(key, options)
    return PXW.Sections[key]:AddButton(options)
end

PXW.Paragraph = function(key, options)
    return PXW.Sections[key]:AddParagraph(options)
end

PXW.Info = function(key, content, risk)
    PXW.Section(key, { Title = "Overview", Icon = "info" })
    PXW.Sections[key]:AddParagraph({ Title = PXW.Titles[key], Content = content })
    PXW.Sections[key]:AddStatus({
        Text = "Risk",
        Status = risk,
        Tone = (risk == "High" and "Danger") or (risk == "Medium" and "Warning") or (risk == "Low" and "Success") or "Muted",
    })
end

PXW.AddTab("Extras", "Extras", "puzzle")
PXW.Info("Extras", "Extra scripts, the Discord invite and\nthe live list of enabled features.\nWarning: Copy Avatars loads an external script.", "Medium")
PXW.Section("Extras", { Title = "Active Features", Icon = "activity" })
PXW.CountLabel = PXW.Sections.Extras:AddLabel({ Text = "Enabled: 0", Icon = "activity" })
PXW.Summary = PXW.Sections.Extras:AddParagraph({ Title = "Enabled now", Content = "No features enabled", RichText = true, Tone = "Text" })
PXW.Section("Extras", { Title = "Discord", Icon = "message-square" })
PXW.Sections.Extras:AddLabel({ Text = "dsc.gg/perplexware", Icon = "link" })
PXW.Sections.Extras:AddButton({
    Text = "Copy Discord Invite",
    Icon = "copy",
    Primary = true,
    Callback = function()
        if setclipboard then
            setclipboard("https://dsc.gg/perplexware/")
            PXW.Window:Notify({ Title = "Copied", Content = "Discord invite copied to the clipboard", Type = "Success", Duration = 2 })
        else
            PXW.Window:Notify({ Title = "Discord", Content = "https://dsc.gg/perplexware/", Type = "Warning", Duration = 6 })
        end
    end,
})

PXW.AddTab("Graphics", "Graphics", "palette")
PXW.Info("Graphics", "Lighting presets for the map.\nOnly one preset can be active at a time.", "None")

PXW.AddTab("Aim", "Aimbot", "crosshair")
PXW.Info("Aim", "Auto shoot, silent aim and the FOV circle.\nWarning: very easy to get flagged.", "High")

PXW.AddTab("Visual", "Visual", "eye")
PXW.Info("Visual", "Player ESP with color and glow options.\nRisk is low, it is only drawn on your screen.", "Low")

PXW.AddTab("KillAll", "Kill All", "skull")
PXW.Info("KillAll", "Kill All and the hitbox expander.\nWarning: very obvious, high ban risk.", "High")

PXW.AddTab("Invisible", "Invisible", "ghost")
PXW.Info("Invisible", "Hides your character from other players.\nWarning: can glitch and get you flagged.", "High")

PXW.AddTab("Cheats", "Cheats", "zap")
PXW.Info("Cheats", "Speed boost and infinite jump.\nWarning: speed checks are common, keep values low.", "Medium")

PXW.AddTab("EventFarm", "Event Farm", "gift")
PXW.Info("EventFarm", "Auto farms the current event.\nWarning: long unattended sessions get noticed.", "Medium")

PXW.AddTab("StreakFarm", "Streak Farm", "flame")
PXW.Info("StreakFarm", "Auto teleport loop for win streaks.\nWarning: runs on its own, an alt account is safer.", "High")

PXW.AddTab("Animations", "Animations", "smile")
PXW.Info("Animations", "Animation packs and a per-state mixer.\nRisk is low.", "Low")

PXW.AddTab("Sounds", "Sounds", "volume-2")
PXW.Info("Sounds", "Kill, shot and reload sounds.\nAudio only, no risk.", "None")

PXW.AddTab("Music", "Music", "music")
PXW.Info("Music", "Simple music player with song controls.\nAudio only, no risk.", "None")

PXW.AddTab("Items", "Items", "crown")
PXW.Info("Items", "Headless and Korblox for your avatar.\nRisk is low.", "Low")

PXW.AddTab("Identity", "Identity", "user")
PXW.Info("Identity", "Fake name shown on your own screen.\nRisk is low.", "Low")


local isEnemy, isInLobby, IsInMatchStrict
local isValidEnemy, isKnife, isGun, getGun
do
    local playerGui = player:WaitForChild("PlayerGui")
    local duelInvalidateRedirectSelection
    local duelClearTargetParts
    local function duelDisconnectConnectionList(list)
        if not list then
            return
        end
        for i = #list, 1, -1 do
            local connection = list[i]
            list[i] = nil
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
    end
    local duelIsInfectionMode
    local function duelIsTargetAlive(target)
        local character = target
        if typeof(target) == "Instance" and target:IsA("Player") then
            character = target.Character
        end
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return false
        end
        if duelIsInfectionMode and duelIsInfectionMode() then
            return character:GetAttribute("InfectionDowned") ~= true
        end
        return humanoid.Health >= 99
    end
    local function duelGetInGameScoreboard()
        local gui = player:FindFirstChild("PlayerGui")
        local main = gui and gui:FindFirstChild("Main")
        local frame = main and main:FindFirstChild("MainGameFrame")
        return frame and frame:FindFirstChild("IngameScore") or nil
    end

    local duelTeamResolverState = {
        Snapshot = {},
        Scoreboard = nil,
        InGame = false,
        LocalGame = nil,
        LastRefresh = 0,
        RefreshInterval = 2,
        Dirty = true,
        WatchConnections = {},
    }

    local function duelInvalidateScoreboard()
        duelTeamResolverState.Dirty = true
    end

    local function duelWatchScoreboard(score)
        local state = duelTeamResolverState
        if state.Scoreboard == score then
            return
        end
        duelDisconnectConnectionList(state.WatchConnections)
        state.Scoreboard = score
        if not score then
            return
        end
        local watchTeams
        watchTeams = function()
            duelInvalidateScoreboard()
            duelDisconnectConnectionList(state.WatchConnections)
            state.WatchConnections[#state.WatchConnections + 1] =
                score.ChildAdded:Connect(watchTeams)
            state.WatchConnections[#state.WatchConnections + 1] =
                score.ChildRemoved:Connect(watchTeams)
            for _, name in ipairs({ "TeamRed", "TeamBlue" }) do
                local folder = score:FindFirstChild(name)
                if folder then
                    state.WatchConnections[#state.WatchConnections + 1] =
                        folder.ChildAdded:Connect(duelInvalidateScoreboard)
                    state.WatchConnections[#state.WatchConnections + 1] =
                        folder.ChildRemoved:Connect(duelInvalidateScoreboard)
                end
            end
        end
        watchTeams()
    end

    local function duelRefreshScoreboardTeams(force)
        local state = duelTeamResolverState
        local now = os.clock()
        local localGame = player:GetAttribute("Game")
        if
            not force
            and not state.Dirty
            and now - state.LastRefresh < state.RefreshInterval
            and state.LocalGame == localGame
            and (not state.Scoreboard or state.Scoreboard.Parent)
        then
            return state.Snapshot
        end

        state.LastRefresh = now
        state.LocalGame = localGame
        local snapshot = {}
        local score = duelGetInGameScoreboard()
        if score ~= state.Scoreboard then
            duelWatchScoreboard(score)
        end
        for _, teamName in ipairs({ "TeamRed", "TeamBlue" }) do
            local teamFolder = score and score:FindFirstChild(teamName)
            if teamFolder then
                local team = teamName == "TeamRed" and "Red" or "Blue"
                for _, entry in ipairs(teamFolder:GetChildren()) do
                    if entry:IsA("GuiObject") then
                        snapshot[string.lower(entry.Name)] = team
                    end
                end
            end
        end
        state.Snapshot = snapshot
        state.Dirty = false
        state.InGame = score ~= nil and snapshot[string.lower(player.Name)] ~= nil
        return snapshot
    end

    local duelInfectionRoleAttributes =
        { "InfectionInfected", "IsInfected", "Infected", "IsZombie", "Zombie" }
    local duelInfectionModeAttributes = { "GameMode", "MatchMode", "Mode" }
    local duelInfectionState = {
        Active = false,
        LastRefresh = -math.huge,
        RefreshInterval = 0.4,
        RoleTeams = {},
        Inferred = {},
        Targets = {},
        Converted = {},
        ConvertedAt = {},
        Pending = {},
        LateJoiners = {},
        LastLocalGame = nil,
        LastMatchId = nil,
        HasMatchContext = false,
        RoundEnded = false,
    }

    local function duelInfectionReadMarker(holder)
        if not holder then
            return nil
        end
        if holder:GetAttribute("InfectionPatientZero") == true then
            return true
        end
        local sawSurvivor = false
        for _, name in ipairs(duelInfectionRoleAttributes) do
            local value = holder:GetAttribute(name)
            if typeof(value) == "boolean" then
                if value then
                    return true
                end
                sawSurvivor = true
            elseif typeof(value) == "string" then
                local normalized = value:lower()
                if
                    normalized == "infected"
                    or normalized == "infection"
                    or normalized == "zombie"
                    or normalized == "true"
                then
                    return true
                end
                if normalized == "survivor" or normalized == "human" or normalized == "false" then
                    sawSurvivor = true
                end
            end
        end
        if sawSurvivor then
            return false
        end
        return nil
    end

    local function duelInfectionHasPatientZero(other)
        if other:GetAttribute("InfectionPatientZero") == true then
            return true
        end
        local character = other.Character
        if not character then
            return false
        end
        if character:GetAttribute("InfectionPatientZero") == true then
            return true
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        return humanoid ~= nil and humanoid:GetAttribute("InfectionPatientZero") == true
    end

    local function duelInfectionAttribute(playerInstance)
        if not playerInstance then
            return nil
        end
        local character = playerInstance.Character
        local characterStatus = duelInfectionReadMarker(character)
        local playerStatus = duelInfectionReadMarker(playerInstance)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local humanoidStatus = duelInfectionReadMarker(humanoid)
        if characterStatus == true or playerStatus == true or humanoidStatus == true then
            return true
        end
        if characterStatus == false or playerStatus == false or humanoidStatus == false then
            return false
        end
        return nil
    end

    local function duelReadInfectionRoster(teams)
        local frame = playerGui:FindFirstChild("Main")
        frame = frame and frame:FindFirstChild("MainGameFrame")
        if not frame then
            return
        end
        local playerFrame = frame:FindFirstChild("PlayersFrame")
        local regularFrame = frame:FindFirstChild("IngameScore")
        local playerNames = {}
        local displayCandidates = {}
        local ambiguousDisplays = {}
        for _, other in ipairs(Players:GetPlayers()) do
            playerNames[other.Name:lower()] = other
            playerNames[tostring(other.UserId)] = other
            local displayKey = other.DisplayName:lower()
            if displayCandidates[displayKey] then
                ambiguousDisplays[displayKey] = true
            end
            displayCandidates[displayKey] = other
        end
        for displayKey, other in pairs(displayCandidates) do
            if not ambiguousDisplays[displayKey] and not playerNames[displayKey] then
                playerNames[displayKey] = other
            end
        end
        local function collect(group, team)
            if not group then
                return
            end
            for _, entry in ipairs(group:GetChildren()) do
                if entry:IsA("GuiObject") then
                    local other = playerNames[entry.Name:lower():gsub("^@", "")]
                    if not other then
                        local entryUserId = entry:GetAttribute("UserId")
                        if entryUserId then
                            other = playerNames[tostring(entryUserId)]
                        end
                    end
                    if not other then
                        for _, sub in ipairs(entry:GetDescendants()) do
                            if
                                sub:IsA("TextLabel")
                                and (sub.Name == "PlayerName" or sub.Name == "TextLabel")
                            then
                                other = playerNames[sub.Text:lower():gsub("^@", "")]
                                if other then
                                    break
                                end
                            end
                        end
                    end
                    if other then
                        teams[other] = team
                    end
                end
            end
        end
        if regularFrame then
            collect(regularFrame:FindFirstChild("TeamRed"), "Red")
            collect(regularFrame:FindFirstChild("TeamBlue"), "Blue")
        end
        if playerFrame then
            collect(playerFrame:FindFirstChild("TeamRedFrame"), "Red")
            collect(playerFrame:FindFirstChild("TeamBlueFrame"), "Blue")
        end
    end

    local function duelClearInfectionRound(ended)
        local state = duelInfectionState
        table.clear(state.Converted)
        table.clear(state.ConvertedAt)
        table.clear(state.Pending)
        table.clear(state.LateJoiners)
        table.clear(state.Inferred)
        table.clear(state.Targets)
        table.clear(state.RoleTeams)
        state.Active = false
        state.RoundEnded = ended == true
        state.LastRefresh = -math.huge
        if duelInvalidateRedirectSelection then
            duelInvalidateRedirectSelection()
        end
    end

    local function duelRefreshInfectionState(force)
        local state = duelInfectionState
        local now = os.clock()
        local localGame = player:GetAttribute("Game")
        local matchId = player:GetAttribute("MatchId")
        if
            state.HasMatchContext
            and (localGame ~= state.LastLocalGame or matchId ~= state.LastMatchId)
        then
            duelClearInfectionRound(false)
        end
        state.HasMatchContext = true
        state.LastLocalGame = localGame
        state.LastMatchId = matchId
        if not force and now - state.LastRefresh < state.RefreshInterval then
            return state
        end
        state.LastRefresh = now
        local regularRoster = duelRefreshScoreboardTeams(false)
        local foundPatientZero = false
        local ownCharacter = player.Character
        local myRoot = ownCharacter and ownCharacter:FindFirstChild("HumanoidRootPart")
        local allPlayers = Players:GetPlayers()
        for _, other in ipairs(allPlayers) do
            if duelInfectionHasPatientZero(other) then
                local compatible = other == player
                if not compatible then
                    compatible = true
                    local otherGame = other:GetAttribute("Game")
                    local otherMatch = other:GetAttribute("MatchId")
                    if
                        localGame ~= nil
                        and localGame ~= ""
                        and otherGame ~= nil
                        and otherGame ~= ""
                        and localGame ~= otherGame
                    then
                        compatible = false
                    end
                    if
                        (localGame == nil or localGame == "")
                        and otherGame ~= nil
                        and otherGame ~= ""
                    then
                        compatible = false
                    end
                    if
                        matchId ~= nil
                        and matchId ~= ""
                        and otherMatch ~= nil
                        and otherMatch ~= ""
                        and matchId ~= otherMatch
                    then
                        compatible = false
                    end
                    local theirCharacter = other.Character
                    local theirRoot = theirCharacter
                        and theirCharacter:FindFirstChild("HumanoidRootPart")
                    if
                        myRoot
                        and theirRoot
                        and (myRoot.Position - theirRoot.Position).Magnitude > 1200
                    then
                        compatible = false
                    end
                end
                if compatible then
                    foundPatientZero = true
                    break
                end
            end
        end
        local modeAttribute
        for _, name in ipairs(duelInfectionModeAttributes) do
            local value = player:GetAttribute(name)
            if typeof(value) == "string" and value ~= "" then
                modeAttribute = value:lower()
                break
            end
        end
        if not modeAttribute then
            for _, name in ipairs(duelInfectionModeAttributes) do
                local value = workspace:GetAttribute(name)
                if typeof(value) == "string" and value ~= "" then
                    modeAttribute = value:lower()
                    break
                end
            end
        end
        local active = not state.RoundEnded
            and (
                modeAttribute == "infection"
                or (
                    not modeAttribute
                    and (foundPatientZero or (state.Active and not duelTeamResolverState.InGame))
                )
            )
        if not active then
            if
                modeAttribute
                and modeAttribute ~= "infection"
                and next(state.LateJoiners) ~= nil
            then
                table.clear(state.LateJoiners)
            end
            if state.Active or next(state.Targets) ~= nil then
                if modeAttribute and modeAttribute ~= "infection" then
                    duelClearInfectionRound(false)
                else
                    state.Active = false
                    table.clear(state.Targets)
                    table.clear(state.Inferred)
                    table.clear(state.RoleTeams)
                    if duelInvalidateRedirectSelection then
                        duelInvalidateRedirectSelection()
                    end
                end
            end
            return state
        end
        state.Active = true
        local teams = {}
        duelReadInfectionRoster(teams)
        state.RoleTeams = teams
        local infectedTeam
        local ambiguousTeam = false
        local markers = {}
        for _, other in ipairs(allPlayers) do
            local marker = duelInfectionAttribute(other)
            markers[other] = marker
            if marker == true or state.Converted[other] == true then
                local team = teams[other]
                if team then
                    if infectedTeam and infectedTeam ~= team then
                        ambiguousTeam = true
                    end
                    infectedTeam = team
                end
            end
        end
        local inferred = {}
        if infectedTeam and not ambiguousTeam then
            for other, team in pairs(teams) do
                if team == infectedTeam and markers[other] ~= false then
                    inferred[other] = true
                end
            end
        end
        state.Inferred = inferred
        local function createTargets()
            local targets = {}
            for _, other in ipairs(allPlayers) do
                if
                    markers[other] == true
                    or state.Converted[other] == true
                    or (markers[other] ~= false and inferred[other] == true)
                then
                    targets[other] = true
                end
            end
            return targets
        end
        local targets = createTargets()
        local infectedRoots = {}
        for infectedPlayer in pairs(targets) do
            local infectedCharacter = infectedPlayer.Character
            local infectedRoot = infectedCharacter
                and infectedCharacter:FindFirstChild("HumanoidRootPart")
            if infectedRoot and infectedRoot:IsA("BasePart") then
                infectedRoots[#infectedRoots + 1] = infectedRoot
            end
        end
        for _, other in ipairs(allPlayers) do
            if
                other ~= player
                and state.LateJoiners[other]
                and markers[other] == nil
                and not targets[other]
                and other.Character
            then
                local rosterTeam = teams[other] or regularRoster[other.Name:lower()]
                local otherGame = other:GetAttribute("Game")
                local otherMatch = other:GetAttribute("MatchId")
                local sameGame = localGame ~= nil and localGame ~= "" and otherGame == localGame
                local sameMatch = matchId ~= nil and matchId ~= "" and otherMatch == matchId
                local differentGame = localGame ~= nil
                    and localGame ~= ""
                    and otherGame ~= nil
                    and otherGame ~= ""
                    and otherGame ~= localGame
                local differentMatch = matchId ~= nil
                    and matchId ~= ""
                    and otherMatch ~= nil
                    and otherMatch ~= ""
                    and otherMatch ~= matchId
                if not differentGame and not differentMatch then
                    local sharesInfectedTeam = false
                    for infectedPlayer in pairs(targets) do
                        local infectedRobloxTeam = infectedPlayer.Team
                        if
                            infectedRobloxTeam
                            and other.Team == infectedRobloxTeam
                            and (
                                markers[infectedPlayer] == true
                                or state.Converted[infectedPlayer] == true
                                or inferred[infectedPlayer] == true
                            )
                        then
                            sharesInfectedTeam = true
                            break
                        end
                    end
                    local nearInfected = false
                    if
                        not rosterTeam
                        and not sameGame
                        and not sameMatch
                        and not sharesInfectedTeam
                    then
                        local characterRoot = other.Character:FindFirstChild("HumanoidRootPart")
                        if characterRoot and characterRoot:IsA("BasePart") then
                            local position = characterRoot.Position
                            for _, infectedRoot in ipairs(infectedRoots) do
                                if (infectedRoot.Position - position).Magnitude <= 300 then
                                    nearInfected = true
                                    break
                                end
                            end
                        end
                    end
                    local participates = rosterTeam ~= nil
                        or sameGame
                        or sameMatch
                        or sharesInfectedTeam
                        or nearInfected
                    if
                        participates
                        and (
                            not infectedTeam
                            or ambiguousTeam
                            or not rosterTeam
                            or rosterTeam == infectedTeam
                        )
                    then
                        targets[other] = true
                    end
                end
            end
        end
        local pending = state.Pending
        local changed = true
        while changed do
            changed = false
            for index = #pending, 1, -1 do
                local entry = pending[index]
                if
                    now - entry.Time > 10
                    or entry.Killer.Parent ~= Players
                    or entry.Victim.Parent ~= Players
                then
                    table.remove(pending, index)
                elseif
                    targets[entry.Killer]
                    and not targets[entry.Victim]
                    and (
                        not state.ConvertedAt[entry.Killer]
                        or state.ConvertedAt[entry.Killer] <= entry.Time
                    )
                then
                    state.Converted[entry.Victim] = true
                    state.ConvertedAt[entry.Victim] = entry.Time
                    targets[entry.Victim] = true
                    table.remove(pending, index)
                    changed = true
                elseif targets[entry.Killer] then
                    table.remove(pending, index)
                end
            end
        end
        local previous = state.Targets
        local targetChanged = false
        for other in pairs(previous) do
            if not targets[other] then
                targetChanged = true
                break
            end
        end
        if not targetChanged then
            for other in pairs(targets) do
                if not previous[other] then
                    targetChanged = true
                    break
                end
            end
        end
        state.Targets = targets
        if targetChanged and duelInvalidateRedirectSelection then
            duelInvalidateRedirectSelection()
        end
        return state
    end

    duelIsInfectionMode = function()
        return duelRefreshInfectionState(false).Active
    end

    local function duelIsInfectedTarget(targetPlayer)
        if not targetPlayer then
            return false
        end
        local state = duelRefreshInfectionState(false)
        return state.Active and state.Targets[targetPlayer] == true
    end

    local function duelInfectionMatchAllowed(targetPlayer, allowMissingCharacter)
        if
            not targetPlayer
            or targetPlayer == player
            or not targetPlayer.Parent
            or (not allowMissingCharacter and not targetPlayer.Character)
        then
            return false
        end
        local myGame = player:GetAttribute("Game")
        local targetGame = targetPlayer:GetAttribute("Game")
        if
            myGame ~= nil
            and myGame ~= ""
            and targetGame ~= nil
            and targetGame ~= ""
            and myGame ~= targetGame
        then
            return false
        end
        if (myGame == nil or myGame == "") and targetGame ~= nil and targetGame ~= "" then
            return false
        end
        local myMatch = player:GetAttribute("MatchId")
        local targetMatch = targetPlayer:GetAttribute("MatchId")
        if
            myMatch ~= nil
            and myMatch ~= ""
            and targetMatch ~= nil
            and targetMatch ~= ""
            and myMatch ~= targetMatch
        then
            return false
        end
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local otherRoot = targetPlayer.Character
            and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and otherRoot and (myRoot.Position - otherRoot.Position).Magnitude > 1200 then
            return false
        end
        return true
    end

    local function duelInfectionMarkDirty()
        duelInfectionState.LastRefresh = -math.huge
    end

    local function duelInfectionOnKill(killer, victim)
        if
            typeof(killer) ~= "Instance"
            or not killer:IsA("Player")
            or typeof(victim) ~= "Instance"
            or not victim:IsA("Player")
            or killer == victim
            or not duelIsInfectionMode()
            or (killer ~= player and not duelInfectionMatchAllowed(killer, true))
            or (victim ~= player and not duelInfectionMatchAllowed(victim, true))
        then
            return
        end
        local state = duelRefreshInfectionState(false)
        if state.Targets[victim] then
            return
        end
        if state.Targets[killer] then
            state.Converted[victim] = true
            state.ConvertedAt[victim] = os.clock()
            state.LastRefresh = -math.huge
            duelRefreshInfectionState(true)
        else
            if #state.Pending >= 96 then
                table.remove(state.Pending, 1)
            end
            state.Pending[#state.Pending + 1] =
                { Killer = killer, Victim = victim, Time = os.clock() }
            state.LastRefresh = -math.huge
        end
    end

    local duelIsInSameGame
    duelIsInSameGame = function(targetPlayer)
        if not targetPlayer or targetPlayer == player or not targetPlayer.Parent then
            return false
        end

        if duelIsInfectionMode() then
            return duelInfectionMatchAllowed(targetPlayer) and duelIsInfectedTarget(targetPlayer)
        end

        local roster = duelRefreshScoreboardTeams(false)
        if not duelTeamResolverState.InGame or not roster[string.lower(targetPlayer.Name)] then
            return false
        end

        local myGame = player:GetAttribute("Game")
        local targetGame = targetPlayer:GetAttribute("Game")
        if myGame ~= nil and myGame ~= "" and targetGame ~= nil and targetGame ~= "" then
            if myGame ~= targetGame then
                return false
            end
        elseif (myGame == nil or myGame == "") and targetGame ~= nil and targetGame ~= "" then
            return false
        end

        local myMatch = player:GetAttribute("MatchId")
        local targetMatch = targetPlayer:GetAttribute("MatchId")
        if
            myMatch ~= nil
            and myMatch ~= ""
            and targetMatch ~= nil
            and targetMatch ~= ""
            and myMatch ~= targetMatch
        then
            return false
        end

        return true
    end

    local function duelResolvePlayerTeam(targetPlayer)
        if not targetPlayer then
            return nil
        end

        local snapshot = duelRefreshScoreboardTeams(false)
        local byName = snapshot[string.lower(targetPlayer.Name)]

        if not byName and targetPlayer.DisplayName then
            byName = snapshot[string.lower(targetPlayer.DisplayName)]
        end

        if byName then
            return byName
        end

        local attr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")
        if attr ~= nil and tostring(attr) ~= "" then
            return tostring(attr)
        end

        if targetPlayer.Team then
            return targetPlayer.Team.Name
        end

        local teamColor = targetPlayer.TeamColor
        if teamColor and teamColor.Name ~= "White" and teamColor.Name ~= "Medium stone grey" then
            return "Color:" .. teamColor.Name
        end

        return nil
    end

    local function duelPlayersAreEnemies(firstPlayer, secondPlayer)
        if not firstPlayer or not secondPlayer or firstPlayer == secondPlayer then
            return false
        end
        if duelIsInfectionMode() then
            return duelIsInfectedTarget(secondPlayer)
        end

        local firstTeam = duelResolvePlayerTeam(firstPlayer)
        local secondTeam = duelResolvePlayerTeam(secondPlayer)

        if firstTeam ~= nil and secondTeam ~= nil then
            return firstTeam ~= secondTeam
        end

        return true
    end

    local function updateMyTeam()
        duelInvalidateScoreboard()
        if duelInvalidateRedirectSelection then
            duelInvalidateRedirectSelection()
        end
    end

    local function updateEnemy()
        duelInvalidateScoreboard()
        duelInfectionMarkDirty()
        if duelInvalidateRedirectSelection then
            duelInvalidateRedirectSelection()
        end
    end

    local duelTeamPlayerConnections = {}
    local duelInfectionCharacterConnections = {}

    local function disconnectPlayerTeamEvents(p)
        duelDisconnectConnectionList(duelInfectionCharacterConnections[p])
        duelInfectionCharacterConnections[p] = nil
        local connections = duelTeamPlayerConnections[p]
        if connections then
            duelDisconnectConnectionList(connections)
            duelTeamPlayerConnections[p] = nil
        end
    end

    local function duelWatchInfectionCharacter(p, character)
        duelDisconnectConnectionList(duelInfectionCharacterConnections[p])
        duelInfectionCharacterConnections[p] = nil
        if not character then
            return
        end
        local connections = {}
        duelInfectionCharacterConnections[p] = connections
        local function changed(name)
            if
                name == "InfectionPatientZero"
                or name == "InfectionInfected"
                or name == "IsInfected"
                or name == "Infected"
                or name == "IsZombie"
                or name == "Zombie"
            then
                duelInfectionMarkDirty()
                updateEnemy()
            end
        end
        connections[#connections + 1] = character.AttributeChanged:Connect(changed)
        local function bindHumanoid(humanoid)
            if humanoid and humanoid:IsA("Humanoid") then
                connections[#connections + 1] = humanoid.AttributeChanged:Connect(changed)
            end
        end
        bindHumanoid(character:FindFirstChildOfClass("Humanoid"))
        connections[#connections + 1] = character.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                bindHumanoid(child)
                duelInfectionMarkDirty()
            end
        end)
    end

    local function setupPlayerEvents(p)
        if not p or p == player or not p.Parent then
            return
        end
        disconnectPlayerTeamEvents(p)
        duelTeamPlayerConnections[p] = {
            p:GetPropertyChangedSignal("Team"):Connect(updateEnemy),
            p:GetPropertyChangedSignal("TeamColor"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("Team"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("team"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("Game"):Connect(updateEnemy),
            p:GetAttributeChangedSignal("MatchId"):Connect(updateEnemy),
            p.AttributeChanged:Connect(function(name)
                if
                    name == "InfectionPatientZero"
                    or name == "InfectionInfected"
                    or name == "IsInfected"
                    or name == "Infected"
                    or name == "IsZombie"
                    or name == "Zombie"
                then
                    duelInfectionMarkDirty()
                    updateEnemy()
                end
            end),
            p.CharacterAdded:Connect(function(character)
                duelWatchInfectionCharacter(p, character)
                duelInfectionMarkDirty()
                updateEnemy()
            end),
            p.CharacterRemoving:Connect(function(character)
                duelWatchInfectionCharacter(p, nil)
                duelInfectionMarkDirty()
                if duelClearTargetParts then
                    duelClearTargetParts(character)
                end
            end),
        }
        duelWatchInfectionCharacter(p, p.Character)
        updateEnemy()
    end

    local pxwTargetConnections = {}
    local pxwTargetMonitorActive = false
    local pxwTargetMonitorSession = 0
    local function pxwMonitorConnection(connection)
        pxwTargetConnections[#pxwTargetConnections + 1] = connection
        return connection
    end
    local function pxwStartTargetMonitor()
        if pxwTargetMonitorActive then
            return
        end
        pxwTargetMonitorActive = true
        pxwTargetMonitorSession += 1
        local session = pxwTargetMonitorSession
        local function localChanged()
            updateMyTeam()
            duelInfectionMarkDirty()
        end
        for _, name in ipairs({ "Team", "TeamColor" }) do
            pxwMonitorConnection(player:GetPropertyChangedSignal(name):Connect(localChanged))
        end
        for _, name in ipairs({ "Team", "team", "Game", "MatchId", "GameMode", "MatchMode", "Mode" }) do
            pxwMonitorConnection(player:GetAttributeChangedSignal(name):Connect(localChanged))
        end
        pxwMonitorConnection(player.AttributeChanged:Connect(function(name)
            if
                name == "InfectionPatientZero"
                or name == "InfectionInfected"
                or name == "IsInfected"
                or name == "Infected"
                or name == "IsZombie"
                or name == "Zombie"
            then
                duelInfectionMarkDirty()
            end
        end))
        pxwMonitorConnection(player.CharacterAdded:Connect(duelInfectionMarkDirty))
        pxwMonitorConnection(playerGui.DescendantAdded:Connect(function(instance)
            if
                instance.Name == "IngameScore"
                or instance.Name == "TeamRed"
                or instance.Name == "TeamBlue"
            then
                duelInvalidateScoreboard()
                duelInfectionMarkDirty()
            end
        end))
        pxwMonitorConnection(playerGui.DescendantRemoving:Connect(function(instance)
            if
                instance == duelTeamResolverState.Scoreboard
                or instance.Name == "IngameScore"
                or instance.Name == "TeamRed"
                or instance.Name == "TeamBlue"
            then
                duelInvalidateScoreboard()
                duelInfectionMarkDirty()
            end
        end))
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player then
                setupPlayerEvents(other)
            end
        end
        pxwMonitorConnection(Players.PlayerAdded:Connect(function(other)
            duelInfectionState.LateJoiners[other] = true
            setupPlayerEvents(other)
            duelInfectionMarkDirty()
        end))
        pxwMonitorConnection(Players.PlayerRemoving:Connect(function(other)
            disconnectPlayerTeamEvents(other)
            for i = #duelInfectionState.Pending, 1, -1 do
                local entry = duelInfectionState.Pending[i]
                if entry.Killer == other or entry.Victim == other then
                    table.remove(duelInfectionState.Pending, i)
                end
            end
            for _, bucket in ipairs({
                "Converted",
                "ConvertedAt",
                "LateJoiners",
                "Inferred",
                "Targets",
                "RoleTeams",
            }) do
                duelInfectionState[bucket][other] = nil
            end
            updateEnemy()
        end))
        duelInvalidateScoreboard()
        duelInfectionMarkDirty()
        task.spawn(function()
            local registered = {}
            local listeners = {
                ["RE/Combat/Killed"] = duelInfectionOnKill,
                ["RE/Match/PlayerRespawned"] = duelInfectionMarkDirty,
                ["RE/Match/StartRoundGui"] = function()
                    duelClearInfectionRound(false)
                end,
                ["RE/Match/MatchResults"] = function()
                    if duelInfectionState.Active then
                        duelClearInfectionRound(true)
                    end
                end,
            }
            while pxwTargetMonitorActive and session == pxwTargetMonitorSession do
                local packages = ReplicatedStorage:FindFirstChild("Packages")
                local networking = packages and packages:FindFirstChild("Networking")
                local finished = true
                for name, callback in pairs(listeners) do
                    if not registered[name] then
                        local remote = networking and networking:FindFirstChild(name)
                        if remote and remote:IsA("RemoteEvent") then
                            pxwMonitorConnection(remote.OnClientEvent:Connect(callback))
                            registered[name] = true
                        else
                            finished = false
                        end
                    end
                end
                if finished then
                    break
                end
                task.wait(2)
            end
        end)
    end
    local function pxwStopTargetMonitor()
        if not pxwTargetMonitorActive then
            return
        end
        pxwTargetMonitorActive = false
        pxwTargetMonitorSession += 1
        duelDisconnectConnectionList(pxwTargetConnections)
        for other in pairs(duelTeamPlayerConnections) do
            disconnectPlayerTeamEvents(other)
        end
        duelDisconnectConnectionList(duelTeamResolverState.WatchConnections)
        duelTeamResolverState.Scoreboard = nil
        duelTeamResolverState.Snapshot = {}
        duelTeamResolverState.InGame = false
        duelTeamResolverState.Dirty = true
        duelClearInfectionRound(false)
    end
    pxwRefreshTargetMonitor = function()
        if
            autoShootEnabled
            or autoShootAggressiveEnabled
            or silentAimManualEnabled
            or silentAimFovEnabled
            or equipGunEnabled
            or (espEnabled and espSettings.Glow)
            or hitboxEnabled
            or KillAllEnabled
        then
            pxwStartTargetMonitor()
        else
            pxwStopTargetMonitor()
        end
    end

    isEnemy = function(targetPlayer)
        if not duelIsInSameGame(targetPlayer) or not targetPlayer.Character then
            return false
        end
        if not duelIsTargetAlive(targetPlayer) then
            return false
        end
        return duelPlayersAreEnemies(player, targetPlayer)
    end
    local SAFE_ZONES = {
        { Center = Vector3.new(-320.50, 280.82, 16.00), Radius = 500 },
        { Center = Vector3.new(1564.14, -155.45, 40.04), Radius = 300 },
    }
    isInLobby = function()
        local character = player.Character
        if not character then
            return true
        end
        if character:FindFirstChildOfClass("ForceField") then
            return true
        end
        if player.Team then
            local name = player.Team.Name:lower()
            if
                name:find("lobby")
                or name:find("spectat")
                or name:find("espectador")
                or name:find("menu")
                or name:find("dead")
            then
                return true
            end
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, zone in ipairs(SAFE_ZONES) do
                if (root.Position - zone.Center).Magnitude <= zone.Radius then
                    return true
                end
            end
        end
        return false
    end
    IsInMatchStrict = function()
        if isInLobby() then
            return false
        end
        duelRefreshScoreboardTeams(false)
        return duelTeamResolverState.InGame or duelIsInfectionMode()
    end
    isValidEnemy = function(other)
        if not isEnemy(other) then
            return false
        end
        local character = other.Character
        return character ~= nil
            and not character:FindFirstChildOfClass("ForceField")
            and duelIsTargetAlive(other)
    end
    isKnife = function(tool)
        if not tool or not tool:IsA("Tool") then
            return false
        end
        if tool:FindFirstChild("Slash") or tool:FindFirstChild("SlashStart") then
            return true
        end
        local name = tool.Name:lower()
        return name:find("knife", 1, true) ~= nil
            or name:find("cuchillo", 1, true) ~= nil
            or name:find("dagger", 1, true) ~= nil
    end
    isGun = function(tool)
        if not tool or not tool:IsA("Tool") then
            return false
        end
        local beam = tool:FindFirstChild("showBeam")
        return beam ~= nil and beam:IsA("RemoteEvent")
    end
    getGun = function()
        local character = player.Character
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if isGun(tool) then
                    return tool
                end
            end
        end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if isGun(tool) then
                    return tool
                end
            end
        end
        return nil
    end
end

local function isReloading(weapon)
    if not weapon or not weapon:IsA("Tool") then
        return false
    end
    for _, name in ipairs({
        "Reloading",
        "IsReloading",
        "reloading",
        "isReloading",
        "Reload",
        "reload",
    }) do
        local v = weapon:GetAttribute(name)
        if v == true or v == "true" then
            return true
        end
    end
    for _, child in ipairs(weapon:GetChildren()) do
        if child:IsA("BoolValue") and child.Value == true then
            local n = string.lower(child.Name)
            if string.find(n, "reload") or string.find(n, "recarg") then
                return true
            end
        end
    end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            local animId = track.Animation and track.Animation.AnimationId or ""
            if string.find(string.lower(animId), "reload") then
                return true
            end
        end
    end
    for _, s in ipairs(weapon:GetDescendants()) do
        if s:IsA("Sound") and s.Playing then
            local n = string.lower(s.Name)
            if string.find(n, "reload") or string.find(n, "recarg") then
                return true
            end
        end
    end
    return false
end

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager
function ConnectionManager.new()
    return setmetatable({ Items = {} }, ConnectionManager)
end
function ConnectionManager:Add(task)
    self.Items[#self.Items + 1] = task
    return task
end
function ConnectionManager:Cleanup()
    for i = #self.Items, 1, -1 do
        local item = self.Items[i]
        self.Items[i] = nil
        local t = typeof(item)
        if t == "RBXScriptConnection" then
            pcall(function()
                item:Disconnect()
            end)
        elseif t == "Instance" then
            pcall(function()
                item:Destroy()
            end)
        elseif t == "function" then
            pcall(item)
        end
    end
end

local function clearHitboxes()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        local character = targetPlayer.Character
        if character then
            local hitbox = character:FindFirstChild("GhostHitbox")
            if hitbox then
                hitbox:Destroy()
            end
        end
    end
end

local pxwHitboxWorkerRunning = false
pxwStartHitboxWorker = function()
    if pxwHitboxWorkerRunning or not hitboxEnabled then
        return
    end
    pxwHitboxWorkerRunning = true
    task.spawn(function()
        while hitboxEnabled do
            task.wait(0.2)
            if not hitboxEnabled then
                break
            end
            if not IsInMatchStrict() then
                clearHitboxes()
                continue
            end
            local targetSize = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            local transObjetivo = hitboxInvisible and 1 or 0.6
            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= player and isEnemy(targetPlayer) then
                    local character = targetPlayer.Character
                    if character then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if rootPart and humanoid and humanoid.Health > 0 then
                            local hitbox = character:FindFirstChild("GhostHitbox")
                            if not hitbox then
                                hitbox = Instance.new("Part")
                                hitbox.Name = "GhostHitbox"
                                hitbox.Size = targetSize
                                hitbox.Transparency = transObjetivo
                                hitbox.Color = hitboxColor
                                hitbox.CanCollide = false
                                hitbox.Massless = true
                                hitbox.CanQuery = true
                                hitbox.CFrame = rootPart.CFrame
                                hitbox.Parent = character
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = rootPart
                                weld.Part1 = hitbox
                                weld.Parent = hitbox
                            else
                                if hitbox.Size ~= targetSize then
                                    hitbox.Size = targetSize
                                end
                                if hitbox.Transparency ~= transObjetivo then
                                    hitbox.Transparency = transObjetivo
                                end
                                if hitbox.Color ~= hitboxColor then
                                    hitbox.Color = hitboxColor
                                end
                                if not hitbox.CanQuery then
                                    hitbox.CanQuery = true
                                end
                            end
                        else
                            local hitbox = character:FindFirstChild("GhostHitbox")
                            if hitbox then
                                hitbox:Destroy()
                            end
                        end
                    end
                else
                    local char = targetPlayer.Character
                    if char then
                        local hb = char:FindFirstChild("GhostHitbox")
                        if hb then
                            hb:Destroy()
                        end
                    end
                end
            end
        end
        pxwHitboxWorkerRunning = false
        if not hitboxEnabled then
            clearHitboxes()
        end
    end)
end

local PadZoneConfig = {
    ["Right Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone1", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone2", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone3", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone4", MainPad = "Pad1", AltPad = "Pad2" },
    },
    ["Left Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone5", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone6", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone7", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone8", MainPad = "Pad1", AltPad = "Pad2" },
    },
}

AutoTeleportMainAlt = {}
AutoTeleportMainAlt.__index = AutoTeleportMainAlt

function AutoTeleportMainAlt.new()
    return setmetatable({
        Running = false,
        Connections = ConnectionManager.new(),
        Acc = 0,
        TickInterval = 0.5,
        ActiveRole = nil,
        DuelType = "1v1",
        PlatformRow = "Right Platforms",
        LastTeleport = 0,
        LastVote = 0,
        LastCancel = 0,
        TeleportCooldown = 0.5,
        VoteCooldown = 1,
        CancelCooldown = 1,
        VotedMap = nil,
        HighlightedPad = nil,
        PadColors = {},
    }, AutoTeleportMainAlt)
end

function AutoTeleportMainAlt:GetActiveRole()
    if self.ActiveRole == "Main" then
        return "Main"
    end
    if self.ActiveRole == "Alt" then
        return "Alt"
    end
    return nil
end

function AutoTeleportMainAlt:GetRoot()
    local char = player.Character
    if not char then
        return nil
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        return root
    end
    return nil
end

function AutoTeleportMainAlt:GetHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function AutoTeleportMainAlt:Attr(name)
    local v = player:GetAttribute(name)
    if typeof(v) == "string" and v ~= "" then
        return v
    end
    return nil
end

function AutoTeleportMainAlt:Snapshot()
    local gameAttr = self:Attr("Game")
    local mapAttr = self:Attr("Map")
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local alive = hum ~= nil and hum.Health > 0 and root ~= nil
    return {
        Game = gameAttr,
        Map = mapAttr,
        InGame = gameAttr ~= nil,
        InMap = gameAttr ~= nil and mapAttr ~= nil,
        Alive = alive,
    }
end

function AutoTeleportMainAlt:IsOnMatch()
    local s = self:Snapshot()
    return s and s.InGame == true and s.InMap ~= true and s.Alive
end

function AutoTeleportMainAlt:ResolvePad(role)
    local rowConfig = PadZoneConfig[self.PlatformRow] or PadZoneConfig["Right Platforms"]
    local cfg = rowConfig[self.DuelType] or rowConfig["1v1"]
    local padZones = workspace:FindFirstChild("PadZones")
    if not padZones then
        return nil
    end
    local zone = padZones:FindFirstChild(cfg.ZoneName)
    if not zone then
        return nil
    end
    local padName = (role == "Alt") and cfg.AltPad or cfg.MainPad
    local holder = zone:FindFirstChild(padName)
    if not holder then
        return nil
    end
    local pad = holder:FindFirstChild("Pad")
    if pad and pad:IsA("BasePart") then
        return pad
    end
    return nil
end

function AutoTeleportMainAlt:IsOnPad(pad)
    if not pad then
        return false
    end
    local root = self:GetRoot()
    if not root then
        return false
    end
    local rel = pad.CFrame:PointToObjectSpace(root.Position)
    local half = pad.Size / 2
    return math.abs(rel.X) <= half.X + 0.5
        and math.abs(rel.Z) <= half.Z + 0.5
        and rel.Y >= -(half.Y + 6)
        and rel.Y <= half.Y + 14
end

function AutoTeleportMainAlt:MarkPad(pad, isAlt)
    if not pad then
        self:UnmarkPad()
        return
    end
    if self.HighlightedPad == pad then
        return
    end
    self:UnmarkPad()
    self.HighlightedPad = pad
    self.PadColors[pad] = { Color = pad.Color, Transparency = pad.Transparency }
    pcall(function()
        pad.Color = isAlt and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 145, 255)
        pad.Transparency = 0.5
    end)
end

function AutoTeleportMainAlt:UnmarkPad()
    if self.HighlightedPad and self.PadColors[self.HighlightedPad] then
        local pad = self.HighlightedPad
        local saved = self.PadColors[pad]
        pcall(function()
            if pad.Parent then
                pad.Color = saved.Color
                pad.Transparency = saved.Transparency
            end
        end)
    end
    self.HighlightedPad = nil
end

function AutoTeleportMainAlt:FindVoteRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net = pkgs and pkgs:FindFirstChild("Networking")
    local r = net and net:FindFirstChild("RF/Voting/Vote")
    if r and r:IsA("RemoteFunction") then
        return r
    end
    return nil
end

function AutoTeleportMainAlt:FindVisibleMapVote()
    local pg = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local mv = main and main:FindFirstChild("MapVoting")
    local holder = mv and mv:FindFirstChild("VotingHolder")
    if not holder then
        return nil
    end
    for _, b in ipairs(holder:GetChildren()) do
        if b:IsA("ImageButton") and b.Visible and b.Name ~= "" then
            return b.Name
        end
    end
    return nil
end

function AutoTeleportMainAlt:VoteMap()
    local s = self:Snapshot()
    if not self:IsOnMatch() then
        return
    end
    if self.VotedMap == s.Game then
        return
    end
    local now = os.clock()
    if now - (self.LastVote or 0) < self.VoteCooldown then
        return
    end
    self.LastVote = now
    local target = self:FindVisibleMapVote()
    local rf = self:FindVoteRemote()
    if not (target and rf) then
        return
    end
    self.VotedMap = s.Game
    pcall(function()
        rf:InvokeServer(target)
    end)
end

function AutoTeleportMainAlt:FindSetStateRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net = pkgs and pkgs:FindFirstChild("Networking")
    local r = net and net:FindFirstChild("RE/Match/SetStatePlr")
    if r and r:IsA("RemoteEvent") then
        return r
    end
    return nil
end

function AutoTeleportMainAlt:CancelQueue()
    local now = os.clock()
    if now - (self.LastCancel or 0) < self.CancelCooldown then
        return
    end
    local ev = self:FindSetStateRemote()
    if not ev then
        return
    end
    self.LastCancel = now
    pcall(function()
        ev:FireServer("REMOVE")
    end)
end

function AutoTeleportMainAlt:HideGameFrame()
    local pg = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local mgf = main and main:FindFirstChild("MainGameFrame")
    if mgf and mgf:IsA("GuiObject") then
        pcall(function()
            mgf.Visible = false
        end)
    end
end

function AutoTeleportMainAlt:HoldCenter()
    local hum = self:GetHumanoid()
    local root = self:GetRoot()
    if hum and root then
        pcall(function()
            hum:MoveTo(root.Position)
        end)
    end
end

function AutoTeleportMainAlt:Teleport(pad)
    if not pad then
        return
    end
    local root = self:GetRoot()
    local hum = self:GetHumanoid()
    if not (root and hum) then
        return
    end
    pcall(function()
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        self:CancelQueue()
        self:HideGameFrame()
        hum:MoveTo(pad.Position)
    end)
end

function AutoTeleportMainAlt:Process()
    if not self.Running then
        return
    end
    local s = self:Snapshot()
    if s.InGame then
        self:UnmarkPad()
        self:HoldCenter()
        self:VoteMap()
        return
    end
    local role = self:GetActiveRole()
    if not role then
        self:UnmarkPad()
        return
    end
    local pad = self:ResolvePad(role)
    self:MarkPad(pad, role == "Alt")
    if not pad then
        return
    end
    if self:IsOnPad(pad) then
        return
    end
    local now = os.clock()
    if now - (self.LastTeleport or 0) < self.TeleportCooldown then
        return
    end
    self.LastTeleport = now
    self:Teleport(pad)
end

function AutoTeleportMainAlt:Kick()
    if self.Running then
        self:Process()
    end
end

function AutoTeleportMainAlt:Start()
    if self.Running then
        return
    end
    self.Running = true
    self.Acc = 0
    self.LastTeleport = 0
    self.LastVote = 0
    self.LastCancel = 0
    self.Connections:Add(player:GetAttributeChangedSignal("Game"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))
    self.Connections:Add(player:GetAttributeChangedSignal("Map"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))
    self.Connections:Add(player:GetAttributeChangedSignal("Team"):Connect(function()
        task.defer(function()
            if self.Running then
                self:Process()
            end
        end)
    end))
    self.Connections:Add(RunService.Heartbeat:Connect(function(dt)
        if not self.Running then
            return
        end
        self.Acc = self.Acc + dt
        if self.Acc >= self.TickInterval then
            self.Acc = 0
            self:Process()
        end
    end))
    self:Process()
end

function AutoTeleportMainAlt:Stop()
    if not self.Running then
        return
    end
    self.Running = false
    self.Connections:Cleanup()
    self.Connections = ConnectionManager.new()
    self:UnmarkPad()
    self.VotedMap = nil
end

AutoTeleportMainAltInstance = AutoTeleportMainAlt.new()

local function IsRoundTimerActive()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then
        return false
    end
    local main = gui:FindFirstChild("Main") or gui
    local gameFrame = main:FindFirstChild("MainGameFrame")
    if not gameFrame or not gameFrame.Visible then
        return false
    end
    local score = gameFrame:FindFirstChild("IngameScore")
    local timer = score and score:FindFirstChild("Timer")
    if not timer then
        return false
    end
    if not (timer:IsA("TextLabel") or timer:IsA("TextButton") or timer:IsA("TextBox")) then
        return false
    end
    local txt = tostring(timer.Text or ""):gsub("%s", "")
    if txt == "" then
        return false
    end
    if string.find(txt, "-") then
        return false
    end
    if txt == "0:00" or txt == "00:00" or txt == "0:0" then
        return false
    end
    return txt:match("^%d+:%d%d$") ~= nil
end

do
    local KILLALL_MOVE_SPEED = 39.9
    local KILLALL_APPROACH_DISTANCE = 2.5
    local KILLALL_APPROACH_TOLERANCE = 0.35
    local KILLALL_SWING_INTERVAL = 0.5
    local KILLALL_SAFE_GROUND_THRESHOLD = 3
    local KILLALL_STICK_MAX_TIME = 2.5
    local KILLALL_STICK_MAX_DISTANCE = 20
    local KILLALL_VOID_PROTECTION = 15
    local KILLALL_HEALTH_STALL_TIME = 1.5
    local KILLALL_TARGET_GRACE_TIME = 1.2
    local KILLALL_PITCH_DEGREES = 90
    local KILLALL_HEIGHT_OFFSET = 1.9
    local KILLALL_HIDE_DEPTH = 4
    local KILLALL_HIDE_DURATION = 0.5
    local KILLALL_KNIFE_RANGE_Y = 4.5
    local KILLALL_JITTER_AMPLITUDE = 0.8
    local KILLALL_JITTER_SWITCH_MIN = 0.05
    local KILLALL_JITTER_SWITCH_MAX = 0.12
    local KILLALL_JITTER_LERP_SPEED = 25
    local KILLALL_UNDERGROUND_DEPTH = 5
    local KILLALL_UNDERGROUND_TOLERANCE = 1.5
    local KILLALL_TRIGGER_RADIUS = 6.0
    local KILLALL_VALIDATION_TOLERANCE = 1.0
    local KILLALL_VALIDATION_FRAMES = 3

    local KillAll = {}
    KillAll.__index = KillAll

    function KillAll.new()
        return setmetatable({
            running = false,
            connections = ConnectionManager.new(),
            savedCollisions = {},
            swingAccumulator = 0,
            safePosition = nil,
            sticking = false,
            stickingStartTime = 0,
            lastEnemyHealth = nil,
            lastHealthChangeTime = 0,
            lastTargetSeenTime = 0,
            currentTarget = nil,
            lockedTargetPlayer = nil,
            lastStickTarget = nil,
            lastStickTargetHum = nil,
            hiding = false,
            hidingUntil = 0,
            targetFloor = nil,
            targetFloorY = nil,
            lastFloorTarget = nil,
            inKnifeRangeNow = false,
            forceDescent = false,
            jitterSide = 1,
            jitterCurrent = 0,
            jitterNextSwitch = 0,
            lastSetCFrame = nil,
            validFrames = 0,
            killActivated = false,
        }, KillAll)
    end

    function KillAll:DisableCollisions()
        local char = player.Character
        if not char then
            return
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if self.savedCollisions[part] == nil then
                    self.savedCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    function KillAll:RestoreCollisions()
        for part, value in pairs(self.savedCollisions) do
            if part.Parent then
                pcall(function()
                    part.CanCollide = value
                end)
            end
        end
        table.clear(self.savedCollisions)
    end

    function KillAll:GetRoot(p)
        local char = p and p.Character
        if not char then
            return nil
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        return nil
    end

    function KillAll:GetHumanoid(p)
        local char = p and p.Character
        return char and char:FindFirstChildOfClass("Humanoid") or nil
    end

    function KillAll:GetFloorY(targetRoot)
        local hum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        local hip = hum and tonumber(hum.HipHeight) or 2
        return targetRoot.Position.Y - hip - targetRoot.Size.Y / 2
    end

    function KillAll:GetPlatformFloorY(targetRoot)
        if not targetRoot then
            return nil
        end
        if self.lastFloorTarget == targetRoot and self.targetFloorY then
            return self.targetFloorY
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { player.Character, targetRoot.Parent }
        local origin = targetRoot.Position + Vector3.new(0, 3, 0)
        local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
        if result then
            self.targetFloorY = result.Position.Y
            self.lastFloorTarget = targetRoot
            return self.targetFloorY
        end
        self.targetFloorY = self:GetFloorY(targetRoot)
        self.lastFloorTarget = targetRoot
        return self.targetFloorY
    end

    function KillAll:IsInKnifeRange(myRoot, targetRoot)
        if not myRoot or not targetRoot then
            return false
        end
        local delta = targetRoot.Position - myRoot.Position
        local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude
        local vertical = math.abs(delta.Y)
        return horizontal <= (KILLALL_APPROACH_DISTANCE + KILLALL_APPROACH_TOLERANCE)
            and vertical <= KILLALL_KNIFE_RANGE_Y
    end

    function KillAll:IsLockedTargetValid()
        local lp = self.lockedTargetPlayer
        if not lp then
            return false
        end
        if not lp.Parent then
            return false
        end
        if not isValidEnemy(lp) then
            return false
        end
        local char = lp.Character
        if not char then
            return false
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then
            return false
        end
        if hum.Health <= 0 then
            return false
        end
        return root
    end

    function KillAll:GetClosestEnemy()
        local myRoot = self:GetRoot(player)
        if not myRoot then
            return nil
        end
        local lockedRoot = self:IsLockedTargetValid()
        if lockedRoot then
            return lockedRoot
        end
        self.lockedTargetPlayer = nil
        self.currentTarget = nil
        local best, bestDist, bestPlayer = nil, nil, nil
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and isValidEnemy(other) then
                local hum = self:GetHumanoid(other)
                local root = self:GetRoot(other)
                if root and hum and hum.Health > 0 then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if not bestDist or dist < bestDist then
                        best, bestDist, bestPlayer = root, dist, other
                    end
                end
            end
        end
        if bestPlayer then
            self.lockedTargetPlayer = bestPlayer
        end
        return best
    end

    function KillAll:IsInMatch()
        return IsRoundTimerActive()
    end

    function KillAll:ResetState()
        self.sticking = false
        self.stickingStartTime = 0
        self.lastEnemyHealth = nil
        self.lastHealthChangeTime = 0
        self.targetFloor = nil
        self.inKnifeRangeNow = false
        self.forceDescent = false
        self.jitterSide = 1
        self.jitterCurrent = 0
        self.jitterNextSwitch = 0
        self.lastSetCFrame = nil
        self.validFrames = 0
        self.killActivated = false
        self:RestoreCollisions()
        local hum = self:GetHumanoid(player)
        if hum and hum.PlatformStand then
            pcall(function()
                hum.PlatformStand = false
            end)
        end
    end

    function KillAll:ReturnToSafePosition(myRoot)
        if not self.safePosition or not myRoot then
            return
        end
        local currentY = myRoot.Position.Y
        if currentY < (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD) then
            pcall(function()
                myRoot.CFrame = CFrame.new(self.safePosition)
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end

    function KillAll:ForceReturnToSafe(myRoot)
        if not self.safePosition or not myRoot then
            return
        end
        pcall(function()
            myRoot.CFrame = CFrame.new(self.safePosition)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    function KillAll:IsFallingIntoVoid(myRoot)
        if not self.safePosition or not myRoot then
            return false
        end
        return myRoot.Position.Y < (self.safePosition.Y - KILLALL_VOID_PROTECTION)
    end

    function KillAll:HideBelowMap()
        local myRoot = self:GetRoot(player)
        if not myRoot then
            return
        end
        local baseY = self.safePosition and self.safePosition.Y or myRoot.Position.Y
        local hideY = baseY - KILLALL_HIDE_DEPTH
        local currentX, currentZ = myRoot.Position.X, myRoot.Position.Z
        pcall(function()
            myRoot.CFrame = CFrame.new(currentX, hideY, currentZ)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
        self.hiding = true
        self.hidingUntil = os.clock() + KILLALL_HIDE_DURATION
    end

    function KillAll:IsKnife(tool)
        if not (tool and tool:IsA("Tool")) then
            return false
        end
        if tool:FindFirstChild("fire") or tool:FindFirstChild("showBeam") then
            return false
        end
        return tool:FindFirstChild("Slash") ~= nil or tool:FindFirstChild("SlashStart") ~= nil
    end

    function KillAll:FindKnife()
        local char = player.Character
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if self:IsKnife(child) then
                    return child, true
                end
            end
        end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if self:IsKnife(child) then
                    return child, false
                end
            end
        end
        return nil, false
    end

    function KillAll:SwingKnife(dt)
        self.swingAccumulator = self.swingAccumulator + dt
        if self.swingAccumulator < KILLALL_SWING_INTERVAL then
            return
        end
        self.swingAccumulator = 0
        local tool, equipped = self:FindKnife()
        if not tool then
            return
        end
        if not equipped then
            local hum = self:GetHumanoid(player)
            if not hum then
                return
            end
            pcall(function()
                hum:EquipTool(tool)
            end)
            if tool.Parent ~= player.Character then
                return
            end
        end
        pcall(function()
            tool:Activate()
        end)
    end

    function KillAll:UpdateJitter(dt)
        local now = os.clock()
        if now >= self.jitterNextSwitch then
            self.jitterSide = (math.random() < 0.5) and 1 or -1
            self.jitterNextSwitch = now
                + KILLALL_JITTER_SWITCH_MIN
                + math.random() * (KILLALL_JITTER_SWITCH_MAX - KILLALL_JITTER_SWITCH_MIN)
        end
        local targetOffset = self.jitterSide * KILLALL_JITTER_AMPLITUDE
        self.jitterCurrent = self.jitterCurrent
            + (targetOffset - self.jitterCurrent)
                * math.clamp(dt * KILLALL_JITTER_LERP_SPEED, 0, 1)
    end

    function KillAll:CheckServerValidation(myRoot)
        if self.killActivated then
            return true
        end
        if not self.lastSetCFrame then
            return false
        end
        local desiredPos = self.lastSetCFrame.Position
        local actualPos = myRoot.Position
        local diff = (actualPos - desiredPos).Magnitude
        if diff <= KILLALL_VALIDATION_TOLERANCE then
            self.validFrames = self.validFrames + 1
            if self.validFrames >= KILLALL_VALIDATION_FRAMES then
                self.killActivated = true
                self.swingAccumulator = KILLALL_SWING_INTERVAL
                return true
            end
        else
            self.validFrames = 0
        end
        return false
    end

    function KillAll:ForceUnderground(myRoot, targetRoot)
        if not myRoot or not targetRoot then
            return
        end
        local floorY = self:GetPlatformFloorY(targetRoot)
        if not floorY then
            return
        end
        local targetY = floorY - KILLALL_UNDERGROUND_DEPTH
        if myRoot.Position.Y > targetY + KILLALL_UNDERGROUND_TOLERANCE then
            pcall(function()
                myRoot.CFrame = CFrame.new(myRoot.Position.X, targetY, myRoot.Position.Z)
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end

    function KillAll:ApproachTarget(myRoot, targetRoot, dt)
        dt = dt or 0
        local myPos = myRoot.Position
        local targetPos = targetRoot.Position
        local deltaXZ = Vector3.new(targetPos.X - myPos.X, 0, targetPos.Z - myPos.Z)
        local hDist = deltaXZ.Magnitude
        if hDist <= KILLALL_TRIGGER_RADIUS then
            if not self.sticking then
                local lookTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
                local targetCF = CFrame.lookAt(myPos, lookTarget)
                self.lastSetCFrame = targetCF
                pcall(function()
                    myRoot.CFrame = targetCF
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end)
                if self:CheckServerValidation(myRoot) then
                    self.sticking = true
                    self.stickingStartTime = os.clock()
                    self.lastStickTarget = targetRoot
                    self.targetFloor = nil
                    self.forceDescent = true
                    local hum = self:GetHumanoid(targetRoot.Parent)
                    self.lastEnemyHealth = hum and hum.Health or nil
                    self.lastHealthChangeTime = os.clock()
                    self.lastStickTargetHum = hum
                    self.jitterCurrent = 0
                end
            end
            return
        end
        self.lastSetCFrame = nil
        self.validFrames = 0
        local dir = deltaXZ.Unit
        local perp = Vector3.new(-dir.Z, 0, dir.X)
        self:UpdateJitter(dt)
        local step = KILLALL_MOVE_SPEED * dt
        local travel = math.min(step, math.max(0, hDist - KILLALL_TRIGGER_RADIUS))
        local maxJitterByDistance = math.sqrt(math.max(0, travel * (2 * hDist - travel))) * 0.85
        local jitterFactor = math.clamp((hDist - KILLALL_TRIGGER_RADIUS) / 8, 0, 1)
        local desiredJitter = self.jitterCurrent * jitterFactor
        local actualJitter = math.clamp(desiredJitter, -maxJitterByDistance, maxJitterByDistance)
        local baseX = myPos.X + dir.X * travel
        local baseZ = myPos.Z + dir.Z * travel
        local newX = baseX + perp.X * actualJitter
        local newZ = baseZ + perp.Z * actualJitter
        local floorY = self:GetPlatformFloorY(targetRoot)
        local newY
        if floorY then
            newY = floorY - KILLALL_UNDERGROUND_DEPTH
        else
            newY = myPos.Y
        end
        local newPos = Vector3.new(newX, newY, newZ)
        local lookTarget = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
        local newCFrame = CFrame.lookAt(newPos, lookTarget)
        pcall(function()
            myRoot.CFrame = newCFrame
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    function KillAll:CanStickToTarget(myRoot, targetRoot)
        if not targetRoot or not targetRoot.Parent then
            return false
        end
        local targetPlayer = Players:GetPlayerFromCharacter(targetRoot.Parent)
        if not targetPlayer or not isValidEnemy(targetPlayer) then
            return false
        end
        local targetHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then
            return false
        end
        local distHorizontal = (Vector3.new(myRoot.Position.X, 0, myRoot.Position.Z) - Vector3.new(
            targetRoot.Position.X,
            0,
            targetRoot.Position.Z
        )).Magnitude
        if distHorizontal > KILLALL_STICK_MAX_DISTANCE then
            return false
        end
        return true
    end

    function KillAll:StickToTarget(myRoot, targetRoot)
        local targetPos = targetRoot.Position
        local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        local onGround = targetHum and targetHum.FloorMaterial ~= Enum.Material.Air
        if targetRoot ~= self.lastStickTarget then
            self.lastStickTarget = targetRoot
            self.targetFloor = nil
        end
        if onGround or not self.targetFloor then
            self.targetFloor = self:GetFloorY(targetRoot)
        end
        local myPos = myRoot.Position
        local dir = Vector3.new(myPos.X - targetPos.X, 0, myPos.Z - targetPos.Z)
        if dir.Magnitude < 0.05 then
            dir = Vector3.new(0, 0, 1)
        else
            dir = dir.Unit
        end
        local x = targetPos.X + dir.X * KILLALL_APPROACH_DISTANCE
        local z = targetPos.Z + dir.Z * KILLALL_APPROACH_DISTANCE
        local inRange = self:IsInKnifeRange(myRoot, targetRoot)
        local y
        if inRange and not self.forceDescent then
            y = myPos.Y
        else
            y = self.targetFloor - KILLALL_HEIGHT_OFFSET
            if inRange then
                self.forceDescent = false
            end
        end
        pcall(function()
            myRoot.CFrame = CFrame.new(x, y, z)
                * CFrame.Angles(math.rad(KILLALL_PITCH_DEGREES), 0, 0)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    function KillAll:CheckEnemyHealth(targetRoot)
        local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
        if not targetHum then
            return false
        end
        local currentHealth = targetHum.Health
        if self.lastEnemyHealth == nil then
            self.lastEnemyHealth = currentHealth
            self.lastHealthChangeTime = os.clock()
            return false
        end
        if currentHealth < self.lastEnemyHealth then
            self.lastEnemyHealth = currentHealth
            self.lastHealthChangeTime = os.clock()
            return false
        end
        if (os.clock() - self.lastHealthChangeTime) >= KILLALL_HEALTH_STALL_TIME then
            return true
        end
        return false
    end

    function KillAll:Update(dt)
        if not self:IsInMatch() then
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            self.lastFloorTarget = nil
            self.targetFloorY = nil
            return
        end
        local myRoot = self:GetRoot(player)
        if not myRoot then
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            return
        end
        if self.lastStickTargetHum then
            local hum = self.lastStickTargetHum
            if not hum.Parent or hum.Health <= 0 then
                self:HideBelowMap()
                self.inKnifeRangeNow = false
                self.forceDescent = false
                self.lastStickTargetHum = nil
                self.lastStickTarget = nil
                self.sticking = false
                self.stickingStartTime = 0
                self.lastEnemyHealth = nil
                self.lastHealthChangeTime = 0
                self.targetFloor = nil
                self.killActivated = false
                self.validFrames = 0
                self.lastSetCFrame = nil
                return
            end
        end
        if self.hiding then
            if os.clock() >= self.hidingUntil then
                self.hiding = false
            else
                pcall(function()
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
        end
        if self:IsFallingIntoVoid(myRoot) then
            self:ForceReturnToSafe(myRoot)
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            local hum = self:GetHumanoid(player)
            if hum then
                pcall(function()
                    hum.PlatformStand = false
                end)
            end
            return
        end
        local target = self:GetClosestEnemy()
        if target then
            self.currentTarget = target
            self.lastTargetSeenTime = os.clock()
        end
        if not target then
            local justLostTarget = (os.clock() - (self.lastTargetSeenTime or 0))
                < KILLALL_TARGET_GRACE_TIME
            local isUnderground = self.safePosition
                and myRoot.Position.Y < (self.safePosition.Y - 2)
            if justLostTarget and isUnderground then
                pcall(function()
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
            self:ReturnToSafePosition(myRoot)
            self:ResetState()
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            self.lastFloorTarget = nil
            self.targetFloorY = nil
            if self.safePosition then
                local hum = self:GetHumanoid(player)
                if hum then
                    pcall(function()
                        hum.PlatformStand = false
                    end)
                end
            end
            return
        end
        self:DisableCollisions()
        if self.lastStickTarget then
            local inRange = self:IsInKnifeRange(myRoot, self.lastStickTarget)
            if inRange and not self.inKnifeRangeNow then
                self.swingAccumulator = KILLALL_SWING_INTERVAL
                self.inKnifeRangeNow = true
            elseif not inRange then
                self.inKnifeRangeNow = false
            end
        end
        self:SwingKnife(dt or 0)
        local hum = self:GetHumanoid(player)
        if hum and not hum.PlatformStand then
            pcall(function()
                hum.PlatformStand = true
            end)
        end
        if
            self.safePosition
            and myRoot.Position.Y >= (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD)
        then
            self.safePosition =
                Vector3.new(myRoot.Position.X, self.safePosition.Y, myRoot.Position.Z)
        end
        if not self.sticking then
            self:ForceUnderground(myRoot, target)
        end
        if self.sticking then
            local lostTarget = (target ~= self.lastStickTarget)
            local timedOut = (os.clock() - self.stickingStartTime) > KILLALL_STICK_MAX_TIME
            local cannotStick = not self:CanStickToTarget(myRoot, target)
            local cannotKill = self:CheckEnemyHealth(target)
            if lostTarget or timedOut or cannotStick or cannotKill then
                self.sticking = false
                self.stickingStartTime = 0
                self.lastEnemyHealth = nil
                self.lastHealthChangeTime = 0
                self.targetFloor = nil
                self.inKnifeRangeNow = false
                self.forceDescent = false
                self.killActivated = false
                self.validFrames = 0
                self.lastSetCFrame = nil
                if lostTarget then
                    self.lastStickTarget = nil
                end
            else
                self:StickToTarget(myRoot, target)
                return
            end
        end
        self:ApproachTarget(myRoot, target, dt or 0)
    end

    function KillAll:Start()
        if self.running then
            return
        end
        self.running = true
        self.swingAccumulator = 0
        self.sticking = false
        self.stickingStartTime = 0
        self.lastEnemyHealth = nil
        self.lastHealthChangeTime = 0
        self.lastTargetSeenTime = 0
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastStickTargetHum = nil
        self.hiding = false
        self.hidingUntil = 0
        self.targetFloor = nil
        self.targetFloorY = nil
        self.lastFloorTarget = nil
        self.inKnifeRangeNow = false
        self.forceDescent = false
        self.jitterSide = 1
        self.jitterCurrent = 0
        self.jitterNextSwitch = 0
        self.lastSetCFrame = nil
        self.validFrames = 0
        self.killActivated = false
        local myRoot = self:GetRoot(player)
        if myRoot then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { player.Character }
            local origin = myRoot.Position + Vector3.new(0, 5, 0)
            local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
            if result then
                self.safePosition =
                    Vector3.new(myRoot.Position.X, result.Position.Y + 3, myRoot.Position.Z)
            else
                self.safePosition = myRoot.Position
            end
        else
            self.safePosition = nil
        end
        self.connections:Add(RunService.Heartbeat:Connect(function(dt)
            if not self.running then
                return
            end
            self:Update(dt)
        end))
        self.connections:Add(player.CharacterAdded:Connect(function()
            table.clear(self.savedCollisions)
            self.sticking = false
            self.safePosition = nil
            self.stickingStartTime = 0
            self.lastEnemyHealth = nil
            self.lastHealthChangeTime = 0
            self.lastTargetSeenTime = 0
            self.currentTarget = nil
            self.lockedTargetPlayer = nil
            self.lastStickTarget = nil
            self.lastStickTargetHum = nil
            self.hiding = false
            self.hidingUntil = 0
            self.targetFloor = nil
            self.targetFloorY = nil
            self.lastFloorTarget = nil
            self.inKnifeRangeNow = false
            self.forceDescent = false
            self.jitterSide = 1
            self.jitterCurrent = 0
            self.jitterNextSwitch = 0
            self.lastSetCFrame = nil
            self.validFrames = 0
            self.killActivated = false
        end))
    end

    function KillAll:Stop()
        if not self.running then
            return
        end
        local myRoot = self:GetRoot(player)
        if myRoot and self.safePosition then
            pcall(function()
                myRoot.CFrame = CFrame.new(self.safePosition)
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        self.running = false
        self.connections:Cleanup()
        self.connections = ConnectionManager.new()
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastStickTargetHum = nil
        self.hiding = false
        self.hidingUntil = 0
        self.inKnifeRangeNow = false
        self.forceDescent = false
        self.killActivated = false
        self.targetFloorY = nil
        self.lastFloorTarget = nil
    end

    KillAllInstance = KillAll.new()
end

PXW.Section("Extras", { Title = "Extra Scripts", Icon = "code" })
PXW.Button("Extras", {
    Text = "Copy Avatars",
    Icon = "users",
    Primary = true,
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/5MA88wuB"))()
        end)
    end,
})

task.wait()

PXW.Section("Aim", { Title = "Auto Shoot", Icon = "crosshair" })

UIElements.TogAutoShoot = PXW.Toggle("Aim", {
    Text = "Auto Shoot (Normal - Head/Torso)",
    Description = "Fires automatically at head or torso.",
    Callback = function(Value)
        autoShootEnabled = Value
        if
            not Value
            and not autoShootEnabled
            and not autoShootAggressiveEnabled
            and pxwSetAimTarget
        then
            pxwSetAimTarget("Auto", nil)
        end
        if pxwUpdateTargetFeatures then
            pxwUpdateTargetFeatures()
        end
    end,
})

UIElements.TogAutoShootAgr = PXW.Toggle("Aim", {
    Text = "Auto Shoot (Aggressive - Full Hitbox)",
    Description = "Fires automatically at the full hitbox.",
    Callback = function(Value)
        autoShootAggressiveEnabled = Value
        if
            not Value
            and not autoShootEnabled
            and not autoShootAggressiveEnabled
            and pxwSetAimTarget
        then
            pxwSetAimTarget("Auto", nil)
        end
        if pxwUpdateTargetFeatures then
            pxwUpdateTargetFeatures()
        end
    end,
})

UIElements.DropAutoShootPart = PXW.Dropdown("Aim", {
    Text = "Auto Shoot Target Part",
    Options = { "Head", "Torso", "Full Body" },
    Default = "Head",
    Callback = function(Value)
        autoShootTargetPart = Value
    end,
})

UIElements.TogEquipGun = PXW.Toggle("Aim", {
    Text = "Equip Gun",
    Description = "Keeps your gun equipped.",
    Default = false,
    Callback = function(Value)
        equipGunEnabled = Value
        if pxwUpdateTargetFeatures then
            pxwUpdateTargetFeatures()
        end
    end,
})

local pxwEquipWorkerRunning = false
pxwStartEquipWorker = function()
    if pxwEquipWorkerRunning or not equipGunEnabled then
        return
    end
    pxwEquipWorkerRunning = true
    task.spawn(function()
        local gunRayParams = RaycastParams.new()
        gunRayParams.FilterType = Enum.RaycastFilterType.Exclude
        while equipGunEnabled do
            task.wait(0.1)
            if not equipGunEnabled then
                break
            end
            if not IsInMatchStrict() then
                continue
            end
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum then
                continue
            end
            if hum.Health <= 0 then
                continue
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if not hrp then
                continue
            end
            local originPos = head and head.Position or hrp.Position
            local hasVisibleEnemy = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and isValidEnemy(p) then
                    local pChar = p.Character
                    if pChar then
                        local targetPart = pChar:FindFirstChild("Head")
                            or pChar:FindFirstChild("UpperTorso")
                            or pChar:FindFirstChild("Torso")
                            or pChar:FindFirstChild("HumanoidRootPart")
                        if targetPart and targetPart:IsA("BasePart") then
                            gunRayParams.FilterDescendantsInstances = { char, pChar }
                            local result = workspace:Raycast(
                                originPos,
                                targetPart.Position - originPos,
                                gunRayParams
                            )
                            if not result and IsInMatchStrict() then
                                hasVisibleEnemy = true
                                break
                            end
                        end
                    end
                end
            end
            if not hasVisibleEnemy then
                continue
            end
            local gun = getGun()
            if not gun then
                continue
            end
            char = player.Character
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum then
                continue
            end
            gun = getGun()
            if not gun then
                continue
            end
            if gun.Parent ~= char then
                pcall(function()
                    hum:EquipTool(gun)
                end)
            end
            task.wait(0.35)
            if not equipGunEnabled then
                break
            end
            char = player.Character
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum then
                pcall(function()
                    hum:UnequipTools()
                end)
            end
            task.wait(1.9)
        end
        pxwEquipWorkerRunning = false
    end)
end


PXW.Section("Aim", { Title = "Silent Aim + FOV", Icon = "radar" })

UIElements.TogSilentAimManual = PXW.Toggle("Aim", {
    Text = "Silent Aim",
    Description = "Redirects your shots to a target.",
    Callback = function(Value)
        silentAimManualEnabled = Value
        if
            not Value
            and not silentAimManualEnabled
            and not silentAimFovEnabled
            and pxwSetAimTarget
        then
            pxwSetAimTarget("Silent", nil)
        end
        if pxwUpdateTargetFeatures then
            pxwUpdateTargetFeatures()
        end
    end,
})

UIElements.DropSilentAimPart = PXW.Dropdown("Aim", {
    Text = "Silent Aim Target Part",
    Options = { "Head", "Torso", "Full Body" },
    Default = "Head",
    Callback = function(Value)
        silentAimTargetPart = Value
    end,
})

UIElements.TogSilentAimFOV = PXW.Toggle("Aim", {
    Text = "Silent Aim (With FOV)",
    Description = "Silent aim limited to the FOV circle.",
    Callback = function(Value)
        silentAimFovEnabled = Value
        if
            not Value
            and not silentAimManualEnabled
            and not silentAimFovEnabled
            and pxwSetAimTarget
        then
            pxwSetAimTarget("Silent", nil)
        end
        if pxwUpdateTargetFeatures then
            pxwUpdateTargetFeatures()
        end
    end,
})

UIElements.TogShowFOV = PXW.Toggle("Aim", {
    Text = "Show FOV Circle",
    Description = "Draws the FOV circle on screen.",
    Callback = function(Value)
        fovVisiblePreference = Value
        if pxwStartFOVWorker then
            pxwStartFOVWorker()
        end
    end,
})

UIElements.SliFOVSize = PXW.Slider("Aim", {
    Text = "FOV Size",
    Step = 1,
    Min = 10,
    Max = 800,
    Default = 120,
    Callback = function(v)
        fovRadius = v
    end,
})

getgenv().PXWTargetPart = nil
local oldPXWHook = getgenv().__PXWDeferredNamecall
if oldPXWHook then
    oldPXWHook.Enabled = false
end

local pxwMouse = player:GetMouse()
local pxwAimTargets = { Auto = nil, Silent = nil }
local pxwAutoFireUntil = 0
local priorPXWAimCleanup = getgenv().__PXWDuelAimCleanup
if type(priorPXWAimCleanup) == "function" then
    pcall(priorPXWAimCleanup)
end
getgenv().__PXWDuelAimCleanup = nil
local pxwHooks = { Enabled = false, Metatable = nil, IndexHook = nil, NamecallHook = nil }
local pxwIsMadium = false
do
    local identify = type(getexecutorname) == "function" and getexecutorname or identifyexecutor
    if type(identify) == "function" then
        local ok, name = pcall(identify)
        pxwIsMadium = ok and tostring(name):lower():find("madium", 1, true) ~= nil or false
    end
end
local pxwDirectCalls = {}
pcall(function()
    pxwDirectCalls.Raycast = workspace.Raycast
end)
pcall(function()
    pxwDirectCalls.FindPartOnRay = workspace.FindPartOnRay
end)
pcall(function()
    pxwDirectCalls.FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
end)
pcall(function()
    pxwDirectCalls.FindPartOnRayWithWhitelist = workspace.FindPartOnRayWithWhitelist
end)

local function pxwAimActive()
    return autoShootEnabled
        or autoShootAggressiveEnabled
        or silentAimManualEnabled
        or silentAimFovEnabled
end

local function pxwValidTarget(target)
    if typeof(target) ~= "Instance" or not target:IsA("BasePart") or not target.Parent then
        return false
    end
    local character = target:FindFirstAncestorOfClass("Model")
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function pxwSelectedAimTarget()
    local now = os.clock()
    local autoActive = autoShootEnabled or autoShootAggressiveEnabled
    if autoActive and now <= pxwAutoFireUntil and pxwValidTarget(pxwAimTargets.Auto) then
        return pxwAimTargets.Auto
    end
    if
        (silentAimManualEnabled or silentAimFovEnabled)
        and pxwValidTarget(pxwAimTargets.Silent)
    then
        return pxwAimTargets.Silent
    end
    if autoActive and pxwValidTarget(pxwAimTargets.Auto) then
        return pxwAimTargets.Auto
    end
    return nil
end

pxwSetAimTarget = function(source, target)
    if source ~= "Auto" and source ~= "Silent" then
        return
    end
    pxwAimTargets[source] = pxwValidTarget(target) and target or nil
    getgenv().PXWTargetPart = pxwSelectedAimTarget()
end

local function pxwGetAimPoint()
    if not pxwHooks.Enabled or not pxwAimActive() or isInLobby() then
        return nil
    end
    local char = player.Character
    if not char then
        return nil
    end
    local equipped = char:FindFirstChildOfClass("Tool")
    if not isGun(equipped) then
        return nil
    end
    local target = pxwSelectedAimTarget()
    if not target then
        return nil
    end
    return target.Position, target
end

local function pxwLikelyWeaponOrigin(origin)
    if typeof(origin) ~= "Vector3" then
        return false
    end
    local currentCamera = workspace.CurrentCamera
    if currentCamera and (origin - currentCamera.CFrame.Position).Magnitude <= 3 then
        return true
    end
    local character = player.Character
    if not character then
        return false
    end
    local tool = character:FindFirstChildOfClass("Tool")
    local handle = tool and tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") and (origin - handle.Position).Magnitude <= 18 then
        return true
    end
    local head = character:FindFirstChild("Head")
    return head and (origin - head.Position).Magnitude <= 8 or false
end

local function pxwShotOrigin()
    local cam = workspace.CurrentCamera
    local cameraOrigin = cam and cam.CFrame.Position
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if cameraOrigin and head and (cameraOrigin - head.Position).Magnitude <= 1.75 then
        return cameraOrigin
    end
    local tool = char and char:FindFirstChildOfClass("Tool")
    local handle = tool and tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle.Position
    end
    if head then
        return head.Position
    end
    return cameraOrigin
end

local function pxwRestoreHooks()
    pxwHooks.Enabled = false
    local mt = pxwHooks.Metatable
    if not mt or type(setreadonly) ~= "function" then
        return
    end
    local ok = pcall(setreadonly, mt, false)
    if not ok then
        return
    end
    pcall(function()
        if mt.__index == pxwHooks.IndexHook then
            mt.__index = pxwHooks.OriginalIndex
        end
        if pxwHooks.NamecallHook and mt.__namecall == pxwHooks.NamecallHook then
            mt.__namecall = pxwHooks.OriginalNamecall
        end
    end)
    pcall(setreadonly, mt, pxwHooks.WasReadonly)
    if
        mt.__index ~= pxwHooks.IndexHook
        and (not pxwHooks.NamecallHook or mt.__namecall ~= pxwHooks.NamecallHook)
    then
        pxwHooks.Metatable = nil
        pxwHooks.IndexHook = nil
        pxwHooks.NamecallHook = nil
    end
end

getgenv().__PXWDuelAimCleanup = pxwRestoreHooks

local function pxwInstallHooks()
    if pxwHooks.Metatable then
        local mt = pxwHooks.Metatable
        local active = mt.__index == pxwHooks.IndexHook
        pxwHooks.Enabled = active
        return active
    end
    if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function" then
        warn("PXW: this executor does not allow installing the mouse redirection.")
        return false
    end
    local ok, mt = pcall(getrawmetatable, pxwIsMadium and game or pxwMouse)
    if not ok or not mt then
        return false
    end
    local originalIndex, originalNamecall = mt.__index, mt.__namecall
    if type(originalIndex) ~= "function" and type(originalIndex) ~= "table" then
        return false
    end
    local wasReadonly = true
    if type(isreadonly) == "function" then
        local success, readonly = pcall(isreadonly, mt)
        if success and type(readonly) == "boolean" then
            wasReadonly = readonly
        end
    end
    local function originalLookup(self, key)
        if type(originalIndex) == "function" then
            return originalIndex(self, key)
        end
        return originalIndex[key]
    end
    local indexHook = function(self, key)
        if
            pxwHooks.Enabled
            and self == pxwMouse
            and (key == "Hit" or key == "Target" or key == "UnitRay" or (pxwIsMadium and key == "TargetSurface"))
            and (pxwIsMadium or type(checkcaller) ~= "function" or not checkcaller())
        then
            local ok, point, target = pcall(pxwGetAimPoint)
            if ok and point and target then
                if key == "Target" then
                    return target
                end
                if key == "TargetSurface" then
                    return Enum.NormalId.Front
                end
                if key == "Hit" then
                    if pxwIsMadium then
                        return CFrame.new(point)
                    end
                    local origin = pxwShotOrigin()
                    local direction = origin and point - origin
                    if direction and direction.Magnitude > 0.001 then
                        return CFrame.lookAt(point, point + direction.Unit)
                    end
                    return CFrame.new(point)
                end
                local originalRay = originalLookup(self, key)
                local origin = typeof(originalRay) == "Ray" and originalRay.Origin or nil
                if not origin then
                    local cam = workspace.CurrentCamera
                    origin = cam and cam.CFrame.Position or pxwShotOrigin()
                end
                local direction = origin and point - origin
                if direction and direction.Magnitude > 0.001 then
                    return Ray.new(origin, direction.Unit)
                end
            end
        end
        return originalLookup(self, key)
    end
    local namecallHook
    if
        not pxwIsMadium
        and type(originalNamecall) == "function"
        and type(getnamecallmethod) == "function"
        and type(checkcaller) == "function"
    then
        namecallHook = function(self, ...)
            if not pxwHooks.Enabled or checkcaller() then
                return originalNamecall(self, ...)
            end
            if self == workspace and not pxwHooks.ResolvingRay then
                local method = getnamecallmethod()
                local direct = method and pxwDirectCalls[method]
                if direct then
                    local args = table.pack(...)
                    local origin, length
                    if method == "Raycast" then
                        if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                            origin, length = args[1], args[2].Magnitude
                        end
                    elseif typeof(args[1]) == "Ray" then
                        origin, length = args[1].Origin, args[1].Direction.Magnitude
                    end
                    if origin and length and length >= 50 and pxwLikelyWeaponOrigin(origin) then
                        pxwHooks.ResolvingRay = true
                        local success, point = pcall(pxwGetAimPoint)
                        pxwHooks.ResolvingRay = false
                        if success and point then
                            local toward = point - origin
                            if toward.Magnitude > 0.001 then
                                if method == "Raycast" then
                                    args[2] = toward.Unit * length
                                else
                                    args[1] = Ray.new(origin, toward.Unit * length)
                                end
                            end
                        end
                    end
                    return direct(self, table.unpack(args, 1, args.n))
                end
            end
            return originalNamecall(self, ...)
        end
    end
    if not pcall(setreadonly, mt, false) then
        return false
    end
    local installed = pcall(function()
        mt.__index = indexHook
        if namecallHook then
            mt.__namecall = namecallHook
        end
    end)
    if not installed then
        pcall(function()
            if mt.__index == indexHook then
                mt.__index = originalIndex
            end
            if namecallHook and mt.__namecall == namecallHook then
                mt.__namecall = originalNamecall
            end
        end)
        pcall(setreadonly, mt, wasReadonly)
        return false
    end
    pcall(setreadonly, mt, wasReadonly)
    pxwHooks.Metatable = mt
    pxwHooks.OriginalIndex = originalIndex
    pxwHooks.OriginalNamecall = originalNamecall
    pxwHooks.IndexHook = indexHook
    pxwHooks.NamecallHook = namecallHook
    pxwHooks.WasReadonly = wasReadonly
    pxwHooks.Enabled = true
    return true
end

local function pxwUpdateHook()
    if pxwAimActive() then
        pxwInstallHooks()
    else
        pxwAimTargets.Auto = nil
        pxwAimTargets.Silent = nil
        pxwAutoFireUntil = 0
        getgenv().PXWTargetPart = nil
        pxwRestoreHooks()
    end
end
local pxwUpdateTargetWorkers
pxwUpdateTargetFeatures = function()
    pxwRefreshTargetMonitor()
    pxwUpdateHook()
    if pxwUpdateTargetWorkers then
        pxwUpdateTargetWorkers()
    end
end

local pxwAutoShootWorkerRunning = false
pxwStartAutoShootWorker = function()
    if pxwAutoShootWorkerRunning or not (autoShootEnabled or autoShootAggressiveEnabled) then
        return
    end
    pxwAutoShootWorkerRunning = true
    task.spawn(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        while autoShootEnabled or autoShootAggressiveEnabled do
            task.wait(0.1)
            if not (autoShootEnabled or autoShootAggressiveEnabled) then
                break
            end
            if not pxwHooks.Enabled then
                continue
            end
            if not isInLobby() then
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    continue
                end
                local weapon = char:FindFirstChildOfClass("Tool")
                if not weapon or not weapon:FindFirstChild("Handle") then
                    pxwSetAimTarget("Auto", nil)
                    continue
                end
                if not isGun(weapon) then
                    pxwSetAimTarget("Auto", nil)
                    continue
                end
                local closestTargetPart = nil
                local shortestDistance = math.huge
                local myPos = char.HumanoidRootPart.Position
                local head = char:FindFirstChild("Head")
                local headPos = head and head.Position or myPos
                local playersToCheck = {}
                for _, other in ipairs(Players:GetPlayers()) do
                    if other ~= player and isEnemy(other) and other.Character then
                        local enemyCharacter = other.Character
                        local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local root = enemyCharacter:FindFirstChild("HumanoidRootPart")
                            playersToCheck[#playersToCheck + 1] = {
                                Character = enemyCharacter,
                                Distance = root and (root.Position - myPos).Magnitude or math.huge,
                            }
                        end
                    end
                end
                table.sort(playersToCheck, function(a, b)
                    return a.Distance < b.Distance
                end)
                local raycastsRemaining = 192
                local function checkPart(part)
                    if not part or not part:IsA("BasePart") then
                        return
                    end
                    local dist = (part.Position - myPos).Magnitude
                    if dist >= shortestDistance then
                        return
                    end
                    local halfHeight = part.Size.Y / 2.1
                    local cframe = part.CFrame
                    local function visible(point)
                        if raycastsRemaining <= 0 then
                            return false
                        end
                        raycastsRemaining -= 1
                        return not workspace:Raycast(headPos, point - headPos, params)
                    end
                    if
                        visible(part.Position)
                        or visible(cframe * Vector3.new(0, halfHeight, 0))
                        or visible(cframe * Vector3.new(0, -halfHeight, 0))
                    then
                        shortestDistance = dist
                        closestTargetPart = part
                    end
                end
                for _, candidate in ipairs(playersToCheck) do
                    if raycastsRemaining <= 0 then
                        break
                    end
                    local enemyCharacter = candidate.Character
                    if enemyCharacter.Parent then
                        params.FilterDescendantsInstances = { char, enemyCharacter }
                        if autoShootAggressiveEnabled or autoShootTargetPart == "Full Body" then
                            for _, part in ipairs(enemyCharacter:GetChildren()) do
                                if raycastsRemaining <= 0 then
                                    break
                                end
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    checkPart(part)
                                end
                            end
                        elseif autoShootTargetPart == "Head" then
                            checkPart(enemyCharacter:FindFirstChild("Head"))
                        elseif autoShootTargetPart == "Torso" then
                            for _, partName in ipairs({ "UpperTorso", "Torso", "HumanoidRootPart" }) do
                                if raycastsRemaining <= 0 then
                                    break
                                end
                                checkPart(enemyCharacter:FindFirstChild(partName))
                            end
                        end
                    end
                end
                if closestTargetPart then
                    pxwAutoFireUntil = os.clock() + 0.35
                    pxwSetAimTarget("Auto", closestTargetPart)
                    pcall(function()
                        weapon:Activate()
                        task.delay(0.05, function()
                            if weapon.Parent == char then
                                weapon:Deactivate()
                            end
                        end)
                    end)
                    task.wait(0.2)
                else
                    pxwSetAimTarget("Auto", nil)
                end
            end
        end
        pxwSetAimTarget("Auto", nil)
        pxwAutoShootWorkerRunning = false
    end)
end

local pxwSilentWorkerRunning = false
pxwStartSilentAimWorker = function()
    if pxwSilentWorkerRunning or not (silentAimManualEnabled or silentAimFovEnabled) then
        return
    end
    pxwSilentWorkerRunning = true
    task.spawn(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        while silentAimManualEnabled or silentAimFovEnabled do
            task.wait(0.1)
            if not (silentAimManualEnabled or silentAimFovEnabled) then
                break
            end
            if not isInLobby() then
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    continue
                end
                local closestTargetPart = nil
                local shortestDistToCenter = math.huge
                local shortestDistanceFisica = math.huge
                local myPos = char.HumanoidRootPart.Position
                local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and isEnemy(p) and p.Character then
                        local enemyHum = p.Character:FindFirstChild("Humanoid")
                        if enemyHum and enemyHum.Health > 0 then
                            local partesAEscanear = {}
                            if silentAimTargetPart == "Head" then
                                local head = p.Character:FindFirstChild("Head")
                                if head then
                                    table.insert(partesAEscanear, head)
                                end
                            elseif silentAimTargetPart == "Torso" then
                                local partesClave = { "UpperTorso", "Torso", "HumanoidRootPart" }
                                for _, partName in ipairs(partesClave) do
                                    local part = p.Character:FindFirstChild(partName)
                                    if part and part:IsA("BasePart") then
                                        table.insert(partesAEscanear, part)
                                    end
                                end
                            elseif silentAimTargetPart == "Full Body" then
                                for _, part in ipairs(p.Character:GetChildren()) do
                                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                        table.insert(partesAEscanear, part)
                                    end
                                end
                            end
                            params.FilterDescendantsInstances = { char, p.Character }
                            for _, part in ipairs(partesAEscanear) do
                                local distFisica = (part.Position - myPos).Magnitude
                                local currentCamera = workspace.CurrentCamera
                                if not currentCamera then
                                    continue
                                end
                                local pos2D, onScreen =
                                    currentCamera:WorldToViewportPoint(part.Position)
                                local distToCenter = (
                                    Vector2.new(pos2D.X, pos2D.Y)
                                    - currentCamera.ViewportSize / 2
                                ).Magnitude
                                local passesFilter = false
                                if silentAimFovEnabled then
                                    if
                                        onScreen
                                        and distToCenter <= fovRadius
                                        and distToCenter < shortestDistToCenter
                                    then
                                        passesFilter = true
                                    end
                                elseif silentAimManualEnabled then
                                    if distFisica < shortestDistanceFisica then
                                        passesFilter = true
                                    end
                                end
                                if passesFilter then
                                    local raycastResult =
                                        workspace:Raycast(headPos, part.Position - headPos, params)
                                    if not raycastResult then
                                        if silentAimFovEnabled then
                                            shortestDistToCenter = distToCenter
                                            closestTargetPart = part
                                        else
                                            shortestDistanceFisica = distFisica
                                            closestTargetPart = part
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if closestTargetPart then
                    pxwSetAimTarget("Silent", closestTargetPart)
                else
                    pxwSetAimTarget("Silent", nil)
                end
            end
        end
        pxwSetAimTarget("Silent", nil)
        pxwSilentWorkerRunning = false
    end)
end

pxwUpdateTargetWorkers = function()
    if autoShootEnabled or autoShootAggressiveEnabled then
        pxwStartAutoShootWorker()
    end
    if silentAimManualEnabled or silentAimFovEnabled then
        pxwStartSilentAimWorker()
    end
    if equipGunEnabled then
        pxwStartEquipWorker()
    end
end

PXW.Section("KillAll", { Title = "Kill All", Icon = "skull" })

UIElements.TogKillAll = PXW.Toggle("KillAll", {
    Text = "Kill All",
    Description = "Hunts every enemy automatically.",
    Default = false,
    Callback = function(Value)
        KillAllEnabled = Value
        if pxwRefreshTargetMonitor then
            pxwRefreshTargetMonitor()
        end
        if Value then
            KillAllInstance:Start()
        else
            KillAllInstance:Stop()
        end
    end,
})

PXW.Section("KillAll", { Title = "Hitbox Expander", Icon = "box" })

UIElements.TogHitbox = PXW.Toggle("KillAll", {
    Text = "Enable Hitbox",
    Description = "Expands enemy hitboxes.",
    Default = false,
    Callback = function(Value)
        hitboxEnabled = Value
        if pxwRefreshTargetMonitor then
            pxwRefreshTargetMonitor()
        end
        if Value then
            pxwStartHitboxWorker()
        else
            clearHitboxes()
        end
    end,
})

UIElements.TogHitboxInvisible = PXW.Toggle("KillAll", {
    Text = "Hitbox Invisible",
    Description = "Makes the expanded hitboxes invisible.",
    Default = false,
    Callback = function(Value)
        hitboxInvisible = Value
    end,
})

UIElements.SliHitboxSize = PXW.Slider("KillAll", {
    Text = "Hitbox Size",
    Step = 0.5,
    Min = 1.0,
    Max = 28.0,
    Default = 3.5,
    Callback = function(v)
        hitboxSize = v
    end,
})

UIElements.ColHitbox = PXW.ColorPicker("KillAll", {
    Text = "Hitbox Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c)
        hitboxColor = c
    end,
})

PXW.Section("Invisible", { Title = "Invisible", Icon = "ghost" })

local function ApplyInvisibilityTransparency(state)
    if player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                if state and v.Transparency == 0 then
                    v:SetAttribute("PXWOrigTrans", 0)
                    v.Transparency = 0.5
                elseif not state and v:GetAttribute("PXWOrigTrans") ~= nil then
                    v.Transparency = v:GetAttribute("PXWOrigTrans")
                    v:SetAttribute("PXWOrigTrans", nil)
                end
            end
        end
    end
end

UIElements.TogInvisible = PXW.Toggle("Invisible", {
    Text = "Invisible",
    Description = "Hides your character from others.",
    Default = false,
    Callback = function(Value)
        InvisibilityActive = Value
        ApplyInvisibilityTransparency(Value)
        if pxwSetInvisibleWorker then
            pxwSetInvisibleWorker(Value)
        end
    end,
})

local pxwInvisibleConnection
pxwSetInvisibleWorker = function(state)
    if pxwInvisibleConnection then
        pxwInvisibleConnection:Disconnect()
        pxwInvisibleConnection = nil
    end
    if not state then
        return
    end
    pxwInvisibleConnection = RunService.Heartbeat:Connect(function()
        if not InvisibilityActive then
            return
        end
        local Char = player.Character
        if Char then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            if Root and Hum and Hum.Health > 0 then
                if Root.Position.Y > 200 then
                    return
                end
                local oldCF = Root.CFrame
                local oldCamOffset = Hum.CameraOffset
                local invisCF = oldCF * CFrame.new(0, -40, 0)
                Root.CFrame = invisCF
                Hum.CameraOffset = invisCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
                RunService.RenderStepped:Wait()
                if Root.Parent and Hum.Parent then
                    Root.CFrame = oldCF
                    Hum.CameraOffset = oldCamOffset
                end
            end
        end
    end)
end

player.CharacterAdded:Connect(function(character)
    if InvisibilityActive then
        task.wait(0.5)
        ApplyInvisibilityTransparency(true)
    end
end)

PXW.Section("Cheats", { Title = "Movement Cheats", Icon = "gauge" })

local remote = ReplicatedStorage:WaitForChild("MovementState", 3)
local function notify(kind, on)
    if remote then
        remote:FireServer(kind, on)
    end
end

local SPEED = 28.7
local JUMP_POWER = 45
local SMOOTH = 14

local speedConn, jumpConn, requestConn
local smoothDir = Vector3.zero
local jumping = false
local vy = 0

local function getChar()
    local c = player.Character
    if not c then
        return
    end
    return c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

local function SetSpeed(state)
    if speedConn then
        speedConn:Disconnect()
        speedConn = nil
    end
    smoothDir = Vector3.zero
    if not state then
        return
    end

    speedConn = RunService.Stepped:Connect(function(_, dt)
        local hum, root = getChar()
        if not hum or not root or hum.Health <= 0 then
            return
        end

        local alpha = 1 - math.exp(-SMOOTH * dt)
        smoothDir = smoothDir:Lerp(hum.MoveDirection, alpha)

        if smoothDir.Magnitude > 0.01 then
            local extra = math.max(SPEED - hum.WalkSpeed, 0)
            root.CFrame = root.CFrame + smoothDir * extra * dt
        end
    end)
end

local function SetInfJump(state)
    if jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
    if requestConn then
        requestConn:Disconnect()
        requestConn = nil
    end
    jumping = false
    vy = 0
    if not state then
        return
    end

    requestConn = UserInputService.JumpRequest:Connect(function()
        jumping = true
    end)

    jumpConn = RunService.Stepped:Connect(function(_, dt)
        local hum, root = getChar()
        if not hum or not root or hum.Health <= 0 then
            return
        end

        local held = UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump
        if jumping and not held then
            jumping = false
        end

        local target = jumping and JUMP_POWER or 0
        vy = vy + (target - vy) * (1 - math.exp(-SMOOTH * dt))

        if vy > 0.5 then
            root.CFrame = root.CFrame + Vector3.new(0, vy * dt, 0)
            local v = root.AssemblyLinearVelocity
            if v.Y < 0 then
                root.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            end
        end
    end)
end

UIElements.TogSpeed = PXW.Toggle("Cheats", {
    Text = "Speed",
    Description = "Raises your walk speed.",
    Default = false,
    Callback = function(state)
        SetSpeed(state)
        notify("Speed", state)
    end,
})

UIElements.SliSpeed = PXW.Slider("Cheats", {
    Text = "Speed Value",
    Step = 1,
    Min = 1,
    Max = 100,
    Default = 29,
    Callback = function(v)
        SPEED = v
    end,
})

UIElements.TogInfJump = PXW.Toggle("Cheats", {
    Text = "Infinite Jump",
    Description = "Jump again while in the air.",
    Default = false,
    Callback = function(state)
        SetInfJump(state)
        notify("Jump", state)
    end,
})

UIElements.SliJumpPower = PXW.Slider("Cheats", {
    Text = "Jump Power",
    Step = 1,
    Min = 1,
    Max = 100,
    Default = 45,
    Callback = function(v)
        JUMP_POWER = v
    end,
})

PXW.Section("StreakFarm", { Title = "Auto Teleport Main/Alt", Icon = "map-pin" })

local autoTPMainToggle, autoTPAltToggle

autoTPMainToggle = PXW.Toggle("StreakFarm", {
    Text = "Auto Teleport (Main)",
    Description = "Runs the teleport routine as Main.",
    Default = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Main"
            if autoTPAltToggle then
                pcall(function()
                    autoTPAltToggle:Set(false)
                end)
            end
            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Main" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end,
})

autoTPAltToggle = PXW.Toggle("StreakFarm", {
    Text = "Auto Teleport (Alt)",
    Description = "Runs the teleport routine as Alt.",
    Default = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Alt"
            if autoTPMainToggle then
                pcall(function()
                    autoTPMainToggle:Set(false)
                end)
            end
            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Alt" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end,
})

PXW.Dropdown("StreakFarm", {
    Text = "Duel Type",
    Options = { "1v1", "2v2", "3v3", "4v4" },
    Default = "1v1",
    Callback = function(value)
        if PadZoneConfig["Right Platforms"][value] then
            AutoTeleportMainAltInstance.DuelType = value
        else
            AutoTeleportMainAltInstance.DuelType = "1v1"
        end
        AutoTeleportMainAltInstance:Kick()
    end,
})

PXW.Dropdown("StreakFarm", {
    Text = "Platform Row",
    Options = { "Right Platforms", "Left Platforms" },
    Default = "Right Platforms",
    Callback = function(value)
        if PadZoneConfig[value] then
            AutoTeleportMainAltInstance.PlatformRow = value
        else
            AutoTeleportMainAltInstance.PlatformRow = "Right Platforms"
        end
        AutoTeleportMainAltInstance:Kick()
    end,
})

do
    PXW.Section("Visual", { Title = "ESP Settings", Icon = "eye" })

    local activeESPs = {}
    local MAX_ESP_DISTANCE = 1500
    local function cleanESP(targetPlayer)
        local current = activeESPs[targetPlayer]
        if not current then
            return
        end
        if current.Highlight then
            current.Highlight:Destroy()
        end
        activeESPs[targetPlayer] = nil
    end
    local function cleanAllESPs()
        for other in pairs(activeESPs) do
            cleanESP(other)
        end
    end

    UIElements.TogEsp = PXW.Toggle("Visual", {
        Text = "Player ESP",
        Description = "Highlights players through walls.",
        Callback = function(s)
            espEnabled = s
            if pxwRefreshTargetMonitor then
                pxwRefreshTargetMonitor()
            end
            if espEnabled and espSettings.Glow then
                pxwStartESPWorker()
            else
                cleanAllESPs()
            end
        end,
    })

    UIElements.ColEsp = PXW.ColorPicker("Visual", {
        Text = "ESP Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(c)
            espColor = c
        end,
    })

    PXW.Section("Visual", { Title = "ESP Filters", Icon = "filter" })

    UIElements.TogEspGl = PXW.Toggle("Visual", {
        Text = "Show Glow",
        Description = "Adds a glow to highlighted players.",
        Default = true,
        Callback = function(s)
            espSettings.Glow = s
            if pxwRefreshTargetMonitor then
                pxwRefreshTargetMonitor()
            end
            if s and espEnabled then
                pxwStartESPWorker()
            else
                cleanAllESPs()
            end
        end,
    })

    local pxwESPWorkerRunning = false
    pxwStartESPWorker = function()
        if pxwESPWorkerRunning or not espEnabled or not espSettings.Glow then
            return
        end
        pxwESPWorkerRunning = true
        task.spawn(function()
            local removingConnection = Players.PlayerRemoving:Connect(cleanESP)
            while espEnabled and espSettings.Glow do
                task.wait(0.2)
                if not espEnabled or not espSettings.Glow then
                    break
                end
                if IsInMatchStrict() then
                    local own = player.Character
                    local head = own and own:FindFirstChild("Head")
                    local pos = head and head.Position
                    for _, other in ipairs(Players:GetPlayers()) do
                        if other ~= player then
                            local character = other.Character
                            local enemyHead = character and character:FindFirstChild("Head")
                            if
                                enemyHead
                                and isEnemy(other)
                                and (
                                    not pos
                                    or (enemyHead.Position - pos).Magnitude <= MAX_ESP_DISTANCE
                                )
                            then
                                local activeEntry = activeESPs[other]
                                if
                                    activeEntry
                                    and (
                                        activeEntry.Char ~= character
                                        or not activeEntry.Highlight
                                        or activeEntry.Highlight.Parent ~= espFolder
                                    )
                                then
                                    cleanESP(other)
                                end
                                if not activeESPs[other] then
                                    local glow = Instance.new("Highlight")
                                    glow.Name = other.Name .. "_Glow"
                                    glow.FillTransparency = 1
                                    glow.OutlineTransparency = 0
                                    glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    glow.Adornee = character
                                    glow.Parent = espFolder
                                    activeESPs[other] = { Highlight = glow, Char = character }
                                end
                                local current = activeESPs[other].Highlight
                                if current.Enabled ~= espSettings.Glow then
                                    current.Enabled = espSettings.Glow
                                end
                                if current.OutlineColor ~= espColor then
                                    current.OutlineColor = espColor
                                end
                            else
                                cleanESP(other)
                            end
                        end
                    end
                else
                    cleanAllESPs()
                end
            end
            removingConnection:Disconnect()
            cleanAllESPs()
            pxwESPWorkerRunning = false
        end)
    end

    local FOVCircle
    local pxwFOVConnection
    pxwStartFOVWorker = function()
        if not fovVisiblePreference then
            if pxwFOVConnection then
                pxwFOVConnection:Disconnect()
                pxwFOVConnection = nil
            end
            if FOVCircle then
                FOVCircle.Visible = false
            end
            return
        end
        if not FOVCircle and Drawing then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Filled = false
            FOVCircle.Thickness = 1
            FOVCircle.Visible = false
        end
        if not FOVCircle or pxwFOVConnection then
            return
        end
        pxwFOVConnection = RunService.RenderStepped:Connect(function()
            if not fovVisiblePreference then
                return
            end
            local currentCamera = workspace.CurrentCamera
            if not currentCamera then
                return
            end
            FOVCircle.Position = currentCamera.ViewportSize / 2
            FOVCircle.Radius = fovRadius
            FOVCircle.Color = silentAimFovEnabled
                    and getgenv().PXWTargetPart
                    and Color3.fromRGB(0, 255, 0)
                or Color3.fromRGB(255, 255, 255)
            FOVCircle.Visible = true
        end)
    end

    PXW.Section("EventFarm", { Title = "Event Farming", Icon = "gift" })

    getgenv().AutoEventFarm = false
    local pxwFarmSession = 0
    local Networking = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages:FindFirstChild("Networking")
    local RemoteFarm = Networking and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")

    PXW.Toggle("EventFarm", {
        Text = "Auto Farm Event",
        Description = "Collects event items automatically.",
        Callback = function(s)
            getgenv().AutoEventFarm = s
            pxwFarmSession += 1
            local session = pxwFarmSession
            if s then
                task.spawn(function()
                    while getgenv().AutoEventFarm and session == pxwFarmSession do
                        pcall(function()
                            if RemoteFarm then
                                RemoteFarm:FireServer()
                            else
                                Networking = ReplicatedStorage:FindFirstChild("Packages")
                                    and ReplicatedStorage.Packages:FindFirstChild("Networking")
                                RemoteFarm = Networking
                                    and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")
                            end
                        end)
                        local char = player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local container = workspace:FindFirstChild("SpawnablesClient")
                            if container then
                                for _, obj in ipairs(container:GetChildren()) do
                                    if
                                        not getgenv().AutoEventFarm
                                        or session ~= pxwFarmSession
                                    then
                                        break
                                    end
                                    local touchPart = obj:FindFirstChild("Touch")
                                    if touchPart then
                                        pcall(function()
                                            firetouchinterest(hrp, touchPart, 0)
                                            firetouchinterest(hrp, touchPart, 1)
                                        end)
                                    end
                                end
                            end
                        end
                        task.wait(0.05)
                    end
                end)
            end
        end,
    })
end

do
    local animationData = {
        ["Old School"] = {
            Walk = 10921244891,
            Run = 10921240218,
            Jump = 10921242013,
            Fall = 10921241244,
            SwimIdle = 10921244018,
            Swim = 10921243048,
            Idle = 10921230744,
            Idle2 = 10921232093,
            Climb = 10921229866,
        },
        ["Adidas Sports"] = {
            Walk = 18537392113,
            Run = 18537384940,
            Jump = 18537380791,
            Fall = 18537367238,
            SwimIdle = 18537387180,
            Swim = 18537389531,
            Idle = 18537376492,
            Idle2 = 18537371272,
            Climb = 18537363391,
        },
        ["Adidas Community"] = {
            Walk = 122150855457006,
            Run = 82598234841035,
            Jump = 75290611992385,
            Fall = 98600215928904,
            SwimIdle = 109346520324160,
            Swim = 133308483266208,
            Idle = 122257458498464,
            Idle2 = 102357151005774,
            Climb = 88763136693023,
        },
        ["Adidas Aura"] = {
            Walk = 83842218823011,
            Run = 118320322718866,
            Jump = 109996626521204,
            Fall = 95603166884636,
            SwimIdle = 94922130551805,
            Swim = 134530128383903,
            Idle = 110211186840347,
            Idle2 = 114191137265065,
            Climb = 97824616490448,
        },
        ["Wicked Popular"] = {
            Walk = 92072849924640,
            Run = 72301599441680,
            Jump = 104325245285198,
            Fall = 121152442762481,
            Idle = 118832222982049,
            Idle2 = 76049494037641,
            SwimIdle = 113199415118199,
            Swim = 99384245425157,
            Climb = 131326830509784,
        },
        ["Elder"] = {
            Walk = 10921111375,
            Run = 10921104374,
            Jump = 10921107367,
            Fall = 10921105765,
            SwimIdle = 10921110146,
            Swim = 10921108971,
            Idle = 10921101664,
            Idle2 = 10921102574,
            Climb = 10921100400,
        },
        ["Zombie"] = {
            Walk = 10921355261,
            Run = 616163682,
            Jump = 10921351278,
            Fall = 10921350320,
            SwimIdle = 10921353442,
            Swim = 10921352344,
            Idle = 10921344533,
            Idle2 = 10921345304,
            Climb = 10921343576,
        },
        ["Mage"] = {
            Walk = 10921152678,
            Run = 10921148209,
            Jump = 10921149743,
            Fall = 10921148939,
            SwimIdle = 10921151661,
            Swim = 10921150788,
            Idle = 10921144709,
            Idle2 = 10921145797,
            Climb = 10921143404,
        },
        ["Catwalk Glam"] = {
            Walk = 109168724482748,
            Run = 81024476153754,
            Jump = 116936326516985,
            Fall = 92294537340807,
            SwimIdle = 98854111361360,
            Swim = 134591743181628,
            Idle = 133806214992291,
            Idle2 = 94970088341563,
            Climb = 119377220967554,
        },
        ["Astronaut"] = {
            Walk = 10921046031,
            Run = 10921039308,
            Jump = 10921042494,
            Fall = 10921040576,
            SwimIdle = 10921045006,
            Swim = 10921044000,
            Idle = 10921034824,
            Idle2 = 10921036806,
            Climb = 10921032124,
        },
        ['Wicked "Dancing Through Life"'] = {
            Walk = 73718308412641,
            Run = 135515454877967,
            Jump = 78508480717326,
            Fall = 78147885297412,
            SwimIdle = 129183123083281,
            Swim = 110657013921774,
            Idle = 92849173543269,
            Idle2 = 132238900951109,
            Climb = 129447497744818,
        },
        ["Werewolf"] = {
            Walk = 10921342074,
            Run = 10921336997,
            Fall = 10921337907,
            SwimIdle = 10921341319,
            Swim = 10921340419,
            Idle = 10921330408,
            Idle2 = 10921333667,
            Climb = 10921329322,
        },
        ["Superhero"] = {
            Walk = 10921298616,
            Run = 10921291831,
            Jump = 10921294559,
            Fall = 10921293273,
            SwimIdle = 10921297391,
            Swim = 10921295495,
            Idle = 10921288909,
            Idle2 = 10921290167,
            Climb = 10921286911,
        },
        ["Toy"] = {
            Walk = 10921312010,
            Run = 10921306285,
            Jump = 10921308158,
            Fall = 10921307241,
            SwimIdle = 10921310341,
            Swim = 10921309319,
            Idle = 10921301576,
            Climb = 10921300839,
        },
        ["No Boundaries"] = {
            Walk = 18747074203,
            Run = 18747070484,
            Jump = 18747069148,
            Fall = 18747062535,
            SwimIdle = 18747071682,
            Swim = 18747073181,
            Idle = 18747067405,
            Idle2 = 18747063918,
            Climb = 18747060903,
        },
        ["NFL"] = {
            Walk = 110358958299415,
            Run = 117333533048078,
            Jump = 119846112151352,
            Fall = 129773241321032,
            SwimIdle = 79090109939093,
            Swim = 132697394189921,
            Idle = 92080889861410,
            Idle2 = 74451233229259,
            Climb = 134630013742019,
        },
        ["Amazon Unboxed"] = {
            Walk = 90478085024465,
            Run = 134824450619865,
            Jump = 121454505477205,
            Fall = 94788218468396,
            SwimIdle = 129126268464847,
            Swim = 105962919001086,
            Idle = 98281136301627,
            Climb = 121145883950231,
        },
        ["Vampire"] = {
            Walk = 10921326949,
            Run = 10921320299,
            Jump = 10921322186,
            Fall = 10921321317,
            SwimIdle = 10921325443,
            Swim = 10921324408,
            Idle = 10921315373,
            Climb = 10921314188,
        },
        ["Ninja"] = {
            Walk = 656121766,
            Run = 656118852,
            Jump = 656117878,
            Fall = 656115606,
            SwimIdle = 656121397,
            Swim = 656119721,
            Idle = 656117400,
            Idle2 = 656118341,
            Climb = 656114359,
        },
        ["Robot"] = {
            Walk = 616095330,
            Run = 616091570,
            Jump = 616090535,
            Fall = 616087089,
            SwimIdle = 616094091,
            Swim = 616092998,
            Idle = 616088211,
            Idle2 = 616089559,
            Climb = 616086039,
        },
        ["Levitation"] = {
            Walk = 616013216,
            Run = 616010382,
            Jump = 616008936,
            Fall = 616005863,
            SwimIdle = 616012453,
            Swim = 616011509,
            Idle = 616006778,
            Idle2 = 616008087,
            Climb = 616003713,
        },
        ["Stylish"] = {
            Walk = 616146177,
            Run = 616140816,
            Jump = 616139451,
            Fall = 616134815,
            SwimIdle = 616144772,
            Swim = 616143378,
            Idle = 616136790,
            Idle2 = 616138447,
            Climb = 616133594,
        },
        ["Bubbly"] = {
            Walk = 910034870,
            Run = 910025107,
            Jump = 910016857,
            Fall = 910001910,
            SwimIdle = 910030921,
            Swim = 910028158,
            Idle = 910004836,
            Idle2 = 910009958,
            Climb = 909997997,
        },
        ["Cartoon"] = {
            Walk = 742640026,
            Run = 742638842,
            Jump = 742637942,
            Fall = 742637151,
            SwimIdle = 742639812,
            Swim = 742639220,
            Idle = 742637544,
            Idle2 = 742638445,
            Climb = 742636889,
        },
    }

    local function clearAllAnimations()
        local char = player.Character
        if not char then
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            return
        end
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:Stop(0)
            track:Destroy()
        end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
                track:Destroy()
            end
        end
        task.wait(0.1)
    end

    local function applyCustomAnims(customData)
        if not customData then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        clearAllAnimations()
        local animate = char:FindFirstChild("Animate")
        if not animate then
            return
        end
        if not originalAnimations then
            local function getAnim(folderName, animName)
                local folder = animate:FindFirstChild(folderName)
                if folder then
                    local anim = folder:FindFirstChild(animName)
                    if anim and anim:IsA("Animation") then
                        local idStr = anim.AnimationId:match("%d+")
                        if idStr then
                            return tonumber(idStr)
                        end
                    end
                end
                return nil
            end
            originalAnimations = {
                Idle = getAnim("idle", "Animation1") or 507766666,
                Idle2 = getAnim("idle", "Animation2") or 507766951,
                Walk = getAnim("walk", "WalkAnim") or 507777826,
                Run = getAnim("run", "RunAnim") or 507767714,
                Jump = getAnim("jump", "JumpAnim") or 507765000,
                Climb = getAnim("climb", "ClimbAnim") or 507765644,
                Fall = getAnim("fall", "FallAnim") or 507767968,
                Swim = getAnim("swim", "Swim") or 507784897,
                SwimIdle = getAnim("swimidle", "SwimIdle") or 507785072,
            }
        end
        animate.Disabled = true
        task.wait(0.1)
        local function updateAnimation(folderName, animName, animId)
            if not animId then
                return
            end
            local folder = animate:FindFirstChild(folderName)
            if folder then
                local anim = folder:FindFirstChild(animName)
                if anim and anim:IsA("Animation") then
                    anim.AnimationId = "rbxassetid://" .. tostring(animId)
                end
            end
        end
        updateAnimation("idle", "Animation1", customData.Idle)
        updateAnimation("idle", "Animation2", customData.Idle2 or customData.Idle)
        updateAnimation("walk", "WalkAnim", customData.Walk)
        updateAnimation("run", "RunAnim", customData.Run)
        updateAnimation("jump", "JumpAnim", customData.Jump)
        updateAnimation("climb", "ClimbAnim", customData.Climb)
        updateAnimation("fall", "FallAnim", customData.Fall)
        updateAnimation("swim", "Swim", customData.Swim)
        updateAnimation("swimidle", "SwimIdle", customData.SwimIdle or customData.Swim)
        task.wait(0.1)
        animate.Disabled = false
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    local pxwAnimationWorkerRunning = false
    pxwStartAnimationWorker = function()
        if pxwAnimationWorkerRunning or not activeAnimationSet then
            return
        end
        pxwAnimationWorkerRunning = true
        task.spawn(function()
            while activeAnimationSet do
                task.wait(0.2)
                if not activeAnimationSet then
                    break
                end
                local char = player.Character
                if not char then
                    continue
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then
                    continue
                end
                if hum.Health <= 0 then
                    continue
                end
                if hum.MoveDirection.Magnitude >= 0.1 then
                    continue
                end
                local animate = char:FindFirstChild("Animate")
                if not animate then
                    continue
                end
                local walkIds = {}
                local walkFolder = animate:FindFirstChild("walk")
                local runFolder = animate:FindFirstChild("run")
                if walkFolder then
                    for _, anim in ipairs(walkFolder:GetChildren()) do
                        if anim:IsA("Animation") then
                            table.insert(walkIds, anim.AnimationId)
                        end
                    end
                end
                if runFolder then
                    for _, anim in ipairs(runFolder:GetChildren()) do
                        if anim:IsA("Animation") then
                            table.insert(walkIds, anim.AnimationId)
                        end
                    end
                end
                if #walkIds == 0 then
                    continue
                end
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if track.Animation and table.find(walkIds, track.Animation.AnimationId) then
                            track:Stop(0)
                        end
                    end
                end
            end
            pxwAnimationWorkerRunning = false
        end)
    end

    player.CharacterAdded:Connect(function()
        if activeAnimationSet then
            task.spawn(function()
                task.wait(0.8)
                applyCustomAnims(activeAnimationSet)
            end)
        end
    end)

    local animList = { "None" }
    for name, _ in pairs(animationData) do
        table.insert(animList, name)
    end
    table.sort(animList)

    PXW.Section("Animations", { Title = "Full Packages", Icon = "folder" })
    local selectedFullBundle = "None"
    PXW.Dropdown("Animations", {
        Text = "Choose Package",
        Options = animList,
        Default = "None",
        Callback = function(Value)
            selectedFullBundle = Value
        end,
    })

    PXW.Button("Animations", {
        Text = "Apply Full Package",
        Callback = function()
            if selectedFullBundle == "None" then
                return
            end
            task.spawn(function()
                activeAnimationSet = animationData[selectedFullBundle]
                pxwStartAnimationWorker()
                applyCustomAnims(activeAnimationSet)
            end)
        end,
    })

    PXW.Button("Animations", {
        Text = "Restore Default",
        Callback = function()
            task.spawn(function()
                local defaultAnims = originalAnimations
                    or {
                        Idle = 507766666,
                        Idle2 = 507766951,
                        Walk = 507777826,
                        Run = 507767714,
                        Jump = 507765000,
                        Climb = 507765644,
                        Fall = 507767968,
                        Swim = 507784897,
                        SwimIdle = 507785072,
                    }
                activeAnimationSet = nil
                applyCustomAnims(defaultAnims)
            end)
        end,
    })

    PXW.Section("Animations", { Title = "Animation Mixer", Icon = "layers" })

    local mixParts = {
        Idle = "None",
        Walk = "None",
        Run = "None",
        Jump = "None",
        Fall = "None",
        Climb = "None",
    }

    PXW.Dropdown("Animations", {
        Text = "Idle",
        Options = animList,
        Default = "None",
        Callback = function(Value)
            mixParts.Idle = Value
        end,
    })
    PXW.Dropdown("Animations", {
        Text = "Walk",
        Options = animList,
        Default = "None",
        Callback = function(Value)
            mixParts.Walk = Value
        end,
    })
    PXW.Dropdown("Animations", {
        Text = "Run",
        Options = animList,
        Default = "None",
        Callback = function(Value)
            mixParts.Run = Value
        end,
    })
    PXW.Dropdown("Animations", {
        Text = "Jump",
        Options = animList,
        Default = "None",
        Callback = function(Value)
            mixParts.Jump = Value
        end,
    })
    PXW.Dropdown("Animations", {
        Text = "Fall",
        Options = animList,
        Default = "None",
        Callback = function(Value)
            mixParts.Fall = Value
        end,
    })
    PXW.Dropdown("Animations", {
        Text = "Climb",
        Options = animList,
        Default = "None",
        Callback = function(Value)
            mixParts.Climb = Value
        end,
    })

    PXW.Button("Animations", {
        Text = "Combine and Apply",
        Callback = function()
            task.spawn(function()
                local customMix = {}
                if mixParts.Idle ~= "None" then
                    customMix.Idle = animationData[mixParts.Idle].Idle
                    customMix.Idle2 = animationData[mixParts.Idle].Idle2
                end
                if mixParts.Walk ~= "None" then
                    customMix.Walk = animationData[mixParts.Walk].Walk
                end
                if mixParts.Run ~= "None" then
                    customMix.Run = animationData[mixParts.Run].Run
                end
                if mixParts.Jump ~= "None" then
                    customMix.Jump = animationData[mixParts.Jump].Jump
                end
                if mixParts.Fall ~= "None" then
                    customMix.Fall = animationData[mixParts.Fall].Fall
                end
                if mixParts.Climb ~= "None" then
                    customMix.Climb = animationData[mixParts.Climb].Climb
                end
                local hasValues = false
                for _, v in pairs(customMix) do
                    if v then
                        hasValues = true
                        break
                    end
                end
                if hasValues then
                    activeAnimationSet = customMix
                    pxwStartAnimationWorker()
                    applyCustomAnims(activeAnimationSet)
                end
            end)
        end,
    })
end

local KillSoundEnabled = false
local ReloadShotSoundEnabled = false
local SelectedKillSound = "Onichaaan"
local KillSoundVolume = 1

local KillSounds = {
    { Name = "Onichaaan", Id = "114361503583259" },
    { Name = "Omagaaa", Id = "4496966777" },
    { Name = "korummm", Id = "119896940405402" },
    { Name = "FAAAH XD", Id = "92076037937225" },
    { Name = "Meme Bell", Id = "107378927201728" },
    { Name = "Enrique", Id = "100688006999379" },
    { Name = "Anime Magic", Id = "109296938403067" },
    { Name = "Anime Laugh", Id = "93739527256723" },
    { Name = "Groan", Id = "94981264286350" },
    { Name = "Magic 2", Id = "100507897550384" },
    { Name = "OwO", Id = "71942674274967" },
    { Name = "SEMPAI >.<", Id = "115498703521334" },
    { Name = "Ahhh:3", Id = "83559496188823" },
    { Name = "nyaa >//~//<", Id = "78798011197804" },
}

local KillSoundPlayer = Instance.new("Sound")
KillSoundPlayer.Name = "PXWKillSound"
KillSoundPlayer.Volume = 1
KillSoundPlayer.Looped = false
KillSoundPlayer.Parent = SoundService

local ShootReloadOptions = {
    ["Revolver + Reload"] = { Shoot = "680140087", Reload = "138084889" },
    ["Anime Magic"] = { Shoot = "109296938403067", Reload = nil },
    ["Laser + Laser Reload"] = { Shoot = "4400449399", Reload = "129456040607483" },
}
local SelectedShootReload = "Revolver + Reload"

local SHOOT_SOUND_MAX_DURATION = 1.5
local shootSoundToken = 0
local lastShootSoundTime = 0
local SHOOT_SOUND_MIN_INTERVAL = 0.05

local ShootSoundPlayer = Instance.new("Sound")
ShootSoundPlayer.Name = "PXWShootSound"
ShootSoundPlayer.Volume = 1
ShootSoundPlayer.Looped = false
ShootSoundPlayer.Parent = SoundService

local ReloadSoundPlayer = Instance.new("Sound")
ReloadSoundPlayer.Name = "PXWReloadSound"
ReloadSoundPlayer.Volume = 1
ReloadSoundPlayer.Looped = false
ReloadSoundPlayer.Parent = SoundService

local function PlayShootSound()
    if not ReloadShotSoundEnabled then
        return
    end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Shoot then
        return
    end
    local now = tick()
    if now - lastShootSoundTime < SHOOT_SOUND_MIN_INTERVAL then
        return
    end
    lastShootSoundTime = now
    shootSoundToken = shootSoundToken + 1
    local myToken = shootSoundToken
    ShootSoundPlayer:Stop()
    ShootSoundPlayer.SoundId = "rbxassetid://" .. cfg.Shoot
    ShootSoundPlayer.Volume = KillSoundVolume
    ShootSoundPlayer:Play()
    task.delay(SHOOT_SOUND_MAX_DURATION, function()
        if shootSoundToken == myToken and ShootSoundPlayer.Playing then
            ShootSoundPlayer:Stop()
        end
    end)
end

local function PlayReloadSound()
    if not ReloadShotSoundEnabled then
        return
    end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Reload then
        return
    end
    ReloadSoundPlayer:Stop()
    ReloadSoundPlayer.SoundId = "rbxassetid://" .. cfg.Reload
    ReloadSoundPlayer.Volume = KillSoundVolume
    ReloadSoundPlayer:Play()
end

local pxwShootConnections = {}
local pxwFireWatched = setmetatable({}, { __mode = "k" })
local pxwToolWatched = setmetatable({}, { __mode = "k" })
local pxwShootRootWatched = setmetatable({}, { __mode = "k" })
local function pxwTrackShoot(connection)
    pxwShootConnections[#pxwShootConnections + 1] = connection
    return connection
end
local function pxwStopShootWatchers()
    duelDisconnectConnectionList(pxwShootConnections)
    table.clear(pxwFireWatched)
    table.clear(pxwToolWatched)
    table.clear(pxwShootRootWatched)
end
local pxwStartReloadWorker
local FIRE_SOUND_KEYWORDS = {
    "fire",
    "shoot",
    "shot",
    "gun",
    "burst",
    "shotgun",
    "gunshot",
    "muzzle",
    "rifle",
    "pistol",
    "shooting",
    "firing",
}

local function isFireSound(s)
    if not s:IsA("Sound") then
        return false
    end
    local n = string.lower(s.Name)
    for _, kw in ipairs(FIRE_SOUND_KEYWORDS) do
        if string.find(n, kw, 1, true) then
            return true
        end
    end
    return false
end

local function HookFireSound(s)
    if not s:IsA("Sound") then
        return
    end
    if not isFireSound(s) then
        return
    end
    if not ReloadShotSoundEnabled or pxwFireWatched[s] then
        return
    end
    pxwFireWatched[s] = true
    pxwTrackShoot(s.Played:Connect(function()
        if not ReloadShotSoundEnabled then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        if
            s:IsDescendantOf(char)
            or s:IsDescendantOf(player:FindFirstChildOfClass("Backpack") or char)
        then
            PlayShootSound()
        end
    end))
end

local function HookShootOnTool(tool)
    if not tool or not tool:IsA("Tool") then
        return
    end
    for _, d in ipairs(tool:GetDescendants()) do
        HookFireSound(d)
    end
    if not pxwToolWatched[tool] and ReloadShotSoundEnabled then
        pxwToolWatched[tool] = true
        pxwTrackShoot(tool.DescendantAdded:Connect(HookFireSound))
    end
end

local function HookShootOnRoot(root)
    if not root then
        return
    end
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("Tool") then
            HookShootOnTool(child)
        end
    end
    pxwTrackShoot(root.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            HookShootOnTool(child)
        end
    end))
end

local pxwReloadRunning = false
pxwStartReloadWorker = function()
    if pxwReloadRunning or not ReloadShotSoundEnabled then
        return
    end
    pxwReloadRunning = true
    task.spawn(function()
        local lastReloadState = false
        while ReloadShotSoundEnabled do
            task.wait(0.05)
            if not ReloadShotSoundEnabled then
                break
            end
            local char = player.Character
            if not char then
                lastReloadState = false
                continue
            end
            local weapon = char:FindFirstChildOfClass("Tool")
            if not weapon or isKnife(weapon) then
                lastReloadState = false
                continue
            end
            local reloading = isReloading(weapon)
            if reloading and not lastReloadState then
                PlayReloadSound()
            end
            lastReloadState = reloading
        end
        pxwReloadRunning = false
    end)
end

local function GetKillSoundIdByName(soundName)
    for _, s in ipairs(KillSounds) do
        if s.Name == soundName then
            return s.Id
        end
    end
    return KillSounds[1].Id
end

local function PlayKillSound()
    if not KillSoundEnabled then
        return
    end
    KillSoundPlayer:Stop()
    KillSoundPlayer.SoundId = "rbxassetid://" .. GetKillSoundIdByName(SelectedKillSound)
    KillSoundPlayer.Volume = KillSoundVolume
    KillSoundPlayer:Play()
end

local lastKillSoundTime = 0
local KILL_SOUND_COOLDOWN = 0.08
local function TryPlayKillSound()
    if not KillSoundEnabled then
        return
    end
    local now = tick()
    if now - lastKillSoundTime < KILL_SOUND_COOLDOWN then
        return
    end
    lastKillSoundTime = now
    PlayKillSound()
end

local pxwKillConnections = {}
local pxwKillWatchedStats = setmetatable({}, { __mode = "k" })
local pxwKillWatchedCharacters = setmetatable({}, { __mode = "k" })
local pxwKillWatchedPlayers = setmetatable({}, { __mode = "k" })
local pxwKillWatchedContainers = setmetatable({}, { __mode = "k" })
local function pxwTrackKill(connection)
    pxwKillConnections[#pxwKillConnections + 1] = connection
    return connection
end
local KILL_STAT_NAMES = {
    kos = true,
    kills = true,
    kill = true,
    ko = true,
    killed = true,
    eliminations = true,
    kills_count = true,
}

local function HookStatValue(stat)
    if not stat then
        return
    end
    if not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
        return
    end
    if not KILL_STAT_NAMES[string.lower(stat.Name)] then
        return
    end
    if not KillSoundEnabled or pxwKillWatchedStats[stat] then
        return
    end
    pxwKillWatchedStats[stat] = true
    local lastVal = stat.Value
    pxwTrackKill(stat:GetPropertyChangedSignal("Value"):Connect(function()
        if stat.Value > lastVal then
            TryPlayKillSound()
        end
        lastVal = stat.Value
    end))
end

local function HookLeaderstatsContainer(container)
    if not container or not KillSoundEnabled or pxwKillWatchedContainers[container] then
        return
    end
    pxwKillWatchedContainers[container] = true
    for _, stat in ipairs(container:GetChildren()) do
        HookStatValue(stat)
    end
    pxwTrackKill(container.ChildAdded:Connect(HookStatValue))
end

local KILL_ATTR_NAMES = { "KOs", "Kills", "kos", "kills", "KO", "killed", "Eliminations" }
local function pxwWatchLocalKillStats()
    for _, attrName in ipairs(KILL_ATTR_NAMES) do
        local lastVal = tonumber(player:GetAttribute(attrName))
        pxwTrackKill(player:GetAttributeChangedSignal(attrName):Connect(function()
            local newVal = tonumber(player:GetAttribute(attrName))
            if newVal ~= nil and lastVal ~= nil and newVal > lastVal then
                TryPlayKillSound()
            end
            lastVal = newVal
        end))
    end
    for _, name in ipairs({ "leaderstats", "Stats", "stats", "PlayerStats" }) do
        HookLeaderstatsContainer(player:FindFirstChild(name))
    end
    pxwTrackKill(player.ChildAdded:Connect(function(child)
        if
            child.Name == "leaderstats"
            or child.Name == "Stats"
            or child.Name == "stats"
            or child.Name == "PlayerStats"
        then
            HookLeaderstatsContainer(child)
        end
    end))
end

local function HookKillOnCharacter(other, character)
    if not KillSoundEnabled or pxwKillWatchedCharacters[character] then
        return
    end
    pxwKillWatchedCharacters[character] = true
    local waitConnection
    local function attachHumanoid(humanoid)
        if not KillSoundEnabled or not humanoid or not humanoid:IsA("Humanoid") then
            return
        end
        if waitConnection then
            waitConnection:Disconnect()
            waitConnection = nil
        end
        pxwTrackKill(humanoid.Died:Connect(function()
            if not KillSoundEnabled then
                return
            end
            local tag = humanoid:FindFirstChild("creator")
            if tag and tag.Value == player then
                TryPlayKillSound()
            end
        end))
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        attachHumanoid(humanoid)
    else
        waitConnection = pxwTrackKill(character.ChildAdded:Connect(attachHumanoid))
    end
end

local function HookKillPlayer(other)
    if other == player or not KillSoundEnabled or pxwKillWatchedPlayers[other] then
        return
    end
    pxwKillWatchedPlayers[other] = true
    if other.Character then
        HookKillOnCharacter(other, other.Character)
    end
    pxwTrackKill(other.CharacterAdded:Connect(function(character)
        HookKillOnCharacter(other, character)
    end))
end

local function pxwStartKillWatchers()
    if not KillSoundEnabled then
        return
    end
    pxwWatchLocalKillStats()
    for _, other in ipairs(Players:GetPlayers()) do
        HookKillPlayer(other)
    end
    pxwTrackKill(Players.PlayerAdded:Connect(HookKillPlayer))
end
local function pxwStopKillWatchers()
    duelDisconnectConnectionList(pxwKillConnections)
    table.clear(pxwKillWatchedStats)
    table.clear(pxwKillWatchedCharacters)
    table.clear(pxwKillWatchedPlayers)
    table.clear(pxwKillWatchedContainers)
end

local OriginalGunVolumes = {}
local HookedGunSounds = setmetatable({}, { __mode = "k" })

local function MuteOwnSound(s)
    if not ReloadShotSoundEnabled or not s:IsA("Sound") then
        return
    end
    if
        s.Name == "PXWKillSound"
        or s.Name == "PXW_MusicPlayer"
        or s.Name == "PXWShootSound"
        or s.Name == "PXWReloadSound"
    then
        return
    end
    if OriginalGunVolumes[s] == nil and s.Volume > 0 then
        OriginalGunVolumes[s] = s.Volume
    end
    if ReloadShotSoundEnabled then
        s.Volume = 0
    end
    if not HookedGunSounds[s] then
        HookedGunSounds[s] = true
        pxwTrackShoot(s:GetPropertyChangedSignal("Volume"):Connect(function()
            if ReloadShotSoundEnabled and s.Volume ~= 0 then
                OriginalGunVolumes[s] = s.Volume
                s.Volume = 0
            end
        end))
        pxwTrackShoot(s.Played:Connect(function()
            if ReloadShotSoundEnabled then
                s.Volume = 0
            end
        end))
    end
end

local function HookOwnRoot(root)
    if not root then
        return
    end
    for _, d in ipairs(root:GetDescendants()) do
        MuteOwnSound(d)
    end
    pxwTrackShoot(root.DescendantAdded:Connect(MuteOwnSound))
end

local function ApplyMuteState(state)
    if state then
        for s in pairs(OriginalGunVolumes) do
            if s.Parent then
                s.Volume = 0
            end
        end
        if player.Character then
            for _, d in ipairs(player.Character:GetDescendants()) do
                MuteOwnSound(d)
            end
        end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, d in ipairs(backpack:GetDescendants()) do
                MuteOwnSound(d)
            end
        end
    else
        for s, v in pairs(OriginalGunVolumes) do
            if s.Parent then
                s.Volume = v
            end
        end
    end
end

local function pxwStartShootWatchers()
    if not ReloadShotSoundEnabled then
        return
    end
    local function attach(root)
        if not root or not ReloadShotSoundEnabled or pxwShootRootWatched[root] then
            return
        end
        pxwShootRootWatched[root] = true
        HookOwnRoot(root)
        HookShootOnRoot(root)
    end
    attach(player.Character)
    attach(player:FindFirstChildOfClass("Backpack"))
    pxwTrackShoot(player.CharacterAdded:Connect(function(character)
        if not ReloadShotSoundEnabled then
            return
        end
        attach(character)
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            attach(backpack)
        end
    end))
    pxwTrackShoot(player.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then
            attach(child)
        end
    end))
    pxwStartReloadWorker()
end

PXW.Section("Sounds", { Title = "Kill Sound", Icon = "volume-2" })

PXW.Toggle("Sounds", {
    Text = "Kill Sound",
    Description = "Plays a sound on every kill.",
    Default = false,
    Callback = function(v)
        if KillSoundEnabled == v then
            return
        end
        KillSoundEnabled = v
        if v then
            pxwStartKillWatchers()
        else
            pxwStopKillWatchers()
            KillSoundPlayer:Stop()
        end
    end,
})

local KillSoundDropdownValues = {}
for _, s in ipairs(KillSounds) do
    table.insert(KillSoundDropdownValues, s.Name)
end

PXW.Dropdown("Sounds", {
    Text = "Kill Sound Choice",
    Options = KillSoundDropdownValues,
    Default = "Onichaaan",
    Callback = function(selected)
        SelectedKillSound = selected
    end,
})

PXW.Section("Sounds", { Title = "Shot and Reload", Icon = "target" })

PXW.Toggle("Sounds", {
    Text = "Shot and Reload Sound",
    Description = "Plays custom shot and reload sounds.",
    Default = false,
    Callback = function(v)
        if ReloadShotSoundEnabled == v then
            return
        end
        ReloadShotSoundEnabled = v
        if v then
            pxwStartShootWatchers()
            ApplyMuteState(true)
        else
            pxwStopShootWatchers()
            ShootSoundPlayer:Stop()
            ReloadSoundPlayer:Stop()
            ApplyMuteState(false)
            table.clear(OriginalGunVolumes)
            table.clear(HookedGunSounds)
        end
    end,
})

PXW.Dropdown("Sounds", {
    Text = "Shot Sound Type",
    Options = { "Revolver + Reload", "Anime Magic", "Laser + Laser Reload" },
    Default = "Revolver + Reload",
    Callback = function(selected)
        SelectedShootReload = selected
    end,
})

UIElements.SliKillSoundVolume = PXW.Slider("Sounds", {
    Text = "Volume",
    Step = 0.1,
    Min = 1,
    Max = 3,
    Default = 1,
    Callback = function(v)
        KillSoundVolume = v
        KillSoundPlayer.Volume = v
        ShootSoundPlayer.Volume = v
        ReloadSoundPlayer.Volume = v
    end,
})

do
    local MusicPlayer = Instance.new("Sound")
    MusicPlayer.Name = "PXW_MusicPlayer"
    MusicPlayer.Looped = false
    MusicPlayer.Volume = 0.5
    MusicPlayer.Parent = SoundService

    local SongList = {
        { Name = "Song 1", Id = "84944985070181" },
        { Name = "Song 2", Id = "87570666848900" },
        { Name = "Song 3", Id = "82746224492420" },
        { Name = "Song 4", Id = "71393805905055" },
        { Name = "Song 5", Id = "75688616622595" },
        { Name = "Song 6", Id = "135609653444873" },
        { Name = "Song 7", Id = "93699644879957" },
        { Name = "Song 8", Id = "110398343528156" },
        { Name = "Song 9", Id = "138863509657081" },
        { Name = "Song 10", Id = "115440201770223" },
        { Name = "Song 11", Id = "128048502331483" },
        { Name = "Song 12", Id = "135321902579514" },
        { Name = "Song 13", Id = "131465489873214" },
    }

    local CurrentIndex = 1
    local ShuffleOn = false
    local NowPlayingParagraph

    local function UpdateNowPlaying()
        local song = SongList[CurrentIndex]
        if song and NowPlayingParagraph then
            NowPlayingParagraph:SetText(
                ("%s | ID: %s | %s"):format(
                    song.Name,
                    song.Id,
                    MusicPlayer.Playing and "Playing" or "Paused"
                )
            )
        end
    end

    local function LoadSong(index)
        if not SongList[index] then
            return
        end
        CurrentIndex = index
        MusicPlayer:Stop()
        MusicPlayer.SoundId = "rbxassetid://" .. SongList[index].Id
        MusicPlayer:Play()
        UpdateNowPlaying()
    end

    local function PlaySong()
        if MusicPlayer.SoundId == "" then
            LoadSong(CurrentIndex)
        elseif not MusicPlayer.Playing then
            MusicPlayer:Resume()
        end
        UpdateNowPlaying()
    end

    local function PauseSong()
        if MusicPlayer.Playing then
            MusicPlayer:Pause()
        end
        UpdateNowPlaying()
    end

    local function StopSong()
        MusicPlayer:Stop()
        MusicPlayer.SoundId = ""
        UpdateNowPlaying()
    end

    local function NextSong()
        local nextIndex
        if ShuffleOn then
            nextIndex = math.random(1, #SongList)
        else
            nextIndex = CurrentIndex + 1
            if nextIndex > #SongList then
                nextIndex = 1
            end
        end
        LoadSong(nextIndex)
    end

    local function PrevSong()
        local prevIndex
        if ShuffleOn then
            prevIndex = math.random(1, #SongList)
        else
            prevIndex = CurrentIndex - 1
            if prevIndex < 1 then
                prevIndex = #SongList
            end
        end
        LoadSong(prevIndex)
    end

    MusicPlayer.Ended:Connect(function()
        NextSong()
    end)

    PXW.Section("Music", { Title = "Now Playing", Icon = "music" })
    NowPlayingParagraph = PXW.Paragraph("Music", {
        Title = "Current Song",
        Content = "No song selected",
    })

    PXW.Section("Music", { Title = "Controls", Icon = "sliders-horizontal" })
    PXW.Button("Music", {
        Text = "Previous",
        Icon = "skip-back",
        Callback = function()
            PrevSong()
        end,
    })
    PXW.Button("Music", {
        Text = "Next",
        Icon = "skip-forward",
        Callback = function()
            NextSong()
        end,
    })
    PXW.Button("Music", {
        Text = "Play",
        Icon = "play",
        Primary = true,
        Callback = function()
            PlaySong()
        end,
    })
    PXW.Button("Music", {
        Text = "Pause",
        Icon = "pause",
        Callback = function()
            PauseSong()
        end,
    })
    PXW.Button("Music", {
        Text = "Stop",
        Icon = "square",
        Callback = function()
            StopSong()
        end,
    })
end


local KORBLOX_ASSETS = {
    ["Right Leg"] = {
        id = "rbxassetid://139607718",
        targetBodyPart = "RightUpperLeg",
        partsToHide = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
        scale = Vector3.new(1.0, 1.0, 1.0),
        audio = "rbxassetid://135315310485417",
        offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
    },
}

local KorbloxEnabled = false
local korbloxSavedTransparency = {}

local function attachKorbloxMesh(itemName, config)
    local character = player.Character
    if not character then
        return false
    end
    local targetPart = character:WaitForChild(config.targetBodyPart, 2)
    if not targetPart then
        return false
    end
    local oldAsset = character:FindFirstChild("Korblox_" .. itemName:gsub("%s+", ""))
    if oldAsset then
        oldAsset:Destroy()
    end
    for _, partName in ipairs(config.partsToHide) do
        local limb = character:FindFirstChild(partName)
        if limb and limb:IsA("BasePart") then
            if korbloxSavedTransparency[partName] == nil then
                korbloxSavedTransparency[partName] = limb.Transparency
            end
            limb.Transparency = 1
        end
    end
    local success, objects = pcall(function()
        return game:GetObjects(config.id)
    end)
    if not success or not objects or #objects == 0 then
        return false
    end
    local assetModel = objects[1]
    assetModel.Name = "Korblox_" .. itemName:gsub("%s+", "")
    local mainMesh = assetModel:IsA("BasePart") and assetModel
        or assetModel:FindFirstChildWhichIsA("BasePart", true)
    if not mainMesh then
        return false
    end
    mainMesh.Size = mainMesh.Size * config.scale
    mainMesh.CanCollide = false
    mainMesh.CFrame = targetPart.CFrame * config.offset
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = targetPart
    weld.Part1 = mainMesh
    weld.Parent = mainMesh
    assetModel.Parent = character
    if config.audio then
        local sound = Instance.new("Sound")
        sound.SoundId = config.audio
        sound.Volume = 0.5
        sound.Parent = mainMesh
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end
    return true
end

local function applyKorblox()
    if not KorbloxEnabled then
        return
    end
    local config = KORBLOX_ASSETS["Right Leg"]
    local ok = attachKorbloxMesh("Right Leg", config)
    if not ok then
        task.wait(0.2)
        attachKorbloxMesh("Right Leg", config)
    end
end

local function removeKorblox()
    local character = player.Character
    if not character then
        return
    end
    local assetName = "Korblox_RightLeg"
    local asset = character:FindFirstChild(assetName)
    if asset then
        pcall(function()
            asset:Destroy()
        end)
    end
    for partName, orig in pairs(korbloxSavedTransparency) do
        local limb = character:FindFirstChild(partName)
        if limb and limb:IsA("BasePart") then
            pcall(function()
                limb.Transparency = orig
            end)
        end
    end
    korbloxSavedTransparency = {}
end

local HEADLESS_ASSET_ID = 134082579
local HeadlessEnabled = false
local insertedHeadlessAccessory = nil

local function setHeadlessTransparency(enabled)
    local character = player.Character
    if not character then
        return
    end
    local head = character:FindFirstChild("Head")
    if head then
        head.Transparency = enabled and 1 or 0
        local faceDecal = head:FindFirstChildOfClass("Decal")
        if faceDecal then
            faceDecal.Transparency = enabled and 1 or 0
        end
    end
end

local function setHeadless(enabled)
    local character = player.Character
    if not character then
        return
    end
    if enabled then
        character:WaitForChild("Head", 2)
        setHeadlessTransparency(true)
        if insertedHeadlessAccessory and insertedHeadlessAccessory.Parent ~= character then
            insertedHeadlessAccessory = nil
        end
        if insertedHeadlessAccessory then
            return
        end
        local success, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(HEADLESS_ASSET_ID))
        end)
        if success and result and #result > 0 then
            local rootModel = result[1]
            local model = nil
            if rootModel:IsA("Accessory") then
                model = rootModel
            else
                for _, descendant in ipairs(rootModel:GetDescendants()) do
                    if descendant:IsA("Accessory") then
                        model = descendant
                        break
                    end
                end
                model = model or (rootModel:IsA("Model") and rootModel or nil)
            end
            if model then
                if model:IsA("Accessory") then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local addSuccess = humanoid
                        and pcall(function()
                            humanoid:AddAccessory(model)
                        end)
                    if not addSuccess then
                        model.Parent = character
                    end
                else
                    model.Parent = character
                end
                insertedHeadlessAccessory = model
            end
        else
            warn("[Headless] Failed to load headless asset: " .. tostring(result))
        end
    else
        setHeadlessTransparency(false)
        if insertedHeadlessAccessory then
            insertedHeadlessAccessory:Destroy()
            insertedHeadlessAccessory = nil
        end
    end
end

player.CharacterAdded:Connect(function(character)
    korbloxSavedTransparency = {}
    insertedHeadlessAccessory = nil
    if KorbloxEnabled then
        task.spawn(function()
            task.wait(0.1)
            applyKorblox()
        end)
    end
    if HeadlessEnabled then
        task.spawn(function()
            task.wait(0.1)
            setHeadless(true)
        end)
    end
end)

PXW.Section("Items", { Title = "Items", Icon = "crown" })

UIElements.TogHeadless = PXW.Toggle("Items", {
    Text = "Apply Headless",
    Description = "Removes your head visually.",
    Default = false,
    Callback = function(v)
        HeadlessEnabled = v
        if v then
            setHeadless(true)
        else
            setHeadless(false)
        end
    end,
})

UIElements.TogKorblox = PXW.Toggle("Items", {
    Text = "Apply Korblox",
    Description = "Applies the Korblox leg.",
    Default = false,
    Callback = function(v)
        KorbloxEnabled = v
        if v then
            applyKorblox()
        else
            removeKorblox()
        end
    end,
})

PXW.Section("Identity", { Title = "Fake Identity", Icon = "user" })

local function safeReplace(str, find, replace)
    local safeFind = find:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
    return (str:gsub(safeFind, replace))
end

local originalData = {}
local visualConnections = {}
local pxwFakeTextConnections = setmetatable({}, { __mode = "k" })
local isWorkspaceLooping = false

local function processText(v, myName, myDisp)
    local parentGui = v:FindFirstAncestorWhichIsA("ScreenGui")
    if
        parentGui
        and (string.find(parentGui.Name, "Perplex") or string.find(parentGui.Name, "PXW"))
    then
        return
    end
    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
        local txt = v.Text
        local hasName = false
        if txt and txt ~= "" then
            if string.find(txt, myName, 1, true) or string.find(txt, myDisp, 1, true) then
                hasName = true
            end
        end
        if hasName and not originalData[v] then
            originalData[v] = {
                Text = txt,
                Color = v.TextColor3,
                TextTransp = v.TextTransparency,
                StrokeTransp = v.TextStrokeTransparency,
                Strokes = {},
            }
            for _, obj in pairs(v:GetChildren()) do
                if obj:IsA("UIStroke") then
                    originalData[v].Strokes[obj] = {
                        Enabled = obj.Enabled,
                        Transp = obj.Transparency,
                        Thickness = obj.Thickness,
                    }
                end
            end
        end
        if originalData[v] then
            if fakeNameEnabled then
                local newText = originalData[v].Text
                newText = safeReplace(newText, myName, spoofNameText)
                newText = safeReplace(newText, myDisp, spoofNameText)
                v.Text = newText
                v.TextTransparency = originalData[v].TextTransp
                v.TextStrokeTransparency = originalData[v].StrokeTransp
                v.TextColor3 = originalData[v].Color
                for _, obj in pairs(v:GetChildren()) do
                    if obj:IsA("UIStroke") and originalData[v].Strokes[obj] then
                        obj.Enabled = originalData[v].Strokes[obj].Enabled
                    end
                end
            else
                v.Text = originalData[v].Text
                v.TextColor3 = originalData[v].Color
                v.TextTransparency = originalData[v].TextTransp
                v.TextStrokeTransparency = originalData[v].StrokeTransp
                for _, obj in pairs(v:GetChildren()) do
                    if obj:IsA("UIStroke") and originalData[v].Strokes[obj] then
                        obj.Enabled = originalData[v].Strokes[obj].Enabled
                        obj.Transparency = originalData[v].Strokes[obj].Transp
                        obj.Thickness = originalData[v].Strokes[obj].Thickness
                    end
                end
            end
        end
    end
end

local function updateSystem()
    local myName = player.Name
    local myDisp = player.DisplayName
    task.spawn(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                for _, v in pairs(p.Character:GetDescendants()) do
                    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                        processText(v, myName, myDisp)
                    end
                end
            end
        end
        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            for _, v in pairs(pGui:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                    processText(v, myName, myDisp)
                end
            end
        end
    end)

    if fakeNameEnabled then
        if not isWorkspaceLooping then
            isWorkspaceLooping = true
            local function safeSpoofText(v)
                local parentGui = v:FindFirstAncestorWhichIsA("ScreenGui")
                if
                    parentGui
                    and (
                        string.find(parentGui.Name, "Perplex")
                        or string.find(parentGui.Name, "PXW")
                    )
                then
                    return
                end
                if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                    processText(v, myName, myDisp)
                    if not pxwFakeTextConnections[v] then
                        pxwFakeTextConnections[v] = true
                        table.insert(
                            visualConnections,
                            v:GetPropertyChangedSignal("Text"):Connect(function()
                                if
                                    isWorkspaceLooping
                                    and v.Text ~= spoofNameText
                                    and not string.find(v.Text, spoofNameText)
                                then
                                    originalData[v] = nil
                                    processText(v, myName, myDisp)
                                end
                            end)
                        )
                    end
                end
            end
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                table.insert(
                    visualConnections,
                    pGui.DescendantAdded:Connect(function(newObject)
                        if
                            isWorkspaceLooping
                            and (
                                newObject:IsA("TextLabel")
                                or newObject:IsA("TextBox")
                                or newObject:IsA("TextButton")
                            )
                        then
                            task.spawn(function()
                                safeSpoofText(newObject)
                            end)
                        end
                    end)
                )
            end
            local successCore, coreGui = pcall(function()
                return game:GetService("CoreGui")
            end)
            if successCore and coreGui then
                table.insert(
                    visualConnections,
                    coreGui.DescendantAdded:Connect(function(newObject)
                        if
                            isWorkspaceLooping
                            and (
                                newObject:IsA("TextLabel")
                                or newObject:IsA("TextBox")
                                or newObject:IsA("TextButton")
                            )
                        then
                            task.spawn(function()
                                safeSpoofText(newObject)
                            end)
                        end
                    end)
                )
            end
        end
    else
        isWorkspaceLooping = false
        for _, conn in ipairs(visualConnections) do
            conn:Disconnect()
        end
        visualConnections = {}
        table.clear(pxwFakeTextConnections)
        for v, data in pairs(originalData) do
            if v and v.Parent then
                v.Text = data.Text
                v.TextColor3 = data.Color
                v.TextTransparency = data.TextTransp
                v.TextStrokeTransparency = data.StrokeTransp
                for stroke, strokeData in pairs(data.Strokes) do
                    if stroke and stroke.Parent then
                        stroke.Enabled = strokeData.Enabled
                        stroke.Transparency = strokeData.Transp
                        stroke.Thickness = strokeData.Thickness
                    end
                end
            end
        end
        originalData = {}
    end
end

UIElements.TogFakeName = PXW.Toggle("Identity", {
    Text = "Enable Fake Name",
    Description = "Replaces your name on screen.",
    Default = false,
    Callback = function(s)
        fakeNameEnabled = s
        updateSystem()
    end,
})

UIElements.InpFakeName = PXW.TextBox("Identity", {
    Text = "Fake Name",
    Placeholder = "Type your fake name...",
    Callback = function(t)
        if t ~= "" then
            spoofNameText = t
            if fakeNameEnabled then
                updateSystem()
            end
        end
    end,
})

player.CharacterAdded:Connect(function()
    if fakeNameEnabled then
        task.wait(1)
        updateSystem()
    end
end)


do
    PXW.Section("Graphics", { Title = "Lighting Presets", Icon = "sun" })

    local bloodyNightEffects = {}
    local sunsetEffects = {}
    local lifelessEffects = {}
    local bloodyNightSkyFolder = nil

    local function SaveLightingOriginal(tag)
        local Lighting = game:GetService("Lighting")
        if Lighting:GetAttribute("OrigSaved_" .. tag) then
            return
        end
        Lighting:SetAttribute("Orig_Ambient_" .. tag, Lighting.Ambient)
        Lighting:SetAttribute("Orig_OutdoorAmbient_" .. tag, Lighting.OutdoorAmbient)
        Lighting:SetAttribute("Orig_Brightness_" .. tag, Lighting.Brightness)
        Lighting:SetAttribute("Orig_ClockTime_" .. tag, Lighting.ClockTime)
        Lighting:SetAttribute("Orig_FogColor_" .. tag, Lighting.FogColor)
        Lighting:SetAttribute("Orig_FogEnd_" .. tag, Lighting.FogEnd)
        Lighting:SetAttribute("Orig_FogStart_" .. tag, Lighting.FogStart)
        Lighting:SetAttribute("Orig_ColorShift_Top_" .. tag, Lighting.ColorShift_Top)
        Lighting:SetAttribute("Orig_ColorShift_Bottom_" .. tag, Lighting.ColorShift_Bottom)
        Lighting:SetAttribute("Orig_ExposureCompensation_" .. tag, Lighting.ExposureCompensation)
        Lighting:SetAttribute("Orig_GlobalShadows_" .. tag, Lighting.GlobalShadows)
        Lighting:SetAttribute(
            "Orig_EnvironmentDiffuseScale_" .. tag,
            Lighting.EnvironmentDiffuseScale
        )
        Lighting:SetAttribute(
            "Orig_EnvironmentSpecularScale_" .. tag,
            Lighting.EnvironmentSpecularScale
        )
        Lighting:SetAttribute("OrigSaved_" .. tag, true)
    end

    local function RestoreLighting(tag)
        local Lighting = game:GetService("Lighting")
        if not Lighting:GetAttribute("OrigSaved_" .. tag) then
            return
        end
        Lighting.Ambient = Lighting:GetAttribute("Orig_Ambient_" .. tag)
        Lighting.OutdoorAmbient = Lighting:GetAttribute("Orig_OutdoorAmbient_" .. tag)
        Lighting.Brightness = Lighting:GetAttribute("Orig_Brightness_" .. tag)
        Lighting.ClockTime = Lighting:GetAttribute("Orig_ClockTime_" .. tag)
        Lighting.FogColor = Lighting:GetAttribute("Orig_FogColor_" .. tag)
        Lighting.FogEnd = Lighting:GetAttribute("Orig_FogEnd_" .. tag)
        Lighting.FogStart = Lighting:GetAttribute("Orig_FogStart_" .. tag)
        Lighting.ColorShift_Top = Lighting:GetAttribute("Orig_ColorShift_Top_" .. tag)
        Lighting.ColorShift_Bottom = Lighting:GetAttribute("Orig_ColorShift_Bottom_" .. tag)
        Lighting.ExposureCompensation = Lighting:GetAttribute("Orig_ExposureCompensation_" .. tag)
        Lighting.GlobalShadows = Lighting:GetAttribute("Orig_GlobalShadows_" .. tag)
        Lighting.EnvironmentDiffuseScale =
            Lighting:GetAttribute("Orig_EnvironmentDiffuseScale_" .. tag)
        Lighting.EnvironmentSpecularScale =
            Lighting:GetAttribute("Orig_EnvironmentSpecularScale_" .. tag)
        Lighting:SetAttribute("OrigSaved_" .. tag, nil)
    end

    local function ClearEffects(list)
        for _, v in ipairs(list) do
            pcall(function()
                v:Destroy()
            end)
        end
        table.clear(list)
    end

    local function ApplyBloodyNightLighting(state)
        local Lighting = game:GetService("Lighting")
        if state then
            SaveLightingOriginal("NS")
            ClearEffects(bloodyNightEffects)

            if bloodyNightSkyFolder then
                bloodyNightSkyFolder:Destroy()
            end
            bloodyNightSkyFolder = Instance.new("Folder")
            bloodyNightSkyFolder.Name = "NS_SkyX"
            bloodyNightSkyFolder.Parent = workspace

            local function makeBeam(angle)
                local beam = Instance.new("Part")
                beam.Anchored = true
                beam.CanCollide = false
                beam.CanQuery = false
                beam.Material = Enum.Material.Neon
                beam.Color = Color3.fromRGB(255, 55, 55)
                beam.Transparency = 0.1
                beam.Size = Vector3.new(2600, 26, 26)
                beam.CFrame = CFrame.new(0, 3200, -2200) * CFrame.Angles(0, 0, math.rad(angle))
                beam.Parent = bloodyNightSkyFolder
                table.insert(bloodyNightEffects, beam)
            end
            makeBeam(45)
            makeBeam(-45)

            local glowPart = Instance.new("Part")
            glowPart.Anchored = true
            glowPart.CanCollide = false
            glowPart.CanQuery = false
            glowPart.Material = Enum.Material.Neon
            glowPart.Color = Color3.fromRGB(255, 110, 110)
            glowPart.Transparency = 0.65
            glowPart.Shape = Enum.PartType.Ball
            glowPart.Size = Vector3.new(420, 420, 420)
            glowPart.CFrame = CFrame.new(0, 3200, -2200)
            glowPart.Parent = bloodyNightSkyFolder
            table.insert(bloodyNightEffects, glowPart)

            local light1 = Instance.new("PointLight")
            light1.Color = Color3.fromRGB(255, 80, 80)
            light1.Range = 300
            light1.Brightness = 3
            light1.Parent = glowPart
            table.insert(bloodyNightEffects, light1)

            local sky = Instance.new("Sky")
            sky.Name = "NS_Sky"
            sky.StarCount = 9000
            sky.MoonAngularSize = 30
            sky.SunAngularSize = 0
            sky.CelestialBodiesShown = true
            sky.Parent = Lighting
            table.insert(bloodyNightEffects, sky)

            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "NS_CC"
            cc.Brightness = 0.05
            cc.Contrast = 0.32
            cc.Saturation = -0.15
            cc.TintColor = Color3.fromRGB(255, 130, 130)
            cc.Parent = Lighting
            table.insert(bloodyNightEffects, cc)

            local bloom = Instance.new("BloomEffect")
            bloom.Name = "NS_Bloom"
            bloom.Intensity = 1
            bloom.Size = 90
            bloom.Threshold = 0.45
            bloom.Parent = Lighting
            table.insert(bloodyNightEffects, bloom)

            local blur = Instance.new("BlurEffect")
            blur.Name = "NS_Blur"
            blur.Size = 3
            blur.Parent = Lighting
            table.insert(bloodyNightEffects, blur)

            local atmo = Instance.new("Atmosphere")
            atmo.Name = "NS_Atmo"
            atmo.Density = 0.42
            atmo.Offset = 0
            atmo.Color = Color3.fromRGB(60, 12, 12)
            atmo.Decay = Color3.fromRGB(80, 20, 20)
            atmo.Glare = 0.5
            atmo.Haze = 1.6
            atmo.Parent = Lighting
            table.insert(bloodyNightEffects, atmo)

            Lighting.ClockTime = 0
            Lighting.Brightness = 1.2
            Lighting.Ambient = Color3.fromRGB(130, 110, 110)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 140, 140)
            Lighting.FogColor = Color3.fromRGB(22, 5, 5)
            Lighting.FogEnd = 1200
            Lighting.FogStart = 150
            Lighting.ColorShift_Top = Color3.fromRGB(125, 25, 25)
            Lighting.ColorShift_Bottom = Color3.fromRGB(65, 8, 8)
            Lighting.ExposureCompensation = -0.2
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.5
            Lighting.EnvironmentSpecularScale = 0.5
        else
            ClearEffects(bloodyNightEffects)
            if bloodyNightSkyFolder then
                bloodyNightSkyFolder:Destroy()
                bloodyNightSkyFolder = nil
            end
            RestoreLighting("NS")
        end
    end

    local function ApplySunsetLighting(state)
        local Lighting = game:GetService("Lighting")
        if state then
            SaveLightingOriginal("AF")
            ClearEffects(sunsetEffects)

            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AF_CC"
            cc.Brightness = 0.05
            cc.Contrast = 0.14
            cc.Saturation = 0.22
            cc.TintColor = Color3.fromRGB(255, 205, 165)
            cc.Parent = Lighting
            table.insert(sunsetEffects, cc)

            local bloom = Instance.new("BloomEffect")
            bloom.Name = "AF_Bloom"
            bloom.Intensity = 0.32
            bloom.Size = 40
            bloom.Threshold = 0.92
            bloom.Parent = Lighting
            table.insert(sunsetEffects, bloom)

            local rays = Instance.new("SunRaysEffect")
            rays.Name = "AF_Rays"
            rays.Intensity = 0.15
            rays.Spread = 0.9
            rays.Parent = Lighting
            table.insert(sunsetEffects, rays)

            local sky = Instance.new("Sky")
            sky.Name = "AF_Sky"
            sky.SunAngularSize = 18
            sky.MoonAngularSize = 0
            sky.StarCount = 2000
            sky.Parent = Lighting
            table.insert(sunsetEffects, sky)

            local atmo = Instance.new("Atmosphere")
            atmo.Name = "AF_Atmo"
            atmo.Density = 0.36
            atmo.Offset = 0.1
            atmo.Color = Color3.fromRGB(255, 185, 135)
            atmo.Decay = Color3.fromRGB(255, 125, 85)
            atmo.Glare = 0.2
            atmo.Haze = 1.2
            atmo.Parent = Lighting
            table.insert(sunsetEffects, atmo)

            Lighting.ClockTime = 6.3
            Lighting.Brightness = 2.4
            Lighting.Ambient = Color3.fromRGB(85, 62, 55)
            Lighting.OutdoorAmbient = Color3.fromRGB(125, 92, 80)
            Lighting.FogColor = Color3.fromRGB(240, 185, 145)
            Lighting.FogEnd = 2500
            Lighting.FogStart = 200
            Lighting.ColorShift_Top = Color3.fromRGB(255, 185, 105)
            Lighting.ColorShift_Bottom = Color3.fromRGB(205, 105, 85)
            Lighting.ExposureCompensation = 0.08
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.8
            Lighting.EnvironmentSpecularScale = 0.6
        else
            ClearEffects(sunsetEffects)
            RestoreLighting("AF")
        end
    end

    local function ApplyLifelessLighting(state)
        local Lighting = game:GetService("Lighting")
        if state then
            SaveLightingOriginal("SV")
            ClearEffects(lifelessEffects)

            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "SV_CC"
            cc.Brightness = 0.05
            cc.Contrast = 0.22
            cc.Saturation = -1
            cc.TintColor = Color3.fromRGB(222, 226, 232)
            cc.Parent = Lighting
            table.insert(lifelessEffects, cc)

            local bloom = Instance.new("BloomEffect")
            bloom.Name = "SV_Bloom"
            bloom.Intensity = 1.25
            bloom.Size = 75
            bloom.Threshold = 0.38
            bloom.Parent = Lighting
            table.insert(lifelessEffects, bloom)

            local sky = Instance.new("Sky")
            sky.Name = "SV_Sky"
            sky.StarCount = 0
            sky.SunAngularSize = 0
            sky.MoonAngularSize = 0
            sky.CelestialBodiesShown = false
            sky.Parent = Lighting
            table.insert(lifelessEffects, sky)

            local atmo = Instance.new("Atmosphere")
            atmo.Name = "SV_Atmo"
            atmo.Density = 0.3
            atmo.Offset = 0.1
            atmo.Color = Color3.fromRGB(180, 185, 190)
            atmo.Decay = Color3.fromRGB(140, 145, 150)
            atmo.Glare = 0
            atmo.Haze = 1.0
            atmo.Parent = Lighting
            table.insert(lifelessEffects, atmo)

            Lighting.ClockTime = 14
            Lighting.Brightness = 2.2
            Lighting.Ambient = Color3.fromRGB(92, 96, 100)
            Lighting.OutdoorAmbient = Color3.fromRGB(132, 136, 140)
            Lighting.FogColor = Color3.fromRGB(172, 176, 180)
            Lighting.FogEnd = 3000
            Lighting.FogStart = 200
            Lighting.ColorShift_Top = Color3.fromRGB(152, 156, 160)
            Lighting.ColorShift_Bottom = Color3.fromRGB(122, 126, 130)
            Lighting.ExposureCompensation = 0
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.6
            Lighting.EnvironmentSpecularScale = 0.3
        else
            ClearEffects(lifelessEffects)
            RestoreLighting("SV")
        end
    end

    local bloodyNightToggle, sunsetToggle, lifelessToggle

    bloodyNightToggle = PXW.Toggle("Graphics", {
        Text = "Bloody Night",
        Description = "Dark red night lighting.",
        Default = false,
        Callback = function(state)
            if state then
                if sunsetToggle then
                    pcall(function()
                        sunsetToggle:Set(false)
                    end)
                end
                if lifelessToggle then
                    pcall(function()
                        lifelessToggle:Set(false)
                    end)
                end
            end
            ApplyBloodyNightLighting(state)
        end,
    })

    sunsetToggle = PXW.Toggle("Graphics", {
        Text = "Fantasy Sunset",
        Description = "Warm sunset lighting.",
        Default = false,
        Callback = function(state)
            if state then
                if bloodyNightToggle then
                    pcall(function()
                        bloodyNightToggle:Set(false)
                    end)
                end
                if lifelessToggle then
                    pcall(function()
                        lifelessToggle:Set(false)
                    end)
                end
            end
            ApplySunsetLighting(state)
        end,
    })

    lifelessToggle = PXW.Toggle("Graphics", {
        Text = "Lifeless",
        Description = "Dull, washed out lighting.",
        Default = false,
        Callback = function(state)
            if state then
                if bloodyNightToggle then
                    pcall(function()
                        bloodyNightToggle:Set(false)
                    end)
                end
                if sunsetToggle then
                    pcall(function()
                        sunsetToggle:Set(false)
                    end)
                end
            end
            ApplyLifelessLighting(state)
        end,
    })
end

PXW.Refresh()
