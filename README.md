--[[========================================================
    ⚡ APICHAT DOMAIN v3.4 ⚡
    เพิ่ม:
    🛡️ Share / Record Protect
    - ซ่อน UI ทั้งหมดเมื่อเปิดโหมด
    - ระบบเบื้องหลังยังทำงานต่อ
    - RightShift = แสดง/ซ่อน UI
    - เพิ่มปุ่มใน Settings
========================================================]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StatsService = game:GetService("Stats")
local MarketPlaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local parentGui = (gethui and gethui()) or CoreGui
local env = (getgenv and getgenv()) or _G

if env.ApichatUnload then
    pcall(env.ApichatUnload)
end

pcall(function()
    for _, root in ipairs({CoreGui, parentGui}) do
        local old = root:FindFirstChild("ApichatDomainRGB")
        if old then
            old:Destroy()
        end
    end
end)

local conns = {}

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(conns, c)
    return c
end

local Theme = {
    MainBg = Color3.fromRGB(15, 15, 18),
    PanelBg = Color3.fromRGB(26, 26, 32),
    Accent = Color3.fromRGB(130, 90, 255),
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(170, 170, 170),
    Border = Color3.fromRGB(45, 45, 52),
}

local CurrentLang = "TH"

local Loc = {
    TH = {
        WelcomeTitle = "ยินดีต้อนรับสู่ ⚡ APICHAT DOMAIN",
        PlayerTitle = "👤 ข้อมูลผู้เล่น (Stats)",
        MapTitle = "🗺 ข้อมูลแมพ (Map)",
        PerfTitle = "⚡ สถานะระบบ (Perf)",

        TabInfo = "หน้าหลัก",
        TabCombat = "ล็อคเป้า & ESP",
        TabMisc = "ฟังก์ชันเสริม",
        TabSettings = "ตั้งค่า",

        Aimbot = "🎯 ล็อคเป้ากล้อง (Aimbot)",
        WallCheck = "🧱 เช็คกำแพง (Wall Check)",
        AimbotTarget = "🎯 ตำแหน่งล็อคเป้า",
        TargetHead = "หัว (Head)",
        TargetTorso = "ตัว (Torso)",
        TeamCheck = "🛡 ละเว้นเพื่อนร่วมทีม (Team Check)",

        BoxESP = "📦 มองทะลุ (Box ESP)",
        NameESP = "🏷 แสดงชื่อ (Name ESP)",
        DistESP = "📏 ระยะห่าง (Distance)",
        SkelESP = "🦴 โครงกระดูก (Skeleton)",
        HealthESP = "🩸 หลอดเลือด (Health)",
        RGBESP = "🌈 สีรุ้ง RGB (ESP)",
        FOVToggle = "⭕ แสดงวงกลม FOV",
        RGBFOV = "🌈 สีรุ้ง RGB (FOV)",
        FOVSize = "📏 ขนาดวง FOV",
        Tracers = "⚡ เส้นนำทาง (Tracers)",
        RGBTracers = "🌈 สีรุ้ง RGB (Tracers)",

        WalkSpeedToggle = "🏃 วิ่งไว (เสี่ยง)",
        WalkSpeedSlider = "🏃 ความเร็ววิ่ง",
        JumpPowerToggle = "🦘 กระโดดสูง (เสี่ยง)",
        JumpPowerSlider = "🦘 ความสูงกระโดด",
        NoclipToggle = "👻 ทะลุกำแพง Noclip (เสี่ยง)",

        LangLabel = "🌐 เปลี่ยนภาษา",
        LangBtn = "🇬🇧 Switch to English",

        SaveTitle = "💾 บันทึกการตั้งค่า",
        BtnSave = "💾 บันทึกการตั้งค่าตอนนี้",
        BtnReset = "🗑 รีเซ็ตทุกอย่าง (ลบที่บันทึกด้วย)",
        BtnUnload = "⏏ ปิดสคริปทั้งหมด",

        SaveNone = "ยังไม่มีค่าที่บันทึกไว้",
        SaveHave = "มีค่าที่บันทึกไว้ (โหลดอัตโนมัติตอนรัน)",
        SaveOK = "บันทึกแล้ว ครั้งหน้าจะโหลดให้อัตโนมัติ",
        SaveFail = "บันทึกไม่ได้ (ตัวรันสคริปต์ไม่รองรับไฟล์)",
        ResetOK = "รีเซ็ตทุกอย่างและลบค่าที่บันทึกแล้ว",

        ShareProtect = "🛡 ซ่อน UI ตอนแชร์/อัดจอ",
        ShareProtectDesc = "ซ่อน UI ทั้งหมด แต่ระบบเบื้องหลังยังทำงาน",
        ShareProtectHotkey = "⌨️ RightShift = แสดง/ซ่อน UI",

        AimPlayers = "🎯 เลือกผู้เล่นที่จะล็อค",
        AimPlayersDesc = "กดเพื่อเลือกผู้เล่น (ค่าเริ่มต้น: ทั้งหมด)",
        PickerTitle = "🎯 รายชื่อผู้เล่นในเซิร์ฟ",
        BtnAll = "เลือกทั้งหมด",
        BtnNone = "ไม่เลือกเลย",

        DdAll = "All (ทั้งหมด)",
        DdNone = "None (ไม่เลือก)",
        DdSome = "เลือก %d/%d",
        DdEmpty = "ไม่มีผู้เล่นอื่น",

        PickerHint = "เปิด = ล็อคคนนี้  |  ปิด = ข้าม",
        NamePrefix = "ชื่อผู้เล่น: ",
        MapPrefix = "ชื่อแมพ: ",
        PlaceID = "Place ID: ",
        ServerPlayers = "จำนวนผู้เล่น: ",
    },

    EN = {
        WelcomeTitle = "Welcome to ⚡ APICHAT DOMAIN",
        PlayerTitle = "👤 Player Stats",
        MapTitle = "🗺 Map Info",
        PerfTitle = "⚡ Performance",

        TabInfo = "Home",
        TabCombat = "Combat & ESP",
        TabMisc = "Misc & Movement",
        TabSettings = "Settings",

        Aimbot = "🎯 Camera Aimbot",
        WallCheck = "🧱 Wall Check (Visible Only)",
        AimbotTarget = "🎯 Aimbot Target",
        TargetHead = "Head",
        TargetTorso = "Torso",
        TeamCheck = "🛡 Team Check",

        BoxESP = "📦 Box ESP",
        NameESP = "🏷 Name ESP",
        DistESP = "📏 Distance",
        SkelESP = "🦴 Skeleton",
        HealthESP = "🩸 Health",
        RGBESP = "🌈 RGB Mode (ESP)",
        FOVToggle = "⭕ Show FOV Circle",
        RGBFOV = "🌈 RGB Mode (FOV)",
        FOVSize = "📏 FOV Radius",
        Tracers = "⚡ Tracers",
        RGBTracers = "🌈 RGB Mode (Tracers)",

        WalkSpeedToggle = "🏃 WalkSpeed (RISKY)",
        WalkSpeedSlider = "🏃 Speed Value",
        JumpPowerToggle = "🦘 High Jump (RISKY)",
        JumpPowerSlider = "🦘 Jump Height",
        NoclipToggle = "👻 Noclip / Walk Through Walls (RISKY)",

        LangLabel = "🌐 Language",
        LangBtn = "🇹🇭 เปลี่ยนเป็นภาษาไทย",

        SaveTitle = "💾 Save Settings",
        BtnSave = "💾 Save current settings",
        BtnReset = "🗑 Reset everything (and delete saved)",
        BtnUnload = "⏏ Unload script",

        SaveNone = "No saved settings yet",
        SaveHave = "Saved settings found (auto-loaded on run)",
        SaveOK = "Saved. It will load automatically next time",
        SaveFail = "Could not save (executor has no file support)",
        ResetOK = "Everything reset and saved file deleted",

        ShareProtect = "🛡 Hide UI During Share/Recording",
        ShareProtectDesc = "Hide all UI while background systems continue",
        ShareProtectHotkey = "⌨️ RightShift = Show/Hide UI",

        AimPlayers = "🎯 Players to aim at",
        AimPlayersDesc = "Tap to choose players (default: all)",
        PickerTitle = "🎯 Select Target Players",
        BtnAll = "Select All",
        BtnNone = "Select None",

        DdAll = "All",
        DdNone = "None",
        DdSome = "%d/%d Selected",
        DdEmpty = "No other players",

        PickerHint = "On = aim at them  |  Off = skip",
        NamePrefix = "Player: ",
        MapPrefix = "Map: ",
        PlaceID = "Place ID: ",
        ServerPlayers = "Players: ",
    }
}

local function tr(key)
    return (Loc[CurrentLang] and Loc[CurrentLang][key]) or key
end

local langHooks = {}

local function onLang(fn)
    table.insert(langHooks, fn)
    pcall(fn)
end

local function applyLang()
    for _, fn in ipairs(langHooks) do
        pcall(fn)
    end
end

--========================================================
-- SETTINGS
--========================================================

local Defaults = {
    AimbotEnabled = false,
    AimbotSmoothness = 0.25,
    AimbotTarget = "Head",
    WallCheckEnabled = true,
    TeamCheckEnabled = true,

    ESPEnabled = false,
    ESPRGB = true,
    NameEnabled = true,
    DistanceEnabled = true,
    SkeletonEnabled = true,
    HealthEnabled = true,

    FOVEnabled = true,
    FOVRadius = 150,
    FOVRGB = true,

    TracersEnabled = false,
    TracersRGB = true,

    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,

    JumpPowerEnabled = false,
    JumpPowerValue = 50,

    NoclipEnabled = false,

    RGBSpeed = 3,

    -- 🛡️ Share / Record Protect
    ShareProtectEnabled = false,
}

local Settings = {}

for k, v in pairs(Defaults) do
    Settings[k] = v
end

local SAVE_FILE = "apichat_domain_settings.json"
local hasSaved = false

pcall(function()
    if isfile and readfile and isfile(SAVE_FILE) then
        local data = HttpService:JSONDecode(readfile(SAVE_FILE))

        if type(data) == "table" then
            hasSaved = true

            for k, v in pairs(data.settings or {}) do
                if Settings[k] ~= nil and type(v) == type(Settings[k]) then
                    Settings[k] = v
                end
            end

            if data.lang == "TH" or data.lang == "EN" then
                CurrentLang = data.lang
            end
        end
    end
end)

--========================================================
-- UI HELPERS
--========================================================

local function mk(class, props, parent)
    local o = Instance.new(class)

    for k, v in pairs(props or {}) do
        o[k] = v
    end

    o.Parent = parent
    return o
end

local function corner(o, r)
    return mk("UICorner", {
        CornerRadius = UDim.new(0, r or 8)
    }, o)
end

local function stroke(o, c, t)
    return mk("UIStroke", {
        Color = c or Theme.Border,
        Thickness = t or 1
    }, o)
end

--========================================================
-- MAIN SCREEN GUI
--========================================================

local ScreenGui = mk("ScreenGui", {
    Name = "ApichatDomainRGB",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, parentGui)

local VisualContainer = mk("Folder", {}, ScreenGui)

--========================================================
-- 🛡️ SHARE PROTECT VARIABLES
--========================================================

local ShareProtectEnabled = false
local ShareProtectHotkey = Enum.KeyCode.RightShift

local MAIN_SIZE = UDim2.new(0, 540, 0, 380)
local mainOpen = false

--========================================================
-- 🛡️ SHARE PROTECT FUNCTION
--========================================================

local function SetShareProtect(enabled)
    ShareProtectEnabled = enabled
    Settings.ShareProtectEnabled = enabled

    if ScreenGui and ScreenGui.Parent then
        -- ปิด/เปิดการแสดงผลของ UI ทั้งหมด
        ScreenGui.Enabled = not enabled
    end
end

--========================================================
-- RIGHTSHIFT SHOW / HIDE UI
--========================================================

connect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == ShareProtectHotkey then
        SetShareProtect(not ShareProtectEnabled)
    end
end)

-- สามารถเรียกจากภายนอกได้
env.ApichatShareProtect = function(state)
    if state == nil then
        state = not ShareProtectEnabled
    end

    SetShareProtect(state)
end

--========================================================
-- TOGGLE LOGO
--========================================================

local ToggleLogo = mk("ImageButton", {
    BackgroundColor3 = Theme.MainBg,
    Position = UDim2.new(0.03, 0, 0.2, 0),
    Size = UDim2.new(0, 45, 0, 45),
    Image = "rbxassetid://73200153325421",
    ImageColor3 = Theme.Text,
    ZIndex = 11
}, ScreenGui)

corner(ToggleLogo, 100)
stroke(ToggleLogo, Theme.Border, 2)

--========================================================
-- MAIN FRAME
--========================================================

local MainFrame = mk("ImageLabel", {
    Image = "rbxassetid://73200153325421",
    ScaleType = Enum.ScaleType.Crop,
    BackgroundColor3 = Theme.MainBg,
    BackgroundTransparency = 1,

    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),

    Size = UDim2.new(0, 0, 0, 0),

    ClipsDescendants = true,
    Active = true,
    Draggable = true,
    Visible = false,
    ZIndex = 10
}, ScreenGui)

