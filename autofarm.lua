--[[========================================================
    ⚡ APICHAT DOMAIN ⚡
    v7 - AUTO EGG FARM + DEEP FALL + EGG ESP (FLY HOME)
    (UI ใหม่ สไตล์เดียวกับสคริปล็อคเป้า)

    เมนู:
    📊 หน้าหลัก | 🥚 ฟาร์ม | 👁️ ESP ไข่ | ⚙️ ตั้งค่า
========================================================]]--

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local StatsService = game:GetService("Stats")

local player = Players.LocalPlayer

--========================================================
-- CONFIG
--========================================================
local BG_IMAGE = "rbxassetid://73200153325421"

local DELAY = 0.1
local COLLECT_TIMEOUT = 5
local HEIGHT_OFFSET = 3

local HOME_WAIT = 0.2

-- บินกลับบ้าน
local FLY_SPEED = 1000      -- ความเร็วบิน (studs/วินาที) ถ้าโดนเตะให้ลดลง
local VOID_MARGIN = 300    -- ระยะปลอดภัยเหนือความสูงที่เกมลบตัวละคร (กันตกแมพ)
local FLY_HEIGHT = 80      -- บินสูงเหนือจุดบ้านเท่าไหร่ (กันชนสิ่งกีดขวาง)
local FLY_TIMEOUT = 60     -- ถ้าบินนานเกินนี้ ให้วาปกลับแทน (กันค้าง)

local ESP_MAX_DISTANCE = 1000
local ESP_UPDATE_RATE = 0.5

--========================================================
-- GUI PARENT
--========================================================
local parentGui = (gethui and gethui()) or CoreGui

pcall(function()
    local old = parentGui:FindFirstChild("ApichatDomain")
    if old then old:Destroy() end
end)

--========================================================
-- THEME (จากสคริปล็อคเป้า)
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

pcall(function()
    if isfile and readfile and isfile("apichat_lang.txt") then
        local l = readfile("apichat_lang.txt")
        if l == "en" or l == "th" then lang = l end
    end
end)

local T = {
    th = {
        welcome = "ยินดีต้อนรับสู่ ⚡ APICHAT DOMAIN",

        menu_home = "หน้าหลัก",
        menu_farm = "ฟาร์ม",
        menu_esp = "ESP ไข่",
        menu_settings = "ตั้งค่า",

        card_stats = "ข้อมูลผู้เล่น (Stats)",
        card_map = "ข้อมูลแมพ (Map)",
        card_perf = "สถานะระบบ (Perf)",
        card_farm = "ออโต้เก็บไข่",
        card_pick = "เลือกไข่ที่จะเก็บ",
        card_esp = "ESP ไข่",
        card_esp_pick = "เลือก Luck ที่จะแสดง",
        card_lang = "ภาษา (Language)",

        name = "ชื่อ",
        map = "แมพ",
        players = "คนในเซิร์ฟ",

        toggle_farm = "🥚 เปิดออโต้เก็บไข่",
        toggle_esp = "👁️ เปิด ESP ไข่",
        esp_dist = "📏 ระยะ ESP",

        status_ready = "สถานะ: พร้อมใช้งาน",
        status_nofolder = "สถานะ: ไม่พบโฟลเดอร์ RenderedEggs",
        status_none = "สถานะ: ไม่มีไข่ตามที่เลือก รอสักครู่...",
        status_collect = "สถานะ: เก็บไข่ (เหลือ %d)",
        status_stopped = "สถานะ: หยุดแล้ว",
        status_full = "สถานะ: ตะกร้าเต็ม รอให้ว่างก่อน...",

        all = "เลือกทั้งหมด",
        none = "ไม่เลือกเลย",

        dd_farm_title = "ระดับไข่ที่จะเก็บ (Filter)",
        dd_farm_desc = "เลือกไข่ที่ต้องการเก็บ กดเพื่อเปิดรายการ",
        dd_esp_title = "ไข่ที่จะแสดง (ESP)",
        dd_esp_desc = "เลือก Luck ที่ต้องการให้แสดง กดเพื่อเปิดรายการ",
        dd_all = "All (ทั้งหมด)",
        dd_none = "None (ไม่เลือก)",
        dd_some = "เลือก %d/%d",
        dd_empty = "รอสแกนไข่...",

        card_place = "วางไข่อัตโนมัติ",
        toggle_place = "📥 เปิดวางไข่อัตโนมัติ",
        dd_place_title = "ระดับไข่ที่จะวาง",
        dd_place_desc = "เลือก Luck ของไข่ในกระเป๋าที่จะให้วางอัตโนมัติ",
        pstatus_idle = "วางไข่: ไม่มีไข่ตามที่เลือกในกระเป๋า",
        pstatus_placing = "วางไข่: กำลังวาง %s",
        pstatus_noprompt = "วางไข่: ไม่พบจุดวางไข่ใกล้ตัว (ลองกดใช้ไข่แทน)",
        pstatus_wait = "วางไข่: รอกลับถึงบ้านก่อน",
        pstatus_idle_names = "วางไข่: ไม่มีไข่ที่เลือก (ในกระเป๋า: %s)",

        card_save = "บันทึกการตั้งค่า",
        btn_save = "💾 บันทึกการตั้งค่าตอนนี้",
        btn_reset = "🗑️ รีเซ็ตค่าที่บันทึกไว้",
        save_none = "ยังไม่มีค่าที่บันทึกไว้",
        save_have = "มีค่าที่บันทึกไว้ (โหลดอัตโนมัติตอนรัน)",
        save_ok = "บันทึกแล้ว ครั้งหน้าจะโหลดให้อัตโนมัติ",
        save_fail = "บันทึกไม่ได้ (ตัวรันสคริปต์ไม่รองรับไฟล์)",
        save_reset = "ลบค่าที่บันทึกและรีเซ็ตทุกอย่างแล้ว",
        save_loaded = "โหลดค่าที่บันทึกไว้แล้ว",

        card_discord = "ดิสคอร์ด (Discord)",
        btn_copy = "📋 คัดลอกลิงก์",
        copied = "✅ คัดลอกแล้ว!",
        copy_fail = "❌ คัดลอกไม่ได้ ลองพิมพ์ลิงก์เอง",

        btn_sethome = "📍 บันทึกจุดบ้านตรงนี้",
        home_set = "✅ บันทึกจุดบ้านแล้ว",
        toggle_afk = "🛡️ กันโดนเตะเมื่อไม่ขยับ (Anti-AFK)",
    },

    en = {
        welcome = "Welcome to ⚡ APICHAT DOMAIN",

        menu_home = "Home",
        menu_farm = "Farm",
        menu_esp = "Egg ESP",
        menu_settings = "Settings",

        card_stats = "Player Info (Stats)",
        card_map = "Map Info (Map)",
        card_perf = "System (Perf)",
        card_farm = "Auto Collect Eggs",
        card_pick = "Select eggs to collect",
        card_esp = "Egg ESP",
        card_esp_pick = "Select Luck to show",
        card_lang = "Language",

        name = "Name",
        map = "Map",
        players = "Players",

        toggle_farm = "🥚 Auto collect eggs",
        toggle_esp = "👁️ Egg ESP",
        esp_dist = "📏 ESP Distance",

        status_ready = "Status: Ready",
        status_nofolder = "Status: RenderedEggs folder not found",
        status_none = "Status: No selected eggs, waiting...",
        status_collect = "Status: Collecting egg (%d left)",
        status_stopped = "Status: Stopped",
        status_full = "Status: Basket full, waiting...",

        all = "Select all",
        none = "Select none",

        dd_farm_title = "Eggs to collect (Filter)",
        dd_farm_desc = "Choose which eggs to collect. Tap to open the list",
        dd_esp_title = "Eggs to show (ESP)",
        dd_esp_desc = "Choose which Luck tiers to show. Tap to open the list",
        dd_all = "All",
        dd_none = "None",
        dd_some = "%d/%d selected",
        dd_empty = "Scanning eggs...",

        card_place = "Auto Place Eggs",
        toggle_place = "📥 Auto place eggs",
        dd_place_title = "Eggs to place",
        dd_place_desc = "Choose which Luck tiers in your backpack to place",
        pstatus_idle = "Place: no selected eggs in backpack",
        pstatus_placing = "Place: placing %s",
        pstatus_noprompt = "Place: no place spot nearby (tried using the egg)",
        pstatus_wait = "Place: waiting to get home",
        pstatus_idle_names = "Place: no selected eggs (backpack: %s)",

        card_save = "Save Settings",
        btn_save = "💾 Save current settings",
        btn_reset = "🗑️ Reset saved settings",
        save_none = "No saved settings yet",
        save_have = "Saved settings found (auto-loaded on run)",
        save_ok = "Saved. It will load automatically next time",
        save_fail = "Could not save (executor has no file support)",
        save_reset = "Saved settings deleted and everything reset",
        save_loaded = "Saved settings loaded",

        card_discord = "Discord",
        btn_copy = "📋 Copy link",
        copied = "✅ Copied!",
        copy_fail = "❌ Could not copy, type the link manually",

        btn_sethome = "📍 Set home here",
        home_set = "✅ Home saved",
        toggle_afk = "🛡️ Anti-AFK (prevent idle kick)",
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

local function corner(o, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o)
end

local function stroke(o, color, thickness)
    return new("UIStroke", {Color = color or Theme.Border, Thickness = thickness or 1}, o)
end

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

--========================================================
-- LOGO (ปุ่มเปิด/ปิด ลากได้)
--========================================================
local logo = new("ImageButton", {
    Name = "Logo",
    Position = UDim2.new(0.03, 0, 0.2, 0),
    Size = UDim2.new(0, 45, 0, 45),
    BackgroundColor3 = Theme.MainBg,
    Image = BG_IMAGE,
    ImageColor3 = Theme.Text,
    ScaleType = Enum.ScaleType.Crop,
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 10,
}, gui)
corner(logo, 100)
stroke(logo, Theme.Border, 2)

--========================================================
-- MAIN WINDOW
--========================================================
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

-- ปรับขนาดตามหน้าจอ (มือถือ)
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

-- overlay มืดเล็กน้อยให้อ่านง่าย
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

-- Title bar
local titleBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
}, main)

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

