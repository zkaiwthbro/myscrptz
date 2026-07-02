-- ================ Loader ================
-- Loads: Starflower ESP, Waypoint Walker, Script3

local scripts = {
    "https://raw.githubusercontent.com/YourUsername/roblox-scripts/main/starflower.lua",
    "https://raw.githubusercontent.com/YourUsername/roblox-scripts/main/walker.lua",
    "https://raw.githubusercontent.com/YourUsername/roblox-scripts/main/script3.lua",
}

for i, url in ipairs(scripts) do
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if ok then
            print("[Loader] Loaded #" .. i .. " ✓")
        else
            warn("[Loader] Failed #" .. i .. ": " .. tostring(err))
        end
    end)
end

print("[Loader] All scripts starting...")
