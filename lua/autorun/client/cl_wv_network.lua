WV = WV or {}

local function handleStatus(msg, level)
    WV.SendEvent("status", { text = msg, level = level or "info" })
end

function WV.RequestAddons()
    net.Start("WV_RequestAddons")
    net.SendToServer()
end

function WV.RequestDirectory(mountId, path)
    if not mountId or mountId == "" then return end
    net.Start("WV_RequestList")
        net.WriteString(mountId)
        net.WriteString(WV.NormalizeDir(path))
    net.SendToServer()
end

function WV.RequestFile(mountId, rel)
    rel = WV.SanitizeFile(rel)
    if not mountId or mountId == "" or rel == "" then return end

    WV.CurrentBase = mountId
    WV.PendingPath = rel

    net.Start("WV_RequestFile")
        net.WriteString(mountId)
        net.WriteString(rel)
    net.SendToServer()
end

function WV.RequestAllImages()
    net.Start("WV_RequestAllImages")
    net.SendToServer()
end

net.Receive("WV_Addons", function()
    local t = WV.ReadCompressedTable() or {}
    if WV.FillAddons then
        WV.FillAddons(t)
        WV.RequestAllImages()
    end
end)

net.Receive("WV_List", function()
    local t = WV.ReadCompressedTable()
    if t and WV.MountDir then
        WV.MountDir(t)
    end
end)

net.Receive("WV_FileStart", function()
    local token = net.ReadUInt(32)
    local rel   = net.ReadString()
    local total = net.ReadUInt(32)
    local chunks = net.ReadUInt(16)

    WV.FileBuf[token] = {
        rel = rel,
        total = total,
        chunks = chunks,
        buf = {}
    }
    WV.PendingPath = rel
end)

net.Receive("WV_FileChunk", function()
    local token = net.ReadUInt(32)
    local idx   = net.ReadUInt(16)
    local len   = net.ReadUInt(16)
    local data  = net.ReadData(len)

    local rec = WV.FileBuf[token]
    if not rec then return end

    rec.buf[idx] = data

    local count = 0
    for _ in pairs(rec.buf) do
        count = count + 1
    end

    if count >= rec.chunks then
        local concat = {}
        for i = 1, rec.chunks do
            concat[#concat + 1] = rec.buf[i]
        end

        local text = util.Decompress(table.concat(concat))
        if not text then
            handleStatus("Unable to decompress file.", "error")
            text = ""
        end

        if WV.ShowFile then
            WV.ShowFile(text, rec.rel)
        end

        WV.FileBuf[token] = nil
    end
end)

net.Receive("WV_Image", function()
    local wsid = net.ReadString()
    local url = net.ReadString()
    WV.SendEvent("addon_image", { wsid = wsid, url = url })
end)

net.Receive("WV_Error", function()
    local msg = net.ReadString() or "Error"
    chat.AddText(Color(255, 80, 80), "[WorkshopViewer] ", Color(255, 255, 255), msg)
    handleStatus(msg, "error")
end)