-- ลาก logo + คลิกเพื่อเปิด/ปิด
do
    local dragging, moved = false, false
    local dragStart, startPos

    logo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if d.Magnitude > 6 then moved = true end
            if moved then
                logo.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end))

    logo.MouseButton1Click:Connect(function()
        if moved then return end
        if mainOpen then hideMain() else showMain() end
    end)
end

--========================================================
-- SIDEBAR + CONTENT
--========================================================
local sidebar = new("Frame", {
    Position = UDim2.new(0, 12, 0, 45),
    Size = UDim2.new(0, 140, 1, -57),
    BackgroundColor3 = Theme.PanelBg,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
}, main)
corner(sidebar, 8)
new("UIListLayout", {
    Padding = UDim.new(0, 6),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)
new("UIPadding", {PaddingTop = UDim.new(0, 10)}, sidebar)

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

    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, scroll)

    new("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 10),
    }, scroll)

    return scroll
end

local pages = {
    home = createScrollPage(),
    farm = createScrollPage(),
    esp = createScrollPage(),
    settings = createScrollPage(),
}

local tabBtns = {}

local function setPage(name)
    for key, page in pairs(pages) do
        page.Visible = (key == name)
    end
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
addTab("farm", "🥚", "menu_farm", 2)
addTab("esp", "👁️", "menu_esp", 3)
addTab("settings", "⚙️", "menu_settings", 4)

--========================================================
-- UI COMPONENTS (การ์ด / สวิตช์ / สไลเดอร์)
--========================================================
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

    new("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, card)

    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, card)

    local header = new("TextLabel", {
        Name = "HeaderLabel",
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

-- text: string หรือ function ที่คืนค่า string (แปลภาษาอัตโนมัติ)
-- inner = true → ใช้ข้างในการ์ด (เตี้ยกว่า)
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
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, frame)

    if type(text) == "function" then
        onLang(function() label.Text = text() end)
    else
        label.Text = text
    end

    local offColor = inner and Theme.Border or Theme.MainBg

    local switch = new("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        BackgroundColor3 = default and Theme.Accent or offColor,
        BorderSizePixel = 0,
    }, frame)
    corner(switch, 100)
    stroke(switch)

    local dot = new("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, switch)
    corner(dot, 100)

    local state = default and true or false

    local function render()
        local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(dot, tInfo, {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        TweenService:Create(switch, tInfo, {
            BackgroundColor3 = state and Theme.Accent or offColor
        }):Play()
    end

    local obj = {Frame = frame, Label = label}

    function obj.Set(v, silent)
        v = v and true or false
        if v == state then return end
        state = v
        render()
        if not silent then callback(state) end
    end

    function obj.Get() return state end

    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    }, frame)

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)

    return obj
end

local function createSlider(parent, titleKey, minVal, maxVal, defaultVal, callback)
    local frame = new("Frame", {
        Size = UDim2.new(1, -8, 0, 56),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0,
    }, parent)
    corner(frame, 8)
    stroke(frame)

    local value = defaultVal

    local label = new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 28),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)
    onLang(function() label.Text = tr(titleKey) .. ": " .. value end)

    local bar = new("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 36),
        BackgroundColor3 = Theme.MainBg,
        BorderSizePixel = 0,
    }, frame)
    corner(bar, 100)

    local fill = new("Frame", {
        Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    }, bar)
    corner(fill, 100)

    local knob = new("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
    }, fill)
    corner(knob, 100)

    local dragging = false

    local function isPress(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor(minVal + (maxVal - minVal) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = tr(titleKey) .. ": " .. value
        callback(value)
    end

    knob.InputBegan:Connect(function(input)
        if isPress(input) then dragging = true end
    end)
    bar.InputBegan:Connect(function(input)
        if isPress(input) then dragging = true update(input) end
    end)
    table.insert(conns, UserInputService.InputEnded:Connect(function(input)
        if isPress(input) then dragging = false end
    end))
    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end))

    return frame
end

local function createAllNone(parent, onAll, onNone)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
    }, parent)

    local a = new("TextButton", {
        Size = UDim2.new(0.5, -4, 1, 0),
        BackgroundColor3 = Theme.Accent,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
    }, row)
    corner(a, 6)

    local n = new("TextButton", {
        Position = UDim2.new(0.5, 4, 0, 0),
        Size = UDim2.new(0.5, -4, 1, 0),
        BackgroundColor3 = Color3.fromRGB(150, 50, 50),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
    }, row)
    corner(n, 6)

    onLang(function()
        a.Text = tr("all")
        n.Text = tr("none")
    end)

    a.MouseButton1Click:Connect(onAll)
    n.MouseButton1Click:Connect(onNone)
