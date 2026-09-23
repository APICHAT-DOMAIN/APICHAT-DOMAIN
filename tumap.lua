--[[========================================================
    ⚡ APICHAT DOMAIN ⚡
    v2.6 - MAXIMUM CLEAN SMOOTH POTATO (ULTRA FLAT)
========================================================]]--

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local StatsService = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local player = Players.LocalPlayer

--========================================================
-- CONFIG
--========================================================

local BG_IMAGE = "rbxassetid://73200153325421"
local DISCORD_INVITE = "https://discord.com/invite/8h4qnh4ev"

local parentGui = (gethui and gethui()) or CoreGui
local SETTINGS_FILE = "APICHAT_DOMAIN_SETTINGS.json"

local Theme = {
    MainBg = Color3.fromRGB(15, 15, 18),
    PanelBg = Color3.fromRGB(26, 26, 32),
    Accent = Color3.fromRGB(130, 90, 255),
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(170, 170, 170),
    Border = Color3.fromRGB(45, 45, 52),
    Green = Color3.fromRGB(50, 220, 130),
    Red = Color3.fromRGB(220, 70, 70),
    Yellow = Color3.fromRGB(255, 200, 50),
}

--========================================================
-- CLEAN OLD UI
--========================================================

pcall(function()
    local old = parentGui:FindFirstChild("ApichatDomain")
    if old then old:Destroy() end
end)

--========================================================
-- STATE
--========================================================

local conns = {}

local walkSpeed = 16
local jumpInfinite = false
local invisibleEnabled = false
local noclipEnabled = false
local godModeEnabled = false
local playerESPEnabled = false
local npcESPEnabled = false
local autoInteract = false
local boostFPSActive = false
local englishMode = false

local espObjects = {}
local npcESPObjects = {}
local savedTransparency = {}

local jumpConnection
local noclipConnection
local godConnection
local autoInteractConnection
local playerESPConnection
local npcESPConnection

--========================================================
-- TRANSLATION SYSTEM
--========================================================

