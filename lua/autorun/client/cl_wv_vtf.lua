WV = WV or {}

local vtfViewerFrame = nil

function WV.GetVTFHTML()
    return [[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<style>
*{box-sizing:border-box;user-select:none;scrollbar-width:thin;scrollbar-color:rgba(255,209,217,0.15) transparent}
html,body{margin:0;padding:0;height:100%;font-family:'Segoe UI',system-ui,sans-serif;background:#0f0d0e;color:#FFD1D9;overflow:hidden;font-size:12px}
::-webkit-scrollbar{width:5px;height:5px}
::-webkit-scrollbar-thumb{background:rgba(255,209,217,0.2);border-radius:3px}
::-webkit-scrollbar-track{background:transparent}

.app{display:flex;height:100%;background:#0f0d0e;border:2px solid white}
.main{flex:1;display:flex;flex-direction:column;min-width:0;background:#0f0d0e}

.explorer-bar{padding:6px 10px;border-bottom:1px solid rgba(255,209,217,0.08);display:flex;align-items:center;gap:8px;background:#1a1416;height:36px;gap:8px}
.btn{background:#1f1619;border:1px solid rgba(255,209,217,0.15);color:#FFD1D9;border-radius:3px;padding:4px 8px;cursor:pointer;font-size:11px;transition:all .1s;white-space:nowrap}
.btn:hover:not(:disabled){background:#2a1b1f;border-color:#ff7aaa}
.btn:disabled{opacity:0.3;cursor:not-allowed}
.btn:active:not(:disabled){transform:translateY(1px)}
.btn-close{background:#3d1f1f;border-color:rgba(255,100,100,0.3);color:#ff7a7a;padding:4px 8px;font-size:14px;font-weight:bold}
.btn-close:hover{background:#5a2a2a;border-color:#ff7a7a;color:#fff}

.material-view{flex:1;display:flex;align-items:center;justify-content:center;position:relative;overflow:hidden;background:#141113}
.info-bar{padding:8px 10px;border-top:1px solid rgba(255,209,217,0.08);background:#1a1416;height:80px;display:flex;flex-direction:column;gap:3px}
.info-text{font-size:10px;color:#9a7a85}
.info-label{color:#FFD1D9;font-weight:600}
</style>
</head>
<body>
<div class="app">
    <div class="main">
        <div class="explorer-bar" style="justify-content:flex-end">
            <button class="btn btn-close" id="close-btn" title="Close" onclick="gmod.close()">×</button>
        </div>
        <div class="material-view" id="material-view"></div>
        <div class="info-bar">
            <div class="info-text"><span class="info-label">Material:</span> <span id="material-path"></span></div>
            <div class="info-text"><span class="info-label">Shader:</span> <span id="shader-info"></span></div>
        </div>
    </div>
</div>
</body>
</html>
]]
end


local function normalizeMaterialPath(path)
    path = tostring(path or "")
    path = path:gsub("\\", "/")
    path = path:gsub("^/+", "")

    local gmaPos = path:find("%.gma/")
    if gmaPos then
        path = path:sub(gmaPos + 5)
    end

    if path:lower():StartWith("materials/") then
        path = path:sub(11)
    end

    path = path:gsub("%.vtf$", "")
    path = path:gsub("%.vmt$", "")
    path = path:gsub("%.png$", "")
    path = path:gsub("%.jpg$", "")
    path = path:gsub("%.jpeg$", "")
    path = path:gsub("%.tga$", "")

    return path
end

local function loadMaterial(matPath)
    local mat = Material(matPath, "smooth")
    if not mat or mat:IsError() then
        return nil
    end
    return mat
end

local function openMaterialViewer(inputPath)
    if not IsValid(LocalPlayer()) then return end

    if IsValid(vtfViewerFrame) then
        vtfViewerFrame:Remove()
    end

    local normalizedPath = normalizeMaterialPath(inputPath)
    local mat = loadMaterial(normalizedPath)

    local texW, texH = 512, 512
    local tex = nil

    if mat then
        tex = mat:GetTexture("$basetexture")
        if tex then
            texW = tex:GetMappingWidth() or texW
            texH = tex:GetMappingHeight() or texH
        end
    end


    local f = vgui.Create("DFrame")
    f:SetTitle("")
    f:SetSize(900, 700)
    f:Center()
    f:MakePopup()
    f:SetDeleteOnClose(true)
    f:SetDraggable(false)
    f:ShowCloseButton(false)
    f.Paint = function() end

    vtfViewerFrame = f

    local container = vgui.Create("DPanel", f)
    container:Dock(FILL)
    container.Paint = function() end

    local dhtmlPanel = vgui.Create("DHTML", container)
    dhtmlPanel:Dock(FILL)
    dhtmlPanel:SetMouseInputEnabled(true)
    dhtmlPanel:SetHTML(WV.GetVTFHTML())

    dhtmlPanel:AddFunction("gmod", "close", function()
        f:Close()
    end)

    local imagePanel = vgui.Create("DPanel", container)
    imagePanel:Dock(FILL)
    imagePanel:SetMouseInputEnabled(false)
    imagePanel:SetZPos(1)

    timer.Simple(0.1, function()
        if not IsValid(dhtmlPanel) then return end
        dhtmlPanel:RunJavascript([[
            document.getElementById('material-path').textContent = ']] .. normalizedPath .. [[';
            document.getElementById('shader-info').textContent = ']] .. (mat and mat:GetShader() or "N/A") .. [[';
        ]])
    end)

    imagePanel.Paint = function(self, w, h)
        if not mat then
            draw.SimpleText(
                "Material not found",
                "DermaDefaultBold",
                w / 2,
                h / 2 - 10,
                Color(255, 80, 80),
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                normalizedPath,
                "DermaDefault",
                w / 2,
                h / 2 + 10,
                Color(150, 150, 150),
                TEXT_ALIGN_CENTER
            )
            return
        end

        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 255)

        local ratio = math.min(w / texW, (h - 90) / texH, 1) * 0.85
        local drawW = texW * ratio
        local drawH = texH * ratio

        surface.DrawTexturedRect(
            (w - drawW) / 2,
            (h - drawH) / 2 - 40,
            drawW,
            drawH
        )
    end
end

concommand.Add("workshop_viewer_vtf", function(_, _, _, argStr)
    if not argStr or argStr == "" then
        chat.AddText(
            Color(255, 80, 80), "[Material Viewer] ",
            Color(255, 255, 255),
            "Usage: workshop_viewer_vtf \"path/to/material.vmt | .vtf | .png | .jpg | .jpeg | .tga | material/path\""
        )
        return
    end

    openMaterialViewer(argStr)
end)