end

-- แถวแบบ Dropdown (ชื่อ + คำอธิบาย + ปุ่มสรุปตัวเลือกด้านขวา)
local function createDropdownRow(parent, titleKey, descKey, order, summaryFn, onOpen)
    local frame = new("Frame", {
        Size = UDim2.new(1, -8, 0, 62),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0,
        LayoutOrder = order,
    }, parent)
    corner(frame, 8)
    stroke(frame)

    local title = new("TextLabel", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -150, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, frame)

    local desc = new("TextLabel", {
        Position = UDim2.new(0, 12, 0, 27),
        Size = UDim2.new(1, -150, 0, 28),
        BackgroundTransparency = 1,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, frame)

    local btn = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 124, 0, 32),
        BackgroundColor3 = Color3.fromRGB(58, 44, 105),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, frame)
    corner(btn, 8)
    stroke(btn, Theme.Accent, 1)

    local obj = {Frame = frame}

    function obj.Refresh()
        btn.Text = summaryFn() .. "  ▾"
    end

    onLang(function()
        title.Text = tr(titleKey)
        desc.Text = tr(descKey)
        obj.Refresh()
    end)

    btn.MouseButton1Click:Connect(onOpen)

    return obj
end

-- หน้าต่างเล็กสำหรับเลือกไข่ (ซ้อนอยู่ในหน้าต่างหลัก)
local function createPicker(titleKey, onAll, onNone)
    local overlay = new("TextButton", {
        Name = "PickerOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 20,
    }, main)

    local panel = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 300, 0, 320),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0,
        Active = true,
    }, overlay)
    corner(panel, 10)
    stroke(panel, Theme.Accent, 1.5)

    new("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, panel)

    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, panel)

    local header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
    }, panel)

    local title = new("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    onLang(function() title.Text = "🎯 " .. tr(titleKey) end)

    local closeX = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundColor3 = Theme.MainBg,
        Text = "✕",
        TextColor3 = Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
    }, header)
    corner(closeX, 100)

    createAllNone(panel, onAll, onNone)

    local list = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 236),
        BackgroundColor3 = Theme.MainBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
    }, panel)
    corner(list, 6)

    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    new("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 8),
    }, list)

    local obj = {List = list}

    function obj.Open() overlay.Visible = true end
    function obj.Close() overlay.Visible = false end

    overlay.MouseButton1Click:Connect(obj.Close)
    closeX.MouseButton1Click:Connect(obj.Close)

    return obj
end

--========================================================
-- HOME PAGE
--========================================================
local statsCard = createCard(pages.home, "👤", "card_stats", 1)

local statsRow = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundTransparency = 1,
    LayoutOrder = 1,
}, statsCard)

local avatar = new("ImageLabel", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(0, 0, 0, 2),
    BackgroundColor3 = Theme.MainBg,
    BorderSizePixel = 0,
}, statsRow)
corner(avatar, 100)

local statsInfo = new("TextLabel", {
    Position = UDim2.new(0, 50, 0, 0),
    Size = UDim2.new(1, -50, 1, 0),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
}, statsRow)

local mapCard = createCard(pages.home, "🗺️", "card_map", 2)
local mapInfo = createInfoLabel(mapCard, 42, 1)

local perfCard = createCard(pages.home, "⚡", "card_perf", 3)
local fpsLabel = createInfoLabel(perfCard, 16, 1, Color3.fromRGB(0, 255, 150))
local pingLabel = createInfoLabel(perfCard, 16, 2, Color3.fromRGB(255, 200, 50))
fpsLabel.Font = Enum.Font.GothamMedium
pingLabel.Font = Enum.Font.GothamMedium
fpsLabel.TextSize = 11
pingLabel.TextSize = 11

-- การ์ดดิสคอร์ด
do
    local DISCORD_LINK = "https://discord.gg/M3wS7hb8d8"

    local dCard = createCard(pages.home, "💬", "card_discord", 4)

    local link = createInfoLabel(dCard, 16, 1, Theme.Accent)
    link.Text = DISCORD_LINK
    link.Font = Enum.Font.GothamMedium
    link.TextSize = 11

    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Accent,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        LayoutOrder = 2,
    }, dCard)
    corner(btn, 6)

    local msgKey = "btn_copy"
    onLang(function() btn.Text = tr(msgKey) end)

    btn.MouseButton1Click:Connect(function()
        local ok = pcall(function()
            local fn = setclipboard or toclipboard
            assert(fn, "no clipboard")
            fn(DISCORD_LINK)
        end)

        msgKey = ok and "copied" or "copy_fail"
        btn.Text = tr(msgKey)

        task.delay(1.5, function()
            msgKey = "btn_copy"
            btn.Text = tr(msgKey)
        end)
    end)
end

