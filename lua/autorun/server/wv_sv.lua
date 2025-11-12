AddCSLuaFile("autorun/client/wv_cl.lua")

util.AddNetworkString("WV_RequestAddons")
util.AddNetworkString("WV_Addons")
util.AddNetworkString("WV_RequestList")
util.AddNetworkString("WV_List")
util.AddNetworkString("WV_RequestFile")
util.AddNetworkString("WV_FileStart")
util.AddNetworkString("WV_FileChunk")
util.AddNetworkString("WV_Error")

local function allowed(ply)
    return IsValid(ply) and ply:IsSuperAdmin()
end

local function sanitize(rel)
    rel = tostring(rel or "")
    rel = string.Replace(rel, "\\", "/")
    rel = rel:gsub("%.%.", "")
    rel = rel:gsub("^/+", "")
    return rel
end

local MAX_CHUNK = 60000
local ALLOWED_EXT = {
    lua = true,
    txt = true,
    json = true,
    md = true,
    cfg = true,
    ini = true,
    vmt = true,
    vmf = true,
    vdf = true,
    log = true,
}

local WV_AddonLookup = {}

local function makeMountId(info)
    if info.file and info.file ~= "" then
        return "FILE@" .. string.lower(info.file)
    end
    if info.wsid and info.wsid ~= "" then
        return "WSID@" .. tostring(info.wsid)
    end
    if info.title and info.title ~= "" then
        return "TITLE@" .. info.title
    end
    return "ADDON@" .. tostring(util.CRC(tostring(info)))
end

local function getSearchBase(addon)
    if not addon then return "GAME" end
    local search = addon.search
    if search and search ~= "" then return search end
    if addon.path and addon.path ~= "" then return addon.path end
    return "GAME"
end

local function buildAddonList()
    WV_AddonLookup = {}
    local out = {}
    for _, a in ipairs(engine.GetAddons()) do
        if a.mounted then
            local mountId = makeMountId(a)
            WV_AddonLookup[mountId] = {
                search = (a.title and a.title ~= "" and a.title) or (a.file or ""),
                path   = a.file or "",
                title  = a.title or (a.file or "unknown"),
                wsid   = tostring(a.wsid or ""),
            }
            out[#out+1] = {
                title   = a.title or (a.file or "unknown"),
                wsid    = tostring(a.wsid or ""),
                file    = a.file or "",
                mount   = mountId,
                size    = tonumber(a.size or 0) or 0,
                updated = tonumber(a.updated or 0) or 0,
            }
        end
    end
    return out
end

net.Receive("WV_RequestAddons", function(_, ply)
    if not allowed(ply) then return end
    local addons = buildAddonList()
    local json = util.TableToJSON(addons, false) or "[]"
    local comp = util.Compress(json) or ""
    net.Start("WV_Addons")
        net.WriteUInt(#comp, 32)
        if #comp > 0 then net.WriteData(comp, #comp) end
    net.Send(ply)
end)

net.Receive("WV_RequestList", function(_, ply)
    if not allowed(ply) then return end
    local mountId = net.ReadString()
    local dir  = sanitize(net.ReadString())
    if mountId == "" then return end
    local addon = WV_AddonLookup[mountId]
    if not addon then
        return sendError(ply, "Unknown or unmounted addon.")
    end
    if dir ~= "" and not string.EndsWith(dir, "/") then dir = dir .. "/" end

    local base = getSearchBase(addon)
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
        if ALLOWED_EXT[ext] then
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

local function sendError(ply, msg)
    net.Start("WV_Error")
        net.WriteString(msg or "error")
    net.Send(ply)
end

net.Receive("WV_RequestFile", function(_, ply)
    if not allowed(ply) then return end
    local mountId = net.ReadString()
    local rel  = sanitize(net.ReadString())

    local addon = WV_AddonLookup[mountId]
    if not addon then
        return sendError(ply, "Unknown or unmounted addon.")
    end

    local ext = string.lower(string.GetExtensionFromFilename(rel or "") or "")
    if not ALLOWED_EXT[ext] then
        return sendError(ply, "Extension not allowed: " .. (ext or "?"))
    end

    local base = getSearchBase(addon)
    local data = file.Read(rel, base)
    if not data and base ~= "GAME" and file.Exists(rel, "GAME") then
        data = file.Read(rel, "GAME")
    end
    if not data then
        return sendError(ply, "File not found: " .. base .. ":" .. rel)
    end

    local compressed = util.Compress(data) or ""
    local total = #compressed
    local chunks = math.ceil(total / MAX_CHUNK)
    local token = math.random(1, 2^31 - 1)

    net.Start("WV_FileStart")
        net.WriteUInt(token, 32)
        net.WriteString(rel)
        net.WriteUInt(total, 32)
        net.WriteUInt(chunks, 16)
    net.Send(ply)

    for i = 1, chunks do
        local s = (i-1)*MAX_CHUNK + 1
        local e = math.min(i*MAX_CHUNK, total)
        local piece = compressed:sub(s, e)
        net.Start("WV_FileChunk", true)
            net.WriteUInt(token, 32)
            net.WriteUInt(i, 16)
            net.WriteUInt(#piece, 16)
            net.WriteData(piece, #piece)
        net.Send(ply)
    end
end)
