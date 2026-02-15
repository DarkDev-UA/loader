local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AimSettings = {
    Enabled = false,
    FovEnabled = false,
    FovRadius = 100,
    FovColor = Color3.fromRGB(0, 255, 0),
    Smoothness = 1,
    TeamCheck = false,
    WallCheck = false,
    TargetPart = "Head"
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local function GetBodyPart(character)
    local partName = AimSettings.TargetPart
    if partName == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    elseif partName == "Legs" then
        return character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("LeftLeg")
    end
    return character:FindFirstChild("Head")
end

local function IsVisible(part)
    if not AimSettings.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, part.Parent})
    return hit == nil
end

local function GetClosestToMouse()
    local target = nil
    local dist = AimSettings.FovRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not AimSettings.TeamCheck or player.Team ~= LocalPlayer.Team) then
            local part = GetBodyPart(player.Character)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mouseDistance = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mouseDistance < dist and IsVisible(part) then
                        dist = mouseDistance
                        target = part
                    end
                end
            end
        end
    end
    return target
end

local Window = WindUI:CreateWindow({
    Title = "DarkDev",
    Icon = "moon",
    Author = "by WoxverUA",
    Folder = "DarkDev",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            
        end,
    },
    
    KeySystem = { 
        Key = { "DarkDev-2026" },
        
        Note = "DarkDev Key System",
        
        URL = "https://discord.gg/uwDS6njya",
        
        SaveKey = true,
    },
})

Window:Tag({
    Title = "v1.0.0",
    Icon = "circle-check",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 13,
})

Window:EditOpenButton({
    Title = "Open UI",
    Icon = "moon",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("#290063"), 
        Color3.fromHex("#170038")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
    Locked = false,
})

Window:Divider()

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
    Locked = false,
})

local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "crosshair",
    Locked = false,
})

local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "scan-eye",
    Locked = false,
})

local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user",
    Locked = false,
})

Window:Divider()

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
    Locked = false,
})

local FovColorpicker = CombatTab:Colorpicker({
    Title = "Fov Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(color) 
        AimSettings.FovColor = color
        FOVCircle.Color = color
    end
})

local FovSizeSlider = CombatTab:Slider({
    Title = "Fov Size",
    Step = 1,
    Value = {Min = 10, Max = 500, Default = 100},
    Callback = function(value)
        AimSettings.FovRadius = value
        FOVCircle.Radius = value
    end
})

local FovToggle = CombatTab:Toggle({
    Title = "Fov",
    Value = false,
    Callback = function(state) 
        AimSettings.FovEnabled = state
        FOVCircle.Visible = state
    end
})

CombatTab:Divider()

local AimbotToggle = CombatTab:Toggle({
    Title = "Aimbot",
    Value = false,
    Callback = function(state) 
        AimSettings.Enabled = state
    end
})

local WallCheckToggle = CombatTab:Toggle({
    Title = "WallCheck",
    Value = false,
    Callback = function(state) 
        AimSettings.WallCheck = state
    end
})

local TeamCheckToggle = CombatTab:Toggle({
    Title = "Team Check",
    Value = false,
    Callback = function(state) 
        AimSettings.TeamCheck = state
    end
})

local AimbotPartDropdown = CombatTab:Dropdown({
    Title = "Aiming Part",
    Values = { "Head", "Torso", "Legs" },
    Value = "Head",
    Callback = function(option) 
        AimSettings.TargetPart = option
    end
})

local AimbotSmoothnessSlider = CombatTab:Slider({
    Title = "Smoothness",
    Step = 0.01,
    Value = {Min = 0.01, Max = 1, Default = 1},
    Callback = function(value)
        AimSettings.Smoothness = value
    end
})

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    if AimSettings.Enabled then
        local target = GetClosestToMouse()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            
            local moveX = (targetPos.X - mousePos.X) * AimSettings.Smoothness
            local moveY = (targetPos.Y - mousePos.Y) * AimSettings.Smoothness
            
            if mouse_event then
                mouse_event(0x0001, moveX, moveY, 0, 0)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
    end
end)