task.spawn(function()
    pcall(function()
        avatar.Image = Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
end)

local mapName = "..."
local fps = 0
local frames = 0

local function getPing()
    local ok, v = pcall(function()
        return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and math.floor(v) or 0
end

local function refreshHome()
    statsInfo.Text = ("%s: %s\nUser: @%s\nID: %d"):format(
        tr("name"), player.DisplayName, player.Name, player.UserId)

    mapInfo.Text = ("%s: %s\nPlace ID: %d\n%s: %d/%d"):format(
        tr("map"), mapName, game.PlaceId, tr("players"), #Players:GetPlayers(), Players.MaxPlayers)

    fpsLabel.Text = "🎮 FPS: " .. fps
    pingLabel.Text = "📶 Ping: " .. getPing() .. " ms"
end

onLang(refreshHome)

task.spawn(function()
    pcall(function()
        mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    refreshHome()
end)

table.insert(conns, RunService.RenderStepped:Connect(function()
    frames = frames + 1
end))

task.spawn(function()
    while gui.Parent do
        task.wait(1)
        fps = frames
        frames = 0
        pcall(refreshHome)
    end
end)

--========================================================
-- FARM DATA
--========================================================
local running = false
local homeCFrame = nil
local userHome = false -- true = ผู้ใช้กำหนดจุดบ้านเอง (ฟาร์มจะไม่ทับค่านี้)

local selTier = {}
local selName = {}

local tierRows = {}
local nameRows = {}

local luckOf = {}
local tierNames = {}

--========================================================
-- CHARACTER
--========================================================
local function getRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

--========================================================
-- NOCLIP
--========================================================
local noclipConn = nil
local savedCollide = {}

local function startNoclip()
    local char = player.Character
    if not char then return end

    savedCollide = {}
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then savedCollide[d] = d.CanCollide end
    end

    if noclipConn then pcall(function() noclipConn:Disconnect() end) end

    noclipConn = RunService.Stepped:Connect(function()
        if not noclipConn then return end
        local c = player.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") then d.CanCollide = false end
        end
    end)
end

local MAIN_PARTS = {
    HumanoidRootPart = true, Head = true, Torso = true,
    UpperTorso = true, LowerTorso = true,
}

local function forceCollide()
    local c = player.Character
    if not c then return end
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") and MAIN_PARTS[d.Name] then
            pcall(function() d.CanCollide = true end)
        end
    end
end

local function endNoclip()
    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end

    for part, was in pairs(savedCollide) do
        pcall(function()
            if part and part.Parent then part.CanCollide = was end
        end)
    end

    savedCollide = {}

    -- บังคับคืนการชนให้ชิ้นส่วนหลักของตัวละคร (กันค้างทะลุแมพ)
    forceCollide()
end

--========================================================
-- FLY HOME + GO HOME
--========================================================
-- บินกลับไปที่จุดบ้านแบบเคลื่อนที่จริง (ไม่วาป)
-- ขึ้นสูงก่อน → บินตรงไปเหนือจุดบ้าน → ลงมาจอด
local function flyTo(targetCF)
    local root = getRoot()
    if not root then return false end

    -- ปลดล็อกจากตอนตกใต้แมพ
    root.Anchored = false
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    startNoclip()

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.zero
    bv.Parent = root

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 1e5
    bg.CFrame = root.CFrame
    bg.Parent = root

    local dest = targetCF.Position + Vector3.new(0, 2, 0)
    local cruiseY = dest.Y + FLY_HEIGHT
    local destroyY = workspace.FallenPartsDestroyHeight
    local t0 = os.clock()
    local arrived = false

    while os.clock() - t0 < FLY_TIMEOUT do
        root = getRoot()
        if not root or not bv.Parent then break end

        local pos = root.Position
        local flat = Vector3.new(dest.X - pos.X, 0, dest.Z - pos.Z)

        local dir
        local speed = FLY_SPEED

        if pos.Y < destroyY + VOID_MARGIN then
            -- ใกล้ขอบล่างของแมพ: พุ่งขึ้นตรงๆ ก่อน กันโดนเกมลบตัว
            dir = Vector3.new(0, 1, 0)
        elseif flat.Magnitude > 10 then
            if pos.Y < cruiseY - 5 then
                -- ช่วงแรก: ขึ้นสูงก่อน (ค่อยๆ เอียงไปทางบ้าน)
                dir = Vector3.new(flat.Unit.X * 0.3, 1, flat.Unit.Z * 0.3).Unit
            else
                dir = Vector3.new(flat.Unit.X, (cruiseY - pos.Y) / 20, flat.Unit.Z).Unit
                -- ชะลอก่อนถึงเหนือจุดบ้าน กันบินเลยจุด
                speed = math.clamp(flat.Magnitude * 4, 40, FLY_SPEED)
            end
        else
            -- เหนือจุดบ้านแล้ว: ค่อยๆ ลงมาจอด
            local down = dest - pos
            if down.Magnitude < 3 then
                arrived = true
                break
            end
            dir = down.Unit
            speed = math.clamp(down.Magnitude * 5, 15, 120)
        end

        bv.Velocity = dir * speed
        bg.CFrame = CFrame.new(pos, pos + Vector3.new(dir.X, 0, dir.Z) + Vector3.new(0, 0.001, 0))
        task.wait()
    end

    root = getRoot()
    if root then
        -- ล็อกตำแหน่งที่จุดบ้าน แล้วคืนการชนก่อนปล่อยแรงบิน (กันทะลุพื้นตอนลงจอด)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = targetCF + Vector3.new(0, 2, 0)
        endNoclip()
        forceCollide()
        task.wait(0.15)
    end

    pcall(function() bv:Destroy() end)
    pcall(function() bg:Destroy() end)

    root = getRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    return arrived
end

local function goHome()
    local root = getRoot()
    local t = 0

    while not root and t < 5 do
        task.wait(0.1)
        t = t + 0.1
        root = getRoot()
    end

    if root and homeCFrame then
        flyTo(homeCFrame)
    end

    endNoclip()

    -- ถ้าลงมาแล้วตกทะลุ/โดนดีดออก ให้วาปกลับ
    -- ออกจากลูปทันทีเมื่อยืนบนพื้นได้แล้ว
    if homeCFrame then
        local homePos = homeCFrame.Position
        local grounded = 0
        local t0 = os.clock()

        while os.clock() - t0 < 3 do
            local r = getRoot()
            local c = player.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")

            if r then
                if (r.Position - homePos).Magnitude > 15 or r.Position.Y < workspace.FallenPartsDestroyHeight + 100 then
                    r.Anchored = false
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                    r.CFrame = homeCFrame + Vector3.new(0, 2, 0)
                    forceCollide()
                    grounded = 0
                elseif hum and hum.FloorMaterial ~= Enum.Material.Air then
                    grounded = grounded + 1
                    if grounded >= 5 then break end
                else
                    grounded = 0
                end
            end

            task.wait()
        end
    end
end

--========================================================
-- FORMAT / PARSE
--========================================================
local function fmt(n)
    local units = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}

    for _, u in ipairs(units) do
        if n >= u[1] then
            local v = n / u[1]
            if v == math.floor(v) then
                return tostring(math.floor(v)) .. u[2]
            end
            return (string.format("%.2f", v):gsub("%.?0+$", "")) .. u[2]
        end
    end

    return tostring(math.floor(n))
end

local function parseLuck(text)
    local num, unit = text:match("^%s*([%d%.]+)%s*([KkMmBbTt]?)%s*$")
    if not num then return nil end

    local n = tonumber(num)
    if not n or n <= 0 then return nil end

    local mult = ({K = 1e3, M = 1e6, B = 1e9, T = 1e12})[unit:upper()] or 1
    return math.floor(n * mult + 0.5)
end

--========================================================
-- EGG NAME
--========================================================
local function findEggName(lbl)
    local a = lbl.Parent

    for _ = 1, 6 do
        if not a or a:IsA("PlayerGui") then break end

        local n = a.Name:lower()
        if n:find("egg") and n ~= "eggs" then
            return a.Name
        end

        for _, c in ipairs(a:GetChildren()) do
            if c:IsA("TextLabel") and c ~= lbl then
                local t = c.Text
                if t:lower():find("egg") and #t < 30 and not t:find("Map") then
                    return t
                end
            end
        end

        a = a.Parent
    end

    return nil
end

--========================================================
-- ESP
--========================================================
local espEnabled = false
local espTier = {}
local espRows = {}
local espObjects = {}

local espFolder = Instance.new("Folder")
espFolder.Name = "ApichatEggESP"
espFolder.Parent = gui

local function removeESP(obj)
    local data = espObjects[obj]
    if not data then return end

    pcall(function()
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
    end)

    espObjects[obj] = nil
end

local function clearESP()
    for obj in pairs(espObjects) do removeESP(obj) end
end

local function createEggESP(model, eggName, luck)
    if espObjects[model] then return end
    if not model or not model.Parent then return end

    local adornee = model:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "EggESP"
    highlight.Adornee = model
    highlight.FillColor = Theme.Accent
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESPText"
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 190, 0, 55)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESP_MAX_DISTANCE
    billboard.Parent = espFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextWrapped = true
    label.Text = "🥚 " .. eggName .. "\nLuck: " .. fmt(luck)
    label.Parent = billboard

    espObjects[model] = {highlight = highlight, billboard = billboard}
end

local function updateESP()
    if not espEnabled then
        clearESP()
        return
    end

    local folder = workspace:FindFirstChild("RenderedEggs")
    if not folder then
        clearESP()
        return
    end

    local current = {}

    for _, model in ipairs(folder:GetChildren()) do
        local eggName = model.Name
        local luck = luckOf[eggName]

        if luck and espTier[luck] then
            current[model] = true
            if not espObjects[model] then
                createEggESP(model, eggName, luck)
            end
        end
    end

    for model in pairs(espObjects) do
        if not current[model] or not model.Parent then
            removeESP(model)
        end
    end
end

--========================================================
-- FARM COLLECT
--========================================================
-- ไข่ที่เก็บไม่สำเร็จ จะถูกข้ามชั่วคราว (กันวนติดไข่ลูกเดิม)
local SKIP_TIME = 8
local SETTLE_TIME = 1.5 -- รอเซิร์ฟเวอร์ยืนยันการเก็บก่อนวาป
local ARRIVE_WAIT = 0.6 -- รอให้เซิร์ฟเวอร์รับตำแหน่งใหม่ก่อนกดเก็บ
local skipUntil = setmetatable({}, {__mode = "k"})

-- อ่านตัวเลขตะกร้าไข่ (เช่น 0/1) จากหน้าจอเกม
local basketLabel = nil

local function getBasket()
    if not (basketLabel and basketLabel.Parent) then
        basketLabel = nil

        local pg = player:FindFirstChild("PlayerGui")
        if not pg then return nil end

        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextLabel") then
                local t = d.Text:lower()
                if t:find("ตะกร้า", 1, true) or t:find("basket", 1, true) then
                    local a = d.Parent
                    for _ = 1, 3 do
                        if not a or a:IsA("PlayerGui") then break end
                        for _, c in ipairs(a:GetDescendants()) do
                            if c:IsA("TextLabel") and c.Text:match("^%s*%d+%s*/%s*%d+%s*$") then
                                basketLabel = c
                                break
                            end
                        end
                        if basketLabel then break end
                        a = a.Parent
                    end
                end
                if basketLabel then break end
            end
        end
    end

    if not basketLabel then return nil end

    local cur, max = basketLabel.Text:match("^%s*(%d+)%s*/%s*(%d+)%s*$")
    if cur then return tonumber(cur), tonumber(max) end
    return nil
end

local function collect(egg)
    local root = getRoot()
    if not root or not egg.part or not egg.part.Parent then return end

    local eggPos = egg.part.Position
    local snapCF = CFrame.new(eggPos + Vector3.new(0, HEIGHT_OFFSET, 0))

    pcall(function()
        egg.prompt.HoldDuration = 0
        egg.prompt.RequiresLineOfSight = false
        egg.prompt.MaxActivationDistance = math.max(egg.prompt.MaxActivationDistance, 30)
    end)

    root.CFrame = snapCF
    task.wait(ARRIVE_WAIT)

    local before = getBasket()
    local waited = 0
    local success = false

    while running and waited < COLLECT_TIMEOUT do
        if not egg.part.Parent or not egg.prompt.Parent or not egg.prompt.Enabled then
            success = true
            break
        end

        -- ดึงตัวกลับมาที่ไข่ทุกรอบ เผื่อโดนเซิร์ฟเวอร์ดีดกลับ
        root = getRoot()
        if not root then return end
        if (root.Position - snapCF.Position).Magnitude > 6 then
            root.CFrame = snapCF
        end

        if fireproximityprompt then
            pcall(fireproximityprompt, egg.prompt)
        end

        if firetouchinterest then
            pcall(function()
                firetouchinterest(root, egg.part, 0)
                task.wait()
                firetouchinterest(root, egg.part, 1)
            end)
        end

        task.wait(0.25)
        waited = waited + 0.25
    end

    if not running then return end

    if not success then
        -- เก็บไม่ได้ (เช่น เต็ม/ติดเงื่อนไขเกม) → ข้ามไข่ลูกนี้ไปก่อน
        skipUntil[egg.prompt] = os.clock() + SKIP_TIME
        return
    end

    -- รอให้เซิร์ฟเวอร์รับรู้การเก็บก่อน แล้วค่อยวาปลงใต้แมพ
    task.wait(SETTLE_TIME)
    if not running then return end

    -- เช็คว่าไข่เข้าตะกร้าจริงไหม (ถ้าอ่านตัวเลขตะกร้าได้)
    local after = getBasket()
    if before and after and after <= before then
        skipUntil[egg.prompt] = os.clock() + SKIP_TIME
        return
    end

    root = getRoot()
    if not root then return end

    local destroyY = workspace.FallenPartsDestroyHeight
    local targetY = math.max(eggPos.Y - FALL_DEPTH, destroyY + VOID_MARGIN)

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    startNoclip()

    if humanoid then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end)
    end

    local startClock = os.clock()
    local lastY = root.Position.Y
    local returned = false

    while running and os.clock() - startClock < FALL_TIMEOUT do
        root = getRoot()
        if not root then break end

        local y = root.Position.Y
        if y <= targetY then break end

        -- ถ้าเกมดึงตัวละครกลับขึ้นมา (Y เด้งขึ้นกะทันหัน) ให้เลิกตกทันที
        if y - lastY > 30 then
            returned = true
            break
        end

        lastY = y
        root.AssemblyLinearVelocity = Vector3.new(0, -FALL_SPEED, 0)
        task.wait()
    end

    root = getRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        if not returned then
            root.Anchored = true
        end
    end
end

--========================================================
-- FARM UI
--========================================================
--========================================================
-- SAVED SETTINGS (โหลดค่าที่บันทึกไว้)
--========================================================
local HttpService = game:GetService("HttpService")
local SAVE_FILE = "apichat_settings.json"
local savedCfg = nil

pcall(function()
    if isfile and readfile and isfile(SAVE_FILE) then
        local data = HttpService:JSONDecode(readfile(SAVE_FILE))
        if type(data) == "table" then savedCfg = data end
    end
end)

local function luckKey(luck)
    return string.format("%.0f", luck)
end

local function savedTier(kind, luck)
    local t = savedCfg and savedCfg.tiers and savedCfg.tiers[kind]
    if t then return t[luckKey(luck)] end
    return nil
end

local function savedName(name)
    local t = savedCfg and savedCfg.names
    if t then return t[name] end
    return nil
end

-- โหลดจุดบ้านที่บันทึกไว้
if savedCfg and type(savedCfg.home) == "table" and #savedCfg.home == 12 then
    pcall(function()
        homeCFrame = CFrame.new(table.unpack(savedCfg.home))
        userHome = true
    end)
end

local antiAfkOn = not (savedCfg and savedCfg.afk == false)

local farmCard = createCard(pages.farm, "🥚", "card_farm", 1)

local startFarm

local farmToggle = createToggle(farmCard, function() return tr("toggle_farm") end, false, function(v)
    running = v
    if v then startFarm() end
end, true)
farmToggle.Frame.LayoutOrder = 1

local statusLabel = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = 2,
}, farmCard)

