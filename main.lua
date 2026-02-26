-- Blox Fruits Auto Farm | WindUI
-- Переписан на основе оригинального скрипта с правильными механиками

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/raw/main/source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Blox Fruits Farm",
    Icon = "🍎",
    Author = "AutoFarm",
    Folder = "BloxFruitsFarm",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
})

local Tabs = {
    Main   = Window:Tab({ Title = "Главная",   Icon = "home"     }),
    Farm   = Window:Tab({ Title = "Фарм",      Icon = "sword"    }),
    Fruits = Window:Tab({ Title = "Фрукты",    Icon = "search"   }),
    Boss   = Window:Tab({ Title = "Боссы",     Icon = "skull"    }),
    Misc   = Window:Tab({ Title = "Разное",    Icon = "settings" }),
}

-- ===================== ПЕРЕМЕННЫЕ =====================
local LevelFarmQuest    = false
local LevelFarmNoQuest  = false
local AutoFarmBoss      = false
local AutoFruitSearch   = false
local AutoFruitTeleport = false
local BusoHaki          = false
local AntiAFK           = false
local FastAttack        = false

local AutoFarmType  = "Above"
local DisFarm       = 30
local Farm_Mode     = CFrame.new(0, DisFarm, 0) * CFrame.Angles(math.rad(-90), 0, 0)
local SelectWeapon  = nil
local SelectWeaponFarm = "Melee"

local ByPassTP      = false

-- Данные текущего моба/квеста (заполняются CheckLevel)
local Ms, NameQuest, QuestLv, NameMon = nil, nil, nil, nil
local CFrameQ, CFrameMon = nil, nil
local Level_Farm_Name   = nil
local Level_Farm_CFrame = nil

-- Моры мира (PlaceId)
local placeId = game.PlaceId
local First_Sea  = (placeId == 2753915549)
local Second_Sea = (placeId == 4442272183)
local Third_Sea  = (placeId == 7449423635)

local plr   = game.Players.LocalPlayer
local CommF = game:GetService("ReplicatedStorage").Remotes.CommF_

-- ===================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====================

local function getChar()  return plr.Character end
local function getHRP()   return getChar() and getChar():FindFirstChild("HumanoidRootPart") end

-- Tween телепорт (плавный)
local function Tween(cf)
    local hrp = getHRP()
    if not hrp then return end
    local TweenService = game:GetService("TweenService")
    local tween = TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

-- Быстрый телепорт
local function BTP(cf)
    local hrp = getHRP()
    if hrp then hrp.CFrame = cf end
end

-- Экипировать оружие
local function EquipTool(toolName)
    if not toolName then return end
    local char = getChar()
    local backpack = plr.Backpack
    -- Если уже экипировано — ок
    if char and char:FindFirstChild(toolName) then return end
    local tool = backpack:FindFirstChild(toolName)
    if tool then
        plr.Character.Humanoid:EquipTool(tool)
    end
end

-- AutoClick (симуляция атаки через RegisterHit)
local function AutoClick()
    pcall(function()
        local Net = game:GetService("ReplicatedStorage").Modules.Net
        local RegisterAttack = Net["RE/RegisterAttack"]
        local RegisterHit    = Net["RE/RegisterHit"]
        local hrp = getHRP()
        if not hrp then return end

        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < 70 then
                    RegisterAttack:FireServer(0.0000001)
                    RegisterHit:FireServer(v.HumanoidRootPart, {})
                    pcall(function()
                        sethiddenproperty(plr, "SimulationRadius", math.huge)
                    end)
                end
            end
        end
    end)
end