local translations = {
    th = {
        home = "หน้าหลัก",
        player = "ผู้เล่น",
        esp = "มอง / ESP",
        settings = "ตั้งค่า",
        
        homeTitle = "📊 หน้าหลัก",
        playerInfo = "👤 ข้อมูลผู้เล่น",
        mapInfo = "🗺️ ข้อมูลแมพ",
        systemStatus = "⚡ สถานะระบบ",
        
        discordCard = "💬 ชุมชน Discord",
        discordDesc = "เข้าร่วมดิสคอร์ดของเราเพื่อติดตามข่าวสารและสคริปต์ใหม่ๆ!",
        discordBtn = "🔗 คัดลอกลิงก์ Discord",
        discordCopied = "✅คัดลอกลิงก์ Discord แล้ว!",
        
        playerAbility = "⚡ ความสามารถผู้เล่น",
        walkSpeed = "🏃 วิ่งไว",
        infiniteJump = "🦘 กระโดดไม่จำกัด",
        invisible = "👻 หายตัว (บางแมพ)",
        noclip = "🚪 ทะลุกำแพง",
        godMode = "🛡️ อมตะ (บางแมพ)",
        playerWarning = "⚠️ ความสามารถที่เขียนว่า (บางแมพ) ขึ้นอยู่กับระบบของเกมและการตรวจสอบจากเซิร์ฟเวอร์",
        
        espTitle = "👁️ มอง / ESP",
        playerEspToggle = "👁️ มองผู้เล่นทะลุ ESP",
        npcEspToggle = "🤖 มอง NPC ทะลุ ESP",
        espDesc = "👁️ Player ESP = แสดงผู้เล่น\n🤖 NPC ESP = ตรวจจับ Model ที่มี Humanoid (บางแมพ)",
        
        settingsTitle = "⚙️ การตั้งค่า",
        langTitle = "🌐 เปลี่ยนภาษา",
        langDesc = "เลือกภาษาของเมนู APICHAT DOMAIN",
        langBtnEn = "🇬🇧 Switch to English",
        langBtnTh = "🇹🇭 Switch to Thai",
        
        fpsBoostTitle = "🚀 โหมดดินน้ำมันเรียบแบนราบ 100% (Ultra Clean Flat)",
        fpsBoostToggle = "🚀 เปิดโหมดลดแลค (ลบลายทั้งหมด / แบนราบ / สว่างสะอาด)",
        fpsBoostDesc = "🚀 ลบ Texture, Decal, Custom Mesh และแปลงทุกชิ้นส่วนเป็น SmoothPlastic สีเทาสว่าง เรียบเนียนขั้นสุด",
        
        interactTitle = "⚡ การเก็บของ",
        interactToggle = "⚡ หยิบของไว / E (บางแมพ)",
        interactDesc = "⚡ ระบบ E จะค้นหา ProximityPrompt ใกล้ตัวและพยายามกดให้อัตโนมัติ\n⚠️ แต่ละเกมอาจใช้ระบบเก็บของแตกต่างกัน",
        
        saveTitle = "💾 บันทึกการตั้งค่า",
        saveDesc = "ยังไม่มีค่าที่บันทึกไว้",
        saveBtn = "💾 บันทึกการตั้งค่าตอนนี้",
        saveSuccess = "✅ บันทึกการตั้งค่าเรียบร้อยแล้ว",
        saveFail = "⚠️ Executor นี้ไม่รองรับการบันทึกไฟล์",
        autoLoadSuccess = "✅ โหลดค่าที่บันทึกไว้อัตโนมัติแล้ว",
        
        resetBtn = "🗑️ รีเซ็ตทุกอย่าง (ลบที่บันทึกด้วย)",
        resetSuccess = "🗑️ รีเซ็ตทุกอย่างเรียบร้อยแล้ว",
        
        closeTitle = "⚠️ ปิดสคริปต์",
        closeDesc = "ปิด APICHAT DOMAIN และหยุดระบบที่กำลังทำงานทั้งหมด",
        closeBtn = "🔼 ปิดสคริปต์ทั้งหมด",
    },
    en = {
        home = "Home",
        player = "Player",
        esp = "ESP",
        settings = "Settings",
        
        homeTitle = "📊 Home",
        playerInfo = "👤 Player Info",
        mapInfo = "🗺️ Map Info",
        systemStatus = "⚡ System Status",
        
        discordCard = "💬 Discord Community",
        discordDesc = "Join our Discord community for updates and new scripts!",
        discordBtn = "🔗 Copy Discord Invite",
        discordCopied = "✅ Copied Discord Link!",
        
        playerAbility = "⚡ Player Abilities",
        walkSpeed = "🏃 WalkSpeed",
        infiniteJump = "🦘 Infinite Jump",
        invisible = "👻 Invisible (Some Games)",
        noclip = "Noclip",
        godMode = "🛡️ God Mode (Some Games)",
        playerWarning = "⚠️ Abilities marked with (Some Games) depend on game systems and server-side checks.",
        
        espTitle = "👁️ Visual / ESP",
        playerEspToggle = "👁️ Player ESP",
        npcEspToggle = "🤖 NPC ESP",
        espDesc = "👁️ Player ESP = Highlight players\n🤖 NPC ESP = Detect models with Humanoid (Some Games)",
        
        settingsTitle = "⚙️ Settings",
        langTitle = "🌐 Language",
        langDesc = "Select APICHAT DOMAIN menu language",
        langBtnEn = "🇬🇧 Switch to English",
        langBtnTh = "🇹🇭 Switch to Thai",
        
        fpsBoostTitle = "🚀 Ultra Clean Flat Potato Mode",
        fpsBoostToggle = "🚀 Enable Ultra Clean Flat (Removes All Textures / Pure Smooth)",
        fpsBoostDesc = "🚀 Removes textures, decals, meshes and turns everything into flat bright gray SmoothPlastic.\n⚠️ Maximizes FPS.",
        
        interactTitle = "⚡ Auto Interaction",
        interactToggle = "⚡ Fast Interact / E (Some Games)",
        interactDesc = "⚡ Auto searches nearby ProximityPrompts and triggers them automatically.\n⚠️ Each game may use different interaction systems.",
        
        saveTitle = "💾 Save Settings",
        saveDesc = "No saved settings found.",
        saveBtn = "💾 Save Settings Now",
        saveSuccess = "✅ Settings saved successfully.",
        saveFail = "⚠️ This executor does not support file saving.",
        autoLoadSuccess = "✅ Auto-loaded saved settings.",
        
        resetBtn = "🗑️ Reset All (Clear Saves)",
        resetSuccess = "🗑️ Reset everything successfully.",
        
        closeTitle = "⚠️ Close Script",
        closeDesc = "Close APICHAT DOMAIN and stop all running processes.",
        closeBtn = "🔼 Close All Scripts",
    }
}

