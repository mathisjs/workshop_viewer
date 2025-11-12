local WV = {}
WV.FileBuf = {}
WV.PendingPath = nil
WV.CurrentBase = nil
WV.CurrentAddonLabel = nil
WV.CurrentWSID = nil
WV.WebView = nil
WV.WebReady = false
WV.PendingEvents = {}

local WV_HTML = include("autorun/client/wv_html.lua")

local function readCompressedTable()
    local len = net.ReadUInt(32)
    if len == 0 then return nil end
    local comp = net.ReadData(len)
    local json = util.Decompress(comp or "")
    return json and util.JSONToTable(json) or nil
end

local function formatBytes(num)
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

local function formatDate(ts)
    ts = tonumber(ts or 0) or 0
    if ts <= 0 then return "?" end
    return os.date("%d/%m/%Y %H:%M", ts)
end

local function normalizeDir(path)
    path = tostring(path or "")
    path = path:gsub("\\", "/")
    path = path:gsub("/+", "/")
    path = path:gsub("^/", "")
    if path ~= "" and not string.EndsWith(path, "/") then
        path = path .. "/"
    end
    return path
end

local function sanitizeFile(path)
    path = tostring(path or "")
    path = path:gsub("\\", "/")
    path = path:gsub("^/+", "")
    return path
end

local function sendEvent(name, payload)
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

local function flushEvents()
    if not (IsValid(WV.WebView) and WV.WebReady) or not WV.PendingEvents then return end
    for _, packet in ipairs(WV.PendingEvents) do
        local json = util.TableToJSON(packet, false) or "{}"
        WV.WebView:Call("window.WVReceive(" .. json .. ");")
    end
    WV.PendingEvents = {}
end

local function requestAddons()
    net.Start("WV_RequestAddons")
    net.SendToServer()
end

local function requestDirectory(mountId, path)
    if not mountId or mountId == "" then return end
    net.Start("WV_RequestList")
        net.WriteString(mountId)
        net.WriteString(normalizeDir(path))
    net.SendToServer()
end

local function requestFile(mountId, rel)
    rel = sanitizeFile(rel)
    if not mountId or mountId == "" or rel == "" then return end
    WV.CurrentBase = mountId
    WV.PendingPath = rel
    net.Start("WV_RequestFile")
        net.WriteString(mountId)
        net.WriteString(rel)
    net.SendToServer()
end

local function openViewer()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:IsSuperAdmin() then
        chat.AddText(Color(255, 80, 80), "[WorkshopViewer] ", color_white, "Only super admins can use this menu.")
        return
    end
    if IsValid(WV.Frame) then WV.Frame:Remove() end

    local f = vgui.Create("DFrame")
    f:SetTitle(" ")
    f:SetSize(math.min(ScrW()*0.9, 1400), math.min(ScrH()*0.9, 900))
    f:Center()
    f:MakePopup()
    WV.Frame = f
    f.OnRemove = function()
        WV.WebView = nil
        WV.WebReady = false
        WV.PendingEvents = nil
    end
    f.Paint = function(self,w,h)
        surface.SetDrawColor(0,0,0,0)
        surface.DrawRect(0, 0, w, h)
        
    end

    local html = vgui.Create("DHTML", f)
    html:Dock(FILL)
    html:SetHTML(WV_HTML)

    WV.WebView = html
    WV.WebReady = false
    WV.PendingEvents = {}

    local function selectAddon(mountId, label, wsid)
        if not mountId or mountId == "" then return end
        WV.CurrentBase = mountId
        WV.CurrentAddonLabel = label or "Addon"
        WV.CurrentWSID = wsid or ""
        WV.PendingPath = nil
        requestDirectory(mountId, "")
    end

    html:AddFunction("wv", "Ready", function()
        WV.WebReady = true
        flushEvents()
        requestAddons()
    end)

    html:AddFunction("wv", "RefreshAddons", function()
        requestAddons()
    end)

    html:AddFunction("wv", "SelectAddon", function(mountId, label, wsid)
        selectAddon(mountId, label, wsid)
    end)

    html:AddFunction("wv", "RequestDirectory", function(mountId, path)
        if not mountId or mountId == "" then return end
        WV.CurrentBase = mountId
        requestDirectory(mountId, path or "")
    end)

    html:AddFunction("wv", "RequestFile", function(mountId, rel)
        requestFile(mountId, rel or "")
    end)

    html:AddFunction("wv", "OpenWorkshop", function(wsid)
        if wsid and wsid ~= "" then
            steamworks.ViewFile(wsid)
        end
    end)

    html:AddFunction("wv", "CopyText", function(text)
        if not text or text == "" then return end
        SetClipboardText(text)
        surface.PlaySound("garrysmod/ui_click.wav")
    end)
