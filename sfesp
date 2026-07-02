local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Wait for LocalPlayer
local player = Players.LocalPlayer
while not player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

-- Wait for PlayerGui
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 30)
if not playerGui then
    warn("[Starflower] PlayerGui not found")
    return
end

-- ===== WAIT FOR PLAYER TO CLICK PLAY (character spawn) =====
print("[Starflower] Waiting for you to click Play...")
local character = player.Character or player.CharacterAdded:Wait()
print("[Starflower] Play detected! Starting tracker...")

local StarflowerTypes = {
    ["Basic"] = true,
    ["Rare"] = true,
    ["Epic"] = true,
    ["Legendary"] = true,
    ["Mythic"] = true,
    ["Lunar"] = true,
}

local ESPEnabled = true
local Highlights = {}
local TrackedModels = {}

-- ========== GUI SETUP ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StarflowerTracker"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 220)
frame.Position = UDim2.new(1, -340, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Starflower Spawns"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -35)
scroll.Position = UDim2.new(0, 5, 0, 32)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scroll

-- ========== HELPER ==========
local function GetFieldName(part)
    local current = part.Parent
    while current and current ~= workspace do
        if current.Name and current.Name:lower():find("field") then
            return current.Name
        end
        current = current.Parent
    end
    return "Unknown Field"
end

local function AddToGUI(typeName, fieldName)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 22)
    label.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    label.Text = typeName .. "  |  " .. fieldName
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.TextSize = 15
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scroll

    scroll.CanvasSize = UDim2.new(0, 0, 0, #scroll:GetChildren() * 26)

    task.delay(30, function()
        if label and label.Parent then label:Destroy() end
    end)
end

-- ========== ESP ==========
local function CreateESP(model)
    if Highlights[model] then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(0, 255, 150)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    Highlights[model] = highlight
end

local function RemoveESP(model)
    if Highlights[model] then
        Highlights[model]:Destroy()
        Highlights[model] = nil
    end
end

-- ========== PROCESS STARFLOWER ==========
local function ProcessStarflower(model)
    if not model or not model:IsA("Model") then return end
    if not StarflowerTypes[model.Name] then return end
    if TrackedModels[model] then return end
    TrackedModels[model] = true

    task.wait(0.2)
    if not model.Parent then return end

    local part = model:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end

    local field = GetFieldName(part)
    AddToGUI(model.Name, field)

    if ESPEnabled then
        CreateESP(model)
    end

    model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            RemoveESP(model)
            TrackedModels[model] = nil
        end
    end)
end

-- ========== MONITOR ==========
local function MonitorStarFlowers()
    local debris = workspace:FindFirstChild("Debris") or workspace:WaitForChild("Debris", 9e9)
    if not debris then return end

    local folder = debris:FindFirstChild("Star Flowers") or debris:WaitForChild("Star Flowers", 9e9)
    if not folder then return end

    for _, model in pairs(folder:GetChildren()) do
        task.spawn(ProcessStarflower, model)
    end

    folder.ChildAdded:Connect(function(model)
        task.spawn(ProcessStarflower, model)
    end)

    print("[Starflower] Monitoring active.")
end

-- ========== TOGGLE ==========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        ESPEnabled = not ESPEnabled
        frame.Visible = ESPEnabled

        if ESPEnabled then
            for model in pairs(TrackedModels) do
                if model and model.Parent then CreateESP(model) end
            end
        else
            for model in pairs(Highlights) do RemoveESP(model) end
        end
    end
end)

-- ========== START ==========
task.spawn(MonitorStarFlowers)

print("[Starflower] Loaded. Press F to toggle.")