local function t(key)
    local lang = englishMode and "en" or "th"
    return translations[lang][key] or key
end

local uiTexts = {}

local function registerText(obj, key, typeProp)
    table.insert(uiTexts, {Object = obj, Key = key, Prop = typeProp or "Text"})
    obj[typeProp or "Text"] = t(key)
end

local function updateAllTexts()
    for _, item in ipairs(uiTexts) do
        if item.Object and item.Object.Parent then
            item.Object[item.Prop] = t(item.Key)
        end
    end
end

--========================================================
-- CONTROLS & REFERENCES
--========================================================

local walkSpeedControl
local jumpControl
local invisibleEnabledToggle
local noclipControl
local godControl
local playerESPControl
local npcESPControl
local autoInteractControl
local fpsBoostControl
local languageBtn
local discordStatusLabel

--========================================================
-- HELPERS
--========================================================

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(obj, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, obj)
end

local function stroke(obj, color, thickness)
    return new("UIStroke", { Color = color or Theme.Border, Thickness = thickness or 1 }, obj)
end

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

--========================================================
-- GUI
--========================================================

local gui = new("ScreenGui", {
    Name = "ApichatDomain",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parentGui)

gui.Destroying:Connect(function()
    for _, c in ipairs(conns) do
        pcall(function() c:Disconnect() end)
    end
    if jumpConnection then pcall(function() jumpConnection:Disconnect() end) end
    if noclipConnection then pcall(function() noclipConnection:Disconnect() end) end
    if godConnection then pcall(function() godConnection:Disconnect() end) end
    if autoInteractConnection then pcall(function() autoInteractConnection:Disconnect() end) end
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

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 12),
        BackgroundTransparency = 1,
        Text = "ยินดีต้อนรับสู่ ⚡ APICHAT DOMAIN",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, card)

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

    TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -340, 0.85, 0)
    }):Play()

    task.delay(3.5, function()
        if not card.Parent then return end
        local out = TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0.85, 0)
        })
        out:Play()
        out.Completed:Connect(function()
            if card then card:Destroy() end
        end)
    end)
end

--========================================================
-- LOGO
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

local mainScale = new("UIScale", {}, main)

local function fitScale()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    mainScale.Scale = math.clamp(math.min(vp.X / 570, vp.Y / 410), 0.5, 1)
end

fitScale()
if Workspace.CurrentCamera then
    table.insert(conns, Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale))
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
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = MAIN_SIZE
    }):Play()
end

local function hideMain()
    mainOpen = false
    local tw = TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tw:Play()
    tw.Completed:Connect(function()
        if not mainOpen then main.Visible = false end
    end)
end

--========================================================
-- TITLE BAR
--========================================================

local titleBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
}, main)