-- Притянуть мобов к игроку
local function BringMonster(targetName, targetCFrame)
    if not targetName or not targetCFrame then return end
    pcall(function()
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local hrp = getHRP()
                if hrp and (v.HumanoidRootPart.Position - hrp.Position).Magnitude < 250 then
                    v.HumanoidRootPart.CFrame       = targetCFrame
                    v.HumanoidRootPart.CanCollide   = false
                    v.HumanoidRootPart.Size         = Vector3.new(60, 60, 60)
                    v.HumanoidRootPart.Transparency = 1
                    v.Humanoid:ChangeState(11)
                    v.Humanoid:ChangeState(14)
                    if v.Humanoid:FindFirstChild("Animator") then
                        v.Humanoid.Animator:Destroy()
                    end
                end
            end
        end
        pcall(function() sethiddenproperty(plr, "SimulationRadius", math.huge) end)
    end)
end

-- Обновить Farm_Mode при изменении типа/дистанции
local function UpdateFarmMode()
    if AutoFarmType == "Above" then
        Farm_Mode = CFrame.new(0, DisFarm, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    else
        Farm_Mode = CFrame.new(0, 2, DisFarm) * CFrame.Angles(math.rad(0), 0, 0)
    end
end

-- ===================== CHECK LEVEL (определяет моба/квест по уровню) =====================

local function CheckLevel()
    local Lv = plr.Data.Level.Value

    if First_Sea then
        if Lv <= 9 then
            Ms="Bandit"; NameQuest="BanditQuest1"; QuestLv=1; NameMon="Bandit"
            CFrameQ=CFrame.new(1060.94,16.46,1547.78); CFrameMon=CFrame.new(1038.55,41.30,1576.51)
        elseif Lv <= 14 then
            Ms="Monkey"; NameQuest="JungleQuest"; QuestLv=1; NameMon="Monkey"
            CFrameQ=CFrame.new(-1601.66,36.85,153.39); CFrameMon=CFrame.new(-1448.14,50.85,63.61)
        elseif Lv <= 29 then
            Ms="Gorilla"; NameQuest="JungleQuest"; QuestLv=2; NameMon="Gorilla"
            CFrameQ=CFrame.new(-1601.66,36.85,153.39); CFrameMon=CFrame.new(-1142.65,40.46,515.39)
        elseif Lv <= 39 then
            Ms="Pirate"; NameQuest="BuggyQuest1"; QuestLv=1; NameMon="Pirate"
            CFrameQ=CFrame.new(-1140.18,4.75,3827.41); CFrameMon=CFrame.new(-1201.09,40.63,3857.60)
        elseif Lv <= 59 then
            Ms="Brute"; NameQuest="BuggyQuest1"; QuestLv=2; NameMon="Brute"
            CFrameQ=CFrame.new(-1140.18,4.75,3827.41); CFrameMon=CFrame.new(-1387.53,24.59,4100.96)
        elseif Lv <= 74 then
            Ms="Desert Bandit"; NameQuest="DesertQuest"; QuestLv=1; NameMon="Desert Bandit"
            CFrameQ=CFrame.new(896.52,6.44,4390.15); CFrameMon=CFrame.new(984.99,16.11,4417.91)
        elseif Lv <= 89 then
            Ms="Desert Officer"; NameQuest="DesertQuest"; QuestLv=2; NameMon="Desert Officer"
            CFrameQ=CFrame.new(896.52,6.44,4390.15); CFrameMon=CFrame.new(1547.15,14.45,4381.80)
        elseif Lv <= 99 then
            Ms="Snow Bandit"; NameQuest="SnowQuest"; QuestLv=1; NameMon="Snow Bandit"
            CFrameQ=CFrame.new(1386.81,87.27,1298.36); CFrameMon=CFrame.new(1356.30,105.77,1328.24)
        elseif Lv <= 119 then
            Ms="Snowman"; NameQuest="SnowQuest"; QuestLv=2; NameMon="Snowman"
            CFrameQ=CFrame.new(1386.81,87.27,1298.36); CFrameMon=CFrame.new(1218.80,138.01,1488.03)
        elseif Lv <= 149 then
            Ms="Chief Petty Officer"; NameQuest="MarineQuest2"; QuestLv=1; NameMon="Chief Petty Officer"
            CFrameQ=CFrame.new(-5035.50,28.68,4324.18); CFrameMon=CFrame.new(-4931.16,65.79,4121.84)
        elseif Lv <= 174 then
            Ms="Sky Bandit"; NameQuest="SkyQuest"; QuestLv=1; NameMon="Sky Bandit"
            CFrameQ=CFrame.new(-4842.14,717.70,2623.05); CFrameMon=CFrame.new(-4955.64,365.46,2908.19)
        elseif Lv <= 189 then
            Ms="Dark Master"; NameQuest="SkyQuest"; QuestLv=2; NameMon="Dark Master"
            CFrameQ=CFrame.new(-4842.14,717.70,2623.05); CFrameMon=CFrame.new(-5148.17,439.05,2332.96)
        elseif Lv <= 209 then
            Ms="Prisoner"; NameQuest="PrisonerQuest"; QuestLv=1; NameMon="Prisoner"
            CFrameQ=CFrame.new(5310.61,0.35,474.95); CFrameMon=CFrame.new(4937.32,0.33,649.57)
        elseif Lv <= 249 then
            Ms="Dangerous Prisoner"; NameQuest="PrisonerQuest"; QuestLv=2; NameMon="Dangerous Prisoner"
            CFrameQ=CFrame.new(5310.61,0.35,474.95); CFrameMon=CFrame.new(5099.66,0.35,1055.76)
        elseif Lv <= 274 then
            Ms="Toga Warrior"; NameQuest="ColosseumQuest"; QuestLv=1; NameMon="Toga Warrior"
            CFrameQ=CFrame.new(-1577.79,7.42,-2984.48); CFrameMon=CFrame.new(-1872.52,49.08,2913.81)
        elseif Lv <= 299 then
            Ms="Gladiator"; NameQuest="ColosseumQuest"; QuestLv=2; NameMon="Gladiator"
            CFrameQ=CFrame.new(-1577.79,7.42,-2984.48); CFrameMon=CFrame.new(-1521.37,81.20,3066.31)
        elseif Lv <= 324 then
            Ms="Military Soldier"; NameQuest="MagmaQuest"; QuestLv=1; NameMon="Military Soldier"
            CFrameQ=CFrame.new(-5316.12,12.26,8517.00); CFrameMon=CFrame.new(-5369.00,61.24,8556.49)
        elseif Lv <= 374 then
            Ms="Military Spy"; NameQuest="MagmaQuest"; QuestLv=2; NameMon="Military Spy"
            CFrameQ=CFrame.new(-5316.12,12.26,8517.00); CFrameMon=CFrame.new(-5787.00,75.83,8651.70)
        elseif Lv <= 399 then
            Ms="Fishman Warrior"; NameQuest="FishmanQuest"; QuestLv=1; NameMon="Fishman Warrior"
            CFrameQ=CFrame.new(61122.65,18.50,1569.40); CFrameMon=CFrame.new(60844.11,98.46,1298.40)
        elseif Lv <= 449 then
            Ms="Fishman Commando"; NameQuest="FishmanQuest"; QuestLv=2; NameMon="Fishman Commando"
            CFrameQ=CFrame.new(61122.65,18.50,1569.40); CFrameMon=CFrame.new(61738.40,64.21,1433.84)
        elseif Lv <= 474 then
            Ms="God's Guard"; NameQuest="SkyExp1Quest"; QuestLv=1; NameMon="God's Guard"
            CFrameQ=CFrame.new(-4721.86,845.30,1953.85); CFrameMon=CFrame.new(-4628.05,866.93,1931.24)
        elseif Lv <= 524 then
            Ms="Shanda"; NameQuest="SkyExp1Quest"; QuestLv=2; NameMon="Shanda"
            CFrameQ=CFrame.new(-7863.16,5545.52,378.42); CFrameMon=CFrame.new(-7685.15,5601.08,441.39)
        elseif Lv <= 549 then
            Ms="Royal Squad"; NameQuest="SkyExp2Quest"; QuestLv=1; NameMon="Royal Squad"
            CFrameQ=CFrame.new(-7903.38,5635.99,-1410.92); CFrameMon=CFrame.new(-7654.25,5637.11,1407.76)
        elseif Lv <= 624 then
            Ms="Royal Soldier"; NameQuest="SkyExp2Quest"; QuestLv=2; NameMon="Royal Soldier"
            CFrameQ=CFrame.new(-7903.38,5635.99,-1410.92); CFrameMon=CFrame.new(-7760.41,5679.91,1884.81)
        elseif Lv <= 649 then
            Ms="Galley Pirate"; NameQuest="FountainQuest"; QuestLv=1; NameMon="Galley Pirate"
            CFrameQ=CFrame.new(5258.28,38.53,4050.04); CFrameMon=CFrame.new(5557.17,152.33,3998.78)
        else
            Ms="Galley Captain"; NameQuest="FountainQuest"; QuestLv=2; NameMon="Galley Captain"
            CFrameQ=CFrame.new(5258.28,38.53,4050.04); CFrameMon=CFrame.new(5677.68,92.79,4966.63)
        end

    elseif Second_Sea then
        if Lv <= 724 then
            Ms="Raider"; NameQuest="Area1Quest"; QuestLv=1; NameMon="Raider"
            CFrameQ=CFrame.new(-427.73,73.00,1835.94); CFrameMon=CFrame.new(68.87,93.64,2429.68)
        elseif Lv <= 774 then
            Ms="Mercenary"; NameQuest="Area1Quest"; QuestLv=2; NameMon="Mercenary"
            CFrameQ=CFrame.new(-427.73,73.00,1835.94); CFrameMon=CFrame.new(-864.85,122.47,1453.15)
        elseif Lv <= 799 then
            Ms="Swan Pirate"; NameQuest="Area2Quest"; QuestLv=1; NameMon="Swan Pirate"
            CFrameQ=CFrame.new(635.61,73.10,917.81); CFrameMon=CFrame.new(1065.37,137.64,1324.38)
        elseif Lv <= 874 then
            Ms="Factory Staff"; NameQuest="Area2Quest"; QuestLv=2; NameMon="Factory Staff"
            CFrameQ=CFrame.new(635.61,73.10,917.81); CFrameMon=CFrame.new(533.22,128.47,355.63)
        elseif Lv <= 899 then
            Ms="Marine Lieutenant"; NameQuest="MarineQuest3"; QuestLv=1; NameMon="Marine Lieutenant"
            CFrameQ=CFrame.new(-2440.99,73.04,3217.71); CFrameMon=CFrame.new(-2489.26,84.61,3151.88)
        elseif Lv <= 949 then
            Ms="Marine Captain"; NameQuest="MarineQuest3"; QuestLv=2; NameMon="Marine Captain"
            CFrameQ=CFrame.new(-2440.99,73.04,3217.71); CFrameMon=CFrame.new(-2335.20,79.79,3245.87)
        elseif Lv <= 974 then
            Ms="Zombie"; NameQuest="ZombieQuest"; QuestLv=1; NameMon="Zombie"
            CFrameQ=CFrame.new(-5494.34,48.51,794.59); CFrameMon=CFrame.new(-5536.50,101.09,835.59)
        elseif Lv <= 999 then
            Ms="Vampire"; NameQuest="ZombieQuest"; QuestLv=2; NameMon="Vampire"
            CFrameQ=CFrame.new(-5494.34,48.51,794.59); CFrameMon=CFrame.new(-5806.11,16.72,1164.44)
        else
            Ms="Snow Trooper"; NameQuest="SnowMountainQuest"; QuestLv=1; NameMon="Snow Trooper"
            CFrameQ=CFrame.new(607.06,401.45,-5370.55); CFrameMon=CFrame.new(535.21,432.74,5484.92)
        end
    end
end

-- ===================== АВТО ВЫБОР ОРУЖИЯ =====================
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, v in pairs(plr.Backpack:GetChildren()) do
                if v:IsA("Tool") and v.ToolTip == SelectWeaponFarm then
                    SelectWeapon = v.Name
                end
            end
        end)
    end
