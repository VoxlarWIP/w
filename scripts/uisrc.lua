local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Library = {
    Name = "Perplexity",
    Version = "3.0.0",
    Author = "@rainlover.r and Claude.AI",
    DefaultIconPack = "Lucide",
    IconSources = {
        Material = "https://raw.githubusercontent.com/Skinny-yz/NullUI-Assets/main/icons/MaterialIcons.luau",
        Lucide = "https://raw.githubusercontent.com/Skinny-yz/NullUI-Assets/main/icons/LucideIcons.luau",
        Phosphor = "https://raw.githubusercontent.com/Skinny-yz/NullUI-Assets/main/icons/Phosphor.luau",
        ["Phosphor-Filled"] = "https://raw.githubusercontent.com/Skinny-yz/NullUI-Assets/main/icons/Phosphor%20Filled.luau",
        SF = "https://raw.githubusercontent.com/Skinny-yz/NullUI-Assets/main/icons/SFSymbols.luau",
    },
}

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local INTER_FAMILY = "rbxassetid://12187365364"

local function sansFont(weight)
    return Font.new(INTER_FAMILY, weight, Enum.FontStyle.Normal)
end

local function monoFont(weight)
    local ok, font = pcall(function()
        return Font.fromName("RobotoMono", weight)
    end)
    if ok and font then
        return font
    end
    return Font.fromEnum(Enum.Font.Code)
end

local FontSets = {
    Sans = {
        Regular = sansFont(Enum.FontWeight.Regular),
        Medium = sansFont(Enum.FontWeight.Medium),
        Semi = sansFont(Enum.FontWeight.SemiBold),
        Bold = sansFont(Enum.FontWeight.Bold),
    },
    Mono = {
        Regular = monoFont(Enum.FontWeight.Regular),
        Medium = monoFont(Enum.FontWeight.Medium),
        Semi = monoFont(Enum.FontWeight.SemiBold),
        Bold = monoFont(Enum.FontWeight.Bold),
    },
}

local FONT_TOKENS = { Regular = "FontRegular", Medium = "FontMedium", Semi = "FontSemi", Bold = "FontBold" }

local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local Styles = {
    Perplexity = {
        Id = "Perplexity",
        Display = "Perplexity (Original)",
        Nav = "Sidebar",
        SingleColumn = true,
        RailFraction = 0.18,
        RailWidth = 170,
        RailWidthMobile = 100,
        ShowLabels = true,
        ShowIcons = true,
        Traffic = false,
        ToggleKind = "Switch",
        Terminal = false,
        Liquid = true,
        Border = true,
        Glow = false,
        Footer = true,
        Mono = false,
        Colors = {
            SurfaceHi = rgb(22, 28, 64), Dialog = rgb(30, 38, 92), DialogHi = rgb(44, 54, 120), LiquidA = rgb(8, 14, 56), LiquidB = rgb(40, 84, 235), LiquidC = rgb(96, 72, 230), LiquidSpec = rgb(150, 196, 255),
            Accent = rgb(79, 91, 255), AccentAlt = rgb(139, 92, 246), Background = rgb(7, 9, 24),
            Surface = rgb(14, 18, 44), SurfaceAlt = rgb(24, 30, 72), Outline = rgb(52, 62, 132),
            Text = rgb(236, 238, 255), Muted = rgb(138, 148, 198), Hover = rgb(34, 42, 96),
            ToggleOn = rgb(79, 91, 255), ToggleOff = rgb(74, 80, 124), Knob = rgb(176, 184, 232),
            Success = rgb(52, 211, 120), Warning = rgb(245, 176, 65), Danger = rgb(244, 86, 96),
        },
        Numbers = { TransWindow = 0.1, TransPanel = 0.4, TransCard = 0.5, TransField = 0.35, TransSheen = 0.94, TransStroke = 0.35, TransLine = 1, TransHeader = 0.72, TransRail = 0.8 },
        Radius = { RadWindow = 16, RadPanel = 12, RadCard = 10, RadControl = 8, RadIcon = 99, RadPill = 99, RadBlob = 9999 },
    },
    MacLauncher = {
        Id = "MacLauncher",
        Display = "MacLauncher",
        Nav = "Dock",
        ShowLabels = false,
        ShowIcons = true,
        Traffic = true,
        ToggleKind = "Switch",
        Terminal = false,
        Liquid = true,
        Border = false,
        Glow = false,
        Footer = false,
        Mono = false,
        Colors = {
            SurfaceHi = rgb(60, 60, 64), Dialog = rgb(62, 62, 68), DialogHi = rgb(80, 80, 88), LiquidA = rgb(26, 30, 56), LiquidB = rgb(10, 132, 255), LiquidC = rgb(94, 92, 230), LiquidSpec = rgb(190, 215, 255),
            Accent = rgb(10, 132, 255), AccentAlt = rgb(94, 92, 230), Background = rgb(30, 30, 32),
            Surface = rgb(46, 46, 49), SurfaceAlt = rgb(62, 62, 66), Outline = rgb(84, 84, 88),
            Text = rgb(245, 245, 247), Muted = rgb(152, 152, 158), Hover = rgb(72, 72, 76),
            ToggleOn = rgb(48, 209, 88), ToggleOff = rgb(92, 92, 98), Knob = rgb(255, 255, 255),
            Success = rgb(48, 209, 88), Warning = rgb(255, 159, 10), Danger = rgb(255, 69, 58),
        },
        Numbers = { TransWindow = 0.16, TransPanel = 0.3, TransCard = 1, TransField = 0.4, TransSheen = 0.92, TransStroke = 0.55, TransLine = 0.82, TransHeader = 0.55, TransRail = 1 },
        Radius = { RadWindow = 14, RadPanel = 11, RadCard = 8, RadControl = 7, RadIcon = 8, RadPill = 99, RadBlob = 9999 },
    },
    OperaGX = {
        Id = "OperaGX",
        Display = "OperaGX Browser",
        Nav = "Sidebar",
        RailWidth = 66,
        RailWidthMobile = 60,
        ShowLabels = false,
        ShowIcons = true,
        Traffic = false,
        ToggleKind = "Switch",
        Terminal = false,
        Liquid = true,
        Border = true,
        Glow = true,
        Footer = false,
        Mono = false,
        Gamer = true,
        Uppercase = true,
        Corner = true,
        BorderSpeed = 95,
        BorderThickness = 2,
        Colors = {
            SurfaceHi = rgb(30, 20, 36), Dialog = rgb(40, 24, 46), DialogHi = rgb(58, 30, 64),
            LiquidA = rgb(46, 4, 26), LiquidB = rgb(255, 26, 72), LiquidC = rgb(178, 0, 255), LiquidSpec = rgb(255, 150, 190),
            Accent = rgb(255, 26, 72), AccentAlt = rgb(178, 0, 255), Background = rgb(6, 6, 10),
            Surface = rgb(16, 14, 22), SurfaceAlt = rgb(30, 24, 40), Outline = rgb(96, 24, 56),
            Text = rgb(246, 240, 248), Muted = rgb(172, 148, 174), Hover = rgb(56, 26, 54),
            ToggleOn = rgb(255, 26, 72), ToggleOff = rgb(66, 56, 80), Knob = rgb(224, 208, 232),
            Success = rgb(60, 230, 140), Warning = rgb(255, 176, 50), Danger = rgb(255, 60, 84),
        },
        Numbers = { TransWindow = 0.04, TransPanel = 0.2, TransCard = 0.22, TransField = 0.2, TransSheen = 0.95, TransStroke = 0.15, TransLine = 1, TransHeader = 0.5, TransRail = 0.55 },
        Radius = { RadWindow = 0, RadPanel = 0, RadCard = 0, RadControl = 0, RadIcon = 0, RadPill = 0, RadBlob = 0 },
    },
    ClaudeCode = {
        Id = "ClaudeCode",
        Display = "Claude Code",
        Nav = "Sidebar",
        RailWidth = 132,
        RailWidthMobile = 96,
        ShowLabels = true,
        ShowIcons = false,
        Traffic = true,
        ToggleKind = "Text",
        Terminal = true,
        Liquid = false,
        Border = false,
        Glow = false,
        Footer = false,
        Mono = true,
        Colors = {
            SurfaceHi = rgb(42, 40, 37), Dialog = rgb(46, 44, 40), DialogHi = rgb(60, 57, 52), LiquidA = rgb(40, 26, 20), LiquidB = rgb(217, 119, 87), LiquidC = rgb(150, 90, 70), LiquidSpec = rgb(240, 200, 170),
            Accent = rgb(217, 119, 87), AccentAlt = rgb(236, 160, 120), Background = rgb(22, 21, 20),
            Surface = rgb(31, 30, 28), SurfaceAlt = rgb(42, 40, 37), Outline = rgb(78, 74, 68),
            Text = rgb(232, 228, 220), Muted = rgb(150, 144, 134), Hover = rgb(48, 46, 42),
            ToggleOn = rgb(217, 119, 87), ToggleOff = rgb(84, 80, 74), Knob = rgb(200, 194, 184),
            Success = rgb(126, 200, 120), Warning = rgb(230, 190, 90), Danger = rgb(232, 104, 92),
        },
        Numbers = { TransWindow = 0.02, TransPanel = 0.12, TransCard = 1, TransField = 0.2, TransSheen = 1, TransStroke = 0.45, TransLine = 0.8, TransHeader = 0.8, TransRail = 0.85 },
        Radius = { RadWindow = 9, RadPanel = 5, RadCard = 4, RadControl = 4, RadIcon = 4, RadPill = 99, RadBlob = 9999 },
    },
}

local StyleOrder = { "Perplexity", "MacLauncher", "OperaGX", "ClaudeCode" }

local StyleKeys = {
    perplexity = "Perplexity", perplexityoriginal = "Perplexity", original = "Perplexity",
    maclauncher = "MacLauncher", mac = "MacLauncher", macos = "MacLauncher", launcher = "MacLauncher",
    operagx = "OperaGX", operagxbrowser = "OperaGX", gx = "OperaGX", opera = "OperaGX",
    claudecode = "ClaudeCode", claude = "ClaudeCode", terminal = "ClaudeCode",
}

local function resolveStyle(name)
    if type(name) ~= "string" then
        return nil
    end
    local key = string.lower(name):gsub("[^%w]", "")
    return StyleKeys[key]
end

local COLOR_TOKENS = {
    "Accent", "AccentAlt", "Background", "Surface", "SurfaceHi", "SurfaceAlt", "Dialog", "DialogHi", "Outline", "Text", "Muted",
    "Hover", "ToggleOn", "ToggleOff", "Knob", "Success", "Warning", "Danger",
    "LiquidA", "LiquidB", "LiquidC", "LiquidSpec",
}

local MOTION = {
    Hover = { 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out },
    Press = { 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out },
    Toggle = { 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
    Tab = { 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
    Dialog = { 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
    DialogOut = { 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In },
    WindowIn = { 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
    WindowOut = { 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In },
    Toast = { 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
    ToastOut = { 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In },
}

local COLOR_TOKEN_SET = {}
for _, token in ipairs(COLOR_TOKENS) do
    COLOR_TOKEN_SET[token] = true
end

local function liquidBlob(x, y, w, h, alpha, rim, seed)
    return {
        X = x, Y = y, W = w, H = h,
        AX = 0.09 + 0.02 * (seed % 3), AY = 0.07 + 0.015 * (seed % 4), AX2 = 0.04, AY2 = 0.05,
        FX = 0.071 + 0.013 * seed, FY = 0.059 + 0.011 * seed, FX2 = 0.137 + 0.007 * seed, FY2 = 0.113 + 0.009 * seed,
        FW = 0.083 + 0.01 * seed, FH = 0.067 + 0.012 * seed, FW2 = 0.151 + 0.006 * seed, FH2 = 0.129 + 0.008 * seed,
        R = 20 * seed, FR = 0.05 + 0.007 * seed, Drift = 1.2 + 0.35 * seed, Flow = 6 + 2 * seed, Spin = 10 + 3 * seed,
        Alpha = alpha, Rim = rim, Phase = seed * 2.399,
    }
end

local LIQUID_WINDOW = {
    liquidBlob(0.22, 0.34, 1.15, 0.95, { 0.9, 0.8, 0.96 }, 1.5, 1),
    liquidBlob(0.8, 0.72, 1.05, 0.98, { 0.9, 0.78, 0.96 }, 1.5, 2),
    liquidBlob(0.52, 0.06, 0.85, 0.62, { 0.93, 0.84, 0.97 }, 1.2, 3),
    liquidBlob(0.12, 0.84, 0.58, 0.5, { 0.86, 0.72, 0.95 }, 1.5, 4),
    liquidBlob(0.88, 0.18, 0.52, 0.56, { 0.86, 0.72, 0.95 }, 1.5, 5),
    liquidBlob(0.62, 0.56, 0.34, 0.3, { 0.82, 0.62, 0.93 }, 2, 6),
    liquidBlob(0.3, 0.52, 0.28, 0.32, { 0.82, 0.62, 0.93 }, 2, 7),
}

local LIQUID_PROMO = {
    liquidBlob(0.0, 0.05, 0.75, 0.7, { 0.72, 0.55, 0.9 }, 1.5, 11),
    liquidBlob(1.0, 0.95, 0.75, 0.75, { 0.72, 0.55, 0.9 }, 1.5, 12),
    liquidBlob(0.96, 0.05, 0.42, 0.5, { 0.7, 0.5, 0.9 }, 2, 13),
    liquidBlob(0.04, 0.95, 0.4, 0.42, { 0.7, 0.5, 0.9 }, 2, 14),
}

local DesktopMetrics = {
    Touch = false, Size = Vector2.new(680, 410), Top = 36, Pad = 6, PanelPad = 10, Gap = 6, Row = 30, RowTall = 38,
    Text = 13, Small = 11, TabHeight = 30, IconSize = 15, Bubble = 26, ControlHeight = 22,
    CategoryHeight = 26, CardHeight = 96,
    ToggleWidth = 32, ToggleHeight = 18, DropdownWidth = 112, InputWidth = 120, SliderHeight = 40,
    SliderLabel = 18, TrackHeight = 5, KnobSize = 12, ItemHeight = 24, MaxDropdownItems = 6, ScrollBar = 3,
    BarHeight = 12, SwatchWidth = 26, SwatchHeight = 15, ButtonHeight = 26, MinColumn = 200, PopupWidth = 184,
    DockIcon = 38, DockHeight = 54, Traffic = 10,
}

local MobileMetrics = {
    Touch = true, Size = Vector2.new(540, 300), Top = 36, Pad = 8, PanelPad = 9, Gap = 6, Row = 38, RowTall = 50,
    Text = 13, Small = 11, TabHeight = 40, IconSize = 18, Bubble = 32, ControlHeight = 28,
    CategoryHeight = 32, CardHeight = 104,
    ToggleWidth = 40, ToggleHeight = 22, DropdownWidth = 128, InputWidth = 144, SliderHeight = 50,
    SliderLabel = 22, TrackHeight = 7, KnobSize = 17, ItemHeight = 32, MaxDropdownItems = 5, ScrollBar = 3,
    BarHeight = 18, SwatchWidth = 32, SwatchHeight = 20, ButtonHeight = 32, MinColumn = 240, PopupWidth = 200,
    DockIcon = 42, DockHeight = 58, Traffic = 12,
}

local filesSupported = writefile ~= nil and readfile ~= nil and isfile ~= nil and listfiles ~= nil and makefolder ~= nil and isfolder ~= nil
local clipboardWriter = setclipboard or toclipboard
local customAsset = getcustomasset or getsynasset

local TEXT_CLASSES = { TextLabel = true, TextButton = true, TextBox = true }

local function new(className, properties, parent)
    local instance = Instance.new(className)
    if instance:IsA("GuiObject") then
        instance.BorderSizePixel = 0
        instance.BackgroundTransparency = 1
    end
    if className == "TextButton" or className == "ImageButton" then
        instance.AutoButtonColor = false
    end
    if TEXT_CLASSES[className] then
        instance.Text = ""
    end
    if className == "TextBox" then
        instance.ClearTextOnFocus = false
    end
    if properties then
        for key, value in pairs(properties) do
            instance[key] = value
        end
        if properties.BackgroundColor3 ~= nil and properties.BackgroundTransparency == nil then
            instance.BackgroundTransparency = 0
        end
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function addList(parent, padding, direction)
    return new("UIListLayout", {
        Padding = UDim.new(0, padding or 0),
        FillDirection = direction or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, parent)
end

local function addPadding(parent, top, right, bottom, left)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, top),
        PaddingRight = UDim.new(0, right or top),
        PaddingBottom = UDim.new(0, bottom or top),
        PaddingLeft = UDim.new(0, left or right or top),
    }, parent)
end

local function slug(text)
    local value = string.lower(tostring(text or ""))
    value = value:gsub("[^%w]+", "_")
    value = value:gsub("^_+", ""):gsub("_+$", "")
    if value == "" then
        value = "feature"
    end
    return value
end

local function hashText(text)
    local value = 5381
    for index = 1, #text do
        value = (value * 33 + string.byte(text, index)) % 4294967296
    end
    return string.format("%08x", value)
end

local function escapeRich(text)
    local value = tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    return value
end

local function hexOf(color)
    return "#" .. color:ToHex()
end

local function decodeJson(text)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

local function sanitizeName(name)
    name = tostring(name or "")
    name = name:gsub("[^%w_%- ]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name
end

local function decimalsOf(step)
    local text = string.format("%.6f", step)
    text = text:gsub("0+$", "")
    local fraction = text:match("%.(%d*)$")
    return fraction and #fraction or 0
end

local MOUSE_NAMES = { MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3" }

local function keyToText(key)
    if key == nil then
        return "None"
    end
    if key.EnumType == Enum.UserInputType then
        return MOUSE_NAMES[key.Name] or key.Name
    end
    return key.Name
end

local function serializeKey(key)
    if key == nil then
        return "None"
    end
    return tostring(key.EnumType) .. "." .. key.Name
end

local function deserializeKey(text)
    if type(text) ~= "string" or text == "None" then
        return nil
    end
    local kind, name = text:match("^(%w+)%.(%w+)$")
    if not kind then
        return nil
    end
    local ok, value = pcall(function()
        return Enum[kind][name]
    end)
    if ok then
        return value
    end
    return nil
end

local function keyFromName(text)
    text = tostring(text or "")
    if text == "" or string.lower(text) == "none" then
        return nil
    end
    local candidates = { text, string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2), string.upper(text) }
    for _, candidate in ipairs(candidates) do
        local ok, value = pcall(function()
            return Enum.KeyCode[candidate]
        end)
        if ok and value then
            return value
        end
    end
    return nil
end

local function inputMatchesKey(input, key)
    if key == nil then
        return false
    end
    if key.EnumType == Enum.KeyCode then
        return input.KeyCode == key
    end
    return input.UserInputType == key
end

local function sameList(first, second)
    if #first ~= #second then
        return false
    end
    for index = 1, #first do
        if first[index] ~= second[index] then
            return false
        end
    end
    return true
end

local function fire(element, ...)
    if element.Callback then
        task.spawn(element.Callback, ...)
    end
    for _, listener in ipairs(element._listeners) do
        task.spawn(listener, ...)
    end
    local window = element.Window
    if window then
        window:_elementChanged(element, ...)
    end
end

local function httpGet(url)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" and #body > 0 then
        return body
    end
    local requester = (syn and syn.request) or request or http_request or (http and http.request)
    if requester then
        local okRequest, response = pcall(requester, { Url = url, Method = "GET" })
        if okRequest and type(response) == "table" and type(response.Body) == "string" then
            return response.Body
        end
    end
    return nil
end

local function mountGui(gui)
    local protect = (syn and syn.protect_gui) or protect_gui
    if protect then
        pcall(protect, gui)
    end
    if gethui then
        local ok = pcall(function()
            gui.Parent = gethui()
        end)
        if ok and gui.Parent then
            return
        end
    end
    local ok = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if ok and gui.Parent then
        return
    end
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local IconPacks = {}
local IconLoading = {}
local IconWaiters = {}
local ImageCache = {}

local function packKey(name)
    if type(name) ~= "string" then
        return nil
    end
    local wanted = string.lower(name):gsub("[^%w]", "")
    for key in pairs(Library.IconSources) do
        local normalized = string.lower(key):gsub("[^%w]", "")
        if normalized == wanted then
            return key
        end
    end
    return nil
end

local function githubRaw(url)
    local user, repo, rest = url:match("^https?://github%.com/([^/]+)/([^/]+)/blob/(.+)$")
    if user then
        return "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. rest
    end
    return url
end

local function imageExtension(url)
    local ext = url:match("%.(%a%a%a%a?)[%?#]") or url:match("%.(%a%a%a%a?)$")
    ext = ext and string.lower(ext)
    if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "webp" then
        return ext
    end
    return "png"
end

local function ensureFolders(path)
    if not filesSupported then
        return
    end
    local built = ""
    for part in string.gmatch(path, "[^/]+") do
        built = built == "" and part or (built .. "/" .. part)
        pcall(function()
            if not isfolder(built) then
                makefolder(built)
            end
        end)
    end
end

local function resolveImageProps(source, folder, callback)
    if type(source) == "number" then
        return { Image = "rbxassetid://" .. source }
    end
    if type(source) ~= "string" or source == "" then
        return false
    end
    if source:match("^rbxassetid://") or source:match("^rbxasset://") or source:match("^rbxthumb://") or source:match("^rbxgameasset://") then
        return { Image = source }
    end
    if source:match("^%d+$") then
        return { Image = "rbxassetid://" .. source }
    end
    if source:match("^https?://") then
        local url = githubRaw(source)
        if ImageCache[url] then
            return { Image = ImageCache[url] }
        end
        if not (customAsset and filesSupported) then
            return nil
        end
        task.spawn(function()
            local directory = folder .. "/images"
            ensureFolders(directory)
            local path = directory .. "/" .. hashText(url) .. "." .. imageExtension(url)
            local exists = false
            pcall(function()
                exists = isfile(path)
            end)
            if not exists then
                local body = httpGet(url)
                if body then
                    pcall(writefile, path, body)
                    pcall(function()
                        exists = isfile(path)
                    end)
                end
            end
            if exists then
                local ok, asset = pcall(customAsset, path)
                if ok and asset then
                    ImageCache[url] = asset
                    if callback then
                        callback({ Image = asset })
                    end
                end
            end
        end)
        return nil
    end
    return false
end

local function loadIconPack(pack, callback)
    if IconPacks[pack] then
        callback(IconPacks[pack])
        return
    end
    IconWaiters[pack] = IconWaiters[pack] or {}
    table.insert(IconWaiters[pack], callback)
    if IconLoading[pack] then
        return
    end
    IconLoading[pack] = true
    task.spawn(function()
        local data
        local url = Library.IconSources[pack]
        local body = url and httpGet(url)
        if body and loadstring then
            local ok, result = pcall(function()
                return loadstring(body)()
            end)
            if ok and type(result) == "table" then
                data = result
            end
        end
        IconPacks[pack] = data or {}
        local waiters = IconWaiters[pack] or {}
        IconWaiters[pack] = nil
        for _, waiter in ipairs(waiters) do
            pcall(waiter, IconPacks[pack])
        end
    end)
end

local function iconProperties(value)
    if type(value) == "number" then
        return { Image = "rbxassetid://" .. value }
    end
    if type(value) == "string" then
        if value:match("^%d+$") then
            return { Image = "rbxassetid://" .. value }
        end
        return { Image = value }
    end
    if type(value) == "table" then
        local image = value.Image or value.Id or value.Asset
        if type(image) == "number" then
            image = "rbxassetid://" .. image
        end
        if image then
            return {
                Image = image,
                ImageRectOffset = value.ImageRectOffset or value.RectOffset,
                ImageRectSize = value.ImageRectSize or value.RectSize,
            }
        end
    end
    return nil
end

local function iconEntry(data, name)
    local lowered = string.lower(name)
    local value = data[name] or data[lowered]
    if value == nil then
        local dashed = lowered:gsub("[%s_]+", "-")
        value = data[dashed]
    end
    return value
end

function Library.ResolveIcon(spec, folder, callback)
    if spec == nil or spec == "" then
        return nil
    end
    local direct = resolveImageProps(spec, folder, callback)
    if direct ~= false then
        return direct
    end
    if type(spec) ~= "string" then
        return nil
    end
    local packName, iconName = spec:match("^([%w%-]+)[:/](.+)$")
    local pack = packName and packKey(packName)
    if not pack then
        pack = packKey(Library.DefaultIconPack)
        iconName = spec
    end
    if not pack then
        return nil
    end
    local data = IconPacks[pack]
    if data then
        local value = iconEntry(data, iconName)
        if value ~= nil then
            return iconProperties(value)
        end
        for otherPack, otherData in pairs(IconPacks) do
            if otherPack ~= pack then
                local otherValue = iconEntry(otherData, iconName)
                if otherValue ~= nil then
                    return iconProperties(otherValue)
                end
            end
        end
        return nil
    end
    loadIconPack(pack, function(loaded)
        local value = iconEntry(loaded, iconName)
        local properties = value ~= nil and iconProperties(value)
        if properties and callback then
            callback(properties)
        end
    end)
    return nil
end

function Library:SetIconPack(name)
    local key = packKey(name)
    if key then
        self.DefaultIconPack = key
    end
    return key ~= nil
end

function Library:AddIconPack(name, url)
    self.IconSources[name] = url
end

function Library:PreloadIcons(...)
    for _, name in ipairs({ ... }) do
        local key = packKey(name)
        if key then
            loadIconPack(key, function() end)
        end
    end
end

function Library:GetStyles()
    local list = {}
    for _, id in ipairs(StyleOrder) do
        table.insert(list, { Id = id, Display = Styles[id].Display })
    end
    return list
end
function Window:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self._connections, connection)
    return connection
end

function Window:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.16, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local store = self._tweens[instance]
    if not store then
        store = {}
        self._tweens[instance] = store
    end
    local last
    for property, value in pairs(properties) do
        local previous = store[property]
        if previous then
            previous:Cancel()
        end
        local tween = TweenService:Create(instance, info, { [property] = value })
        store[property] = tween
        local connection
        connection = tween.Completed:Connect(function()
            if store[property] == tween then
                store[property] = nil
            end
            if connection then
                connection:Disconnect()
            end
        end)
        tween:Play()
        last = tween
    end
    return last
end

function Window:Motion(name, instance, properties)
    local motion = MOTION[name] or MOTION.Hover
    return self:Tween(instance, properties, motion[1], motion[2], motion[3])
end

function Window:_cancelTweens()
    for _, store in pairs(self._tweens) do
        for _, tween in pairs(store) do
            pcall(function()
                tween:Cancel()
            end)
        end
    end
    self._tweens = setmetatable({}, { __mode = "k" })
end

function Window:Bind(instance, property, token)
    local value = self.Tokens[token]
    if value == nil then
        return
    end
    instance[property] = value
    local list = self._bindings[token]
    if not list then
        list = {}
        self._bindings[token] = list
    end
    table.insert(list, { instance, property })
end

function Window:_applyGradientEntry(entry)
    local list = entry.List
    if list then
        local points = {}
        for index, token in ipairs(list) do
            points[index] = ColorSequenceKeypoint.new((index - 1) / (#list - 1), self.Tokens[token])
        end
        entry[1].Color = ColorSequence.new(points)
    else
        entry[1].Color = ColorSequence.new(self.Tokens[entry[2]], self.Tokens[entry[3]])
    end
end

function Window:_refreshGradients()
    local alive = {}
    for _, entry in ipairs(self._gradients) do
        if entry[1]:IsDescendantOf(self.Gui) then
            self:_applyGradientEntry(entry)
            table.insert(alive, entry)
        end
    end
    self._gradients = alive
end

function Window:SetToken(token, value)
    self.Tokens[token] = value
    local list = self._bindings[token]
    if list then
        local alive = {}
        for _, binding in ipairs(list) do
            local instance = binding[1]
            if instance:IsDescendantOf(self.Gui) then
                instance[binding[2]] = value
                table.insert(alive, binding)
            end
        end
        self._bindings[token] = alive
    end
    if COLOR_TOKEN_SET[token] then
        self:_refreshGradients()
    end
end

function Window:SetThemeColor(token, color)
    if COLOR_TOKEN_SET[token] and typeof(color) == "Color3" then
        self:SetToken(token, color)
        local picker = self._colorPickers and self._colorPickers[token]
        if picker then
            picker:Set(color, true)
        end
    end
end

function Window:Make(className, properties, parent, binds)
    properties = properties or {}
    local instance = Instance.new(className)
    if className == "UIStroke" then
        pcall(function()
            instance.LineJoinMode = Enum.LineJoinMode.Miter
        end)
    end
    local isText = TEXT_CLASSES[className] == true
    if instance:IsA("GuiObject") then
        instance.BorderSizePixel = 0
        instance.BackgroundTransparency = 1
    end
    if className == "TextButton" or className == "ImageButton" then
        instance.AutoButtonColor = false
    end
    local bindings = {}
    if isText then
        instance.Text = ""
        instance.TextSize = self.Metrics.Text
        bindings.FontFace = FONT_TOKENS[properties.Font or "Medium"]
        bindings.TextColor3 = properties.Color or (properties.Muted and "Muted") or "Text"
        if className == "TextBox" then
            instance.ClearTextOnFocus = false
        end
    end
    if binds then
        for property, token in pairs(binds) do
            bindings[property] = token
        end
    end
    for key, value in pairs(properties) do
        if not (isText and (key == "Font" or key == "Color" or key == "Muted")) then
            instance[key] = value
            bindings[key] = nil
        end
    end
    if properties.BackgroundTransparency == nil and bindings.BackgroundTransparency == nil then
        if bindings.BackgroundColor3 ~= nil or properties.BackgroundColor3 ~= nil then
            instance.BackgroundTransparency = 0
        end
    end
    for property, token in pairs(bindings) do
        self:Bind(instance, property, token)
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

function Window:Corner(parent, token)
    return self:Make("UICorner", {}, parent, { CornerRadius = token or "RadControl" })
end

function Window:Stroke(parent, colorToken, transparencyToken, thickness)
    return self:Make("UIStroke", {
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent, { Color = colorToken or "Outline", Transparency = transparencyToken or "TransStroke" })
end

function Window:_createLiquid(container, specs, options)
    options = options or {}
    local liquid = { Container = container, Page = options.Page, Blobs = {} }
    local limit = self.Metrics.Touch and math.min(#specs, 5) or #specs
    for index = 1, limit do
        local spec = specs[index]
        local frame = new("Frame", {
            Name = "Blob",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(spec.X, spec.Y),
            Size = UDim2.fromScale(spec.W, spec.H),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Active = false,
            ZIndex = 1,
        }, container)
        self:Corner(frame, "RadBlob")
        local fill = self:GradientList(frame, { "LiquidA", "LiquidB", "LiquidC", "LiquidA" }, 35)
        fill.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, spec.Alpha[1]),
            NumberSequenceKeypoint.new(0.35, spec.Alpha[2]),
            NumberSequenceKeypoint.new(0.7, spec.Alpha[3]),
            NumberSequenceKeypoint.new(1, 1),
        })
        local rim = self:Make("UIStroke", {
            Thickness = spec.Rim,
            Transparency = 0.45,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, frame, { Color = "LiquidSpec" })
        local rimGradient = new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.22, 0.2),
                NumberSequenceKeypoint.new(0.42, 0.85),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, rim)
        table.insert(liquid.Blobs, { Frame = frame, Fill = fill, Rim = rimGradient, Spec = spec })
    end
    function liquid:Update(t)
        for _, blob in ipairs(self.Blobs) do
            local s = blob.Spec
            local p = s.Phase
            local x = s.X + s.AX * math.sin(t * s.FX + p) + s.AX2 * math.sin(t * s.FX2 + p * 1.7)
            local y = s.Y + s.AY * math.cos(t * s.FY + p * 0.8) + s.AY2 * math.sin(t * s.FY2 + p * 2.3)
            local w = s.W * (1 + 0.16 * math.sin(t * s.FW + p) + 0.06 * math.sin(t * s.FW2 + p * 2.1))
            local h = s.H * (1 + 0.16 * math.cos(t * s.FH + p * 1.3) + 0.06 * math.sin(t * s.FH2 + p * 0.7))
            local frame = blob.Frame
            frame.Position = UDim2.fromScale(x, y)
            frame.Size = UDim2.fromScale(w, h)
            frame.Rotation = (s.R + 28 * math.sin(t * s.FR + p) + t * s.Drift) % 360
            blob.Fill.Rotation = (t * s.Flow + p * 40) % 360
            blob.Rim.Rotation = (t * s.Spin + p * 60) % 360
        end
    end
    liquid:Update(self._time)
    table.insert(self._liquids, liquid)
    return liquid
end

function Window:Display(text)
    if self.Style and self.Style.Uppercase then
        return string.upper(text)
    end
    return text
end

function Window:_line(parent, properties, rotation)
    properties.BackgroundColor3 = Color3.new(1, 1, 1)
    local frame = self:Make("Frame", properties, parent, { BackgroundTransparency = "TransStroke" })
    local _, entry = self:Gradient(frame, "Outline", "Outline", rotation or 0)
    local gamer = self.Style.Gamer == true
    entry[2] = gamer and "Accent" or "Outline"
    entry[3] = gamer and "AccentAlt" or "Outline"
    self:_applyGradientEntry(entry)
    table.insert(self._lines, entry)
    return frame, entry
end

function Window:_applyLines()
    local gamer = self.Style.Gamer == true
    local alive = {}
    for _, entry in ipairs(self._lines) do
        if entry[1]:IsDescendantOf(self.Gui) then
            entry[2] = gamer and "Accent" or "Outline"
            entry[3] = gamer and "AccentAlt" or "Outline"
            self:_applyGradientEntry(entry)
            table.insert(alive, entry)
        end
    end
    self._lines = alive
end

function Window:GradientList(parent, tokenList, rotation)
    local gradient = new("UIGradient", { Rotation = rotation or 0 }, parent)
    local entry = { gradient, List = tokenList }
    table.insert(self._gradients, entry)
    self:_applyGradientEntry(entry)
    return gradient, entry
end

function Window:Gradient(parent, tokenA, tokenB, rotation)
    local gradient = new("UIGradient", { Rotation = rotation or 0 }, parent)
    gradient.Color = ColorSequence.new(self.Tokens[tokenA], self.Tokens[tokenB])
    local entry = { gradient, tokenA, tokenB }
    table.insert(self._gradients, entry)
    return gradient, entry
end

local GLASS = {
    Window = { "Background", "TransWindow", "RadWindow" },
    Panel = { "Surface", "TransPanel", "RadPanel" },
    Card = { "Surface", "TransCard", "RadCard" },
    Field = { "SurfaceAlt", "TransField", "RadControl" },
}

local BRACKET_MASK = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.07, 0),
    NumberSequenceKeypoint.new(0.073, 1),
    NumberSequenceKeypoint.new(0.927, 1),
    NumberSequenceKeypoint.new(0.93, 0),
    NumberSequenceKeypoint.new(1, 0),
})

