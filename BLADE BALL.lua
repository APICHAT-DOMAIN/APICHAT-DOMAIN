--[[========================================================
    ⚡ APICHAT DOMAIN ⚡
    v3 - BLADE BALL AUTO PARRY + STARTUP SPLASH LOGO

    เมนู:
    📊 หน้าหลัก | ⚔️ ออโต้ | ⚙️ ตั้งค่า
========================================================]]--

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local StatsService = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

--========================================================
-- CONFIG
--========================================================
local BG_IMAGE = "rbxassetid://73200153325421"
local AUTO_HIT = false
local SPAM_MODE = false
local HIT_RANGE = 25

--========================================================
-- GUI PARENT
--========================================================
local parentGui = (gethui and gethui()) or CoreGui

pcall(function()
    local old = parentGui:FindFirstChild("ApichatDomain")
    if old then old:Destroy() end
end)

--========================================================
-- THEME
--========================================================
local Theme = {
    MainBg = Color3.fromRGB(15, 15, 18),
    PanelBg = Color3.fromRGB(26, 26, 32),
    Accent = Color3.fromRGB(130, 90, 255),
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(170, 170, 170),
    Border = Color3.fromRGB(45, 45, 52),
}

--========================================================
-- LANGUAGE
--========================================================
local lang = "th"

local T = {
    th = {
        welcome = "ยินดีต้อนรับสู่ ⚡ APICHAT DOMAIN",
        menu_home = "หน้าหลัก",
        menu_auto = "ออโต้",
        menu_settings = "ตั้งค่า",

        card_stats = "ข้อมูลผู้เล่น (Stats)",
        card_map = "ข้อมูลแมพ (Map)",
        card_perf = "สถานะระบบ (Perf)",
        card_auto = "ออโต้ตีบอล (Auto Parry)",
        card_lang = "ภาษา (Language)",

        name = "ชื่อ",
        map = "แมพ",
        players = "คนในเซิร์ฟ",

        toggle_auto = "⚔️ เปิดออโต้ตีบอลอัตโนมัติ",
        toggle_spam = "⚡ เปิดโหมดตีรัว (Spam Parry)",
        slider_range = "📏 ระยะตอบสนองลูกบอล",
        
        status_ready = "สถานะออโต้: พร้อมใช้งาน (รอสีแดง)",
        status_hitting = "สถานะออโต้: ตีบอลแล้ว!",

        card_discord = "ดิสคอร์ด (Discord)",
        btn_copy = "📋 คัดลอกลิงก์",
        copied = "✅ คัดลอกแล้ว!",
        copy_fail = "❌ คัดลอกไม่ได้ ลองพิมพ์ลิงก์เอง",

        toggle_afk = "🛡️ กันโดนเตะเมื่อไม่ขยับ (Anti-AFK)",
    },

    en = {
        welcome = "Welcome to ⚡ APICHAT DOMAIN",
        menu_home = "Home",
        menu_auto = "Auto",
        menu_settings = "Settings",

        card_stats = "Player Info (Stats)",
        card_map = "Map Info (Map)",
        card_perf = "System (Perf)",
        card_auto = "Auto Parry",
        card_lang = "Language",

        name = "Name",
        map = "Map",
        players = "Players",

        toggle_auto = "⚔️ Enable Auto Parry",
        toggle_spam = "⚡ Enable Spam Parry Mode",
        slider_range = "📏 Hit Distance Threshold",

        status_ready = "Status: Ready (Waiting Red)",
        status_hitting = "Status: Parrying!",

        card_discord = "Discord",
        btn_copy = "📋 Copy link",
        copied = "✅ Copied!",
        copy_fail = "❌ Could not copy",

        toggle_afk = "🛡️ Anti-AFK",
    },
}

local function tr(key)
    return (T[lang] and T[lang][key]) or key
end

local langHooks = {}
local function onLang(fn)
    table.insert(langHooks, fn)
    pcall(fn)
end
local function applyLang()
    for _, fn in ipairs(langHooks) do pcall(fn) end
end

--========================================================
-- UI HELPERS
--========================================================
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end
local function stroke(o, color, thickness) return new("UIStroke", {Color = color or Theme.Border, Thickness = thickness or 1}, o) end

