--[[
    ⚡ APICHAT DOMAIN ⚡
    FPS Booster - กราฟิกดินน้ำมัน (Clay Mode)
    ลดกราฟิกสุด ๆ เพื่อเครื่องสเปกต่ำ
]]

local NAME = "⚡ APICHAT DOMAIN ⚡"

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

-- ตั้งค่า (true = เปิด / false = ปิด)
local CONFIG = {
    ClayMaterial = true,      -- ทุกอย่างเป็นพลาสติกเรียบ ๆ (ดินน้ำมัน)
    RemoveTextures = true,    -- ลบ Texture / Decal / SurfaceAppearance
    RemoveEffects = true,     -- ปิดเอฟเฟกต์ (Bloom, Blur, SunRays ฯลฯ)
    RemoveParticles = true,   -- ปิด Particle / Fire / Smoke / Trail
    NoShadows = true,         -- ปิดเงา
    LowTerrain = true,        -- ลดน้ำ / หญ้า
    FpsCap = 0,               -- 0 = ไม่จำกัด (ถ้าตัวรันรองรับ)
}

local function notify(title, text, duration)
    for _ = 1, 5 do
        local ok = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 6,
            })
        end)
        if ok then return end
        task.wait(1)
    end
end

-- ตั้งคุณภาพกราฟิกต่ำสุด
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)
pcall(function()
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
end)
pcall(function()
    if CONFIG.FpsCap and setfpscap then
        setfpscap(CONFIG.FpsCap)
    end
end)

-- Lighting
local function optimizeLighting()
    pcall(function()
        if CONFIG.NoShadows then
            Lighting.GlobalShadows = false
            Lighting.ShadowSoftness = 0
        end
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end)
    pcall(function()
        Lighting.Technology = Enum.Technology.Compatibility
    end)
end

local function cleanLightingObject(v)
    if not CONFIG.RemoveEffects then return end
    if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
        pcall(function()
            v.Enabled = false
        end)
        pcall(function()
            if v:IsA("Atmosphere") then
                v.Density = 0
                v.Haze = 0
            end
        end)
    end
end

-- Terrain
local function optimizeTerrain()
    if not (CONFIG.LowTerrain and Terrain) then return end
    pcall(function()
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.Decoration = false
    end)
end

-- จัดการแต่ละ Instance
local function optimize(v)
    pcall(function()
        if v:IsA("BasePart") then
            if CONFIG.ClayMaterial then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
            if CONFIG.NoShadows then
                v.CastShadow = false
            end
            if v:IsA("MeshPart") and CONFIG.RemoveTextures then
                v.TextureID = ""
            end
        elseif CONFIG.RemoveTextures and (v:IsA("Decal") or v:IsA("Texture")) then
            v:Destroy()
        elseif CONFIG.RemoveTextures and v:IsA("SurfaceAppearance") then
            v:Destroy()
        elseif CONFIG.RemoveTextures and v:IsA("SpecialMesh") then
            v.TextureId = ""
        elseif CONFIG.RemoveParticles and (
            v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")
            or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles")
        ) then
            v.Enabled = false
        elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = false
        elseif v:IsA("Explosion") then
            v.Visible = false
        end
    end)
end

-- เริ่มทำงาน
optimizeLighting()
optimizeTerrain()

for _, v in ipairs(Lighting:GetChildren()) do
    cleanLightingObject(v)
end
Lighting.ChildAdded:Connect(cleanLightingObject)

-- ทำเป็นชุด ๆ กันเครื่องค้าง
task.spawn(function()
    local count = 0
    for _, v in ipairs(Workspace:GetDescendants()) do
        optimize(v)
        count += 1
        if count % 300 == 0 then
            task.wait()
        end
    end
end)

-- ของที่เกิดใหม่ทีหลัง
Workspace.DescendantAdded:Connect(function(v)
    task.defer(optimize, v)
end)

-- แจ้งเตือนมุมขวาล่าง
notify(NAME, "FPS Boost เปิดใช้งานแล้ว! โหมดดินน้ำมัน 🟢", 6)
