local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SAVE_FILE = "waypoints_" .. game.PlaceId .. ".json"

local points = {}
local walking = false


local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local ControlModule = PlayerModule:GetControls()

local currentMoveDir = Vector3.new(0, 0, 0)
local moveConn

local function StartMove(cameraRelativeDir)
    currentMoveDir = cameraRelativeDir
    if moveConn then return end
    moveConn = RunService.Heartbeat:Connect(function()
        local ac = ControlModule.activeController
        if ac then
            ac.moveVector = currentMoveDir
            ac.forwardValue = -currentMoveDir.Z
            ac.backwardValue = 0
            ac.leftValue = -currentMoveDir.X
            ac.rightValue = 0
            ac.moveVectorIsCameraRelative = true
        end
        ControlModule.inputMoveVector = currentMoveDir
    end)
end

local function StopMove()
    if moveConn then moveConn:Disconnect() moveConn = nil end
    local ac = ControlModule.activeController
    if ac then
        ac.moveVector = Vector3.new(0, 0, 0)
        ac.forwardValue = 0
        ac.backwardValue = 0
        ac.leftValue = 0
        ac.rightValue = 0
    end
    ControlModule.inputMoveVector = Vector3.new(0, 0, 0)
end

-- Rebind ControlModule when character respawns
player.CharacterAdded:Connect(function()
    task.wait(1)
    PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
    ControlModule = PlayerModule:GetControls()
end)

-- ========== SAVE / LOAD ==========
local function savePoints()
    local data = {}
    for _, v in ipairs(points) do
        table.insert(data, {v.X, v.Y, v.Z})
    end
    writefile(SAVE_FILE, HttpService:JSONEncode(data))
end

local function loadPoints()
    if isfile and isfile(SAVE_FILE) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and data then
            for _, v in ipairs(data) do
                table.insert(points, Vector3.new(v[1], v[2], v[3]))
            end
        end
    end
end

loadPoints()

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGui"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local FULL_HEIGHT = 360
local MIN_HEIGHT = 30

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, FULL_HEIGHT)
frame.Position = UDim2.new(0.02, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.BorderSizePixel = 0
title.Text = "  Waypoint Walker"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local titleBg = Instance.new("Frame")
titleBg.Size = UDim2.new(1, 0, 0, 30)
titleBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBg.BorderSizePixel = 0
titleBg.ZIndex = 0
titleBg.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBg

title.BackgroundTransparency = 1
title.ZIndex = 2

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.ZIndex = 2
minBtn.Parent = frame

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    frame.Size = UDim2.new(0, 220, 0, minimized and MIN_HEIGHT or FULL_HEIGHT)
    minBtn.Text = minimized and "+" or "—"
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 20)
status.Position = UDim2.new(0, 5, 0, 33)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

local function makeButton(text, yPos, color, parent, height)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, height or 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent or frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    return btn
end

local setBtn = makeButton("Set Point (K)", 56, Color3.fromRGB(60, 120, 200))
local toggleBtn = makeButton("Start Walking (Q)", 92, Color3.fromRGB(60, 160, 80))
local deleteBtn = makeButton("Delete All Points (L)", 128, Color3.fromRGB(190, 60, 60))

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -20, 0, 18)
listLabel.Position = UDim2.new(0, 10, 0, 164)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Saved Points:"
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 12
listLabel.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 0, FULL_HEIGHT - 195)
scroll.Position = UDim2.new(0, 10, 0, 185)
scroll.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scroll

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.PaddingLeft = UDim.new(0, 4)
listPadding.PaddingRight = UDim.new(0, 4)
listPadding.Parent = scroll

local function updateStatus()
    status.Text = "Points: " .. #points .. "  |  Walking: " .. (walking and "ON" or "OFF")
    status.TextColor3 = walking and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200)
end

local refreshList

local function deletePoint(index)
    table.remove(points, index)
    if #points > 0 then
        savePoints()
    elseif isfile and isfile(SAVE_FILE) then
        delfile(SAVE_FILE)
    end
    refreshList()
    updateStatus()
end

refreshList = function()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for i, point in ipairs(points) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, -8, 0, 26)
        entry.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        entry.BorderSizePixel = 0
        entry.LayoutOrder = i
        entry.Parent = scroll

        local entryCorner = Instance.new("UICorner")
        entryCorner.CornerRadius = UDim.new(0, 4)
        entryCorner.Parent = entry

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -30, 1, 0)
        label.Position = UDim2.new(0, 6, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = string.format("#%d  (%.0f, %.0f, %.0f)", i, point.X, point.Y, point.Z)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.Parent = entry

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 22, 0, 22)
        delBtn.Position = UDim2.new(1, -24, 0, 2)
        delBtn.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
        delBtn.BorderSizePixel = 0
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 12
        delBtn.Parent = entry

        local delCorner = Instance.new("UICorner")
        delCorner.CornerRadius = UDim.new(0, 4)
        delCorner.Parent = delBtn

        delBtn.MouseButton1Click:Connect(function()
            deletePoint(i)
        end)
    end
