local OceanUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEERSTUDIO101/Ocean/refs/heads/main/ocean.lua"))()

local Window = OceanUI:CreateWindow({
	Title = "Ocean",
	-- Size  = {680, 420},  -- optional custom size
})

Window:CreateTag("BETA", Color3.fromRGB(240, 100, 100))
Window:CreateTag("v1.2", Color3.fromRGB(80, 150, 255))

Window:Notify({
	Title = "Welcome",
	Text = "Successfully loaded script hub!",
	Icon = "check",
	Duration = 4
})

local MainTab = Window:AddTab("Main", "home")

MainTab:AddToggle({
	Title    = "Anti-AFK",
	Subtitle = "Prevent idle kick",
	Icon     = "shield",
	Default  = false,
	Callback = function(state)
		Window:Notify({
			Title = "Module Update",
			Text = "Anti-AFK is now " .. (state and "Enabled" or "Disabled"),
			Icon = state and "check" or "x",
			Duration = 2
		})
	end,
})

MainTab:AddToggle({
	Title    = "Unlock FPS",
	Subtitle = "Remove frame cap",
	Icon     = "monitor",
	Default  = true,
	Callback = function(state)
		Window:Notify({
			Title = "FPS Unlocker",
			Text = state and "Cap removed" or "Cap restored",
			Icon = "monitor",
			Duration = 2
		})
	end,
})

MainTab:AddSeparator()

MainTab:AddSlider({
	Title   = "Walk Speed",
	Icon    = "user",
	Min     = 16,
	Max     = 100,
	Default = 16,
	Callback = function(value)
		print("Walk Speed:", value)
	end,
})

MainTab:AddSlider({
	Title   = "Jump Power",
	Icon    = "arrow-up",
	Min     = 50,
	Max     = 200,
	Default = 50,
	Callback = function(value)
		print("Jump Power:", value)
	end,
})

MainTab:AddSeparator()

MainTab:AddButton({
	Title    = "Rejoin",
	Icon     = "log-out",
	Callback = function()
		Window:Notify({Title="Teleporting...", Text="Rejoining server", Icon="log-out", Duration=2})
		task.wait(1)
		game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
	end,
})

MainTab:AddButton({
	Title    = "Copy Job ID",
	Icon     = "copy",
	Callback = function()
		setclipboard(game.JobId)
		Window:Notify({
			Title = "Copied",
			Text = "Job ID copied to clipboard!",
			Icon = "file-check",
			Duration = 2
		})
	end,
})

local PlayersTab = Window:AddTab("Players", "users")

PlayersTab:AddLabel("Select a player to interact with", "info")

PlayersTab:AddDropdown({
	Title   = "Target",
	Icon    = "crosshair",
	Options = {"Player1", "Player2", "Player3"},
	Default = 1,
	Callback = function(selected)
		Window:Notify({
			Title = "Target Updated",
			Text = "Selected: " .. selected,
			Icon = "user-check",
			Duration = 2
		})
	end,
})

PlayersTab:AddTextBox({
	Title       = "Custom Name",
	Icon        = "pencil",
	Placeholder = "Enter username...",
	Callback    = function(text, enterPressed)
		if enterPressed then
			Window:Notify({
				Title = "Search",
				Text = "Looking up " .. text,
				Icon = "search",
				Duration = 2
			})
		end
	end,
})

local SettingsTab = Window:AddTab("Settings", "settings")

SettingsTab:AddKeybind({
	Title    = "Toggle UI",
	Subtitle = "Press to show/hide",
	Icon     = "keyboard",
	Default  = Enum.KeyCode.RightShift,
	Callback = function()
		Window:Notify({
			Title = "Keybind",
			Text = "UI toggled!",
			Icon = "keyboard",
			Duration = 2
		})
	end,
})

SettingsTab:AddToggle({
	Title   = "Notifications",
	Icon    = "bell",
	Default = true,
	Callback = function(state)
		Window:Notify({
			Title = "Settings",
			Text = state and "Notifications On" or "Notifications Off",
			Icon = state and "bell" or "bell-off",
			Duration = 2
		})
	end,
})

SettingsTab:AddSlider({
	Title   = "UI Scale",
	Icon    = "move",
	Min     = 50,
	Max     = 150,
	Default = 100,
	Callback = function(value)
		print("UI Scale:", value, "%")
	end,
})

SettingsTab:AddPrivacyToggle(SettingsTab, {
    Title    = "Privacy Mode",
    Subtitle = "Versteckt deinen Namen & Avatar",
    Default  = false,
})