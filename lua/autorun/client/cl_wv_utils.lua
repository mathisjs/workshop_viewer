WV = WV or {}

function WV.ReadCompressedTable()
    local len = net.ReadUInt(32)
    if len == 0 then return nil end
    local comp = net.ReadData(len)
    local json = util.Decompress(comp or "")
    return json and util.JSONToTable(json) or nil
end

function WV.FormatBytes(num)
    num = tonumber(num or 0) or 0
    if num <= 0 then return "0 B" end
    local units = { "B", "KB", "MB", "GB" }
    local i = 1
    while num >= 1024 and i < #units do
        num = num / 1024
        i = i + 1
    end
    return string.format("%.1f %s", num, units[i])
end

function WV.FormatDate(ts)
    ts = tonumber(ts or 0) or 0
    if ts <= 0 then return "?" end
    return os.date("%d/%m/%Y %H:%M", ts)
end

function WV.NormalizeDir(path)
    path = tostring(path or "")
    path = path:gsub("\\", "/")
    path = path:gsub("/+", "/")
    path = path:gsub("^/", "")
    if path ~= "" and not string.EndsWith(path, "/") then
        path = path .. "/"
    end
    return path
end

function WV.SanitizeFile(path)
    path = tostring(path or "")
    path = path:gsub("\\", "/")
    path = path:gsub("^/+", "")
    return path
end

function WV.SendEvent(name, payload)
    if not IsValid(WV.WebView) then return end
    payload = payload or {}
    local packet = { event = name, payload = payload }

    if not WV.WebReady then
        WV.PendingEvents = WV.PendingEvents or {}
        table.insert(WV.PendingEvents, packet)
        return
    end

    local json = util.TableToJSON(packet, false) or "{}"
    WV.WebView:Call("window.WVReceive(" .. json .. ");")
end

function WV.FlushEvents()
    if not (IsValid(WV.WebView) and WV.WebReady) or not WV.PendingEvents then return end

    for _, packet in ipairs(WV.PendingEvents) do
        local json = util.TableToJSON(packet, false) or "{}"
        WV.WebView:Call("window.WVReceive(" .. json .. ");")
    end

    WV.PendingEvents = {}
end