end

-- ========== DRAGGING ==========
local dragging, dragStart, startPos
local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end
title.InputBegan:Connect(startDrag)
titleBg.InputBegan:Connect(startDrag)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ========== ACTIONS ==========
local function setPoint()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        table.insert(points, root.Position)
        savePoints()
        refreshList()
        updateStatus()
    end
end

local function toggleWalk()
    walking = not walking
    toggleBtn.Text = walking and "Stop Walking (Q)" or "Start Walking (Q)"
    toggleBtn.BackgroundColor3 = walking and Color3.fromRGB(200, 140, 40) or Color3.fromRGB(60, 160, 80)
    if not walking then StopMove() end
    updateStatus()
end

local function deleteAllPoints()
    points = {}
    walking = false
    StopMove()
    toggleBtn.Text = "Start Walking (Q)"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
    if isfile and isfile(SAVE_FILE) then
        delfile(SAVE_FILE)
    end
    refreshList()
    updateStatus()
end

setBtn.MouseButton1Click:Connect(setPoint)
toggleBtn.MouseButton1Click:Connect(toggleWalk)
deleteBtn.MouseButton1Click:Connect(deleteAllPoints)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        setPoint()
    elseif input.KeyCode == Enum.KeyCode.Q then
        toggleWalk()
    elseif input.KeyCode == Enum.KeyCode.L then
        deleteAllPoints()
    end
end)

--- ========== PATHFINDING WALK (smooth + corner smoothing) ==========
-- ========== PATHFINDING WALK (smooth + human-like) ==========
local function walkTo(destination)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    -- Add tiny random offset to destination (2-3 stud jitter — humans don't hit exact spots)
    local destJitter = Vector3.new(
        (math.random() - 0.5) * 4,
        0,
        (math.random() - 0.5) * 4
    )
    local jitteredDest = destination + destJitter

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })

    local ok = pcall(function()
        path:ComputeAsync(root.Position, jitteredDest)
    end)

    local waypoints
    if ok and path.Status == Enum.PathStatus.Success then
        waypoints = path:GetWaypoints()
    else
        waypoints = { { Position = jitteredDest, Action = Enum.PathWaypointAction.Walk } }
    end

    humanoid.AutoRotate = true

    -- Smoothing settings
    local SMOOTH_FACTOR = 0.25
    local LOOKAHEAD_DIST = 6
    local ARRIVE_DIST = 4
    local WAYPOINT_TIMEOUT = 8

    local smoothedDir = Vector3.new(0, 0, 0)

    for i, waypoint in ipairs(waypoints) do
        if not walking then break end

        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        local nextWaypoint = waypoints[i + 1]
        local start = tick()

        while walking do
            if not player.Character then break end
            root = player.Character:FindFirstChild("HumanoidRootPart")
            if not root then break end

            local delta = waypoint.Position - root.Position
            local flatDelta = Vector3.new(delta.X, 0, delta.Z)
            local dist = flatDelta.Magnitude

            if dist < ARRIVE_DIST then break end
            if tick() - start > WAYPOINT_TIMEOUT then break end

            local dir = flatDelta.Unit

            if nextWaypoint and dist < LOOKAHEAD_DIST then
                local nextDelta = nextWaypoint.Position - root.Position
                local nextFlat = Vector3.new(nextDelta.X, 0, nextDelta.Z)
                if nextFlat.Magnitude > 0 then
                    local blendAmount = 1 - (dist / LOOKAHEAD_DIST)
                    dir = (dir:Lerp(nextFlat.Unit, blendAmount * 0.7)).Unit
                end
            end

            -- Micro-jitter on direction (tiny hand-shake, like human aim)
            local microJitter = Vector3.new(
                (math.random() - 0.5) * 0.05,
                0,
                (math.random() - 0.5) * 0.05
            )
            dir = (dir + microJitter).Unit

            if smoothedDir.Magnitude > 0 then
                smoothedDir = smoothedDir:Lerp(dir, SMOOTH_FACTOR)
            else
                smoothedDir = dir
            end

            local ac = ControlModule.activeController
            if ac then
                ac.moveVector = smoothedDir
                ac.forwardValue = 0
                ac.backwardValue = 0
                ac.leftValue = 0
                ac.rightValue = 0
                ac.moveVectorIsCameraRelative = false
            end
            ControlModule.inputMoveVector = smoothedDir

            -- Randomized tick rate (45-75ms — humans aren't perfectly consistent)
            task.wait(0.045 + math.random() * 0.03)
        end
    end

    StopMove()
end

-- ========== MAIN LOOP (with human-like idle) ==========
task.spawn(function()
    while true do
        if walking and #points > 0 then
            for i, point in ipairs(points) do
                if not walking then break end
                walkTo(point)
                -- short randomized pause between points
                task.wait(0.35 + math.random() * 0.3)
            end

        else
            task.wait(0.2)
        end
        task.wait()
    end
end)

refreshList()
updateStatus()
print("Waypoint Walker loaded (ControlModule hook — works minimized).")
