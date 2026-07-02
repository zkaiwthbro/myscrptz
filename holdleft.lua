-- LocalScript in StarterPlayerScripts
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera

local toggled = false

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.M then
		toggled = not toggled
		
		local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
		
		if toggled then
			print("Holding left click: ON (background mode)")
		else
			VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
			print("Holding left click: OFF")
		end
	end
end)

-- Continuous hold loop (more resilient when tabbed out)
task.spawn(function()
	while true do
		if toggled then
			local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
			VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
		end
		task.wait(0.05) -- keep re-sending the hold
	end
end)