do
    local homeBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.MainBg,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        LayoutOrder = 3,
    }, farmCard)
    corner(homeBtn, 6)
    stroke(homeBtn, Theme.Accent, 1)

    local flash = false
    onLang(function() homeBtn.Text = flash and tr("home_set") or tr("btn_sethome") end)

    homeBtn.MouseButton1Click:Connect(function()
        local r = getRoot()
        if not r then return end

        homeCFrame = r.CFrame
        userHome = true

        flash = true
        homeBtn.Text = tr("home_set")
        task.delay(1.5, function()
            flash = false
            homeBtn.Text = tr("btn_sethome")
        end)
    end)
end

local statusKey = "status_ready"
local statusArgs = {}

local function renderStatus()
    statusLabel.Text = string.format(tr(statusKey), table.unpack(statusArgs))
end

local function setStatus(key, ...)
    statusKey = key
    statusArgs = {...}
    renderStatus()
end

onLang(renderStatus)

local function setAllRows(rows, v)
    for _, r in pairs(rows) do r.Set(v) end
end

local farmDD, espDD, placeDD

local function refreshDropdowns()
    if farmDD then farmDD.Refresh() end
    if espDD then espDD.Refresh() end
    if placeDD then placeDD.Refresh() end
end

local function summarize(...)
    local on, total = 0, 0
    for _, rows in ipairs({...}) do
        for _, r in pairs(rows) do
            total = total + 1
            if r.Get() then on = on + 1 end
        end
    end
    if total == 0 then return tr("dd_empty") end
    if on == total then return tr("dd_all") end
    if on == 0 then return tr("dd_none") end
    return string.format(tr("dd_some"), on, total)