function Window:_syncGamerParts()
    local gamer = self.Style.Gamer == true
    local alive = {}
    for _, part in ipairs(self._gamerParts) do
        if part:IsDescendantOf(self.Gui) then
            part.Enabled = gamer
            table.insert(alive, part)
        end
    end
    self._gamerParts = alive
end

function Window:_bracket(frame)
    if #self._gamerParts >= 128 then
        self:_syncGamerParts()
    end
    local stroke = self:Make("UIStroke", {
        Name = "Bracket",
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Enabled = self.Style.Gamer == true,
    }, frame, { Color = "Accent" })
    new("UIGradient", { Rotation = 45, Transparency = BRACKET_MASK }, stroke)
    table.insert(self._gamerParts, stroke)
    return stroke
end

function Window:GlassEdge(stroke)
    return new("UIGradient", {
        Rotation = 45,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.35),
            NumberSequenceKeypoint.new(1, 0.7),
        }),
    }, stroke)
end

function Window:Glass(parent, kind, properties, className)
    local spec = GLASS[kind]
    properties = properties or {}
    local layered = kind == "Panel" or kind == "Card"
    local binds = { BackgroundTransparency = spec[2] }
    if layered then
        properties.BackgroundColor3 = Color3.new(1, 1, 1)
    else
        binds.BackgroundColor3 = spec[1]
    end
    local frame = self:Make(className or "Frame", properties, parent, binds)
    self:Corner(frame, spec[3])
    local fillEntry
    if layered then
        local _, entry = self:Gradient(frame, "SurfaceHi", "Surface", 90)
        fillEntry = entry
    end
    self:GlassEdge(self:Stroke(frame))
    if kind == "Panel" then
        self:_bracket(frame)
    end
    return frame, fillEntry
end

function Window:ApplyIcon(label, spec, colorToken, onApplied)
    label.Image = ""
    if colorToken then
        self:Bind(label, "ImageColor3", colorToken)
    end
    local function apply(properties)
        pcall(function()
            for key, value in pairs(properties) do
                if value ~= nil then
                    label[key] = value
                end
            end
        end)
        if onApplied then
            onApplied()
        end
    end
    local properties = Library.ResolveIcon(spec, self.Folder, apply)
    if properties then
        apply(properties)
        return true
    end
    return false
end

function Window:ApplyImage(label, source)
    label.ImageTransparency = 1
    local function apply(properties)
        pcall(function()
            label.Image = properties.Image
            self:Tween(label, { ImageTransparency = 0 }, 0.4)
        end)
    end
    local properties = resolveImageProps(source, self.Folder, apply)
    if properties then
        apply(properties)
    end
end

function Window:_styleTokens(style)
    local tokens = {}
    for key, value in pairs(style.Colors) do
        tokens[key] = value
    end
    for key, value in pairs(style.Numbers) do
        tokens[key] = value
    end
    for key, value in pairs(style.Radius) do
        tokens[key] = UDim.new(0, value)
    end
    local fonts = style.Mono and FontSets.Mono or FontSets.Sans
    tokens.FontRegular = fonts.Regular
    tokens.FontMedium = fonts.Medium
    tokens.FontSemi = fonts.Semi
    tokens.FontBold = fonts.Bold
    tokens.FontMono = FontSets.Mono.Regular
    tokens.FontMonoSemi = FontSets.Mono.Semi
    return tokens
end

function Window:_onStyle(owner, callback)
    self._styleHooks[owner] = callback
end

function Window:_offStyle(owner)
    self._styleHooks[owner] = nil
end

function Window:SetStyle(name, silent)
    local id = resolveStyle(name) or name
    local style = Styles[id]
    if not style then
        return false
    end
    self.StyleId = id
    self.Style = style
    for token, value in pairs(self:_styleTokens(style)) do
        self:SetToken(token, value)
    end
    if self.Effects.Rainbow then
        self.Effects.Rainbow = false
    end
    self.TerminalVisible = style.Terminal and not self.Metrics.Touch
    self:_applyStyleLayout()
    for token, picker in pairs(self._colorPickers) do
        picker:Set(self.Tokens[token], true)
    end
    if self._terminalToggle then
        self._terminalToggle:Set(self.TerminalVisible, true)
    end
    if self._styleDropdown then
        self._styleDropdown:Set(style.Display, true)
    end
    self:_saveSettings()
    if not silent then
        self:Notify({ Title = "Style", Content = style.Display .. " applied", Type = "Success" })
    end
    return true
end

function Window:GetStyle()
    return self.StyleId
end

function Window:SetRainbow(enabled)
    self.Effects.Rainbow = enabled == true
    if not self.Effects.Rainbow then
        local colors = self.Style.Colors
        self:SetToken("Accent", colors.Accent)
        self:SetToken("AccentAlt", colors.AccentAlt)
        self:SetToken("ToggleOn", colors.ToggleOn)
        for token, picker in pairs(self._colorPickers) do
            picker:Set(self.Tokens[token], true)
        end
    end
end

function Window:_screenSize()
    local size = self.Gui.AbsoluteSize
    if size.X < 50 or size.Y < 50 then
        local camera = workspace.CurrentCamera
        size = camera and camera.ViewportSize or Vector2.new(1280, 720)
    end
    return size
end

function Window:_windowHeight()
    return self.Minimized and self.Metrics.Top or self.BaseSize.Y
end

function Window:_clampCenter(position)
    local screen = self:_screenSize()
    local scale = self._targetScale or self.Scale.Scale
    local half = Vector2.new(self.BaseSize.X * scale / 2, self:_windowHeight() * scale / 2)
    local x = math.clamp(position.X, math.min(half.X, screen.X / 2), math.max(screen.X - half.X, screen.X / 2))
    local y = math.clamp(position.Y, math.min(half.Y, screen.Y / 2), math.max(screen.Y - half.Y, screen.Y / 2))
    return Vector2.new(x, y)
end

function Window:_applyPosition()
    local screen = self:_screenSize()
    local clamped = self:_clampCenter(Vector2.new(self._center.X * screen.X, self._center.Y * screen.Y))
    self._center = Vector2.new(clamped.X / screen.X, clamped.Y / screen.Y)
    self.Root.Position = UDim2.fromScale(self._center.X, self._center.Y)
end

function Window:_clampMenuButton()
    local button = self.MenuButton
    if not button or self._movers.Menu or not self._menuPos then
        return
    end
    local screen = self:_screenSize()
    local half = self._menuHalf or 22
    local size = half * 2
    local x = math.clamp(self._menuPos.X, 0, math.max(0, screen.X - size))
    local y = math.clamp(self._menuPos.Y, 0, math.max(0, screen.Y - size))
    self._menuPos = Vector2.new(x, y)
    button.Position = UDim2.fromOffset(x + half, y + half)
end

function Window:_applySize()
    self.Root.Size = UDim2.fromOffset(self.BaseSize.X, self:_windowHeight())
    self.Body.Visible = not self.Minimized
    if self.Grip then
        self.Grip.Visible = not self.Minimized
    end
end

function Window:_updateScale()
    local screen = self:_screenSize()
    local base = self.DesignSize
    local scale = 1
    if self.AutoScale then
        local fit = math.min(screen.X * 0.95 / base.X, screen.Y * 0.9 / base.Y)
        if self.Metrics.Touch then
            scale = fit * 0.88
        else
            local reference = math.min(screen.X / self.ReferenceSize.X, screen.Y / self.ReferenceSize.Y)
            scale = math.min(reference, fit)
        end
    end
    scale = math.clamp(scale * self.UserScale, 0.4, 3)
    self._targetScale = scale
    if self.Visible then
        self.Scale.Scale = scale
    end
    self.ToastScale.Scale = scale
    local limit = screen * 0.98 / scale
    self.BaseSize = Vector2.new(math.min(self.PreferredSize.X, limit.X), math.min(self.PreferredSize.Y, limit.Y))
    self:_applySize()
    self:_layout()
    self:_applyPosition()
    self:_clampMenuButton()
end

function Window:_layout()
    local metrics = self.Metrics
    local style = self.Style
    local pad = metrics.Pad
    local sidebar = style.Nav == "Sidebar"
    local dock = style.Nav == "Dock"
    local railWidth = 0
    if sidebar then
        if style.RailFraction and not metrics.Touch then
            railWidth = math.clamp(math.floor(self.BaseSize.X * style.RailFraction), 120, 170)
        else
            railWidth = (metrics.Touch and style.RailWidthMobile) or style.RailWidth
        end
    end
    local dockSpace = dock and (metrics.DockHeight + pad) or 0
    self.Rail.Visible = sidebar
    self.Rail.Position = UDim2.fromOffset(pad, pad)
    self.Rail.Size = UDim2.new(0, railWidth, 1, -pad * 2)
    self.RailDivider.Visible = sidebar
    self.RailDivider.Position = UDim2.fromOffset(pad + railWidth + math.floor(pad / 2), 0)
    self.Dock.Visible = dock
    self.Dock.Position = UDim2.new(0.5, 0, 1, -pad)
    local terminalWidth = 0
    local overlay = false
    if self.TerminalVisible then
        terminalWidth = math.clamp(self.BaseSize.X * 0.36, 170, 260)
        local remaining = self.BaseSize.X - railWidth - terminalWidth - pad * (sidebar and 4 or 3)
        if remaining < metrics.MinColumn then
            overlay = true
            terminalWidth = math.clamp(self.BaseSize.X * 0.62, 180, 300)
        end
    end
    local left = pad + (sidebar and (railWidth + pad) or 0)
    local right = pad + ((terminalWidth > 0 and not overlay) and (terminalWidth + pad) or 0)
    self.PageHolder.Position = UDim2.fromOffset(left, pad)
    self.PageHolder.Size = UDim2.new(1, -(left + right), 1, -(pad * 2 + dockSpace))
    self.Terminal.Visible = terminalWidth > 0
    self.Terminal.Size = UDim2.new(0, terminalWidth, 1, -(pad * 2 + dockSpace))
    self.Terminal.Position = UDim2.new(1, -pad, 0, pad)
    self.Terminal.ZIndex = overlay and 6 or 1
    self.Footer.Visible = sidebar and style.Footer == true and self.BaseSize.Y > 380
end

function Window:_trackDrag(target, onUpdate, onBegin, onFinish, options)
    options = options or {}
    local handle = { Target = target, Threshold = options.Threshold or 8 }
    handle.Connection = self:Connect(target.InputBegan, function(input)
        if self.Destroyed then
            return
        end
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then
            return
        end
        if handle.Record or self._claimed[input] then
            return
        end
        local record = {
            Handle = handle,
            Input = input,
            Update = onUpdate,
            Finish = onFinish,
            Start = Vector2.new(input.Position.X, input.Position.Y),
            Moved = false,
            Threshold = handle.Threshold,
        }
        handle.Record = record
        self._claimed[input] = record
        table.insert(self._drags, record)
        if onBegin then
            onBegin(input, record)
        end
        if handle.Record == record then
            onUpdate(input, record)
        end
    end)
    return handle
end

function Window:_finishDrag(record, cancelled)
    if not record or record.Done then
        return
    end
    record.Done = true
    local index = table.find(self._drags, record)
    if index then
        table.remove(self._drags, index)
    end
    self._claimed[record.Input] = nil
    if record.Handle.Record == record then
        record.Handle.Record = nil
    end
    if record.Finish then
        local ok, reason = pcall(record.Finish, cancelled == true, record)
        if not ok then
            warn("[Perplexity] drag finish error: " .. tostring(reason))
        end
    end
end

function Window:_cancelDrags(keep)
    for _, record in ipairs(table.clone(self._drags)) do
        if not (keep and keep(record)) then
            self:_finishDrag(record, true)
        end
    end
end

