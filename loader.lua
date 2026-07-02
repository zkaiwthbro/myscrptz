-- ================ Loader ================
-- Loads: Starflower ESP, Waypoint Walker, Gather , Reset

local scripts = {
    "https://raw.githubusercontent.com/zkaiwthbro/myscrptz/main/holdleft.lua",
    "https://raw.githubusercontent.com/zkaiwthbro/myscrptz/main/movement.lua",
    "https://raw.githubusercontent.com/zkaiwthbro/myscrptz/main/reset.lua",
    "https://raw.githubusercontent.com/zkaiwthbro/myscrptz/main/sfesp.lua",
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
