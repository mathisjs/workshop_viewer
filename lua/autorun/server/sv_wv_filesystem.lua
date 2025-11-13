WV = WV or {}
WV.AddonLookup = WV.AddonLookup or {}

function WV.MakeMountId(info)
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

function WV.GetSearchBase(addon)
    if not addon then return "GAME" end
    local search = addon.search
    if search and search ~= "" then return search end
    if addon.path and addon.path ~= "" then return addon.path end
    return "GAME"
end

function WV.BuildAddonList()
    WV.AddonLookup = {}
    local out = {}
    for _, a in ipairs(engine.GetAddons()) do
        if a.mounted then
            local mountId = WV.MakeMountId(a)
            WV.AddonLookup[mountId] = {
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