function Window:_dragInput(input)
    for _, record in ipairs(table.clone(self._drags)) do
        local original = record.Input
        local matches = input == original
            or (original.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
        if matches and not record.Done then
            if not record.Moved then
                local current = Vector2.new(input.Position.X, input.Position.Y)
                if (current - record.Start).Magnitude > record.Threshold then
                    record.Moved = true
                end
            end
            record.Update(input, record)
        end
    end
end

function Window:_dragEnded(input)
    for _, record in ipairs(table.clone(self._drags)) do
        local original = record.Input
        local matches = input == original
            or (original.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)
        if matches then
            self:_finishDrag(record, false)
        end
    end
end

function Window:_watchDrags()
    for _, record in ipairs(table.clone(self._drags)) do
        local state = record.Input.UserInputState
        if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
            self:_finishDrag(record, state == Enum.UserInputState.Cancel)
        end
    end
end

function Window:_stepMovers(dt)
    local finished = {}
    for name, mover in pairs(self._movers) do
        local delta = mover.Target - mover.Current
        local distance = delta.Magnitude
        if distance > 0.2 then
            local alpha = 1 - math.exp(-dt * (mover.Rate or 30))
            local step = delta * alpha
            local limit = (mover.MaxSpeed or 12000) * dt
            if step.Magnitude > limit then
                step = step.Unit * limit
            end
            mover.Current = mover.Current + step
            mover.Apply(mover.Current)
        else
            if distance > 0 then
                mover.Current = mover.Target
                mover.Apply(mover.Current)
            end
            if not mover.Dragging then
                table.insert(finished, name)
            end
        end
    end
    for _, name in ipairs(finished) do
        self._movers[name] = nil
    end
end

function Window:_step(dt)
    self._time = self._time + dt
    self:_watchDrags()
    self:_stepMovers(dt)
    if not self.Visible then
        return
    end
    local clock = self._time
    if self.Effects.Liquid and self.Style.Liquid and not self.Minimized then
        self._liquidClock = self._liquidClock + dt
        if self._liquidClock >= (self.Metrics.Touch and 1 / 24 or 1 / 40) then
            self._liquidClock = 0
            for _, liquid in ipairs(self._liquids) do
                if not liquid.Page or liquid.Page.Visible then
                    liquid:Update(clock)
                end
            end
        end
    end
    if self.BorderGradient and self.Effects.Border and self.Style.Border then
        self.BorderGradient.Rotation = (clock * (self.Style.BorderSpeed or 40)) % 360
    end
    if self.Effects.Rainbow then
        self._rainbowClock = (self._rainbowClock or 0) + dt
        if self._rainbowClock > 0.08 then
            self._rainbowClock = 0
            local hue = (clock * 0.07) % 1
            local accent = Color3.fromHSV(hue, 0.72, 1)
            self:SetToken("Accent", accent)
            self:SetToken("AccentAlt", Color3.fromHSV((hue + 0.12) % 1, 0.72, 1))
            if self.Style.Colors.ToggleOn == self.Style.Colors.Accent then
                self:SetToken("ToggleOn", accent)
            end
        end
    end
    if self.Style.Nav == "Dock" and not self.Metrics.Touch then
        local mouseX = UserInputService:GetMouseLocation().X
        for _, tab in ipairs(self.AllTabs) do
            local slot = tab.Holder
            if tab.DockScale and slot.Parent == self.Dock then
                local width = math.max(slot.AbsoluteSize.X, 1)
                local distance = math.abs(mouseX - (slot.AbsolutePosition.X + width / 2)) / width
                local target = self._dockHover and (1 + 0.55 * math.exp(-(distance * distance) * 1.4)) or 1
                local current = tab.DockScale.Scale
                tab.DockScale.Scale = current + (target - current) * math.min(1, dt * 16)
            end
        end
    end
    if self._caret then
        self._caret.Visible = math.floor(clock * 2) % 2 == 0
    end
end

function Window:_showPopup(popup, anchor, size)
    self:_closePopup()
    local scale = self.Scale.Scale
    local overlay = self.Overlay
    local origin = (anchor.AbsolutePosition - overlay.AbsolutePosition) / scale
    local anchorSize = anchor.AbsoluteSize / scale
    local available = overlay.AbsoluteSize / scale
    local x = origin.X + anchorSize.X - size.X
    x = math.clamp(x, 4, math.max(4, available.X - size.X - 4))
    local y = origin.Y + anchorSize.Y + 4
    if y + size.Y > available.Y - 4 then
        local above = origin.Y - size.Y - 4
        if above >= 4 then
            y = above
        else
            y = math.max(4, available.Y - size.Y - 4)
        end
    end
    local finalPosition = UDim2.fromOffset(math.floor(x), math.floor(y))
    popup.Position = UDim2.fromOffset(math.floor(x), math.floor(y) + 6)
    popup.Size = UDim2.fromOffset(size.X, size.Y)
    popup.Visible = true
    self:Motion("Hover", popup, { Position = finalPosition })
    self.Blocker.Visible = true
    self._popup = popup
end

function Window:_closePopup()
    local popup = self._popup
    if popup then
        popup.Visible = false
        self._popup = nil
    end
    self.Blocker.Visible = false
end

function Window:_setBlur(show)
    if not self.BlurEffect then
        return
    end
    local size = (show and self.Effects.Blur) and 14 or 0
    self:Tween(self.BlurEffect, { Size = size }, 0.3)
end

function Window:SetVisible(visible)
    visible = visible == true
    if self.Visible == visible then
        return
    end
    self.Visible = visible
    self._visibleToken = (self._visibleToken or 0) + 1
    local token = self._visibleToken
    local target = self._targetScale or self.Scale.Scale
    self:_closePopup()
    self:_setBlur(visible)
    if visible then
        self.Root.Visible = true
        self.Root.GroupTransparency = 1
        self.Scale.Scale = target * 0.95
        self:Motion("WindowIn", self.Root, { GroupTransparency = 0 })
        self:Motion("WindowIn", self.Scale, { Scale = target })
    else
        self:_cancelDrags(function(record)
            return record.Handle == self._menuHandle
        end)
        self:Motion("WindowOut", self.Root, { GroupTransparency = 1 })
        self:Motion("WindowOut", self.Scale, { Scale = target * 0.96 })
        task.delay(0.22, function()
            if self._visibleToken == token and not self.Visible then
                self.Root.Visible = false
                self.Scale.Scale = target
            end
        end)
    end
end

function Window:Toggle()
    self:SetVisible(not self.Visible)
end

function Window:SetMinimized(minimized)
    self.Minimized = minimized == true
    self:_closePopup()
    self:_applySize()
    self:_applyPosition()
end

function Window:ToggleMaximize()
    local screen = self:_screenSize()
    local scale = self._targetScale or self.Scale.Scale
    if self._restoreSize then
        self.PreferredSize = self._restoreSize
        self._restoreSize = nil
    else
        self._restoreSize = self.PreferredSize
        self.PreferredSize = Vector2.new(screen.X * 0.98 / scale, screen.Y * 0.96 / scale)
    end
    self._center = Vector2.new(0.5, 0.5)
    self:_updateScale()
end

function Window:GetFlag(flag)
    local element = self.Flags[flag]
    return element and element.Value or nil
end

function Window:SetFlag(flag, value, silent)
    local element = self.Flags[flag]
    if element and element.Set then
        element:Set(value, silent)
    end
end

function Window:Notify(options)
    if type(options) == "string" then
        options = { Content = options }
    end
    options = options or {}
    local duration = options.Duration or 4
    if options.Log ~= false then
        self:_addHistory(options)
    end
    local typeToken = ({ Success = "Success", Warning = "Warning", Error = "Danger" })[options.Type] or "Accent"
    local wrapper = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, self.ToastHolder)
    local card = self:Make("TextButton", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.fromOffset(340, 0),
    }, wrapper, { BackgroundColor3 = "Surface" })
    card.BackgroundTransparency = 0.08
    self:Corner(card, "RadCard")
    self:GlassEdge(self:Stroke(card, typeToken, nil, 1))
    local bar = self:Make("Frame", { Size = UDim2.new(0, 3, 1, -12), Position = UDim2.fromOffset(6, 6) }, card, { BackgroundColor3 = typeToken })
    self:Corner(bar, "RadControl")
    local progress = self:Make("Frame", {
        Size = UDim2.new(1, -16, 0, 2),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -3),
    }, card, { BackgroundColor3 = typeToken })
    local body = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, card)
    addPadding(body, 9, 12, 12, 18)
    addList(body, 2)
    if options.Title and options.Title ~= "" then
        self:Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            Text = options.Title,
            Font = "Semi",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }, body)
    end
    if options.Content and options.Content ~= "" then
        self:Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = options.Content,
            TextSize = 13,
            TextWrapped = true,
            Muted = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 2,
        }, body)
    end
    local dismissed = false
    local function dismiss()
        if dismissed then
            return
        end
        dismissed = true
        local index = table.find(self._toasts, dismiss)
        if index then
            table.remove(self._toasts, index)
        end
        self:Motion("ToastOut", card, { Position = UDim2.fromOffset(340, 0) })
        task.delay(0.26, function()
            wrapper:Destroy()
        end)
    end
    if #self._toasts >= 5 then
        self._toasts[1]()
    end
    table.insert(self._toasts, dismiss)
    card.Activated:Connect(dismiss)
    self:Motion("Toast", card, { Position = UDim2.fromOffset(0, 0) })
    self:Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        if not self.Destroyed then
            dismiss()
        end
    end)
    if self.TerminalPrint and options.Log ~= false then
        local tone = ({ Success = "Success", Warning = "Warning", Error = "Danger" })[options.Type] or "Muted"
        self:TerminalPrint((options.Title and (options.Title .. ": ") or "") .. (options.Content or ""), tone)
    end
    return { Dismiss = dismiss }
end

function Window:Dialog(options)
    options = options or {}
    if self._dialog then
        self._dialog.Close(true)
    end
    self:_closePopup()
    local dim = self:Make("TextButton", {
        Name = "Dialog",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 100,
    }, self.Overlay)
    local card, cardFill = self:Glass(dim, "Panel", {
        Name = "DialogCard",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.8, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
    }, "CanvasGroup")
    cardFill[2] = "DialogHi"
    cardFill[3] = "Dialog"
    self:_applyGradientEntry(cardFill)
    card.BackgroundTransparency = 0.02
    new("UISizeConstraint", { MaxSize = Vector2.new(300, 10000) }, card)
    local pop = new("UIScale", { Scale = 0.95 }, card)
    addPadding(card, 14)
    addList(card, 8)
    self:Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Text = options.Title or "Confirm",
        Font = "Bold",
        TextSize = self.Metrics.Text + 2,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
    }, card)
    if options.Content and options.Content ~= "" then
        self:Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = options.Content,
            TextSize = self.Metrics.Text,
            TextWrapped = true,
            TextTransparency = 0.12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 2,
        }, card)
    end
    local handle = { Closed = false, Resolved = false }
    local elements = {}
    local function close(immediate)
        if handle.Closed then
            return
        end
        handle.Closed = true
        if self._dialog == handle then
            self._dialog = nil
        end
        if immediate then
            dim:Destroy()
            return
        end
        for _, element in ipairs(elements) do
            element.Button.Active = false
        end
        dim.Active = false
        self:Motion("DialogOut", dim, { BackgroundTransparency = 1 })
        self:Motion("DialogOut", card, { GroupTransparency = 1 })
        self:Motion("DialogOut", pop, { Scale = 0.96 })
        task.delay(0.2, function()
            dim:Destroy()
        end)
    end
    handle.Close = close
    local buttons = {}
    for index, definition in ipairs(options.Buttons or { { Text = "OK", Primary = true } }) do
        buttons[index] = {
            Text = definition.Text,
            Primary = definition.Primary,
            NoBind = true,
            Callback = function()
                if handle.Resolved or handle.Closed then
                    return
                end
                handle.Resolved = true
                close()
                if definition.Callback then
                    task.spawn(definition.Callback)
                end
            end,
        }
    end
    local _, created = self:_createButtonRow(card, buttons, 3, nil, true)
    elements = created
    self:Motion("Dialog", dim, { BackgroundTransparency = 0.7 })
    self:Motion("Dialog", card, { GroupTransparency = 0 })
    self:Motion("Dialog", pop, { Scale = 1 })
    self._dialog = handle
    return handle
end

local DOCK_TOKENS = { "Accent", "Success", "Warning", "Danger", "AccentAlt" }

function Window:_iconButton(parent, order, icon, glyph, callback)
    local metrics = self.Metrics
    local size = metrics.Touch and 30 or 24
    local button = self:Make("TextButton", {
        Size = UDim2.fromOffset(size, size),
        LayoutOrder = order,
        ZIndex = 2,
    }, parent, { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField" })
    self:Corner(button, "RadControl")
    self:Stroke(button)
    local fallback = self:Make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        Text = glyph or "",
        TextSize = 16,
        Font = "Semi",
        ZIndex = 3,
    }, button)
    local image = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = 4,
    }, button)
    self:ApplyIcon(image, icon, "Text", function()
        fallback.Visible = false
    end)
    self:Connect(button.MouseEnter, function()
        self:Tween(button, { BackgroundColor3 = self.Tokens.Hover })
    end)
    self:Connect(button.MouseLeave, function()
        self:Tween(button, { BackgroundColor3 = self.Tokens.SurfaceAlt })
    end)
    self:Connect(button.Activated, callback)
    return button
end

function Window:_buildGui(options)
    local metrics = self.Metrics
    local gui = new("ScreenGui", {
        Name = options.Name or "Perplexity",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
        OnTopOfCoreBlur = true,
    })
    mountGui(gui)
    self.Gui = gui
    pcall(function()
        self.BlurEffect = new("BlurEffect", { Name = "PerplexityBlur", Size = 0 }, Lighting)
    end)
    local root = self:Make("CanvasGroup", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(self.BaseSize.X, self.BaseSize.Y),
        Active = true,
    }, gui, { BackgroundColor3 = "Background", BackgroundTransparency = "TransWindow" })
    self.Root = root
    self.Scale = new("UIScale", {}, root)
    self:Corner(root, "RadWindow")
    local border = self:Stroke(root, "Outline", "TransStroke", 1.5)
    self.BorderStroke = border
    self.BorderGradient = self:Gradient(border, "Accent", "AccentAlt", 0)
    local liquidLayer = new("Frame", { Name = "LiquidLayer", Size = UDim2.fromScale(1, 1), ClipsDescendants = true }, root)
    self.LiquidLayer = liquidLayer
    self:_createLiquid(liquidLayer, LIQUID_WINDOW)
    for _, rotation in ipairs({ 0, 90 }) do
        local shade = new("Frame", {
            Name = "Vignette",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            ZIndex = 2,
        }, liquidLayer)
        new("UIGradient", {
            Rotation = rotation,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(0.5, 1),
                NumberSequenceKeypoint.new(1, 0.3),
            }),
        }, shade)
    end
    local corners = new("Frame", { Name = "GamerCorners", Size = UDim2.fromScale(1, 1), ClipsDescendants = true }, root)
    self.CornerDecor = corners
    local bigCorner = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(92, 92),
        Rotation = 45,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.18,
    }, corners)
    self:Gradient(bigCorner, "Accent", "AccentAlt", 0)
    local smallCorner = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromOffset(62, 62),
        Rotation = 45,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.35,
    }, corners)
    self:Gradient(smallCorner, "AccentAlt", "Accent", 0)
    self.Sheen = self:Make("Frame", {
        Name = "Sheen",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, root, { BackgroundTransparency = "TransSheen" })
    new("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.55, 0.85),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, self.Sheen)
    local top = self:Make("Frame", {
        Name = "Top",
        Size = UDim2.new(1, 0, 0, metrics.Top),
    }, root, { BackgroundColor3 = "Surface", BackgroundTransparency = "TransHeader" })
    self.Top = top
    self:_line(top, {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
    })
    local dragArea = new("Frame", { Name = "Drag", Size = UDim2.fromScale(1, 1), Active = true }, top)
    local trafficSize = metrics.Traffic
    local traffic = new("Frame", {
        Name = "Traffic",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(trafficSize * 3 + 16, trafficSize),
        ZIndex = 2,
    }, top)
    self.TrafficFrame = traffic
    local glyphs = {}
    local trafficSpecs = {
        { Color = rgb(255, 95, 87), Glyph = "x", Action = function() self:SetVisible(false) end },
        { Color = rgb(254, 188, 46), Glyph = "-", Action = function() self:SetMinimized(not self.Minimized) end },
        { Color = rgb(40, 200, 64), Glyph = "+", Action = function() self:ToggleMaximize() end },
    }
    for index, spec in ipairs(trafficSpecs) do
        local dot = new("TextButton", {
            Size = UDim2.fromOffset(trafficSize, trafficSize),
            Position = UDim2.fromOffset((index - 1) * (trafficSize + 8), 0),
            BackgroundColor3 = spec.Color,
            ZIndex = 3,
        }, traffic)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)
        local glyph = new("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            Text = spec.Glyph,
            TextSize = 10,
            TextColor3 = Color3.fromRGB(60, 30, 20),
            FontFace = FontSets.Sans.Bold,
            TextTransparency = 1,
            ZIndex = 4,
        }, dot)
        table.insert(glyphs, glyph)
        self:Connect(dot.MouseEnter, function()
            for _, other in ipairs(glyphs) do
                self:Tween(other, { TextTransparency = 0.1 }, 0.1)
            end
        end)
        self:Connect(dot.MouseLeave, function()
            for _, other in ipairs(glyphs) do
                self:Tween(other, { TextTransparency = 1 }, 0.1)
            end
        end)
        self:Connect(dot.Activated, spec.Action)
    end
    local logo = self:Make("Frame", {
        Name = "Logo",
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2,
    }, top)
    self:Corner(logo, "RadIcon")
    self:Gradient(logo, "Accent", "AccentAlt", 45)
    local logoLetter = self:Make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        Text = string.upper(string.sub(self.Title, 1, 1)),
        Font = "Bold",
        TextSize = 15,
        TextColor3 = Color3.new(1, 1, 1),
        ZIndex = 3,
    }, logo)
    local logoImage = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16),
        ImageColor3 = Color3.new(1, 1, 1),
        ZIndex = 4,
    }, logo)
    self:ApplyIcon(logoImage, self.Icon or "sparkles", nil, function()
        logoLetter.Visible = false
    end)
    self.LogoBox = logo
    local titleGroup = new("Frame", {
        Name = "TitleGroup",
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2,
    }, top)
    local titleLayout = addList(titleGroup, 8, Enum.FillDirection.Horizontal)
    titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    self.TitleGroup = titleGroup
    self.TitleLabel = self:Make("TextLabel", {
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = self:Display(self.Title),
        Font = "Bold",
        TextSize = metrics.Text + 4,
        LayoutOrder = 1,
    }, titleGroup)
    self:_onStyle("title", function()
        self.TitleLabel.Text = self:Display(self.Title)
    end)
    if not metrics.Touch then
        local badge = self:Glass(titleGroup, "Field", {
            Size = UDim2.fromOffset(0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = 2,
        })
        addPadding(badge, 0, 8, 0, 8)
        self:Make("TextLabel", {
            Size = UDim2.fromOffset(0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = options.Version or ("v" .. Library.Version),
            TextSize = metrics.Small,
            Muted = true,
        }, badge)
    end
    local actions = new("Frame", {
        Name = "Actions",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2,
    }, top)
    local actionsLayout = addList(actions, 6, Enum.FillDirection.Horizontal)
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    local searchSize = metrics.ControlHeight + 4
    local searchExpanded = metrics.Touch and 118 or 150
    local search = self:Glass(actions, "Field", {
        Name = "Search",
        Size = UDim2.fromOffset(searchSize, searchSize),
        LayoutOrder = 1,
        ClipsDescendants = true,
        ZIndex = 2,
    })
    local searchIcon = new("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, (searchSize - 14) / 2, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        ZIndex = 3,
    }, search)
    local searchGlyph = self:Make("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, (searchSize - 14) / 2, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Text = "?",
        TextSize = 12,
        Muted = true,
        ZIndex = 3,
    }, search)
    self:ApplyIcon(searchIcon, "search", "Muted", function()
        searchGlyph.Visible = false
    end)
    local searchBox = self:Make("TextBox", {
        Name = "Input",
        Position = UDim2.fromOffset(searchSize, 0),
        Size = UDim2.new(1, -(searchSize + 6), 1, 0),
        PlaceholderText = "Search...",
        TextSize = metrics.Text - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 3,
    }, search, { PlaceholderColor3 = "Muted" })
    local searchHit = new("TextButton", { Name = "Hit", Size = UDim2.fromOffset(searchSize, searchSize), ZIndex = 4 }, search)
    local searchOpen = false
    local function setSearchOpen(open)
        searchOpen = open
        searchBox.Visible = open
        self:Motion("Tab", search, { Size = UDim2.fromOffset(open and searchExpanded or searchSize, searchSize) })
        if open then
            searchBox:CaptureFocus()
        end
    end
    self.SearchBox = searchBox
    self._setSearchOpen = setSearchOpen
    self:Connect(searchHit.Activated, function()
        if searchOpen then
            searchBox.Text = ""
            setSearchOpen(false)
        else
            setSearchOpen(true)
        end
    end)
    self:Connect(searchBox.FocusLost, function()
        if searchBox.Text == "" and searchOpen then
            setSearchOpen(false)
        end
    end)
    self:Connect(searchBox:GetPropertyChangedSignal("Text"), function()
        self:SetSearch(searchBox.Text)
    end)
    self.BellButton = self:_iconButton(actions, 2, "bell", "!", function()
        self:ToggleNotifications()
    end)
    self._bellDot = self:Make("Frame", {
        Name = "Dot",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, 4),
        Size = UDim2.fromOffset(7, 7),
        Visible = false,
        ZIndex = 6,
    }, self.BellButton, { BackgroundColor3 = "Danger" })
    self:Corner(self._bellDot, "RadPill")
    self:_iconButton(actions, 3, "save", "S", function()
        self:FastSave()
    end)
    self._terminalButton = self:_iconButton(actions, 4, "terminal", ">", function()
        self:SetTerminalVisible(not self.TerminalVisible)
    end)
    local windowButtons = new("Frame", {
        Name = "WindowButtons",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 5,
        ZIndex = 2,
    }, actions)
    local windowLayout = addList(windowButtons, 6, Enum.FillDirection.Horizontal)
    windowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    self:_iconButton(windowButtons, 1, "minus", "-", function()
        self:SetMinimized(not self.Minimized)
    end)
    self:_iconButton(windowButtons, 2, "x", "x", function()
        self:SetVisible(false)
    end)
    self.WindowButtons = windowButtons
    local dragCenter
    self._windowDrag = self:_trackDrag(dragArea, function(input, record)
        local mover = self._movers.Window
        if not mover or not dragCenter then
            return
        end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - record.Start
        mover.Target = self:_clampCenter(dragCenter + delta)
    end, function()
        local screen = self:_screenSize()
        dragCenter = Vector2.new(self._center.X * screen.X, self._center.Y * screen.Y)
        self:_closePopup()
        self._movers.Window = {
            Current = dragCenter,
            Target = dragCenter,
            Dragging = true,
            Rate = metrics.Touch and 18 or 34,
            MaxSpeed = metrics.Touch and 3200 or 12000,
            Apply = function(position)
                local screen = self:_screenSize()
                self._center = Vector2.new(position.X / screen.X, position.Y / screen.Y)
                self.Root.Position = UDim2.fromScale(self._center.X, self._center.Y)
            end,
        }
    end, function()
        local mover = self._movers.Window
        if mover then
            mover.Dragging = false
            mover.Rate = 50
        end
    end)
    local body = new("Frame", {
        Name = "Body",
        Position = UDim2.fromOffset(0, metrics.Top),
        Size = UDim2.new(1, 0, 1, -metrics.Top),
    }, root)
    self.Body = body
    local rail = self:Make("Frame", { Name = "Rail" }, body, { BackgroundColor3 = "Surface", BackgroundTransparency = "TransRail" })
    self:Corner(rail, "RadPanel")
    self.Rail = rail
    self.RailDivider = self:_line(body, {
        Name = "RailDivider",
        Size = UDim2.new(0, 1, 1, 0),
    }, 90)
    self.RailList = self:Make("ScrollingFrame", {
        Name = "Tabs",
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 0,
    }, rail)
    addList(self.RailList, 4)
    local railBottom = new("Frame", {
        Name = "RailBottom",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, rail)
    addList(railBottom, 6)
    self.RailBottom = railBottom
    self.BuiltinHolder = new("Frame", {
        Name = "Builtin",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
    }, railBottom)
    addList(self.BuiltinHolder, 4)
    local footer = self:Glass(railBottom, "Card", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 52),
        LayoutOrder = 2,
    })
    self.Footer = footer
    local footerLogo = self:Make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, footer)
    self:Corner(footerLogo, "RadIcon")
    self:Gradient(footerLogo, "Accent", "AccentAlt", 45)
    local footerImage = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(18, 18),
        ImageColor3 = Color3.new(1, 1, 1),
    }, footerLogo)
    local footerLetter = self:Make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        Text = string.upper(string.sub(self.Title, 1, 1)),
        Font = "Bold",
        TextSize = 15,
        TextColor3 = Color3.new(1, 1, 1),
    }, footerLogo)
    self:ApplyIcon(footerImage, self.Icon or "sparkles", nil, function()
        footerLetter.Visible = false
    end)
    self:Make("TextLabel", {
        Position = UDim2.fromOffset(42, 6),
        Size = UDim2.new(1, -46, 0, 14),
        Text = self.Title,
        Font = "Semi",
        TextSize = metrics.Small + 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, footer)
    self:Make("TextLabel", {
        Position = UDim2.fromOffset(42, 20),
        Size = UDim2.new(1, -46, 0, 12),
        Text = options.Version or ("v" .. Library.Version),
        TextSize = metrics.Small - 1,
        Muted = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, footer)
    if options.Status ~= false then
        local pill = self:Make("Frame", {
            Position = UDim2.fromOffset(42, 33),
            Size = UDim2.fromOffset(0, 14),
            AutomaticSize = Enum.AutomaticSize.X,
        }, footer, { BackgroundColor3 = "Success" })
        pill.BackgroundTransparency = 0.8
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)
        addPadding(pill, 0, 8, 0, 18)
        local dot = self:Make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, -12, 0.5, 0),
            Size = UDim2.fromOffset(6, 6),
        }, pill, { BackgroundColor3 = "Success" })
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)
        self:Make("TextLabel", {
            Size = UDim2.fromOffset(0, 14),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = options.Status or "Supported",
            TextSize = metrics.Small - 1,
            Color = "Success",
        }, pill)
    end
    self:Connect(railBottom:GetPropertyChangedSignal("AbsoluteSize"), function()
        local height = railBottom.AbsoluteSize.Y / self.Scale.Scale
        self.RailList.Size = UDim2.new(1, 0, 1, -(height + 8))
    end)
    local dock = self:Glass(body, "Panel", {
        Name = "Dock",
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.new(0, 0, 0, metrics.DockHeight),
        AutomaticSize = Enum.AutomaticSize.X,
    })
    addPadding(dock, 4, 10, 2, 10)
    local dockLayout = addList(dock, 2, Enum.FillDirection.Horizontal)
    dockLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.Dock = dock
    self:Connect(dock.MouseEnter, function()
        self._dockHover = true
    end)
    self:Connect(dock.MouseLeave, function()
        self._dockHover = false
    end)
    self.PageHolder = new("Frame", { Name = "Pages", ClipsDescendants = true }, body)
    self:_buildTerminal(body)
    local gripSize = metrics.Touch and 28 or 16
    local grip = new("TextButton", {
        Name = "Resize",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1),
        Size = UDim2.fromOffset(gripSize, gripSize),
        ZIndex = 10,
    }, root)
    self.Grip = grip
    for _, dotSpec in ipairs({ { 1, 1 }, { 2, 1 }, { 3, 1 }, { 1, 2 }, { 2, 2 }, { 1, 3 } }) do
        self:Make("Frame", {
            Size = UDim2.fromOffset(2, 2),
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 3 - dotSpec[1] * 4, 1, 3 - dotSpec[2] * 4),
            ZIndex = 11,
        }, grip, { BackgroundColor3 = "Muted" })
    end
    local resizeStart, resizeSize, resizeCorner
    self:_trackDrag(grip, function(input)
        local scale = self._targetScale or self.Scale.Scale
        local screen = self:_screenSize()
        local slow = metrics.Touch and 0.7 or 1
        local delta = (Vector2.new(input.Position.X, input.Position.Y) - resizeStart) * slow / scale
        local maxWidth = math.max(self.MinSize.X, (screen.X - resizeCorner.X) / scale)
        local maxHeight = math.max(self.MinSize.Y, (screen.Y - resizeCorner.Y) / scale)
        local width = math.clamp(resizeSize.X + delta.X, self.MinSize.X, maxWidth)
        local height = math.clamp(resizeSize.Y + delta.Y, self.MinSize.Y, maxHeight)
        self.PreferredSize = Vector2.new(width, height)
        self.BaseSize = self.PreferredSize
        self:_applySize()
        self:_layout()
        local center = resizeCorner + self.BaseSize * scale / 2
        self._center = Vector2.new(center.X / screen.X, center.Y / screen.Y)
        root.Position = UDim2.fromScale(self._center.X, self._center.Y)
    end, function(input)
        resizeStart = Vector2.new(input.Position.X, input.Position.Y)
        resizeSize = self.BaseSize
        local screen = self:_screenSize()
        local scale = self._targetScale or self.Scale.Scale
        resizeCorner = Vector2.new(
            self._center.X * screen.X - self.BaseSize.X * scale / 2,
            self._center.Y * screen.Y - self:_windowHeight() * scale / 2
        )
        self:_closePopup()
    end)
    self.Overlay = new("Frame", { Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 50 }, root)
    self.Blocker = new("TextButton", {
        Name = "Blocker",
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 1,
    }, self.Overlay)
    self:Connect(self.Blocker.Activated, function()
        self:_closePopup()
    end)
    local toasts = new("Frame", {
        Name = "Toasts",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 250, 2, 0),
    }, gui)
    addPadding(toasts, 12)
    local toastLayout = addList(toasts, 8)
    toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    self.ToastHolder = toasts
    self.ToastScale = new("UIScale", {}, toasts)
    local showButton = options.ToggleButton
    if showButton == nil then
        showButton = metrics.Touch
    end
    if showButton then
        local buttonSize = metrics.Touch and 50 or 44
        local half = buttonSize / 2
        local menuButton = self:Glass(gui, "Panel", {
            Name = "MenuButton",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(16 + half, 80 + half),
            Size = UDim2.fromOffset(buttonSize, buttonSize),
            ZIndex = 5,
        })
        for _, child in ipairs(menuButton:GetChildren()) do
            if child:IsA("UICorner") then
                child:Destroy()
            end
        end
        self:Corner(menuButton, "RadPill")
        local menuLabel = self:Make("TextButton", {
            Size = UDim2.fromScale(1, 1),
            Text = string.upper(string.sub(self.Title, 1, 1)),
            Font = "Bold",
            TextSize = 20,
            Color = "Accent",
            ZIndex = 6,
        }, menuButton)
        local menuScale = new("UIScale", {}, menuButton)
        local menuStart
        self._menuPos = Vector2.new(16, 80)
        self._menuHandle = self:_trackDrag(menuLabel, function(input, record)
            local mover = self._movers.Menu
            if not mover or not menuStart then
                return
            end
            local delta = Vector2.new(input.Position.X, input.Position.Y) - record.Start
            local screen = self:_screenSize()
            mover.Target = Vector2.new(
                math.clamp(menuStart.X + delta.X, 0, screen.X - buttonSize),
                math.clamp(menuStart.Y + delta.Y, 0, screen.Y - buttonSize)
            )
        end, function()
            self:Motion("Press", menuScale, { Scale = 0.94 })
            menuStart = self._menuPos
            self._menuHalf = half
            self._movers.Menu = {
                Current = menuStart,
                Target = menuStart,
                Dragging = true,
                Rate = metrics.Touch and 24 or 40,
                MaxSpeed = 5000,
                Apply = function(position)
                    self._menuPos = position
                    menuButton.Position = UDim2.fromOffset(position.X + half, position.Y + half)
                end,
            }
        end, function(cancelled, record)
            self:Motion("Press", menuScale, { Scale = 1 })
            local mover = self._movers.Menu
            if mover then
                mover.Dragging = false
                mover.Rate = 50
            end
            if not cancelled and not record.Moved then
                self:Toggle()
            end
        end, { Threshold = 10 })
        self._menuHalf = half
        self.MenuButton = menuButton
    end
    self:Connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function()
        self:_updateScale()
    end)
    local camera = workspace.CurrentCamera
    if camera then
        self:Connect(camera:GetPropertyChangedSignal("ViewportSize"), function()
            self:_updateScale()
        end)
    end
    self:Connect(UserInputService.InputBegan, function(input)
        self:_handleInputBegan(input)
    end)
    self:Connect(UserInputService.InputEnded, function(input)
        self:_handleInputEnded(input)
        self:_dragEnded(input)
    end)
    self:Connect(UserInputService.InputChanged, function(input)
        self:_dragInput(input)
    end)
    self:Connect(UserInputService.WindowFocusReleased, function()
        self:_cancelDrags()
    end)
    self:Connect(RunService.RenderStepped, function(dt)
        self:_step(dt)
    end)
    self:_applyStyleLayout()
    self:_updateScale()
