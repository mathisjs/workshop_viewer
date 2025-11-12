-- Workshop Viewer Addon
if SERVER then
    AddCSLuaFile("autorun/client/wv_cl.lua")
    include("autorun/server/wv_sv.lua")
else
    include("autorun/client/wv_cl.lua")
end