local conns = {}

--========================================================
-- MAIN GUI
--========================================================
local gui = new("ScreenGui", {
    Name = "ApichatDomain",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parentGui)

gui.Destroying:Connect(function()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
end)

--========================================================
-- STARTUP CENTER LOGO SPLASH (โลโก้กลางหน้าจอก่อนเริ่ม)
--========================================================
local function showStartupSplash(onComplete)
    local splashFrame = new("Frame", {
        Name = "SplashContainer",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 12),
        BackgroundTransparency = 0.3,
        ZIndex = 100,
    }, gui)

    local splashLogo = new("ImageLabel", {
        Name = "SplashLogo",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.45, 0),
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.MainBg,
        Image = BG_IMAGE,
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 1,
        ZIndex = 101,
    }, splashFrame)
    corner(splashLogo, 100)
    local splashStroke = stroke(splashLogo, Theme.Accent, 3)
    splashStroke.Transparency = 1

    local splashText = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.45, 75),
        Size = UDim2.new(0, 300, 0, 30),
        BackgroundTransparency = 1,
        Text = "⚡ APICHAT DOMAIN ⚡",
        TextColor3 = Theme.Text,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        ZIndex = 101,
    }, splashFrame)

    -- Animation In (ขยายขึ้นกึ่งกลาง)
    TweenService:Create(splashLogo, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 130, 0, 130),
        ImageTransparency = 0
    }):Play()
    TweenService:Create(splashStroke, TweenInfo.new(0.6), {Transparency = 0}):Play()
    TweenService:Create(splashText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

    task.delay(1.6, function()
        -- Animation Out (จางและหดลง)
        local fadeBg = TweenService:Create(splashFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        TweenService:Create(splashLogo, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            ImageTransparency = 1
        }):Play()
        TweenService:Create(splashStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(splashText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        
        fadeBg:Play()
        fadeBg.Completed:Connect(function()
            splashFrame:Destroy()
            if onComplete then onComplete() end
        end)
    end)
end

--========================================================
-- WELCOME BANNER
--========================================================
local function showWelcomeBanner()
    local card = new("Frame", {
        Size = UDim2.new(0, 320, 0, 65),
        Position = UDim2.new(1, 20, 0.85, 0),
        BackgroundColor3 = Theme.MainBg,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 60,
    }, gui)
    corner(card, 10)
    stroke(card, Theme.Accent, 1.5)

    local title = new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 12),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, card)
    onLang(function() title.Text = tr("welcome") end)

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 32),
        BackgroundTransparency = 1,
        Text = player.DisplayName .. " (@" .. player.Name .. ")",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, card)

    TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -340, 0.85, 0)}):Play()

    task.delay(3.5, function()
        local out = TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 20, 0.85, 0)})
        out:Play()
        out.Completed:Connect(function() card:Destroy() end)
    end)
end

-- LOGO BUTTON
local logo = new("ImageButton", {
    Name = "Logo",
    Position = UDim2.new(0.03, 0, 0.2, 0),
    Size = UDim2.new(0, 45, 0, 45),
    BackgroundColor3 = Theme.MainBg,
    Image = BG_IMAGE,
    ImageColor3 = Theme.Text,
    ScaleType = Enum.ScaleType.Crop,
    AutoButtonColor = false,
    Visible = true,
    ZIndex = 10,
}, gui)
corner(logo, 100)
stroke(logo, Theme.Border, 2)

-- MAIN WINDOW
local MAIN_SIZE = UDim2.new(0, 540, 0, 380)
local mainOpen = false

local main = new("ImageLabel", {
    Name = "Main",
    Image = BG_IMAGE,
    ImageTransparency = 0.1,
    ScaleType = Enum.ScaleType.Crop,
    BackgroundColor3 = Theme.MainBg,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 0, 0, 0),
    ClipsDescendants = true,
    Visible = false,
    Active = true,
    Draggable = true,
}, gui)
corner(main, 12)
stroke(main, Theme.Border, 1.5)

local mainScale = new("UIScale", {}, main)
local function fitScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    mainScale.Scale = math.clamp(math.min(vp.X / 570, vp.Y / 410), 0.5, 1)
end
fitScale()
if workspace.CurrentCamera then
    table.insert(conns, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale))