end)

-- ===================== ОСНОВНОЙ ФАРМ (с квестом) =====================
task.spawn(function()
    while task.wait() do
        if LevelFarmQuest then
            pcall(function()
                CheckLevel()
                UpdateFarmMode()

                local questUI = plr.PlayerGui:FindFirstChild("Main") and plr.PlayerGui.Main:FindFirstChild("Quest")
                local questVisible = questUI and questUI.Visible
                local questTitle   = questUI and questUI:FindFirstChild("Container") and questUI.Container:FindFirstChild("QuestTitle")
                local hasQuest     = questTitle and string.find(questTitle.Title.Text or "", NameMon or "")

                if not hasQuest or not questVisible then
                    -- Берём квест
                    CommF_:InvokeServer("AbandonQuest")
                    Tween(CFrameQ)
                    if CFrameQ and (CFrameQ.Position - getHRP().Position).Magnitude <= 5 then
                        task.wait(1)
                        CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                    end
                else
                    -- Бьём мобов
                    local enemy = workspace.Enemies:FindFirstChild(Ms)
                    if enemy then
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name == Ms and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                EquipTool(SelectWeapon)
                                Tween(v.HumanoidRootPart.CFrame * Farm_Mode)
                                v.HumanoidRootPart.CanCollide   = false
                                v.HumanoidRootPart.Size         = Vector3.new(60,60,60)
                                v.HumanoidRootPart.Transparency = 1
                                Level_Farm_Name   = v.Name
                                Level_Farm_CFrame = v.HumanoidRootPart.CFrame
                                AutoClick()
                                task.wait(0.05)
                                break
                            end
                        end
                    else
                        Tween(CFrameMon)
                    end
                end
            end)
        end
    end
end)

