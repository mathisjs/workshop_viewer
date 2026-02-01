WV = WV or {}

function WV.Allowed(ply)
    return IsValid(ply) and ply:IsSuperAdmin()
end

function WV.Sanitize(rel)
    rel = tostring(rel or "")
    rel = string.Replace(rel, "\\", "/")
    rel = rel:gsub("%.%.", "")
    rel = rel:gsub("^/+", "")
    return rel
end

WV.MAX_CHUNK = 60000

WV.ALLOWED_EXT = {
    lua = true,
    txt = true,
    json = true,
    md = true,
    cfg = true,
    ini = true,
    vmt = true,
    vtf = true,
    vmf = true,
    vdf = true,
    log = true,
    mp3 = true,
    wav = true,
    ogg = true,
    bsp = true,
    vpk = true,
    mdl = true,
    phy = true,
    vvd = true,
    vtx = true,
    ani = true,
    qc = true,
    smd = true,
    png = true,
    jpg = true,
    jpeg = true,
    tga = true,
    gma = true,
}

function WV.SendError(ply, msg)
    net.Start("WV_Error")
        net.WriteString(msg or "error")
    net.Send(ply)
end
