local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local hitboxSize = 1
local hitboxEnabled = false
local hitboxVisual = false
local Players = game:GetService("Players")
local enabled = false
local espColor = Color3.fromRGB(0, 255, 0)
local connections = {}

local function updateHitbox(player)
    if player == Players.LocalPlayer then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        if hitboxEnabled then
            hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            hrp.CanCollide = false
            if hitboxVisual then
                hrp.Transparency = 0.7
                hrp.Material = Enum.Material.Neon
                hrp.BrickColor = BrickColor.new("Really red")
            else
                hrp.Transparency = 1
                hrp.Material = Enum.Material.Plastic
            end
        else
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 1
        end
    end
end

RunService.RenderStepped:Connect(function()
    if hitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            updateHitbox(p)
        end
    end
end)

local function applyEsp(player)
    if player == Players.LocalPlayer then return end
    
    local function setup(char)
        if not char then return end
        
        local hl = char:FindFirstChild("esp_hl")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "esp_hl"
            hl.Parent = char
        end
        
        if enabled then
            hl.FillColor = espColor
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Adornee = char
            hl.Enabled = true
        else
            hl.Enabled = false
        end
    end
    
    if connections[player] then connections[player]:Disconnect() end
    connections[player] = player.CharacterAdded:Connect(setup)
    
    if player.Character then setup(player.Character) end
end

local Window = WindUI:CreateWindow({
    Title = "DarkDev",
    Icon = "ghost",
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
            print("clicked")
        end,
    },
    
    KeySystem = { 
        Key = { "1234" },
        
        Note = "DarkDev Key System",
        
        URL = "1234",
        
        SaveKey = true,
    },
})

Window:EditOpenButton({
    Title = "Open DarkDev",
    Icon = "ghost",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("#780000"), 
        Color3.fromHex("#450000")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})


local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
    Locked = false,
})

local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "scan-eye",
    Locked = false,
})

local HitboxSection = MainTab:Section({ 
    Title = "Hitbox",
    Icon = "box",
})

local EspSection = VisualsTab:Section({ 
    Title = "Esp",
    Icon = "eye",
})

local HitboxSizeSlider = HitboxSection:Slider({
    Title = "Hitbox Size",
    Description = "Set the hitbox size",
    Step = 1,
    Value = {Min = 1, Max = 100, Default = 1},
    Callback = function(value)
        hitboxSize = value
    end
})

HitboxSection:Divider()

local EnableHitboxToggle = HitboxSection:Toggle({
    Title = "Enable Hitbox",
    Value = false,
    Callback = function(state) 
        hitboxEnabled = state
        if not state then
            for _, p in ipairs(Players:GetPlayers()) do updateHitbox(p) end
        end
    end
})

local EspColorpicker = EspSection:Colorpicker({
    Title = "Esp Color",
    Description = "Select color of Esp",
    Default = espColor,
    Callback = function(color) 
        espColor = color
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("esp_hl") then
                p.Character.esp_hl.FillColor = color
            end
        end
    end
})

EspSection:Divider()

local PlayersEspToggle = EspSection:Toggle({
    Title = "Players Esp",
    Value = false,
    Callback = function(state) 
        enabled = state
        
        if enabled then
            for _, p in ipairs(Players:GetPlayers()) do
                applyEsp(p)
            end
            connections["PlayerAdded"] = Players.PlayerAdded:Connect(applyEsp)
        else
            if connections["PlayerAdded"] then
                connections["PlayerAdded"]:Disconnect()
                connections["PlayerAdded"] = nil
            end
            
            for _, p in ipairs(Players:GetPlayers()) do
                if connections[p] then 
                    connections[p]:Disconnect() 
                    connections[p] = nil 
                end
                if p.Character and p.Character:FindFirstChild("esp_hl") then
                    p.Character.esp_hl:Destroy()
                end
            end
        end
    end
})

local HitboxEspToggle = EspSection:Toggle({
    Title = "Hitbox Esp",
    Value = false,
    Callback = function(state) 
        hitboxVisual = state
        
        if hitboxEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if state then
                        hrp.Transparency = 0.7
                        hrp.Material = Enum.Material.Neon
                    else
                        hrp.Transparency = 1
                        hrp.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    end
})