new("TextLabel", {
    Position = UDim2.new(0, 16, 0, 0),
    Size = UDim2.new(0.7, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "⚡ APICHAT DOMAIN ⚡",
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

--========================================================
-- DRAG LOGO
--========================================================

do
    local dragging = false
    local moved = false
    local dragStart, startPos

    logo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = logo.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
-- SIDEBAR & CONTENT
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

new("UIPadding", { PaddingTop = UDim.new(0, 10) }, sidebar)

local contentArea = new("Frame", {
    Position = UDim2.new(0, 162, 0, 45),
    Size = UDim2.new(1, -174, 1, -57),
    BackgroundTransparency = 1,
}, main)

local function createPage()
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
    home = createPage(),
    player = createPage(),
    esp = createPage(),
    settings = createPage(),
}

local tabBtns = {}

local function setPage(name)
    for key, page in pairs(pages) do
        page.Visible = key == name
    end
    for key, btn in pairs(tabBtns) do
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = key == name and 0.1 or 1,
            TextColor3 = key == name and Theme.Text or Theme.SubText
        }):Play()
    end
end

local function addTab(key, icon, textKey, order)
    local btn = new("TextButton", {
        Size = UDim2.new(1, -16, 0, 36),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
    }, sidebar)

    corner(btn, 6)
    registerText(btn, textKey)
    task.spawn(function()
        while btn.Parent do
            btn.Text = "  " .. icon .. "  " .. t(textKey)
            task.wait(0.5)
        end
    end)

    tabBtns[key] = btn
    btn.MouseButton1Click:Connect(function() setPage(key) end)
end

addTab("home", "📊", "home", 1)
addTab("player", "⚡", "player", 2)
addTab("esp", "👁️", "esp", 3)
addTab("settings", "⚙️", "settings", 4)

--========================================================
-- UI BUILDERS
--========================================================

local function createCard(parent, icon, titleKey, order, isTitleDynamic)
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

    local titleLabel = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    }, card)

    if isTitleDynamic then
        registerText(titleLabel, titleKey)
        task.spawn(function()
            while titleLabel.Parent do
                titleLabel.Text = icon .. " " .. t(titleKey)
                task.wait(0.5)
            end
        end)
    else
        titleLabel.Text = icon .. " " .. titleKey
    end

    return card
end

local function createInfo(parent, text, order, dynamicKey)
    local label = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = order or 1,
    }, parent)

    if dynamicKey then
        registerText(label, dynamicKey)
    end
    return label
end

local function createToggle(parent, textKey, default, callback)
    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.MainBg,
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

    registerText(label, textKey)

    local switch = new("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        BackgroundColor3 = default and Theme.Accent or Theme.Border,
        BorderSizePixel = 0,
    }, frame)

    corner(switch, 100)

    local dot = new("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, switch)

    corner(dot, 100)

    local state = default

    local function render()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        TweenService:Create(switch, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Accent or Theme.Border
        }):Play()
    end

    local obj = {}
    function obj.Set(v, execute)
        state = v
        render()
        if execute ~= false then callback(v) end
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

    render()
    return obj
end