end

concommand.Add("workshop_viewer", openViewer)
hook.Add("PopulateToolMenu", "WV_AddToolMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "Admin", "WorkshopViewer", "Workshop Viewer", "", "", function(panel)
        panel:ClearControls()
        local b = vgui.Create("DButton", panel)
        b:SetText("Open Workshop Viewer")
        b.DoClick = openViewer
        panel:AddItem(b)
    end)
end)

WV.fillAddons = function(list)
    WV.AddonCache = list or {}
    for _, addon in ipairs(WV.AddonCache) do
        if not addon.mount or addon.mount == "" then
            addon.mount = addon.file or addon.title or addon.wsid or ""
        end
        addon.size_human = formatBytes(addon.size)
        addon.updated_human = formatDate(addon.updated)
    end
    sendEvent("addons", WV.AddonCache)
end

WV.mountDir = function(payload)
    if not payload then return end
    if payload.mount and payload.mount ~= "" then
        WV.CurrentBase = payload.mount
    end
    if payload.base and payload.base ~= "" then
        WV.CurrentSearch = payload.base
    end
    payload.addon = WV.CurrentAddonLabel or "Addon"
    payload.wsid = WV.CurrentWSID or ""
    sendEvent("directory", payload)
end

WV.showFile = function(text, rel)
    local pathLabel = rel or WV.PendingPath or "Unknown file"
    WV.PendingPath = nil
    sendEvent("file", {
        addon = WV.CurrentAddonLabel or "Addon",
        text = text or "",
        path = pathLabel
    })
end

local function handleStatus(msg, level)
    sendEvent("status", { text = msg, level = level or "info" })
end

net.Receive("WV_Addons", function()
    local t = readCompressedTable() or {}
    if WV.fillAddons then WV.fillAddons(t) end
end)

net.Receive("WV_List", function()
    local t = readCompressedTable()
    if t and WV.mountDir then WV.mountDir(t) end
end)

net.Receive("WV_FileStart", function()
    local token = net.ReadUInt(32)
    local rel   = net.ReadString()
    local total = net.ReadUInt(32)
    local chunks = net.ReadUInt(16)
    WV.FileBuf[token] = { rel = rel, total = total, chunks = chunks, got = 0, buf = {} }
    WV.PendingPath = rel
end)

net.Receive("WV_FileChunk", function()
    local token = net.ReadUInt(32)
    local idx   = net.ReadUInt(16)
    local len   = net.ReadUInt(16)
    local data  = net.ReadData(len)
    local rec = WV.FileBuf[token]; if not rec then return end
    rec.buf[idx] = data
    local count = 0 for _ in pairs(rec.buf) do count = count + 1 end
    if count >= rec.chunks then
        local concat = {}
        for i = 1, rec.chunks do concat[#concat+1] = rec.buf[i] end
        local text = util.Decompress(table.concat(concat))
        if not text then
            handleStatus("Unable to decompress file.", "error")
            text = ""
        end
        if WV.showFile then WV.showFile(text, rec.rel) end
        WV.FileBuf[token] = nil
    end
end)

net.Receive("WV_Error", function()
    local msg = net.ReadString() or "Error"
    chat.AddText(Color(255,80,80), "[WorkshopViewer] ", Color(255,255,255), msg)
    handleStatus(msg, "error")
end)