corner(MainFrame, 12)
stroke(MainFrame, Theme.Border, 1.5)

local function hideMain()
    mainOpen = false

    TweenService:Create(
        MainFrame,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 0)
        }
    ):Play()

    task.delay(0.25, function()
        if not mainOpen then
            MainFrame.Visible = false
        end
    end)
end

local function showMain()
    mainOpen = true
    MainFrame.Visible = true

    TweenService:Create(
        MainFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = MAIN_SIZE
        }
    ):Play()
end

--========================================================
-- WELCOME BANNER
--========================================================

local function showWelcomeBanner()
    local card = mk("Frame", {
        Size = UDim2.new(0, 320, 0, 65),
        Position = UDim2.new(1, 20, 1, -85),
        BackgroundColor3 = Theme.MainBg,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 60,
    }, ScreenGui)

    corner(card, 10)
    stroke(card, Theme.Accent, 1.5)

    local title = mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 12),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, card)

    onLang(function()
        title.Text = tr("WelcomeTitle")
    end)

    local sub = mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 32),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, card)

    TweenService:Create(
        card,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(1, -340, 1, -85)
        }
    ):Play()

    task.delay(3.5, function()
        pcall(function()
            local outTween = TweenService:Create(
                card,
                TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {
                    Position = UDim2.new(1, 20, 1, -85)
                }
            )

            local fadeCard = TweenService:Create(
                card,
                TweenInfo.new(0.6),
                {
                    BackgroundTransparency = 1
                }
            )

            local fadeTitle = TweenService:Create(
                title,
                TweenInfo.new(0.6),
                {
                    TextTransparency = 1
                }
            )

            local fadeSub = TweenService:Create(
                sub,
                TweenInfo.new(0.6),
                {
                    TextTransparency = 1
                }
            )

            outTween:Play()
            fadeCard:Play()
            fadeTitle:Play()
            fadeSub:Play()

            local strokeObj = card:FindFirstChildOfClass("UIStroke")

            if strokeObj then
                TweenService:Create(
                    strokeObj,
                    TweenInfo.new(0.6),
                    {
                        Transparency = 1
                    }
                ):Play()
            end

            outTween.Completed:Wait()
            card:Destroy()
        end)
    end)