end

new("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
}, main)

local function showMain()
    mainOpen = true
    main.Visible = true
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = MAIN_SIZE}):Play()
end

local function hideMain()
    mainOpen = false
    local tw = TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 0, 0, 0)})
    tw:Play()
    tw.Completed:Connect(function()
        if not mainOpen then main.Visible = false end
    end)
end

local titleBar = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 }, main)

new("TextLabel", {
    Position = UDim2.new(0, 16, 0, 0),
    Size = UDim2.new(0.7, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "APICHAT DOMAIN",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)

local closeBtn = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.new(0, 24, 0, 24),
    BackgroundColor3 = Theme.PanelBg,
    Text = "✕",
    TextColor3 = Theme.SubText,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, titleBar)
corner(closeBtn, 100)
closeBtn.MouseButton1Click:Connect(hideMain)

do
    local dragging, moved = false, false
    local dragStart, startPos

    logo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = logo.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if d.Magnitude > 6 then moved = true end
            if moved then
                logo.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end))

    logo.MouseButton1Click:Connect(function()
        if moved then return end
        if mainOpen then hideMain() else showMain() end
    end)
end

--========================================================
-- SIDEBAR & PAGES
--========================================================
local sidebar = new("Frame", {
    Position = UDim2.new(0, 12, 0, 45),
    Size = UDim2.new(0, 140, 1, -57),
    BackgroundColor3 = Theme.PanelBg,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
}, main)
corner(sidebar, 8)
new("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, sidebar)
new("UIPadding", { PaddingTop = UDim.new(0, 10) }, sidebar)

local contentArea = new("Frame", {
    Position = UDim2.new(0, 162, 0, 45),
    Size = UDim2.new(1, -174, 1, -57),
    BackgroundTransparency = 1,
}, main)

local function createScrollPage()
    local scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, contentArea)
    new("UIListLayout", { Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
    new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 10) }, scroll)
    return scroll
end

local pages = {
    home = createScrollPage(),
    auto = createScrollPage(),
    settings = createScrollPage(),
}

local tabBtns = {}

local function setPage(name)
    for key, page in pairs(pages) do page.Visible = (key == name) end
    for key, b in pairs(tabBtns) do
        TweenService:Create(b, TweenInfo.new(0.2), {
            BackgroundTransparency = (key == name) and 0.1 or 1,
            TextColor3 = (key == name) and Theme.Text or Theme.SubText,
        }):Play()
    end
end

local function addTab(key, icon, textKey, order)
    local b = new("TextButton", {
        Size = UDim2.new(1, -16, 0, 36),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
    }, sidebar)
    corner(b, 6)
    tabBtns[key] = b

    onLang(function() b.Text = "  " .. icon .. "  " .. tr(textKey) end)
    b.MouseButton1Click:Connect(function() setPage(key) end)
end

addTab("home", "📊", "menu_home", 1)
addTab("auto", "⚔️", "menu_auto", 2)
addTab("settings", "⚙️", "menu_settings", 3)
setPage("home")

-- UI COMPONENTS
local function createCard(parent, icon, titleKey, order)
    local card = new("Frame", {
        Size = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
    }, parent)
    corner(card, 8)
    stroke(card)
    new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, card)
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, card)
    
    local header = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    }, card)
    onLang(function() header.Text = icon .. " " .. tr(titleKey) end)
    return card
end

local function createInfoLabel(parent, height, order, color)
    return new("TextLabel", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        TextColor3 = color or Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = order or 1,
    }, parent)
end

local function createToggle(parent, text, default, callback, inner)
    local frame = new("Frame", {
        Size = inner and UDim2.new(1, 0, 0, 38) or UDim2.new(1, -8, 0, 46),
        BackgroundColor3 = inner and Theme.MainBg or Theme.PanelBg,
        BorderSizePixel = 0,
    }, parent)
    corner(frame, 8)
    stroke(frame)

    local label = new("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    if type(text) == "function" then onLang(function() label.Text = text() end) else label.Text = text end

    local offColor = inner and Theme.Border or Theme.MainBg
    local switch = new("Frame", { Size = UDim2.new(0, 44, 0, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), BackgroundColor3 = default and Theme.Accent or offColor, BorderSizePixel = 0 }, frame)
    corner(switch, 100)
    stroke(switch)

    local dot = new("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 }, switch)
    corner(dot, 100)

    local state = default
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, frame)

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }):Play()
        TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = state and Theme.Accent or offColor }):Play()
        callback(state)
    end)
    return {Frame = frame}
