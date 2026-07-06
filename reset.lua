-- LocalScript in StarterPlayerScript
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local toggled = false

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.R then
		toggled = not toggled
		print("Auto-reset toggled:", toggled)
	end
end)

-- Infinite loop (survives respawns since it's a LocalScript)
while true do
	task.wait(300) -- 3 minutes
	
	if toggled then
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Health = 0
			end
		end
	end
end