local function createSlider(parent, titleKey, minVal, maxVal, defaultVal, callback)
    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Theme.MainBg,
        BorderSizePixel = 0,
    }, parent)

    corner(frame, 8)
    stroke(frame)

    local value = defaultVal
    local label = new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 25),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local function refreshSliderText()
        label.Text = t(titleKey) .. ": " .. value
    end
    refreshSliderText()

    task.spawn(function()
        while label.Parent do
            refreshSliderText()
            task.wait(0.5)
        end
    end)

    local bar = new("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = Theme.Border,
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
    local function press(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
    end

    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor(minVal + (maxVal - minVal) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        refreshSliderText()
        callback(value)
    end

    knob.InputBegan:Connect(function(input) if press(input) then dragging = true end end)
    bar.InputBegan:Connect(function(input) if press(input) then dragging = true; update(input) end end)

    table.insert(conns, UserInputService.InputEnded:Connect(function(input) if press(input) then dragging = false end end))
    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end))

    local obj = {}
    function obj.Set(v, execute)
        value = math.clamp(tonumber(v) or defaultVal, minVal, maxVal)
        local pos = (value - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        refreshSliderText()
        if execute ~= false then callback(value) end
    end
    function obj.Get() return value end
    return obj
end

--========================================================
-- HOME PAGE
--========================================================

local homeCard = createCard(pages.home, "👤", "playerInfo", 1, true)

local avatar = new("ImageLabel", {
    Size = UDim2.new(0, 50, 0, 50),
    BackgroundColor3 = Theme.MainBg,
    BorderSizePixel = 0,
}, homeCard)

corner(avatar, 100)
pcall(function()
    avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)

createInfo(homeCard, "ชื่อ: " .. player.DisplayName .. "\nUsername: @" .. player.Name .. "\nUserId: " .. player.UserId, 2)

local mapCard = createCard(pages.home, "🗺️", "mapInfo", 2, true)
local mapName = "กำลังโหลด..."
pcall(function()
    mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)
createInfo(mapCard, "แมพ: " .. mapName .. "\nPlace ID: " .. tostring(game.PlaceId) .. "\nผู้เล่น: " .. tostring(#Players:GetPlayers()), 1)

local perfCard = createCard(pages.home, "⚡", "systemStatus", 3, true)
local fpsLabel = createInfo(perfCard, "🎮 FPS: 0\n📶 Ping: 0 ms", 1)

local frames = 0
local fps = 0
table.insert(conns, RunService.RenderStepped:Connect(function() frames += 1 end))

task.spawn(function()
    while gui.Parent do
        task.wait(1)
        fps = frames
        frames = 0
        local ping = 0
        pcall(function()
            ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        fpsLabel.Text = "🎮 FPS: " .. fps .. "\n📶 Ping: " .. ping .. " ms"
    end
end)

local discordCard = createCard(pages.home, "💬", "discordCard", 4, true)
discordStatusLabel = createInfo(discordCard, t("discordDesc"), 1, "discordDesc")

local discordBtn = new("TextButton", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Text = t("discordBtn"),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, discordCard)

corner(discordBtn, 8)
task.spawn(function()
    while discordBtn.Parent do
        discordBtn.Text = t("discordBtn")
        task.wait(0.5)
    end
end)

discordBtn.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard(DISCORD_INVITE) end end)
    discordStatusLabel.Text = t("discordCopied")
    discordStatusLabel.TextColor3 = Theme.Green
    task.delay(2.5, function()
        if discordStatusLabel and discordStatusLabel.Parent then
            discordStatusLabel.Text = t("discordDesc")
            discordStatusLabel.TextColor3 = Theme.SubText
        end
    end)
end)

--========================================================
-- PLAYER PAGE
--========================================================

local playerCard = createCard(pages.player, "⚡", "playerAbility", 1, true)

walkSpeedControl = createSlider(playerCard, "walkSpeed", 1, 1000, 16, function(v)
    walkSpeed = v
    local hum = getHumanoid()
    if hum then pcall(function() hum.WalkSpeed = v end) end
end)

jumpControl = createToggle(playerCard, "infiniteJump", false, function(v)
    jumpInfinite = v
    if v then
        if jumpConnection then jumpConnection:Disconnect() end
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            local hum = getHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if jumpConnection then jumpConnection:Disconnect(); jumpConnection = nil end
    end
end)

local function setInvisible(enabled)
    local char = getCharacter()
    if not char then return end
    if enabled then
        savedTransparency = {}
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                savedTransparency[obj] = obj.Transparency
                pcall(function() obj.Transparency = 1 end)
            end
        end
    else
        for obj, value in pairs(savedTransparency) do
            if obj and obj.Parent then
                pcall(function() obj.Transparency = value end)
            end
        end
        savedTransparency = {}
    end
end

invisibleEnabledToggle = createToggle(playerCard, "invisible", false, function(v)
    invisibleEnabled = v
    setInvisible(v)
end)

local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    local char = getCharacter()
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then pcall(function() obj.CanCollide = true end) end
        end
    end
end

local function startNoclip()
    stopNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = getCharacter()
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then pcall(function() obj.CanCollide = false end) end
        end
    end)
end

noclipControl = createToggle(playerCard, "noclip", false, function(v)
    noclipEnabled = v
    if v then startNoclip() else stopNoclip() end
end)

local function applyGodMode()
    local hum = getHumanoid()
    if not hum then return end
    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end)
end

godControl = createToggle(playerCard, "godMode", false, function(v)
    godModeEnabled = v
    if godConnection then godConnection:Disconnect(); godConnection = nil end
    if v then
        applyGodMode()
        godConnection = RunService.Heartbeat:Connect(function()
            if godModeEnabled then applyGodMode() end
        end)
    end
end)

createInfo(playerCard, t("playerWarning"), 10, "playerWarning")

--========================================================
-- ESP PAGE
--========================================================

local espCard = createCard(pages.esp, "👁️", "espTitle", 1, true)

local function removePlayerESP(plr)
    local data = espObjects[plr]
    if not data then return end
    if data.highlight then pcall(function() data.highlight:Destroy() end) end
    if data.billboard then pcall(function() data.billboard:Destroy() end) end
    espObjects[plr] = nil
end

local function createPlayerESP(plr)
    if plr == player or espObjects[plr] then return end
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ApichatPlayerESP"
    highlight.Adornee = char
    highlight.FillColor = Theme.Accent
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ApichatPlayerESPText"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 180, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "👤 " .. plr.DisplayName .. "\n@" .. plr.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard

    espObjects[plr] = { highlight = highlight, billboard = billboard }
end

local function clearPlayerESP()
    for plr in pairs(espObjects) do removePlayerESP(plr) end
end

playerESPControl = createToggle(espCard, "playerEspToggle", false, function(v)
    playerESPEnabled = v
    if not v then clearPlayerESP() end
end)

local function isNPC(model)
    if not model:IsA("Model") or Players:GetPlayerFromCharacter(model) then return false end
    return model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function removeNPCESP(model)
    local data = npcESPObjects[model]
    if not data then return end
    if data.highlight then pcall(function() data.highlight:Destroy() end) end
    if data.billboard then pcall(function() data.billboard:Destroy() end) end
    npcESPObjects[model] = nil
end

local function createNPCESP(model)
    if npcESPObjects[model] or not isNPC(model) then return end
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ApichatNPCESP"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 90, 90)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ApichatNPCESPText"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 160, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🤖 " .. model.Name
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard

    npcESPObjects[model] = { highlight = highlight, billboard = billboard }
end

local function clearNPCESP()
    for model in pairs(npcESPObjects) do removeNPCESP(model) end
end

npcESPControl = createToggle(espCard, "npcEspToggle", false, function(v)
    npcESPEnabled = v
    if not v then clearNPCESP() end
end)

createInfo(espCard, t("espDesc"), 3, "espDesc")

task.spawn(function()
    while gui.Parent do
        if playerESPEnabled then
            pcall(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then createPlayerESP(plr) end
                end
            end)
        end
        if npcESPEnabled then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and isNPC(obj) then createNPCESP(obj) end
                end
            end)
        end
        task.wait(0.5)
    end
end)