end

function Window:_applyStyleLayout()
    local style = self.Style
    local metrics = self.Metrics
    self.TrafficFrame.Visible = style.Traffic
    self.WindowButtons.Visible = not style.Traffic
    local leftX = style.Traffic and (14 + metrics.Traffic * 3 + 16 + 14) or 14
    self.LogoBox.Position = UDim2.new(0, leftX, 0.5, 0)
    self.TitleGroup.Position = UDim2.new(0, leftX + 30, 0.5, 0)
    self.LiquidLayer.Visible = self.Effects.Liquid and style.Liquid
    self.BorderGradient.Enabled = self.Effects.Border and style.Border
    self.BorderStroke.Thickness = style.BorderThickness or 1.5
    self.CornerDecor.Visible = style.Corner == true
    self:_applyLines()
    self:_syncGamerParts()
    self.Sheen.Visible = style.Numbers.TransSheen < 1
    for _, tab in ipairs(self.AllTabs) do
        tab:_applyNav()
    end
    for _, hook in pairs(self._styleHooks) do
        pcall(hook)
    end
    self:_refreshGradients()
    self:_layout()
    for _, tab in ipairs(self.AllTabs) do
        tab:_updateLayout()
    end
end

function Window:SetTerminalVisible(visible)
    self.TerminalVisible = visible == true
    if self._terminalToggle then
        self._terminalToggle:Set(self.TerminalVisible, true)
    end
    self:_layout()
    if self.TerminalVisible and self._terminalBanner then
        self._terminalBanner()
    end
end

function Window:_playIntro()
    local metrics = self.Metrics
    local splash = self:Make("CanvasGroup", {
        Name = "Intro",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 200,
        Active = true,
    }, self.Overlay, { BackgroundColor3 = "Background" })
    splash.BackgroundTransparency = 0
    local center = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(260, 170),
    }, splash)
    local pop = new("UIScale", { Scale = 0.6 }, center)
    local logo = self:Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(64, 64),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, center)
    self:Corner(logo, "RadPanel")
    self:Gradient(logo, "Accent", "AccentAlt", 45)
    local letter = self:Make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        Text = string.upper(string.sub(self.Title, 1, 1)),
        Font = "Bold",
        TextSize = 34,
        TextColor3 = Color3.new(1, 1, 1),
    }, logo)
    local image = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(38, 38),
        ImageColor3 = Color3.new(1, 1, 1),
    }, logo)
    self:ApplyIcon(image, self.Icon or "sparkles", nil, function()
        letter.Visible = false
    end)
    self:Make("TextLabel", {
        Position = UDim2.fromOffset(0, 74),
        Size = UDim2.new(1, 0, 0, 28),
        Text = self.Title,
        Font = "Bold",
        TextSize = 24,
    }, center)
    self:Make("TextLabel", {
        Position = UDim2.fromOffset(0, 102),
        Size = UDim2.new(1, 0, 0, 16),
        Text = "v" .. Library.Version .. "  by " .. Library.Author,
        TextSize = 12,
        Muted = true,
    }, center)
    local track = self:Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 134),
        Size = UDim2.fromOffset(180, 4),
    }, center, { BackgroundColor3 = "SurfaceAlt" })
    self:Corner(track, "RadPill")
    local fill = self:Make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1) }, track)
    self:Corner(fill, "RadPill")
    self:Gradient(fill, "Accent", "AccentAlt", 0)
    self:Tween(pop, { Scale = 1 }, 0.5, Enum.EasingStyle.Quint)
    self:Tween(fill, { Size = UDim2.new(1, 0, 1, 0) }, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    task.delay(1.15, function()
        if self.Destroyed then
            return
        end
        self:Tween(splash, { GroupTransparency = 1 }, 0.45)
        task.delay(0.5, function()
            splash:Destroy()
        end)
    end)
end

function Window:SelectTab(tab)
    self:_closePopup()
    if self.SelectedTab == tab then
        return
    end
    local previous = self.SelectedTab
    if previous then
        previous.Selected = false
        previous:_applySelected(true)
        previous.Page.Visible = false
    end
    self.SelectedTab = tab
    tab.Selected = true
    tab.Page.Visible = true
    tab.Page.Position = UDim2.fromOffset(0, 16)
    self:Motion("Tab", tab.Page, { Position = UDim2.fromOffset(0, 0) })
    tab:_applySelected(true)
    tab:_updateLayout()
end

function Window:AddTab(options)
    if type(options) == "string" then
        options = { Title = options }
    end
    local tab = self:_createTab(options or {}, false)
    table.insert(self.Tabs, tab)
    if not self.SelectedTab then
        self:SelectTab(tab)
    end
    return tab
end

function Window:_createTab(options, builtin)
    local metrics = self.Metrics
    local tab = setmetatable({
        Window = self,
        Title = options.Title or options.Name or "Tab",
        IconSpec = options.Icon,
        Builtin = builtin == true,
        Selected = false,
        Sections = { Left = {}, Right = {} },
        Index = #self.AllTabs + 1,
    }, Tab)
    table.insert(self.AllTabs, tab)
    tab.Holder = new("Frame", {
        Name = "TabItem",
        Size = UDim2.new(1, 0, 0, metrics.TabHeight),
        LayoutOrder = (builtin and 1000 or 0) + tab.Index,
    })
    tab.Button = self:Make("TextButton", { Name = "Tab" }, tab.Holder, { BackgroundColor3 = "SurfaceAlt" })
    tab.Button.BackgroundTransparency = 1
    tab.ButtonCorner = self:Corner(tab.Button, "RadControl")
    tab.Fill = self:Make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
    }, tab.Button)
    tab.FillCorner = self:Corner(tab.Fill, "RadControl")
    local _, entry = self:Gradient(tab.Fill, "Accent", "AccentAlt", 0)
    tab.FillEntry = entry
    tab.Glow = self:Make("UIStroke", { Thickness = 2, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tab.Button, { Color = "Accent" })
    tab.Icon = new("ImageLabel", { Name = "Icon", AnchorPoint = Vector2.new(0, 0.5), ZIndex = 3 }, tab.Button)
    tab.IconFallback = self:Make("TextLabel", {
        Name = "Fallback",
        AnchorPoint = Vector2.new(0, 0.5),
        Text = string.upper(string.sub(tab.Title, 1, 1)),
        Font = "Bold",
        TextSize = metrics.Text,
        ZIndex = 3,
    }, tab.Button)
    self:ApplyIcon(tab.Icon, options.Icon, "Text", function()
        tab.IconFallback.Visible = false
    end)
    tab.Label = self:Make("TextLabel", {
        Name = "Label",
        AnchorPoint = Vector2.new(0, 0.5),
        Text = tab.Title,
        Font = "Semi",
        TextSize = metrics.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        RichText = true,
        ZIndex = 3,
    }, tab.Button)
    tab.Dot = self:Make("Frame", {
        Name = "Dot",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 6),
        Size = UDim2.fromOffset(5, 5),
        BackgroundTransparency = 1,
    }, tab.Holder, { BackgroundColor3 = "Text" })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, tab.Dot)
    tab.DockScale = new("UIScale", {}, tab.Button)
    tab.Tip = self:Glass(tab.Holder, "Field", {
        Name = "Tip",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0, -4),
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = false,
        ZIndex = 20,
    })
    addPadding(tab.Tip, 0, 8, 0, 8)
    self:Make("TextLabel", {
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = tab.Title,
        TextSize = metrics.Small,
        ZIndex = 21,
    }, tab.Tip)
    self:Connect(tab.Button.MouseEnter, function()
        if self.Style.Nav == "Dock" or not self.Style.ShowLabels then
            tab.Tip.Visible = true
        end
    end)
    self:Connect(tab.Button.MouseLeave, function()
        tab.Tip.Visible = false
    end)
    tab.Page = self:Make("ScrollingFrame", {
        Name = "Page",
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = metrics.ScrollBar,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
        Visible = false,
    }, self.PageHolder, { ScrollBarImageColor3 = "Accent" })
    addPadding(tab.Page, 2, metrics.ScrollBar + 4, 6, 2)
    tab.Layout = addList(tab.Page, metrics.Gap, Enum.FillDirection.Horizontal)
    tab.Left = new("Frame", {
        Name = "Left",
        Size = UDim2.new(0.5, -metrics.Gap / 2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        Visible = false,
    }, tab.Page)
    addList(tab.Left, metrics.Gap)
    tab.Right = new("Frame", {
        Name = "Right",
        Size = UDim2.new(0.5, -metrics.Gap / 2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Visible = false,
    }, tab.Page)
    addList(tab.Right, metrics.Gap)
    self:Connect(tab.Button.Activated, function()
        self:SelectTab(tab)
    end)
    self:Connect(tab.Button.MouseEnter, function()
        tab:_applyHover(true)
    end)
    self:Connect(tab.Button.MouseLeave, function()
        tab:_applyHover(false)
    end)
    self:Connect(tab.Page:GetPropertyChangedSignal("AbsoluteSize"), function()
        tab:_updateLayout()
    end)
    tab:_applyNav()
    tab:_applySelected(false)
    return tab
end

function Tab:_applyLabel()
    local window = self.Window
    if window.StyleId == "ClaudeCode" then
        local marker = self.Selected and string.format('<font color="%s">&gt;</font> ', hexOf(window.Tokens.Accent)) or "  "
        self.Label.Text = marker .. escapeRich(string.lower(self.Title))
    else
        self.Label.Text = escapeRich(window:Display(self.Title))
    end
end

function Tab:_applyNav()
    local window = self.Window
    local metrics = window.Metrics
    local style = window.Style
    local holder, button, fill, icon, fallback, label = self.Holder, self.Button, self.Fill, self.Icon, self.IconFallback, self.Label
    local dock = style.Nav == "Dock"
    if dock then
        holder.Parent = window.Dock
    elseif self.Builtin then
        holder.Parent = window.BuiltinHolder
    else
        holder.Parent = window.RailList
    end
    local iconSize = metrics.IconSize
    if dock then
        holder.Size = UDim2.fromOffset(metrics.DockIcon + 14, metrics.DockIcon + 16)
        button.AnchorPoint = Vector2.new(0.5, 1)
        button.Position = UDim2.new(0.5, 0, 1, -8)
        button.Size = UDim2.fromOffset(metrics.DockIcon, metrics.DockIcon)
        button.BackgroundTransparency = 1
        local token = DOCK_TOKENS[(self.Index - 1) % #DOCK_TOKENS + 1]
        self.FillEntry[2] = token
        self.FillEntry[3] = token
        self.FillCorner.CornerRadius = UDim.new(0, 12)
        self.ButtonCorner.CornerRadius = UDim.new(0, 12)
        fill.BackgroundTransparency = 0
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromOffset(metrics.DockIcon * 0.52, metrics.DockIcon * 0.52)
        fallback.AnchorPoint = Vector2.new(0.5, 0.5)
        fallback.Position = UDim2.fromScale(0.5, 0.5)
        fallback.Size = UDim2.fromOffset(metrics.DockIcon * 0.5, metrics.DockIcon * 0.5)
        label.Visible = false
    elseif style.ShowLabels then
        holder.Size = UDim2.new(1, 0, 0, metrics.TabHeight)
        button.AnchorPoint = Vector2.new(0, 0)
        button.Position = UDim2.fromOffset(0, 0)
        button.Size = UDim2.fromScale(1, 1)
        button.BackgroundTransparency = 1
        self.FillEntry[2] = "Accent"
        self.FillEntry[3] = "AccentAlt"
        self.FillCorner.CornerRadius = window.Tokens.RadControl
        self.ButtonCorner.CornerRadius = window.Tokens.RadControl
        local showIcon = style.ShowIcons
        icon.Visible = showIcon
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0, 12, 0.5, 0)
        icon.Size = UDim2.fromOffset(iconSize, iconSize)
        fallback.AnchorPoint = Vector2.new(0, 0.5)
        fallback.Position = UDim2.new(0, 12, 0.5, 0)
        fallback.Size = UDim2.fromOffset(iconSize, iconSize)
        label.Visible = true
        local textX = showIcon and (12 + iconSize + 10) or 10
        label.Position = UDim2.new(0, textX, 0.5, 0)
        label.Size = UDim2.new(1, -(textX + 8), 0, metrics.TabHeight - 8)
    else
        holder.Size = UDim2.new(1, 0, 0, metrics.TabHeight + 10)
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.Position = UDim2.fromScale(0.5, 0.5)
        button.Size = UDim2.fromOffset(metrics.TabHeight + 4, metrics.TabHeight + 4)
        button.BackgroundTransparency = 0.3
        self.FillEntry[2] = "Accent"
        self.FillEntry[3] = "AccentAlt"
        self.FillCorner.CornerRadius = window.Tokens.RadPill
        self.ButtonCorner.CornerRadius = window.Tokens.RadPill
        icon.Visible = true
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromOffset(iconSize, iconSize)
        fallback.AnchorPoint = Vector2.new(0.5, 0.5)
        fallback.Position = UDim2.fromScale(0.5, 0.5)
        fallback.Size = UDim2.fromOffset(iconSize, iconSize)
        label.Visible = false
    end
    fallback.Visible = icon.Image == "" and (icon.Visible or dock or not style.ShowLabels)
    self.Dot.Visible = dock
    self.Glow.Enabled = style.Glow
    self:_applyLabel()
    self:_applySelected(false)
    self:_refreshFallback()
end

function Tab:_applyHover(hovered)
    local window = self.Window
    local style = window.Style
    if self.Selected or style.Nav == "Dock" then
        return
    end
    local rest = style.ShowLabels and 1 or 0.3
    local lit = style.ShowLabels and 0.8 or 0.1
    window:Motion("Hover", self.Button, { BackgroundTransparency = hovered and lit or rest })
end

function Tab:_refreshFallback()
    if self.Icon.Image ~= "" then
        self.IconFallback.Visible = false
    end
end

function Tab:_applySelected(animate)
    local window = self.Window
    local style = window.Style
    local selected = self.Selected
    local function set(instance, properties)
        if animate then
            window:Motion("Tab", instance, properties)
        else
            for key, value in pairs(properties) do
                instance[key] = value
            end
        end
    end
    if style.Nav == "Dock" then
        set(self.Dot, { BackgroundTransparency = selected and 0 or 1 })
        set(self.Icon, { ImageTransparency = 0 })
        set(self.IconFallback, { TextTransparency = 0 })
    elseif style.ShowLabels then
        local filled = selected and style.Id ~= "ClaudeCode"
        set(self.Fill, { BackgroundTransparency = filled and 0 or 1 })
        set(self.Label, { TextTransparency = selected and 0 or 0.4 })
        set(self.Icon, { ImageTransparency = selected and 0 or 0.4 })
        set(self.IconFallback, { TextTransparency = selected and 0 or 0.4 })
        set(self.Glow, { Transparency = 1 })
    else
        set(self.Fill, { BackgroundTransparency = selected and 0 or 1 })
        set(self.Icon, { ImageTransparency = selected and 0 or 0.35 })
        set(self.IconFallback, { TextTransparency = selected and 0 or 0.35 })
        set(self.Glow, { Transparency = (selected and style.Glow) and 0.35 or 1 })
    end
    self:_applyLabel()
end

function Tab:_updateLayout()
    local window = self.Window
    local metrics = window.Metrics
    local style = window.Style
    local pixels = self.Page.AbsoluteSize.X
    if pixels <= 0 then
        return
    end
    local width = pixels / window.Scale.Scale - metrics.ScrollBar - 6
    local hasLeft = #self.Sections.Left > 0 or self.CategoryPanel ~= nil
    local hasRight = #self.Sections.Right > 0
    local minimum = metrics.MinColumn * 2 + metrics.Gap
    local single = style.SingleColumn == true or width < minimum or not (hasLeft and hasRight)
    if single then
        self.Layout.FillDirection = Enum.FillDirection.Vertical
        self.Left.Size = UDim2.new(1, 0, 0, 0)
        self.Right.Size = UDim2.new(1, 0, 0, 0)
    else
        self.Layout.FillDirection = Enum.FillDirection.Horizontal
        local half = UDim2.new(0.5, -metrics.Gap / 2, 0, 0)
        self.Left.Size = half
        self.Right.Size = half
    end
end

local Category = {}
Category.__index = Category

function Tab:_buildCategoryPanel()
    local window = self.Window
    local metrics = window.Metrics
    local panel = window:Glass(self.Left, "Panel", {
        Name = "Categories",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 500,
    })
    addPadding(panel, metrics.PanelPad - 2)
    addList(panel, metrics.Gap)
    local strip = window:Make("ScrollingFrame", {
        Name = "Strip",
        Size = UDim2.new(1, 0, 0, metrics.CategoryHeight),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 0,
        LayoutOrder = 1,
    }, panel)
    addList(strip, 6, Enum.FillDirection.Horizontal)
    window:Make("Frame", {
        Name = "StripLine",
        Size = UDim2.new(1, 0, 0, 1),
        LayoutOrder = 2,
    }, panel, { BackgroundColor3 = "Outline", BackgroundTransparency = "TransStroke" })
    local content = new("Frame", {
        Name = "CategoryContent",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 3,
    }, panel)
    addList(content, metrics.Gap)
    self.CategoryPanel = panel
    self.CategoryStrip = strip
    self.CategoryContent = content
    self.Categories = {}
    self.Left.Visible = true
    self:_updateLayout()
end

function Tab:AddCategory(options)
    if type(options) == "string" then
        options = { Title = options }
    end
    options = options or {}
    if not self.CategoryPanel then
        self:_buildCategoryPanel()
    end
    local window = self.Window
    local metrics = window.Metrics
    local category = setmetatable({
        Window = window,
        Tab = self,
        Title = options.Title or options.Name or "Category",
        Selected = false,
    }, Category)
    local pill = window:Make("Frame", {
        Name = "Pill",
        Size = UDim2.fromOffset(0, metrics.CategoryHeight),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = #self.Categories + 1,
        ClipsDescendants = true,
    }, self.CategoryStrip, { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField" })
    window:Corner(pill, "RadControl")
    window:Stroke(pill)
    category.Fill = window:Make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
    }, pill)
    window:Corner(category.Fill, "RadControl")
    window:Gradient(category.Fill, "Accent", "AccentAlt", 0)
    category.Label = window:Make("TextLabel", {
        Size = UDim2.fromOffset(0, metrics.CategoryHeight),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = window:Display(category.Title),
        Font = "Semi",
        TextSize = metrics.Text - 1,
        TextTransparency = 0.35,
        ZIndex = 2,
    }, pill)
    addPadding(category.Label, 0, 11, 0, 11)
    window:_onStyle(category, function()
        category.Label.Text = window:Display(category.Title)
    end)
    local hit = new("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 3 }, pill)
    window:Connect(hit.Activated, function()
        self:SelectCategory(category)
    end)
    window:Connect(hit.MouseEnter, function()
        if not category.Selected then
            window:Motion("Hover", pill, { BackgroundColor3 = window.Tokens.Hover })
        end
    end)
    window:Connect(hit.MouseLeave, function()
        window:Motion("Hover", pill, { BackgroundColor3 = window.Tokens.SurfaceAlt })
    end)
    table.insert(self.Categories, category)
    if #self.Categories == 1 then
        self:SelectCategory(category)
    end
    return category
end

function Category:AddSection(options)
    if type(options) == "string" then
        options = { Title = options }
    end
    options = options or {}
    options.Category = self
    options.Side = "Left"
    return self.Tab:AddSection(options)
end

function Category:Select()
    self.Tab:SelectCategory(self)
end

function Tab:SelectCategory(category)
    local window = self.Window
    for _, other in ipairs(self.Categories) do
        local selected = other == category
        other.Selected = selected
        window:Motion("Tab", other.Fill, { BackgroundTransparency = selected and 0 or 1 })
        window:Motion("Tab", other.Label, { TextTransparency = selected and 0 or 0.35 })
    end
    for _, section in ipairs(self.Sections.Left) do
        if section.Category then
            section:_applyVisibility()
        end
    end
end

function Tab:AddSection(options)
    if type(options) == "string" then
        options = { Title = options }
    end
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local category = options.Category
    local bare = options.Bare == true
    local side = options.Side
    if side ~= "Left" and side ~= "Right" then
        side = (#self.Sections.Left <= #self.Sections.Right) and "Left" or "Right"
    end
    if category then
        side = "Left"
    end
    local column = side == "Left" and self.Left or self.Right
    if category then
        column = self.CategoryContent
    end
    local section = setmetatable({
        Window = window,
        Tab = self,
        Side = side,
        Category = category,
        Title = options.Title or options.Name,
        Collapsed = false,
        Columns = options.Columns or 1,
        _order = 0,
        _items = {},
        _grids = {},
        _searchVisible = true,
    }, Section)
    local frameProperties = {
        Name = "Section",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = category and (#self.Sections.Left + 1) or (#self.Sections[side] + 1),
    }
    if bare or category then
        section.Frame = window:Make("Frame", frameProperties, column)
    else
        section.Frame = window:Glass(column, "Panel", frameProperties)
        addPadding(section.Frame, metrics.PanelPad)
    end
    addList(section.Frame, metrics.Gap)
    local title = section.Title
    if title and title ~= "" and not bare then
        local collapsible = options.Collapsible ~= false
        local header = window:Make(collapsible and "TextButton" or "Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, metrics.Text + 10 + (metrics.Touch and 6 or 0)),
            LayoutOrder = 1,
        }, section.Frame)
        local textX = 0
        if options.Icon then
            local headerIcon = new("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.fromOffset(metrics.IconSize, metrics.IconSize),
            }, header)
            window:ApplyIcon(headerIcon, options.Icon, "Text")
            textX = metrics.IconSize + 8
        end
        section.HeaderLabel = window:Make("TextLabel", {
            Position = UDim2.fromOffset(textX, 0),
            Size = UDim2.new(1, -(textX + 20), 1, 0),
            Text = window:Display(title),
            Font = "Semi",
            TextSize = metrics.Text + 1,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, header)
        window:_onStyle(section, function()
            section.HeaderLabel.Text = window:Display(title)
        end)
        if collapsible then
            section.Chevron = window:_chevron(header, 2)
            window:Connect(header.Activated, function()
                section:SetCollapsed(not section.Collapsed)
            end)
        end
        if not category then
            window:_line(section.Frame, {
                Name = "Separator",
                Size = UDim2.new(1, 0, 0, 1),
                LayoutOrder = 2,
            })
        end
    end
    section.Content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 3,
    }, section.Frame)
    section.ContentList = addList(section.Content, metrics.Gap)
    window:Connect(section.Frame:GetPropertyChangedSignal("AbsoluteSize"), function()
        section:_applyColumns()
    end)
    column.Visible = true
    table.insert(self.Sections[side], section)
    self:_updateLayout()
    if options.Collapsed == true and title and not bare then
        section:SetCollapsed(true)
    end
    section:_applyVisibility()
    return section
end

function Window:_chevron(parent, rightOffset)
    local holder = new("Frame", {
        Size = UDim2.fromOffset(10, 6),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -(rightOffset or 8), 0.5, 0),
    }, parent)
    self:Make("Frame", { Size = UDim2.fromOffset(7, 2), Position = UDim2.fromOffset(0, 2), Rotation = 40 }, holder, { BackgroundColor3 = "Muted" })
    self:Make("Frame", { Size = UDim2.fromOffset(7, 2), Position = UDim2.fromOffset(4, 2), Rotation = -40 }, holder, { BackgroundColor3 = "Muted" })
    return holder
end

function Section:_nextOrder(keepGrid)
    self._order = self._order + 1
    if not keepGrid then
        self._grid = nil
    end
    return self._order
end

function Section:_rowParent(gridItem)
    if not gridItem or self.Columns <= 1 then
        return self.Content
    end
    if not self._grid then
        local metrics = self.Window.Metrics
        local holder = new("Frame", {
            Name = "Grid",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = self:_nextOrder(true),
        }, self.Content)
        local record = {
            Frame = holder,
            List = addList(holder, metrics.Gap),
            Grid = new("UIGridLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                CellPadding = UDim2.fromOffset(metrics.Gap, metrics.Gap),
                CellSize = UDim2.new(0.5, -metrics.Gap / 2, 0, metrics.RowTall),
            }),
        }
        table.insert(self._grids, record)
        self._grid = record
        self:_styleGrid(record, self._appliedColumns or 1)
    end
    return self._grid.Frame