end

--========================================================
-- INTRO
--========================================================

local IntroContainer = mk("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 50
}, ScreenGui)

local CenterLogo = mk("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 90, 0, 90),
    Image = "rbxassetid://73200153325421",
    BackgroundTransparency = 1,
    ImageTransparency = 1,
    ZIndex = 51
}, IntroContainer)

corner(CenterLogo, 16)

local BottomRightLogo = mk("ImageLabel", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -25, 1, -25),
    Size = UDim2.new(0, 55, 0, 55),
    Image = "rbxassetid://73200153325421",
    BackgroundTransparency = 1,
    ImageTransparency = 1,
    ZIndex = 51
}, IntroContainer)

corner(BottomRightLogo, 12)

task.spawn(function()
    local fadeIn = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local fadeOut = TweenInfo.new(
        0.7,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
    )

    TweenService:Create(
        CenterLogo,
        fadeIn,
        {
            ImageTransparency = 0,
            Size = UDim2.new(0, 110, 0, 110)
        }
    ):Play()

    TweenService:Create(
        BottomRightLogo,
        fadeIn,
        {
            ImageTransparency = 0
        }
    ):Play()

    task.wait(1.2)

    local tCenter = TweenService:Create(
        CenterLogo,
        fadeOut,
        {
            ImageTransparency = 1,
            Size = UDim2.new(0, 70, 0, 70)
        }
    )

    local tBottom = TweenService:Create(
        BottomRightLogo,
        fadeOut,
        {
            ImageTransparency = 1
        }
    )

    tCenter:Play()
    tBottom:Play()

    tCenter.Completed:Wait()

    IntroContainer:Destroy()

    showMain()
    showWelcomeBanner()

    -- ถ้าค่าที่บันทึกไว้เปิด Share Protect อยู่
    -- ให้ซ่อน UI หลัง Intro เสร็จ
    if Settings.ShareProtectEnabled then
        SetShareProtect(true)
    end
end)

--========================================================
-- TITLE BAR
--========================================================

local TitleBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1
}, MainFrame)

mk("TextLabel", {
    Position = UDim2.new(0, 16, 0, 0),
    Size = UDim2.new(0.7, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "APICHAT DOMAIN",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
}, TitleBar)

local CloseBtn = mk("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.new(0, 24, 0, 24),
    BackgroundColor3 = Theme.PanelBg,
    Text = "✕",
    TextColor3 = Theme.SubText,
    Font = Enum.Font.GothamBold,
    TextSize = 11
}, TitleBar)

corner(CloseBtn, 100)

CloseBtn.MouseButton1Click:Connect(hideMain)

ToggleLogo.MouseButton1Click:Connect(function()
    if mainOpen then
        hideMain()
    else
        showMain()
    end
end)

--========================================================
-- SIDEBAR
--========================================================

local Sidebar = mk("Frame", {
    Position = UDim2.new(0, 12, 0, 45),
    Size = UDim2.new(0, 140, 1, -57),
    BackgroundColor3 = Theme.PanelBg,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0
}, MainFrame)

corner(Sidebar, 8)

mk("UIListLayout", {
    Padding = UDim.new(0, 6),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder
}, Sidebar)

mk("UIPadding", {
    PaddingTop = UDim.new(0, 10)
}, Sidebar)

local ContentArea = mk("Frame", {
    Position = UDim2.new(0, 162, 0, 45),
    Size = UDim2.new(1, -174, 1, -57),
    BackgroundTransparency = 1
}, MainFrame)

local function createScrollTab(visible)
    local scroll = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = visible
    }, ContentArea)

    mk("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    }, scroll)

    mk("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 10)
    }, scroll)

    return scroll
end

local InfoTab = createScrollTab(true)
local CombatTab = createScrollTab(false)
local MiscTab = createScrollTab(false)
local SettingsTab = createScrollTab(false)

local TabBtns = {}

local function createTabBtn(locKey, icon, targetTab, order)
    local btn = mk("TextButton", {
        Size = UDim2.new(1, -16, 0, 36),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order
    }, Sidebar)

    corner(btn, 6)

    onLang(function()
        btn.Text = "  " .. icon .. "  " .. tr(locKey)
    end)

    table.insert(TabBtns, {
        Btn = btn,
        Tab = targetTab
    })

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(TabBtns) do
            t.Tab.Visible = (t.Tab == targetTab)
            t.Btn.BackgroundTransparency =
                (t.Tab == targetTab) and 0.1 or 1

            t.Btn.TextColor3 =
                (t.Tab == targetTab) and Theme.Text or Theme.SubText
        end
    end)

    return btn
end

local Tab1Btn = createTabBtn("TabInfo", "📊", InfoTab, 1)
createTabBtn("TabCombat", "🎯", CombatTab, 2)
createTabBtn("TabMisc", "🚀", MiscTab, 3)
createTabBtn("TabSettings", "⚙", SettingsTab, 4)

Tab1Btn.BackgroundTransparency = 0.1
Tab1Btn.TextColor3 = Theme.Text

--========================================================
-- CONTROLS
--========================================================

local controls = {}