-- ===================== ФАРМ БЕЗ КВЕСТА =====================
task.spawn(function()
    while task.wait() do
        if LevelFarmNoQuest then
            pcall(function()
                CheckLevel()
                UpdateFarmMode()
                local enemy = workspace.Enemies:FindFirstChild(Ms)
                if enemy then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == Ms and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                            EquipTool(SelectWeapon)
                            Tween(v.HumanoidRootPart.CFrame * Farm_Mode)
                            v.HumanoidRootPart.CanCollide   = false
                            v.HumanoidRootPart.Size         = Vector3.new(60,60,60)
                            v.HumanoidRootPart.Transparency = 1
                            AutoClick()
                            task.wait(0.05)
                            break
                        end
                    end
                else
                    Tween(CFrameMon)
                end
            end)
        end
    end
end)

-- ===================== ПРИТЯГИВАНИЕ МОБОВ =====================
task.spawn(function()
    while task.wait(0.5) do
        if (LevelFarmQuest or LevelFarmNoQuest) and Level_Farm_Name and Level_Farm_CFrame then
            pcall(function()
                BringMonster(Level_Farm_Name, Level_Farm_CFrame)
            end)
        end
    end
end)

-- ===================== АВТО БОСС =====================
local bossList = {
    {name="Bobby",         pos=CFrame.new(977.47, 44.40, 1430.00)},
    {name="Yeti",          pos=CFrame.new(1175.00, 138.00, 1420.00)},
    {name="Mob Leader",    pos=CFrame.new(-1201.09, 40.63, 3857.60)},
    {name="Vice Admiral",  pos=CFrame.new(-5096.74, 28.50, 4262.50)},
    {name="Warden",        pos=CFrame.new(5310.61, 0.35, 474.95)},
    {name="Chief Warden",  pos=CFrame.new(5310.61, 0.35, 474.95)},
}