end

local function createSlider(parent, titleKey, minVal, maxVal, defaultVal, callback)
    local frame = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Theme.MainBg, BorderSizePixel = 0 }, parent)
    corner(frame, 8)
    stroke(frame)

    local value = defaultVal
    local label = new("TextLabel", { Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, frame)
    onLang(function() label.Text = tr(titleKey) .. ": " .. value end)

    local bar = new("Frame", { Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 36), BackgroundColor3 = Theme.Border, BorderSizePixel = 0 }, frame)
    corner(bar, 100)

    local fill = new("Frame", { Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0 }, bar)
    corner(fill, 100)

    local knob = new("TextButton", { Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "" }, fill)
    corner(knob, 100)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor(minVal + (maxVal - minVal) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = tr(titleKey) .. ": " .. value
        callback(value)
    end

    knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true update(input) end end)
    table.insert(conns, UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
    table.insert(conns, UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end))

    return {Frame = frame}
end

--========================================================
-- HOME PAGE
--========================================================
local statsCard = createCard(pages.home, "👤", "card_stats", 1)
local statsRow = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, LayoutOrder = 1 }, statsCard)
local avatar = new("ImageLabel", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 0, 0, 2), BackgroundColor3 = Theme.MainBg, BorderSizePixel = 0 }, statsRow)
corner(avatar, 100)

local statsInfo = new("TextLabel", { Position = UDim2.new(0, 50, 0, 0), Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextColor3 = Theme.SubText, Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center }, statsRow)

local mapCard = createCard(pages.home, "🗺️", "card_map", 2)
local mapInfo = createInfoLabel(mapCard, 42, 1)

local perfCard = createCard(pages.home, "⚡", "card_perf", 3)
local fpsLabel = createInfoLabel(perfCard, 16, 1, Color3.fromRGB(0, 255, 150))
local pingLabel = createInfoLabel(perfCard, 16, 2, Color3.fromRGB(255, 200, 50))
fpsLabel.Font = Enum.Font.GothamMedium
pingLabel.Font = Enum.Font.GothamMedium

task.spawn(function()
    pcall(function() avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
end)

local mapName = "..."
local frames = 0
local function getPing() local ok, v = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end) return ok and math.floor(v) or 0 end