--========================================================
-- SETTINGS PAGE (ULTRA CLEAN FLAT POTATO)
--========================================================

local settingsCard = createCard(pages.settings, "⚙️", "settingsTitle", 1, true)

local fpsBoostCard = createCard(pages.settings, "🚀", "fpsBoostTitle", 2, true)
fpsBoostControl = createToggle(
    fpsBoostCard,
    "fpsBoostToggle",
    false,
    function(v)
        boostFPSActive = v
        pcall(function()
            if v then
                -- 1. ตั้งค่าแสงสว่างเคลียร์เต็มที่ มองเห็นชัดเจน
                Lighting.GlobalShadows = false
                Lighting.Brightness = 3
                Lighting.ClockTime = 12
                Lighting.FogEnd = 999999
                Lighting.GeographicLatitude = 0
                Lighting.Ambient = Color3.fromRGB(220, 220, 220)
                Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
                
                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
                        child:Destroy()
                    end
                end

                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end)

                -- 2. เคลียร์น้ำใน Terrain ให้ใสเรียบแบน
                if Terrain then
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveTransparency = 1
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 1
                    Terrain.Decoration = false
                end

                -- 3. ลบ Decal, Texture, Mesh และวัตถุที่ไม่จำเป็นออกทั้งหมด บังคับทุกชิ้นเป็น SmoothPlastic สีเทาสว่างแบนเรียบ
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Reflectance = 0
                        obj.CastShadow = false
                        obj.Color = Color3.fromRGB(215, 215, 215)
                    elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SpecialMesh") or obj:IsA("MeshPart") then
                        pcall(function() obj:Destroy() end)
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Beam") or obj:IsA("Explosion") then
                        pcall(function() obj:Destroy() end)
                    elseif obj:IsA("Sound") then
                        pcall(function() obj:Stop() end)
                    end
                end
            else
                Lighting.GlobalShadows = true
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(0, 0, 0)
                Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                end)
            end
        end)
    end
)
createInfo(fpsBoostCard, t("fpsBoostDesc"), 2, "fpsBoostDesc")