end

function Section:_styleGrid(record, columns)
    local metrics = self.Window.Metrics
    if columns > 1 then
        local gap = metrics.Gap
        record.Grid.CellSize = UDim2.new(1 / columns, -math.ceil(gap * (columns - 1) / columns), 0, metrics.RowTall)
        record.List.Parent = nil
        record.Grid.Parent = record.Frame
    else
        record.Grid.Parent = nil
        record.List.Parent = record.Frame
    end
end

function Section:_applyColumns()
    local window = self.Window
    local metrics = window.Metrics
    local width = self.Frame.AbsoluteSize.X / window.Scale.Scale
    local minimum = metrics.Touch and 200 or 160
    local columns = 1
    if self.Columns > 1 and width - metrics.PanelPad * 2 >= minimum * self.Columns + metrics.Gap * (self.Columns - 1) then
        columns = self.Columns
    end
    if columns == self._appliedColumns then
        return
    end
    self._appliedColumns = columns
    for _, record in ipairs(self._grids) do
        self:_styleGrid(record, columns)
    end
end

function Section:_track(frame, getText)
    local item = { Frame = frame, GetText = getText, Hidden = false, Filtered = false, Section = self }
    function item:Refresh()
        local section = self.Section
        local collapsed = section.Collapsed and section.Window.SearchQuery == ""
        self.Frame.Visible = not self.Hidden and not self.Filtered and not collapsed
    end
    table.insert(self._items, item)
    item:Refresh()
    return item
end

function Section:_untrack(item)
    local index = table.find(self._items, item)
    if index then
        table.remove(self._items, index)
    end
end

function Section:SetCollapsed(collapsed)
    self.Collapsed = collapsed == true
    for _, item in ipairs(self._items) do
        item:Refresh()
    end
    if self.Chevron then
        self.Window:Tween(self.Chevron, { Rotation = self.Collapsed and -90 or 0 }, 0.2)
    end
end

function Section:_applyVisibility()
    local visible = self._searchVisible ~= false
    if self.Category and not self.Category.Selected and self.Window.SearchQuery == "" then
        visible = false
    end
    self.Frame.Visible = visible
end

function Section:ApplySearch(query)
    local titleMatch = query ~= "" and self.Title ~= nil and string.find(string.lower(self.Title), query, 1, true) ~= nil
    local shown = 0
    for _, item in ipairs(self._items) do
        local match = query == "" or titleMatch
        if not match and item.GetText then
            local text = item.GetText()
            match = text ~= nil and string.find(string.lower(text), query, 1, true) ~= nil
        end
        item.Filtered = not match
        item:Refresh()
        if match and not item.Hidden then
            shown = shown + 1
        end
    end
    self._searchVisible = query == "" or shown > 0
    self:_applyVisibility()
end

function Tab:ApplySearch(query)
    for _, side in ipairs({ "Left", "Right" }) do
        for _, section in ipairs(self.Sections[side]) do
            section:ApplySearch(query)
        end
    end
end

function Window:_addHistory(options)
    local history = self._notifHistory
    table.insert(history, 1, {
        Title = options.Title or "",
        Content = options.Content or "",
        Type = options.Type,
        Time = os.date("%H:%M"),
    })
    if #history > 30 then
        table.remove(history)
    end
    self._unread = self._unread + 1
    if self._bellDot then
        self._bellDot.Visible = true
    end
end

function Window:_buildNotifications()
    local metrics = self.Metrics
    local panel = self:Glass(self.Overlay, "Panel", { Name = "Notifications", Visible = false, ZIndex = 2 })
    panel.BackgroundTransparency = 0.04
    local header = new("Frame", { Size = UDim2.new(1, 0, 0, 34) }, panel)
    self:Make("TextLabel", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Text = "Notifications",
        Font = "Semi",
        TextSize = metrics.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    local clear = self:Make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(54, 22),
        Text = "Clear",
        Font = "Semi",
        TextSize = metrics.Small,
        Color = "Accent",
    }, header)
    self:Make("Frame", {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    }, panel, { BackgroundColor3 = "Outline", BackgroundTransparency = "TransStroke" })
    local list = self:Make("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 1, -36),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = metrics.ScrollBar,
    }, panel, { ScrollBarImageColor3 = "Accent" })
    addPadding(list, 8)
    addList(list, 6)
    self._notifPanel = panel
    self._notifList = list
    self:Connect(clear.Activated, function()
        self._notifHistory = {}
        self:_rebuildNotifications()
    end)
end

function Window:_rebuildNotifications()
    if not self._notifPanel then
        self:_buildNotifications()
    end
    local metrics = self.Metrics
    for _, child in ipairs(self._notifList:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    if #self._notifHistory == 0 then
        self:Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 40),
            Text = "No notifications yet",
            TextSize = metrics.Small + 1,
            Muted = true,
        }, self._notifList)
        return
    end
    for index, entry in ipairs(self._notifHistory) do
        local typeToken = ({ Success = "Success", Warning = "Warning", Error = "Danger" })[entry.Type] or "Accent"
        local item = self:Glass(self._notifList, "Field", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = index,
        })
        local bar = self:Make("Frame", { Size = UDim2.new(0, 3, 1, -12), Position = UDim2.fromOffset(6, 6) }, item, { BackgroundColor3 = typeToken })
        new("UICorner", { CornerRadius = self.Tokens.RadPill }, bar)
        local body = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, item)
        addPadding(body, 7, 10, 8, 16)
        addList(body, 1)
        self:Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Text = (entry.Title ~= "" and entry.Title or "Notice") .. "  " .. entry.Time,
            Font = "Semi",
            TextSize = metrics.Small + 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = 1,
        }, body)
        if entry.Content ~= "" then
            self:Make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Text = entry.Content,
                TextSize = metrics.Small,
                TextWrapped = true,
                Muted = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                LayoutOrder = 2,
            }, body)
        end
    end
end

function Window:ToggleNotifications()
    if self._notifPanel and self._notifPanel.Visible then
        self:_closePopup()
        return
    end
    self:_rebuildNotifications()
    self._unread = 0
    if self._bellDot then
        self._bellDot.Visible = false
    end
    self:_showPopup(self._notifPanel, self.BellButton, Vector2.new(self.Metrics.Touch and 230 or 240, 260))
end

function Window:SetSearch(text)
    self.SearchQuery = string.lower(tostring(text or ""))
    for _, tab in ipairs(self.AllTabs) do
        tab:ApplySearch(self.SearchQuery)
    end
end

local function attachControl(row, instance, order)
    if order then
        instance.LayoutOrder = order
    else
        instance.LayoutOrder = row.AttachOrder
        row.AttachOrder = row.AttachOrder - 1
    end
    instance.Parent = row.Attach
end

local function setRowDisabled(row, disabled)
    if not row.Cover then
        row.Cover = row.Window:Make("TextButton", {
            Name = "Cover",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.5,
            ZIndex = 20,
            Visible = false,
        }, row.Frame)
        row.Window:Corner(row.Cover, "RadCard")
    end
    row.Cover.Visible = disabled == true
end

function Window:_ripple(frame, input)
    if not self.Effects.Ripple then
        return
    end
    local scale = self.Scale.Scale
    local x = (input.Position.X - frame.AbsolutePosition.X) / scale
    local width = frame.AbsoluteSize.X / scale
    local ring = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, x, 0.5, 0),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.8,
        Rotation = self.Style.Gamer and 45 or 0,
        ZIndex = 2,
    }, frame)
    new("UICorner", { CornerRadius = self.Tokens.RadPill }, ring)
    local diameter = math.max(width, 80) * 1.7
    self:Tween(ring, { Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1 }, 0.6, Enum.EasingStyle.Quad)
    task.delay(0.65, function()
        ring:Destroy()
    end)
end

function Window:_wireRow(row)
    local frame = row.Frame
    local hovered = false
    local pressed = false
    local function apply()
        local tokens = self.Tokens
        local transparency = tokens.TransCard
        if pressed then
            transparency = math.min(1, transparency + 0.2)
        elseif hovered then
            transparency = math.min(transparency, 0.55)
        end
        self:Motion(pressed and "Press" or "Hover", frame, {
            BackgroundColor3 = hovered and tokens.Hover or tokens.Surface,
            BackgroundTransparency = transparency,
        })
        local strokeColor = tokens.Outline
        local strokeTransparency = tokens.TransStroke
        if row.Active then
            strokeColor = tokens.Accent
            strokeTransparency = 0.4
        end
        if hovered and self.Style.Glow then
            strokeColor = tokens.Accent
            strokeTransparency = 0.15
        end
        self:Motion("Hover", row.Stroke, { Color = strokeColor, Transparency = strokeTransparency })
        if row.Bar then
            self:Motion("Hover", row.Bar, { BackgroundTransparency = row.Active and 0 or (hovered and 0.2 or 0.55) })
        end
    end
    row.Refresh = apply
    self:Connect(row.Click.MouseEnter, function()
        hovered = true
        apply()
    end)
    self:Connect(row.Click.MouseLeave, function()
        hovered = false
        pressed = false
        apply()
    end)
    if row.Clickable then
        self:Connect(row.Click.MouseButton1Down, function()
            pressed = true
            apply()
        end)
        self:Connect(row.Click.MouseButton1Up, function()
            pressed = false
            apply()
        end)
        self:Connect(row.Click.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            self:_ripple(frame, input)
            if row.Element and row.Element.BindId and UserInputService.KeyboardEnabled then
                row._press = (row._press or 0) + 1
                local token = row._press
                task.delay(0.6, function()
                    if row._press == token and not self.Destroyed then
                        row._suppress = true
                        self:_listen(row.Element)
                        task.delay(0.5, function()
                            row._suppress = false
                        end)
                    end
                end)
            end
        end)
        self:Connect(row.Click.InputEnded, function()
            row._press = (row._press or 0) + 1
        end)
    end
end

local function createRow(section, options, mode, gridItem)
    local window = section.Window
    local metrics = window.Metrics
    local plain = mode == "Plain"
    local row = { Window = window, Section = section, Options = options, AttachOrder = 100, Plain = plain, TextX = 12 }
    local rowOrder = section:_nextOrder(gridItem == true)
    local frame = window:Make("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, plain and metrics.SliderHeight or metrics.Row),
        LayoutOrder = rowOrder,
        ClipsDescendants = true,
    }, section:_rowParent(gridItem == true), { BackgroundColor3 = "Surface", BackgroundTransparency = "TransCard" })
    window:Corner(frame, "RadCard")
    row.Stroke = window:Stroke(frame)
    window:GlassEdge(row.Stroke)
    window:Make("Frame", {
        Name = "Line",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, 0),
        Size = UDim2.new(1, -20, 0, 1),
    }, frame, { BackgroundColor3 = "Outline", BackgroundTransparency = "TransLine" })
    row.Frame = frame
    row.Item = section:_track(frame, function()
        return (row.Title and row.Title.Text or "") .. " " .. (options.Description or "")
    end)
    row.Click = new("TextButton", { Name = "Click", Size = UDim2.fromScale(1, 1) }, frame)
    row.Bar = window:Make("Frame", {
        Name = "Bar",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.new(0, 3, 0.62, 0),
        BackgroundTransparency = 0.55,
        Visible = window.Style.Gamer == true,
        ZIndex = 3,
    }, frame, { BackgroundColor3 = "Accent" })
    if plain then
        window:_onStyle(row, function()
            row.Bar.Visible = window.Style.Gamer == true
        end)
        return row
    end
    local hasIcon = options.Icon ~= nil
    row.Bubble = window:Make("Frame", {
        Name = "Bubble",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(metrics.Bubble, metrics.Bubble),
    }, frame, { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField" })
    window:Corner(row.Bubble, "RadIcon")
    window:Stroke(row.Bubble)
    row.Icon = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(metrics.IconSize, metrics.IconSize),
    }, row.Bubble)
    if hasIcon then
        window:ApplyIcon(row.Icon, options.Icon, "Accent")
    end
    row.Attach = new("Frame", {
        Name = "Attach",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
    }, frame)
    local attachLayout = addList(row.Attach, 6, Enum.FillDirection.Horizontal)
    attachLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    attachLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    row.Block = new("Frame", {
        Name = "Text",
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, frame)
    local blockLayout = addList(row.Block, 1)
    blockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    row.Title = window:Make("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, metrics.Text + 4),
        Text = options.Text or options.Title or "",
        Font = "Semi",
        TextSize = metrics.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 1,
    }, row.Block)
    if options.Description then
        row.Desc = window:Make("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, metrics.Small + 4),
            Text = options.Description,
            Font = "Regular",
            TextSize = metrics.Small,
            Muted = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = 2,
        }, row.Block)
    end
    function row:UpdateBlock()
        local attachWidth = self.Attach.AbsoluteSize.X / window.Scale.Scale
        self.Block.Position = UDim2.new(0, self.TextX, 0.5, 0)
        self.Block.Size = UDim2.new(1, -(self.TextX + attachWidth + 16), 0, 0)
    end
    function row:Relayout()
        local style = window.Style
        self.Bar.Visible = style.Gamer == true
        local showBubble = hasIcon and style.ShowIcons
        self.Bubble.Visible = showBubble
        local tall = options.Description ~= nil or showBubble
        self.Frame.Size = UDim2.new(1, 0, 0, tall and metrics.RowTall or metrics.Row)
        self.TextX = 12 + (showBubble and (metrics.Bubble + 10) or 0)
        self:UpdateBlock()
    end
    window:Connect(row.Attach:GetPropertyChangedSignal("AbsoluteSize"), function()
        row:UpdateBlock()
    end)
    window:_onStyle(row, function()
        row:Relayout()
    end)
    row:Relayout()
    window:_wireRow(row)
    return row
end

local function extendElement(element, row)
    element.Row = row
    row.Element = element
    element._listeners = element._listeners or {}
    function element:OnChanged(listener)
        table.insert(self._listeners, listener)
        return self
    end
    function element:SetVisible(visible)
        row.Item.Hidden = not visible
        row.Item:Refresh()
    end
    function element:SetDisabled(disabled)
        setRowDisabled(row, disabled)
    end
    function element:SetText(text)
        if row.Title then
            row.Title.Text = text
        end
    end
    function element:SetDescription(text)
        if row.Desc then
            row.Desc.Text = text
        end
    end
    function element:Destroy()
        local window = self.Window
        if self.Flag then
            window.Flags[self.Flag] = nil
        end
        window:_unregisterCommand(self)
        window:_offStyle(row)
        window:_offStyle(self)
        if self.BindId then
            local index = table.find(window._quickbinds, self)
            if index then
                table.remove(window._quickbinds, index)
            end
        end
        row.Section:_untrack(row.Item)
        row.Frame:Destroy()
    end
    function element:AddKeybind(options)
        assert(row.Attach, "This element does not support attachments")
        return row.Window:_createKeybind(row, options or {})
    end
    function element:AddColorPicker(options)
        assert(row.Attach, "This element does not support attachments")
        return row.Window:_createColor(row, options or {})
    end
    return element
end