task.spawn(function()
    while task.wait() do
        if AutoFarmBoss then
            pcall(function()
                for _, boss in pairs(bossList) do
                    local bossModel = workspace.Enemies:FindFirstChild(boss.name)
                    if bossModel and bossModel:FindFirstChild("Humanoid") and bossModel.Humanoid.Health > 0 then
                        EquipTool(SelectWeapon)
                        Tween(bossModel.HumanoidRootPart.CFrame * Farm_Mode)
                        AutoClick()
                        task.wait(0.1)
                        break
                    end
                end
            end)
        end
    end
end)

-- ===================== ПОИСК ФРУКТОВ =====================
task.spawn(function()
    while task.wait(5) do
        if AutoFruitSearch then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("fruit") or obj.Name:lower():find("devil")) then
                        local hrp = getHRP()
                        if hrp then
                            local dist = math.floor((obj.Position - hrp.Position).Magnitude)
                            WindUI:Notify({
                                Title   = "🍎 Фрукт найден!",
                                Content = obj.Name .. " | " .. dist .. " студ",
                                Duration = 8,
                            })
                            if AutoFruitTeleport then
                                Tween(CFrame.new(obj.Position + Vector3.new(0, 3, 0)))
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ===================== BUSO HAKI =====================
task.spawn(function()
    while task.wait(1) do
        if BusoHaki then
            pcall(function()
                if not getChar():FindFirstChild("HasBuso") then
                    CommF_:InvokeServer("Buso")
                end
            end)
        end
    end
end)