local function createToggle(parent, locKey, key, onChange)
    local frame = mk("Frame", {
        Size = UDim2.new(1, -8, 0, 46),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0
    }, parent)

    corner(frame, 8)
    stroke(frame)

    local label = mk("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    }, frame)

    onLang(function()
        label.Text = tr(locKey)
    end)

    local switch = mk("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        BackgroundColor3 = Theme.MainBg
    }, frame)

    corner(switch, 100)
    stroke(switch)

    local dot = mk("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }, switch)

    corner(dot, 100)

    local function render()
        local on = Settings[key]

        dot.Position = on
            and UDim2.new(1, -21, 0.5, -9)
            or UDim2.new(0, 3, 0.5, -9)

        switch.BackgroundColor3 =
            on and Theme.Accent or Theme.MainBg
    end

    render()

    local function set(v)
        Settings[key] = v
        render()

        if onChange then
            onChange(v)
        end
    end

    local btn = mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    }, frame)

    btn.MouseButton1Click:Connect(function()
        set(not Settings[key])
    end)

    controls[key] = {
        Set = set
    }

    if onChange then
        onChange(Settings[key])
    end
end

local function createSlider(parent, locKey, key, minVal, maxVal, onChange)
    local frame = mk("Frame", {
        Size = UDim2.new(1, -8, 0, 56),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0
    }, parent)

    corner(frame, 8)
    stroke(frame)

    local label = mk("TextLabel", {
        Size = UDim2.new(1, -24, 0, 28),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local bar = mk("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 36),
        BackgroundColor3 = Theme.MainBg,
        BorderSizePixel = 0
    }, frame)

    corner(bar, 100)

    local fill = mk("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0)
    }, bar)

    corner(fill, 100)

    local knob = mk("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = ""
    }, fill)

    corner(knob, 100)

    local function render()
        local v = Settings[key]

        fill.Size = UDim2.new(
            (v - minVal) / (maxVal - minVal),
            0,
            1,
            0
        )

        label.Text = tr(locKey) .. ": " .. v
    end

    onLang(render)

    local function set(v)
        Settings[key] = math.clamp(
            math.floor(v),
            minVal,
            maxVal
        )

        render()

        if onChange then
            onChange(Settings[key])
        end
    end

    local dragging = false

    local function update(input)
        set(
            minVal +
            (maxVal - minVal) *
            math.clamp(
                (input.Position.X - bar.AbsolutePosition.X)
                / bar.AbsoluteSize.X,
                0,
                1
            )
        )
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then

            dragging = true
        end
    end)

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            update(i)
        end
    end)

    connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    connect(UserInputService.InputChanged, function(i)
        if dragging
            and (
                i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch
            ) then

            update(i)
        end
    end)

    controls[key] = {
        Set = set
    }

    if onChange then
        onChange(Settings[key])
    end
end

local function createModeSwitch(parent, locKey, key, optionKeys, values)
    local frame = mk("Frame", {
        Size = UDim2.new(1, -8, 0, 46),
        BackgroundColor3 = Theme.PanelBg
    }, parent)

    corner(frame, 8)
    stroke(frame)

    local label = mk("TextLabel", {
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    onLang(function()
        label.Text = tr(locKey)
    end)

    local btn = mk("TextButton", {
        Size = UDim2.new(0, 96, 0, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 10
    }, frame)

    corner(btn, 4)

    local function indexOf(v)
        for i, x in ipairs(values) do
            if x == v then
                return i
            end
        end

        return 1
    end

    local function render()
        btn.Text = tr(
            optionKeys[indexOf(Settings[key])]
        )
    end

    onLang(render)

    btn.MouseButton1Click:Connect(function()
        local i = indexOf(Settings[key]) + 1

        if i > #values then
            i = 1
        end

        Settings[key] = values[i]
        render()
    end)

    controls[key] = {
        Set = function(v)
            Settings[key] = v
            render()
        end
    }
end

--========================================================
-- INFO TAB
--========================================================

local welcomeCard = mk("Frame", {
    Size = UDim2.new(1, -8, 0, 75),
    BackgroundColor3 = Theme.PanelBg
}, InfoTab)

corner(welcomeCard, 8)
stroke(welcomeCard)

local profileImg = mk("ImageLabel", {
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 10, 0.5, -26),
    BackgroundColor3 = Theme.MainBg,
    BackgroundTransparency = 0,
    Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
}, welcomeCard)

corner(profileImg, 100)
stroke(profileImg, Theme.Accent, 1.5)

task.spawn(function()
    pcall(function()
        local content, isReady =
            Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )

        if isReady then
            profileImg.Image = content
        end
    end)
end)

local wTitle = mk("TextLabel", {
    Size = UDim2.new(1, -75, 0, 24),
    Position = UDim2.new(0, 70, 0, 12),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
}, welcomeCard)

local wSub = mk("TextLabel", {
    Size = UDim2.new(1, -75, 0, 26),
    Position = UDim2.new(0, 70, 0, 36),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, welcomeCard)

onLang(function()
    wTitle.Text = tr("WelcomeTitle")

    wSub.Text =
        tr("NamePrefix")
        .. LocalPlayer.DisplayName
        .. " (@"
        .. LocalPlayer.Name
        .. ")"
end)

local mapCard = mk("Frame", {
    Size = UDim2.new(1, -8, 0, 85),
    BackgroundColor3 = Theme.PanelBg
}, InfoTab)

corner(mapCard, 8)
stroke(mapCard)

local mTitle = mk("TextLabel", {
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 12, 0, 6),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
}, mapCard)

local mInfo = mk("TextLabel", {
    Size = UDim2.new(1, -20, 0, 50),
    Position = UDim2.new(0, 12, 0, 30),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, mapCard)

local function updateMapInfo()
    local placeName = "Roblox Game"

    pcall(function()
        placeName =
            MarketPlaceService:GetProductInfo(game.PlaceId).Name
    end)

    mInfo.Text =
        tr("MapPrefix")
        .. placeName
        .. "\n"
        .. tr("PlaceID")
        .. game.PlaceId
        .. "\n"
        .. tr("ServerPlayers")
        .. #Players:GetPlayers()
        .. "/"
        .. Players.MaxPlayers
end

onLang(function()
    mTitle.Text = tr("MapTitle")
    updateMapInfo()
end)

local perfCard = mk("Frame", {
    Size = UDim2.new(1, -8, 0, 65),
    BackgroundColor3 = Theme.PanelBg
}, InfoTab)

corner(perfCard, 8)
stroke(perfCard)

local pTitle = mk("TextLabel", {
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 12, 0, 6),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
}, perfCard)

local pInfo = mk("TextLabel", {
    Size = UDim2.new(1, -20, 0, 28),
    Position = UDim2.new(0, 12, 0, 30),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, perfCard)

onLang(function()
    pTitle.Text = tr("PerfTitle")
end)

local lastTime = os.clock()

connect(RunService.RenderStepped, function()
    local curTime = os.clock()

    local fps =
        math.floor(
            1 / math.max(curTime - lastTime, 0.001)
        )

    lastTime = curTime

    local ping = 0

    pcall(function()
        ping =
            math.floor(
                StatsService.Network.ServerStatsItem
                ["Data Ping"]:GetValue()
            )
    end)

    pInfo.Text =
        "FPS: "
        .. fps
        .. " | Ping: "
        .. ping
        .. " ms"
end)

--========================================================
-- COMBAT / PLAYER PICKER
--========================================================

local SelectedTargets = {}

local PickerFrame = mk("Frame", {
    Size = UDim2.new(0, 280, 0, 310),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.MainBg,
    Visible = false,
    ZIndex = 30
}, ScreenGui)

corner(PickerFrame, 10)
stroke(PickerFrame, Theme.Accent, 2)

local pHeader = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundTransparency = 1,
    ZIndex = 30
}, PickerFrame)

