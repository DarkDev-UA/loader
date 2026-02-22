local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DarkDev | Hub",
   Icon = "moon",
   LoadingTitle = "DarkDev Community",
   LoadingSubtitle = "by WoxverUA",
   ShowText = "Open UI",
   Theme = "DarkBlue",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DarkDevHub",
      FileName = "DarkDevConfig"
   },

   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/BxNBdEgcV",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "DarkDev | Hub",
      Subtitle = "Key System",
      Note = "Join my Discord to get a Key | https://discord.gg/BxNBdEgcV",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"DarkDev-2026"}
   }
})

local Tabs = ({
  InfoTab = Window:CreateTab("Info", "info"),
  MainTab = Window:CreateTab("Main", "house"),
  VisualsTab = Window:CreateTab("Visuals", "scan-eye")
})

Rayfield:LoadConfiguration()