-- ===================== ANTI AFK =====================
task.spawn(function()
    while task.wait(0.1) do
        if AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                plr.Idled:connect(function()
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end)
        end
    end
end)

-- ===================== ANTI LAG =====================
local function AntiLag()
    local l = game.Lighting
    local t = workspace.Terrain
    t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0; t.WaterTransparency = 0
    l.GlobalShadows = false; l.FogEnd = 9e9; l.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false
        elseif v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled = false
        end
    end
    WindUI:Notify({ Title = "Anti Lag", Content = "FPS оптимизирован!", Duration = 3 })
end

-- ===================== NOCLIP LOOP =====================
task.spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        if LevelFarmQuest or LevelFarmNoQuest or AutoFarmBoss then
            pcall(function()
                for _, v in pairs(getChar():GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end)
        end
    end)
end)

-- ===================== UI =====================

-- ГЛАВНАЯ
local HomeSection = Tabs.Main:Section({ Title = "Статус" })
HomeSection:Button({
    Title = "Anti Lag / FPS Boost",
    Description = "Убирает эффекты для повышения FPS",
    Callback = AntiLag,
})
HomeSection:Toggle({
    Title = "Anti AFK",
    Description = "Не вылетаешь за бездействие",
    Default = false,
    Callback = function(v) AntiAFK = v end,
})
HomeSection:Toggle({
    Title = "Buso Haki (Авто)",
    Description = "Автоматически включает Buso Haki",
    Default = false,
    Callback = function(v) BusoHaki = v end,
})

-- ФАРМ
local FarmSection = Tabs.Farm:Section({ Title = "Авто Фарм" })
FarmSection:Toggle({
    Title = "Фарм с Квестом",
    Description = "Берёт квест → бьёт мобов → сдаёт (авто по уровню)",
    Default = false,
    Callback = function(v)
        LevelFarmQuest = v
        if v then LevelFarmNoQuest = false end
    end,
})
FarmSection:Toggle({
    Title = "Фарм без Квеста",
    Description = "Просто бьёт мобов без взятия квеста",
    Default = false,
    Callback = function(v)
        LevelFarmNoQuest = v
        if v then LevelFarmQuest = false end
    end,
})

