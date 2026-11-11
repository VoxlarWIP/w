print("\n" .. string.rep("=", 80))
print("PerplexWare")
print(string.rep("=", 80))

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not LocalPlayer then
    error("ERROR: No local player available")
    return
end

function notifyLoadStatus(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "PerplexWare",
            Text = text,
            Duration = duration or 6,
        })
    end)
end

local Library
local Window

do
    local loadAttempts = 3
    local loadRetryWait = 1.5
    local lastLoadError = nil

    for attempt = 1, loadAttempts do
        local loaded, result = pcall(function()
            return loadstring(game:HttpGet("https://pxw-gg.pages.dev/scripts/uisrc.lua"))()
        end)

        if loaded and result then
            Library = result
            break
        end

        lastLoadError = result
        warn(string.format("[PerplexWare] Interface load attempt %d/%d failed: %s", attempt, loadAttempts, tostring(lastLoadError)))

        if attempt < loadAttempts then
            notifyLoadStatus("Could not load the interface, retrying (" .. attempt .. "/" .. loadAttempts .. ")...", 4)
            task.wait(loadRetryWait)
        end
    end

    if not Library then
        notifyLoadStatus("Could not load the interface after " .. loadAttempts .. " attempts. Check your connection and run the script again.", 10)
        error("ERROR: Failed to load the PerplexWare interface - " .. tostring(lastLoadError))
    end
end

Library:PreloadIcons("Lucide")

PerplexTheme = {
    Accent = Color3.fromRGB(18, 18, 20),
    AccentAlt = Color3.fromRGB(74, 74, 80),
    Background = Color3.fromRGB(246, 246, 248),
    Surface = Color3.fromRGB(255, 255, 255),
    SurfaceAlt = Color3.fromRGB(236, 236, 240),
    Outline = Color3.fromRGB(210, 210, 216),
    Text = Color3.fromRGB(18, 18, 20),
    Muted = Color3.fromRGB(110, 110, 118),
    Hover = Color3.fromRGB(230, 230, 235),
    ToggleOn = Color3.fromRGB(18, 18, 20),
    ToggleOff = Color3.fromRGB(196, 196, 202),
    Knob = Color3.fromRGB(255, 255, 255),
}
getgenv().PerplexTheme = PerplexTheme

