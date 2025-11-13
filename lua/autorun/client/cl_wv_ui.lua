WV = WV or {}

WV.FillAddons = function(list)
    WV.AddonCache = list or {}
    for _, addon in ipairs(WV.AddonCache) do
        if not addon.mount or addon.mount == "" then
            addon.mount = addon.file or addon.title or addon.wsid or ""
        end
        addon.size_human = WV.FormatBytes(addon.size)
        addon.updated_human = WV.FormatDate(addon.updated)
    end
    WV.SendEvent("addons", WV.AddonCache)
end

WV.MountDir = function(payload)
    if not payload then return end
    if payload.mount and payload.mount ~= "" then
        WV.CurrentBase = payload.mount
    end
    if payload.base and payload.base ~= "" then
        WV.CurrentSearch = payload.base
    end
    payload.addon = WV.CurrentAddonLabel or "Addon"
    payload.wsid = WV.CurrentWSID or ""
    WV.SendEvent("directory", payload)
end

WV.ShowFile = function(text, rel)
    local pathLabel = rel or WV.PendingPath or "Unknown file"
    WV.PendingPath = nil
    WV.SendEvent("file", {
        addon = WV.CurrentAddonLabel or "Addon",
        text = text or "",
        path = pathLabel
    })
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
    html:SetHTML(WV.GetHTML())

    WV.WebView = html
    WV.WebReady = false
    WV.PendingEvents = {}

    local function selectAddon(mountId, label, wsid)
        if not mountId or mountId == "" then return end
        WV.CurrentBase = mountId
        WV.CurrentAddonLabel = label or "Addon"
        WV.CurrentWSID = wsid or ""
        WV.PendingPath = nil
        WV.RequestDirectory(mountId, "")
    end

    html:AddFunction("wv", "Ready", function()
        WV.WebReady = true
        WV.FlushEvents()
        WV.RequestAddons()
    end)

    html:AddFunction("wv", "RefreshAddons", function()
        WV.RequestAddons()
    end)

    html:AddFunction("wv", "SelectAddon", function(mountId, label, wsid)
        selectAddon(mountId, label, wsid)
    end)

    html:AddFunction("wv", "RequestDirectory", function(mountId, path)
        if not mountId or mountId == "" then return end
        WV.CurrentBase = mountId
        WV.RequestDirectory(mountId, path or "")
    end)

    html:AddFunction("wv", "RequestFile", function(mountId, rel)
        WV.RequestFile(mountId, rel or "")
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