function Window:_makeBindable(row, element, id)
    local metrics = self.Metrics
    element.BindId = id
    element.BindKey = nil
    local chip = self:Make("TextButton", {
        Name = "BindChip",
        Size = UDim2.fromOffset(0, metrics.ControlHeight - 4),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = false,
        TextSize = metrics.Small,
        Font = "Semi",
        Muted = true,
    }, nil, { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField" })
    self:Corner(chip, "RadControl")
    addPadding(chip, 0, 7, 0, 7)
    attachControl(row, chip, 90)
    local function render()
        local listening = self._listening == element
        chip.Visible = listening or element.BindKey ~= nil
        chip.Text = listening and "press a key..." or ("[" .. keyToText(element.BindKey) .. "]")
    end
    element._render = render
    function element:SetKey(key, silent)
        if key ~= nil and typeof(key) ~= "EnumItem" then
            key = nil
        end
        self.BindKey = key
        render()
        if not silent then
            self.Window:_queueAutoSave()
            if key then
                self.Window:TerminalPrint("bound " .. (self.CommandName and ("/" .. self.CommandName) or id) .. " to [" .. keyToText(key) .. "]", "Accent")
            end
        end
    end
    self:Connect(chip.Activated, function()
        self:_listen(element)
    end)
    self:Connect(row.Click.MouseButton2Click, function()
        self:_listen(element)
    end)
    table.insert(self._quickbinds, element)
    local pending = self._pendingBinds[id]
    if pending ~= nil then
        self._pendingBinds[id] = nil
        task.defer(function()
            element:SetKey(deserializeKey(pending), true)
        end)
    end
end

function Window:_listen(element)
    local previous = self._listening
    if previous == element then
        self._listening = nil
        element._render()
        return
    end
    self._listening = element
    if previous and previous._render then
        previous._render()
    end
    element._render()
end

function Section:AddToggle(options)
    if type(options) == "string" then
        options = { Text = options }
    end
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local row = createRow(self, options, nil, true)
    row.Clickable = true
    local toggle = { Type = "Toggle", Window = window, Value = false, Callback = options.Callback }
    extendElement(toggle, row)
    local trackWidth, trackHeight = metrics.ToggleWidth, metrics.ToggleHeight
    local knobSize = trackHeight - 6
    local track = window:Make("Frame", {
        Name = "Switch",
        Size = UDim2.fromOffset(trackWidth, trackHeight),
    }, nil, { BackgroundColor3 = "ToggleOff" })
    window:Corner(track, "RadPill")
    local trackGlow = window:Make("UIStroke", { Thickness = 2, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, track, { Color = "ToggleOn" })
    local fill = window:Make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, track, { BackgroundColor3 = "ToggleOn" })
    fill.BackgroundTransparency = 1
    window:Corner(fill, "RadPill")
    local knob = window:Make("Frame", {
        Size = UDim2.fromOffset(knobSize, knobSize),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
    }, track, { BackgroundColor3 = "Knob" })
    window:Corner(knob, "RadPill")
    local stateText = window:Make("TextLabel", {
        Name = "State",
        Size = UDim2.fromOffset(0, trackHeight),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = "[ ]",
        Font = "Semi",
        TextSize = metrics.Small + 1,
        Color = "ToggleOn",
    }, nil)
    attachControl(row, track, 100)
    attachControl(row, stateText, 100)
    local function render(animate)
        local on = toggle.Value
        local style = window.Style
        local kind = style.ToggleKind
        row.Active = on
        if row.Refresh then
            row.Refresh()
        end
        track.Visible = kind == "Switch"
        stateText.Visible = kind == "Text"
        stateText.Text = on and "[x]" or "[ ]"
        local fillTransparency = on and 0 or 1
        local knobX = on and (trackWidth - knobSize - 3) or 3
        local knobColor = on and Color3.new(1, 1, 1) or window.Tokens.Knob
        local glowTransparency = (on and style.Glow) and 0.45 or 1
        local textTransparency = on and 0 or 0.55
        if animate then
            window:Tween(fill, { BackgroundTransparency = fillTransparency }, 0.2)
            window:Tween(knob, { Position = UDim2.new(0, knobX, 0.5, 0), BackgroundColor3 = knobColor }, 0.25, Enum.EasingStyle.Quint)
            window:Tween(trackGlow, { Transparency = glowTransparency }, 0.2)
            window:Tween(stateText, { TextTransparency = textTransparency }, 0.15)
            window:Tween(knob, { Size = UDim2.fromOffset(knobSize + 4, knobSize) }, 0.08)
            task.delay(0.1, function()
                if knob.Parent then
                    window:Tween(knob, { Size = UDim2.fromOffset(knobSize, knobSize) }, 0.15)
                end
            end)
        else
            fill.BackgroundTransparency = fillTransparency
            knob.Position = UDim2.new(0, knobX, 0.5, 0)
            knob.BackgroundColor3 = knobColor
            trackGlow.Transparency = glowTransparency
            stateText.TextTransparency = textTransparency
        end
    end
    function toggle:Set(value, silent, force)
        value = value == true
        if value == self.Value and not force then
            return
        end
        self.Value = value
        render(true)
        if not silent then
            fire(self, value)
        end
    end
    function toggle:Trigger()
        self:Set(not self.Value)
    end
    function toggle:Serialize()
        return self.Value
    end
    function toggle:Deserialize(value)
        self:Set(value == true, false, true)
    end
    window:Connect(row.Click.Activated, function()
        if row._suppress then
            row._suppress = false
            return
        end
        toggle:Set(not toggle.Value)
    end)
    toggle.Value = options.Default == true
    toggle.DefaultValue = toggle.Value
    function toggle:Reset()
        self:Set(self.DefaultValue, false, true)
    end
    window:_onStyle(toggle, function()
        render(false)
    end)
    render(false)
    if options.NoBind ~= true and options.Internal ~= true then
        window:_makeBindable(row, toggle, options.Flag or ("toggle_" .. slug(options.Text)))
    end
    return window:_register(toggle, options)
end

function Section:AddSlider(options)
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local minimum = options.Min or 0
    local maximum = options.Max or 100
    if maximum <= minimum then
        maximum = minimum + 1
    end
    local step = options.Step or options.Increment or 1
    local decimals = decimalsOf(step)
    local suffix = options.Suffix or ""
    local row = createRow(self, options, "Plain")
    row.Click:Destroy()
    local slider = { Type = "Slider", Window = window, Min = minimum, Max = maximum, Step = step, Value = minimum, Callback = options.Callback }
    extendElement(slider, row)
    row.Title = window:Make("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(12, 4),
        Size = UDim2.new(1, -96, 0, metrics.SliderLabel),
        Text = options.Text or options.Title or "",
        Font = "Semi",
        TextSize = metrics.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row.Frame)
    local valueBox = window:Make("TextBox", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 4),
        Size = UDim2.fromOffset(80, metrics.SliderLabel),
        Font = "Semi",
        TextSize = metrics.Text - 1,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row.Frame, { TextColor3 = "Accent" })
    local trackY = metrics.SliderHeight - metrics.TrackHeight - 10
    local track = window:Make("Frame", {
        Name = "Track",
        Position = UDim2.fromOffset(12, trackY),
        Size = UDim2.new(1, -24, 0, metrics.TrackHeight),
    }, row.Frame, { BackgroundColor3 = "ToggleOff" })
    window:Corner(track, "RadPill")
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1) }, track)
    window:Corner(fill, "RadPill")
    window:Gradient(fill, "Accent", "AccentAlt", 0)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(metrics.KnobSize, metrics.KnobSize),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Rotation = window.Style.Gamer and 45 or 0,
        ZIndex = 2,
    }, track)
    window:Corner(knob, "RadPill")
    window:_onStyle(slider, function()
        knob.Rotation = window.Style.Gamer and 45 or 0
    end)
    local knobGlow = window:Make("UIStroke", { Thickness = 3, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, knob, { Color = "Accent" })
    local hit = new("TextButton", {
        Position = UDim2.fromOffset(0, metrics.SliderLabel + 4),
        Size = UDim2.new(1, 0, 1, -(metrics.SliderLabel + 4)),
        ZIndex = 3,
    }, row.Frame)
    local function snap(value)
        value = math.clamp(value, minimum, maximum)
        value = minimum + math.floor((value - minimum) / step + 0.5) * step
        value = math.clamp(value, minimum, maximum)
        return tonumber(string.format("%." .. decimals .. "f", value))
    end
    local function render()
        local ratio = (slider.Value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.fromScale(ratio, 0.5)
        valueBox.Text = string.format("%." .. decimals .. "f", slider.Value) .. suffix
    end
    function slider:Set(value, silent, force)
        value = snap(tonumber(value) or self.Value)
        if value == self.Value and not force then
            return
        end
        self.Value = value
        render()
        if not silent then
            fire(self, value)
        end
    end
    function slider:Serialize()
        return self.Value
    end
    function slider:Deserialize(value)
        self:Set(value, false, true)
    end
    window:Connect(valueBox.Focused, function()
        valueBox.Text = string.format("%." .. decimals .. "f", slider.Value)
    end)
    window:Connect(valueBox.FocusLost, function()
        local typed = tonumber(string.match(valueBox.Text, "-?%d+%.?%d*"))
        if typed then
            slider:Set(typed)
        end
        render()
    end)
    local page = self.Tab.Page
    window:_trackDrag(hit, function(input)
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return
        end
        local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
        slider:Set(minimum + (maximum - minimum) * ratio)
    end, function()
        page.ScrollingEnabled = false
        window:Tween(knob, { Size = UDim2.fromOffset(metrics.KnobSize + 6, metrics.KnobSize + 6) }, 0.12, Enum.EasingStyle.Quint)
        window:Tween(knobGlow, { Transparency = 0.5 }, 0.12)
    end, function()
        page.ScrollingEnabled = true
        window:Tween(knob, { Size = UDim2.fromOffset(metrics.KnobSize, metrics.KnobSize) }, 0.15)
        window:Tween(knobGlow, { Transparency = 1 }, 0.15)
    end)
    slider.Value = snap(options.Default or minimum)
    slider.DefaultValue = slider.Value
    function slider:Reset()
        self:Set(self.DefaultValue, false, true)
    end
    render()
    return window:_register(slider, options)
end

function Window:_fieldButton(properties, binds)
    local metrics = self.Metrics
    properties.TextSize = properties.TextSize or (metrics.Text - 1)
    local button = self:Make("TextButton", properties, nil, binds or { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField" })
    self:Corner(button, "RadControl")
    self:Stroke(button)
    return button
end

function Section:AddDropdown(options)
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local multi = options.Multi == true
    local row = createRow(self, options)
    local dropdown = {
        Type = "Dropdown",
        Window = window,
        Multi = multi,
        Options = {},
        Value = multi and {} or nil,
        Callback = options.Callback,
    }
    extendElement(dropdown, row)
    local button = window:_fieldButton({
        Name = "Dropdown",
        Size = UDim2.fromOffset(metrics.DropdownWidth, metrics.ControlHeight),
        ClipsDescendants = true,
    })
    local valueLabel = window:Make("TextLabel", {
        Size = UDim2.new(1, -26, 1, 0),
        Position = UDim2.fromOffset(9, 0),
        TextSize = metrics.Text - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, button)
    window:_chevron(button, 8)
    attachControl(row, button)
    local popup = window:Glass(window.Overlay, "Panel", { Name = "DropdownPopup", Visible = false, ZIndex = 2 })
    popup.BackgroundTransparency = 0.04
    local list = window:Make("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = metrics.ScrollBar,
    }, popup, { ScrollBarImageColor3 = "Accent" })
    addPadding(list, 4)
    addList(list, 2)
    local items = {}
    local searchBox = window:Make("TextBox", {
        Name = "Search",
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.new(1, -8, 0, metrics.ItemHeight - 2),
        PlaceholderText = "Search...",
        TextSize = metrics.Text - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
    }, popup, { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField", PlaceholderColor3 = "Muted" })
    window:Corner(searchBox, "RadControl")
    addPadding(searchBox, 0, 8, 0, 8)
    window:Connect(searchBox:GetPropertyChangedSignal("Text"), function()
        local query = string.lower(searchBox.Text)
        for option, item in pairs(items) do
            item.Button.Visible = query == "" or string.find(string.lower(option), query, 1, true) ~= nil
        end
    end)
    local function isSelected(option)
        if multi then
            return table.find(dropdown.Value, option) ~= nil
        end
        return dropdown.Value == option
    end
    local function updateText()
        local empty
        if multi then
            empty = #dropdown.Value == 0
            valueLabel.Text = empty and (options.Placeholder or "None") or table.concat(dropdown.Value, ", ")
        else
            empty = dropdown.Value == nil
            valueLabel.Text = dropdown.Value or options.Placeholder or "Select..."
        end
        valueLabel.TextTransparency = empty and 0.5 or 0
    end
    local function refreshItems()
        for option, item in pairs(items) do
            local selected = isSelected(option)
            item.Label.TextColor3 = selected and window.Tokens.Accent or window.Tokens.Text
            item.Button.BackgroundTransparency = selected and 0.7 or 1
        end
    end
    local function choose(option)
        if multi then
            local selection = {}
            for _, candidate in ipairs(dropdown.Options) do
                local wasOn = table.find(dropdown.Value, candidate) ~= nil
                local isOn = wasOn
                if candidate == option then
                    isOn = not wasOn
                end
                if isOn then
                    table.insert(selection, candidate)
                end
            end
            dropdown:Set(selection)
        else
            dropdown:Set(option)
            window:_closePopup()
        end
    end
    local function rebuild()
        for _, item in pairs(items) do
            item.Button:Destroy()
        end
        items = {}
        for index, option in ipairs(dropdown.Options) do
            local itemButton = window:Make("TextButton", {
                Size = UDim2.new(1, 0, 0, metrics.ItemHeight),
                LayoutOrder = index,
            }, list, { BackgroundColor3 = "Hover" })
            itemButton.BackgroundTransparency = 1
            window:Corner(itemButton, "RadControl")
            local itemLabel = window:Make("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.fromOffset(8, 0),
                Text = option,
                TextSize = metrics.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, itemButton)
            items[option] = { Button = itemButton, Label = itemLabel }
            itemButton.Activated:Connect(function()
                choose(option)
            end)
        end
        refreshItems()
    end
    function dropdown:SetOptions(newOptions)
        self.Options = {}
        for _, option in ipairs(newOptions or {}) do
            table.insert(self.Options, tostring(option))
        end
        if multi then
            local kept = {}
            for _, option in ipairs(self.Options) do
                if table.find(self.Value, option) then
                    table.insert(kept, option)
                end
            end
            self.Value = kept
        elseif self.Value ~= nil and not table.find(self.Options, self.Value) then
            self.Value = nil
        end
        rebuild()
        updateText()
    end
    function dropdown:Set(value, silent, force)
        local newValue
        if multi then
            local lookup = {}
            if type(value) == "table" then
                for _, entry in ipairs(value) do
                    lookup[entry] = true
                end
            elseif type(value) == "string" then
                lookup[value] = true
            end
            newValue = {}
            for _, option in ipairs(self.Options) do
                if lookup[option] then
                    table.insert(newValue, option)
                end
            end
            if not force and sameList(newValue, self.Value) then
                return
            end
        else
            if value ~= nil and not table.find(self.Options, value) then
                return
            end
            if not force and value == self.Value then
                return
            end
            newValue = value
        end
        self.Value = newValue
        updateText()
        refreshItems()
        if not silent then
            fire(self, multi and table.clone(newValue) or newValue)
        end
    end
    function dropdown:Serialize()
        if multi then
            return table.clone(self.Value)
        end
        return self.Value
    end
    function dropdown:Deserialize(value)
        self:Set(value, false, true)
    end
    window:Connect(button.Activated, function()
        if popup.Visible then
            window:_closePopup()
            return
        end
        local useSearch = options.Searchable == true or (options.Searchable == nil and #dropdown.Options > 8)
        local searchHeight = useSearch and (metrics.ItemHeight + 4) or 0
        searchBox.Visible = useSearch
        searchBox.Text = ""
        list.Position = UDim2.fromOffset(0, searchHeight)
        list.Size = UDim2.new(1, 0, 1, -searchHeight)
        local count = math.min(#dropdown.Options, metrics.MaxDropdownItems)
        local height = metrics.ItemHeight + 8
        if count > 0 then
            height = count * metrics.ItemHeight + (count - 1) * 2 + 8
        end
        height = height + searchHeight
        local width = math.max(button.AbsoluteSize.X / window.Scale.Scale, 130)
        refreshItems()
        window:_showPopup(popup, button, Vector2.new(width, height))
    end)
    dropdown:SetOptions(options.Options)
    dropdown:Set(options.Default, true)
    dropdown.DefaultValue = multi and table.clone(dropdown.Value) or dropdown.Value
    function dropdown:Reset()
        self:Set(self.DefaultValue, false, true)
    end
    return window:_register(dropdown, options)
end

function Section:AddTextBox(options)
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local row = createRow(self, options)
    local textbox = { Type = "TextBox", Window = window, Value = options.Default or "", Callback = options.Callback }
    extendElement(textbox, row)
    local box = window:Make("TextBox", {
        Name = "Input",
        Size = UDim2.fromOffset(metrics.InputWidth, metrics.ControlHeight),
        Text = textbox.Value,
        PlaceholderText = options.Placeholder or "",
        TextSize = metrics.Text - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true,
    }, nil, { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField", PlaceholderColor3 = "Muted" })
    window:Corner(box, "RadControl")
    addPadding(box, 0, 8, 0, 8)
    local stroke = window:Stroke(box)
    attachControl(row, box)
    window:Connect(box.Focused, function()
        window:Tween(stroke, { Color = window.Tokens.Accent, Transparency = 0 }, 0.15)
    end)
    window:Connect(box.FocusLost, function(enterPressed)
        window:Tween(stroke, { Color = window.Tokens.Outline, Transparency = window.Tokens.TransStroke }, 0.15)
        textbox.Value = box.Text
        fire(textbox, box.Text, enterPressed)
    end)
    function textbox:Set(text, silent)
        text = tostring(text or "")
        self.Value = text
        box.Text = text
        if not silent then
            fire(self, text, false)
        end
    end
    function textbox:Serialize()
        return self.Value
    end
    function textbox:Deserialize(value)
        self:Set(value, false)
    end
    textbox.DefaultValue = textbox.Value
    function textbox:Reset()
        self:Set(self.DefaultValue, false)
    end
    return window:_register(textbox, options)
end

function Window:_createButtonRow(parent, buttons, layoutOrder, section, transient)
    local metrics = self.Metrics
    local count = #buttons
    local frame = new("Frame", {
        Name = "ButtonRow",
        Size = UDim2.new(1, 0, 0, metrics.ButtonHeight),
        LayoutOrder = layoutOrder or 0,
    }, parent)
    addList(frame, metrics.Gap, Enum.FillDirection.Horizontal)
    local created = {}
    local function connect(signal, callback)
        if transient then
            return signal:Connect(callback)
        end
        return self:Connect(signal, callback)
    end
    for index, definition in ipairs(buttons) do
        local label = definition.Text or definition.Title or "Button"
        local primary = definition.Primary == true
        local holder = self:Make("Frame", {
            Name = "ButtonHolder",
            Size = UDim2.new(1 / count, -math.ceil(metrics.Gap * (count - 1) / count), 1, 0),
            LayoutOrder = index,
            ClipsDescendants = true,
            BackgroundColor3 = primary and Color3.new(1, 1, 1) or nil,
            BackgroundTransparency = primary and 0 or nil,
        }, frame, (not primary) and { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField" } or nil)
        self:Corner(holder, "RadControl")
        local stroke
        if primary then
            self:Gradient(holder, "Accent", "AccentAlt", 0)
            stroke = self:Stroke(holder, "AccentAlt", nil, 1)
        else
            stroke = self:Stroke(holder)
        end
        local text = self:Make("TextLabel", {
            Name = "Label",
            Size = UDim2.fromScale(1, 1),
            Text = self:Display(label),
            Font = "Semi",
            TextSize = metrics.Text,
            TextColor3 = primary and Color3.new(1, 1, 1) or nil,
            ZIndex = 2,
        }, holder)
        local hit = new("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 3 }, holder)
        local hovered = false
        local function rest(motionName)
            local tokens = self.Tokens
            if primary then
                self:Motion(motionName, holder, { BackgroundTransparency = hovered and 0.1 or 0 })
            else
                self:Motion(motionName, holder, {
                    BackgroundColor3 = hovered and tokens.Hover or tokens.SurfaceAlt,
                    BackgroundTransparency = tokens.TransField,
                })
                self:Motion(motionName, stroke, {
                    Color = hovered and tokens.Accent or tokens.Outline,
                    Transparency = hovered and 0.45 or tokens.TransStroke,
                })
            end
        end
        connect(hit.MouseEnter, function()
            hovered = true
            rest("Hover")
        end)
        connect(hit.MouseLeave, function()
            hovered = false
            rest("Hover")
        end)
        connect(hit.MouseButton1Down, function()
            self:Motion("Press", holder, { BackgroundTransparency = primary and 0.22 or math.min(1, self.Tokens.TransField + 0.25) })
        end)
        connect(hit.MouseButton1Up, function()
            rest("Press")
        end)
        local element = {
            Type = "Button",
            Window = self,
            Callback = definition.Callback,
            _listeners = {},
            Text = label,
            Button = hit,
            Label = text,
            Holder = holder,
        }
        element._render = function()
            local base = element.Text
            if self._listening == element then
                base = "press a key..."
            elseif element.BindKey then
                base = base .. "  [" .. keyToText(element.BindKey) .. "]"
            end
            text.Text = self:Display(base)
        end
        if not transient then
            self:_onStyle(element, element._render)
        end
        local function run()
            if definition.Callback then
                task.spawn(definition.Callback)
            end
            self:_elementChanged(element)
        end
        function element:Trigger()
            run()
        end
        function element:SetText(newText)
            self.Text = newText
            if self._render then
                self._render()
            else
                text.Text = newText
            end
        end
        function element:SetDisabled(disabled)
            hit.Active = not disabled
            text.TextTransparency = disabled and 0.6 or 0
        end
        connect(hit.Activated, function()
            if element._suppress then
                element._suppress = false
                return
            end
            run()
        end)
        connect(hit.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self:_ripple(holder, input)
            end
        end)
        if definition.NoBind ~= true and definition.Internal ~= true then
            element.BindId = definition.Flag or ("button_" .. slug(label))
            element.BindKey = nil
            function element:SetKey(key, silent)
                if key ~= nil and typeof(key) ~= "EnumItem" then
                    key = nil
                end
                self.BindKey = key
                self._render()
                if not silent then
                    self.Window:_queueAutoSave()
                end
            end
            connect(hit.MouseButton2Click, function()
                self:_listen(element)
            end)
            table.insert(self._quickbinds, element)
            local pending = self._pendingBinds[element.BindId]
            if pending ~= nil then
                self._pendingBinds[element.BindId] = nil
                task.defer(function()
                    element:SetKey(deserializeKey(pending), true)
                end)
            end
        end
        if definition.Internal ~= true and definition.NoBind ~= true then
            self:_registerCommand(element, { Text = label })
        end
        created[index] = element
    end
    return frame, created
end

function Section:AddButtonRow(buttons)
    local frame, created = self.Window:_createButtonRow(self.Content, buttons, self:_nextOrder(), self)
    self:_track(frame, function()
        local parts = {}
        for _, definition in ipairs(buttons) do
            table.insert(parts, definition.Text or definition.Title or "")
        end
        return table.concat(parts, " ")
    end)
    return created
end

function Section:AddButton(options)
    if type(options) == "string" then
        options = { Text = options }
    end
    options = options or {}
    options.Primary = options.Primary
    return self:AddButtonRow({ options })[1]
end

function Section:AddLabel(options)
    if type(options) == "string" then
        options = { Text = options }
    end
    options = options or {}
    local row = createRow(self, options)
    return extendElement({ Type = "Label", Window = self.Window }, row)
end

function Section:AddParagraph(options)
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local frame = new("Frame", {
        Name = "Paragraph",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self:_nextOrder(),
    }, self.Content)
    addList(frame, 2)
    local title
    if options.Title and options.Title ~= "" then
        title = window:Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, metrics.Text + 6),
            Text = options.Title,
            Font = "Semi",
            TextSize = metrics.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }, frame)
    end
    local content = window:Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = options.Content or options.Text or "",
        TextSize = metrics.Text - 1,
        TextWrapped = true,
        Muted = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = options.RichText == true,
        LayoutOrder = 2,
    }, frame)
    local item = self:_track(frame, function()
        return (options.Title or "") .. " " .. content.Text
    end)
    return {
        Type = "Paragraph",
        SetText = function(_, text)
            content.Text = text
        end,
        SetTitle = function(_, text)
            if title then
                title.Text = text
            end
        end,
        SetVisible = function(_, visible)
            item.Hidden = not visible
            item:Refresh()
        end,
        Destroy = function()
            self:_untrack(item)
            frame:Destroy()
        end,
    }
end

function Section:AddDivider(options)
    if type(options) == "string" then
        options = { Text = options }
    end
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local hasText = options.Text and options.Text ~= ""
    local frame = new("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, hasText and (metrics.Text + 8) or 6),
        LayoutOrder = self:_nextOrder(),
    }, self.Content)
    window:Make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.new(1, 0, 0, 1),
    }, frame, { BackgroundColor3 = "Outline", BackgroundTransparency = "TransStroke" })
    if hasText then
        local label = window:Make("TextLabel", {
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = options.Text,
            TextSize = metrics.Text - 1,
            Font = "Semi",
            Muted = true,
        }, frame, { BackgroundColor3 = "Surface" })
        label.BackgroundTransparency = 0
        addPadding(label, 0, 6, 0, 6)
    end
    local item = self:_track(frame, nil)
    return {
        Type = "Divider",
        SetVisible = function(_, visible)
            item.Hidden = not visible
            item:Refresh()
        end,
        Destroy = function()
            self:_untrack(item)
            frame:Destroy()
        end,
    }
end

function Section:AddImage(options)
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local height = options.Height or (metrics.Touch and 110 or 130)
    local frame = window:Glass(self.Content, "Card", {
        Name = "Image",
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = self:_nextOrder(),
        ClipsDescendants = true,
    })
    local image = new("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        ScaleType = options.Fit and Enum.ScaleType.Fit or Enum.ScaleType.Crop,
        ZIndex = 1,
    }, frame)
    window:Corner(image, "RadCard")
    window:ApplyImage(image, options.Image or options.Source)
    local caption
    if options.Caption then
        local shade = window:Make("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.4,
            ZIndex = 2,
        }, frame)
        caption = window:Make("TextLabel", {
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Text = options.Caption,
            Font = "Semi",
            TextSize = metrics.Text + 1,
            TextColor3 = Color3.new(1, 1, 1),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3,
        }, shade)
    end
    local item = self:_track(frame, function()
        return options.Caption or ""
    end)
    return {
        Type = "Image",
        SetImage = function(_, source)
            window:ApplyImage(image, source)
        end,
        SetVisible = function(_, visible)
            item.Hidden = not visible
            item:Refresh()
        end,
        Destroy = function()
            self:_untrack(item)
            frame:Destroy()
        end,
    }
end

function Section:AddCard(options)
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local height = options.Height or metrics.CardHeight
    local imageShare = 0.42
    local buttonWidth = options.Button and (metrics.Touch and 92 or 76) or 0
    local frame = window:Glass(self.Content, "Card", {
        Name = "Card",
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = self:_nextOrder(),
        ClipsDescendants = true,
    })
    frame.BackgroundTransparency = math.min(window.Tokens.TransCard, 0.5)
    local image = new("ImageLabel", {
        Size = UDim2.fromScale(imageShare, 1),
        ScaleType = Enum.ScaleType.Crop,
    }, frame)
    window:Corner(image, "RadCard")
    window:ApplyImage(image, options.Image)
    local fade = window:Make("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(imageShare, 0, 0, 0),
        Size = UDim2.new(0, 70, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, frame)
    local fadeGradient = window:Gradient(fade, "Surface", "Surface", 0)
    fadeGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.05) })
    local text = new("Frame", {
        Position = UDim2.new(imageShare, 8, 0, 0),
        Size = UDim2.new(1 - imageShare, -20, 1, 0),
    }, frame)
    addPadding(text, 10, 0, 10, 0)
    addList(text, 3)
    window:Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, metrics.Text + 6),
        Text = options.Title or "",
        Font = "Bold",
        TextSize = metrics.Text + 3,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 1,
    }, text)
    window:Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, (metrics.Small + 3) * 2),
        Text = options.Description or "",
        TextSize = metrics.Small,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Muted = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2,
    }, text)
    if options.Tags and #options.Tags > 0 then
        local tagRow = new("Frame", { Size = UDim2.new(1, -(buttonWidth + 8), 0, 18), ClipsDescendants = true, LayoutOrder = 3 }, text)
        addList(tagRow, 6, Enum.FillDirection.Horizontal)
        for index, tag in ipairs(options.Tags) do
            local pill = window:Glass(tagRow, "Field", {
                Size = UDim2.fromOffset(0, 18),
                AutomaticSize = Enum.AutomaticSize.X,
                LayoutOrder = index,
            })
            window:Corner(pill, "RadPill")
            addPadding(pill, 0, 8, 0, 8)
            window:Make("TextLabel", {
                Size = UDim2.fromOffset(0, 18),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = tag,
                TextSize = metrics.Small,
            }, pill)
        end
    end
    local button
    if options.Button then
        local holder = new("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -10, 1, -10),
            Size = UDim2.fromOffset(buttonWidth, metrics.ButtonHeight),
            ZIndex = 5,
        }, frame)
        local _, created = window:_createButtonRow(holder, {
            { Text = options.Button, Primary = true, Callback = options.Callback, NoBind = options.NoBind, Flag = options.Flag },
        }, 1, self)
        button = created[1]
    end
    local item = self:_track(frame, function()
        return (options.Title or "") .. " " .. (options.Description or "")
    end)
    return {
        Type = "Card",
        Button = button,
        SetVisible = function(_, visible)
            item.Hidden = not visible
            item:Refresh()
        end,
        Destroy = function()
            self:_untrack(item)
            frame:Destroy()
        end,
    }
end