local FarmSetSection = Tabs.Farm:Section({ Title = "Настройки Фарма" })
FarmSetSection:Dropdown({
    Title = "Тип оружия",
    Values = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = "Melee",
    Callback = function(v) SelectWeaponFarm = v end,
})
FarmSetSection:Dropdown({
    Title = "Позиция фарма",
    Values = {"Above", "Beside"},
    Default = "Above",
    Callback = function(v)
        AutoFarmType = v
        UpdateFarmMode()
    end,
})
FarmSetSection:Slider({
    Title = "Дистанция фарма",
    Min = 5, Max = 60, Default = 30, Rounding = 0,
    Callback = function(v)
        DisFarm = v
        UpdateFarmMode()
    end,
})
FarmSetSection:Button({
    Title = "Показать текущего моба",
    Callback = function()
        pcall(CheckLevel)
        WindUI:Notify({
            Title   = "Текущий моб",
            Content = Ms and (Ms .. " | Квест: " .. (NameQuest or "?")) or "Не определён (войди в игру)",
            Duration = 5,
        })
    end,
})

-- ФРУКТЫ
local FruitSection = Tabs.Fruits:Section({ Title = "Поиск Фруктов" })
FruitSection:Toggle({
    Title = "Авто Поиск Фруктов",
    Description = "Сканирует карту каждые 5 сек и уведомляет",
    Default = false,
    Callback = function(v) AutoFruitSearch = v end,
})
FruitSection:Toggle({
    Title = "Авто Телепорт к Фрукту",
    Description = "Телепортирует к найденному фрукту",
    Default = false,
    Callback = function(v) AutoFruitTeleport = v end,
})
FruitSection:Button({
    Title = "Найти фрукт сейчас",
    Callback = function()
        local found = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("fruit") or obj.Name:lower():find("devil")) then
                found = true
                local hrp = getHRP()
                local dist = hrp and math.floor((obj.Position - hrp.Position).Magnitude) or 0
                WindUI:Notify({ Title = "🍎 Фрукт!", Content = obj.Name .. " | " .. dist .. " студ", Duration = 6 })
                Tween(CFrame.new(obj.Position + Vector3.new(0, 3, 0)))
                break
            end
        end
        if not found then
            WindUI:Notify({ Title = "Фрукты", Content = "Фруктов не найдено :(", Duration = 3 })
        end
    end,
})

-- БОССЫ
local BossSection = Tabs.Boss:Section({ Title = "Авто Боссы" })
BossSection:Toggle({
    Title = "Авто Фарм Боссов",
    Description = "Атакует боссов Sea 1 автоматически",
    Default = false,
    Callback = function(v) AutoFarmBoss = v end,
})
BossSection:Button({
    Title = "Найти босса сейчас",
    Callback = function()
        for _, boss in pairs(bossList) do
            local b = workspace.Enemies:FindFirstChild(boss.name)
            if b and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then
                WindUI:Notify({ Title = "Босс найден!", Content = boss.name, Duration = 4 })
                Tween(b.HumanoidRootPart.CFrame * Farm_Mode)
                return
            end
        end
        WindUI:Notify({ Title = "Боссы", Content = "Боссов нет на сервере", Duration = 3 })
    end,
})

-- РАЗНОЕ
local MiscSection = Tabs.Misc:Section({ Title = "Прочее" })
MiscSection:Toggle({
    Title = "Bypass Teleport",
    Description = "Мгновенный телепорт вместо Tween",
    Default = false,
    Callback = function(v) ByPassTP = v end,
})
MiscSection:Button({
    Title = "Set Spawn Point",
    Description = "Установить точку спавна здесь",
    Callback = function()
        pcall(function() CommF_:InvokeServer("SetSpawnPoint") end)
        WindUI:Notify({ Title = "Spawn", Content = "Точка спавна установлена!", Duration = 3 })
    end,
})
MiscSection:Button({
    Title = "Reset Character",
    Callback = function()
        local char = getChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v:Destroy() end
            end
        end
    end,
})

-- ===================== ПРИВЕТСТВИЕ =====================
WindUI:Notify({
    Title   = "Blox Fruits Farm",
    Content = "Скрипт загружен! Sea: " .. (First_Sea and "First" or Second_Sea and "Second" or Third_Sea and "Third" or "Unknown"),
    Duration = 6,
})