local languageCard = createCard(pages.settings, "🌐", "langTitle", 3, true)
createInfo(languageCard, t("langDesc"), 1, "langDesc")

languageBtn = new("TextButton", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Text = t("langBtnEn"),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, languageCard)
corner(languageBtn, 8)

languageBtn.MouseButton1Click:Connect(function()
    englishMode = not englishMode
    languageBtn.Text = englishMode and t("langBtnTh") or t("langBtnEn")
    updateAllTexts()
end)

local interactCard = createCard(pages.settings, "⚡", "interactTitle", 4, true)
autoInteractControl = createToggle(interactCard, "interactToggle", false, function(v)
    autoInteract = v
    if v then
        autoInteractConnection = RunService.Heartbeat:Connect(function()
            if not autoInteract then return end
            local root = getRoot()
            if not root then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local parent = obj.Parent
                    local part = parent and (parent:IsA("BasePart") and parent or parent:FindFirstAncestorWhichIsA("BasePart"))
                    if part and (root.Position - part.Position).Magnitude <= math.max(obj.MaxActivationDistance, 15) then
                        pcall(function()
                            obj.HoldDuration = 0
                            if fireproximityprompt then fireproximityprompt(obj) end
                        end)
                    end
                end
            end
        end)
    else
        if autoInteractConnection then autoInteractConnection:Disconnect(); autoInteractConnection = nil end
    end
end)
createInfo(interactCard, t("interactDesc"), 3, "interactDesc")

local saveCard = createCard(pages.settings, "💾", "saveTitle", 5, true)
local saveStatus = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundTransparency = 1,
    Text = t("saveDesc"),
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
}, saveCard)
registerText(saveStatus, "saveDesc")

local function saveSettings()
    if not writefile then return false end
    return pcall(function()
        local data = {
            walkSpeed = walkSpeed,
            jumpInfinite = jumpInfinite,
            invisibleEnabled = invisibleEnabled,
            noclipEnabled = noclipEnabled,
            godModeEnabled = godModeEnabled,
            playerESPEnabled = playerESPEnabled,
            npcESPEnabled = npcESPEnabled,
            autoInteract = autoInteract,
            boostFPSActive = boostFPSActive,
            englishMode = englishMode
        }
        writefile(SETTINGS_FILE, HttpService:JSONEncode(data))
    end)
end

local saveBtn = new("TextButton", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Text = t("saveBtn"),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, saveCard)
registerText(saveBtn, "saveBtn")
corner(saveBtn, 8)

saveBtn.MouseButton1Click:Connect(function()
    if saveSettings() then
        saveStatus.Key = "saveSuccess"
        saveStatus.Text = t("saveSuccess")
        saveStatus.TextColor3 = Theme.Green
    else
        saveStatus.Key = "saveFail"
        saveStatus.Text = t("saveFail")
        saveStatus.TextColor3 = Theme.Yellow
    end
end)

local resetBtn = new("TextButton", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Theme.Red,
    BorderSizePixel = 0,
    Text = t("resetBtn"),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, saveCard)
