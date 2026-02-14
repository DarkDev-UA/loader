local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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

local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "scan-eye",
    Locked = false,
})

local Players = game:GetService("Players")
local enabled = false
local connections = {}

local function applyEsp(player)
    if player == Players.LocalPlayer then return end
    
    local function setup(char)
        if not char then return end
        
        local old = char:FindFirstChild("esp_hl")
        if old then old:Destroy() end
        
        if enabled then
            local hl = Instance.new("Highlight")
            hl.Name = "esp_hl"
            hl.FillColor = Color3.fromRGB(0, 255, 127)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Adornee = char
            hl.Parent = char
        end
    end
    
    connections[player] = player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

local PlayersEspToggle = VisualsTab:Toggle({
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