end

local farmPicker = createPicker("card_pick",
    function() setAllRows(tierRows, true) setAllRows(nameRows, true) end,
    function() setAllRows(tierRows, false) setAllRows(nameRows, false) end
)

farmDD = createDropdownRow(pages.farm, "dd_farm_title", "dd_farm_desc", 2,
    function() return summarize(tierRows, nameRows) end,
    function() farmPicker.Open() end
)

--========================================================
-- AUTO PLACE UI
--========================================================
local placeEnabled = false
local placeTier = {}
local placeRows = {}
local placeSkip = setmetatable({}, {__mode = "k"})

local placeCard = createCard(pages.farm, "📥", "card_place", 3)

local placeToggle = createToggle(placeCard, function() return tr("toggle_place") end, false, function(v)
    placeEnabled = v
end, true)
placeToggle.Frame.LayoutOrder = 1

local pStatusLabel = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    LayoutOrder = 2,
}, placeCard)

local pStatusKey = "pstatus_idle"
local pStatusArgs = {}

local function renderPStatus()
    pStatusLabel.Text = string.format(tr(pStatusKey), table.unpack(pStatusArgs))
end

local function setPStatus(key, ...)
    pStatusKey = key
    pStatusArgs = {...}
    renderPStatus()
end

onLang(renderPStatus)

local placePicker = createPicker("dd_place_title",
    function() setAllRows(placeRows, true) end,
    function() setAllRows(placeRows, false) end
)

placeDD = createDropdownRow(pages.farm, "dd_place_title", "dd_place_desc", 4,
    function() return summarize(placeRows) end,
    function() placePicker.Open() end
)

local function refreshTier(luck)
    local row = tierRows[luck]
    if not row then return end

    local names = table.concat(tierNames[luck] or {}, ", ")
    row.Label.Text = "Luck " .. fmt(luck) .. (names ~= "" and ("  ·  " .. names) or "")
end

local function ensureTier(luck)
    if tierRows[luck] then return end

    selTier[luck] = true

    local row = createToggle(farmPicker.List, "", true, function(v)
        selTier[luck] = v
        refreshDropdowns()
    end, true)
    row.Frame.LayoutOrder = 10 + math.floor(math.log(luck, 10) * 100 + 0.5)

    tierRows[luck] = row
    refreshTier(luck)
    refreshDropdowns()

    local sv = savedTier("farm", luck)
    if sv ~= nil then row.Set(sv) end
end

local function ensureNameRow(name)
    if nameRows[name] then return end

    selName[name] = true

    local row = createToggle(farmPicker.List, "? " .. name, true, function(v)
        selName[name] = v
        refreshDropdowns()
    end, true)
    row.Frame.LayoutOrder = 100000

    nameRows[name] = row
    refreshDropdowns()

    local sv = savedName(name)
    if sv ~= nil then row.Set(sv) end
end

--========================================================
-- ESP UI
--========================================================
local espCard = createCard(pages.esp, "👁️", "card_esp", 1)

local espToggle = createToggle(espCard, function() return tr("toggle_esp") end, false, function(v)
    espEnabled = v
    if v then pcall(updateESP) else clearESP() end
end, true)
espToggle.Frame.LayoutOrder = 1

local espPicker = createPicker("card_esp_pick",
    function() setAllRows(espRows, true) end,
    function() setAllRows(espRows, false) end
)

espDD = createDropdownRow(pages.esp, "dd_esp_title", "dd_esp_desc", 2,
    function() return summarize(espRows) end,
    function() espPicker.Open() end
)

local function makeESPRow(luck)
    if espRows[luck] then return end

    espTier[luck] = true

    local row = createToggle(espPicker.List, "Luck " .. fmt(luck), true, function(v)
        espTier[luck] = v
        pcall(updateESP)
        refreshDropdowns()
    end, true)
    row.Frame.LayoutOrder = 10 + math.floor(math.log(luck, 10) * 100 + 0.5)

    espRows[luck] = row
    refreshDropdowns()

    local sv = savedTier("esp", luck)
    if sv ~= nil then row.Set(sv) end
end

local function makePlaceRow(luck)
    if placeRows[luck] then return end

    placeTier[luck] = true

    local row = createToggle(placePicker.List, "Luck " .. fmt(luck), true, function(v)
        placeTier[luck] = v
        refreshDropdowns()
    end, true)
    row.Frame.LayoutOrder = 10 + math.floor(math.log(luck, 10) * 100 + 0.5)

    placeRows[luck] = row
    refreshDropdowns()

    local sv = savedTier("place", luck)
    if sv ~= nil then row.Set(sv) end
end

--========================================================
-- REGISTER LUCK
--========================================================
local function registerLuck(name, luck)
    luckOf[name] = luck

    tierNames[luck] = tierNames[luck] or {}
    if not table.find(tierNames[luck], name) then
        table.insert(tierNames[luck], name)
    end

    ensureTier(luck)
    refreshTier(luck)
    makeESPRow(luck)
    makePlaceRow(luck)

    if nameRows[name] then
        nameRows[name].Frame:Destroy()
        nameRows[name] = nil
        refreshDropdowns()
    end
end

--========================================================
-- SCAN
--========================================================
local function scanIndex()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return end

    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") then
            local luck = parseLuck(d.Text)
            if luck then
                local name = findEggName(d)
                if name then registerLuck(name, luck) end
            end
        end
    end
end

local function scanNames()
    local folder = workspace:FindFirstChild("RenderedEggs")
    if not folder then return end

    for _, child in ipairs(folder:GetChildren()) do
        if not luckOf[child.Name] then
            ensureNameRow(child.Name)
        end
    end
end

local function isSelected(eggName)
    local luck = luckOf[eggName]
    if luck then return selTier[luck] end
    return selName[eggName]
end

local function findEggs()
    local folder = workspace:FindFirstChild("RenderedEggs")
    if not folder then return nil end

    scanNames()

    local root = getRoot()
    local result = {}

    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and not (skipUntil[d] and skipUntil[d] > os.clock()) then
            local model = d
            while model and model.Parent ~= folder do
                model = model.Parent
            end

            if model and isSelected(model.Name) then
                local part = d.Parent
                if part and not part:IsA("BasePart") then
                    part = part:FindFirstAncestorWhichIsA("BasePart")
                end

                if part then
                    local dist = root and (root.Position - part.Position).Magnitude or 0
                    table.insert(result, {prompt = d, part = part, dist = dist})
                end
            end
        end
    end

    table.sort(result, function(a, b) return a.dist < b.dist end)
    return result
end

--========================================================
-- BACKGROUND LOOPS
--========================================================
task.spawn(function()
    while gui.Parent do
        pcall(scanIndex)
        pcall(scanNames)
        task.wait(5)
    end
end)