function Section:AddChangelog(entries)
    local window = self.Window
    local metrics = window.Metrics
    local rowHeight = metrics.Small + 14
    local frame = new("Frame", {
        Name = "Changelog",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self:_nextOrder(),
    }, self.Content)
    addList(frame, 0)
    entries = entries or {}
    for index, entry in ipairs(entries) do
        local line = new("Frame", { Size = UDim2.new(1, 0, 0, rowHeight), LayoutOrder = index }, frame)
        window:Make("TextLabel", {
            Position = UDim2.fromOffset(2, 0),
            Size = UDim2.fromOffset(36, rowHeight),
            Text = entry.Version or "",
            Font = "Semi",
            TextSize = metrics.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, line)
        window:Make("TextLabel", {
            Position = UDim2.fromOffset(42, 0),
            Size = UDim2.new(1, -(42 + 62), 1, 0),
            Text = entry.Text or "",
            TextSize = metrics.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, line)
        window:Make("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -2, 0, 0),
            Size = UDim2.fromOffset(60, rowHeight),
            Text = entry.Date or "",
            TextSize = metrics.Small - 1,
            Muted = true,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, line)
        if index < #entries then
            window:Make("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 1),
            }, line, { BackgroundColor3 = "Outline", BackgroundTransparency = "TransStroke" })
        end
    end
    local item = self:_track(frame, nil)
    return {
        Type = "Changelog",
        Destroy = function()
            self:_untrack(item)
            frame:Destroy()
        end,
    }
end

function Section:AddPromo(options)
    options = options or {}
    local window = self.Window
    local metrics = window.Metrics
    local height = options.Height or (metrics.Touch and 112 or 118)
    local frame = window:Glass(self.Content, "Card", {
        Name = "Promo",
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = self:_nextOrder(),
        ClipsDescendants = true,
    })
    local art = new("Frame", { Name = "Art", Size = UDim2.fromScale(1, 1), ClipsDescendants = true }, frame)
    window:_createLiquid(art, LIQUID_PROMO, { Page = self.Tab.Page })
    for _, rotation in ipairs({ 0, 90 }) do
        local shade = new("Frame", {
            Name = "Shade",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            ZIndex = 2,
        }, art)
        new("UIGradient", {
            Rotation = rotation,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.55),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, shade)
    end
    local content = new("Frame", { Name = "Content", Size = UDim2.fromScale(1, 1), ZIndex = 3 }, frame)
    local layout = addList(content, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    local logo = window:Make("Frame", {
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = Color3.new(1, 1, 1),
        LayoutOrder = 1,
    }, content)
    window:Corner(logo, "RadControl")
    window:Gradient(logo, "Accent", "AccentAlt", 45)
    local letter = window:Make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        Text = string.upper(string.sub(window.Title, 1, 1)),
        Font = "Bold",
        TextSize = 18,
        TextColor3 = Color3.new(1, 1, 1),
    }, logo)
    local image = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ImageColor3 = Color3.new(1, 1, 1),
    }, logo)
    window:ApplyIcon(image, options.Icon or window.Icon or "sparkles", nil, function()
        letter.Visible = false
    end)
    window:Make("TextLabel", {
        Size = UDim2.new(0.86, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = options.Title or "Built for a better experience.",
        Font = "Semi",
        TextSize = metrics.Text + 1,
        TextWrapped = true,
        LayoutOrder = 2,
    }, content)
    window:Make("TextLabel", {
        Size = UDim2.new(0.86, 0, 0, metrics.Small + 4),
        Text = options.Subtitle or window.Title,
        TextSize = metrics.Small,
        Muted = true,
        LayoutOrder = 3,
    }, content)
    local item = self:_track(frame, nil)
    return {
        Type = "Promo",
        SetVisible = function(_, visible)
            item.Hidden = not visible
            item:Refresh()
        end,
        Destroy = function()
            self:_untrack(item)
            frame:Destroy()
        end,
    }
end

function Section:AddKeybind(options)
    options = options or {}
    local row = createRow(self, options)
    local keybind = self.Window:_createKeybind(row, options)
    keybind.OwnsRow = true
    return keybind
end

function Section:AddColorPicker(options)
    options = options or {}
    local row = createRow(self, options)
    local picker = self.Window:_createColor(row, options)
    picker.OwnsRow = true
    return picker
end

function Window:_createKeybind(row, options)
    local metrics = self.Metrics
    local keybind = {
        Type = "Keybind",
        Window = self,
        Row = row,
        Mode = options.Mode or "Press",
        State = false,
        Key = nil,
        Value = nil,
        Callback = options.Callback,
        _listeners = {},
        _changed = {},
    }
    if options.OnChanged then
        table.insert(keybind._changed, options.OnChanged)
    end
    local button = self:_fieldButton({
        Name = "Keybind",
        Size = UDim2.fromOffset(0, metrics.ControlHeight),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = "None",
        TextSize = metrics.Text - 1,
    })
    addPadding(button, 0, 9, 0, 9)
    new("UISizeConstraint", { MinSize = Vector2.new(metrics.Touch and 58 or 48, 0) }, button)
    attachControl(row, button)
    keybind.Button = button
    local function render()
        local listening = self._listening == keybind
        button.Text = listening and "..." or keyToText(keybind.Key)
        button.TextColor3 = listening and self.Tokens.Accent or self.Tokens.Text
    end
    keybind._render = render
    function keybind:SetKey(key, silent)
        if key ~= nil and typeof(key) ~= "EnumItem" then
            key = nil
        end
        self.Key = key
        self.Value = key
        self.State = false
        render()
        if not silent then
            for _, listener in ipairs(self._changed) do
                task.spawn(listener, key)
            end
            self.Window:_queueAutoSave()
        end
    end
    function keybind:OnChanged(listener)
        table.insert(self._changed, listener)
        return self
    end
    function keybind:Serialize()
        return serializeKey(self.Key)
    end
    function keybind:Deserialize(value)
        self:SetKey(deserializeKey(value))
    end
    function keybind:SetVisible(visible)
        if self.OwnsRow then
            row.Item.Hidden = not visible
            row.Item:Refresh()
        else
            button.Visible = visible
        end
    end
    function keybind:SetDisabled(disabled)
        setRowDisabled(row, disabled)
    end
    function keybind:SetText(text)
        if row.Title then
            row.Title.Text = text
        end
    end
    function keybind:Destroy()
        local index = table.find(self.Window._keybinds, self)
        if index then
            table.remove(self.Window._keybinds, index)
        end
        if self.Flag then
            self.Window.Flags[self.Flag] = nil
        end
        self.Window:_unregisterCommand(self)
        if self.OwnsRow then
            row.Section:_untrack(row.Item)
            row.Frame:Destroy()
        else
            button:Destroy()
        end
    end
    self:Connect(button.Activated, function()
        self:_listen(keybind)
    end)
    table.insert(self._keybinds, keybind)
    keybind.DefaultValue = options.Default
    function keybind:Reset()
        self:SetKey(self.DefaultValue)
    end
    if options.Default then
        keybind:SetKey(options.Default, true)
    else
        render()
    end
    return self:_register(keybind, options)
end

function Window:_createColor(row, options)
    local metrics = self.Metrics
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local picker = {
        Type = "ColorPicker",
        Window = self,
        Row = row,
        Value = default,
        Callback = options.Callback,
        _listeners = {},
    }
    local hue, saturation, value = default:ToHSV()
    local swatch = new("TextButton", {
        Name = "Swatch",
        Size = UDim2.fromOffset(metrics.SwatchWidth, metrics.SwatchHeight),
        BackgroundColor3 = default,
    }, nil)
    self:Corner(swatch, "RadControl")
    self:Stroke(swatch)
    attachControl(row, swatch)
    picker.Button = swatch
    local pad = 8
    local popupWidth = metrics.PopupWidth
    local popupHeight = pad * 2 + metrics.ControlHeight + metrics.BarHeight * 3 + pad * 3
    local popup = self:Glass(self.Overlay, "Panel", { Name = "ColorPopup", Visible = false, ZIndex = 2 })
    popup.BackgroundTransparency = 0.04
    addPadding(popup, pad)
    addList(popup, pad)
    local hexBox = self:Make("TextBox", {
        Size = UDim2.new(1, 0, 0, metrics.ControlHeight),
        PlaceholderText = "#RRGGBB",
        TextSize = metrics.Text - 1,
        LayoutOrder = 1,
    }, popup, { BackgroundColor3 = "SurfaceAlt", BackgroundTransparency = "TransField", PlaceholderColor3 = "Muted" })
    self:Corner(hexBox, "RadControl")
    self:Stroke(hexBox)
    local function createBar(order)
        local bar = new("Frame", {
            Size = UDim2.new(1, 0, 0, metrics.BarHeight),
            LayoutOrder = order,
            BackgroundColor3 = Color3.new(1, 1, 1),
        }, popup)
        self:Corner(bar, "RadPill")
        local gradient = new("UIGradient", {}, bar)
        local marker = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.new(0, 6, 1, 6),
            BackgroundColor3 = Color3.new(1, 1, 1),
            ZIndex = 3,
        }, bar)
        self:Corner(marker, "RadPill")
        new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.3 }, marker)
        local hit = new("TextButton", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.new(1, 0, 1, 10),
            ZIndex = 4,
        }, bar)
        return bar, gradient, marker, hit
    end
    local hueBar, hueGradient, hueMarker, hueHit = createBar(2)
    local saturationBar, saturationGradient, saturationMarker, saturationHit = createBar(3)
    local valueBar, valueGradient, valueMarker, valueHit = createBar(4)
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })
    local function updateVisuals()
        local current = Color3.fromHSV(hue, saturation, value)
        picker.Value = current
        swatch.BackgroundColor3 = current
        hueMarker.Position = UDim2.fromScale(hue, 0.5)
        saturationMarker.Position = UDim2.fromScale(saturation, 0.5)
        valueMarker.Position = UDim2.fromScale(value, 0.5)
        saturationGradient.Color = ColorSequence.new(Color3.fromHSV(hue, 0, value), Color3.fromHSV(hue, 1, value))
        valueGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(hue, saturation, 1))
        if not hexBox:IsFocused() then
            hexBox.Text = "#" .. current:ToHex():upper()
        end
    end
    local function bindBar(hit, bar, apply)
        self:_trackDrag(hit, function(input)
            local width = bar.AbsoluteSize.X
            if width <= 0 then
                return
            end
            apply(math.clamp((input.Position.X - bar.AbsolutePosition.X) / width, 0, 1))
            updateVisuals()
            fire(picker, picker.Value)
        end)
    end
    bindBar(hueHit, hueBar, function(ratio)
        hue = ratio
    end)
    bindBar(saturationHit, saturationBar, function(ratio)
        saturation = ratio
    end)
    bindBar(valueHit, valueBar, function(ratio)
        value = ratio
    end)
    function picker:Set(color, silent)
        if typeof(color) ~= "Color3" then
            return
        end
        hue, saturation, value = color:ToHSV()
        updateVisuals()
        self.Value = color
        swatch.BackgroundColor3 = color
        if not silent then
            fire(self, color)
        end
    end
    function picker:Serialize()
        return self.Value:ToHex()
    end
    function picker:Deserialize(text)
        if type(text) ~= "string" then
            return
        end
        local cleaned = text:gsub("#", "")
        local ok, parsed = pcall(Color3.fromHex, "#" .. cleaned)
        if ok and typeof(parsed) == "Color3" then
            self:Set(parsed)
        end
    end
    function picker:OnChanged(listener)
        table.insert(self._listeners, listener)
        return self
    end
    function picker:SetVisible(visible)
        if self.OwnsRow then
            row.Item.Hidden = not visible
            row.Item:Refresh()
        else
            swatch.Visible = visible
        end
    end
    function picker:SetDisabled(disabled)
        setRowDisabled(row, disabled)
    end
    function picker:SetText(text)
        if row.Title then
            row.Title.Text = text
        end
    end
    function picker:Destroy()
        if self.Flag then
            self.Window.Flags[self.Flag] = nil
        end
        self.Window:_unregisterCommand(self)
        popup:Destroy()
        if self.OwnsRow then
            row.Section:_untrack(row.Item)
            row.Frame:Destroy()
        else
            swatch:Destroy()
        end
    end
    self:Connect(hexBox.FocusLost, function()
        local text = hexBox.Text:gsub("#", ""):gsub("%s", "")
        if #text == 6 and text:match("^%x+$") then
            local ok, parsed = pcall(Color3.fromHex, "#" .. text)
            if ok and typeof(parsed) == "Color3" then
                picker:Set(parsed)
                return
            end
        end
        updateVisuals()
    end)
    self:Connect(swatch.Activated, function()
        if popup.Visible then
            self:_closePopup()
            return
        end
        self:_showPopup(popup, swatch, Vector2.new(popupWidth, popupHeight))
    end)
    updateVisuals()
    picker.Value = default
    picker.DefaultValue = default
    function picker:Reset()
        self:Set(self.DefaultValue)
    end
    swatch.BackgroundColor3 = default
    return self:_register(picker, options)
end
local TONES = { Text = "Text", Muted = "Muted", Success = "Success", Danger = "Danger", Warning = "Warning", Accent = "Accent" }

function Window:_buildTerminal(body)
    local metrics = self.Metrics
    local terminal = self:Glass(body, "Panel", {
        Name = "Terminal",
        AnchorPoint = Vector2.new(1, 0),
        Visible = false,
    })
    terminal.BackgroundTransparency = 0.06
    self.Terminal = terminal
    local mono = { FontFace = "FontMono" }
    local monoSemi = { FontFace = "FontMonoSemi" }
    local header = new("Frame", { Name = "Header", Size = UDim2.new(1, 0, 0, 30) }, terminal)
    self:Make("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Text = "* perplexity terminal",
        TextSize = metrics.Small + 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Color = "Accent",
    }, header, monoSemi)
    self._caret = self:Make("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.fromOffset(16, 30),
        Text = "_",
        TextSize = metrics.Small + 3,
        Color = "Accent",
    }, header, monoSemi)
    self:Make("Frame", {
        Position = UDim2.new(0, 8, 0, 30),
        Size = UDim2.new(1, -16, 0, 1),
    }, terminal, { BackgroundColor3 = "Outline", BackgroundTransparency = "TransStroke" })
    self.CommandScroll = self:Make("ScrollingFrame", {
        Name = "Commands",
        Position = UDim2.fromOffset(8, 34),
        Size = UDim2.new(1, -16, 0.4, -12),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = metrics.ScrollBar,
    }, terminal, { ScrollBarImageColor3 = "Accent" })
    addList(self.CommandScroll, 1)
    self:Make("Frame", {
        Position = UDim2.new(0, 8, 0.4, 24),
        Size = UDim2.new(1, -16, 0, 1),
    }, terminal, { BackgroundColor3 = "Outline", BackgroundTransparency = "TransStroke" })
    self:Make("TextLabel", {
        Position = UDim2.new(0, 10, 0.4, 4),
        Size = UDim2.new(1, -20, 0, 18),
        Text = "output",
        TextSize = metrics.Small,
        Muted = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, terminal, mono)
    self.LogScroll = self:Make("ScrollingFrame", {
        Name = "Log",
        Position = UDim2.new(0, 8, 0.4, 30),
        Size = UDim2.new(1, -16, 0.6, -(30 + 42)),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = metrics.ScrollBar,
    }, terminal, { ScrollBarImageColor3 = "Accent" })
    addList(self.LogScroll, 2)
    local prompt = self:Glass(terminal, "Field", {
        Name = "Prompt",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 8, 1, -8),
        Size = UDim2.new(1, -16, 0, metrics.ControlHeight + 6),
    })
    self:Make("TextLabel", {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(14, metrics.ControlHeight + 6),
        Text = ">",
        TextSize = metrics.Text,
        Color = "Accent",
    }, prompt, monoSemi)
    self.PromptBox = self:Make("TextBox", {
        Position = UDim2.fromOffset(24, 0),
        Size = UDim2.new(1, -30, 1, 0),
        PlaceholderText = "/help",
        TextSize = metrics.Small + 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true,
    }, prompt, { FontFace = "FontMono", PlaceholderColor3 = "Muted" })
    self:Connect(self.PromptBox.FocusLost, function(enterPressed)
        local text = self.PromptBox.Text
        self.PromptBox.Text = ""
        if enterPressed and text ~= "" then
            self:RunCommand(text)
            if not metrics.Touch then
                self.PromptBox:CaptureFocus()
            end
        end
    end)
    local bannerShown = false
    self._terminalBanner = function()
        if bannerShown then
            return
        end
        bannerShown = true
        self:TerminalPrint("* Welcome to " .. self.Title .. "!", "Accent")
        self:TerminalPrint("  v" .. Library.Version .. "  " .. Library.Author, "Muted")
        self:TerminalPrint("  /help for commands, /list shows every feature", "Muted")
    end
    self:_onStyle("terminal", function()
        for _, entry in ipairs(self.CommandOrder) do
            self:_refreshCommand(entry)
        end
    end)
end

function Window:TerminalPrint(text, tone, rich)
    local scroll = self.LogScroll
    if not scroll or self.Destroyed then
        return
    end
    local token = TONES[tone or "Text"] or "Text"
    local content = rich and text or tostring(text)
    local line = self:Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = content,
        TextSize = self.Metrics.Small + 1,
        TextWrapped = true,
        RichText = rich == true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = self._logCount,
    }, scroll, { FontFace = "FontMono", TextColor3 = token })
    self._logCount = self._logCount + 1
    table.insert(self._logLines, line)
    if #self._logLines > 140 then
        local oldest = table.remove(self._logLines, 1)
        oldest:Destroy()
    end
    if self.Effects.Typewriter and not rich then
        local total = utf8.len(content) or #content
        if total > 1 then
            line.MaxVisibleGraphemes = 0
            task.spawn(function()
                local step = math.max(1, math.floor(total / 22))
                local shown = step
                while shown < total and line.Parent do
                    line.MaxVisibleGraphemes = shown
                    task.wait(0.012)
                    shown = shown + step
                end
                if line.Parent then
                    line.MaxVisibleGraphemes = -1
                end
            end)
        end
    end
    task.defer(function()
        if scroll.Parent then
            scroll.CanvasPosition = Vector2.new(0, 100000)
        end
    end)
    return line
end

function Window:TerminalClear()
    for _, line in ipairs(self._logLines) do
        line:Destroy()
    end
    self._logLines = {}
end

function Window:_describe(element)
    local kind = element.Type
    if kind == "Toggle" then
        return element.Value and "on" or "off"
    elseif kind == "Slider" then
        return tostring(element.Value)
    elseif kind == "Dropdown" then
        if element.Multi then
            return #element.Value > 0 and table.concat(element.Value, ", ") or "none"
        end
        return tostring(element.Value or "none")
    elseif kind == "TextBox" then
        return '"' .. tostring(element.Value) .. '"'
    elseif kind == "ColorPicker" then
        return "#" .. element.Value:ToHex()
    elseif kind == "Keybind" then
        return keyToText(element.Key)
    end
    return "run"
end

function Window:_commandText(entry)
    local accent = hexOf(self.Tokens.Accent)
    local muted = hexOf(self.Tokens.Muted)
    local state = escapeRich(self:_describe(entry.Element))
    if #state > 18 then
        state = string.sub(state, 1, 17) .. "~"
    end
    return string.format('<font color="%s">/%s</font>  <font color="%s">%s</font>', accent, escapeRich(entry.Name), muted, state)
end

function Window:_refreshCommand(entry)
    if entry.Button then
        entry.Button.Text = self:_commandText(entry)
    end
end

function Window:_registerCommand(element, options)
    if options.Internal or not self.CommandScroll then
        return
    end
    local base = slug(options.Text or options.Title or options.Flag)
    local name = base
    local suffix = 2
    while self.Commands[name] do
        name = base .. "_" .. suffix
        suffix = suffix + 1
    end
    local entry = { Name = name, Element = element, Type = element.Type }
    self.Commands[name] = entry
    table.insert(self.CommandOrder, entry)
    element.CommandName = name
    element._commandEntry = entry
    entry.Button = self:Make("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, self.Metrics.Small + 8),
        TextSize = self.Metrics.Small + 1,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = #self.CommandOrder,
    }, self.CommandScroll, { FontFace = "FontMono" })
    self:_refreshCommand(entry)
    self:Connect(entry.Button.Activated, function()
        local kind = element.Type
        if kind == "Toggle" or kind == "Button" then
            element:Trigger()
        else
            self.PromptBox.Text = "/" .. name .. " "
            if not self.Metrics.Touch then
                self.PromptBox:CaptureFocus()
            end
        end
    end)
end

function Window:_unregisterCommand(element)
    local entry = element._commandEntry
    if not entry then
        return
    end
    self.Commands[entry.Name] = nil
    local index = table.find(self.CommandOrder, entry)
    if index then
        table.remove(self.CommandOrder, index)
    end
    if entry.Button then
        entry.Button:Destroy()
    end
    element._commandEntry = nil
end

function Window:_register(element, options)
    element.Flag = options.Flag
    element.Internal = options.Internal == true
    if options.Flag then
        self.Flags[options.Flag] = element
        local pending = self._pending[options.Flag]
        if pending ~= nil then
            self._pending[options.Flag] = nil
            task.defer(function()
                pcall(element.Deserialize, element, pending)
            end)
        end
    end
    self:_registerCommand(element, options)
    return element
end

function Window:_elementChanged(element, ...)
    if element.Type == nil or element.Type == "Keybind" then
        return
    end
    local entry = element._commandEntry
    if entry then
        self:_refreshCommand(entry)
    end
    if element.Flag then
        self:_queueAutoSave()
    end
    if entry then
        self._logTokens[element] = (self._logTokens[element] or 0) + 1
        local token = self._logTokens[element]
        local delay = element.Type == "Slider" and 0.45 or 0.05
        task.delay(delay, function()
            if self._logTokens[element] == token and not self.Destroyed then
                local detail = element.Type == "Button" and "executed" or ("-> " .. self:_describe(element))
                self:TerminalPrint("* /" .. entry.Name .. "  " .. detail, "Muted")
            end
        end)
    end
end

local function splitList(text)
    local parts = {}
    for part in string.gmatch(text, "[^,]+") do
        table.insert(parts, (part:gsub("^%s+", ""):gsub("%s+$", "")))
    end
    return parts
end

function Window:_runFeature(entry, argument)
    local element = entry.Element
    local kind = element.Type
    local lowered = string.lower(argument)
    if kind == "Toggle" then
        if lowered == "on" or lowered == "true" or lowered == "1" or lowered == "enable" then
            element:Set(true)
        elseif lowered == "off" or lowered == "false" or lowered == "0" or lowered == "disable" then
            element:Set(false)
        else
            element:Set(not element.Value)
        end
    elseif kind == "Button" then
        element:Trigger()
    elseif kind == "Slider" then
        local number = tonumber(argument)
        if not number then
            self:TerminalPrint("usage: /" .. entry.Name .. " <number>  (" .. element.Min .. " to " .. element.Max .. ")", "Danger")
            return
        end
        element:Set(number)
    elseif kind == "Dropdown" then
        local wanted = element.Multi and splitList(argument) or { argument }
        local matched = {}
        for _, text in ipairs(wanted) do
            for _, option in ipairs(element.Options) do
                if string.lower(option) == string.lower(text) then
                    table.insert(matched, option)
                end
            end
        end
        if #matched == 0 then
            self:TerminalPrint("options: " .. table.concat(element.Options, ", "), "Warning")
            return
        end
        element:Set(element.Multi and matched or matched[1])
    elseif kind == "TextBox" then
        element:Set(argument)
    elseif kind == "ColorPicker" then
        local cleaned = argument:gsub("#", "")
        local ok, color = pcall(Color3.fromHex, "#" .. cleaned)
        if not ok then
            self:TerminalPrint("usage: /" .. entry.Name .. " #RRGGBB", "Danger")
            return
        end
        element:Set(color)
    elseif kind == "Keybind" then
        element:SetKey(keyFromName(argument))
    end
    self:TerminalPrint("ok  /" .. entry.Name .. "  " .. self:_describe(element), "Success")
end

local Builtins = {}

function Builtins.help(self)
    self:TerminalPrint("commands:", "Accent")
    for _, line in ipairs({
        "/list              show every feature and its state",
        "/<feature> [value] run or change a feature",
        "/save [name]       save the config",
        "/load <name>       load a config",
        "/delete <name>     delete a config",
        "/configs           list saved configs",
        "/autosave [on|off] toggle auto save",
        "/style [name]      show or change the UI style",
        "/binds             list feature keybinds",
        "/clear  /version  /hide",
    }) do
        self:TerminalPrint("  " .. line, "Muted")
    end
end

function Builtins.list(self)
    if #self.CommandOrder == 0 then
        self:TerminalPrint("no features registered yet", "Muted")
        return
    end
    for _, entry in ipairs(self.CommandOrder) do
        self:TerminalPrint(string.format("  /%-18s %s", entry.Name, self:_describe(entry.Element)), "Text")
    end
end

Builtins.features = Builtins.list

function Builtins.clear(self)
    self:TerminalClear()
end

function Builtins.version(self)
    self:TerminalPrint(Library.Name .. " v" .. Library.Version .. " by " .. Library.Author, "Accent")
end

function Builtins.hide(self)
    self:SetVisible(false)
end

function Builtins.save(self, argument)
    local name = argument ~= "" and argument or self.ActiveConfig or "default"
    local ok, result = self:SaveConfig(name)
    self:TerminalPrint(ok and ("saved " .. result) or result, ok and "Success" or "Danger")
    if ok and self._refreshConfigList then
        self._refreshConfigList(result)
    end
end

function Builtins.load(self, argument)
    local ok, result = self:LoadConfig(argument ~= "" and argument or (self.ActiveConfig or ""))
    self:TerminalPrint(ok and "config loaded" or result, ok and "Success" or "Danger")
end

function Builtins.delete(self, argument)
    local ok, result = self:DeleteConfig(argument)
    self:TerminalPrint(ok and ("deleted " .. result) or result, ok and "Success" or "Danger")
    if ok and self._refreshConfigList then
        self._refreshConfigList(nil)
    end
end

