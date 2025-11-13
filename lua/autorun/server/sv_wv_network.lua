WV = WV or {}

net.Receive("WV_RequestAddons", function(_, ply)
    if not WV.Allowed(ply) then return end
    local addons = WV.BuildAddonList()
    local json = util.TableToJSON(addons, false) or "[]"
    local comp = util.Compress(json) or ""
    net.Start("WV_Addons")
        net.WriteUInt(#comp, 32)
        if #comp > 0 then net.WriteData(comp, #comp) end
    net.Send(ply)
end)

net.Receive("WV_RequestList", function(_, ply)
    if not WV.Allowed(ply) then return end
    local mountId = net.ReadString()
    local dir  = WV.Sanitize(net.ReadString())
    if mountId == "" then return end
    local addon = WV.AddonLookup[mountId]
    if not addon then
        return WV.SendError(ply, "Unknown or unmounted addon.")
    end
    if dir ~= "" and not string.EndsWith(dir, "/") then dir = dir .. "/" end

    local base = WV.GetSearchBase(addon)
    local files, dirs = file.Find(dir .. "*", base, "nameasc")
    if (not files or not dirs) and base ~= "GAME" then
        files, dirs = file.Find(dir .. "*", "GAME", "nameasc")
        if files and dirs then base = "GAME" end
    end
    local payload = { base = base, mount = mountId, dir = dir, dirs = {}, files = {} }

    for _, d in ipairs(dirs or {}) do
        payload.dirs[#payload.dirs+1] = d
    end
    for _, f in ipairs(files or {}) do
        local ext = string.lower(string.GetExtensionFromFilename(f) or "")
        if WV.ALLOWED_EXT[ext] then
            payload.files[#payload.files+1] = { name = f, path = dir .. f, ext = ext }
        end
    end

    local json = util.TableToJSON(payload, false) or "{}"
    local comp = util.Compress(json) or ""
    net.Start("WV_List")
        net.WriteUInt(#comp, 32)
        if #comp > 0 then net.WriteData(comp, #comp) end
    net.Send(ply)
end)

net.Receive("WV_RequestFile", function(_, ply)
    if not WV.Allowed(ply) then return end
    local mountId = net.ReadString()
    local rel  = WV.Sanitize(net.ReadString())

    local addon = WV.AddonLookup[mountId]
    if not addon then
        return WV.SendError(ply, "Unknown or unmounted addon.")
    end

    local ext = string.lower(string.GetExtensionFromFilename(rel or "") or "")
    if not WV.ALLOWED_EXT[ext] then
        return WV.SendError(ply, "Extension not allowed: " .. (ext or "?"))
    end

    local base = WV.GetSearchBase(addon)
    local data = file.Read(rel, base)
    if not data and base ~= "GAME" and file.Exists(rel, "GAME") then
        data = file.Read(rel, "GAME")
    end
    if not data then
        return WV.SendError(ply, "File not found: " .. base .. ":" .. rel)
    end

    local compressed = util.Compress(data) or ""
    local total = #compressed
    local chunks = math.ceil(total / WV.MAX_CHUNK)
    local token = math.random(1, 2^31 - 1)

    net.Start("WV_FileStart")
        net.WriteUInt(token, 32)
        net.WriteString(rel)
        net.WriteUInt(total, 32)
        net.WriteUInt(chunks, 16)
    net.Send(ply)

    for i = 1, chunks do
        local s = (i-1)*WV.MAX_CHUNK + 1
        local e = math.min(i*WV.MAX_CHUNK, total)
        local piece = compressed:sub(s, e)
        net.Start("WV_FileChunk", true)
            net.WriteUInt(token, 32)
            net.WriteUInt(i, 16)
            net.WriteUInt(#piece, 16)
            net.WriteData(piece, #piece)
        net.Send(ply)
    end
end)