task.spawn(function()
    while gui.Parent do
        if espEnabled then pcall(updateESP) end
        task.wait(ESP_UPDATE_RATE)
    end
end)

--========================================================
-- AUTO PLACE LOGIC
--========================================================
local PLACE_WORDS = {"place", "plant", "put", "deposit", "วาง", "ใส่"}
local PLACE_SKIP_TIME = 4

-- หาไข่ในกระเป๋า/มือ ที่ตรงกับระดับที่เลือก (จับคู่จากชื่อไข่ที่สแกนได้)
local function findEggTools()
    local result = {}

    local function scan(container)
        if not container then return end
        for _, t in ipairs(container:GetChildren()) do
            if t:IsA("Tool") and not (placeSkip[t] and placeSkip[t] > os.clock()) then
                local lname = t.Name:lower()

                -- 1) จับคู่ชื่อไข่ (เลือกชื่อที่ยาวที่สุด กันชื่อสั้นไปซ้อนชื่อยาว)
                local bestName, bestLuck = nil, nil
                for eggName, luck in pairs(luckOf) do
                    local en = eggName:lower()
                    if lname:find(en, 1, true) and (not bestName or #en > #bestName) then
                        bestName, bestLuck = eggName, luck
                    end
                end

                -- 2) ถ้าไม่เจอชื่อ ลองอ่านตัวเลข Luck จากชื่อไอเทม (เช่น 1.5B)
                if not bestName then
                    for num, unit in t.Name:gmatch("([%d%.]+)%s*([KkMmBbTt])%f[%A]") do
                        local l = parseLuck(num .. unit)
                        if l and placeTier[l] ~= nil then
                            bestName, bestLuck = t.Name, l
                            break
                        end
                    end
                end

                if bestName then
                    if placeTier[bestLuck] then
                        table.insert(result, {tool = t, name = bestName, luck = bestLuck})
                    end
                elseif lname:find("egg", 1, true) or t.Name:find("ไข่", 1, true) then
                    -- 3) ไข่ที่ยังไม่รู้ระดับ จะวางให้เมื่อเลือกทุกระดับไว้
                    local allOn = true
                    for _, on in pairs(placeTier) do
                        if not on then allOn = false break end
                    end
                    if allOn then
                        table.insert(result, {tool = t, name = t.Name, luck = 0})
                    end
                end
            end
        end
    end

    scan(player:FindFirstChildOfClass("Backpack"))
    scan(player.Character)

    return result
end

-- แคชรายการจุดวางไข่ (สแกนทั้งแมพครั้งเดียวแล้วใช้ซ้ำ ลดอาการลัค)
local placePromptCache = {}
local placePromptCacheT = 0
local promptUsed = setmetatable({}, {__mode = "k"})
local placeTries = setmetatable({}, {__mode = "k"})

local function refreshPlacePrompts()
    placePromptCache = {}

    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and not d:FindFirstAncestor("RenderedEggs") then
            local text = (d.ActionText .. " " .. d.ObjectText):lower()
            for _, w in ipairs(PLACE_WORDS) do
                if text:find(w, 1, true) then
                    table.insert(placePromptCache, d)
                    break
                end
            end
        end
    end

    placePromptCacheT = os.clock()
end

-- หาจุดวางที่ใกล้ที่สุด (ข้ามจุดที่เพิ่งวางไปเมื่อกี้ เพื่อให้ไข่ลูกถัดไปไปจุดอื่น)
local function findPlacePrompt(pos)
    if os.clock() - placePromptCacheT > 10 then
        refreshPlacePrompts()
    end

    local function pick()
        local best, bestD = nil, 40
        for _, d in ipairs(placePromptCache) do
            if d.Parent and d.Enabled and not (promptUsed[d] and promptUsed[d] > os.clock()) then
                local part = d.Parent
                if part and not part:IsA("BasePart") then
                    part = part:FindFirstAncestorWhichIsA("BasePart")
                end
                if part then
                    local dist = (part.Position - pos).Magnitude
                    if dist < bestD then best, bestD = d, dist end
                end
            end
        end
        return best
    end

    local best = pick()

    if not best and os.clock() - placePromptCacheT > 1.5 then
        refreshPlacePrompts()
        best = pick()
    end

    return best
end

local function toolSnapshot(t)
    local parts = {t.Name}
    for k, v in pairs(t:GetAttributes()) do
        table.insert(parts, k .. "=" .. tostring(v))
    end
    table.sort(parts)
    return table.concat(parts, "|")
end

-- วางไข่ 1 ลูก คืนค่า true ถ้าควรวางลูกต่อไป
local function placeStep()
    local root = getRoot()
    if not root or root.Anchored then return false end

    if running and homeCFrame and (root.Position - homeCFrame.Position).Magnitude > 30 then
        setPStatus("pstatus_wait")
        return false
    end

    local eggs = findEggTools()
    if #eggs == 0 then
        -- แสดงชื่อไอเทมในกระเป๋า เพื่อช่วยดูว่าทำไมไม่จับคู่กับไข่
        local names = {}
        local bp = player:FindFirstChildOfClass("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and #names < 3 then table.insert(names, t.Name) end
            end
        end

        if #names > 0 then
            setPStatus("pstatus_idle_names", table.concat(names, ", "))
        else
            setPStatus("pstatus_idle")
        end
        return false
    end

    local e = eggs[1]
    setPStatus("pstatus_placing", e.name)

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if e.tool.Parent ~= char then
        if hum then pcall(function() hum:EquipTool(e.tool) end) end
        task.wait(0.25)
    end

    local before = toolSnapshot(e.tool)
    local prompt = findPlacePrompt(root.Position)

    if prompt and fireproximityprompt then
        promptUsed[prompt] = os.clock() + 3

        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 30)
        end)
        pcall(fireproximityprompt, prompt)
    else
        -- ไม่เจอจุดวาง: ลองใช้ไข่ในมือ แล้วข้ามไข่ลูกนี้ชั่วคราว
        pcall(function() e.tool:Activate() end)
        setPStatus("pstatus_noprompt")
        placeSkip[e.tool] = os.clock() + PLACE_SKIP_TIME
        task.wait(0.4)
        return false
    end

    task.wait(0.45)

    -- ถ้าไข่ยังอยู่และไม่มีอะไรเปลี่ยน ลองซ้ำได้ 3 ครั้ง (เผื่อเป็นไข่ที่ซ้อนกันหลายลูก)
    if e.tool.Parent then
        if toolSnapshot(e.tool) == before then
            placeTries[e.tool] = (placeTries[e.tool] or 0) + 1
            if placeTries[e.tool] >= 3 then
                placeSkip[e.tool] = os.clock() + PLACE_SKIP_TIME
                placeTries[e.tool] = nil
            end
        else
            placeTries[e.tool] = nil
        end
    end

    return true
end

local function placeAll()
    for _ = 1, 10 do
        if not placeEnabled then break end
        if not placeStep() then break end
    end
end

-- ตอนไม่ได้เปิดฟาร์ม ให้วางไข่เป็นลูปแยก (ตอนเปิดฟาร์ม จะวางต้นรอบของฟาร์มแทน)
task.spawn(function()
    while gui.Parent do
        if placeEnabled and not running then pcall(placeAll) end
        task.wait(1.5)
    end
end)