function Builtins.configs(self)
    local names = self:ListConfigs()
    self:TerminalPrint(#names > 0 and table.concat(names, ", ") or "no saved configs", "Text")
end

function Builtins.autosave(self, argument)
    local lowered = string.lower(argument)
    if lowered == "on" or lowered == "off" then
        self:SetAutoSave(lowered == "on")
    end
    self:TerminalPrint("auto save " .. (self.AutoSave and "on" or "off"), "Text")
end

function Builtins.style(self, argument)
    if argument == "" then
        for _, info in ipairs(Library:GetStyles()) do
            self:TerminalPrint((info.Id == self.StyleId and "> " or "  ") .. info.Id .. "  (" .. info.Display .. ")", "Text")
        end
        return
    end
    if not self:SetStyle(argument) then
        self:TerminalPrint("unknown style: " .. argument, "Danger")
    end
end

function Builtins.binds(self)
    local count = 0
    for _, element in ipairs(self._quickbinds) do
        if element.BindKey then
            count = count + 1
            self:TerminalPrint("  [" .. keyToText(element.BindKey) .. "]  " .. (element.CommandName and ("/" .. element.CommandName) or element.BindId), "Text")
        end
    end
    if count == 0 then
        self:TerminalPrint("no binds yet, right-click a toggle or button", "Muted")
    end
end

function Window:RunCommand(line)
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    if line == "" then
        return
    end
    self:TerminalPrint("> " .. line, "Accent")
    local body = line:gsub("^/", "")
    local name, argument = body:match("^(%S+)%s*(.*)$")
    if not name then
        return
    end
    name = string.lower(name)
    local builtin = Builtins[name]
    if builtin then
        builtin(self, argument)
        return
    end
    local entry = self.Commands[name]
    if not entry then
        self:TerminalPrint("unknown command: /" .. name .. "  (try /help)", "Danger")
        return
    end
    self:_runFeature(entry, argument)
end

function Window:_handleInputBegan(input)
    local listening = self._listening
    if listening then
        local key
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                key = false
            else
                key = input.KeyCode
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
            key = input.UserInputType
        end
        if key ~= nil then
            self._listening = nil
            listening:SetKey(key or nil)
        end
        return
    end
    if UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == Enum.KeyCode.Escape and (self._dialog or self._popup) then
        if self._dialog then
            self._dialog.Close()
        else
            self:_closePopup()
        end
        return
    end
    if self.MenuKey and inputMatchesKey(input, self.MenuKey) then
        self:Toggle()
    end
    for _, keybind in ipairs(table.clone(self._keybinds)) do
        if keybind.Key and inputMatchesKey(input, keybind.Key) then
            if keybind.Mode == "Hold" then
                keybind.State = true
                fire(keybind, true)
            elseif keybind.Mode == "Toggle" then
                keybind.State = not keybind.State
                fire(keybind, keybind.State)
            else
                fire(keybind)
            end
        end
    end
    for _, element in ipairs(table.clone(self._quickbinds)) do
        if element.BindKey and inputMatchesKey(input, element.BindKey) then
            element:Trigger()
        end
    end
end

function Window:_handleInputEnded(input)
    for _, keybind in ipairs(self._keybinds) do
        if keybind.Mode == "Hold" and keybind.State and inputMatchesKey(input, keybind.Key) then
            keybind.State = false
            fire(keybind, false)
        end
    end
end

function Window:ClearBinds()
    for _, element in ipairs(self._quickbinds) do
        if element.BindKey then
            element:SetKey(nil, true)
        end
    end
    self:_queueAutoSave()
end

function Window:ListBinds()
    local list = {}
    for _, element in ipairs(self._quickbinds) do
        if element.BindKey then
            list[element.BindId] = keyToText(element.BindKey)
        end
    end
    return list
end

function Window:_prepareStorage()
    self.CanSave = filesSupported
    if self.CanSave then
        ensureFolders(self.ConfigPath)
    end
end

function Window:_configFile(name)
    return self.ConfigPath .. "/" .. name .. ".json"
end

function Window:_readConfigText(name)
    if self.CanSave then
        local ok, content = pcall(function()
            local path = self:_configFile(name)
            if isfile(path) then
                return readfile(path)
            end
            return nil
        end)
        if ok then
            return content
        end
        return nil
    end
    return self._memoryConfigs[name]
end

function Window:_readSettings()
    self.Prefs = { Enabled = false, Config = nil, AutoSave = false, Active = nil, Style = nil, Intro = true }
    if not self.CanSave then
        return
    end
    local ok, text = pcall(function()
        local path = self.Folder .. "/settings.json"
        if isfile(path) then
            return readfile(path)
        end
        return nil
    end)
    if not ok or not text then
        return
    end
    local data = decodeJson(text)
    if not data then
        return
    end
    self.Prefs = {
        Enabled = data.Enabled == true,
        Config = type(data.Config) == "string" and data.Config or nil,
        AutoSave = data.AutoSave == true,
        Active = type(data.Active) == "string" and data.Active or nil,
        Style = type(data.Style) == "string" and data.Style or nil,
        Intro = data.Intro ~= false,
    }
end

function Window:_saveSettings()
    if not self.CanSave or not self.Prefs then
        return
    end
    self.Prefs.Style = self.StyleId
    self.Prefs.Active = self.ActiveConfig
    self.Prefs.AutoSave = self.AutoSave
    local payload = HttpService:JSONEncode({
        Enabled = self.Prefs.Enabled,
        Config = self.Prefs.Config,
        AutoSave = self.Prefs.AutoSave,
        Active = self.Prefs.Active,
        Style = self.Prefs.Style,
        Intro = self.Prefs.Intro,
    })
    pcall(writefile, self.Folder .. "/settings.json", payload)
end

function Window:_loadAutoConfig()
    local prefs = self.Prefs
    if prefs.Enabled and prefs.Config then
        local content = self:_readConfigText(prefs.Config)
        local decoded = content and decodeJson(content)
        if decoded then
            self._pending = type(decoded.Flags) == "table" and decoded.Flags or {}
            self._pendingBinds = type(decoded.Binds) == "table" and decoded.Binds or {}
            self._autoloadApplied = prefs.Config
            self.ActiveConfig = prefs.Config
            if decoded.Style and resolveStyle(decoded.Style) then
                self._configStyle = resolveStyle(decoded.Style)
            end
        end
    end
end

function Window:ListConfigs()
    local names = {}
    if self.CanSave then
        local ok, files = pcall(listfiles, self.ConfigPath)
        if ok and type(files) == "table" then
            for _, path in ipairs(files) do
                local name = tostring(path):match("([^/\\]+)%.json$")
                if name then
                    table.insert(names, name)
                end
            end
        end
    else
        for name in pairs(self._memoryConfigs) do
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

function Window:ExportConfig()
    local flags = {}
    for flag, element in pairs(self.Flags) do
        if element.Serialize then
            local value = element:Serialize()
            if value ~= nil then
                flags[flag] = value
            end
        end
    end
    local binds = {}
    for _, element in ipairs(self._quickbinds) do
        if element.BindKey and element.BindId then
            binds[element.BindId] = serializeKey(element.BindKey)
        end
    end
    return HttpService:JSONEncode({ Version = 2, Style = self.StyleId, Flags = flags, Binds = binds })
end

function Window:ApplyConfig(data)
    self._quietUntil = os.clock() + 2.5
    local styleId = resolveStyle(data.Style)
    if styleId and styleId ~= self.StyleId then
        self:SetStyle(styleId, true)
    end
    local flags = type(data.Flags) == "table" and data.Flags or {}
    for flag, value in pairs(flags) do
        local element = self.Flags[flag]
        if element and element.Deserialize then
            pcall(element.Deserialize, element, value)
        else
            self._pending[flag] = value
        end
    end
    local binds = type(data.Binds) == "table" and data.Binds or {}
    for id, keyText in pairs(binds) do
        local applied = false
        for _, element in ipairs(self._quickbinds) do
            if element.BindId == id then
                element:SetKey(deserializeKey(keyText), true)
                applied = true
            end
        end
        if not applied then
            self._pendingBinds[id] = keyText
        end
    end
end

function Window:ImportConfig(text)
    local data = decodeJson(text)
    if not data then
        return false, "Invalid JSON"
    end
    if type(data.Flags) ~= "table" and type(data.Binds) ~= "table" then
        data = { Flags = data }
    end
    self:ApplyConfig(data)
    return true
end

function Window:SaveConfig(name)
    name = sanitizeName(name)
    if name == "" then
        return false, "Enter a config name"
    end
    local json = self:ExportConfig()
    if self.CanSave then
        local ok = pcall(writefile, self:_configFile(name), json)
        if not ok then
            return false, "Could not write the file"
        end
    else
        self._memoryConfigs[name] = json
    end
    self.ActiveConfig = name
    self:_saveSettings()
    return true, name
end

function Window:LoadConfig(name)
    name = sanitizeName(name)
    if name == "" then
        return false, "Select a config"
    end
    local text = self:_readConfigText(name)
    if not text then
        return false, "Config not found"
    end
    local ok, reason = self:ImportConfig(text)
    if ok then
        self.ActiveConfig = name
        self:_saveSettings()
    end
    return ok, reason
end

function Window:DeleteConfig(name)
    name = sanitizeName(name)
    if name == "" then
        return false, "Select a config"
    end
    if self.CanSave then
        local path = self:_configFile(name)
        local exists = false
        pcall(function()
            exists = isfile(path)
        end)
        if not exists then
            return false, "Config not found"
        end
        if not delfile then
            return false, "delfile is not supported"
        end
        if not pcall(delfile, path) then
            return false, "Could not delete the file"
        end
    else
        if not self._memoryConfigs[name] then
            return false, "Config not found"
        end
        self._memoryConfigs[name] = nil
    end
    if self.Prefs.Config == name then
        self:SetAutoLoad(false)
    end
    if self.ActiveConfig == name then
        self.ActiveConfig = nil
        self:_saveSettings()
    end
    return true, name
end

function Window:SetAutoLoad(enabled, name)
    if name ~= nil then
        self.Prefs.Config = sanitizeName(name)
    end
    local hasName = self.Prefs.Config ~= nil and self.Prefs.Config ~= ""
    self.Prefs.Enabled = enabled == true and hasName
    self:_saveSettings()
    return self.Prefs.Enabled
end

function Window:GetAutoLoad()
    return self.Prefs.Enabled, self.Prefs.Config
end

function Window:SetAutoSave(enabled)
    self.AutoSave = enabled == true
    if self._autoSaveToggle then
        self._autoSaveToggle:Set(self.AutoSave, true)
    end
    self:_saveSettings()
end

function Window:_queueAutoSave()
    if not self.AutoSave or self.Destroyed or os.clock() < self._quietUntil then
        return
    end
    self._autoSaveToken = (self._autoSaveToken or 0) + 1
    local token = self._autoSaveToken
    task.delay(2, function()
        if self._autoSaveToken == token and self.AutoSave and not self.Destroyed then
            local ok, name = self:SaveConfig(self.ActiveConfig or "autosave")
            if ok then
                self:Notify({ Title = "Auto Save", Content = name, Type = "Success", Duration = 1.5, Log = false })
                self:TerminalPrint("autosaved " .. name, "Muted")
            end
        end
    end)
end

function Window:FastSave()
    local ok, result = self:SaveConfig(self.ActiveConfig or "default")
    if ok then
        if self._refreshConfigList then
            self._refreshConfigList(result)
        end
        self:Notify({ Title = "Saved", Content = result, Type = "Success", Duration = 2 })
    else
        self:Notify({ Title = "Save failed", Content = result, Type = "Error" })
    end
    return ok, result
end
function Window:_applyEffects()
    self.LiquidLayer.Visible = self.Effects.Liquid and self.Style.Liquid
    self.BorderGradient.Enabled = self.Effects.Border and self.Style.Border
end

function Window:_buildSettings()
    local tab = self:_createTab({ Title = "Settings", Icon = "settings" }, true)
    self.SettingsTab = tab
    local appearance = tab:AddSection({ Title = "Appearance", Icon = "palette", Side = "Left" })
    local displays = {}
    local displayToId = {}
    for _, info in ipairs(Library:GetStyles()) do
        table.insert(displays, info.Display)
        displayToId[info.Display] = info.Id
    end
    self._styleDropdown = appearance:AddDropdown({
        Text = "UI Style",
        Description = "Switch between the 4 looks",
        Icon = "layout-dashboard",
        Options = displays,
        Default = self.Style.Display,
        Flag = "__Style",
        Internal = true,
        Callback = function(display)
            local id = displayToId[display]
            if id and id ~= self.StyleId then
                self:SetStyle(id)
            end
        end,
    })
    self._terminalToggle = appearance:AddToggle({
        Text = "Terminal Panel",
        Description = "Every feature as a command",
        Icon = "terminal",
        Default = self.TerminalVisible,
        Flag = "__Terminal",
        Internal = true,
        Callback = function(visible)
            self:SetTerminalVisible(visible)
        end,
    })
    appearance:AddToggle({
        Text = "Auto Scale",
        Description = "Scale from the screen size",
        Icon = "scaling",
        Default = self.AutoScale,
        Flag = "__AutoScale",
        Internal = true,
        Callback = function(enabled)
            self.AutoScale = enabled
            self:_updateScale()
        end,
    })
    appearance:AddSlider({
        Text = "UI Scale",
        Min = 50,
        Max = 150,
        Step = 5,
        Default = 100,
        Suffix = "%",
        Flag = "__UIScale",
        Internal = true,
        Callback = function(percent)
            self.UserScale = percent / 100
            self:_updateScale()
        end,
    })
    appearance:AddKeybind({
        Text = "Menu Key",
        Icon = "keyboard",
        Default = self.MenuKey,
        Flag = "__MenuKey",
        Internal = true,
        OnChanged = function(key)
            self.MenuKey = key
        end,
    })
    appearance:AddToggle({
        Text = "Background Blur",
        Description = "Frosted glass behind the menu",
        Icon = "droplets",
        Default = self.Effects.Blur,
        Flag = "__fx_blur",
        Internal = true,
        Callback = function(enabled)
            self.Effects.Blur = enabled
            self:_setBlur(self.Visible)
        end,
    })
    local effects = tab:AddSection({ Title = "Effects", Icon = "sparkles", Side = "Left", Collapsed = true })
    local function effectToggle(text, icon, key, flag, after)
        effects:AddToggle({
            Text = text,
            Icon = icon,
            Default = self.Effects[key],
            Flag = flag,
            Internal = true,
            Callback = function(enabled)
                self.Effects[key] = enabled
                if after then
                    after(enabled)
                end
            end,
        })
    end
    effectToggle("Liquid Glass Background", "droplets", "Liquid", "__fx_liquid", function()
        self:_applyEffects()
    end)
    effectToggle("Animated Border", "zap", "Border", "__fx_border", function()
        self:_applyEffects()
    end)
    effectToggle("Click Ripple", "mouse-pointer-click", "Ripple", "__fx_ripple")
    effectToggle("Typewriter Terminal", "terminal", "Typewriter", "__fx_typewriter")
    effectToggle("Rainbow Accent", "rainbow", "Rainbow", "__fx_rainbow", function(enabled)
        self:SetRainbow(enabled)
    end)
    effects:AddToggle({
        Text = "Intro Animation",
        Icon = "play",
        Default = self.Prefs.Intro ~= false,
        Internal = true,
        Callback = function(enabled)
            self.Prefs.Intro = enabled
            self:_saveSettings()
        end,
    })
    local colors = tab:AddSection({ Title = "Colors", Icon = "palette", Side = "Left", Collapsed = true })
    for _, spec in ipairs({
        { "Accent", "Accent" }, { "AccentAlt", "Accent Alt" }, { "Background", "Background" }, { "Surface", "Surface" },
        { "SurfaceAlt", "Surface Alt" }, { "Text", "Text" }, { "Muted", "Muted Text" }, { "Outline", "Outline" },
        { "ToggleOn", "Toggle On" }, { "Success", "Success" }, { "Warning", "Warning" }, { "Danger", "Danger" },
    }) do
        local token = spec[1]
        self._colorPickers[token] = colors:AddColorPicker({
            Text = spec[2],
            Default = self.Tokens[token],
            Flag = "__Color_" .. token,
            Internal = true,
            Callback = function(color)
                self:SetToken(token, color)
            end,
        })
    end
    colors:AddButton({
        Text = "Reset Colors",
        Callback = function()
            self:SetStyle(self.StyleId, true)
            self:Notify({ Title = "Colors", Content = "Style colors restored", Type = "Success" })
        end,
    })
    local config = tab:AddSection({ Title = "Configuration", Icon = "save", Side = "Right" })
    local folderPath = "workspace/" .. self.ConfigPath
    config:AddParagraph({
        Title = "File location",
        Content = self.CanSave and folderPath or "File system not supported here. Configs stay in memory until the UI is unloaded.",
    })
    config:AddButton({
        Text = "Copy Folder Path",
        NoBind = true,
        Internal = true,
        Callback = function()
            if clipboardWriter then
                clipboardWriter(folderPath)
                self:Notify({ Title = "Config", Content = "Folder path copied", Type = "Success" })
            else
                self:Notify({ Title = "Config", Content = folderPath, Type = "Warning" })
            end
        end,
    })
    local nameBox = config:AddTextBox({ Text = "Config Name", Icon = "file-text", Placeholder = "my_config", Internal = true })
    local list = config:AddDropdown({
        Text = "Saved Configs",
        Icon = "folder",
        Options = self:ListConfigs(),
        Default = self.ActiveConfig,
        Placeholder = "Select...",
        Internal = true,
    })
    local autoLabel
    local autoToggle
    local function refreshAutoLabel()
        local enabled, name = self:GetAutoLoad()
        autoLabel:SetText(enabled and ("Auto load: " .. name) or "Auto load: off")
    end
    local function refreshList(selected)
        list:SetOptions(self:ListConfigs())
        if selected then
            list:Set(selected, true)
        end
    end
    self._refreshConfigList = refreshList
    local function targetName(preferBox)
        local boxName = sanitizeName(nameBox.Value)
        if preferBox and boxName ~= "" then
            return boxName
        end
        return list.Value or (boxName ~= "" and boxName or nil)
    end
    local function deleteConfig(name)
        local ok, result = self:DeleteConfig(name)
        if ok then
            refreshList(nil)
            autoToggle:Set(self:GetAutoLoad(), true)
            refreshAutoLabel()
            self:Notify({ Title = "Config", Content = "Deleted " .. result, Type = "Success" })
        else
            self:Notify({ Title = "Config", Content = result, Type = "Error" })
        end
    end
    config:AddButtonRow({
        {
            Text = "Save",
            Internal = true,
            Callback = function()
                local ok, result = self:SaveConfig(targetName(true))
                if ok then
                    refreshList(result)
                    self:Notify({ Title = "Config", Content = "Saved " .. result, Type = "Success" })
                else
                    self:Notify({ Title = "Config", Content = result, Type = "Error" })
                end
            end,
        },
        {
            Text = "Load",
            Internal = true,
            Callback = function()
                local ok, result = self:LoadConfig(targetName(false))
                if ok then
                    self:Notify({ Title = "Config", Content = "Config loaded", Type = "Success" })
                else
                    self:Notify({ Title = "Config", Content = result, Type = "Error" })
                end
            end,
        },
    })
    config:AddButtonRow({
        {
            Text = "Delete",
            Internal = true,
            Callback = function()
                local name = targetName(false)
                if not name then
                    self:Notify({ Title = "Config", Content = "Select a saved config first", Type = "Warning" })
                    return
                end
                self:Dialog({
                    Title = "Delete config",
                    Content = "Delete " .. name .. " permanently?",
                    Buttons = {
                        { Text = "Cancel" },
                        {
                            Text = "Delete",
                            Primary = true,
                            Callback = function()
                                deleteConfig(name)
                            end,
                        },
                    },
                })
            end,
        },
        {
            Text = "Refresh",
            Internal = true,
            Callback = function()
                refreshList(list.Value)
            end,
        },
    })
    config:AddButton({
        Text = "Fast Save",
        Primary = true,
        Flag = "fast_save",
        Callback = function()
            self:FastSave()
        end,
    })
    self._autoSaveToggle = config:AddToggle({
        Text = "Auto Save",
        Description = "Save the active config after every change",
        Icon = "save",
        Default = self.AutoSave,
        Internal = true,
        Callback = function(enabled)
            self:SetAutoSave(enabled)
        end,
    })
    local autoEnabled = self:GetAutoLoad()
    autoToggle = config:AddToggle({
        Text = "Auto Load Config",
        Description = "Load the selected config on startup",
        Icon = "rotate-cw",
        Default = autoEnabled,
        Internal = true,
        Callback = function(enabled)
            if enabled then
                local name = targetName(false)
                if not name then
                    self:Notify({ Title = "Config", Content = "Select a saved config first", Type = "Warning" })
                    autoToggle:Set(false, true)
                    return
                end
                self:SetAutoLoad(true, name)
            else
                self:SetAutoLoad(false)
            end
            refreshAutoLabel()
        end,
    })
    autoLabel = config:AddLabel({ Text = "", Internal = true })
    refreshAutoLabel()
    config:AddDivider({ Text = "Share" })
    config:AddButton({
        Text = "Copy Config as JSON",
        NoBind = true,
        Internal = true,
        Callback = function()
            local json = self:ExportConfig()
            if clipboardWriter then
                clipboardWriter(json)
                self:Notify({ Title = "Config", Content = "Config JSON copied", Type = "Success" })
            else
                self:Notify({ Title = "Config", Content = "Clipboard not supported, JSON placed in the box below", Type = "Warning" })
            end
            self.ImportBox:Set(json, true)
        end,
    })
    self.ImportBox = config:AddTextBox({ Text = "Paste JSON", Icon = "clipboard", Placeholder = "{ ... }", Internal = true })
    config:AddButton({
        Text = "Import JSON",
        NoBind = true,
        Internal = true,
        Callback = function()
            local ok, result = self:ImportConfig(self.ImportBox.Value)
            if ok then
                self:Notify({ Title = "Config", Content = "Config imported", Type = "Success" })
            else
                self:Notify({ Title = "Config", Content = result, Type = "Error" })
            end
        end,
    })
    local binds = tab:AddSection({ Title = "Keybinds", Icon = "keyboard", Side = "Right", Collapsed = true })
    binds:AddParagraph({
        Content = "Right-click (or hold) any toggle or button, then press a key. Sliders and dropdowns can not be bound. Escape clears a bind.",
    })
    binds:AddButtonRow({
        {
            Text = "Show Binds",
            NoBind = true,
            Internal = true,
            Callback = function()
                self:SetTerminalVisible(true)
                self:RunCommand("/binds")
            end,
        },
        {
            Text = "Clear Binds",
            NoBind = true,
            Internal = true,
            Callback = function()
                self:ClearBinds()
                self:Notify({ Title = "Keybinds", Content = "All binds cleared", Type = "Success" })
            end,
        },
    })
    local window = tab:AddSection({ Title = "Window", Icon = "app-window", Side = "Right", Collapsed = true })
    window:AddButtonRow({
        {
            Text = "Reset Defaults",
            NoBind = true,
            Internal = true,
            Callback = function()
                self:Dialog({
                    Title = "Reset to defaults",
                    Content = "Every setting returns to its default value.",
                    Buttons = {
                        { Text = "Cancel" },
                        {
                            Text = "Reset",
                            Primary = true,
                            Callback = function()
                                self:ResetToDefaults()
                                self:Notify({ Title = "Settings", Content = "Defaults restored", Type = "Success" })
                            end,
                        },
                    },
                })
            end,
        },
        {
            Text = "Unload UI",
            NoBind = true,
            Internal = true,
            Callback = function()
                self:Dialog({
                    Title = "Unload UI",
                    Content = "Remove the UI and stop everything it controls?",
                    Buttons = {
                        { Text = "Cancel" },
                        {
                            Text = "Unload",
                            Primary = true,
                            Callback = function()
                                self:Destroy()
                            end,
                        },
                    },
                })
            end,
        },
    })
end

function Window:ResetToDefaults()
    for _, element in pairs(self.Flags) do
        if element.Reset then
            pcall(element.Reset, element)
        end
    end
end

function Window:_buildAbout(options)
    local tab = self:_createTab({ Title = "About", Icon = "info" }, true)
    self.AboutTab = tab
    local main = tab:AddSection({ Title = "Perplexity", Icon = "sparkles", Side = "Left", Collapsible = false })
    main:AddCard({
        Title = Library.Name,
        Description = "Glass UI library with 4 styles, icon packs, image support, built-in configs and a command terminal.",
        Tags = { "v" .. Library.Version, "Glass", "Mobile" },
        Image = options.AboutImage,
        Button = "Copy Credits",
        NoBind = true,
        Callback = function()
            local credits = Library.Name .. " v" .. Library.Version .. " by " .. Library.Author
            if clipboardWriter then
                clipboardWriter(credits)
            end
            self:Notify({ Title = "Credits", Content = credits, Type = "Success" })
        end,
    })
    main:AddParagraph({
        Title = "Credits",
        Content = "Author and polish by " .. Library.Author .. ".",
    })
    local styles = tab:AddSection({ Title = "UI Styles", Icon = "layout-dashboard", Side = "Right" })
    local buttons = {}
    for _, info in ipairs(Library:GetStyles()) do
        table.insert(buttons, {
            Text = info.Display,
            NoBind = true,
            Internal = true,
            Callback = function()
                self:SetStyle(info.Id)
            end,
        })
    end
    styles:AddButtonRow({ buttons[1], buttons[2] })
    styles:AddButtonRow({ buttons[3], buttons[4] })
    local log = tab:AddSection({ Title = "Changelog", Icon = "file-text", Side = "Right" })
    log:AddChangelog({
        { Version = "v3.0.0", Text = "Perplexity Style now have 1 column\nUpgrade OperaGX Style Look\nNew Hook\n "
        { Version = "v2.0.0", Text = "Perplexity: 4 styles, icons, images, terminal", Date = "10/17/2026" },
        { Version = "v1.1.0", Text = "Search, dialogs, resize", Date = "10/16/2026" },
        { Version = "v1.0.0", Text = "UI source and example", Date = "10/15/2026" },
    })
end

function Window:Destroy()
    if self.Destroyed then
        return
    end
    self.Destroyed = true
    self:_cancelDrags()
    self:_cancelTweens()
    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self._connections = {}
    if self.BlurEffect then
        pcall(function()
            self.BlurEffect:Destroy()
        end)
    end
    if self.Gui then
        self.Gui:Destroy()
    end
    local environment = getgenv and getgenv() or _G
    if environment.__PerplexityWindow == self then
        environment.__PerplexityWindow = nil
    end
    if self.OnUnload then
        pcall(self.OnUnload)
    end
end

function Library:CreateWindow(options)
    options = options or {}
    local environment = getgenv and getgenv() or _G
    local previous = environment.__PerplexityWindow
    if previous and previous.Destroy then
        pcall(previous.Destroy, previous)
    end
    local touch = options.Mobile
    if touch == nil then
        touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end
    local metrics = touch and MobileMetrics or DesktopMetrics
    local self = setmetatable({
        Title = options.Title or Library.Name,
        Icon = options.Icon,
        Metrics = metrics,
        Tokens = {},
        Flags = {},
        Tabs = {},
        AllTabs = {},
        Commands = {},
        CommandOrder = {},
        Visible = true,
        Minimized = false,
        SearchQuery = "",
        AutoScale = options.AutoScale ~= false,
        UserScale = 1,
        ReferenceSize = options.ReferenceSize or Vector2.new(1920, 1080),
        MenuKey = options.MenuKey or Enum.KeyCode.RightShift,
        Folder = options.Folder or "Perplexity",
        OnUnload = options.OnUnload,
        DesignSize = options.Size or metrics.Size,
        BaseSize = options.Size or metrics.Size,
        PreferredSize = options.Size or metrics.Size,
        MinSize = touch and Vector2.new(420, 240) or Vector2.new(480, 300),
        Effects = { Liquid = true, Border = true, Ripple = true, Typewriter = true, Rainbow = false, Blur = options.Blur ~= false },
        TerminalVisible = false,
        AutoSave = false,
        _connections = {},
        _bindings = {},
        _gradients = {},
        _styleHooks = {},
        _keybinds = {},
        _quickbinds = {},
        _pending = {},
        _pendingBinds = {},
        _movers = {},
        _drags = {},
        _liquids = {},
        _lines = {},
        _gamerParts = {},
        _liquidClock = 0,
        _claimed = setmetatable({}, { __mode = "k" }),
        _tweens = setmetatable({}, { __mode = "k" }),
        _notifHistory = {},
        _unread = 0,
        _toasts = {},
        _colorPickers = {},
        _memoryConfigs = {},
        _logLines = {},
        _logCount = 1,
        _logTokens = {},
        _time = 0,
        _center = Vector2.new(0.5, 0.5),
        _quietUntil = os.clock() + 2.5,
    }, Window)
    self.ConfigPath = self.Folder .. "/configs"
    self:_prepareStorage()
    self:_readSettings()
    self:_loadAutoConfig()
    local styleId = resolveStyle(self._configStyle) or resolveStyle(self.Prefs.Style) or resolveStyle(options.Style) or "Perplexity"
    self.StyleId = styleId
    self.Style = Styles[styleId]
    self.Tokens = self:_styleTokens(self.Style)
    if options.Theme then
        for token, color in pairs(options.Theme) do
            if COLOR_TOKEN_SET[token] then
                self.Tokens[token] = color
            end
        end
    end
    self.AutoSave = self.Prefs.AutoSave
    self.ActiveConfig = self.ActiveConfig or self.Prefs.Active
    self.TerminalVisible = self.Style.Terminal and not touch
    self:_buildGui(options)
    self:_buildSettings()
    self:_buildAbout(options)
    environment.__PerplexityWindow = self
    if self.TerminalVisible then
        self._terminalBanner()
    end
    if options.Intro ~= false and self.Prefs.Intro ~= false then
        self:_playIntro()
    end
    self:_setBlur(true)
    if self._autoloadApplied then
        task.delay(1.6, function()
            if not self.Destroyed then
                self:Notify({ Title = "Config", Content = "Auto loaded " .. self._autoloadApplied, Type = "Success" })
            end
        end)
    end
    return self
end

Library.new = Library.CreateWindow

return Library