registerText(resetBtn, "resetBtn")
corner(resetBtn, 8)

resetBtn.MouseButton1Click:Connect(function()
    walkSpeed = 16
    if walkSpeedControl then walkSpeedControl.Set(16, false) end
    local hum = getHumanoid()
    if hum then pcall(function() hum.WalkSpeed = 16 end) end
    
    jumpInfinite = false
    if jumpControl then jumpControl.Set(false, false) end
    if jumpConnection then jumpConnection:Disconnect(); jumpConnection = nil end
    
    invisibleEnabled = false
    if invisibleEnabledToggle then invisibleEnabledToggle.Set(false, false) end
    setInvisible(false)
    
    noclipEnabled = false
    if noclipControl then noclipControl.Set(false, false) end
    stopNoclip()
    
    godModeEnabled = false
    if godControl then godControl.Set(false, false) end
    if godConnection then godConnection:Disconnect(); godConnection = nil end
    
    playerESPEnabled = false
    if playerESPControl then playerESPControl.Set(false, false) end
    clearPlayerESP()
    
    npcESPEnabled = false
    if npcESPControl then npcESPControl.Set(false, false) end
    clearNPCESP()
    
    autoInteract = false
    if autoInteractControl then autoInteractControl.Set(false, false) end
    if autoInteractConnection then autoInteractConnection:Disconnect(); autoInteractConnection = nil end
    
    boostFPSActive = false
    if fpsBoostControl then fpsBoostControl.Set(false, false) end
    
    englishMode = false
    languageBtn.Text = t("langBtnEn")
    updateAllTexts()
    
    if isfile and delfile then
        pcall(function() if isfile(SETTINGS_FILE) then delfile(SETTINGS_FILE) end end)
    end
    
    saveStatus.Key = "resetSuccess"
    saveStatus.Text = t("resetSuccess")
    saveStatus.TextColor3 = Theme.Green
end)

local closeCard = createCard(pages.settings, "⚠️", "closeTitle", 6, true)
createInfo(closeCard, t("closeDesc"), 1, "closeDesc")

local closeAllBtn = new("TextButton", {
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = Theme.Red,
    BorderSizePixel = 0,
    Text = t("closeBtn"),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
}, closeCard)
registerText(closeAllBtn, "closeBtn")
corner(closeAllBtn, 8)

closeAllBtn.MouseButton1Click:Connect(function()
    pcall(function() gui:Destroy() end)
end)

-- Toggle Menu Key
table.insert(conns, UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        if mainOpen then hideMain() else showMain() end
    end
end))

-- Auto Load Settings
task.defer(function()
    task.wait(0.5)
    if not readfile or not isfile or not isfile(SETTINGS_FILE) then return end
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
    if success and type(data) == "table" then
        if data.walkSpeed then walkSpeedControl.Set(data.walkSpeed, true) end
        if data.jumpInfinite then jumpControl.Set(true, true) end
        if data.invisibleEnabled then invisibleEnabledToggle.Set(true, true) end
        if data.noclipEnabled then noclipControl.Set(true, true) end
        if data.godModeEnabled then godControl.Set(true, true) end
        if data.playerESPEnabled then playerESPControl.Set(true, true) end
        if data.npcESPEnabled then npcESPControl.Set(true, true) end
        if data.autoInteract then autoInteractControl.Set(true, true) end
        if data.boostFPSActive then fpsBoostControl.Set(true, true) end
        if data.englishMode then
            englishMode = true
            languageBtn.Text = t("langBtnTh")
            updateAllTexts()
        end
        saveStatus.Key = "autoLoadSuccess"
        saveStatus.Text = t("autoLoadSuccess")
        saveStatus.TextColor3 = Theme.Green
    end
end)

setPage("home")

task.spawn(function()
    pcall(function()
        showWelcomeBanner()
        showMain()
        logo.Visible = true
    end)
end)

print("⚡ APICHAT DOMAIN v2.6 Loaded Successfully!")