local pTitle = mk("TextLabel", {
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(0.7, 0, 1, 0),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 30
}, pHeader)

onLang(function()
    pTitle.Text = tr("PickerTitle")
end)

local pClose = mk("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.new(0, 22, 0, 22),
    BackgroundColor3 = Theme.PanelBg,
    Text = "✕",
    TextColor3 = Theme.SubText,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    ZIndex = 30
}, pHeader)

corner(pClose, 100)

pClose.MouseButton1Click:Connect(function()
    PickerFrame.Visible = false
end)

local pBtnsBar = mk("Frame", {
    Position = UDim2.new(0, 10, 0, 38),
    Size = UDim2.new(1, -20, 0, 26),
    BackgroundTransparency = 1,
    ZIndex = 30
}, PickerFrame)

local btnAll = mk("TextButton", {
    Size = UDim2.new(0.48, 0, 1, 0),
    BackgroundColor3 = Theme.Accent,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    ZIndex = 30
}, pBtnsBar)

corner(btnAll, 6)

local btnNone = mk("TextButton", {
    Size = UDim2.new(0.48, 0, 1, 0),
    Position = UDim2.new(0.52, 0, 0, 0),
    BackgroundColor3 = Theme.PanelBg,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    ZIndex = 30
}, pBtnsBar)

corner(btnNone, 6)
stroke(btnNone)

onLang(function()
    btnAll.Text = tr("BtnAll")
    btnNone.Text = tr("BtnNone")
end)

local pScroll = mk("ScrollingFrame", {
    Position = UDim2.new(0, 10, 0, 70),
    Size = UDim2.new(1, -20, 1, -78),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Border,
    ZIndex = 30
}, PickerFrame)

mk("UIListLayout", {
    Padding = UDim.new(0, 6)
}, pScroll)

local pickerUpdateBtn = nil

local function refreshPickerList()
    for _, child in ipairs(pScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pRow = mk("Frame", {
                Size = UDim2.new(1, -4, 0, 32),
                BackgroundColor3 = Theme.PanelBg,
                ZIndex = 31
            }, pScroll)

            corner(pRow, 6)
            stroke(pRow)

            local pName = mk("TextLabel", {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -55, 1, 0),
                BackgroundTransparency = 1,
                Text = p.DisplayName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 31
            }, pRow)

            local pSw = mk("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0, 34, 0, 18),
                BackgroundColor3 =
                    (SelectedTargets[p.UserId] ~= false)
                    and Theme.Accent
                    or Theme.MainBg,
                ZIndex = 31
            }, pRow)

            corner(pSw, 100)

            local pDot = mk("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position =
                    (SelectedTargets[p.UserId] ~= false)
                    and UDim2.new(1, -16, 0.5, 0)
                    or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 31
            }, pSw)

            corner(pDot, 100)

            local btn = mk("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 32
            }, pRow)

            btn.MouseButton1Click:Connect(function()
                local curr =
                    (SelectedTargets[p.UserId] ~= false)

                SelectedTargets[p.UserId] = not curr

                pSw.BackgroundColor3 =
                    not curr and Theme.Accent
                    or Theme.MainBg

                pDot.Position =
                    not curr
                    and UDim2.new(1, -16, 0.5, 0)
                    or UDim2.new(0, 2, 0.5, 0)

                if pickerUpdateBtn then
                    pickerUpdateBtn()
                end
            end)
        end
    end
end

btnAll.MouseButton1Click:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        SelectedTargets[p.UserId] = true
    end

    refreshPickerList()

    if pickerUpdateBtn then
        pickerUpdateBtn()
    end
end)

btnNone.MouseButton1Click:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        SelectedTargets[p.UserId] = false
    end

    refreshPickerList()

    if pickerUpdateBtn then
        pickerUpdateBtn()
    end
end)

local pickerBtnFrame = mk("Frame", {
    Size = UDim2.new(1, -8, 0, 46),
    BackgroundColor3 = Theme.PanelBg
}, CombatTab)

corner(pickerBtnFrame, 8)
stroke(pickerBtnFrame)

local pickerLbl = mk("TextLabel", {
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, pickerBtnFrame)

local pickerStatus = mk("TextButton", {
    Size = UDim2.new(0, 100, 0, 24),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    BackgroundColor3 = Theme.Accent,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 10
}, pickerBtnFrame)

corner(pickerStatus, 4)

pickerUpdateBtn = function()
    local total = #Players:GetPlayers() - 1

    if total <= 0 then
        pickerStatus.Text = tr("DdEmpty")
        return
    end

    local count = 0

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer
            and SelectedTargets[p.UserId] ~= false then

            count = count + 1
        end
    end

    if count == total then
        pickerStatus.Text = tr("DdAll")
    elseif count == 0 then
        pickerStatus.Text = tr("DdNone")
    else
        pickerStatus.Text =
            string.format(
                tr("DdSome"),
                count,
                total
            )
    end
end

onLang(function()
    pickerLbl.Text = tr("AimPlayers")

    if pickerUpdateBtn then
        pickerUpdateBtn()
    end
end)

pickerStatus.MouseButton1Click:Connect(function()
    refreshPickerList()
    PickerFrame.Visible = true
end)

--========================================================
-- FOV
--========================================================

local FOVFrame = mk("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1,
    Active = false,
    ZIndex = 1
}, ScreenGui)

mk("UICorner", {
    CornerRadius = UDim.new(1, 0)
}, FOVFrame)

local FOVStroke = stroke(
    FOVFrame,
    Color3.fromRGB(255, 255, 255),
    1.5
)

--========================================================
-- COMBAT SETTINGS
--========================================================

createToggle(
    CombatTab,
    "Aimbot",
    "AimbotEnabled"
)

createToggle(
    CombatTab,
    "WallCheck",
    "WallCheckEnabled"
)

createToggle(
    CombatTab,
    "TeamCheck",
    "TeamCheckEnabled"
)

createModeSwitch(
    CombatTab,
    "AimbotTarget",
    "AimbotTarget",
    {
        "TargetHead",
        "TargetTorso"
    },
    {
        "Head",
        "HumanoidRootPart"
    }
)

createToggle(
    CombatTab,
    "BoxESP",
    "ESPEnabled"
)

createToggle(
    CombatTab,
    "NameESP",
    "NameEnabled"
)

createToggle(
    CombatTab,
    "DistESP",
    "DistanceEnabled"
)

createToggle(
    CombatTab,
    "HealthESP",
    "HealthEnabled"
)

createToggle(
    CombatTab,
    "SkelESP",
    "SkeletonEnabled"
)

