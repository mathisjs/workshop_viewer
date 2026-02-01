if SERVER then
    AddCSLuaFile("autorun/client/cl_wv_main.lua")
    AddCSLuaFile("autorun/client/cl_wv_utils.lua")
    AddCSLuaFile("autorun/client/cl_wv_html.lua")
    AddCSLuaFile("autorun/client/cl_wv_network.lua")
    AddCSLuaFile("autorun/client/cl_wv_ui.lua")

    include("autorun/server/sv_wv_utils.lua")
    include("autorun/server/sv_wv_filesystem.lua")
    include("autorun/server/sv_wv_main.lua")
    include("autorun/server/sv_wv_network.lua")
else
    include("autorun/client/cl_wv_main.lua")
    include("autorun/client/cl_wv_utils.lua")
    include("autorun/client/cl_wv_html.lua")
    include("autorun/client/cl_wv_network.lua")
    include("autorun/client/cl_wv_ui.lua")
end
