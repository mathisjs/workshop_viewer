if SERVER then
    AddCSLuaFile("autorun/client/ui/cl_wv_main.lua")
    AddCSLuaFile("autorun/client/cl_wv_utils.lua")
    AddCSLuaFile("autorun/client/ui/cl_vw_css.lua")
    AddCSLuaFile("autorun/client/ui/cl_vw_javascript.lua")
    AddCSLuaFile("autorun/client/ui/cl_vw_html.lua")
    AddCSLuaFile("autorun/client/cl_wv_network.lua")
    AddCSLuaFile("autorun/client/ui/cl_wv_ui.lua")
    AddCSLuaFile("autorun/client/cl_wv_vtf.lua")

    include("autorun/server/sv_wv_utils.lua")
    include("autorun/server/sv_wv_filesystem.lua")
    include("autorun/server/sv_wv_main.lua")
    include("autorun/server/sv_wv_network.lua")
else
    include("autorun/client/ui/cl_wv_main.lua")
    include("autorun/client/cl_wv_utils.lua")
    include("autorun/client/ui/cl_vw_css.lua")
    include("autorun/client/ui/cl_vw_javascript.lua")
    include("autorun/client/ui/cl_vw_html.lua")
    include("autorun/client/cl_wv_network.lua")
    include("autorun/client/ui/cl_wv_ui.lua")
    include("autorun/client/cl_wv_vtf.lua")
end