createToggle(
    CombatTab,
    "RGBESP",
    "ESPRGB"
)

createToggle(
    CombatTab,
    "FOVToggle",
    "FOVEnabled",
    function(on)
        FOVFrame.Visible = on
    end
)

createToggle(
    CombatTab,
    "RGBFOV",
    "FOVRGB",
    function(on)
        if not on then
            FOVStroke.Color =
                Color3.fromRGB(255, 255, 255)
        end
    end
)

createSlider(
    CombatTab,
    "FOVSize",
    "FOVRadius",
    40,
    400,
    function(v)
        FOVFrame.Size =
            UDim2.new(
                0,
                v * 2,
                0,
                v * 2
            )
    end
)

createToggle(
    CombatTab,
    "Tracers",
    "TracersEnabled"
)

createToggle(
    CombatTab,
    "RGBTracers",
    "TracersRGB"
)

--========================================================
-- MISC
--========================================================

createToggle(
    MiscTab,
    "WalkSpeedToggle",
    "WalkSpeedEnabled"
)

createSlider(
    MiscTab,
    "WalkSpeedSlider",
    "WalkSpeedValue",
    16,
    200
)

createToggle(
    MiscTab,
    "JumpPowerToggle",
    "JumpPowerEnabled"
)

createSlider(
    MiscTab,
    "JumpPowerSlider",
    "JumpPowerValue",
    50,
    300
)

createToggle(
    MiscTab,
    "NoclipToggle",
    "NoclipEnabled"
)

--========================================================
-- SETTINGS TAB
--========================================================

-- 🛡️ SHARE PROTECT PANEL
local shareFrame = mk("Frame", {
    Size = UDim2.new(1, -8, 0, 78),
    BackgroundColor3 = Theme.PanelBg
}, SettingsTab)

corner(shareFrame, 8)
stroke(shareFrame, Theme.Accent, 1.2)

local shareTitle = mk("TextLabel", {
    Size = UDim2.new(1, -70, 0, 24),
    Position = UDim2.new(0, 12, 0, 6),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, shareFrame)

local shareDesc = mk("TextLabel", {
    Size = UDim2.new(1, -70, 0, 22),
    Position = UDim2.new(0, 12, 0, 30),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, shareFrame)

local shareSwitch = mk("Frame", {
    Size = UDim2.new(0, 44, 0, 24),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    BackgroundColor3 = Theme.MainBg
}, shareFrame)

corner(shareSwitch, 100)
stroke(shareSwitch)

local shareDot = mk("Frame", {
    Size = UDim2.new(0, 18, 0, 18),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
}, shareSwitch)

corner(shareDot, 100)

local shareButton = mk("TextButton", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = ""
}, shareFrame)

local function renderShareProtect()
    local on = ShareProtectEnabled

    shareDot.Position =
        on
        and UDim2.new(1, -21, 0.5, -9)
        or UDim2.new(0, 3, 0.5, -9)

    shareSwitch.BackgroundColor3 =
        on
        and Theme.Accent
        or Theme.MainBg
end

local function updateShareText()
    shareTitle.Text = tr("ShareProtect")
    shareDesc.Text =
        tr("ShareProtectDesc")
        .. "\n"
        .. tr("ShareProtectHotkey")
end

onLang(updateShareText)

renderShareProtect()

shareButton.MouseButton1Click:Connect(function()
    SetShareProtect(not ShareProtectEnabled)
    renderShareProtect()
end)

--========================================================
-- LANGUAGE
--========================================================

local langFrame = mk("Frame", {
    Size = UDim2.new(1, -8, 0, 46),
    BackgroundColor3 = Theme.PanelBg
}, SettingsTab)

corner(langFrame, 8)
stroke(langFrame)

local langLbl = mk("TextLabel", {
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, langFrame)

onLang(function()
    langLbl.Text = tr("LangLabel")
end)

local langBtn = mk("TextButton", {
    Size = UDim2.new(0, 130, 0, 26),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    BackgroundColor3 = Theme.Accent,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 10
}, langFrame)

corner(langBtn, 4)

onLang(function()
    langBtn.Text = tr("LangBtn")
end)

langBtn.MouseButton1Click:Connect(function()
    CurrentLang =
        (CurrentLang == "TH")
        and "EN"
        or "TH"

    applyLang()
end)

--========================================================
-- SAVE SETTINGS
--========================================================

local saveFrame = mk("Frame", {
    Size = UDim2.new(1, -8, 0, 115),
    BackgroundColor3 = Theme.PanelBg
}, SettingsTab)

corner(saveFrame, 8)
stroke(saveFrame)

local saveTitle = mk("TextLabel", {
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 12, 0, 5),
    BackgroundTransparency = 1,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, saveFrame)

local saveStatus = mk("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 12, 0, 28),
    BackgroundTransparency = 1,
    TextColor3 = Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left
}, saveFrame)

local function updateSaveStatusText()
    saveTitle.Text = tr("SaveTitle")

    saveStatus.Text =
        hasSaved
        and tr("SaveHave")
        or tr("SaveNone")
end

onLang(updateSaveStatusText)

local btnSave = mk("TextButton", {
    Size = UDim2.new(1, -24, 0, 24),
    Position = UDim2.new(0, 12, 0, 52),
    BackgroundColor3 = Theme.Accent,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 10
}, saveFrame)

corner(btnSave, 4)

onLang(function()
    btnSave.Text = tr("BtnSave")
end)

local btnReset = mk("TextButton", {
    Size = UDim2.new(1, -24, 0, 24),
    Position = UDim2.new(0, 12, 0, 82),
    BackgroundColor3 = Color3.fromRGB(180, 50, 50),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 10
}, saveFrame)

corner(btnReset, 4)

onLang(function()
    btnReset.Text = tr("BtnReset")
end)

btnSave.MouseButton1Click:Connect(function()
    pcall(function()
        if writefile then
            local data = {
                settings = Settings,
                lang = CurrentLang
            }

            writefile(
                SAVE_FILE,
                HttpService:JSONEncode(data)
            )

            hasSaved = true
            updateSaveStatusText()
        end
    end)
end)

btnReset.MouseButton1Click:Connect(function()
    pcall(function()
        if delfile and isfile and isfile(SAVE_FILE) then
            delfile(SAVE_FILE)
        end

        hasSaved = false

        for k, v in pairs(Defaults) do
            Settings[k] = v
        end

        ShareProtectEnabled = false

        renderShareProtect()
        updateSaveStatusText()
    end)
end)

--========================================================
-- UNLOAD
--========================================================

local unloadBtn = mk("TextButton", {
    Size = UDim2.new(1, -8, 0, 36),
    BackgroundColor3 = Color3.fromRGB(150, 40, 40),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11
}, SettingsTab)

corner(unloadBtn, 8)

onLang(function()
    unloadBtn.Text = tr("BtnUnload")
end)

unloadBtn.MouseButton1Click:Connect(function()
    if env.ApichatUnload then
        env.ApichatUnload()
    end
end)

--========================================================
-- LOGIC CORE
--========================================================

local PlayerElements = {}

local function createPlayerUI(player)
    if player == LocalPlayer or PlayerElements[player] then
        return
    end

    local box = mk("Frame", {
        BackgroundTransparency = 1,
        Visible = false
    }, VisualContainer)

    local boxStroke = mk("UIStroke", {
        Thickness = 1.5
    }, box)

    local name = mk("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 0, 18),
        AnchorPoint = Vector2.new(0.5, 1),
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        Visible = false,
        TextStrokeTransparency = 0.5
    }, VisualContainer)

    local dist = mk("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        Visible = false,
        TextStrokeTransparency = 0.5
    }, VisualContainer)

    local hBg = mk("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        AnchorPoint = Vector2.new(1, 0.5),
        Visible = false
    }, VisualContainer)

    local hFill = mk("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 255, 120),
        BorderSizePixel = 0
    }, hBg)

    local tracer = mk("Frame", {
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = false
    }, VisualContainer)

    local skels = {}

    for i = 1, 15 do
        skels[i] = mk("Frame", {
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Visible = false
        }, VisualContainer)
    end

    PlayerElements[player] = {
        Box = box,
        BoxStroke = boxStroke,
        NameLabel = name,
        DistLabel = dist,
        HealthBg = hBg,
        HealthFill = hFill,
        Tracer = tracer,
        SkelLines = skels
    }