local function refreshHome()
    statsInfo.Text = ("%s: %s\nUser: @%s\nID: %d"):format(tr("name"), player.DisplayName, player.Name, player.UserId)
    mapInfo.Text = ("%s: %s\nPlace ID: %d\n%s: %d/%d"):format(tr("map"), mapName, game.PlaceId, tr("players"), #Players:GetPlayers(), Players.MaxPlayers)
end
onLang(refreshHome)

task.spawn(function()
    pcall(function() mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    refreshHome()
    while gui.Parent do
        task.wait(1)
        fpsLabel.Text = "🎮 FPS: " .. frames
        pingLabel.Text = "📶 Ping: " .. getPing() .. " ms"
        frames = 0
    end
end)
table.insert(conns, RunService.RenderStepped:Connect(function() frames = frames + 1 end))

--========================================================
-- AUTO PAGE (BLADE BALL RED BALL + SPAM + SMOOTH MOVE)
--========================================================
local autoCard = createCard(pages.auto, "⚔️", "card_auto", 1)

local autoToggle = createToggle(autoCard, function() return tr("toggle_auto") end, false, function(v)
    AUTO_HIT = v
end, true)
autoToggle.Frame.LayoutOrder = 1

local spamToggle = createToggle(autoCard, function() return tr("toggle_spam") end, false, function(v)
    SPAM_MODE = v
end, true)
spamToggle.Frame.LayoutOrder = 2

local hitSlider = createSlider(autoCard, "slider_range", 10, 80, HIT_RANGE, function(val)
    HIT_RANGE = val
end)
hitSlider.Frame.LayoutOrder = 3

local autoStatusLabel = createInfoLabel(autoCard, 16, 4, Theme.SubText)
onLang(function() autoStatusLabel.Text = tr("status_ready") end)

local function doParry()
    task.spawn(function()
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)
end

local function getTargetBall()
    local ballsFolder = workspace:FindFirstChild("Balls")
    if not ballsFolder then return nil end
    for _, ball in pairs(ballsFolder:GetChildren()) do
        if ball:IsA("BasePart") and ball.Velocity.Magnitude > 0 then
            return ball
        end
    end
    return nil
end

local function isBallTargetingMe(ball)
    if not ball then return false end
    
    local targetAttr = ball:GetAttribute("target") or ball:GetAttribute("Target") or ball:GetAttribute("realTarget")
    if targetAttr then
        if targetAttr == player.Name or targetAttr == player.DisplayName then
            return true
        end
    end

    local highlight = ball:FindFirstChildOfClass("Highlight")
    if highlight then
        local c = highlight.FillColor
        if c.R > 0.7 and c.G < 0.3 and c.B < 0.3 then
            return true
        end
    end

    if ball.Color.R > 0.7 and ball.Color.G < 0.3 and ball.Color.B < 0.3 then
        return true
    end

    return false
end

local isParrying = false

table.insert(conns, RunService.RenderStepped:Connect(function()
    if not AUTO_HIT then 
        autoStatusLabel.Text = tr("status_ready")
        autoStatusLabel.TextColor3 = Theme.SubText
        return 
    end

    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local ball = getTargetBall()
    if ball and isBallTargetingMe(ball) then
        local distance = (ball.Position - root.Position).Magnitude
        local velocity = ball.Velocity.Magnitude

        if distance <= HIT_RANGE or (distance / math.max(velocity, 1)) < 0.35 then 
            autoStatusLabel.Text = tr("status_hitting")
            autoStatusLabel.TextColor3 = Theme.Accent
            
            if SPAM_MODE then
                doParry()
            else
                if not isParrying then
                    isParrying = true
                    doParry()
                    task.delay(0.25, function() isParrying = false end)
                end
            end
        end
    else
        autoStatusLabel.Text = tr("status_ready")
        autoStatusLabel.TextColor3 = Theme.SubText
    end
end))

--========================================================
-- SETTINGS PAGE
--========================================================
local langCard = createCard(pages.settings, "🌐", "card_lang", 1)
local langRow = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = 1 }, langCard)

local thBtn = new("TextButton", { Text = "ภาษาไทย", Size = UDim2.new(0.5, -4, 1, 0), TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 11 }, langRow)
corner(thBtn, 6) stroke(thBtn)

local enBtn = new("TextButton", { Text = "English", Position = UDim2.new(0.5, 4, 0, 0), Size = UDim2.new(0.5, -4, 1, 0), TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 11 }, langRow)
corner(enBtn, 6) stroke(enBtn)

onLang(function()
    thBtn.BackgroundColor3 = (lang == "th") and Theme.Accent or Theme.MainBg
    enBtn.BackgroundColor3 = (lang == "en") and Theme.Accent or Theme.MainBg
end)

thBtn.MouseButton1Click:Connect(function() lang = "th" applyLang() end)
enBtn.MouseButton1Click:Connect(function() lang = "en" applyLang() end)

-- Anti-AFK
local antiAfkOn = true
local VirtualUser = game:GetService("VirtualUser")
table.insert(conns, player.Idled:Connect(function()
    if not antiAfkOn then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end))

local afkToggle = createToggle(pages.settings, function() return tr("toggle_afk") end, antiAfkOn, function(v)
    antiAfkOn = v
end, true)
afkToggle.Frame.LayoutOrder = 2

--========================================================
-- EXECUTE SEQUENCE
--========================================================
applyLang()

-- แสดงโลโก้กลางหน้าจอก่อน แล้วค่อยแสดงแบนเนอร์กับหน้าต่างหลัก
showStartupSplash(function()
    showWelcomeBanner()
    showMain()
end)