--========================================================
-- FARM LOOP
--========================================================
startFarm = function()
    if not userHome then
        local r = getRoot()
        if r then homeCFrame = r.CFrame end
    end

    task.spawn(function()
        local function cycle()
            if placeEnabled then pcall(placeAll) end

            local cur, max = getBasket()
            if cur and max and cur >= max then
                setStatus("status_full")
                task.wait(1)
                return
            end

            local eggs = findEggs()

            if eggs == nil then
                setStatus("status_nofolder")
                task.wait(1)
            elseif #eggs == 0 then
                setStatus("status_none")
                task.wait(1)
            else
                setStatus("status_collect", #eggs)
                collect(eggs[1])
                task.wait(DELAY)
                goHome()
                task.wait(HOME_WAIT)
            end
        end

        while running do
            -- ถ้ามี error กลางรอบ ให้กลับบ้านแล้วทำต่อ (ไม่ให้ฟาร์มหยุดเงียบๆ)
            local ok = pcall(cycle)
            if not ok then
                pcall(goHome)
                task.wait(1)
            end
        end

        goHome()
        setStatus("status_stopped")
    end)
end

--========================================================
-- SETTINGS
--========================================================
local langCard = createCard(pages.settings, "🌐", "card_lang", 1)

local langRow = new("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundTransparency = 1,
    LayoutOrder = 1,
}, langCard)

local thBtn = new("TextButton", {
    Text = "ภาษาไทย",
    Size = UDim2.new(0.5, -4, 1, 0),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
}, langRow)
corner(thBtn, 6)
stroke(thBtn)

local enBtn = new("TextButton", {
    Text = "English",
    Position = UDim2.new(0.5, 4, 0, 0),
    Size = UDim2.new(0.5, -4, 1, 0),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
}, langRow)
corner(enBtn, 6)
stroke(enBtn)

onLang(function()
    thBtn.BackgroundColor3 = (lang == "th") and Theme.Accent or Theme.MainBg
    enBtn.BackgroundColor3 = (lang == "en") and Theme.Accent or Theme.MainBg
end)

local function setLang(l)
    lang = l
    pcall(function()
        if writefile then writefile("apichat_lang.txt", l) end
    end)
    applyLang()
    -- อัปเดตข้อความแถวไข่ที่สร้างแบบ dynamic
    for luck in pairs(tierRows) do refreshTier(luck) end
end

thBtn.MouseButton1Click:Connect(function() setLang("th") end)
enBtn.MouseButton1Click:Connect(function() setLang("en") end)

-- Anti-AFK
do
    local VirtualUser = game:GetService("VirtualUser")
    table.insert(conns, player.Idled:Connect(function()
        if not antiAfkOn then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end))
end

local afkToggle = createToggle(pages.settings, function() return tr("toggle_afk") end, antiAfkOn, function(v)
    antiAfkOn = v
end)
afkToggle.Frame.LayoutOrder = 3

--========================================================
-- SAVE SETTINGS UI
--========================================================
local saveCard = createCard(pages.settings, "💾", "card_save", 2)

local function makeSaveBtn(textKey, color, order, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = color,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        LayoutOrder = order,
    }, saveCard)
    corner(b, 6)
    onLang(function() b.Text = tr(textKey) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local saveStatus = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true,
    LayoutOrder = 3,
}, saveCard)

local saveStatusKey = savedCfg and "save_have" or "save_none"

local function setSaveStatus(key)
    saveStatusKey = key
    saveStatus.Text = tr(key)
end

onLang(function() saveStatus.Text = tr(saveStatusKey) end)

local function collectCfg()
    local cfg = {
        farm = running,
        esp = espEnabled,
        place = placeEnabled,
        afk = antiAfkOn,
        home = (userHome and homeCFrame) and {homeCFrame:GetComponents()} or nil,
        tiers = {farm = {}, esp = {}, place = {}},
        names = {},
    }

    -- เก็บของเดิมไว้ก่อน (ไข่ที่ยังสแกนไม่เจอรอบนี้จะไม่หาย)
    if savedCfg then
        for kind, t in pairs((savedCfg.tiers or {})) do
            if cfg.tiers[kind] then
                for k, v in pairs(t) do cfg.tiers[kind][k] = v end
            end
        end
        for k, v in pairs(savedCfg.names or {}) do cfg.names[k] = v end
    end

    for luck, v in pairs(selTier) do cfg.tiers.farm[luckKey(luck)] = v end
    for luck, v in pairs(espTier) do cfg.tiers.esp[luckKey(luck)] = v end
    for luck, v in pairs(placeTier) do cfg.tiers.place[luckKey(luck)] = v end
    for name, v in pairs(selName) do cfg.names[name] = v end

    return cfg
end

local function saveNow()
    local ok = pcall(function()
        assert(writefile, "no writefile")
        local cfg = collectCfg()
        writefile(SAVE_FILE, HttpService:JSONEncode(cfg))
        savedCfg = cfg
    end)
    setSaveStatus(ok and "save_ok" or "save_fail")
end

local function resetSaved()
    pcall(function()
        if delfile and isfile and isfile(SAVE_FILE) then
            delfile(SAVE_FILE)
        elseif writefile then
            writefile(SAVE_FILE, "{}")
        end
    end)

    savedCfg = nil

    farmToggle.Set(false)
    homeCFrame = nil
    userHome = false
    afkToggle.Set(true)
    espToggle.Set(false)
    placeToggle.Set(false)

    setAllRows(tierRows, true)
    setAllRows(nameRows, true)
    setAllRows(espRows, true)
    setAllRows(placeRows, true)

    setSaveStatus("save_reset")
end

makeSaveBtn("btn_save", Theme.Accent, 1, saveNow)
makeSaveBtn("btn_reset", Color3.fromRGB(150, 50, 50), 2, resetSaved)

--========================================================
-- CHARACTER RESPAWN
--========================================================
player.CharacterAdded:Connect(function()
    task.wait(1)
    if running then endNoclip() end
end)

--========================================================
-- START + INTRO
--========================================================
setPage("home")

local function showWindowNow()
    main.Size = MAIN_SIZE
    main.Visible = true
    mainOpen = true
    logo.Visible = true
end

task.spawn(function()
    local ok = pcall(function()
        showWelcomeBanner()

        local center = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Image = BG_IMAGE,
            ImageTransparency = 1,
            ZIndex = 50,
        }, gui)

        local twIn = TweenService:Create(center,
            TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 180, 0, 180), ImageTransparency = 0})
        twIn:Play()
        twIn.Completed:Wait()
        task.wait(1.2)

        local twOut = TweenService:Create(center,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1})
        twOut:Play()
        twOut.Completed:Wait()
        center:Destroy()

        showMain()
        logo.Visible = true
    end)

    if not ok then showWindowNow() end
end)

task.delay(2, function()
    pcall(scanIndex)
    pcall(scanNames)

    -- โหลดสถานะสวิตช์ที่บันทึกไว้ (เปิดเองให้ ไม่ต้องกดทีละอัน)
    if savedCfg then
        task.wait(0.5)
        if savedCfg.esp then espToggle.Set(true) end
        if savedCfg.place then placeToggle.Set(true) end
        if savedCfg.farm then farmToggle.Set(true) end
        setSaveStatus("save_loaded")
    end
end)

--========================================================
-- CLEANUP + HOTKEY
--========================================================
gui.Destroying:Connect(function()
    running = false
    placeEnabled = false
    pcall(endNoclip)
end)

-- กด RightShift (คอม) เพื่อซ่อน/แสดงเมนู
table.insert(conns, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if mainOpen then hideMain() else showMain() end
    end
end))