do
    local protectionTriggered = false

    local function triggerSelfDestruct(reason)
        if protectionTriggered then return end
        protectionTriggered = true

        pcall(function()
            local targets = {"PXWUI", "PXWMain"}
            for _, guiParent in ipairs({
                game:GetService("CoreGui"),
                LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"),
            }) do
                if guiParent then
                    for _, name in ipairs(targets) do
                        local g = guiParent:FindFirstChild(name)
                        if g then g:Destroy() end
                    end

                    for _, child in ipairs(guiParent:GetChildren()) do
                        if child:IsA("ScreenGui") then
                            pcall(function() child:Destroy() end)
                        end
                    end
                end
            end
        end)

        error("__Perplex_PROTECTED__" .. (reason or ""), 0)
    end

    pcall(function()
        local debugLibrary = debug
        if type(debugLibrary) == "table" then
            local watchedDebugFunctions = {
                "getinfo", "getupvalue", "setupvalue", "getlocal",
                "setlocal", "getmetatable", "setmetatable",
                "traceback", "sethook", "getfenv", "setfenv"
            }
            for _, fnName in ipairs(watchedDebugFunctions) do
                local original = debugLibrary[fnName]
                if type(original) == "function" then
                    debugLibrary[fnName] = function(...)
                        local args = {...}

                        local isWatchedDebugCall = (
                            fnName == "getinfo" or fnName == "getupvalue" or fnName == "setupvalue"
                            or fnName == "getmetatable" or fnName == "setmetatable"
                            or fnName == "getfenv" or fnName == "setfenv"
                            or fnName == "getlocal" or fnName == "setlocal"
                            or fnName == "sethook"
                        )
                        if isWatchedDebugCall then
                            triggerSelfDestruct("debug_api_intercepted:" .. fnName)
                        end
                        return original(...)
                    end
                end
            end
        end
    end)

    pcall(function()
        if type(decompile) == "function" then
            local originalDecompile = decompile

            getgenv().decompile = function(obj, ...)

                if obj and (obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script")) then
                    triggerSelfDestruct("decompile_attempt")
                end
                return originalDecompile(obj, ...)
            end
        end
    end)

    pcall(function()
        local watchedDumpFunctions = {"getscriptbytecode", "dumpstring", "getscripthash"}
        local globalEnvironment = type(getgenv) == "function" and getgenv() or _G
        for _, fnName in ipairs(watchedDumpFunctions) do
            if type(globalEnvironment[fnName]) == "function" then
                local originalFunction = globalEnvironment[fnName]
                globalEnvironment[fnName] = function(...)
                    triggerSelfDestruct("bytecode_dump_intercepted:" .. fnName)
                    return originalFunction(...)
                end
            end
        end
    end)

    local environmentSnapshot = {}
    pcall(function()
        if type(getgenv) == "function" then
            local globalEnvironment = getgenv()

            for k, _ in pairs(globalEnvironment) do
                environmentSnapshot[k] = true
            end
        end
    end)

    pcall(function()
        local isStudioEnvironment = RunService:IsStudio()
        if isStudioEnvironment then

            if not LocalPlayer then
                triggerSelfDestruct("studio_no_player")
            end
        end
    end)

    task.spawn(function()
        local checkInterval = 3
        local iterationCount = 0
        while not protectionTriggered do
            iterationCount = iterationCount + 1
            task.wait(checkInterval)
            if protectionTriggered then break end

            pcall(function()
                if type(decompile) == "function" then
                    local functionSource = tostring(decompile)

                    if functionSource:find("native") or functionSource:find("C function") then
                        triggerSelfDestruct("decompile_restored_native")
                    end
                end
            end)

            pcall(function()
                if type(getgenv) == "function" then
                    local globalEnvironment = getgenv()
                    local dumpSignals = {
                        "getscriptbytecode", "dumpstring", "getscripthash",
                        "readbytecode", "getfuncinfo", "getprotolist"
                    }
                    for _, fnName in ipairs(dumpSignals) do
                        if type(globalEnvironment[fnName]) == "function" and not environmentSnapshot[fnName] then

                            triggerSelfDestruct("injected_dump_fn:" .. fnName)
                        end
                    end
                end
            end)
        end
    end)
end

print("\nSERVICES: Initialized successfully")

local Config = {

    EnableSpeedMultiplier = false,
    SpeedMultiplierValue = 1,

    TeleportMovementSpeed = 5,
    EnableTeleportWalk = false,
    JumpHeight = 50,
    EnableEnhancedJump = false,

    EnableInfiniteSlide = false,
    InfiniteSlideSpeed = 30,

    EnableInfiniteSlideOld = false,
    InfiniteSlideSpeedOld = 30,
    AutoJump = false,

    AutoJumpSpeed = 1.5,
    AutoCrouch = false,

    AutoCrouchSpeed = 1.5,
    EnableJumpAcceleration = false,
    JumpAccelerationSpeed = 42,

    EnableGravityMod = false,
    GravityScale = 0.5,

    EnableFrontalJump = false,

    EnableRampMultiplier = false,

    EnableBackJump = false,
    BackJumpSpeed = 42,

    EnableFullBright = false,
    EnableAutoTicket = false,
    EnableVoidEscape = false,
    EnableAfkMap     = false,
    EnableGagMap     = false,
    EnableAntiAfk    = false,
    EnableWhistleESP = false,

    EnableReviveAura = false,
    EnableAutoSave   = false,
    EnableEspDown    = false,
    EnableAutoCarry = false,
    CarryRange    = 30,
    CarryInterval = 0.2,
    EnableAutoForceSpawn = false,
    EnableAntiBot = false,
    AntiBotDistance = 10,
    AntiBotCooldown = 0.15,

    EnableEmoteSpeed = false,
    EmoteSpeedMultiplier = 1.5,

    EnableLayerJumps = false,
    LayerJumpsCount = 2,

    EnableImpulseJump = false,
    ImpulseJumpSpeed = 42,

    EnableAutoTrimp = false,
    AutoTrimpMultiplier = 2.5,
    AutoTrimpFallSpeed = 0.5,

    EnableTrimpTeleport = false,

    EnableFigure8  = false,
    Figure8Speed   = 1.5,
    Figure8Radius  = 8,

    EnableLissajous  = false,
    LissajousSpeed   = 1.5,
    LissajousRadius  = 8,

    EnableSpiro      = false,
    SpiroSpeed       = 0.8,
    SpiroRadius      = 12,
    SpiroRatio       = 0.35,

    EnableRemoveWalls = false,
}

local camera = Workspace.CurrentCamera
getgenv().FrontalJumpSpeed = 42
getgenv().RampMultiplier = 1.55
getgenv().RampMultiplierValue = 1.55
local maxExtraSpeed = 80
local currentSpeed = getgenv().FrontalJumpSpeed
local airAccumulator = 0
local lastTick = tick()
local wasAir = false
local activeBV = nil
local lastJumpTime = tick()
local jumpInterval = 0.65

local autoJumpNextTime = 0
local autoCrouchNextTime = 0
local rampLocked = false

getgenv().BackJumpSpeed = 42
getgenv().BackRampMultiplier = 0
local backCurrentSpeed = getgenv().BackJumpSpeed
local backAirAccumulator = 0
local backLastTick = tick()
local backWasAir = false
local backActiveBV = nil
local backLastJumpTime = tick()
local backJumpInterval = 0.65
local backRampLocked = false

local frontalRaycastParams = RaycastParams.new()
frontalRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
local backRaycastParams = RaycastParams.new()
backRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
local rampRaycastParams = RaycastParams.new()
rampRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
local slideRaycastParams = RaycastParams.new()
slideRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
local antiBotRaycastParams = RaycastParams.new()
antiBotRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local Lighting = game:GetService("Lighting")

local fullBrightState = {
    Enabled = false,
    Connection = nil,
    Original = nil,
}

local fullBrightHooks = {
    SaveSettings = nil,
}

function captureFullBrightState()
    if fullBrightState.Original then
        return
    end

    local ok, snapshot = pcall(function()
        return {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
            ColorShift_Top = Lighting.ColorShift_Top,
            GlobalShadows = Lighting.GlobalShadows,
            ClockTime = Lighting.ClockTime,
            ExposureCompensation = Lighting.ExposureCompensation,
            FogColor = Lighting.FogColor,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        }
    end)

    if ok and snapshot then
        fullBrightState.Original = snapshot
    end
end

function disconnectFullBrightConnection()
    if fullBrightState.Connection then
        pcall(function()
            fullBrightState.Connection:Disconnect()
        end)
        fullBrightState.Connection = nil
    end
end

function restoreFullBrightState()
    local original = fullBrightState.Original
    if not original then
        return
    end

    pcall(function()
        Lighting.Brightness = original.Brightness
        Lighting.Ambient = original.Ambient
        Lighting.OutdoorAmbient = original.OutdoorAmbient
        Lighting.ColorShift_Bottom = original.ColorShift_Bottom
        Lighting.ColorShift_Top = original.ColorShift_Top
        Lighting.GlobalShadows = original.GlobalShadows
        Lighting.ClockTime = original.ClockTime
        Lighting.ExposureCompensation = original.ExposureCompensation
        Lighting.FogColor = original.FogColor
        Lighting.FogEnd = original.FogEnd
        Lighting.FogStart = original.FogStart
        Lighting.EnvironmentDiffuseScale = original.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = original.EnvironmentSpecularScale
    end)
end

function applyFullBright()
    pcall(function()
        if Lighting.GlobalShadows ~= false then
            Lighting.GlobalShadows = false
        end

        if Lighting.Brightness ~= 1 then
            Lighting.Brightness = 1
        end

        local white = Color3.new(1, 1, 1)
        if Lighting.Ambient ~= white then
            Lighting.Ambient = white
        end
        if Lighting.OutdoorAmbient ~= white then
            Lighting.OutdoorAmbient = white
        end
        if Lighting.ColorShift_Bottom ~= white then
            Lighting.ColorShift_Bottom = white
        end
        if Lighting.ColorShift_Top ~= white then
            Lighting.ColorShift_Top = white
        end

        if Lighting.ClockTime ~= 12 then
            Lighting.ClockTime = 12
        end

        if Lighting.ExposureCompensation ~= 0 then
            Lighting.ExposureCompensation = 0
        end

        if Lighting.FogColor ~= white then
            Lighting.FogColor = white
        end

        if Lighting.FogEnd ~= 1e10 then
            Lighting.FogEnd = 1e10
        end

        if Lighting.FogStart ~= 0 then
            Lighting.FogStart = 0
        end

        if Lighting.EnvironmentDiffuseScale ~= 1 then
            Lighting.EnvironmentDiffuseScale = 1
        end

        if Lighting.EnvironmentSpecularScale ~= 1 then
            Lighting.EnvironmentSpecularScale = 1
        end
    end)
end

function setFullBrightEnabled(state)
    local enabled = state and true or false

    fullBrightState.Enabled = enabled
    Config.EnableFullBright = enabled

    if enabled then
        captureFullBrightState()
        applyFullBright()

        if not fullBrightState.Connection then
            fullBrightState.Connection = RunService.Heartbeat:Connect(function()
                if not fullBrightState.Enabled then
                    return
                end

                applyFullBright()
            end)
        end
    else
        disconnectFullBrightConnection()
        restoreFullBrightState()
    end

    if fullBrightHooks.SaveSettings then
        pcall(function()
            fullBrightHooks.SaveSettings()
        end)
    end
end

local savedOptions = {
    EnableTeleportWalk = false,
    EnableEnhancedJump = false,
    EnableGravityMod = false,
}

local HttpService = game:GetService("HttpService")
local SettingsFile = "EVADE_V52_Settings.json"

function writeSettingsFile()
    pcall(function()
        local data = {
            EnableTeleportWalk = Config.EnableTeleportWalk,
            TeleportMovementSpeed = Config.TeleportMovementSpeed,
            EnableEnhancedJump = Config.EnableEnhancedJump,
            JumpHeight = Config.JumpHeight,
            EnableInfiniteSlide = Config.EnableInfiniteSlide,
            InfiniteSlideSpeed = Config.InfiniteSlideSpeed,
            EnableInfiniteSlideOld = Config.EnableInfiniteSlideOld,
            InfiniteSlideSpeedOld = Config.InfiniteSlideSpeedOld,
            AutoJump = Config.AutoJump,
            AutoJumpSpeed = Config.AutoJumpSpeed,
            AutoCrouch = Config.AutoCrouch,
            AutoCrouchSpeed = Config.AutoCrouchSpeed,
            EnableJumpAcceleration = Config.EnableJumpAcceleration,
            JumpAccelerationSpeed = Config.JumpAccelerationSpeed,
            EnableGravityMod = Config.EnableGravityMod,
            GravityScale = Config.GravityScale,
            EnableFrontalJump = Config.EnableFrontalJump,
            FrontalJumpSpeed = getgenv().FrontalJumpSpeed,
            RampMultiplier = getgenv().RampMultiplier,
            EnableRampMultiplier = Config.EnableRampMultiplier,
            RampMultiplierValue = getgenv().RampMultiplierValue,
            EnableFullBright = Config.EnableFullBright,
            EnableAutoTicket = Config.EnableAutoTicket,
            EnableVoidEscape = Config.EnableVoidEscape,
            EnableAfkMap     = Config.EnableAfkMap,
            EnableGagMap     = Config.EnableGagMap,
            EnableAntiAfk    = Config.EnableAntiAfk,
            EnableWhistleESP = Config.EnableWhistleESP,
            EnableReviveAura = Config.EnableReviveAura,
            EnableAutoSave   = Config.EnableAutoSave,
            EnableEspDown    = Config.EnableEspDown,
            EnableAutoCarry = Config.EnableAutoCarry,
            CarryRange    = Config.CarryRange,
            CarryInterval = Config.CarryInterval,
            EnableAutoForceSpawn = Config.EnableAutoForceSpawn,
            EnableAntiBot = Config.EnableAntiBot,
            AntiBotDistance = Config.AntiBotDistance,
            AntiBotCooldown = Config.AntiBotCooldown,
            EnableAutoTrimp = Config.EnableAutoTrimp,
            AutoTrimpMultiplier = Config.AutoTrimpMultiplier,
            AutoTrimpFallSpeed = Config.AutoTrimpFallSpeed,
            EnableTrimpTeleport = Config.EnableTrimpTeleport,
            EnableSpeedMultiplier = Config.EnableSpeedMultiplier,
            SpeedMultiplierValue = Config.SpeedMultiplierValue,
            EnableEmoteSpeed = Config.EnableEmoteSpeed,
            EmoteSpeedMultiplier = Config.EmoteSpeedMultiplier,
            EnableLayerJumps = Config.EnableLayerJumps,
            LayerJumpsCount = Config.LayerJumpsCount,
            EnableImpulseJump = Config.EnableImpulseJump,
            ImpulseJumpSpeed = Config.ImpulseJumpSpeed,
            EnableBackJump = Config.EnableBackJump,
            BackJumpSpeed = getgenv().BackJumpSpeed,
            BackRampMultiplier = getgenv().BackRampMultiplier,
            EnableFigure8  = Config.EnableFigure8,
            Figure8Speed   = Config.Figure8Speed,
            Figure8Radius  = Config.Figure8Radius,
            EnableLissajous  = Config.EnableLissajous,
            LissajousSpeed   = Config.LissajousSpeed,
            LissajousRadius  = Config.LissajousRadius,
            EnableSpiro      = Config.EnableSpiro,
            SpiroSpeed       = Config.SpiroSpeed,
            SpiroRadius      = Config.SpiroRadius,
            SpiroRatio       = Config.SpiroRatio,
        }
        writefile(SettingsFile, HttpService:JSONEncode(data))
    end)
end

function SaveSettings()
    if getgenv().PerplexSaveQueued then
        return
    end
    getgenv().PerplexSaveQueued = true
    task.delay(0.4, function()
        getgenv().PerplexSaveQueued = false
        writeSettingsFile()
    end)
end

function LoadSettings()
    local ok, result = pcall(function()
        if isfile and isfile(SettingsFile) then
            local content = readfile(SettingsFile)
            if content and content ~= "" then
                return HttpService:JSONDecode(content)
            end
        end
        return nil
    end)

    if ok and result then
        if result.EnableTeleportWalk ~= nil then Config.EnableTeleportWalk = result.EnableTeleportWalk end
        if result.TeleportMovementSpeed ~= nil then Config.TeleportMovementSpeed = result.TeleportMovementSpeed end
        if result.EnableEnhancedJump ~= nil then Config.EnableEnhancedJump = result.EnableEnhancedJump end
        if result.JumpHeight ~= nil then Config.JumpHeight = result.JumpHeight end
        if result.EnableInfiniteSlide ~= nil then Config.EnableInfiniteSlide = result.EnableInfiniteSlide end
        if result.InfiniteSlideSpeed ~= nil then Config.InfiniteSlideSpeed = math.clamp(result.InfiniteSlideSpeed, 15, 150) end
        if result.EnableInfiniteSlideOld ~= nil then Config.EnableInfiniteSlideOld = result.EnableInfiniteSlideOld end
        if result.InfiniteSlideSpeedOld ~= nil then Config.InfiniteSlideSpeedOld = math.clamp(result.InfiniteSlideSpeedOld, 15, 150) end
        if result.AutoJump ~= nil then Config.AutoJump = result.AutoJump end
        if result.AutoJumpSpeed ~= nil then Config.AutoJumpSpeed = math.clamp(tonumber(result.AutoJumpSpeed) or 1.5, 0.5, 8) end
        if result.AutoCrouch ~= nil then Config.AutoCrouch = result.AutoCrouch end
        if result.AutoCrouchSpeed ~= nil then Config.AutoCrouchSpeed = math.clamp(tonumber(result.AutoCrouchSpeed) or 1.5, 0.5, 24) end
        if result.EnableJumpAcceleration ~= nil then Config.EnableJumpAcceleration = result.EnableJumpAcceleration end
        if result.JumpAccelerationSpeed ~= nil then Config.JumpAccelerationSpeed = math.clamp(tonumber(result.JumpAccelerationSpeed) or 42, 30, 110) end
        if result.EnableGravityMod ~= nil then Config.EnableGravityMod = result.EnableGravityMod end
        if result.GravityScale ~= nil then Config.GravityScale = result.GravityScale end
        if result.EnableFrontalJump ~= nil then Config.EnableFrontalJump = result.EnableFrontalJump end
        if result.FrontalJumpSpeed ~= nil then getgenv().FrontalJumpSpeed = result.FrontalJumpSpeed end
        if result.RampMultiplier ~= nil then getgenv().RampMultiplier = result.RampMultiplier end
        if result.EnableRampMultiplier ~= nil then Config.EnableRampMultiplier = result.EnableRampMultiplier end
        if result.RampMultiplierValue ~= nil then getgenv().RampMultiplierValue = result.RampMultiplierValue end
        if result.EnableFullBright ~= nil then Config.EnableFullBright = result.EnableFullBright end
        if result.EnableAutoTicket ~= nil then Config.EnableAutoTicket = result.EnableAutoTicket end
        if result.EnableVoidEscape ~= nil then Config.EnableVoidEscape = result.EnableVoidEscape end
        if result.EnableAfkMap     ~= nil then Config.EnableAfkMap     = result.EnableAfkMap     end
        if result.EnableGagMap     ~= nil then Config.EnableGagMap     = result.EnableGagMap     end
        if result.EnableAntiAfk    ~= nil then Config.EnableAntiAfk    = result.EnableAntiAfk    end
        if result.EnableWhistleESP ~= nil then Config.EnableWhistleESP = result.EnableWhistleESP end
        if result.EnableReviveAura ~= nil then Config.EnableReviveAura = result.EnableReviveAura end
        if result.EnableAutoSave   ~= nil then Config.EnableAutoSave   = result.EnableAutoSave   end
        if result.EnableEspDown    ~= nil then Config.EnableEspDown    = result.EnableEspDown    end
        if result.EnableAutoCarry ~= nil then Config.EnableAutoCarry = result.EnableAutoCarry end
        if result.CarryRange    ~= nil then Config.CarryRange    = result.CarryRange    end
        if result.CarryInterval ~= nil then Config.CarryInterval = result.CarryInterval end
        if result.EnableAutoForceSpawn ~= nil then Config.EnableAutoForceSpawn = result.EnableAutoForceSpawn end
        if result.EnableAntiBot ~= nil then Config.EnableAntiBot = result.EnableAntiBot end
        if result.AntiBotDistance ~= nil then Config.AntiBotDistance = result.AntiBotDistance end
        if result.AntiBotCooldown ~= nil then Config.AntiBotCooldown = result.AntiBotCooldown end
        if result.EnableAutoTrimp ~= nil then Config.EnableAutoTrimp = result.EnableAutoTrimp end
        if result.AutoTrimpMultiplier ~= nil then Config.AutoTrimpMultiplier = result.AutoTrimpMultiplier end
        if result.AutoTrimpFallSpeed ~= nil then Config.AutoTrimpFallSpeed = result.AutoTrimpFallSpeed end
        if result.EnableTrimpTeleport ~= nil then Config.EnableTrimpTeleport = result.EnableTrimpTeleport end
        if result.EnableSpeedMultiplier ~= nil then Config.EnableSpeedMultiplier = result.EnableSpeedMultiplier end
        if result.SpeedMultiplierValue ~= nil then Config.SpeedMultiplierValue = result.SpeedMultiplierValue end
        if result.EnableEmoteSpeed ~= nil then Config.EnableEmoteSpeed = result.EnableEmoteSpeed end
        if result.EmoteSpeedMultiplier ~= nil then Config.EmoteSpeedMultiplier = result.EmoteSpeedMultiplier end
        if result.EnableLayerJumps ~= nil then Config.EnableLayerJumps = result.EnableLayerJumps end
        if result.LayerJumpsCount ~= nil then Config.LayerJumpsCount = result.LayerJumpsCount end
        if result.EnableImpulseJump ~= nil then Config.EnableImpulseJump = result.EnableImpulseJump end
        if result.ImpulseJumpSpeed ~= nil then Config.ImpulseJumpSpeed = math.clamp(tonumber(result.ImpulseJumpSpeed) or 42, 10, 120) end
        if result.EnableBackJump ~= nil then Config.EnableBackJump = result.EnableBackJump end
        if result.BackJumpSpeed ~= nil then getgenv().BackJumpSpeed = result.BackJumpSpeed end
        if result.BackRampMultiplier ~= nil then getgenv().BackRampMultiplier = result.BackRampMultiplier end
        if result.EnableFigure8  ~= nil then Config.EnableFigure8  = result.EnableFigure8 end
        if result.Figure8Speed   ~= nil then Config.Figure8Speed   = math.clamp(tonumber(result.Figure8Speed)  or 1.5, 0.2, 3.0) end
        if result.Figure8Radius  ~= nil then Config.Figure8Radius  = math.clamp(tonumber(result.Figure8Radius) or 8,   3,   25)  end
        if result.EnableLissajous  ~= nil then Config.EnableLissajous  = result.EnableLissajous end
        if result.LissajousSpeed   ~= nil then Config.LissajousSpeed   = math.clamp(tonumber(result.LissajousSpeed)  or 1.5, 0.2, 3.0) end
        if result.LissajousRadius  ~= nil then Config.LissajousRadius  = math.clamp(tonumber(result.LissajousRadius) or 8,   3,   25)  end
        if result.EnableSpiro  ~= nil then Config.EnableSpiro  = result.EnableSpiro end
        if result.SpiroSpeed   ~= nil then Config.SpiroSpeed   = math.clamp(tonumber(result.SpiroSpeed)  or 0.8, 0.1, 2.0)  end
        if result.SpiroRadius  ~= nil then Config.SpiroRadius  = math.clamp(tonumber(result.SpiroRadius) or 12,  5,   30)   end
        if result.SpiroRatio   ~= nil then Config.SpiroRatio   = math.clamp(tonumber(result.SpiroRatio)  or 0.35, 0.1, 0.9) end
        print("SETTINGS: Previous configuration loaded successfully")
    else
        print("SETTINGS: No saved configuration found, using defaults")
    end
end

LoadSettings()

fullBrightHooks.SaveSettings = SaveSettings

currentSpeed = Config.EnableJumpAcceleration and Config.JumpAccelerationSpeed or getgenv().FrontalJumpSpeed

backCurrentSpeed = getgenv().BackJumpSpeed

print("CONFIGURATION: Initialized")

print("\nCreating PerplexWare interface...")

Window = Library:CreateWindow({
    Title = "PXW | dsc.gg/PerplexWare",
    Version = "V1 (Bugged)",
    Icon = "sparkles",
    Style = "OperaGX",
    AutoScale = true,
    Size = Vector2.new(800, 400),
    Scale = 1,
    Folder = "PerplexWare",
    MenuKey = Enum.KeyCode.RightControl,
    Status = "Evade",
    AdvancedSettings = false,
    Theme = PerplexTheme,
})

PerplexUI = {
    Tabs = {},
    Sections = {},
    SectionTitles = {},
    SideFlip = {},
    LastAction = {},
    LastRisk = {},
    LastNoted = {},
    Features = {},
}
getgenv().PerplexUI = PerplexUI

PerplexRisk = {
    ["Speed Multiplier"] = "Risk: speed changes can get you flagged.",
    ["Teleport Walk"] = "Risk: teleport movement is easy to detect.",
    ["Jump Height"] = "Risk: abnormal jumps can get you flagged.",
    ["Infinite Slide"] = "Risk: boosted slide speed may be flagged.",
    ["Infinite Slide (Old)"] = "Risk: boosted slide speed may be flagged.",
    ["Auto Jump"] = "Risk: inhuman jump timing may be flagged.",
    ["Crouch"] = "Risk: inhuman crouch timing may be flagged.",
    ["Jump Acceleration"] = "Risk: changed air speed may be flagged.",
    ["Layer Jumps"] = "Risk: extra air jumps may be flagged.",
    ["Impulse Jump"] = "Risk: forced air speed may be flagged.",
    ["Frontal Jump"] = "Risk: forced air speed may be flagged.",
    ["Ramp Boost"] = "Risk: boosted ramp speed may be flagged.",
    ["Back Jump"] = "Risk: forced air speed may be flagged.",
    ["Gravity"] = "Risk: gravity changes may be flagged.",
    ["Auto Trimp"] = "Risk: boosted bounce speed may be flagged.",
    ["Trimp + Walk"] = "Risk: teleport movement is easy to detect.",
    ["Figure-8 Loop"] = "High risk: constant teleport loop.",
    ["Lissajous 3:2"] = "High risk: constant teleport loop.",
    ["Spirograph"] = "High risk: constant teleport loop.",
    ["Auto Ticket"] = "Risk: teleports to tickets, may be flagged.",
    ["Void Escape"] = "Risk: launches you high into the air.",
    ["AFK Map"] = "Loads an external map file.",
    ["Grow a Garden"] = "Risk: downloads and runs an external map script.",
    ["Remove Walls"] = "Risk: deletes map walls, may be flagged.",
    ["Auto Spawn"] = "Risk: fires the spawn remote automatically.",
    ["Anti Bot"] = "Risk: teleports you around the map.",
    ["Revive"] = "Risk: automatic revives may be flagged.",
    ["Auto Save"] = "Risk: teleports to downed players.",
    ["Carry"] = "Risk: automatic pickups may be flagged.",
    ["Emote Speed"] = "Risk: changed emote speed may be flagged.",
    ["Force Spawn"] = "Risk: fires the spawn remote.",
    ["Lag Switch"] = "Risk: freezes your game for 1 second.",
}
getgenv().PerplexRisk = PerplexRisk

PerplexSliderSteps = {
    ["Jump Count"] = 1,
}

PerplexTones = {
    Success = Color3.fromRGB(28, 130, 78),
    Warning = Color3.fromRGB(176, 110, 8),
    Danger = Color3.fromRGB(190, 42, 42),
    Muted = Color3.fromRGB(100, 100, 108),
}

function copyToClipboard(text, label)
    if setclipboard then
        setclipboard(text)
        Window:Notify({ Title = "Copied", Content = label .. " copied to the clipboard", Type = "Success", Duration = 2 })
    else
        Window:Notify({ Title = "Clipboard", Content = "setclipboard is not available here", Type = "Warning", Duration = 3 })
    end
end

function makeFlagName(...)
    local joined = (table.concat({ ... }, "_"):gsub("[^%w_]", ""))
    PerplexUI.FlagCounts = PerplexUI.FlagCounts or {}
    local count = (PerplexUI.FlagCounts[joined] or 0) + 1
    PerplexUI.FlagCounts[joined] = count
    if count > 1 then
        return joined .. "_" .. count
    end
    return joined
end

function escapeRichText(text)
    return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function setToneText(paragraph, text, tone)
    local color = PerplexTones[tone] or PerplexTones.Muted
    paragraph:SetText(string.format('<font color="#%s">%s</font>', color:ToHex(), escapeRichText(text)))
end

function inferSliderStep(minValue, maxValue)
    local range = maxValue - minValue
    if range >= 20 then
        return 1
    end
    if range >= 3 then
        return 0.1
    end
    return 0.05
end

function refreshActiveFeatures()
    if not PerplexUI.ActiveParagraph then
        return
    end

    local grouped = {}
    local counts = {}
    local total = 0
    for _, entry in ipairs(PerplexUI.Features) do
        if entry.Element.Value then
            grouped[entry.Tab] = grouped[entry.Tab] or {}
            table.insert(grouped[entry.Tab], entry.Name)
            counts[entry.Tab] = (counts[entry.Tab] or 0) + 1
            total = total + 1
        end
    end

    local lines = {}
    for _, tabKey in ipairs({ "Move", "Map", "Extra", "Emote", "Avatar" }) do
        if grouped[tabKey] then
            table.insert(lines, tabKey .. " tab: " .. table.concat(grouped[tabKey], ", "))
        end
        Window:SetBadge(tabKey, counts[tabKey], "Accent")
    end

    PerplexUI.ActiveBar:SetRange(0, math.max(#PerplexUI.Features, 1))
    PerplexUI.ActiveBar:Set(total, true)
    PerplexUI.ActiveParagraph:SetText(#lines > 0 and table.concat(lines, "\n") or "No features enabled.")
end

function registerFeature(tabKey, name, element)
    table.insert(PerplexUI.Features, { Tab = tabKey, Name = name, Element = element })
    element:OnChanged(refreshActiveFeatures)
end

function addTabInfo(tabKey, text)
    local section = PerplexUI.Tabs[tabKey]:AddSection({ Title = "Info", Icon = "info", Side = "Left" })
    section:AddParagraph({ Title = tabKey .. " tab", Content = text })
    PerplexUI.SideFlip[tabKey] = true
    return section
end

function addTabHeader(tabKey, title, size)
    if size and size < 14 then
        return PerplexUI.Sections[tabKey]
    end

    local side = PerplexUI.SideFlip[tabKey] and "Right" or "Left"
    PerplexUI.SideFlip[tabKey] = not PerplexUI.SideFlip[tabKey]

    local section = PerplexUI.Tabs[tabKey]:AddSection({ Title = title, Side = side })
    PerplexUI.Sections[tabKey] = section
    PerplexUI.SectionTitles[tabKey] = title
    PerplexUI.LastAction[tabKey] = nil
    PerplexUI.LastRisk[tabKey] = nil
    PerplexUI.LastNoted[tabKey] = nil
    return section
end

function ensureTabSection(tabKey)
    if not PerplexUI.Sections[tabKey] then
        addTabHeader(tabKey, tabKey, 14)
    end
    return PerplexUI.Sections[tabKey]
end

function addTabNote(tabKey, text)
    local last = PerplexUI.LastAction[tabKey]
    if last and not PerplexUI.LastNoted[tabKey] then
        local risk = PerplexUI.LastRisk[tabKey]
        last:SetDescription(risk and (text .. "\n" .. risk) or text)
        PerplexUI.LastNoted[tabKey] = true
        return last
    end
    return ensureTabSection(tabKey):AddLabel({ Text = text, Icon = "info" })
end

function addTabToggle(tabKey, text, default, callback)
    local section = ensureTabSection(tabKey)
    local risk = PerplexRisk[text]
    local element = section:AddToggle({
        Text = text,
        Description = risk,
        Default = default and true or false,
        Flag = makeFlagName(tabKey, PerplexUI.SectionTitles[tabKey], text),
        Callback = callback,
    })
    PerplexUI.LastAction[tabKey] = element
    PerplexUI.LastRisk[tabKey] = risk
    PerplexUI.LastNoted[tabKey] = false
    registerFeature(tabKey, text, element)
    return element
end

function addTabSlider(tabKey, text, minValue, maxValue, default, callback)
    local section = ensureTabSection(tabKey)
    return section:AddSlider({
        Text = text,
        Min = minValue,
        Max = maxValue,
        Step = PerplexSliderSteps[text] or inferSliderStep(minValue, maxValue),
        Default = math.clamp(tonumber(default) or minValue, minValue, maxValue),
        Flag = makeFlagName(tabKey, PerplexUI.SectionTitles[tabKey], text),
        Callback = callback,
    })
end

function addTabButton(tabKey, text, callback)
    local section = ensureTabSection(tabKey)
    local risk = PerplexRisk[text]
    local element = section:AddButton({
        Text = text,
        Description = risk,
        Callback = callback,
    })
    PerplexUI.LastAction[tabKey] = element
    PerplexUI.LastRisk[tabKey] = risk
    PerplexUI.LastNoted[tabKey] = false
    return element
end

function addTabLabel(tabKey, text, icon)
    return ensureTabSection(tabKey):AddLabel({ Text = text, Icon = icon })
end

function addTabTextBox(tabKey, text, placeholder, callback)
    return ensureTabSection(tabKey):AddTextBox({
        Text = text,
        Placeholder = placeholder,
        Internal = true,
        Callback = callback,
    })
end

PerplexUI.Tabs.Move = Window:AddTab({ Title = "Move", Icon = "gauge" })
PerplexUI.Tabs.Map = Window:AddTab({ Title = "Map", Icon = "map" })
PerplexUI.Tabs.Extra = Window:AddTab({ Title = "Extra", Icon = "sparkles" })
PerplexUI.Tabs.Emote = Window:AddTab({ Title = "Emote", Icon = "smile" })
PerplexUI.Tabs.Avatar = Window:AddTab({ Title = "Avatar", Icon = "user" })
PerplexUI.Tabs.All = Window:AddTab({ Title = "All", Icon = "layout-grid" })

addTabInfo("Move", "Speed, jumps, slides and path loops.\nMost options here are risky.")
addTabInfo("Map", "Lighting, map spawns, teleports and ESP.")
addTabInfo("Extra", "Walls, bots, revive, carry and spawn tools.\nSome options teleport you.")
addTabInfo("Emote", "Swap visual emotes and play emote animations.")
addTabInfo("Avatar", "Change your visual avatar and body parts.")
addTabInfo("All", "Test cosmetic models and auras on your rig.")

do
    local activeSection = PerplexUI.Tabs.Move:AddSection({ Title = "Active Features", Icon = "activity", Side = "Right" })
    PerplexUI.ActiveBar = activeSection:AddProgressBar({
        Text = "Features On",
        Min = 0,
        Max = 1,
        Format = function(value)
            return string.format("%d / %d", math.floor(value), #PerplexUI.Features)
        end,
    })
    PerplexUI.ActiveParagraph = activeSection:AddParagraph({ Title = "Enabled now", Content = "No features enabled." })

    local discordSection = PerplexUI.Tabs.Move:AddSection({ Title = "Discord", Icon = "message-circle", Side = "Right" })
    discordSection:AddLabel({ Text = "dsc.gg/perplexware", Icon = "link" })
    discordSection:AddButton({
        Text = "Copy Discord Invite",
        Primary = true,
        NoBind = true,
        Internal = true,
        Callback = function()
            copyToClipboard("https://dsc.gg/perplexware/", "Discord invite")
        end,
    })
    PerplexUI.SideFlip.Move = false
end

do
local AvatarStatusParagraph
local AvatarUsernameBox

function SetAvatarStatus(text, tone)
    if AvatarStatusParagraph then
        setToneText(AvatarStatusParagraph, text, tone)
    end
end

function GetAvatarVisualHumanoid()
    local rigsFolder = workspace:FindFirstChild("Rigs")
    local visualRig = rigsFolder and rigsFolder:FindFirstChild(Players.LocalPlayer.Name)
    local humanoid = visualRig and visualRig:FindFirstChildOfClass("Humanoid")
    return visualRig, humanoid
end

function ApplyAvatarByUsername()
    local username = tostring(AvatarUsernameBox.Value or ""):match("^%s*(.-)%s*$")
    if username == "" then
        SetAvatarStatus("Enter a username.", "Danger")
        return
    end

    local visualRig, visualHumanoid = GetAvatarVisualHumanoid()
    if not visualRig or not visualHumanoid then
        SetAvatarStatus("The visual R6 rig was not found.", "Danger")
        return
    end
    if visualHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
        SetAvatarStatus("The visual rig is not R6.", "Danger")
        return
    end

    SetAvatarStatus("Loading " .. username .. "'s avatar...", "Muted")
    local okUser, userIdOrError = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if not okUser then
        SetAvatarStatus("That user was not found.", "Danger")
        return
    end

    local okDescription, descriptionOrError = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userIdOrError)
    end)
    if not okDescription then
        SetAvatarStatus("The avatar could not be loaded.", "Danger")
        return
    end

    local okApply, applyError = pcall(function()

        visualHumanoid:ApplyDescriptionReset(descriptionOrError)
    end)
    if not okApply then
        SetAvatarStatus("The avatar could not be applied.", "Danger")
        warn("[Avatar] ApplyDescriptionReset error:", applyError)
        return
    end

    SetAvatarStatus(username .. "'s avatar was applied. Enter another name to change it.", "Success")
end

addTabHeader("Avatar", "Avatar Change", 14)
AvatarUsernameBox = addTabTextBox("Avatar", "Username", "Enter a player username", function(text, enterPressed)
    if enterPressed then
        ApplyAvatarByUsername()
    end
end)
addTabButton("Avatar", "Apply Avatar", ApplyAvatarByUsername)
AvatarStatusParagraph = PerplexUI.Sections.Avatar:AddParagraph({ Title = "Status", Content = "Enter a username and apply it.", RichText = true })

addTabHeader("Avatar", "Custom Body Parts", 14)
local CustomBodyPartState = {
    Saved = {},
    HeadlessFallback = {
        Active = false,
        HeadTransparency = nil,
        FaceTransparency = nil,
    },
}

local CustomBodyParts = {
    Korblox = {
        English = "Korblox Right Leg",
        Property = "RightLeg",
        AssetId = 139607718,
    },
    Headless = {
        English = "Headless Invisible Head",
        Property = "Head",
        AssetId = 15093053680,
    },
}

function SetHeadlessFallback(visualRig, enabled)
    local head = visualRig and visualRig:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then
        return false
    end

    local face = head:FindFirstChild("face")
    if enabled then
        if not CustomBodyPartState.HeadlessFallback.Active then
            CustomBodyPartState.HeadlessFallback.HeadTransparency = head.LocalTransparencyModifier
            CustomBodyPartState.HeadlessFallback.FaceTransparency = face and face:IsA("Decal") and face.Transparency or nil
        end
        head.LocalTransparencyModifier = 1
        if face and face:IsA("Decal") then
            face.Transparency = 1
        end
        CustomBodyPartState.HeadlessFallback.Active = true
    else
        head.LocalTransparencyModifier = CustomBodyPartState.HeadlessFallback.HeadTransparency or 0
        if face and face:IsA("Decal") and CustomBodyPartState.HeadlessFallback.FaceTransparency ~= nil then
            face.Transparency = CustomBodyPartState.HeadlessFallback.FaceTransparency
        end
        CustomBodyPartState.HeadlessFallback = {
            Active = false,
            HeadTransparency = nil,
            FaceTransparency = nil,
        }
    end
    return true
end

function ApplyCustomBodyPart(partInfo, enabled)
    local visualRig, visualHumanoid = GetAvatarVisualHumanoid()
    if not visualRig or not visualHumanoid then
        SetAvatarStatus("The visual R6 rig was not found.", "Danger")
        return false
    end
    if visualHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
        SetAvatarStatus("Custom parts require the visual R6 rig.", "Danger")
        return false
    end

    local okDescription, descriptionOrError = pcall(function()
        return visualHumanoid:GetAppliedDescription()
    end)
    if not okDescription or not descriptionOrError then
        SetAvatarStatus("The current avatar description could not be read.", "Danger")
        warn("[Avatar] GetAppliedDescription error:", descriptionOrError)
        return false
    end

    if enabled then
        if CustomBodyPartState.Saved[partInfo.Property] == nil then
            CustomBodyPartState.Saved[partInfo.Property] = descriptionOrError[partInfo.Property]
        end
        descriptionOrError[partInfo.Property] = partInfo.AssetId
        SetAvatarStatus("Applying " .. partInfo.English .. "...", "Muted")
    else
        descriptionOrError[partInfo.Property] = CustomBodyPartState.Saved[partInfo.Property] or 0
        CustomBodyPartState.Saved[partInfo.Property] = nil
        if partInfo.Property == "Head" and CustomBodyPartState.HeadlessFallback.Active then
            SetHeadlessFallback(visualRig, false)
        end
    end

    local okApply, applyError = pcall(function()
        visualHumanoid:ApplyDescriptionReset(descriptionOrError)
    end)
    if not okApply then
        if enabled and partInfo.Property == "Head" and SetHeadlessFallback(visualRig, true) then
            SetAvatarStatus("Headless fallback applied locally.", "Success")
            warn("[Avatar] Headless Dynamic Head fallback used:", applyError)
            return true
        end
        SetAvatarStatus("The body part could not be applied.", "Danger")
        warn("[Avatar] ApplyDescriptionReset error:", applyError)
        return false
    end

    SetAvatarStatus(enabled and "Body part applied to the visual rig." or "Body part restored.", enabled and "Success" or "Muted")
    return true
end

local KorbloxRightLegToggle
local HeadlessHeadToggle

KorbloxRightLegToggle = addTabToggle("Avatar", CustomBodyParts.Korblox.English, false, function(enabled)
    local ok = ApplyCustomBodyPart(CustomBodyParts.Korblox, enabled)
    if not ok and enabled then
        KorbloxRightLegToggle:Set(false, true)
    end
end)

HeadlessHeadToggle = addTabToggle("Avatar", CustomBodyParts.Headless.English, false, function(enabled)
    local ok = ApplyCustomBodyPart(CustomBodyParts.Headless, enabled)
    if not ok and enabled then
        HeadlessHeadToggle:Set(false, true)
    end
end)
end

print("\nConfiguring Move tab...")

local lastSpeedSelf, lastSpeedState, lastSpeedValue = nil, nil, nil
getgenv().PerplexSpeedRestoreRequested = false
getgenv().PerplexRestoreSpeedMultiplier = nil

addTabHeader("Move", "Speed Multiplier", 14)

addTabToggle("Move", "Speed Multiplier", Config.EnableSpeedMultiplier, function(state)
    Config.EnableSpeedMultiplier = state
    print(state and "Speed Multiplier ENABLED" or "X Speed Multiplier DISABLED")
    if state then
        getgenv().PerplexSpeedRestoreRequested = false
        getgenv().PerplexSpeedApplyRequested = true
        if getgenv().PerplexApplySpeedMultiplier then
            getgenv().PerplexApplySpeedMultiplier()
        end
    else
        getgenv().PerplexSpeedRestoreRequested = true
        if getgenv().PerplexRestoreSpeedMultiplier then
            getgenv().PerplexRestoreSpeedMultiplier()
        end
    end
    SaveSettings()
end)

addTabSlider("Move", "Speed Value", 1, 5, Config.SpeedMultiplierValue, function(value)
        Config.SpeedMultiplierValue = value
        if Config.EnableSpeedMultiplier and getgenv().PerplexApplySpeedMultiplier then
            getgenv().PerplexSpeedApplyRequested = true
            getgenv().PerplexApplySpeedMultiplier()
        end
        print("Speed Multiplier value: " .. value)
        SaveSettings()
    end)

addTabHeader("Move", "Basic Movement", 14)

addTabToggle("Move", "Teleport Walk", Config.EnableTeleportWalk, function(state)
    Config.EnableTeleportWalk = state
    print(state and "Teleport Walk ENABLED" or "X Teleport Walk DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Teleport Speed", 1, 50, Config.TeleportMovementSpeed, function(value)
        Config.TeleportMovementSpeed = value
        print("Teleport speed: " .. value)
        SaveSettings()
    end)

addTabHeader("Move", "Jump Height", 14)

addTabToggle("Move", "Jump Height", Config.EnableEnhancedJump, function(state)
    Config.EnableEnhancedJump = state
    print(state and "Enhanced Jump ENABLED" or "X Enhanced Jump DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Jump Height", 20, 300, Config.JumpHeight, function(value)
        Config.JumpHeight = value
        print("Jump height: " .. value)
        SaveSettings()
    end)

addTabHeader("Move", "Infinite Slide", 14)

addTabToggle("Move", "Infinite Slide", Config.EnableInfiniteSlide, function(state)
    Config.EnableInfiniteSlide = state
    print(state and "Infinite Slide ENABLED" or "X Infinite Slide DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Slide Speed", 15, 150, Config.InfiniteSlideSpeed, function(value)
        Config.InfiniteSlideSpeed = math.clamp(math.floor(value), 15, 150)
        print("Infinite Slide speed: " .. Config.InfiniteSlideSpeed)
        SaveSettings()
    end)

addTabNote("Move", "Maintains the slide while the slide input is held")

addTabHeader("Move", "Infinite Slide (Old)", 14)

addTabToggle("Move", "Infinite Slide (Old)", Config.EnableInfiniteSlideOld, function(state)
    Config.EnableInfiniteSlideOld = state
    print(state and "Slide Inf OLD ENABLED" or "Slide Inf OLD DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Slide Speed Old", 15, 150, Config.InfiniteSlideSpeedOld, function(value)
        Config.InfiniteSlideSpeedOld = math.clamp(math.floor(value), 15, 150)
        print("Infinite Slide OLD speed: " .. Config.InfiniteSlideSpeedOld)
        SaveSettings()
    end)

addTabNote("Move", "Previous slide version: direct velocity without BodyVelocity or surface projection")

addTabHeader("Move", "Auto Jump", 14)

addTabToggle("Move", "Auto Jump", Config.AutoJump, function(state)
    Config.AutoJump = state
    if not state then
        autoJumpNextTime = 0
    end
    print(state and "Auto Jump ENABLED" or "X Auto Jump DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Auto Jump Speed", 0.5, 8, Config.AutoJumpSpeed, function(value)
        Config.AutoJumpSpeed = math.clamp(tonumber(value) or 1.5, 0.5, 8)
        print("Auto Jump speed: " .. string.format("%.2f", Config.AutoJumpSpeed) .. " jumps/s")
        SaveSettings()
    end)

addTabNote("Move", "Jumps per second; a higher value makes it jump faster")

addTabHeader("Move", "Crouch", 14)

addTabToggle("Move", "Crouch", Config.AutoCrouch, function(state)
    Config.AutoCrouch = state
    if not state then
        autoCrouchNextTime = 0
    end
    print(state and "Auto Crouch ENABLED" or "X Auto Crouch DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Crouch Speed", 0.5, 24, Config.AutoCrouchSpeed, function(value)
        Config.AutoCrouchSpeed = math.clamp(tonumber(value) or 1.5, 0.5, 24)
        print("Auto Crouch speed: " .. string.format("%.2f", Config.AutoCrouchSpeed) .. " toggles/s")
        SaveSettings()
    end)

addTabHeader("Move", "Jump Acceleration", 14)

addTabToggle("Move", "Jump Acceleration", Config.EnableJumpAcceleration, function(state)
    Config.EnableJumpAcceleration = state
    lastJumpTime = tick()
    currentSpeed = Config.JumpAccelerationSpeed
    print(state and "Jump Acceleration ENABLED" or "X Jump Acceleration DISABLED")
    SaveSettings()
end)

local JumpAccelerationSpeedSlider = addTabSlider("Move", "Jump Acceleration", 30, 110, Config.JumpAccelerationSpeed, function(value)
        Config.JumpAccelerationSpeed = math.clamp(tonumber(value) or 42, 30, 110)
        if Config.EnableJumpAcceleration then currentSpeed = Config.JumpAccelerationSpeed end
        print("Jump Acceleration Speed: " .. Config.JumpAccelerationSpeed)
        SaveSettings()
    end)

addTabNote("Move", "No ramps")

addTabHeader("Move", "Layer Jumps", 14)

addTabToggle("Move", "Layer Jumps", Config.EnableLayerJumps, function(state)
    Config.EnableLayerJumps = state
    print(state and "Layer Jumps ENABLED" or "X Layer Jumps DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Jump Count", 2, 20, Config.LayerJumpsCount, function(value)
        Config.LayerJumpsCount = math.floor(value)
        print("Layer Jumps count: " .. Config.LayerJumpsCount)
        SaveSettings()
    end)

addTabHeader("Move", "Impulse Jump", 14)

addTabToggle("Move", "Impulse Jump", Config.EnableImpulseJump, function(state)
    Config.EnableImpulseJump = state
    print(state and "Impulse Jump ENABLED" or "X Impulse Jump DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Impulse Speed", 10, 120, Config.ImpulseJumpSpeed, function(value)
        Config.ImpulseJumpSpeed = value
        print("Impulse Jump speed: " .. string.format("%.0f", value))
        SaveSettings()
    end)

addTabHeader("Move", "Frontal Jump", 14)

addTabToggle("Move", "Frontal Jump", Config.EnableFrontalJump, function(state)
    Config.EnableFrontalJump = state
    if state then

        savedOptions.EnableTeleportWalk = Config.EnableTeleportWalk
        savedOptions.EnableEnhancedJump = Config.EnableEnhancedJump
        savedOptions.EnableGravityMod = Config.EnableGravityMod

        Config.EnableTeleportWalk = false
        Config.EnableEnhancedJump = false
        Config.EnableGravityMod = false

        lastJumpTime = tick()
        currentSpeed = getgenv().FrontalJumpSpeed
        airAccumulator = 0

        print("Frontal Jump ENABLED - Beta")
        print("   - Teleport Walk disabled")
        print("   - Enhanced Jump disabled")
        print("   - Gravity Mod disabled")
    else

        Config.EnableTeleportWalk = savedOptions.EnableTeleportWalk
        Config.EnableEnhancedJump = savedOptions.EnableEnhancedJump
        Config.EnableGravityMod = savedOptions.EnableGravityMod

        if activeBV then activeBV:Destroy() end
        activeBV = nil
        currentSpeed = getgenv().FrontalJumpSpeed

        print("X Frontal Jump DISABLED")
        print("   - Options restored")
    end
    SaveSettings()
end)

addTabSlider("Move", "Movement Speed", 30, 110, getgenv().FrontalJumpSpeed, function(value)
        getgenv().FrontalJumpSpeed = value
        currentSpeed = value
        print("Frontal Jump Speed: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Ramp Multiplier", 0.10, 5.0, getgenv().RampMultiplier, function(value)
        getgenv().RampMultiplier = value
        print("Ramp Multiplier: " .. value)
        SaveSettings()
    end)

addTabHeader("Move", "Ramp Multiplier", 14)

addTabToggle("Move", "Ramp Boost", Config.EnableRampMultiplier, function(state)
    Config.EnableRampMultiplier = state
    print(state and "Ramp Multiplier ENABLED (standalone)" or "X Ramp Multiplier DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Ramp Multiplier", 0.10, 5.0, getgenv().RampMultiplierValue, function(value)
        getgenv().RampMultiplierValue = value
        print("Ramp Multiplier (standalone): " .. value)
        SaveSettings()
    end)

addTabHeader("Move", "Back Jump", 14)

addTabToggle("Move", "Back Jump", Config.EnableBackJump, function(state)
    Config.EnableBackJump = state
    if state then
        backLastJumpTime = tick()
        backCurrentSpeed = getgenv().BackJumpSpeed
        backAirAccumulator = 0
        print("Back Jump ENABLED")
    else
        if backActiveBV then backActiveBV:Destroy() end
        backActiveBV = nil
        backCurrentSpeed = getgenv().BackJumpSpeed
        print("X Back Jump DISABLED")
    end
    SaveSettings()
end)

addTabSlider("Move", "Back Speed", 30, 110, getgenv().BackJumpSpeed, function(value)
        getgenv().BackJumpSpeed = value
        backCurrentSpeed = value
        print("Back Jump Speed: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Back Ramp Multiplier", 0, 5.0, getgenv().BackRampMultiplier, function(value)
        getgenv().BackRampMultiplier = value
        print("Back Ramp Multiplier: " .. value)
        SaveSettings()
    end)

addTabHeader("Move", "Gravity", 14)

addTabToggle("Move", "Gravity", Config.EnableGravityMod, function(state)
    Config.EnableGravityMod = state
    print(state and "Gravity Mod ENABLED" or "X Gravity Mod DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Gravity Scale", 0.1, 2, Config.GravityScale, function(value)
        Config.GravityScale = value
        print("Gravity Scale: " .. value)
        SaveSettings()
    end)

addTabHeader("Move", "Auto Trimp", 14)

addTabToggle("Move", "Auto Trimp", Config.EnableAutoTrimp, function(state)
    Config.EnableAutoTrimp = state
    print(state and "Auto Trimp ENABLED" or "X Auto Trimp DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Trimp Multiplier", 1.0, 10.0, Config.AutoTrimpMultiplier, function(value)
        Config.AutoTrimpMultiplier = value
        print("Trimp Multiplier: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Fall Speed", 0.1, 1.0, Config.AutoTrimpFallSpeed, function(value)
        Config.AutoTrimpFallSpeed = value
        print("Trimp Fall Speed: " .. value)
        SaveSettings()
    end)

addTabNote("Move", "Bounces off the ground with accumulated speed")

addTabHeader("Move", "Trimp + Teleport Walk", 14)

addTabToggle("Move", "Trimp + Walk", Config.EnableTrimpTeleport, function(state)
    Config.EnableTrimpTeleport = state
    print(state and "Trimp + Teleport Walk ENABLED" or "X Trimp + Teleport Walk DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Trimp Multiplier", 1.0, 10.0, Config.AutoTrimpMultiplier, function(value)
        Config.AutoTrimpMultiplier = value
        print("Trimp Multiplier: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Fall Speed", 0.1, 1.0, Config.AutoTrimpFallSpeed, function(value)
        Config.AutoTrimpFallSpeed = value
        print("Trimp Fall Speed: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Teleport Speed", 1, 50, Config.TeleportMovementSpeed, function(value)
        Config.TeleportMovementSpeed = value
        print("Teleport speed: " .. value)
        SaveSettings()
    end)

addTabNote("Move", "Combines trimp bounce and teleport walk")

addTabHeader("Move", "Figure-8 Movement", 14)

addTabToggle("Move", "Figure-8 Loop", Config.EnableFigure8, function(state)
    Config.EnableFigure8 = state
    if state then
        StartFigure8Loop()
    else
        StopFigure8Loop()
    end
    print(state and "Figure-8 Loop ENABLED" or "X Figure-8 Loop DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Speed", 0.2, 3.0, Config.Figure8Speed, function(value)
        Config.Figure8Speed = value
        print("Figure-8 Speed: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Radius (studs)", 3, 25, Config.Figure8Radius, function(value)
        Config.Figure8Radius = value
        print("Figure-8 Radius: " .. value)
        SaveSettings()
    end)

addTabNote("Move", "Traces a figure-8 around the activation point\nSpeed and radius adjustable in real-time")

addTabHeader("Move", "Lissajous 3:2 Curve", 14)

addTabToggle("Move", "Lissajous 3:2", Config.EnableLissajous, function(state)
    Config.EnableLissajous = state
    if state then
        StartLissajousLoop()
    else
        StopLissajousLoop()
    end
    print(state and "Lissajous Loop ENABLED" or "X Lissajous Loop DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Speed", 0.2, 3.0, Config.LissajousSpeed, function(value)
        Config.LissajousSpeed = value
        print("Lissajous Speed: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Radius (studs)", 3, 25, Config.LissajousRadius, function(value)
        Config.LissajousRadius = value
        print("Lissajous Radius: " .. value)
        SaveSettings()
    end)

addTabNote("Move", "6-crossing loop figure\nClassic oscilloscope pattern")

addTabHeader("Move", "Spirograph (Hypotrochoid)", 14)

addTabToggle("Move", "Spirograph", Config.EnableSpiro, function(state)
    Config.EnableSpiro = state
    if state then
        StartSpiroLoop()
    else
        StopSpiroLoop()
    end
    print(state and "Spirograph Loop ENABLED" or "X Spirograph Loop DISABLED")
    SaveSettings()
end)

addTabSlider("Move", "Speed", 0.1, 2.0, Config.SpiroSpeed, function(value)
        Config.SpiroSpeed = value
        print("Spiro Speed: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Outer Radius (studs)", 5, 30, Config.SpiroRadius, function(value)
        Config.SpiroRadius = value
        print("Spiro Radius: " .. value)
        SaveSettings()
    end)

addTabSlider("Move", "Inner Ratio", 0.1, 0.9, Config.SpiroRatio, function(value)
        Config.SpiroRatio = value
        print("Spiro Ratio: " .. value)
        SaveSettings()
    end)

addTabNote("Move", "Spirograph-style figure\nChange ratio for stars, roses and more shapes")

print("MOVE: Tab completed")

local AfkMapSpawnCFrame  = nil
local AfkMapRespawnConn  = nil
local AntiAfkConn        = nil
local AFk_MAP_FILE       = "pxw_map.json"
local AFK_MAP_URL        = "https://pastefy.app/wIFzavO5/raw"

function loadAfkMap()

    if isfile then
        local ok, raw = pcall(game.HttpGet, game, AFK_MAP_URL)
        if ok and raw and raw ~= "" then
            pcall(writefile, AFk_MAP_FILE, raw)
        end
    end
    if not isfile or not isfile(AFk_MAP_FILE) then return false, "File not found" end
    local ok, raw = pcall(readfile, AFk_MAP_FILE)
    if not ok then return false, "Error reading file" end
    local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    if not ok2 or not data or not data.parts then return false, "Invalid file" end

    local old = workspace:FindFirstChild("PerplexAfkMap")
    if old then old:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "PerplexAfkMap"
    folder.Parent = workspace
    local spawnCFrame = nil
    for _, p in ipairs(data.parts) do
        pcall(function()
            local part = Instance.new(p.t or "Part")
            part.Size = Vector3.new(p.sx, p.sy, p.sz)
            part.CFrame = CFrame.new(p.px, p.py, p.pz) * CFrame.Angles(math.rad(p.rx), math.rad(p.ry), math.rad(p.rz))
            part.Color = Color3.fromRGB(p.cr, p.cg, p.cb)
            pcall(function() part.Material = Enum.Material:GetEnumItems()[p.m] or Enum.Material.SmoothPlastic end)
            part.Transparency = p.tr or 0
            part.Anchored = p.an == 1
            part.CanCollide = p.ca == 1
            part.CastShadow = false
            part.Parent = folder
            if part:IsA("SpawnLocation") then
                spawnCFrame = part.CFrame
            end
        end)
    end

    AfkMapSpawnCFrame = (spawnCFrame or CFrame.new(0, 10, 0)) + Vector3.new(0, 5, 0)
    return true, data.count or #data.parts
end

function setAfkMapEnabled(state)
    Config.EnableAfkMap = state
    if state then

        if AfkMapSpawnCFrame then
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = AfkMapSpawnCFrame end
        end

        if AfkMapRespawnConn then AfkMapRespawnConn:Disconnect() end
        AfkMapRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Config.EnableAfkMap and AfkMapSpawnCFrame then
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then h.CFrame = AfkMapSpawnCFrame end
            end
        end)
    else
        if AfkMapRespawnConn then AfkMapRespawnConn:Disconnect() AfkMapRespawnConn = nil end
        AfkMapSpawnCFrame = nil
        local old = workspace:FindFirstChild("PerplexAfkMap")
        if old then old:Destroy() end
    end
    SaveSettings()
end

local GagMapCachedScript  = nil
local GagMapSpawnCFrame   = nil
local GagMapRespawnConn   = nil
local GAG_MAP_URL         = "https://api.rubis.app/v2/scrap/3myh0ngrEORmA71x/raw"
local GAG_MAP_FOLDER      = "__Perplex_GagMap"

function loadGagMap()

    if not GagMapCachedScript then
        local ok, raw = pcall(game.HttpGet, game, GAG_MAP_URL)
        if not ok or not raw or raw == "" then
            return false, "Error downloading the map"
        end
        GagMapCachedScript = raw
        print("[GagMap] Downloaded and cached (" .. #raw .. " bytes)")
    else
        print("[GagMap] Using in-memory cache (no re-download)")
    end

    local fn, compileErr = loadstring(GagMapCachedScript)
    if not fn then return false, "Compile error: " .. tostring(compileErr) end

    local old = workspace:FindFirstChild(GAG_MAP_FOLDER)
    if old then old:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = GAG_MAP_FOLDER
    folder.Parent = workspace

    local beforeSet = {}
    for _, child in ipairs(workspace:GetChildren()) do
        beforeSet[child] = true
    end

    local ok2, err2 = pcall(fn)
    if not ok2 then
        folder:Destroy()
        return false, "Runtime error: " .. tostring(err2)
    end

    local spawnCFrame = nil
    local count = 0
    for _, child in ipairs(workspace:GetChildren()) do
        if not beforeSet[child] and child ~= folder then
            if child:IsA("SpawnLocation") then
                spawnCFrame = child.CFrame
            end
            child.Parent = folder
            count = count + 1
        end
    end

    GagMapSpawnCFrame = (spawnCFrame or CFrame.new(-104.5, 0.5, -13.5)) + Vector3.new(0, 5, 0)
    return true, count
end

function setGagMapEnabled(state)
    Config.EnableGagMap = state
    if state then

        if GagMapSpawnCFrame then
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = GagMapSpawnCFrame end
        end

        if GagMapRespawnConn then GagMapRespawnConn:Disconnect() end
        GagMapRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Config.EnableGagMap and GagMapSpawnCFrame then
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then h.CFrame = GagMapSpawnCFrame end
            end
        end)
    else
        if GagMapRespawnConn then GagMapRespawnConn:Disconnect() GagMapRespawnConn = nil end
        GagMapSpawnCFrame = nil
        local old = workspace:FindFirstChild(GAG_MAP_FOLDER)
        if old then old:Destroy() end
    end
    SaveSettings()
end

function setAntiAfkEnabled(state)
    Config.EnableAntiAfk = state
    if state then
        if AntiAfkConn then return end
        AntiAfkConn = game:GetService("RunService").Heartbeat:Connect(function()
            if math.floor(os.clock()) % 60 == 0 then
                pcall(function()
                    game:GetService("VirtualInputManager"):SendMouseWheelEvent(0, 0, true, game)
                end)
            end
        end)
    else
        if AntiAfkConn then AntiAfkConn:Disconnect() AntiAfkConn = nil end
    end
    SaveSettings()
end

local playerEspRigService = nil
local playerEspWhistleTemplate = nil
local playerEspEntries = {}
local playerEspConnections = {}
local playerEspAccumulator = 0
local PLAYER_ESP_WHITE = Color3.fromRGB(255, 255, 255)
local PLAYER_ESP_RED = Color3.fromRGB(255, 70, 70)
local PLAYER_ESP_REFRESH = 0.10

pcall(function()
    local services = ReplicatedStorage:WaitForChild("Services", 5)
    local asset = services and services:WaitForChild("Asset", 5)
    local rigModule = asset and asset:WaitForChild("RigService", 5)
    if rigModule then
        playerEspRigService = require(rigModule)
    end
end)

pcall(function()
    local objects = ReplicatedStorage:WaitForChild("Objects", 5)
    local gameFolder = objects and objects:WaitForChild("Game", 5)
    local characterFolder = gameFolder and gameFolder:WaitForChild("Character", 5)
    local actionVisuals = characterFolder and characterFolder:WaitForChild("ActionVisuals", 5)
    local actions = actionVisuals and actionVisuals:WaitForChild("Actions", 5)
    local whistle = actions and actions:WaitForChild("Whistle", 5)
    playerEspWhistleTemplate = whistle and whistle:FindFirstChild("WhistleHighlight")
end)

function playerEspDisconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

function playerEspSetVisible(entry, visible)
    if entry.highlight then
        entry.highlight.Enabled = visible and Config.EnableWhistleESP
    end
    if entry.billboard then
        entry.billboard.Enabled = visible and Config.EnableWhistleESP
    end
end

function playerEspApplyColor(entry)
    if not entry or not entry.highlight then
        return
    end

    local color = entry.downed and PLAYER_ESP_RED or PLAYER_ESP_WHITE
    pcall(function()
        entry.highlight.FillColor = color
        entry.highlight.OutlineColor = color
    end)
end

function playerEspClearVisual(entry)
    if not entry then
        return
    end

    playerEspDisconnect(entry.died)
    entry.died = nil

    if entry.highlight then
        pcall(function()
            entry.highlight:Destroy()
        end)
        entry.highlight = nil
    end
    if entry.billboard then
        pcall(function()
            entry.billboard:Destroy()
        end)
        entry.billboard = nil
    end

    entry.label = nil
    entry.root = nil
    entry.visualRoot = nil
    entry.visualModel = nil
    entry.rigData = nil
    entry.downed = false
    entry.humanoid = nil
    entry.character = nil
end

function playerEspDestroyEntry(player)
    local entry = playerEspEntries[player]
    if not entry then
        return
    end

    playerEspDisconnect(entry.characterAdded)
    playerEspDisconnect(entry.characterRemoving)
    playerEspClearVisual(entry)
    playerEspEntries[player] = nil
end

function playerEspGetRigData(character)
    if not playerEspRigService or not character then
        return nil
    end

    local tag = character:GetAttribute("Tag")
    if not tag then
        return nil
    end

    local ok, rig = pcall(function()
        return playerEspRigService:GetRigFromTag(tag)
    end)
    if ok and rig and rig.Model and rig.Model:IsA("Model") then
        return rig
    end

    return nil
end

function playerEspResolveVisual(player, character)
    local rigData = playerEspGetRigData(character)
    local visualModel = rigData and rigData.Model or nil
    if visualModel then
        local visualRoot = visualModel:FindFirstChild("HumanoidRootPart", true)
            or visualModel.PrimaryPart
            or visualModel:FindFirstChildWhichIsA("BasePart", true)
        if visualRoot then
            return visualModel, visualRoot, rigData
        end
    end

    local playersFolder = Workspace:FindFirstChild("Players")
    visualModel = playersFolder and playersFolder:FindFirstChild(player.Name)
    if visualModel and visualModel:IsA("Model") then
        local visualRoot = visualModel:FindFirstChild("HumanoidRootPart", true)
            or visualModel.PrimaryPart
            or visualModel:FindFirstChildWhichIsA("BasePart", true)
        if visualRoot then
            return visualModel, visualRoot, nil
        end
    end

    local characterRoot = character and character:FindFirstChild("HumanoidRootPart")
    return character, characterRoot, nil
end

function playerEspIsDowned(rigData, character)
    if rigData and rigData.DataRegistry then
        local okDowned, downed = pcall(function()
            return rigData.DataRegistry:Get("Downed")
        end)
        if okDowned and downed == true then
            return true
        end

        local okState, state = pcall(function()
            return rigData.DataRegistry:Get("State")
        end)
        if okState and state == "Downed" then
            return true
        end
    end

    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health <= 0
end

function playerEspCreateEntry(player, character)
    if player == LocalPlayer then
        return
    end

    local entry = playerEspEntries[player]
    if not entry then
        entry = {}
        playerEspEntries[player] = entry
    else
        playerEspClearVisual(entry)
    end

    local characterRoot = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not characterRoot or not humanoid then
        return
    end

    local visualModel, visualRoot, rigData = playerEspResolveVisual(player, character)
    if not visualModel or not visualRoot then
        return
    end

    local downed = playerEspIsDowned(rigData, character)
    local oldHighlight = character:FindFirstChild("Beta_PlayerESP_WhistleHighlight")
    if oldHighlight then
        oldHighlight:Destroy()
    end
    local oldBillboard = visualRoot:FindFirstChild("Beta_PlayerESP_Label")
    if oldBillboard then
        oldBillboard:Destroy()
    end

    local highlight
    if playerEspWhistleTemplate then
        highlight = playerEspWhistleTemplate:Clone()
        highlight.Name = "Beta_PlayerESP_WhistleHighlight"
        highlight.Adornee = visualModel
        highlight.Enabled = Config.EnableWhistleESP
        highlight.Parent = character
    else
        highlight = Instance.new("Highlight")
        highlight.Name = "Beta_PlayerESP_WhistleHighlight_Fallback"
        highlight.Adornee = visualModel
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.Enabled = Config.EnableWhistleESP
        highlight.Parent = character
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Beta_PlayerESP_Label"
    billboard.Adornee = visualRoot
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    pcall(function()
        billboard.MaxDistance = math.huge
    end)
    billboard.Size = UDim2.new(0, 360, 0, 42)
    billboard.StudsOffset = Vector3.new(0, 3.8, 0)
    billboard.Enabled = Config.EnableWhistleESP
    billboard.Parent = visualRoot

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = PLAYER_ESP_WHITE
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Text = player.DisplayName
    label.Parent = billboard

    entry.character = character
    entry.root = characterRoot
    entry.visualModel = visualModel
    entry.visualRoot = visualRoot
    entry.rigData = rigData
    entry.downed = downed
    entry.humanoid = humanoid
    entry.highlight = highlight
    entry.billboard = billboard
    entry.label = label
    playerEspApplyColor(entry)

    entry.died = humanoid.Died:Connect(function()
        if playerEspEntries[player] == entry then
            entry.downed = true
            playerEspApplyColor(entry)
        end
    end)
end

function playerEspAttachPlayer(player)
    if player == LocalPlayer then
        return
    end

    playerEspDestroyEntry(player)
    local entry = {
        characterAdded = player.CharacterAdded:Connect(function(character)
            task.defer(function()
                if Config.EnableWhistleESP then
                    local root = character:WaitForChild("HumanoidRootPart", 5)
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if root and humanoid then
                        playerEspCreateEntry(player, character)
                    end
                end
            end)
        end),
        characterRemoving = player.CharacterRemoving:Connect(function()
            local current = playerEspEntries[player]
            if current then
                playerEspClearVisual(current)
            end
        end),
    }
    playerEspEntries[player] = entry

    if player.Character then
        playerEspCreateEntry(player, player.Character)
    end
end

function playerEspAttachAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            playerEspAttachPlayer(player)
        end
    end
end

function playerEspRefresh()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not playerEspEntries[player] then
            playerEspAttachPlayer(player)
        end
    end

    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    local observerPosition = localRoot and localRoot.Position or (camera and camera.CFrame.Position)
    if not observerPosition then
        return
    end

    for player, entry in pairs(playerEspEntries) do
        if not player.Parent then
            playerEspDestroyEntry(player)
        elseif entry.character and entry.character.Parent and entry.root and entry.root.Parent then
            local visualModel, visualRoot, rigData = playerEspResolveVisual(player, entry.character)
            if visualModel ~= entry.visualModel or visualRoot ~= entry.visualRoot then
                playerEspCreateEntry(player, entry.character)
                entry = playerEspEntries[player]
            elseif entry then
                entry.rigData = rigData or entry.rigData
            end

            if entry and entry.visualRoot and entry.visualRoot.Parent then
                entry.downed = playerEspIsDowned(entry.rigData, entry.character)
                playerEspApplyColor(entry)
                local distance = (entry.visualRoot.Position - observerPosition).Magnitude
                playerEspSetVisible(entry, Config.EnableWhistleESP and distance <= math.huge)
                if entry.label then
                    entry.label.Text = string.format("%s  |  %d m", player.DisplayName, math.floor(distance + 0.5))
                end
            end
        else
            playerEspSetVisible(entry, false)
        end
    end
end

function playerEspSetEnabled(state)
    Config.EnableWhistleESP = state and true or false
    if Config.EnableWhistleESP then
        playerEspAttachAll()
    else
        for player in pairs(playerEspEntries) do
            playerEspDestroyEntry(player)
        end
    end
    SaveSettings()
end

table.insert(playerEspConnections, Players.PlayerAdded:Connect(function(player)
    if Config.EnableWhistleESP then
        playerEspAttachPlayer(player)
    end
end))
table.insert(playerEspConnections, Players.PlayerRemoving:Connect(function(player)
    playerEspDestroyEntry(player)
end))
table.insert(playerEspConnections, RunService.Heartbeat:Connect(function(deltaTime)
    playerEspAccumulator = playerEspAccumulator + deltaTime
    if playerEspAccumulator >= PLAYER_ESP_REFRESH then
        playerEspAccumulator = 0
        if Config.EnableWhistleESP then
            playerEspRefresh()
        end
    end
end))

print("\nConfiguring Map tab...")

addTabHeader("Map", "Map Features", 14)

addTabToggle("Map", "FullBright", Config.EnableFullBright, function(state)
    setFullBrightEnabled(state)
    print(state and "FullBright ENABLED" or "X FullBright DISABLED")
end)

addTabNote("Map", "Removes darkness and improves visibility")

addTabToggle("Map", "Auto Ticket", Config.EnableAutoTicket, function(state)
    Config.EnableAutoTicket = state
    print(state and "Auto Ticket ENABLED" or "X Auto Ticket DISABLED")
    SaveSettings()
end)

addTabNote("Map", "Teleports you to every available ticket on the map")

addTabToggle("Map", "Void Escape", Config.EnableVoidEscape, function(state)
    Config.EnableVoidEscape = state
    print(state and "Void Escape ENABLED" or "X Void Escape DISABLED")
    SaveSettings()
end)

addTabNote("Map", "Sends you high into the air, away from all danger")

addTabToggle("Map", "AFK Map", Config.EnableAfkMap, function(state)
    local ok, result = loadAfkMap()
    if not ok then
        print("[AfkMap] X " .. tostring(result))
        return
    end
    setAfkMapEnabled(state)
    print(state and ("AFK Map ENABLED - " .. tostring(result) .. " parts loaded") or "X AFK Map DISABLED")
end)

addTabNote("Map", "Spawns you in your personal mini map when enabled")

addTabToggle("Map", "Grow a Garden", Config.EnableGagMap, function(state)
    if state then
        local ok, result = loadGagMap()
        if not ok then
            print("[GagMap] X " .. tostring(result))
            return
        end
        setGagMapEnabled(true)
        print("Grow a Garden ENABLED - " .. tostring(result) .. " parts loaded")
    else
        setGagMapEnabled(false)
        print("X Grow a Garden DISABLED")
    end
end)

addTabNote("Map", "Spawns in Grow a Garden on enable; auto-cached after first download")

addTabToggle("Map", "Anti AFK", Config.EnableAntiAfk, function(state)
    setAntiAfkEnabled(state)
    print(state and "Anti AFK ENABLED" or "X Anti AFK DISABLED")
end)

addTabNote("Map", "Prevents the game from kicking you for inactivity")

addTabToggle("Map", "Player ESP", Config.EnableWhistleESP, function(state)
    playerEspSetEnabled(state)
    print(state and "Player ESP ENABLED" or "X Player ESP DISABLED")
end)

addTabNote("Map", "White outline, name and distance; red when downed")

print("MAP: Tab completed")

if Config.EnableWhistleESP then
    task.defer(function()
        playerEspSetEnabled(true)
    end)
end

if Config.EnableFullBright then
    task.defer(function()
        setFullBrightEnabled(true)
    end)
end

local removeWallsBackup     = {}
local removeWallsWatcher    = nil
local removeWallsParent     = nil

local function getInvisPartsContainer()
    local map = workspace:FindFirstChild("Map")
    local container = map and map:FindFirstChild("InvisParts")
    if not container then
        container = workspace:FindFirstChild("InvisParts", true)
    end
    return container
end

local function removeWallsDestroyParts(container)
    local parts = container:GetDescendants()
    for _, obj in ipairs(parts) do
        if obj:IsA("BasePart") then

            pcall(function()
                local clone = obj:Clone()
                clone:SetAttribute("__RW_ParentPath", obj.Parent:GetFullName())
                table.insert(removeWallsBackup, clone)
            end)
            pcall(function() obj:Destroy() end)
        end
    end
end

local function removeWallsWatchNew(container)

    if removeWallsWatcher then
        pcall(function() removeWallsWatcher:Disconnect() end)
        removeWallsWatcher = nil
    end
    removeWallsWatcher = container.DescendantAdded:Connect(function(obj)
        if not Config.EnableRemoveWalls then return end
        if obj:IsA("BasePart") then
            task.defer(function()
                if not Config.EnableRemoveWalls then return end
                pcall(function()
                    local clone = obj:Clone()
                    clone:SetAttribute("__RW_ParentPath", obj.Parent:GetFullName())
                    table.insert(removeWallsBackup, clone)
                end)
                pcall(function() obj:Destroy() end)
            end)
        end
    end)
end

local function setRemoveWallsEnabled(state)
    Config.EnableRemoveWalls = state

    if state then
        removeWallsBackup = {}
        local container = getInvisPartsContainer()
        if not container then
            warn("[RemoveWalls] InvisParts not found in workspace.")
            Config.EnableRemoveWalls = false
            return
        end
        removeWallsParent = container
        print("[RemoveWalls] Found at: " .. container:GetFullName())
        removeWallsDestroyParts(container)
        removeWallsWatchNew(container)
        print("[RemoveWalls] Enabled - " .. #removeWallsBackup .. " parts removed and backed up")
    else

        if removeWallsWatcher then
            pcall(function() removeWallsWatcher:Disconnect() end)
            removeWallsWatcher = nil
        end

        local restored = 0
        if removeWallsParent and removeWallsParent.Parent then
            for _, clone in ipairs(removeWallsBackup) do
                pcall(function()
                    local newPart = clone:Clone()
                    newPart.Parent = removeWallsParent
                    restored = restored + 1
                end)
            end
        end
        removeWallsBackup = {}
        removeWallsParent = nil
        print("[RemoveWalls] Disabled - " .. restored .. " parts restored")
    end
end

print("OK REMOVE WALLS: Logic loaded")

print("\nConfiguring Extra tab...")

addTabHeader("Extra", "Remove Walls", 14)

addTabToggle("Extra", "Remove Walls", Config.EnableRemoveWalls, function(state)
    setRemoveWallsEnabled(state)
    print(state and "Remove Walls ENABLED" or "X Remove Walls DISABLED")
end)

addTabNote("Extra", "Removes the map's invisible walls. Disabling restores them.")

addTabHeader("Extra", "Auto Spawn", 14)

addTabToggle("Extra", "Auto Spawn", Config.EnableAutoForceSpawn, function(state)
    Config.EnableAutoForceSpawn = state
    print(state and "Auto Spawn ENABLED" or "X Auto Spawn DISABLED")
    SaveSettings()
end)

addTabNote("Extra", "Detects when you're downed and automatically fires Force Spawn")

addTabHeader("Extra", "Anti Bot", 14)

addTabToggle("Extra", "Anti Bot", Config.EnableAntiBot, function(state)
    Config.EnableAntiBot = state
    print(state and "Anti Bot ENABLED" or "X Anti Bot DISABLED")
    SaveSettings()
end)

addTabSlider("Extra", "Anti Bot Distance", 1, 25, Config.AntiBotDistance, function(value)
        Config.AntiBotDistance = math.clamp(math.floor(value), 1, 25)
        print("Anti Bot distance: " .. Config.AntiBotDistance .. " studs")
        SaveSettings()
    end)

addTabSlider("Extra", "Anti Bot Speed", 0.05, 2, Config.AntiBotCooldown, function(value)
        Config.AntiBotCooldown = math.clamp(tonumber(value) or 0.15, 0.05, 2)
        print("Anti Bot speed (cooldown): " .. string.format("%.2f", Config.AntiBotCooldown) .. "s")
        SaveSettings()
    end)

addTabNote("Extra", "When a bot is detected nearby, teleports you near another player or to a random nearby spot (never below the map). Adjust distance and speed with the sliders.")

addTabHeader("Extra", "Revive Aura", 14)

addTabToggle("Extra", "Revive", Config.EnableReviveAura, function(state)
    Config.EnableReviveAura = state
    print(state and "Revive Aura ENABLED" or "X Revive Aura DISABLED")
    SaveSettings()
end)

addTabNote("Extra", "Automatically revives downed players near you")

addTabHeader("Extra", "ESP Down", 14)

addTabToggle("Extra", "ESP Down", Config.EnableEspDown, function(state)
    Config.EnableEspDown = state
    espDownSetEnabled(state)
    print(state and "Esp Down ENABLED" or "X Esp Down DISABLED")
    SaveSettings()
end)

addTabNote("Extra", "Shows highlight and name only on downed players")

addTabHeader("Extra", "Auto Save", 14)

addTabToggle("Extra", "Auto Save", Config.EnableAutoSave, function(state)
    Config.EnableAutoSave = state
    print(state and "Auto Save ENABLED" or "X Auto Save DISABLED")
    SaveSettings()
end)

addTabNote("Extra", "Teleports to downed players and revives them automatically")

addTabHeader("Extra", "Auto Carry", 14)

addTabToggle("Extra", "Carry", Config.EnableAutoCarry, function(state)
    Config.EnableAutoCarry = state
    print(state and "Auto Carry ENABLED" or "X Auto Carry DISABLED")
    SaveSettings()
end)

addTabSlider("Extra", "Carry Range (studs)", 5, 60, Config.CarryRange, function(value)
        Config.CarryRange = value
        print("Carry Range: " .. value .. " studs")
        SaveSettings()
    end)

addTabSlider("Extra", "Grab Interval (sec)", 0.05, 1.0, Config.CarryInterval, function(value)
        Config.CarryInterval = value
        print("Carry Interval: " .. value .. "s")
        SaveSettings()
    end)

addTabNote("Extra", "Automatically picks up downed players near you")

addTabHeader("Extra", "Emote Speed", 14)

addTabToggle("Extra", "Emote Speed", Config.EnableEmoteSpeed, function(state)
    Config.EnableEmoteSpeed = state
    SaveSettings()
end)

addTabSlider("Extra", "Emote Speed Multiplier", 1.0, 4.0, Config.EmoteSpeedMultiplier, function(value)
        Config.EmoteSpeedMultiplier = value
        print("Emote Speed Multiplier: " .. value)
        SaveSettings()
    end)

addTabNote("Extra", "Normal speed while performing an emote")

addTabHeader("Extra", "Force Spawn", 14)

addTabButton("Extra", "Force Spawn", function()
    local SetPlayerMode = game:GetService("ReplicatedStorage")
        :WaitForChild("Events")
        :WaitForChild("SetPlayerMode")
    pcall(function()
        SetPlayerMode:FireServer(true)
    end)
    print("[ForceSpawn] Fired")
end)

addTabNote("Extra", "Press to try to spawn immediately")

addTabHeader("Extra", "Lag Switch", 14)

addTabButton("Extra", "Lag Switch", function()

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        pcall(function()
            hum.JumpPower = Config.JumpHeight * 1.5
            hum.UseJumpPower = true
        end)
    end

    local start = os.clock()
    while os.clock() - start < 1.0 do end

    task.delay(5, function()
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h.JumpPower = Config.JumpHeight
                h.UseJumpPower = true
            end)
        end
        print("[LagSwitch] Jump reset")
    end)

    print("[LagSwitch] Fired - 1.5x jump active for 5s")
end)

addTabNote("Extra", "Induces 1s of lag and activates 1.5x jump for 5 seconds")

print("OK EXTRA: Tab completed")

print("\nConfiguring Emote tab...")

local EMOTES = {
    { label = "RockinStride",       animId = "rbxassetid://111570274714712", soundId = "rbxassetid://114846968069031", emoteName = "RockinStride" },
    { label = "ZombieStride 1",     animId = "rbxassetid://125497596837433", soundId = "", emoteName = "ZombieStride", emoteKey = "ZombieStride1" },
    { label = "ZombieStride 2",     animId = "rbxassetid://84248734120911",  soundId = "", emoteName = "ZombieStride", emoteKey = "ZombieStride2" },
    { label = "ZombieStride 3",     animId = "rbxassetid://73383479205643",  soundId = "", emoteName = "ZombieStride", emoteKey = "ZombieStride3" },
    { label = "Ghoulish Galleon",   animId = "rbxassetid://119226805386886", soundId = "", emoteName = "GhoulishGalleon", emoteKey = "GhoulishGalleon" },
    { label = "Solar Slayer 1",      animId = "rbxassetid://117293869950361", soundId = "", emoteName = "SolarSlayer", emoteKey = "SolarSlayer1", selectionVariant = "1" },
    { label = "Solar Slayer 2",      animId = "rbxassetid://111930618562488", soundId = "", emoteName = "SolarSlayer", emoteKey = "SolarSlayer2", selectionVariant = "2" },
    { label = "Solar Combine",       animId = "rbxassetid://117293869950361", soundId = "", emoteName = "SolarSlayer", emoteKey = "SolarCombine", selectionVariants = {"1", "2"} },
    { label = "Griddy",             animId = "rbxassetid://82579103193493",  soundId = "", emoteName = "Griddy" },
    { label = "BananaDance",  animId = "rbxassetid://76664554569994",  soundId = "", emoteName = "BananaDance" },
    { label = "OiiaOiia",     animId = "rbxassetid://82698079573413",  soundId = "", emoteName = "OiiaOiia" },
    { label = "Writhing",     animId = "rbxassetid://118337616190939", soundId = "", emoteName = "Writhing" },
    { label = "AstroSlide",   animId = "rbxassetid://103095884226031", soundId = "", emoteName = "AstroSlide" },
    { label = "Popular",      animId = "rbxassetid://126396646825215", soundId = "", emoteName = "Popular" },
    { label = "Moonwalk",     animId = "rbxassetid://97074392214454",  soundId = "", emoteName = "Moonwalk" },
    { label = "Golpeador",    animId = "",                             soundId = "", emoteName = "Golpeador" },
    { label = "Headless Baller", animId = "rbxassetid://113685905137377", soundId = "", emoteName = "HeadlessBaller" },
    { label = "Banger",          animId = "rbxassetid://89805417778763",  soundId = "", emoteName = "Banger"         },
    { label = "Broom of Doom",   animId = "rbxassetid://112692937680187", soundId = "", emoteName = "Broom"          },
    { label = "Bold March",      animId = "rbxassetid://89755710041366",  soundId = "", emoteName = "BoldMarch"      },
}

local IDLE_IDS = {
    ["rbxassetid://17418770762"] = true,
    ["rbxassetid://17418484618"] = true,
    ["rbxassetid://17418691532"] = true,
    ["rbxassetid://17418712872"] = true,
    ["rbxassetid://17418485963"] = true,
    ["rbxassetid://17418788540"] = true,
    ["rbxassetid://17418483149"] = true,
    ["rbxassetid://17524391617"] = true,
}

local EmoteState = {
    enabled  = true,
    emoteIdx = nil,
}

local activeVisualTrack = nil
local activeVisualTrackRestarting = false
local activeProps       = {}
local activeSound       = nil
local activeSoundKillerConn = nil
local substituting      = false
local emoteGeneration  = 0
local emoteConnections  = {}
local emoteLifecycleConnections = {}
local roundCleanupConnections = {}
local inEvadeEmote      = false

function disconnectEmoteConnections(list)
    for _, connection in ipairs(list) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(list)
end

local emoteModuleCache = {}
function buildEmoteCache()
    local items = ReplicatedStorage:FindFirstChild("Items")
    if not items then return end

    local roots = {}
    local packs = items:FindFirstChild("ItemPacks")
    if packs then table.insert(roots, packs) end
    local baseItems = items:FindFirstChild("BaseItems")
    if baseItems then table.insert(roots, baseItems) end

    for _, emote in ipairs(EMOTES) do
        local acceptedNames = {[emote.emoteName] = true}
        if emote.emoteName == "Broom" then
            acceptedNames.BroomOfDoom = true
            acceptedNames["Broom of Doom"] = true
        end

        for _, root in ipairs(roots) do
            local found = false
            for _, inst in ipairs(root:GetDescendants()) do
                if inst.ClassName == "ModuleScript" and acceptedNames[inst.Name] then
                    local hasEmoteModel = inst:FindFirstChild("CharacterClassic", true)
                        or inst:FindFirstChild("EmoteModel", true)
                    if emote.emoteName ~= "Broom" or hasEmoteModel then
                        emoteModuleCache[emote.emoteKey or emote.emoteName] = inst
                        found = true
                        break
                    end
                end
            end
            if found then break end
        end
    end

    if not emoteModuleCache.Broom then
        for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
            if inst.ClassName == "ModuleScript"
            and (inst.Name == "Broom" or inst.Name == "BroomOfDoom" or inst.Name == "Broom of Doom") then
                local hasEmoteModel = inst:FindFirstChild("CharacterClassic", true)
                    or inst:FindFirstChild("EmoteModel", true)
                if hasEmoteModel then
                    emoteModuleCache.Broom = inst
                    break
                end
            end
        end
    end
end

function cleanupActiveEmote()
    emoteGeneration = emoteGeneration + 1
    if activeVisualTrack then

        local track = activeVisualTrack
        activeVisualTrack = nil
        activeVisualTrackRestarting = false
        pcall(function() track:Stop(0) end)
    end
    for _, obj in ipairs(activeProps) do
        pcall(function() obj:Destroy() end)
    end
    activeProps = {}
    if activeSound then
        pcall(function() activeSound:Stop(); activeSound:Destroy() end)
        activeSound = nil
    end
    if activeSoundKillerConn then
        pcall(function() activeSoundKillerConn:Disconnect() end)
        activeSoundKillerConn = nil
    end
end

function resetEmoteRuntime()
    cleanupActiveEmote()
    inEvadeEmote = false
    substituting = false
end

function bindEmoteCharacterLifecycle(char)
    disconnectEmoteConnections(emoteLifecycleConnections)
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        table.insert(emoteLifecycleConnections, humanoid.Died:Connect(resetEmoteRuntime))
    end

    table.insert(emoteLifecycleConnections, char.AncestryChanged:Connect(function(_, parent)
        if not parent then
            resetEmoteRuntime()
        end
    end))
end

function setupRoundCleanupWatchers()
    disconnectEmoteConnections(roundCleanupConnections)
    local updateMapBound = false
    local stateBound = false

    task.spawn(function()

        for _ = 1, 90 do
            local events = ReplicatedStorage:FindFirstChild("Events")
            local updateMap = events and events:FindFirstChild("UpdateMap")
            if not updateMapBound and updateMap and updateMap:IsA("RemoteEvent") then
                updateMapBound = true
                table.insert(roundCleanupConnections, updateMap.OnClientEvent:Connect(resetEmoteRuntime))
            end

            local services = ReplicatedStorage:FindFirstChild("Services")
            local data = services and services:FindFirstChild("Data")
            local registry = data and data:FindFirstChild("ServerStateRegistryService")
            local changedEvent = registry and registry:FindFirstChild("ChangedEvent")
            if not stateBound and changedEvent and changedEvent:IsA("BindableEvent") then
                stateBound = true
                table.insert(roundCleanupConnections, changedEvent.Event:Connect(function(key, value)
                    if (key == "MapLoading" and value == true)
                    or (key == "Voting" and value == true) then
                        resetEmoteRuntime()
                    end
                end))
            end

            if updateMapBound and stateBound then break end
            task.wait(1)
        end
    end)
end

function rebindRockinExternalJointPart(part, clonedEM, rig)
    if not part or clonedEM:IsAncestorOf(part) then
        return part
    end

    local rigPart = rig:FindFirstChild(part.Name, true)
    if rigPart and not clonedEM:IsAncestorOf(rigPart) then
        return rigPart
    end

    return part
end

function getRelativeInstancePath(inst, root)
    if not inst or not root then return nil end

    local ok, instFull = pcall(function() return inst:GetFullName() end)
    local okRoot, rootFull = pcall(function() return root:GetFullName() end)
    if not ok or not okRoot then return nil end

    local prefix = rootFull .. "."
    if instFull:sub(1, #prefix) ~= prefix then return nil end
    return instFull:sub(#prefix + 1)
end

function findGhoulishJointPart(part, sourceModel, clonedModel, rig)
    if not part then return nil end
    if clonedModel:IsAncestorOf(part) then return part end

    local relativePath = getRelativeInstancePath(part, sourceModel)
    if relativePath then
        local clonePart = clonedModel
        for segment in string.gmatch(relativePath, "[^%.]+") do
            clonePart = clonePart:FindFirstChild(segment)
            if not clonePart then break end
        end
        if clonePart and clonePart:IsA("BasePart") then
            return clonePart
        end
    end

    local rigPart = rig:FindFirstChild(part.Name, true)
    if rigPart and not clonedModel:IsAncestorOf(rigPart) then
        return rigPart
    end

    return part
end

local GHOULISH_ROOT_OFFSET = CFrame.new(0, -4.1, 3)

function spawnEmoteProps(emote, rig)
    local cacheKey = emote.emoteKey or emote.emoteName
    local mod = emoteModuleCache[cacheKey]
    if not mod and emote.emoteName == "Broom" then
        buildEmoteCache()
        mod = emoteModuleCache[cacheKey]
    end
    if not mod then return end

    local cc, emoteModel
    if emote.selectionVariant then
        local selection = mod:FindFirstChild("Selection")
        local variant = selection and selection:FindFirstChild(emote.selectionVariant)
        cc = variant and variant:FindFirstChild("CharacterClassic")
        emoteModel = cc and cc:FindFirstChild("EmoteModel")
    end
    if not emoteModel then
        cc = mod:FindFirstChild("CharacterClassic")
        emoteModel = cc and cc:FindFirstChild("EmoteModel")
    end
    if not emoteModel and emote.emoteName == "Broom" then
        for _, inst in ipairs(mod:GetDescendants()) do
            if inst.Name == "EmoteModel" then
                emoteModel = inst
                break
            end
        end
    end
    if not emoteModel and not emote.selectionVariants then return end

    local propsParent = rig
    if emote.emoteName == "SolarSlayer" then

        local solarFolder = rig:FindFirstChild("__Perplex_SolarSlayerProps")
        if not solarFolder then
            solarFolder = Instance.new("Folder")
            solarFolder.Name = "__Perplex_SolarSlayerProps"
            solarFolder.Parent = rig
        end
        propsParent = solarFolder
    end

    if emote.selectionVariants and emote.emoteName == "SolarSlayer" then
        local selection = mod:FindFirstChild("Selection")
        if selection then
            for _, variantId in ipairs(emote.selectionVariants) do
                local variant = selection:FindFirstChild(variantId)
                local variantCC = variant and variant:FindFirstChild("CharacterClassic")
                local variantModel = variantCC and variantCC:FindFirstChild("EmoteModel")
                if variantModel then
                    local combinedProp = variantModel:Clone()
                    combinedProp.Parent = propsParent
                    table.insert(activeProps, combinedProp)
                    for _, prop in ipairs(combinedProp:GetDescendants()) do
                        if prop:IsA("BasePart") then
                            pcall(function()
                                prop.CanCollide = false
                                prop.CanTouch = false
                                prop.CanQuery = false
                                prop.Massless = true
                            end)
                        end
                    end
                    for _, motor in ipairs(combinedProp:GetDescendants()) do
                        if motor:IsA("Motor6D") or motor:IsA("Weld") or motor:IsA("WeldConstraint") then
                            local sourcePart0 = motor.Part0
                            if sourcePart0 and not combinedProp:IsAncestorOf(sourcePart0) then
                                local rigPart = rig:FindFirstChild(sourcePart0.Name)
                                if rigPart and rigPart:IsA("BasePart") then motor.Part0 = rigPart end
                            end
                            local sourcePart1 = motor.Part1
                            if sourcePart1 and not combinedProp:IsAncestorOf(sourcePart1) then
                                local rigPart = rig:FindFirstChild(sourcePart1.Name)
                                if rigPart and rigPart:IsA("BasePart") then motor.Part1 = rigPart end
                            end
                        end
                    end
                end
            end
        end
        return
    end

    local clonedEM = emoteModel:Clone()
    clonedEM.Parent = propsParent
    table.insert(activeProps, clonedEM)

    if emote.emoteName == "SolarSlayer"
    or emote.emoteName == "GhoulishGalleon"
    or emote.emoteName == "Broom" then
        for _, prop in ipairs(clonedEM:GetDescendants()) do
            if prop:IsA("BasePart") then
                pcall(function() prop.CanCollide = false end)
                pcall(function() prop.CanTouch = false end)
                pcall(function() prop.CanQuery = false end)
                pcall(function() prop.Massless = true end)
            end
        end
    end

    if emote.emoteName == "GhoulishGalleon" then
        local rigRoot = rig:FindFirstChild("HumanoidRootPart", true)
            or rig:FindFirstChild("Torso", true)
        local rootMotor = nil
        local hull = nil

        for _, joint in ipairs(clonedEM:GetDescendants()) do
            if joint:IsA("Motor6D")
            and joint.Name == "Hull"
            and joint.Parent == clonedEM then
                rootMotor = joint
            end
            if joint:IsA("BasePart") and joint.Name == "Hull" then
                hull = hull or joint
            end
        end

        local targetCFrame = hull and hull.CFrame or nil
        if rootMotor and rigRoot then
            local okC0, c0 = pcall(function() return rootMotor.C0 end)
            local okC1, c1 = pcall(function() return rootMotor.C1 end)
            if okC0 and okC1 and typeof(c0) == "CFrame" and typeof(c1) == "CFrame" then
                targetCFrame = rigRoot.CFrame
                    * GHOULISH_ROOT_OFFSET
                    * c0
                    * c1:Inverse()
            end
        end
        if hull and targetCFrame then
            pcall(function() hull.CFrame = targetCFrame end)
        end

        for _, joint in ipairs(clonedEM:GetDescendants()) do
            if joint ~= rootMotor
            and (joint:IsA("Motor6D") or joint:IsA("Weld")) then
                joint.Part0 = findGhoulishJointPart(joint.Part0, emoteModel, clonedEM, rig)
                joint.Part1 = findGhoulishJointPart(joint.Part1, emoteModel, clonedEM, rig)
            end
        end

        if rootMotor then
            rootMotor:Destroy()
        end

        if rigRoot and hull then
            local follow = Instance.new("WeldConstraint")
            follow.Name = "__Perplex_GhoulishFollow"
            follow.Part0 = rigRoot
            follow.Part1 = hull
            follow.Parent = rigRoot
            table.insert(activeProps, follow)
        end
        return
    end

    for _, motor in ipairs(clonedEM:GetDescendants()) do
        if motor:IsA("Motor6D")
        or ((emote.emoteName == "SolarSlayer" or emote.emoteName == "Broom")
        and (motor:IsA("Weld") or motor:IsA("WeldConstraint"))) then
            local sourcePart0 = motor.Part0
            if sourcePart0 and not clonedEM:IsAncestorOf(sourcePart0) then
                local rigPart = rig:FindFirstChild(sourcePart0.Name)
                if rigPart and rigPart:IsA("BasePart") then
                    motor.Part0 = rigPart
                end
            end

            local sourcePart1 = motor.Part1
            if sourcePart1 and not clonedEM:IsAncestorOf(sourcePart1) then
                local rigPart = rig:FindFirstChild(sourcePart1.Name)
                if rigPart and rigPart:IsA("BasePart") then
                    motor.Part1 = rigPart
                end
            end
        end
    end
end

function playEmoteSound(emote, rig)
    if emote.soundId == "" then return end
    local snd = Instance.new("Sound")
    snd.SoundId = emote.soundId
    snd.Volume  = 0.5
    snd.Looped  = false
    snd.Parent  = rig
    snd:Play()
    activeSound = snd
end

function onEmoteAnimPlayed(anim, track)
    if not EmoteState.enabled or not EmoteState.emoteIdx then return end
    if substituting then return end

    local id = track.Animation and track.Animation.AnimationId
    if not id then return end

    if IDLE_IDS[id] then
        local selectedEmote = EmoteState.emoteIdx and EMOTES[EmoteState.emoteIdx]
        if selectedEmote
        and selectedEmote.emoteName == "GhoulishGalleon"
        and inEvadeEmote then
            return
        end
        if activeVisualTrack then task.spawn(cleanupActiveEmote) end
        return
    end

    if not inEvadeEmote then return end

    local emote = EMOTES[EmoteState.emoteIdx]
    if not emote or emote.animId == "" then return end
    if emote.animId == id then return end

    substituting = true
    cleanupActiveEmote()
    local visualEpoch = emoteGeneration

    pcall(function()
        local rig = anim.Parent.Parent
        for _, snd in ipairs(rig:GetDescendants()) do
            if snd:IsA("Sound") and snd.IsPlaying then snd:Stop() end
        end
    end)

    pcall(function()
        if activeSoundKillerConn then
            activeSoundKillerConn:Disconnect()
            activeSoundKillerConn = nil
        end
        local playersFolder = workspace:FindFirstChild("Players")
        local charModel = playersFolder and playersFolder:FindFirstChild(LocalPlayer.Name)
        if charModel then
            local hrp = charModel:FindFirstChild("HumanoidRootPart")
            local soundPos = hrp and hrp:FindFirstChild("SoundPos")
            if soundPos then
                for _, snd in ipairs(soundPos:GetChildren()) do
                    if snd:IsA("Sound") and snd.Name == "EmoteSound" then
                        pcall(function() snd:Stop() end)
                    end
                end
            end
            activeSoundKillerConn = charModel.DescendantAdded:Connect(function(inst)
                if inst:IsA("Sound") and inst.Name == "EmoteSound" then
                    task.defer(function()
                        pcall(function() inst:Stop() end)
                    end)
                end
            end)
        end
    end)

    pcall(function()
        local rig = anim.Parent.Parent
        for _, obj in ipairs(rig:GetChildren()) do
            if obj:IsA("Model") and obj ~= rig:FindFirstChildOfClass("Humanoid") then
                obj:Destroy()
            end
        end
    end)

    pcall(function() track:Stop(0) end)

    local fake = Instance.new("Animation")
    fake.AnimationId = emote.animId
    local ok, visualTrack = pcall(function()
        return anim:LoadAnimation(fake)
    end)

    if ok and visualTrack then
        if visualEpoch ~= emoteGeneration or not inEvadeEmote then
            pcall(function() visualTrack:Stop(0); fake:Destroy() end)
            task.defer(function() substituting = false end)
            return
        end
        activeVisualTrack = visualTrack
        visualTrack.Priority = Enum.AnimationPriority.Action

        visualTrack.Looped = true
        visualTrack:Play()
        if visualEpoch ~= emoteGeneration or not inEvadeEmote then
            if activeVisualTrack == visualTrack then activeVisualTrack = nil end
            pcall(function() visualTrack:Stop(0); fake:Destroy() end)
            task.defer(function() substituting = false end)
            return
        end

        pcall(function()
            local rig = anim.Parent.Parent
            spawnEmoteProps(emote, rig)
        end)

        pcall(function()
            local rig = anim.Parent.Parent
            playEmoteSound(emote, rig)
        end)

        visualTrack.Stopped:Connect(function()

            if activeVisualTrack ~= visualTrack then
                pcall(function() fake:Destroy() end)
                return
            end

            if not inEvadeEmote or visualEpoch ~= emoteGeneration then
                activeVisualTrack = nil
                pcall(function() fake:Destroy() end)
                return
            end

            if activeVisualTrackRestarting then return end
            activeVisualTrackRestarting = true
            task.defer(function()
                activeVisualTrackRestarting = false
                if activeVisualTrack ~= visualTrack
                    or not inEvadeEmote
                    or visualEpoch ~= emoteGeneration then
                    return
                end

                pcall(function()
                    visualTrack.Looped = true
                    visualTrack.TimePosition = 0
                    visualTrack:Play(0)
                end)
            end)
        end)
    end

    task.defer(function() substituting = false end)
end

function connectEmoteRig(humAnim, acAnim)
    for _, c in ipairs(emoteConnections) do pcall(function() c:Disconnect() end) end
    emoteConnections = {}
    if humAnim then
        emoteConnections[#emoteConnections+1] = humAnim.AnimationPlayed:Connect(function(track)
            onEmoteAnimPlayed(humAnim, track)
        end)
    end
    if acAnim then
        emoteConnections[#emoteConnections+1] = acAnim.AnimationPlayed:Connect(function(track)
            onEmoteAnimPlayed(acAnim, track)
        end)
    end
end

function getEmoteRigAnimators()
    local rigs = workspace:FindFirstChild("Rigs")
    if not rigs then return nil, nil end
    local rig = rigs:FindFirstChild(LocalPlayer.Name)
    if not rig then return nil, nil end
    local hum     = rig:FindFirstChildOfClass("Humanoid")
    local humAnim = hum and hum:FindFirstChildOfClass("Animator")
    local ac      = rig:FindFirstChildOfClass("AnimationController")
    local acAnim  = ac and ac:FindFirstChildOfClass("Animator")
    return humAnim, acAnim
end

buildEmoteCache()

task.spawn(function()
    local humAnim, acAnim = getEmoteRigAnimators()
    if not humAnim and not acAnim then
        local rigs = workspace:WaitForChild("Rigs", 10)
        if not rigs then return end
        local rig = rigs:WaitForChild(LocalPlayer.Name, 10)
        if not rig then return end
        local hum = rig:WaitForChild("Humanoid", 5)
        humAnim = hum and hum:WaitForChild("Animator", 5)
        local ac = rig:WaitForChild("AnimationController", 5)
        acAnim  = ac and ac:WaitForChild("Animator", 5)
    end
    pcall(connectEmoteRig, humAnim, acAnim)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    bindEmoteCharacterLifecycle(char)
    task.wait(1)
    local humAnim, acAnim = getEmoteRigAnimators()
    if humAnim or acAnim then pcall(connectEmoteRig, humAnim, acAnim) end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    resetEmoteRuntime()
    disconnectEmoteConnections(emoteLifecycleConnections)
end)

bindEmoteCharacterLifecycle(LocalPlayer.Character)
setupRoundCleanupWatchers()

local EmoteGridItems = {
    { Image = "rbxassetid://74660035371902",  LabelES = "Broom of Doom",   LabelEN = "Broom of Doom",   emoteKey = "Broom"          },
    { Image = "rbxassetid://73174831119162",  LabelES = "Griddy",         LabelEN = "Griddy",         emoteKey = "Griddy" },
    { Image = "rbxassetid://98064200423688",  LabelES = "Popular",        LabelEN = "Popular",        emoteKey = "Popular" },
    { Image = "rbxassetid://127215087541402", LabelES = "Writhing",       LabelEN = "Writhing",       emoteKey = "Writhing" },
    { Image = "rbxassetid://84918625639293",  LabelES = "Astro Slide",    LabelEN = "Astro Slide",    emoteKey = "AstroSlide" },
    { Image = "rbxassetid://84060840420307",  LabelES = "Moonwalk",       LabelEN = "Moonwalk",       emoteKey = "Moonwalk" },
    { Image = "rbxassetid://71947616607317",  LabelES = "Banana Dance",   LabelEN = "Banana Dance",   emoteKey = "BananaDance" },
    { Image = "rbxassetid://110443286307594", LabelES = "OiiaOiia",       LabelEN = "OiiaOiia",       emoteKey = "OiiaOiia" },
    { Image = "rbxassetid://86302242319867",  LabelES = "Zombie Stride 1", LabelEN = "Zombie Stride 1", emoteKey = "ZombieStride1" },
    { Image = "rbxassetid://86302242319867",  LabelES = "Zombie Stride 2", LabelEN = "Zombie Stride 2", emoteKey = "ZombieStride2" },
    { Image = "rbxassetid://86302242319867",  LabelES = "Zombie Stride 3", LabelEN = "Zombie Stride 3", emoteKey = "ZombieStride3" },
    { Image = "rbxassetid://136281024873093", LabelES = "Ghoulish Galleon", LabelEN = "Ghoulish Galleon", emoteKey = "GhoulishGalleon" },
    { Image = "rbxassetid://124775667511401", LabelES = "Solar Slayer 1",  LabelEN = "Solar Slayer 1",  emoteKey = "SolarSlayer1" },
    { Image = "rbxassetid://119932397286210", LabelES = "Solar Slayer 2",  LabelEN = "Solar Slayer 2",  emoteKey = "SolarSlayer2" },
    { Image = "rbxassetid://124775667511401", LabelES = "Solar Combine",   LabelEN = "Solar Combine",   emoteKey = "SolarCombine" },
    { Image = "rbxassetid://88980462354208",  LabelES = "Rockin' Stride",  LabelEN = "Rockin' Stride",  emoteKey = "RockinStride"   },
    { Image = "rbxassetid://120404811560579", LabelES = "Headless Baller", LabelEN = "Headless Baller", emoteKey = "HeadlessBaller" },
    { Image = "rbxassetid://88586004283343",  LabelES = "Banger",          LabelEN = "Banger",          emoteKey = "Banger"         },
    { Image = "rbxassetid://88448996681393",  LabelES = "Bold March",      LabelEN = "Bold March",      emoteKey = "BoldMarch"      },
}

local emoteIndexByKey = {}
for i, e in ipairs(EMOTES) do
    emoteIndexByKey[e.emoteKey or e.emoteName] = i
end

function setupEmoteTab()
    local targetEmoteName = ""
    local sourceEmoteName = ""
    local emoteStatusParagraph
    local sourceEmoteBox
    local emoteChoiceDropdown
    local emoteChoiceKeys = {}
    local emoteChoiceOptions = { "None" }

    local EMOTE_LIST_NAMES = {
        "MaracaTime", "Bhop", "GamingTime", "StealthyBox", "TouchGrass", "HeliosChariot",
        "DogParty", "FreshFlop", "CatParty", "TurtleHobble", "DuckyMarch", "Sleepybara",
        "HoveringCrystal", "FlyingFish", "OiiaOiia", "Caffeinated", "Frolic", "Bumblebee",
        "MarchShowcase", "Tank", "Rocket", "QueensAppearance", "RegalWalk", "WingedRoyalSit",
        "BananaDance", "HitTheJackpot", "CuddleBearSit", "CrabRave", "NeptunesThrone", "MountedSeahorse",
        "DynastyDrumming", "FireworkBlast", "ClassicJeep", "RainingTacos", "SkateboardStroll", "TurkeyJockey",
        "WinterOf85", "RockinStride", "Broom", "WindupDance", "SnowmobileCruise", "CampfireDoze",
        "FlyingSleigh", "GhoulishGalleon", "DeadBoneStride", "CyberBroom", "Xylobone", "GhastlyGrimoire",
        "AngelicWings", "HarpRecital", "BobointheBox", "IceFishing", "RudolphMount", "SledDrifting",
        "SnowmanConstruction", "SantaMech", "WinterRide", "WindUpPose", "AvariceLounge", "SerenePerch",
        "BeachChairLounge", "LemonadeStand", "RowBoat", "PoolTime", "SummerDays", "CasualSurfing",
        "ManyFans", "CuerdasDelAlma", "GraveRider", "ScorchedEarth", "SpiritedAway", "HeadlessHorseman",
        "CozyChair", "FrostDrake", "SkiSpree", "WinterMelody", "RockingHorse", "SnowAngel",
        "AprilShower", "GoldRitual", "DreamyCloud", "ValentineComputer", "CoccoonRebirth", "LadybugFlight",
        "LotusSwing", "MegaflyJet", "SnailMail", "HoneyPool", "SummerLowrider", "AstralMantaRay",
        "FrutigerFloatie", "LeapingDolphin", "AquaticDaydreamer", "SubmarineRide", "EncapsulatedBubble",
    }

    function trimName(value)
        value = tostring(value or "")
        return value:gsub("^%s+", ""):gsub("%s+$", "")
    end

    function setStatus(text, tone)
        if emoteStatusParagraph then
            setToneText(emoteStatusParagraph, text, tone)
        end
    end

    function findEmoteFolder(name)
        local rep = game:GetService("ReplicatedStorage")
        local cleanName = trimName(name)
        if cleanName == "" then return nil end
        local folder = rep:FindFirstChild(cleanName, true)
        if folder then return folder end
        local compactName = cleanName:gsub("%s+", "")
        if compactName ~= cleanName then
            folder = rep:FindFirstChild(compactName, true)
        end
        return folder
    end

    function applyVisualEmote()
        local targetName = trimName(targetEmoteName)
        local sourceName = trimName(sourceEmoteName)
        if targetName == "" or sourceName == "" then
            setStatus("Both emote names are required.", "Warning")
            return
        end
        local targetFolder = findEmoteFolder(targetName)
        local sourceFolder = findEmoteFolder(sourceName)
        if not targetFolder then
            setStatus("Current emote not found: " .. targetName, "Danger")
            return
        end
        if not sourceFolder then
            setStatus("Visual emote not found: " .. sourceName, "Danger")
            return
        end
        if targetFolder == sourceFolder then
            setStatus("The current and visual emotes must be different.", "Warning")
            return
        end
        local clones = {}
        for _, item in ipairs(sourceFolder:GetChildren()) do
            local ok, clonedItem = pcall(function() return item:Clone() end)
            if not ok or not clonedItem then
                for _, pending in ipairs(clones) do pcall(function() pending:Destroy() end) end
                setStatus("Could not prepare the visual emote.", "Danger")
                return
            end
            table.insert(clones, clonedItem)
        end
        for _, item in ipairs(targetFolder:GetChildren()) do pcall(function() item:Destroy() end) end
        for _, clonedItem in ipairs(clones) do clonedItem.Parent = targetFolder end
        setStatus("Applied: " .. targetName .. " -> " .. sourceName, "Success")
        print("PC VISUAL EMOTE: " .. targetName .. " -> " .. sourceName)
    end

    function clearMobileEmoteSelection()
        EmoteState.emoteIdx = nil
        cleanupActiveEmote()
        if emoteChoiceDropdown then
            emoteChoiceDropdown:Set("None", true)
        end
    end

    addTabHeader("Emote", "Visual Emote Changer", 16)
    PerplexUI.Sections.Emote:AddParagraph({
        Title = "How it works",
        Content = "Enter the current emote name and the visual emote you want to use.",
    })
    addTabTextBox("Emote", "Current Emote / Target", "Example: Popular", function(text)
        targetEmoteName = trimName(text)
    end)
    sourceEmoteBox = addTabTextBox("Emote", "Visual Emote / Source", "Example: Broom of Doom", function(text)
        sourceEmoteName = trimName(text)
    end)
    PerplexUI.Sections.Emote:AddDropdown({
        Text = "List of Emotes",
        Options = EMOTE_LIST_NAMES,
        Searchable = true,
        Internal = true,
        Callback = function(choice)
            if not choice or choice == "" then
                return
            end
            sourceEmoteName = choice
            sourceEmoteBox:Set(choice, true)
            applyVisualEmote()
        end,
    })
    addTabButton("Emote", "Apply Visual Emote", applyVisualEmote)
    emoteStatusParagraph = PerplexUI.Sections.Emote:AddParagraph({
        Title = "Status",
        Content = "Ready to apply a visual change.",
        RichText = true,
    })

    for _, item in ipairs(EmoteGridItems) do
        emoteChoiceKeys[item.LabelEN] = item.emoteKey
        table.insert(emoteChoiceOptions, item.LabelEN)
    end

    EmoteState.enabled = not getgenv().PerplexIsPCEmotePlatform()

    addTabHeader("Emote", "Emote Player", 16)
    addTabToggle("Emote", "Emote Player", EmoteState.enabled, function(state)
        EmoteState.enabled = state
        if not state then
            clearMobileEmoteSelection()
        end
    end)
    emoteChoiceDropdown = PerplexUI.Sections.Emote:AddDropdown({
        Text = "Emote",
        Options = emoteChoiceOptions,
        Default = "None",
        Searchable = true,
        Internal = true,
        Callback = function(choice)
            local emoteKey = emoteChoiceKeys[choice]
            if emoteKey then
                EmoteState.emoteIdx = emoteIndexByKey[emoteKey]
            else
                EmoteState.emoteIdx = nil
                cleanupActiveEmote()
            end
        end,
    })
end

getgenv().PerplexIsPCEmotePlatform = function()
    local isPC = false
    pcall(function()
        local userInputService = game:GetService("UserInputService")
        local preferredInput = userInputService.PreferredInput
        if preferredInput == Enum.PreferredInput.KeyboardAndMouse then
            isPC = true
            return
        elseif preferredInput == Enum.PreferredInput.Touch then
            return
        end
        local hasKeyboard = userInputService.KeyboardEnabled
        local hasMouse = userInputService.MouseEnabled
        local hasTouch = userInputService.TouchEnabled
        if hasKeyboard and hasMouse and not hasTouch then
            isPC = true
            return
        end
        local camera = workspace.CurrentCamera
        local viewportWidth = camera and camera.ViewportSize.X or 0
        isPC = viewportWidth >= 1080
    end)
    return isPC
end

setupEmoteTab()

print("\nOK: INTERFACE FULLY CONFIGURED")

print("\nLoading movement functions...")

function applyTeleportWalk()
    if not Config.EnableTeleportWalk and not Config.EnableTrimpTeleport then return end

    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    if hum.MoveDirection.Magnitude > 0 then
        pcall(function()
            char:TranslateBy(hum.MoveDirection * Config.TeleportMovementSpeed * 0.1)
        end)
    end
end

local InfiniteSlideState = {
    inSlide = false,
    slideDir = Vector3.new(0, 0, 1),
}
local infiniteSlideBV = nil

local InfiniteSlideKeys = {
    Enum.KeyCode.LeftControl,
    Enum.KeyCode.C,
}

function getInfiniteSlideInputHeld()
    if UserInputService.KeyboardEnabled then
        for _, keyCode in ipairs(InfiniteSlideKeys) do
            if UserInputService:IsKeyDown(keyCode) then
                return true
            end
        end
        return false
    end

    if UserInputService.GamepadEnabled then
        local ok, held = pcall(function()
            return UserInputService:IsGamepadButtonDown(
                Enum.UserInputType.Gamepad1,
                Enum.KeyCode.ButtonR2
            )
        end)
        if ok then
            return held
        end
    end

    return nil
end

function getInfiniteSlideDirection(char, root)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local move = humanoid.MoveDirection
        local moveHorizontal = Vector3.new(move.X, 0, move.Z)
        if moveHorizontal.Magnitude > 0.1 then
            return moveHorizontal.Unit
        end
    end

    local currentCamera = Workspace.CurrentCamera
    if currentCamera then
        local look = currentCamera.CFrame.LookVector
        local cameraHorizontal = Vector3.new(look.X, 0, look.Z)
        if cameraHorizontal.Magnitude > 0.1 then
            return cameraHorizontal.Unit
        end
    end

    local velocity = root.AssemblyLinearVelocity
    local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
    if horizontal.Magnitude > 0.1 then
        return horizontal.Unit
    end

    return InfiniteSlideState.slideDir
end

function applyEnhancedJump()
    if not Config.EnableEnhancedJump then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end

    local hum = char.Humanoid
    if hum.Health <= 0 then return end

    if hum:GetState() ~= Enum.HumanoidStateType.Jumping then
        pcall(function()
            hum.JumpPower = Config.JumpHeight
            hum.UseJumpPower = true
        end)
    end
end

function applyInfiniteSlide()
    if not Config.EnableInfiniteSlide then
        InfiniteSlideState.inSlide = false
        if infiniteSlideBV then infiniteSlideBV:Destroy() infiniteSlideBV = nil end
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local slideAttachment = root and root:FindFirstChild("Slide")
    local slideSound = slideAttachment and slideAttachment:FindFirstChild("SlideSound")
    if not char or not root or not slideSound then
        InfiniteSlideState.inSlide = false
        if infiniteSlideBV then infiniteSlideBV:Destroy() infiniteSlideBV = nil end
        return
    end

    if slideSound.Playing then
        if not InfiniteSlideState.inSlide then
            InfiniteSlideState.inSlide = true
            local velocity = root.AssemblyLinearVelocity
            local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
            if horizontal.Magnitude > 0.1 then
                InfiniteSlideState.slideDir = horizontal.Unit
            end
        end
    elseif not InfiniteSlideState.inSlide then
        if infiniteSlideBV then infiniteSlideBV:Destroy() infiniteSlideBV = nil end
        return
    end

    local inputHeld = getInfiniteSlideInputHeld()
    if inputHeld == false or (inputHeld == nil and not slideSound.Playing) then
        InfiniteSlideState.inSlide = false
        if infiniteSlideBV then infiniteSlideBV:Destroy() infiniteSlideBV = nil end
        return
    end

    slideRaycastParams.FilterDescendantsInstances = {char}
    local rayResult = Workspace:Raycast(root.Position, Vector3.new(0, -4, 0), slideRaycastParams)
    local surfaceNormal = rayResult and rayResult.Normal or Vector3.new(0, 1, 0)

    InfiniteSlideState.slideDir = getInfiniteSlideDirection(char, root)
    local dir = InfiniteSlideState.slideDir

    local projected = dir - surfaceNormal * dir:Dot(surfaceNormal)
    if projected.Magnitude > 0.01 then
        projected = projected.Unit
    else
        projected = dir
    end

    if not infiniteSlideBV or not infiniteSlideBV.Parent or infiniteSlideBV.Parent ~= root then
        if infiniteSlideBV then pcall(function() infiniteSlideBV:Destroy() end) end
        infiniteSlideBV = Instance.new("BodyVelocity")
        infiniteSlideBV.MaxForce = Vector3.new(4e5, 4e5, 4e5)
        infiniteSlideBV.P = 1e4
        infiniteSlideBV.Parent = root
    end
    infiniteSlideBV.Velocity = projected * Config.InfiniteSlideSpeed
end

local InfiniteSlideStateOld = {
    inSlide = false,
    slideDir = Vector3.new(0, 0, 1),
}

function applyInfiniteSlideOld()
    if not Config.EnableInfiniteSlideOld then
        InfiniteSlideStateOld.inSlide = false
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local slideAttachment = root and root:FindFirstChild("Slide")
    local slideSound = slideAttachment and slideAttachment:FindFirstChild("SlideSound")
    if not char or not root or not slideSound then
        InfiniteSlideStateOld.inSlide = false
        return
    end

    if slideSound.Playing then
        if not InfiniteSlideStateOld.inSlide then
            InfiniteSlideStateOld.inSlide = true
            local velocity = root.AssemblyLinearVelocity
            local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
            if horizontal.Magnitude > 0.1 then
                InfiniteSlideStateOld.slideDir = horizontal.Unit
            end
        end
    elseif not InfiniteSlideStateOld.inSlide then
        return
    end

    local inputHeld = getInfiniteSlideInputHeld()
    if inputHeld == false or (inputHeld == nil and not slideSound.Playing) then
        InfiniteSlideStateOld.inSlide = false
        return
    end

    local velocity = root.AssemblyLinearVelocity
    InfiniteSlideStateOld.slideDir = getInfiniteSlideDirection(char, root)
    root.AssemblyLinearVelocity = Vector3.new(
        InfiniteSlideStateOld.slideDir.X * Config.InfiniteSlideSpeedOld,
        velocity.Y,
        InfiniteSlideStateOld.slideDir.Z * Config.InfiniteSlideSpeedOld
    )
end

function applyAutoJump()
    if not Config.AutoJump then return end

    local now = tick()
    if now < autoJumpNextTime then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    if hum:GetState() == Enum.HumanoidStateType.Running then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            local jumpsPerSecond = math.clamp(tonumber(Config.AutoJumpSpeed) or 1.5, 0.5, 8)
            autoJumpNextTime = now + (1 / jumpsPerSecond)
        end)
    else

        autoJumpNextTime = math.min(autoJumpNextTime, now)
    end
end

local crouchToggleFn  = nil
local crouchResolving = false

local function resolveCrouchToggleAsync()
    if crouchToggleFn or crouchResolving then return end
    crouchResolving = true

    task.spawn(function()
        local ok, btn = pcall(function()
            return LocalPlayer.PlayerGui
                :WaitForChild("Game",        5)
                :WaitForChild("HUD",         5)
                :WaitForChild("Mobile",      5)
                :WaitForChild("Right",       5)
                :WaitForChild("Mobile",      5)
                :WaitForChild("CrouchButton",5)
        end)

        if ok and btn then
            local conns = getconnections(btn.Activated)
            if not conns or #conns == 0 then
                conns = getconnections(btn.MouseButton1Click)
            end

            if conns and #conns > 0 and conns[1].Function then
                crouchToggleFn = conns[1].Function
                print("Auto Crouch: CrouchButton resolved successfully")
            else
                warn("[AutoCrouch] no accessible connections on CrouchButton")
            end
        else
            warn("[AutoCrouch] CrouchButton not found")
        end

        crouchResolving = false
    end)
end

function applyAutoCrouch()
    if not Config.AutoCrouch then return end

    if not crouchToggleFn then
        resolveCrouchToggleAsync()
        return
    end

    local now = tick()
    if now < autoCrouchNextTime then return end

    local ok = pcall(crouchToggleFn)
    if ok then
        local togglesPerSecond = math.clamp(tonumber(Config.AutoCrouchSpeed) or 1.5, 0.5, 24)
        autoCrouchNextTime = now + (1 / togglesPerSecond)
    end
end

local layerJumpsInstance = nil
local originalJumpCap = nil
local layerJumpsRespawned = false

function FindMoveStatsInstance()

    if layerJumpsInstance and not layerJumpsRespawned then return layerJumpsInstance end

    local ok, gcTable = pcall(getgc, true)
    if not ok or not gcTable then return layerJumpsInstance end

    local candidate = nil
    for i = 1, #gcTable do
        local v = gcTable[i]
        if type(v) == "table" then
            local ok2, ms = pcall(rawget, v, "MoveStats")
            if ok2 and type(ms) == "table" then
                local ok3, jc = pcall(rawget, ms, "JumpCap")
                if ok3 and type(jc) == "number" then

                    if layerJumpsRespawned then
                        if jc ~= Config.LayerJumpsCount then
                            candidate = v
                            break
                        end

                    else
                        candidate = v
                        break
                    end
                end
            end
        end
    end

    if candidate then
        layerJumpsInstance = candidate
        layerJumpsRespawned = false
    end
    return layerJumpsInstance
end

LocalPlayer.CharacterAdded:Connect(function()
    layerJumpsInstance = nil
    originalJumpCap = nil
    layerJumpsRespawned = true
    lastSpeedSelf, lastSpeedState, lastSpeedValue = nil, nil, nil
    getgenv().PerplexSpeedRestoreRequested = false
    if Config.EnableSpeedMultiplier then
        getgenv().PerplexSpeedApplyRequested = true
        task.delay(0.75, function()
            if getgenv().PerplexApplySpeedMultiplier then getgenv().PerplexApplySpeedMultiplier() end
        end)
    end
end)

function applyLayerJumps()
    if not Config.EnableLayerJumps then
        if layerJumpsInstance and originalJumpCap then
            pcall(function()
                local ms = rawget(layerJumpsInstance, "MoveStats")
                if type(ms) == "table" then
                    ms.JumpCap = originalJumpCap
                end
            end)
            originalJumpCap = nil
        end
        return
    end

    local inst = FindMoveStatsInstance()
    if not inst then return end

    pcall(function()
        local ms = rawget(inst, "MoveStats")
        if type(ms) == "table" and type(ms.JumpCap) == "number" then
            if not originalJumpCap then
                originalJumpCap = (ms.JumpCap ~= Config.LayerJumpsCount) and ms.JumpCap or 1
            end
            ms.JumpCap = Config.LayerJumpsCount
        end
    end)
end

local impulseCurrentSpeed = 42
local impulseWasAir = false
local activeImpulseBV = nil

function applyImpulseJump()
    if not Config.EnableImpulseJump then
        impulseWasAir = false
        impulseCurrentSpeed = Config.ImpulseJumpSpeed
        if activeImpulseBV then activeImpulseBV:Destroy() activeImpulseBV = nil end
        return
    end

    local baseSpeed = Config.ImpulseJumpSpeed

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    if humanoid.Health <= 0 then return end

    local isAir = humanoid.FloorMaterial == Enum.Material.Air

    if impulseWasAir and not isAir then
        impulseCurrentSpeed = baseSpeed
        impulseAirAccumulator = 0
        if activeImpulseBV then activeImpulseBV:Destroy() activeImpulseBV = nil end
    end
    impulseWasAir = isAir

    if not isAir then return end

    local lookDir = camera.CFrame.LookVector
    lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
    if lookDir.Magnitude ~= 0 then lookDir = lookDir.Unit end

    if not activeImpulseBV or not activeImpulseBV.Parent or activeImpulseBV.Parent ~= root then
        if activeImpulseBV then pcall(function() activeImpulseBV:Destroy() end) end
        activeImpulseBV = Instance.new("BodyVelocity")
        activeImpulseBV.MaxForce = Vector3.new(4e5, 0, 4e5)
        activeImpulseBV.P = 1250
        activeImpulseBV.Parent = root
    end
    activeImpulseBV.Velocity = lookDir * impulseCurrentSpeed
end

function applyGravityModification()
    if not Config.EnableGravityMod then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end

    local hum = char.Humanoid
    local rootPart = char.HumanoidRootPart

    if hum.Health <= 0 then return end

    pcall(function()
        local velocity = rootPart.AssemblyLinearVelocity

        if velocity.Y < 0 then
            rootPart.AssemblyLinearVelocity = Vector3.new(
                velocity.X,
                velocity.Y * Config.GravityScale,
                velocity.Z
            )
        end
    end)
end

function ActivateFrontalJump()
    if inEmote then return end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")

        if root and humanoid then
            if Config.EnableJumpAcceleration then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJumpTime = tick()
                return
            end
            local humanoidState = humanoid:GetState()
            local isOnGround = (humanoidState == Enum.HumanoidStateType.Landed or humanoidState == Enum.HumanoidStateType.Running)

            if isOnGround then

                local lookDir = camera.CFrame.LookVector
                lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
                if lookDir.Magnitude ~= 0 then
                    lookDir = lookDir.Unit
                end

                local rayOriginFront = root.Position
                local rayDirectionFront = lookDir * 10
                frontalRaycastParams.FilterDescendantsInstances = {char}
                local raycastResultFront = Workspace:Raycast(rayOriginFront, rayDirectionFront, frontalRaycastParams)

                if raycastResultFront and not Config.EnableJumpAcceleration then

                    rampLocked = true
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

                    task.delay(0.1, function()
                        if char and root then
                            local jumpBoost = getgenv().FrontalJumpSpeed * getgenv().RampMultiplier * 0.8
                            pcall(function()
                                root.AssemblyLinearVelocity = Vector3.new(
                                    root.AssemblyLinearVelocity.X,
                                    jumpBoost,
                                    root.AssemblyLinearVelocity.Z
                                )
                            end)
                        end
                    end)
                else

                    if not rampLocked then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end

                lastJumpTime = tick()
            end
        end
    end
end

function applyFrontalJump()
    if not Config.EnableFrontalJump and not Config.EnableJumpAcceleration then
        if activeBV then pcall(function() activeBV:Destroy() end) end
        activeBV = nil
        return
    end

    local deltaTime = tick() - lastTick
    lastTick = tick()
    local baseSpeed = Config.EnableJumpAcceleration and math.clamp(tonumber(Config.JumpAccelerationSpeed) or 42, 30, 110) or getgenv().FrontalJumpSpeed

    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")

        if root and humanoid then
            local isAir = humanoid.FloorMaterial == Enum.Material.Air
            local humanoidState = humanoid:GetState()
            local isOnGround = (humanoidState == Enum.HumanoidStateType.Landed or humanoidState == Enum.HumanoidStateType.Running) and not isAir

            local hitObject = false
            if wasAir and isOnGround then
                hitObject = true
                currentSpeed = baseSpeed
                airAccumulator = 0
                rampLocked = false
            end
            wasAir = isAir

            if isAir then
                local lookDir = camera.CFrame.LookVector
                lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)

                if lookDir.Magnitude ~= 0 then
                    lookDir = lookDir.Unit
                end

                if not activeBV or not activeBV.Parent or activeBV.Parent ~= root then
                    if activeBV then pcall(function() activeBV:Destroy() end) end
                    activeBV = Instance.new("BodyVelocity")
                    activeBV.MaxForce = Vector3.new(4e5, 0, 4e5)
                    activeBV.P = 1250
                    activeBV.Parent = root
                end
                activeBV.Velocity = lookDir * currentSpeed
            else

                airAccumulator = airAccumulator + deltaTime
                while airAccumulator >= 0.04 do
                    airAccumulator = airAccumulator - 0.04

                    currentSpeed = math.min(baseSpeed + 10, currentSpeed + 0.3)
                end

                local lookDir = camera.CFrame.LookVector
                lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)

                if lookDir.Magnitude ~= 0 then
                    lookDir = lookDir.Unit
                end

                local impulsePower = currentSpeed
                if not Config.EnableJumpAcceleration then

                    local rayOriginFront = root.Position
                    local rayDirectionFront = lookDir * 8
                    frontalRaycastParams.FilterDescendantsInstances = {char}
                    local raycastResultFront = Workspace:Raycast(rayOriginFront, rayDirectionFront, frontalRaycastParams)
                    if raycastResultFront then
                        impulsePower = currentSpeed * getgenv().RampMultiplier
                    end
                end

                if not activeBV or not activeBV.Parent or activeBV.Parent ~= root then
                    if activeBV then pcall(function() activeBV:Destroy() end) end
                    activeBV = Instance.new("BodyVelocity")
                    activeBV.MaxForce = Vector3.new(4e5, 0, 4e5)
                    activeBV.P = 1250
                    activeBV.Parent = root
                end
                activeBV.Velocity = lookDir * impulsePower

                currentSpeed = math.max(baseSpeed, currentSpeed - 2.5 * deltaTime)

                if tick() - lastJumpTime >= jumpInterval then
                    ActivateFrontalJump()
                end
            end
        end
    end
end

local rampMultPrevState = nil

function applyRampMultiplier()
    if not Config.EnableRampMultiplier then
        rampMultPrevState = nil
        return
    end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    local state = humanoid:GetState()
    local justJumped = (state == Enum.HumanoidStateType.Jumping and rampMultPrevState ~= Enum.HumanoidStateType.Jumping)
    rampMultPrevState = state

    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude < 0.05 then return end

    rampRaycastParams.FilterDescendantsInstances = {char}
    local hit = Workspace:Raycast(root.Position, moveDir.Unit * 8, rampRaycastParams)
    if not hit then return end

    if justJumped then

        local boost = humanoid.WalkSpeed * getgenv().RampMultiplierValue * 0.8
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X,
                boost,
                root.AssemblyLinearVelocity.Z
            )
        end)
    elseif humanoid.FloorMaterial ~= Enum.Material.Air then

        local currentVel = root.AssemblyLinearVelocity
        local boosted = moveDir.Unit * humanoid.WalkSpeed * getgenv().RampMultiplierValue
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(boosted.X, currentVel.Y, boosted.Z)
        end)
    end
end

function ActivateBackJump()
    if inEmote then return end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")

        if root and humanoid then
            local humanoidState = humanoid:GetState()
            local isOnGround = (humanoidState == Enum.HumanoidStateType.Landed or humanoidState == Enum.HumanoidStateType.Running)

            if isOnGround then
                local lookDir = camera.CFrame.LookVector
                local backDir = Vector3.new(-lookDir.X, 0, -lookDir.Z)
                if backDir.Magnitude ~= 0 then
                    backDir = backDir.Unit
                end

                local rayOriginBack = root.Position
                local rayDirectionBack = backDir * 10
                backRaycastParams.FilterDescendantsInstances = {char}
                local raycastResultBack = Workspace:Raycast(rayOriginBack, rayDirectionBack, backRaycastParams)

                if raycastResultBack then

                    backRampLocked = true
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

                    task.delay(0.1, function()
                        if char and root then
                            local jumpBoost = getgenv().BackJumpSpeed * getgenv().BackRampMultiplier * 0.8
                            pcall(function()
                                root.AssemblyLinearVelocity = Vector3.new(
                                    root.AssemblyLinearVelocity.X,
                                    jumpBoost,
                                    root.AssemblyLinearVelocity.Z
                                )
                            end)
                        end
                    end)
                else

                    if not backRampLocked then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end

                backLastJumpTime = tick()
            end
        end
    end
end

function applyBackJump()
    if not Config.EnableBackJump then
        if backActiveBV then pcall(function() backActiveBV:Destroy() end) end
        backActiveBV = nil
        return
    end

    local deltaTime = tick() - backLastTick
    backLastTick = tick()

    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")

        if root and humanoid then
            local isAir = humanoid.FloorMaterial == Enum.Material.Air
            local humanoidState = humanoid:GetState()
            local isOnGround = (humanoidState == Enum.HumanoidStateType.Landed or humanoidState == Enum.HumanoidStateType.Running) and not isAir

            if backWasAir and isOnGround then
                backCurrentSpeed = getgenv().BackJumpSpeed
                backAirAccumulator = 0
                backRampLocked = false
            end
            backWasAir = isAir

            local lookDir = camera.CFrame.LookVector
            local backDir = Vector3.new(-lookDir.X, 0, -lookDir.Z)
            if backDir.Magnitude ~= 0 then
                backDir = backDir.Unit
            end

            if isAir then

                if not backActiveBV or not backActiveBV.Parent or backActiveBV.Parent ~= root then
                    if backActiveBV then pcall(function() backActiveBV:Destroy() end) end
                    backActiveBV = Instance.new("BodyVelocity")
                    backActiveBV.MaxForce = Vector3.new(4e5, 0, 4e5)
                    backActiveBV.P = 1250
                    backActiveBV.Parent = root
                end
                backActiveBV.Velocity = backDir * backCurrentSpeed
            else

                backAirAccumulator = backAirAccumulator + deltaTime
                while backAirAccumulator >= 0.04 do
                    backAirAccumulator = backAirAccumulator - 0.04
                    backCurrentSpeed = math.min(getgenv().BackJumpSpeed + 10, backCurrentSpeed + 0.3)
                end

                local rayOriginBack = root.Position
                local rayDirectionBack = backDir * 8
                backRaycastParams.FilterDescendantsInstances = {char}
                local raycastResultBack = Workspace:Raycast(rayOriginBack, rayDirectionBack, backRaycastParams)

                local impulsePower = backCurrentSpeed
                if raycastResultBack then
                    impulsePower = backCurrentSpeed * getgenv().BackRampMultiplier
                end

                if not backActiveBV or not backActiveBV.Parent or backActiveBV.Parent ~= root then
                    if backActiveBV then pcall(function() backActiveBV:Destroy() end) end
                    backActiveBV = Instance.new("BodyVelocity")
                    backActiveBV.MaxForce = Vector3.new(4e5, 0, 4e5)
                    backActiveBV.P = 1250
                    backActiveBV.Parent = root
                end
                backActiveBV.Velocity = backDir * impulsePower

                backCurrentSpeed = math.max(getgenv().BackJumpSpeed, backCurrentSpeed - 2.5 * deltaTime)

                if tick() - backLastJumpTime >= backJumpInterval then
                    ActivateBackJump()
                end
            end
        end
    end
end

print("MOVEMENT: Functions loaded successfully")

print("FULLBRIGHT: Function loaded successfully")

local AutoTicketContexts = nil

function FindAutoTicketContexts()
    if AutoTicketContexts then return AutoTicketContexts end
    local ok, gcTable = pcall(getgc, true)
    if not ok or not gcTable then return nil end

    for i = 1, #gcTable do
        local v = gcTable[i]
        if type(v) == "table" then
            local ok2, first = pcall(function() return v[1] end)
            if ok2 and type(first) == "table" then
                local ok3, hasIds = pcall(rawget, first, "CollectableIDs")
                if ok3 and hasIds then
                    AutoTicketContexts = v
                    break
                end
            end
        end
    end

    return AutoTicketContexts
end

function GetServerPing()
    local ok, ping = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    return (ok and ping) or 0.1
end

function SmoothTp(part, targetCFrame, duration)
    if not part or not part.Parent then return end
    duration = duration or 0.3
    local startCFrame = part.CFrame
    local startTime = tick()

    while tick() - startTime < duration do
        if not Config.EnableAutoTicket then return end
        if not part or not part.Parent then return end
        local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
        pcall(function() part.CFrame = startCFrame:Lerp(targetCFrame, alpha) end)
        RunService.Heartbeat:Wait()
    end

    if part and part.Parent then
        pcall(function() part.CFrame = targetCFrame end)
    end
end

function applyAutoTicket()
    local contexts = FindAutoTicketContexts()
    if not contexts then return end

    local duration = 0.5 + math.clamp(GetServerPing(), 0, 0.5)

    for i = 1, #contexts do
        if not Config.EnableAutoTicket then return end
        local ctx = contexts[i]

        if type(ctx) == "table" and ctx.CollectableIDs then
            for _, collectable in pairs(ctx.CollectableIDs) do
                if not Config.EnableAutoTicket then return end

                local ok, position = pcall(function()
                    return collectable.CollectableData.Position
                end)

                if ok and position then
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        SmoothTp(root, CFrame.new(position), duration)
                        task.wait(2.5)
                    end
                end
            end
        end
    end
end

local autoTicketLoopStarted = false
function StartAutoTicketLoop()
    if autoTicketLoopStarted then return end
    autoTicketLoopStarted = true

    task.spawn(function()
        while true do
            if Config.EnableAutoTicket then
                pcall(applyAutoTicket)
            end
            task.wait(0.5)
        end
    end)
end

StartAutoTicketLoop()

print("AUTO TICKET: Function loaded successfully")

local VOID_Y_THRESHOLD = -350
function applyVoidEscape()
    if not Config.EnableVoidEscape then return end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if root.Position.Y > VOID_Y_THRESHOLD then return end

    pcall(function()
        root.CFrame = CFrame.new(0, 9e9, 0)
    end)
end

print("VOID ESCAPE: Function loaded successfully")

local CharServiceModule = nil
local InteractRemote = nil

function FindCharService()
    if CharServiceModule then return CharServiceModule end
    local ok, gcTable = pcall(getgc, true)
    if not ok or not gcTable then return nil end

    for i = 1, #gcTable do
        local v = gcTable[i]
        if type(v) == "table" then
            local ok2, hasGetCharacters = pcall(rawget, v, "GetCharacters")
            if ok2 and hasGetCharacters then
                CharServiceModule = v
                break
            end
        end
    end

    return CharServiceModule
end

function GetInteractRemote()
    if InteractRemote then return InteractRemote end
    local ok, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("Interact", 5)
    end)
    if ok and remote then
        InteractRemote = remote
    end
    return InteractRemote
end

function applyReviveAura()
    if not Config.EnableReviveAura then return end

    local charService = FindCharService()
    local interact = GetInteractRemote()
    if not charService or not interact then return end

    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local ok, chars = pcall(function() return charService:GetCharacters() end)
    if not ok or not chars then return end

    for i = 1, #chars do
        if not Config.EnableReviveAura then return end
        local v = chars[i]

        if type(v) == "table" and v.Done and not v.Local then
            local okState, isDowned = pcall(function() return v.State.State == "Downed" end)

            if okState and isDowned and v.PrimaryPart then
                local okDist, distance = pcall(function()
                    return (v.PrimaryPart.Position - myRoot.Position).Magnitude
                end)

                if okDist and distance < 30 then
                    pcall(function()
                        interact:FireServer("Revive", v.Tag, true)
                    end)

                    local reviveLength = 1.5
                    pcall(function()
                        reviveLength = v.DataRegistry:Get("ReviveLength") or 1.5
                    end)

                    task.wait(reviveLength)

                    local stillOk, stillDowned = pcall(function()
                        return v.State.State == "Downed" and v.PrimaryPart ~= nil
                    end)

                    if Config.EnableReviveAura and stillOk and stillDowned then
                        local okDist2, distance2 = pcall(function()
                            return (v.PrimaryPart.Position - myRoot.Position).Magnitude
                        end)
                        if okDist2 and distance2 < 30 then
                            pcall(function()
                                interact:FireServer("Revive", v.Tag)
                            end)
                        end
                    end
                end
            end
        end
    end
end

local reviveAuraLoopStarted = false
function StartReviveAuraLoop()
    if reviveAuraLoopStarted then return end
    reviveAuraLoopStarted = true

    task.spawn(function()
        while true do
            if Config.EnableReviveAura then
                pcall(applyReviveAura)
            end
            task.wait(0.5)
        end
    end)
end

StartReviveAuraLoop()

print("OK REVIVE AURA: Function loaded successfully")

local SetPlayerModeRemote = nil
local autoSpawnLastFired  = 0
local AUTO_SPAWN_COOLDOWN = 3

local function GetSetPlayerModeRemote()
    if SetPlayerModeRemote then return SetPlayerModeRemote end
    local ok, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("SetPlayerMode", 5)
    end)
    if ok and remote then
        SetPlayerModeRemote = remote
    end
    return SetPlayerModeRemote
end

local function applyAutoSpawn()
    if not Config.EnableAutoForceSpawn then return end

    local now = tick()
    if now - autoSpawnLastFired < AUTO_SPAWN_COOLDOWN then return end

    local charService = FindCharService()
    if not charService then return end

    local ok, chars = pcall(function() return charService:GetCharacters() end)
    if not ok or not chars then return end

    for i = 1, #chars do
        local v = chars[i]

        if type(v) == "table" and v.Done and v.Local then
            local okState, isDowned = pcall(function()
                return v.State and v.State.State == "Downed"
            end)
            if okState and isDowned then
                autoSpawnLastFired = now
                local remote = GetSetPlayerModeRemote()
                if remote then
                    pcall(function() remote:FireServer(true) end)
                    print("[AutoSpawn] Downed state detected - Force Spawn fired")
                else
                    warn("[AutoSpawn] SetPlayerMode remote not found")
                end
            end
            break
        end
    end
end

local autoSpawnLoopStarted = false
local function StartAutoSpawnLoop()
    if autoSpawnLoopStarted then return end
    autoSpawnLoopStarted = true

    task.spawn(function()
        while true do
            if Config.EnableAutoForceSpawn then
                pcall(applyAutoSpawn)
            end
            task.wait(0.2)
        end
    end)
end

StartAutoSpawnLoop()

print("OK AUTO SPAWN: Function loaded successfully")

local antiBotLastFired = 0

local function antiBotFindGroundY(position, excludeInstance)
    antiBotRaycastParams.FilterDescendantsInstances = {excludeInstance}
    local origin = position + Vector3.new(0, 50, 0)
    local ok, result = pcall(function()
        return Workspace:Raycast(origin, Vector3.new(0, -1000, 0), antiBotRaycastParams)
    end)
    if ok and result then
        return result.Position.Y
    end
    return nil
end

local function antiBotGetOtherPlayers(chars)
    local list = {}
    for i = 1, #chars do
        local v = chars[i]
        if type(v) == "table" and v.Done and not v.Local and v.PlayerReference and v.PrimaryPart then
            list[#list + 1] = v
        end
    end
    return list
end

local function applyAntiBot()
    if not Config.EnableAntiBot then return end

    local now = tick()
    if now - antiBotLastFired < Config.AntiBotCooldown then return end

    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local charService = FindCharService()
    if not charService then return end

    local ok, chars = pcall(function() return charService:GetCharacters() end)
    if not ok or not chars then return end

    local botDistance = nil
    for i = 1, #chars do
        local v = chars[i]
        if type(v) == "table" and v.Done and v.AI == true and v.PrimaryPart then
            local okDist, distance = pcall(function()
                return (v.PrimaryPart.Position - myRoot.Position).Magnitude
            end)
            if okDist and distance < Config.AntiBotDistance then
                botDistance = distance
                break
            end
        end
    end
    if not botDistance then return end

    local function tryPlayer()
        local others = antiBotGetOtherPlayers(chars)
        if #others == 0 then return false end
        local target = others[math.random(1, #others)]
        local okPos, pos = pcall(function() return target.PrimaryPart.Position end)
        if not okPos then return false end
        pcall(function()
            myRoot.CFrame = CFrame.new(pos + Vector3.new(math.random(-6, 6), 3, math.random(-6, 6)))
        end)
        return true
    end

    local function tryNearby()
        for attempt = 1, 5 do
            local angle  = math.random() * math.pi * 2
            local radius = math.random(20, 40)
            local candidate = myRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local groundY = antiBotFindGroundY(candidate, char)
            if groundY then
                pcall(function()
                    myRoot.CFrame = CFrame.new(candidate.X, groundY + 3, candidate.Z)
                end)
                return true
            end
        end
        return false
    end

    local preferPlayer = math.random() < 0.5
    local teleported
    if preferPlayer then
        teleported = tryPlayer() or tryNearby()
    else
        teleported = tryNearby() or tryPlayer()
    end

    if teleported then
        antiBotLastFired = now
        print("[AntiBot] Bot at " .. string.format("%.1f", botDistance) .. " studs - teleported")
    end

end

local antiBotLoopStarted = false
local antiBotAccumulator = 0
local ANTIBOT_REFRESH = 0.25
local function StartAntiBotLoop()
    if antiBotLoopStarted then return end
    antiBotLoopStarted = true

    RunService.Heartbeat:Connect(function(dt)
        if not Config.EnableAntiBot then return end
        antiBotAccumulator = antiBotAccumulator + dt
        if antiBotAccumulator < ANTIBOT_REFRESH then return end
        antiBotAccumulator = 0
        pcall(applyAntiBot)
    end)
end

StartAntiBotLoop()

print("OK ANTI BOT: Function loaded successfully")

local espDownEntries      = {}
local espDownAccumulator  = 0
local espDownConnection   = nil
local ESP_DOWN_COLOR      = Color3.fromRGB(255, 140, 0)
local ESP_DOWN_REFRESH    = 0.15

local function espDownClearEntry(tag)
    local e = espDownEntries[tag]
    if not e then return end
    pcall(function() if e.highlight then e.highlight:Destroy() end end)
    pcall(function() if e.billboard then e.billboard:Destroy() end end)
    espDownEntries[tag] = nil
end

local function espDownClearAll()
    for tag in pairs(espDownEntries) do
        espDownClearEntry(tag)
    end
end

local function espDownCreateEntry(tag, primaryPart, displayName)

    espDownClearEntry(tag)

    local highlight = Instance.new("Highlight")
    highlight.Name = "__EspDown_Highlight"
    highlight.Adornee = primaryPart.Parent or primaryPart
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = ESP_DOWN_COLOR
    highlight.OutlineColor = ESP_DOWN_COLOR
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Enabled = true
    highlight.Parent = primaryPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "__EspDown_Billboard"
    billboard.Adornee = primaryPart
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    pcall(function() billboard.MaxDistance = math.huge end)
    billboard.Size = UDim2.new(0, 300, 0, 36)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Enabled = true
    billboard.Parent = primaryPart

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = ESP_DOWN_COLOR
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextSize = 17
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Text = (displayName or "?") .. " [DOWN]"
    label.Parent = billboard

    espDownEntries[tag] = { highlight = highlight, billboard = billboard, label = label, displayName = displayName or "?" }
end

local function espDownRefresh()
    if not Config.EnableEspDown then return end

    local charService = FindCharService()
    if not charService then return end

    local ok, chars = pcall(function() return charService:GetCharacters() end)
    if not ok or not chars then return end

    local downedNow = {}
    for i = 1, #chars do
        local v = chars[i]
        if type(v) == "table" and v.Done and not v.Local and v.Tag and v.PrimaryPart then
            local okState, isDowned = pcall(function()
                return v.State and v.State.State == "Downed"
            end)
            if okState and isDowned then
                downedNow[v.Tag] = v
            end
        end
    end

    for tag in pairs(espDownEntries) do
        if not downedNow[tag] then
            espDownClearEntry(tag)
        end
    end

    for tag, v in pairs(downedNow) do
        if not espDownEntries[tag] then
            local displayName = "?"
            pcall(function()

                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then
                        local attr = p.Character:GetAttribute("Tag")
                        if attr == tag then
                            displayName = p.DisplayName
                            break
                        end
                    end
                end
            end)
            espDownCreateEntry(tag, v.PrimaryPart, displayName)
        else

            local e = espDownEntries[tag]
            if e and e.label then
                pcall(function()
                    local char = LocalPlayer.Character
                    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                    if myRoot and v.PrimaryPart then
                        local dist = math.floor((v.PrimaryPart.Position - myRoot.Position).Magnitude + 0.5)
                        e.label.Text = e.displayName .. "  |  " .. dist .. " m  [DOWN]"
                    end
                end)
            end
        end
    end
end

function espDownSetEnabled(state)
    if state then
        if not espDownConnection then
            espDownConnection = RunService.Heartbeat:Connect(function(dt)
                espDownAccumulator = espDownAccumulator + dt
                if espDownAccumulator >= ESP_DOWN_REFRESH then
                    espDownAccumulator = 0
                    pcall(espDownRefresh)
                end
            end)
        end
    else
        if espDownConnection then
            espDownConnection:Disconnect()
            espDownConnection = nil
        end
        espDownClearAll()
    end
end

if Config.EnableEspDown then
    task.defer(function()
        espDownSetEnabled(true)
    end)
end

print("OK ESP DOWN: Function loaded successfully")

local autoCarryLoopStarted = false
local carryActive       = false
local carryActiveTime   = 0
local CARRY_LOCK_SECS   = 2.0

local function applyAutoCarry()
    if not Config.EnableAutoCarry then
        carryActive = false
        return
    end

    local charService = FindCharService()
    local interact    = GetInteractRemote()
    if not charService or not interact then return end

    local char   = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local ok, chars = pcall(function() return charService:GetCharacters() end)
    if not ok or not chars then return end

    local serverState = nil
    for i = 1, #chars do
        local v = chars[i]
        if type(v) == "table" and v.Local and v.State then
            local okSt, st = pcall(function() return v.State.State end)
            if okSt then serverState = st end
            break
        end
    end

    local isCarryingNow = (serverState == "CarryIdle" or serverState == "CarryMove")

    if isCarryingNow then

        carryActive     = true
        carryActiveTime = tick()
        return
    end

    if carryActive then

        if tick() - carryActiveTime < CARRY_LOCK_SECS then return end

        carryActive = false
    end

    local range = (type(Config.CarryRange) == "number" and Config.CarryRange > 0)
        and Config.CarryRange or 30

    for i = 1, #chars do
        if not Config.EnableAutoCarry then return end
        local v = chars[i]

        if type(v) == "table" and v.Done and not v.Local then
            local okState, isDowned = pcall(function()
                return v.State and v.State.State == "Downed"
            end)

            if okState and isDowned and v.PrimaryPart then
                local okDist, distance = pcall(function()
                    return (v.PrimaryPart.Position - myRoot.Position).Magnitude
                end)

                if okDist and distance < range then
                    local tag = v.Tag
                    if tag then

                        carryActive     = true
                        carryActiveTime = tick()
                        pcall(function()
                            interact:FireServer("Carry", tag)
                        end)
                        break
                    end
                end
            end
        end
    end
end

local function StartAutoCarryLoop()
    if autoCarryLoopStarted then return end
    autoCarryLoopStarted = true

    task.spawn(function()
        while true do
            if Config.EnableAutoCarry then
                pcall(applyAutoCarry)
            end
            local interval = (type(Config.CarryInterval) == "number" and Config.CarryInterval > 0)
                and Config.CarryInterval or 0.2
            task.wait(interval)
        end
    end)
end

StartAutoCarryLoop()

print("OK AUTO CARRY: Function loaded successfully")

local autoSaveLoopStarted = false
local autoSaveBusy        = false

local function applyAutoSave()
    if not Config.EnableAutoSave then return end
    if autoSaveBusy then return end

    local charService = FindCharService()
    local interact    = GetInteractRemote()
    if not charService or not interact then return end

    local char   = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local ok, chars = pcall(function() return charService:GetCharacters() end)
    if not ok or not chars then return end

    for i = 1, #chars do
        if not Config.EnableAutoSave then return end
        local v = chars[i]

        if type(v) == "table" and v.Done and not v.Local then
            local okState, isDowned = pcall(function()
                return v.State and v.State.State == "Downed"
            end)

            if okState and isDowned and v.PrimaryPart then
                autoSaveBusy = true

                local savedTag = v.Tag
                pcall(function()

                    local targetPos = v.PrimaryPart.Position
                    myRoot.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))

                    task.wait(0.1)

                    interact:FireServer("Revive", savedTag, true)

                    local reviveLength = 1.5
                    pcall(function()
                        reviveLength = v.DataRegistry:Get("ReviveLength") or 1.5
                    end)

                    task.wait(reviveLength)

                    local stillOk, stillDowned = pcall(function()
                        return v.State.State == "Downed" and v.PrimaryPart ~= nil
                    end)

                    if Config.EnableAutoSave and stillOk and stillDowned then
                        interact:FireServer("Revive", savedTag)
                    end
                end)

                autoSaveBusy = false
                break
            end
        end
    end
end

local function StartAutoSaveLoop()
    if autoSaveLoopStarted then return end
    autoSaveLoopStarted = true

    task.spawn(function()
        while true do
            if Config.EnableAutoSave then
                pcall(applyAutoSave)
            end
            task.wait(0.5)
        end
    end)
end

StartAutoSaveLoop()

print("OK AUTO SAVE: Function loaded successfully")

local figure8T            = 0
local figure8CenterCF     = nil
local figure8Conn         = nil
local figure8PrevAnchor   = false
local figure8PrevWalkSpd  = 16

function StopFigure8Loop()

    if figure8Conn then
        figure8Conn:Disconnect()
        figure8Conn = nil
    end

    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = figure8PrevWalkSpd end
    end
    figure8CenterCF = nil
    print("X Figure-8 Loop STOPPED")
end

function StartFigure8Loop()
    StopFigure8Loop()

    local char = LocalPlayer.Character
    if not char then
        warn("[Figure-8] No character found")
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        warn("[Figure-8] HumanoidRootPart or Humanoid not found")
        return
    end

    figure8PrevAnchor  = hrp.Anchored
    figure8PrevWalkSpd = hum.WalkSpeed

    hum.WalkSpeed  = 0
    figure8T       = 0

    local lookVec = hrp.CFrame.LookVector
    figure8CenterCF = CFrame.new(hrp.Position)
        * CFrame.Angles(0, math.atan2(lookVec.X, lookVec.Z), 0)

    print("Figure-8 Loop STARTED at " .. tostring(hrp.Position))

    figure8Conn = RunService.Heartbeat:Connect(function(dt)
        if not Config.EnableFigure8 then return end

        local char2 = LocalPlayer.Character
        if not char2 then return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return end

        figure8T = figure8T + Config.Figure8Speed * dt

        local R  = Config.Figure8Radius
        local t  = figure8T

        local localX =  R       * math.cos(t)
        local localZ = (R * 0.5)* math.sin(2 * t)
        local tanX   = -R       * math.sin(t)
        local tanZ   =  R       * math.cos(2 * t)

        local right   = figure8CenterCF.RightVector
        local forward = figure8CenterCF.LookVector
        local origin  = figure8CenterCF.Position

        local worldPos = origin + right * localX + forward * localZ

        worldPos = Vector3.new(worldPos.X, origin.Y, worldPos.Z)

        local worldTan = right * tanX + forward * tanZ
        local tanMag   = worldTan.Magnitude

        local newCF
        if tanMag > 0.01 then
            newCF = CFrame.new(worldPos, worldPos + worldTan)
        else

            newCF = CFrame.new(worldPos, worldPos + forward)
        end

        hrp2.CFrame = newCF

        hrp2.AssemblyLinearVelocity  = Vector3.zero
        hrp2.AssemblyAngularVelocity = Vector3.zero
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if Config.EnableFigure8 then
        Config.EnableFigure8 = false
        StopFigure8Loop()
        print("[Figure-8] Character respawned - loop deactivated automatically")
    end
end)

print("OK FIGURE-8 LOOP: Function loaded successfully")

local lissajousT            = 0
local lissajousCenterCF     = nil
local lissajousConn         = nil
local lissajousPrevAnchor   = false
local lissajousPrevWalkSpd  = 16

function StopLissajousLoop()
    if lissajousConn then
        lissajousConn:Disconnect()
        lissajousConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = lissajousPrevWalkSpd end
    end
    lissajousCenterCF = nil
    print("X Lissajous Loop STOPPED")
end

function StartLissajousLoop()
    StopLissajousLoop()

    local char = LocalPlayer.Character
    if not char then
        warn("[Lissajous] No character found")
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        warn("[Lissajous] HumanoidRootPart or Humanoid not found")
        return
    end

    lissajousPrevAnchor  = hrp.Anchored
    lissajousPrevWalkSpd = hum.WalkSpeed

    hum.WalkSpeed = 0
    lissajousT    = 0

    local lookVec = hrp.CFrame.LookVector
    lissajousCenterCF = CFrame.new(hrp.Position)
        * CFrame.Angles(0, math.atan2(lookVec.X, lookVec.Z), 0)

    print("Lissajous Loop STARTED at " .. tostring(hrp.Position))

    lissajousConn = RunService.Heartbeat:Connect(function(dt)
        if not Config.EnableLissajous then return end

        local char2 = LocalPlayer.Character
        if not char2 then return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return end

        lissajousT = lissajousT + Config.LissajousSpeed * dt

        local R  = Config.LissajousRadius
        local t  = lissajousT
        local ph = math.pi / 4

        local localX = R * math.sin(3 * t)
        local localZ = R * math.sin(2 * t + ph)
        local tanX   = 3 * R * math.cos(3 * t)
        local tanZ   = 2 * R * math.cos(2 * t + ph)

        local right   = lissajousCenterCF.RightVector
        local forward = lissajousCenterCF.LookVector
        local origin  = lissajousCenterCF.Position

        local worldPos = origin + right * localX + forward * localZ
        worldPos = Vector3.new(worldPos.X, origin.Y, worldPos.Z)

        local worldTan = right * tanX + forward * tanZ
        local tanMag   = worldTan.Magnitude

        local newCF
        if tanMag > 0.01 then
            newCF = CFrame.new(worldPos, worldPos + worldTan)
        else
            newCF = CFrame.new(worldPos, worldPos + forward)
        end

        hrp2.CFrame = newCF
        hrp2.AssemblyLinearVelocity  = Vector3.zero
        hrp2.AssemblyAngularVelocity = Vector3.zero
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if Config.EnableLissajous then
        Config.EnableLissajous = false
        StopLissajousLoop()
        print("[Lissajous] Character respawned - loop deactivated automatically")
    end
end)

print("OK LISSAJOUS LOOP: Function loaded successfully")

local spiroT            = 0
local spiroCenterCF     = nil
local spiroConn         = nil
local spiroPrevAnchor   = false
local spiroPrevWalkSpd  = 16

function StopSpiroLoop()
    if spiroConn then
        spiroConn:Disconnect()
        spiroConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = spiroPrevWalkSpd end
    end
    spiroCenterCF = nil
    print("X Spirograph Loop STOPPED")
end

function StartSpiroLoop()
    StopSpiroLoop()

    local char = LocalPlayer.Character
    if not char then
        warn("[Spirograph] No character found")
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        warn("[Spirograph] HumanoidRootPart or Humanoid not found")
        return
    end

    spiroPrevAnchor  = hrp.Anchored
    spiroPrevWalkSpd = hum.WalkSpeed

    hum.WalkSpeed = 0
    spiroT        = 0

    local lookVec = hrp.CFrame.LookVector
    spiroCenterCF = CFrame.new(hrp.Position)
        * CFrame.Angles(0, math.atan2(lookVec.X, lookVec.Z), 0)

    print("Spirograph Loop STARTED at " .. tostring(hrp.Position))

    spiroConn = RunService.Heartbeat:Connect(function(dt)
        if not Config.EnableSpiro then return end

        local char2 = LocalPlayer.Character
        if not char2 then return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return end

        spiroT = spiroT + Config.SpiroSpeed * dt

        local R  = Config.SpiroRadius
        local r  = R * Config.SpiroRatio
        local Rr = R - r
        local k  = Rr / r
        local t  = spiroT

        local localX = Rr * math.cos(t) + r * math.cos(k * t)
        local localZ = Rr * math.sin(t) - r * math.sin(k * t)
        local tanX   = -Rr * math.sin(t) - r * k * math.sin(k * t)
        local tanZ   =  Rr * math.cos(t) - r * k * math.cos(k * t)

        local right   = spiroCenterCF.RightVector
        local forward = spiroCenterCF.LookVector
        local origin  = spiroCenterCF.Position

        local worldPos = origin + right * localX + forward * localZ
        worldPos = Vector3.new(worldPos.X, origin.Y, worldPos.Z)

        local worldTan = right * tanX + forward * tanZ
        local tanMag   = worldTan.Magnitude

        local newCF
        if tanMag > 0.01 then
            newCF = CFrame.new(worldPos, worldPos + worldTan)
        else
            newCF = CFrame.new(worldPos, worldPos + forward)
        end

        hrp2.CFrame = newCF
        hrp2.AssemblyLinearVelocity  = Vector3.zero
        hrp2.AssemblyAngularVelocity = Vector3.zero
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if Config.EnableSpiro then
        Config.EnableSpiro = false
        StopSpiroLoop()
        print("[Spirograph] Character respawned - loop deactivated automatically")
    end
end)

print("OK SPIROGRAPH LOOP: Function loaded successfully")

local MovementStatModule = nil
local originalSpeedChange = nil
local speedMultiplierHooked = false
local inEmote = false
getgenv().PerplexSpeedApplyRequested = Config.EnableSpeedMultiplier == true

function FindMovementStat()
    if MovementStatModule then return MovementStatModule end
    local ok, gcTable = pcall(getgc, true)
    if not ok or not gcTable then return nil end

    for i = 1, #gcTable do
        local v = gcTable[i]
        if type(v) == "table" then
            local ok2, isValid = pcall(function()
                return rawget(v, "SpeedChange") and type(v.SpeedChange) == "function"
            end)
            if ok2 and isValid then
                MovementStatModule = v
                break
            end
        end
    end

    return MovementStatModule
end

function SetupSpeedMultiplierHook()
    if speedMultiplierHooked then return end
    if not hookfunction then return end

    local movementStat = FindMovementStat()
    if not movementStat then return end

    inEmote = false

    local ok = pcall(function()
        originalSpeedChange = hookfunction(movementStat.SpeedChange, function(self, state, value)
            if state == "Emote" then
                if value ~= nil then

                    inEmote = true
                    inEvadeEmote = true
                    if Config.EnableEmoteSpeed then
                        return originalSpeedChange(self, state, Config.EmoteSpeedMultiplier)
                    end
                    return originalSpeedChange(self, state, value)
                else

                    inEmote = false
                    inEvadeEmote = false
                    task.spawn(cleanupActiveEmote)
                    return originalSpeedChange(self, state, value)
                end
            end
            if state == "State" then
                lastSpeedSelf, lastSpeedState, lastSpeedValue = self, state, value
                if getgenv().PerplexSpeedRestoreRequested and not Config.EnableSpeedMultiplier then
                    task.defer(function()
                        if getgenv().PerplexRestoreSpeedMultiplier then
                            getgenv().PerplexRestoreSpeedMultiplier()
                        end
                    end)
                end
            end
            if (state ~= "State" and state ~= "Emote") or not Config.EnableSpeedMultiplier then
                return originalSpeedChange(self, state, value)
            end
            return originalSpeedChange(self, state, Config.SpeedMultiplierValue)
        end)
    end)

    if ok then
        speedMultiplierHooked = true
        print("SPEED MULTIPLIER: Hook connected")
        if Config.EnableSpeedMultiplier then
            getgenv().PerplexSpeedApplyRequested = true
            task.defer(function()
                if getgenv().PerplexApplySpeedMultiplier then getgenv().PerplexApplySpeedMultiplier() end
            end)
        end
        if getgenv().PerplexSpeedRestoreRequested and not Config.EnableSpeedMultiplier then
            task.defer(function()
                if getgenv().PerplexRestoreSpeedMultiplier then
                    getgenv().PerplexRestoreSpeedMultiplier()
                end
            end)
        end
    end
end

getgenv().PerplexApplySpeedMultiplier = function()
    if not Config.EnableSpeedMultiplier or not originalSpeedChange then return false end
    local target = lastSpeedSelf or MovementStatModule
    if not target then return false end
    local ok = pcall(originalSpeedChange, target, "State", Config.SpeedMultiplierValue)
    if ok then getgenv().PerplexSpeedApplyRequested = false end
    return ok
end

getgenv().PerplexRestoreSpeedMultiplier = function()
    if not originalSpeedChange or not lastSpeedSelf or lastSpeedState ~= "State" then
        return false
    end
    if lastSpeedValue == nil then
        return false
    end

    local ok = pcall(originalSpeedChange, lastSpeedSelf, lastSpeedState, lastSpeedValue)
    if ok then
        getgenv().PerplexSpeedRestoreRequested = false
        lastSpeedSelf, lastSpeedState, lastSpeedValue = nil, nil, nil
    end
    return ok
end

addTabHeader("Emote", "Speed Hook", 14)
local speedHookDiagLabel = addTabLabel("Emote", "Speed Hook: waiting...", "info")

local function TryHookSpeedMultiplier()
    if speedMultiplierHooked then return end
    pcall(SetupSpeedMultiplierHook)
    if speedHookDiagLabel then
        if speedMultiplierHooked then
            speedHookDiagLabel:SetText("Speed Hook: hooked")
        else
            speedHookDiagLabel:SetText("Speed Hook: failed, retrying on next respawn")
        end
    end
end

TryHookSpeedMultiplier()

LocalPlayer.CharacterAdded:Connect(function()
    if speedMultiplierHooked then return end
    task.defer(TryHookSpeedMultiplier)
end)

task.spawn(function()

    local updateMapBound = false
    local stateBound = false
    for _ = 1, 90 do
        if speedMultiplierHooked then break end

        local events = ReplicatedStorage:FindFirstChild("Events")
        local updateMap = events and events:FindFirstChild("UpdateMap")
        if not updateMapBound and updateMap and updateMap:IsA("RemoteEvent") then
            updateMapBound = true
            updateMap.OnClientEvent:Connect(function()
                if speedMultiplierHooked then return end
                task.defer(TryHookSpeedMultiplier)
            end)
        end

        local services = ReplicatedStorage:FindFirstChild("Services")
        local data = services and services:FindFirstChild("Data")
        local registry = data and data:FindFirstChild("ServerStateRegistryService")
        local changedEvent = registry and registry:FindFirstChild("ChangedEvent")
        if not stateBound and changedEvent and changedEvent:IsA("BindableEvent") then
            stateBound = true
            changedEvent.Event:Connect(function(key, value)
                if speedMultiplierHooked then return end
                if (key == "MapLoading" and value == true)
                or (key == "Voting" and value == true) then
                    task.defer(TryHookSpeedMultiplier)
                end
            end)
        end

        if updateMapBound and stateBound then break end
        task.wait(1)
    end
end)

print("SPEED MULTIPLIER: Function loaded successfully")

local trimpWasAir = false

function applyAutoTrimp()
    if not Config.EnableAutoTrimp and not Config.EnableTrimpTeleport then return end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    if humanoid.Health <= 0 then return end

    local isAir = humanoid.FloorMaterial == Enum.Material.Air

    pcall(function()
        if isAir then

            local vel = root.AssemblyLinearVelocity
            if vel.Y < 0 then
                root.AssemblyLinearVelocity = Vector3.new(
                    vel.X,
                    vel.Y * Config.AutoTrimpFallSpeed,
                    vel.Z
                )
            end
        else

            if trimpWasAir then
                local vel = root.AssemblyLinearVelocity
                local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
                local impulse = math.max(horizontalSpeed, 20) * Config.AutoTrimpMultiplier
                root.AssemblyLinearVelocity = Vector3.new(
                    vel.X,
                    impulse,
                    vel.Z
                )
            end
        end
    end)

    trimpWasAir = isAir
end

print("OK AUTO TRIMP: Function loaded successfully")

print("\nActivating main loop...")

local function mainLoopTick()
    applyTeleportWalk()
    applyEnhancedJump()
    applyAutoJump()
    applyAutoCrouch()
    applyLayerJumps()
    applyImpulseJump()
    applyGravityModification()
    applyFrontalJump()
    applyRampMultiplier()
    applyBackJump()
    applyVoidEscape()
    applyAutoTrimp()
    applyInfiniteSlide()
    applyInfiniteSlideOld()
end

local connection = RunService.Heartbeat:Connect(function()
    pcall(mainLoopTick)
end)

print("LOOP: Main loop started")

print("\n" .. string.rep("=", 80))
print("PerplexWare loaded")
print("Menu key: RightControl")
print("Discord | @rainlover.r")
print("https://dsc.gg/perplexware/")
print(string.rep("=", 80) .. "\n")

function setupAllTab()
local AllStatus
local AllCount
local AllSearch
local AllTable
local AllCandidates = {}
local AllCandidateByPath = {}
local AllCurrentRoot = nil
local AllDiscoveryRunning = false
local AllDiscoveryToken = 0
local AllMaxDiscoveryNodes = 2200
local AllDiscoveryBatch = 18
local AllDiscoveryWait = 0.035
local AllTabVisible = false
local ALL_MAX_VISIBLE = 60

addTabHeader("All", "Visual Catalog", 15)
AllStatus = addTabLabel("All", "Preparing catalog...", "info")
AllCount = addTabLabel("All", "Candidates: 0", "list")
AllSearch = addTabTextBox("All", "Search", "Search name or path...", function()
    if not AllDiscoveryRunning and AllTabVisible then
        allRebuildRows()
    end
end)
PerplexUI.Sections.All:AddParagraph({
    Title = "How to use",
    Content = "Select a row to test it on your rig.\nHeavy rendering only happens on select.",
})
AllTable = PerplexUI.Sections.All:AddDataTable({
    Height = 220,
    EmptyText = "No candidates yet",
    Columns = {
        { Key = "Name", Title = "Name" },
        { Key = "Kind", Title = "Type" },
        { Key = "Path", Title = "Path" },
    },
    Rows = {},
    OnSelect = function(row)
        local candidate = row and AllCandidateByPath[row.Path]
        if candidate then
            allTestCandidate(candidate)
        end
    end,
})

function allSetStatus(text)
    if AllStatus then
        AllStatus:SetText(tostring(text))
    end
end

function allSetCount(value)
    if AllCount then
        AllCount:SetText("Candidates: " .. tostring(value))
    end
end

function allLower(value)
    return string.lower(tostring(value or ""))
end

local AllExcludedNames = {
    defectrebel = true,
    davethebrickbattler = true,
    darkestknight = true,
    cursedkrampus = true,
    combustor = true,
    clark = true,
    catbobosuit = true,
    capeofposeidon = true,
    bunnyjard = true,
    bobo = true,
    anniversaryfireworks = true,
    anniversarycatjard = true,
    duckywaterfall = true,
    frostysnowman = true,
    gardenerjard = true,
    ghost = true,
    ghostlyanchor = true,
    frankenstein = true,
    interloper = true,
    jardclown = true,
    jard = true,
    jardsunderland = true,
    jollysanta = true,
    krampus = true,
    leviathananchor = true,
    lupen = true,
    markv = true,
    masterchief = true,
    mechanicalbugler = true,
    overseer = true,
    pootis = true,
    poseidon = true,
    retrosunset = true,
    seal = true,
    sharkbobo = true,
    spy = true,
    summerjard = true,
    thecorrupted = true,
    thehidden = true,
    trooper = true,
    vanguard = true,
    weepingbobo = true,
    werewolf = true,
    woodennutcracker = true,
    workerelf = true,
    zombie = true,
    zombieskeleton = true,
}

function allIsExcludedName(name)
    return AllExcludedNames[allLower(name)] == true
end

function allPathOf(instance)
    local parts = {}
    local current = instance
    while current and current ~= game do
        parts[#parts + 1] = current.Name
        current = current.Parent
    end
    local result = {}
    for index = #parts, 1, -1 do
        result[#result + 1] = parts[index]
    end
    return table.concat(result, ".")
end

function allIsCosmeticsPath(instance)
    local path = allLower(allPathOf(instance))
    return string.find(path, ".cosmetics", 1, true) ~= nil
        or allLower(instance.Name) == "cosmetics"
end

function allMatchesSearch(candidate)
    if allIsExcludedName(candidate.name) then return false end
    local query = allLower(AllSearch.Value)
    if query == "" then return true end
    return string.find(allLower(candidate.name), query, 1, true) ~= nil
        or string.find(allLower(candidate.path), query, 1, true) ~= nil
end

function allClearRows()
    AllCandidateByPath = {}
    if AllTable then
        AllTable:Clear()
    end
end

local bodyNames = {
    ["head"] = true, ["torso"] = true, ["left arm"] = true, ["right arm"] = true,
    ["left leg"] = true, ["right leg"] = true, ["uppertorso"] = true,
    ["lowertorso"] = true, ["lefthand"] = true, ["righthand"] = true,
    ["leftupperarm"] = true, ["rightupperarm"] = true,
    ["leftlowerarm"] = true, ["rightlowerarm"] = true,
    ["leftupperleg"] = true, ["rightupperleg"] = true,
    ["leftlowerleg"] = true, ["rightlowerleg"] = true,
    ["leftfoot"] = true, ["rightfoot"] = true,
    ["humanoidrootpart"] = true, ["torsorot"] = true, ["armrot"] = true,
}

function allIsReferenceBodyPart(instance)
    if not instance:IsA("BasePart") then return false end
    local name = allLower(instance.Name)
    return bodyNames[name]
        or string.find(name, "body", 1, true) ~= nil
        or string.find(name, "limb", 1, true) ~= nil
end

function allPrepareVisualModel(model)
    local hidden = 0
    local parts = 0
    local vfx = 0
    local sounds = 0
    for _, instance in ipairs(model:GetDescendants()) do
        if instance:IsA("BasePart") then
            parts = parts + 1
            instance.CanCollide = false
            instance.CanTouch = false
            instance.CanQuery = false
            instance.Massless = true
            if allIsReferenceBodyPart(instance) then
                instance.Transparency = 1
                hidden = hidden + 1
            end
        elseif instance:IsA("ParticleEmitter")
            or instance:IsA("Beam")
            or instance:IsA("Trail")
            or instance:IsA("Highlight")
            or instance:IsA("PointLight")
            or instance:IsA("SpotLight")
            or instance:IsA("SurfaceLight") then
            vfx = vfx + 1
        elseif instance:IsA("Sound") then
            sounds = sounds + 1
        end
    end
    return hidden, parts, vfx, sounds
end

function allRepairInternalJoints(model)
    local repaired = 0
    for _, joint in ipairs(model:GetDescendants()) do
        if joint:IsA("Motor6D") or joint:IsA("Weld") then
            local p0 = joint.Part0
            local p1 = joint.Part1
            if p0 and not p0:IsDescendantOf(model) then
                local replacement = model:FindFirstChild(p0.Name, true)
                if replacement and replacement:IsA("BasePart") then
                    pcall(function() joint.Part0 = replacement end)
                    repaired = repaired + 1
                end
            end
            if p1 and not p1:IsDescendantOf(model) then
                local replacement = model:FindFirstChild(p1.Name, true)
                if replacement and replacement:IsA("BasePart") then
                    pcall(function() joint.Part1 = replacement end)
                    repaired = repaired + 1
                end
            end
        end
    end
    return repaired
end

function allGetTargetRig()
    local rigs = Workspace:FindFirstChild("Rigs")
    local rig = rigs and rigs:FindFirstChild(LocalPlayer.Name)
    if not rig then rig = Workspace:FindFirstChild(LocalPlayer.Name) end
    if not rig then return nil, nil end
    local root = rig:FindFirstChild("HumanoidRootPart")
        or rig:FindFirstChild("Torso")
        or rig:FindFirstChild("UpperTorso")
        or rig.PrimaryPart
    return rig, root
end

function allRemoveCurrent()
    if AllCurrentRoot then
        pcall(function() AllCurrentRoot:Destroy() end)
        AllCurrentRoot = nil
    end
    local existing = Workspace:FindFirstChild("__Perplex_AllVisualCandidates")
    if existing then pcall(function() existing:Destroy() end) end
    allSetStatus("All candidates were removed")
end

function allTestCandidate(candidate)
    allRemoveCurrent()
    local sourceModule = candidate.module
    if not sourceModule or not sourceModule.Parent then
        allSetStatus(candidate.name .. " is no longer available")
        return
    end
    local rig, targetRoot = allGetTargetRig()
    if not rig or not targetRoot then
        allSetStatus("Visual rig or its root not found")
        return
    end

    local characterModel = sourceModule:FindFirstChild("CharacterClassic")
        or sourceModule:FindFirstChild("Character")
    local sourceAura = sourceModule:FindFirstChild("Aura")
    local useModel = candidate.kind == "model" and characterModel and characterModel:IsA("Model")
    local useAura = candidate.kind == "aura"
        and sourceAura
        and (sourceAura:IsA("BasePart") or sourceAura:IsA("Model"))
    if not useModel and not useAura then
        allSetStatus(candidate.name .. " no longer has a compatible visual format")
        return
    end

    local container = Workspace:FindFirstChild("__Perplex_AllVisualCandidates")
    if not container then
        container = Instance.new("Folder")
        container.Name = "__Perplex_AllVisualCandidates"
        container.Parent = Workspace
    end

    local ok, clone = pcall(function()
        if useModel then
            return characterModel:Clone()
        end
        if sourceAura:IsA("BasePart") then
            local wrapper = Instance.new("Model")
            local auraClone = sourceAura:Clone()
            auraClone.Parent = wrapper
            wrapper.PrimaryPart = auraClone
            return wrapper
        end
        return sourceAura:Clone()
    end)
    if not ok or not clone then
        allSetStatus("Could not clone " .. candidate.name)
        return
    end

    clone.Name = candidate.name .. (useModel and "_VisualOnly" or "_AuraVisualOnly")
    clone.Parent = container
    local hidden, parts, vfx, sounds = allPrepareVisualModel(clone)
    if useAura then
        local carrier = clone:FindFirstChild("Aura", true)
        if carrier and carrier:IsA("BasePart") then
            carrier.Transparency = 1
        end
    end
    local repaired = allRepairInternalJoints(clone)
    local cloneRoot = clone:FindFirstChild("HumanoidRootPart", true)
        or clone:FindFirstChild("Torso", true)
        or clone.PrimaryPart
    if not cloneRoot or not cloneRoot:IsA("BasePart") then
        pcall(function() clone:Destroy() end)
        allSetStatus(candidate.name .. " has no root part")
        return
    end

    clone.PrimaryPart = cloneRoot
    pcall(function() clone:PivotTo(targetRoot.CFrame) end)
    local weld = Instance.new("WeldConstraint")
    weld.Name = "__Perplex_AllFollowTarget"
    weld.Part0 = cloneRoot
    weld.Part1 = targetRoot
    weld.Parent = cloneRoot
    AllCurrentRoot = container
    allSetStatus(candidate.name .. " active | body hidden " .. tostring(hidden) .. "/" .. tostring(parts) .. " | VFX " .. tostring(vfx) .. " | joints " .. tostring(repaired) .. " | sounds " .. tostring(sounds))
end

function allRebuildRows()
    allClearRows()
    if not AllTabVisible then
        allSetStatus(tostring(#AllCandidates) .. " candidates discovered | open the tab to see them")
        return
    end
    local matched = 0
    local shown = 0
    local rows = {}
    for _, candidate in ipairs(AllCandidates) do
        if allMatchesSearch(candidate) then
            matched = matched + 1
            if shown < ALL_MAX_VISIBLE then
                shown = shown + 1
                AllCandidateByPath[candidate.path] = candidate
                rows[#rows + 1] = { Name = candidate.name, Kind = candidate.kind, Path = candidate.path }
            end
        end
    end
    AllTable:SetRows(rows)
    if matched > shown then
        allSetStatus(tostring(shown) .. "/" .. tostring(matched) .. " rows visible (max " .. tostring(ALL_MAX_VISIBLE) .. ") | filter to find faster")
    else
        allSetStatus(tostring(shown) .. " rows visible | " .. tostring(#AllCandidates) .. " candidates discovered")
    end
end

function allDiscoverCandidates()
    if AllDiscoveryRunning then return end
    AllDiscoveryRunning = true
    AllDiscoveryToken = AllDiscoveryToken + 1
    local token = AllDiscoveryToken
    allClearRows()
    AllCandidates = {}
    allSetCount(0)
    allSetStatus("Discovering modules under Cosmetics...")

    task.spawn(function()
        local items = ReplicatedStorage:FindFirstChild("Items")
        local roots = {}
        if items then
            local baseItems = items:FindFirstChild("BaseItems")
            local baseCosmetics = baseItems and baseItems:FindFirstChild("Cosmetics")
            if baseCosmetics then roots[#roots + 1] = baseCosmetics end
            local itemPacks = items:FindFirstChild("ItemPacks")
            if itemPacks then roots[#roots + 1] = itemPacks end
        end

        local queue = {}
        for _, root in ipairs(roots) do queue[#queue + 1] = root end
        local queueIndex = 1
        local visited = {}
        local seenModules = {}
        local scanned = 0
        local limitReached = false

        while queueIndex <= #queue and scanned < AllMaxDiscoveryNodes and token == AllDiscoveryToken do
            local batch = 0
            while batch < AllDiscoveryBatch
                and queueIndex <= #queue
                and scanned < AllMaxDiscoveryNodes
                and token == AllDiscoveryToken do
                local node = queue[queueIndex]
                queueIndex = queueIndex + 1
                batch = batch + 1
                scanned = scanned + 1
                if node and not visited[node] then
                    visited[node] = true
                    if node:IsA("ModuleScript") and allIsCosmeticsPath(node)
                        and not allIsExcludedName(node.Name)
                        and not seenModules[node] then
                        local characterModel = node:FindFirstChild("CharacterClassic")
                            or node:FindFirstChild("Character")
                        local auraObject = node:FindFirstChild("Aura")
                        local candidateKind
                        if characterModel and characterModel:IsA("Model") then
                            candidateKind = "model"
                        elseif auraObject
                            and (auraObject:IsA("BasePart") or auraObject:IsA("Model")) then
                            candidateKind = "aura"
                        end
                        if candidateKind then
                            seenModules[node] = true
                            AllCandidates[#AllCandidates + 1] = {
                                name = node.Name,
                                path = allPathOf(node),
                                module = node,
                                kind = candidateKind,
                            }
                        end
                    end
                    if node:IsA("Folder") then
                        local nodeName = allLower(node.Name)
                        local skipFolder = nodeName == "emotes"
                            or nodeName == "boomboxes"
                            or nodeName == "loadout"
                            or nodeName == "carryanimations"
                        if not skipFolder then
                            for _, child in ipairs(node:GetChildren()) do
                                if child:IsA("Folder") or child:IsA("ModuleScript") then
                                    queue[#queue + 1] = child
                                end
                            end
                        end
                    end
                end
            end
            allSetCount(#AllCandidates)
            allSetStatus("Scanning " .. tostring(scanned) .. " nodes | " .. tostring(#AllCandidates) .. " candidates")
            task.wait(AllDiscoveryWait)
        end

        if scanned >= AllMaxDiscoveryNodes and queueIndex <= #queue then
            limitReached = true
        end
        table.sort(AllCandidates, function(a, b)
            local al = allLower(a.name)
            local bl = allLower(b.name)
            if al == bl then return allLower(a.path) < allLower(b.path) end
            return al < bl
        end)
        AllDiscoveryRunning = false
        allSetCount(#AllCandidates)
        if AllTabVisible then
            allRebuildRows()
        end
        if limitReached then
            allSetStatus("Limit reached | " .. tostring(#AllCandidates) .. " candidates | press Refresh List")
        else
            allSetStatus("Done | " .. tostring(#AllCandidates) .. " candidates | search or scroll")
        end
    end)
end

addTabButton("All", "Refresh List", allDiscoverCandidates)
addTabButton("All", "Remove All", allRemoveCurrent)

Window:On("TabChanged", function(tab)
    AllTabVisible = tab ~= nil and tab.Title == "All"
    if not AllDiscoveryRunning then
        allRebuildRows()
    end
end)

local oldAllVisuals = Workspace:FindFirstChild("__Perplex_AllVisualCandidates")
if oldAllVisuals then pcall(function() oldAllVisuals:Destroy() end) end

local AllInitOk, AllInitError = pcall(allDiscoverCandidates)
if not AllInitOk then
    allSetStatus("All tab error: " .. tostring(AllInitError))
    warn("[All] Discovery start error: " .. tostring(AllInitError))
end

end

setupAllTab()

refreshActiveFeatures()

Window:Notify({
    Title = "PerplexWare",
    Content = "Loaded. Press RightControl to hide or show the menu.",
    Type = "Success",
    Duration = 5,
})

return Window
