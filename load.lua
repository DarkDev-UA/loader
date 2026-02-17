local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local autoFarmEnabled = false
local autoQuestEnabled = false
local Ms, NM, NQ, LQ, CQ
local BannedUsers = {10500256022}

local ErrorTable = {
    [111] = "Welcome, loaded successfully.",
    [270] = "Core component missing! Please check connection.",
    [347] = "Game not supported. Script unloaded.",
    [816] = "You have been banned from the script.",
    [392] = "Sorry, we can't load script! Something went horribly wrong."
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RegisterAttack = ReplicatedStorage.Modules.Net["RE/RegisterAttack"]
local RegisterHit = ReplicatedStorage.Modules.Net["RE/RegisterHit"]

local function DarkNotify(code)
    local message = ErrorTable[code] or "Unknown Error occurred."
    Library:Notify({
        Title = "DarkDev | Code " .. tostring(code),
        Description = message,
        Time = 7,
    })
end

local function GetSessionID()
    local success, result = pcall(function()
        local SendHitsToServer = getrenv()._G.SendHitsToServer
        local CombatThread = getupvalues(SendHitsToServer)[1]
        local UserIDSlice = tostring(game.Players.LocalPlayer.UserId):sub(2, 4)
        local MemorySlice = tostring(CombatThread):sub(11, 15)
        return UserIDSlice .. MemorySlice
    end)
    return success and result or "ErrorID"
end

local function FastAttack(target)
    pcall(function()
        RegisterAttack:FireServer(0.5)
        local dataTable = {
            target:WaitForChild("RightLowerLeg"),
            {},
            nil,
            GetSessionID()
        }
        RegisterHit:FireServer(unpack(dataTable))
    end)
end

local function CheckQuest()
    local Lv = game.Players.LocalPlayer.Data.Level.Value
    if Lv >= 0 and Lv <= 10 then
        Ms, NM, LQ, NQ, CQ = "Bandit", "Bandit", 1, "BanditQuest1", CFrame.new(1062, 16, 1546)
    elseif Lv >= 10 and Lv <= 15 then
        Ms, NM, LQ, NQ, CQ = "Monkey", "Monkey", 1, "JungleQuest", CFrame.new(-1601, 36, 153)
    end
end

local function CleanUp()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v.Name == "DarkVelocity" then
                v:Destroy()
            end
        end
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        local ts = game:GetService("TweenService")
        pcall(function() ts:Create(hrp, TweenInfo.new(0), {CFrame = hrp.CFrame}):Play() end)
    end
end

local function TP(P)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local bv = hrp:FindFirstChild("DarkVelocity") or Instance.new("BodyVelocity")
        bv.Name = "DarkVelocity"
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
        
        local dist = (P.Position - hrp.Position).Magnitude
        if dist < 5 then hrp.CFrame = P return end
        game:GetService("TweenService"):Create(hrp, TweenInfo.new(dist/300, Enum.EasingStyle.Linear), {CFrame = P}):Play()
    end
end

local player = game:GetService("Players").LocalPlayer
for _, id in pairs(BannedUsers) do
    if player.UserId == id then
        DarkNotify(816)
        task.wait(5)
        Library:Unload()
        return
    end
end

if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272121 and game.PlaceId ~= 7449423635 then
    DarkNotify(347)
    task.wait(5)
    Library:Unload()
    return 
end

local Window = Library:CreateWindow({
    Title = "DarkDev | Hub",
    Footer = "Build: v1.0.3 | Game: Blox Fruit",
    NotifySide = "Right",
})

local Tabs = { Main = Window:AddTab("Main", "house") }
local MainGroup = Tabs.Main:AddLeftGroupbox("Main Functions")

MainGroup:AddToggle("AutoFarm", {
    Text = "Auto Farm Level",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        if not Value then 
            autoFarmEnabled = false 
            CleanUp() 
            return
        end
        
        task.spawn(function()
            while autoFarmEnabled do
                if not autoFarmEnabled then break end
                
                task.wait(0.1)
                pcall(function()
                    CheckQuest()
                    local char = game.Players.LocalPlayer.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    local questVisible = game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible
                    
                    if autoQuestEnabled and not questVisible then
                        CleanUp()
                        TP(CQ)
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NQ, LQ)
                    else
                        local target = nil
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name:find(NM) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                target = v; break
                            end
                        end

                        if target and target:FindFirstChild("HumanoidRootPart") then
                            if not autoFarmEnabled then CleanUp() return end
                            
                            local tPos = target.HumanoidRootPart.Position
                            hrp.CFrame = CFrame.new(tPos.X, tPos.Y + 45, tPos.Z)
                            
                            local bv = hrp:FindFirstChild("DarkVelocity") or Instance.new("BodyVelocity")
                            bv.Name = "DarkVelocity"
                            bv.Velocity = Vector3.new(0,0,0)
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Parent = hrp
                            
                            FastAttack(target)
                        else
                            CleanUp()
                            TP(CQ * CFrame.new(0, 50, 0))
                        end
                    end
                end)
            end
            CleanUp()
        end)
    end
})

MainGroup:AddToggle("AutoQuest", {
    Text = "Auto Take Quest",
    Default = false,
    Callback = function(Value)
        autoQuestEnabled = Value
    end
})

DarkNotify(111)