-- ================ Loader ================
-- Loads: Starflower ESP, Waypoint Walker, Gather , Reset

local scripts = {
    "https://github.com/zkaiwthbro/myscrptz/blob/main/hold%20left",
    "https://github.com/zkaiwthbro/myscrptz/blob/main/movement",
    "https://github.com/zkaiwthbro/myscrptz/blob/main/reset",
    "https://github.com/zkaiwthbro/myscrptz/blob/main/sfesp",
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