end

local function removePlayerUI(player)
    local el = PlayerElements[player]

    if not el then
        return
    end

    el.Box:Destroy()
    el.NameLabel:Destroy()
    el.DistLabel:Destroy()
    el.HealthBg:Destroy()
    el.Tracer:Destroy()

    for _, l in ipairs(el.SkelLines) do
        l:Destroy()
    end

    PlayerElements[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do
    createPlayerUI(p)
end

connect(Players.PlayerAdded, function(p)
    createPlayerUI(p)

    if pickerUpdateBtn then
        pickerUpdateBtn()
    end
end)

connect(Players.PlayerRemoving, function(p)
    removePlayerUI(p)

    if pickerUpdateBtn then
        pickerUpdateBtn()
    end
end)

local R15Joints = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local R6Joints = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function isVisible(cam, targetPart, character)
    local origin = cam.CFrame.Position

    local result =
        workspace:Raycast(
            origin,
            targetPart.Position - origin,
            raycastParams
        )

    return
        (not result)
        or result.Instance:IsDescendantOf(character)
end

local function isSameTeam(player)
    if not LocalPlayer
        or not player
        or player == LocalPlayer then

        return true
    end

    if LocalPlayer.Team
        and player.Team
        and LocalPlayer.Team == player.Team then

        return true
    end

    return false
end

local function drawLineBetween(frame, p1, p2, color)
    frame.Size =
        UDim2.new(
            0,
            (p2 - p1).Magnitude,
            0,
            1.5
        )

    frame.Position =
        UDim2.new(
            0,
            (p1.X + p2.X) / 2,
            0,
            (p1.Y + p2.Y) / 2
        )

    frame.Rotation =
        math.deg(
            math.atan2(
                p2.Y - p1.Y,
                p2.X - p1.X
            )
        )

    frame.BackgroundColor3 = color
    frame.Visible = true
end

--========================================================
-- MOVEMENT
--========================================================

local savedMove = {}

local function updateMovement(hum)
    if Settings.WalkSpeedEnabled then
        if savedMove.walk == nil then
            savedMove.walk = hum.WalkSpeed
        end

        if hum.WalkSpeed ~= Settings.WalkSpeedValue then
            hum.WalkSpeed = Settings.WalkSpeedValue
        end

    elseif savedMove.walk ~= nil then
        hum.WalkSpeed = savedMove.walk
        savedMove.walk = nil
    end

    if Settings.JumpPowerEnabled then
        if hum.UseJumpPower then

            if savedMove.jump == nil then
                savedMove.jump = hum.JumpPower
            end

            if hum.JumpPower ~= Settings.JumpPowerValue then
                hum.JumpPower = Settings.JumpPowerValue
            end

        else

            if savedMove.jumpHeight == nil then
                savedMove.jumpHeight = hum.JumpHeight
            end

            hum.JumpHeight =
                Settings.JumpPowerValue / 5
        end

    else

        if savedMove.jump ~= nil then
            hum.JumpPower = savedMove.jump
            savedMove.jump = nil
        end

        if savedMove.jumpHeight ~= nil then
            hum.JumpHeight = savedMove.jumpHeight
            savedMove.jumpHeight = nil
        end
    end
end

--========================================================
-- NOCLIP
--========================================================

local noclipOrig = {}

local function restoreNoclip()
    for part, was in pairs(noclipOrig) do
        pcall(function()
            if part and part.Parent then
                part.CanCollide = was
            end
        end)
    end

    noclipOrig = {}
end

connect(RunService.Stepped, function()
    local char = LocalPlayer.Character

    if Settings.NoclipEnabled and char then

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then

                if noclipOrig[part] == nil then
                    noclipOrig[part] = part.CanCollide
                end

                part.CanCollide = false
            end
        end

    elseif next(noclipOrig) ~= nil then
        restoreNoclip()
    end
end)

connect(LocalPlayer.CharacterAdded, function()
    savedMove = {}
    noclipOrig = {}
end)

--========================================================
-- RENDER / LOGIC
--========================================================

connect(RunService.RenderStepped, function()
    local cam = workspace.CurrentCamera

    if not cam then
        return
    end

    local myChar = LocalPlayer.Character

    if myChar then
        raycastParams.FilterDescendantsInstances = {
            myChar
        }
    else
        raycastParams.FilterDescendantsInstances = {}
    end

    local screenBottom =
        Vector2.new(
            cam.ViewportSize.X / 2,
            cam.ViewportSize.Y
        )

    local hue =
        (os.clock() % Settings.RGBSpeed)
        / Settings.RGBSpeed

    local rgbColor =
        Color3.fromHSV(
            hue,
            0.8,
            1
        )

    local myHum =
        myChar
        and myChar:FindFirstChildOfClass("Humanoid")

    if myHum then
        updateMovement(myHum)
    end

    if Settings.FOVEnabled and Settings.FOVRGB then
        FOVStroke.Color = rgbColor
    end

    local closestPlayer = nil

    local shortDist =
        Settings.FOVEnabled
        and Settings.FOVRadius
        or math.huge

    local center =
        Vector2.new(
            cam.ViewportSize.X / 2,
            cam.ViewportSize.Y / 2
        )

    for player, elems in pairs(PlayerElements) do

        local isTargetSelected =
            (SelectedTargets[player.UserId] ~= false)

        local char = player.Character
        local hrp =
            char
            and char:FindFirstChild("HumanoidRootPart")

        local head =
            char
            and char:FindFirstChild("Head")

        local hum =
            char
            and char:FindFirstChildOfClass("Humanoid")

        if isTargetSelected
            and (
                not Settings.TeamCheckEnabled
                or not isSameTeam(player)
            )
            and hrp
            and head
            and hum
            and hum.Health > 0 then

            local hrpPos, onScreen =
                cam:WorldToViewportPoint(
                    hrp.Position
                )

            local targetPart =
                char:FindFirstChild(
                    Settings.AimbotTarget
                )

            if Settings.AimbotEnabled
                and targetPart
                and onScreen then

                local checkVis =
                    (not Settings.WallCheckEnabled)
                    or isVisible(
                        cam,
                        targetPart,
                        char
                    )

                if checkVis then

                    local d =
                        (
                            Vector2.new(
                                hrpPos.X,
                                hrpPos.Y
                            ) - center
                        ).Magnitude

                    if d < shortDist then
                        shortDist = d
                        closestPlayer = targetPart
                    end
                end
            end

            if onScreen then

                local headPos =
                    cam:WorldToViewportPoint(
                        head.Position
                        + Vector3.new(0, 0.8, 0)
                    )

                local legPos =
                    cam:WorldToViewportPoint(
                        hrp.Position
                        - Vector3.new(0, 3.2, 0)
                    )

                local height =
                    math.abs(
                        headPos.Y - legPos.Y
                    )

                local width =
                    height * 0.6

                if Settings.ESPEnabled then

                    elems.Box.Size =
                        UDim2.new(
                            0,
                            width,
                            0,
                            height
                        )

                    elems.Box.Position =
                        UDim2.new(
                            0,
                            hrpPos.X - width / 2,
                            0,
                            headPos.Y
                        )

                    elems.BoxStroke.Color =
                        Settings.ESPRGB
                        and rgbColor
                        or Theme.Accent

                    elems.Box.Visible = true

                else
                    elems.Box.Visible = false
                end

                if Settings.ESPEnabled
                    and Settings.NameEnabled then

                    elems.NameLabel.Text =
                        player.DisplayName

                    elems.NameLabel.Position =
                        UDim2.new(
                            0,
                            hrpPos.X,
                            0,
                            headPos.Y - 4
                        )

                    elems.NameLabel.TextColor3 =
                        Settings.ESPRGB
                        and rgbColor
                        or Color3.fromRGB(
                            255,
                            255,
                            255
                        )

                    elems.NameLabel.Visible = true

                else
                    elems.NameLabel.Visible = false
                end

                if Settings.ESPEnabled
                    and Settings.DistanceEnabled
                    and myChar
                    and myChar:FindFirstChild(
                        "HumanoidRootPart"
                    ) then

                    local dist =
                        math.floor(
                            (
                                myChar.HumanoidRootPart.Position
                                - hrp.Position
                            ).Magnitude
                        )

                    elems.DistLabel.Text =
                        "[" .. dist .. "m]"

                    elems.DistLabel.Position =
                        UDim2.new(
                            0,
                            hrpPos.X,
                            0,
                            legPos.Y + 4
                        )

                    elems.DistLabel.TextColor3 =
                        Settings.ESPRGB
                        and rgbColor
                        or Theme.SubText

                    elems.DistLabel.Visible = true

                else
                    elems.DistLabel.Visible = false
                end

                if Settings.ESPEnabled
                    and Settings.HealthEnabled then

                    local p =
                        math.clamp(
                            hum.Health / hum.MaxHealth,
                            0,
                            1
                        )

                    elems.HealthBg.Size =
                        UDim2.new(
                            0,
                            3,
                            0,
                            height
                        )

                    elems.HealthBg.Position =
                        UDim2.new(
                            0,
                            hrpPos.X - width / 2 - 5,
                            0,
                            hrpPos.Y
                        )

                    elems.HealthFill.Size =
                        UDim2.new(
                            1,
                            0,
                            p,
                            0
                        )

                    elems.HealthFill.Position =
                        UDim2.new(
                            0,
                            0,
                            1 - p,
                            0
                        )

                    elems.HealthFill.BackgroundColor3 =
                        Color3.fromHSV(
                            p * 0.3,
                            1,
                            1
                        )

                    elems.HealthBg.Visible = true

                else
                    elems.HealthBg.Visible = false
                end

                if Settings.TracersEnabled then

                    drawLineBetween(
                        elems.Tracer,
                        screenBottom,
                        Vector2.new(
                            hrpPos.X,
                            hrpPos.Y
                        ),
                        Settings.TracersRGB
                        and rgbColor
                        or Theme.Accent
                    )

                else
                    elems.Tracer.Visible = false
                end

                if Settings.ESPEnabled
                    and Settings.SkeletonEnabled then

                    local joints =
                        char:FindFirstChild(
                            "UpperTorso"
                        )
                        and R15Joints
                        or R6Joints

                    local c =
                        Settings.ESPRGB
                        and rgbColor
                        or Color3.fromRGB(
                            200,
                            200,
                            200
                        )

                    for i, v in ipairs(joints) do

                        local p1 =
                            char:FindFirstChild(v[1])

                        local p2 =
                            char:FindFirstChild(v[2])

                        if p1 and p2 then

                            local sp1, s1 =
                                cam:WorldToViewportPoint(
                                    p1.Position
                                )

                            local sp2, s2 =
                                cam:WorldToViewportPoint(
                                    p2.Position
                                )

                            if s1 and s2 then

                                drawLineBetween(
                                    elems.SkelLines[i],
                                    Vector2.new(
                                        sp1.X,
                                        sp1.Y
                                    ),
                                    Vector2.new(
                                        sp2.X,
                                        sp2.Y
                                    ),
                                    c
                                )

                            else
                                elems.SkelLines[i].Visible = false
                            end

                        else
                            elems.SkelLines[i].Visible = false
                        end
                    end

                else

                    for _, l in ipairs(elems.SkelLines) do
                        l.Visible = false
                    end
                end

            else

                elems.Box.Visible = false
                elems.NameLabel.Visible = false
                elems.DistLabel.Visible = false
                elems.HealthBg.Visible = false
                elems.Tracer.Visible = false

                for _, l in ipairs(elems.SkelLines) do
                    l.Visible = false
                end
            end

        else

            elems.Box.Visible = false
            elems.NameLabel.Visible = false
            elems.DistLabel.Visible = false
            elems.HealthBg.Visible = false
            elems.Tracer.Visible = false

            for _, l in ipairs(elems.SkelLines) do
                l.Visible = false
            end
        end
    end

    if Settings.AimbotEnabled
        and closestPlayer then

        local lookAt =
            CFrame.new(
                cam.CFrame.Position,
                closestPlayer.Position
            )

        cam.CFrame =
            cam.CFrame:Lerp(
                lookAt,
                Settings.AimbotSmoothness
            )
    end
end)

--========================================================
-- UNLOAD
--========================================================

env.ApichatUnload = function()

    for _, c in ipairs(conns) do
        pcall(function()
            c:Disconnect()
        end)
    end

    pcall(function()
        restoreNoclip()
    end)

    pcall(function()
        ScreenGui:Destroy()
    end)

    env.ApichatShareProtect = nil
    env.ApichatUnload = nil
end