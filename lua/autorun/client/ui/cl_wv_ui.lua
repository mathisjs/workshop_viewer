WV = WV or {}

WV.FillAddons = function(list)
    list = list or {}
    for _, addon in ipairs(list) do
        if not addon.mount or addon.mount == "" then
            addon.mount = addon.file or addon.title or addon.wsid or ""
        end
    end
    WV.SendEvent("addons", list)
end

WV.MountDir = function(payload)
    if not payload then return end
    if payload.mount and payload.mount ~= "" then
        WV.CurrentBase = payload.mount
    end
    WV.SendEvent("directory", payload)
end

WV.ShowFile = function(text, rel)
    local pathLabel = rel or WV.PendingPath or "Unknown file"
    WV.PendingPath = nil
    WV.SendEvent("file", {
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
    f:SetSize(math.min(ScrW()*0.9, 1600), math.min(ScrH()*0.9, 900))
    f:Center()
    f:ShowCloseButton(false)
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

    local loader = vgui.Create("DPanel", f)
    loader:SetSize(f:GetWide(), f:GetTall())
    loader:SetPos(0, 0)
    loader:SetZPos(100)
    loader.Paint = function(self, w, h)
        surface.SetDrawColor(30, 30, 30, 255)
        surface.DrawRect(0, 0, w, h)
        local time = CurTime() * 3
        local centerX, centerY = w/2, h/2
        local radius = 40
        for i = 0, 7 do
            local angle = math.rad(i * 45 + time * 50)
            local alpha = math.max(50, 255 - (i * 25))
            local x = centerX + math.cos(angle) * radius
            local y = centerY + math.sin(angle) * radius
            surface.SetDrawColor(100, 150, 255, alpha)
            surface.DrawRect(x - 4, y - 4, 8, 8)
        end
        draw.SimpleText("Loading...", "DermaDefaultBold", centerX, centerY + 60, Color(200, 200, 200), TEXT_ALIGN_CENTER)
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
        WV.PendingPath = nil
        WV.RequestDirectory(mountId, "")
    end

    html:AddFunction("wv", "Ready", function()
        WV.WebReady = true
        WV.FlushEvents()
        WV.RequestAddons()
        if IsValid(loader) then
            loader:AlphaTo(0, 0.3, 0, function()
                loader:Remove()
            end)
        end
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

    html:AddFunction("wv", "LoadBookmarks", function()
        WV.SendBookmarks()
    end)

    html:AddFunction("wv", "SaveBookmarks", function(bookmarksTable)
        WV.SaveBookmarks(bookmarksTable)
    end)

    html:AddFunction("wv", "Close", function()
        if IsValid(WV.Frame) then
            WV.Frame:Remove()
        end
    end)

    html:AddFunction("wv", "OpenVTF", function(vtfPath)
        if vtfPath and vtfPath ~= "" then
            local fullPath = vtfPath
            if WV.CurrentBase and WV.CurrentBase ~= "" then
                fullPath = WV.CurrentBase .. "/" .. vtfPath
            end
            RunConsoleCommand("workshop_viewer_vtf", fullPath)
        end
    end)

    timer.Simple(5, function()
        if IsValid(loader) and IsValid(html) then
            loader:AlphaTo(0, 0.3, 0, function()
                loader:Remove()
            end)
        end
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
