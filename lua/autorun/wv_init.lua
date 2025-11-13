local Welcome = [[
  _       _               _            _                   
 ( )  _  ( )             ( )          ( )                  
 | | ( ) | |   _    _ __ | |/')   ___ | |__     _    _ _   
 | | | | | | /'_`\ ( '__)| , <  /',__)|  _ `\ /'_`\ ( '_`\ 
 | (_/ \_) |( (_) )| |   | |\`\ \__, \| | | |( (_) )| (_) )
 `\___x___/'`\___/'(_)   (_) (_)(____/(_) (_)`\___/'| ,__/'
                                                   | |    
                                                   (_)    
         _   _                                   
        ( ) ( ) _                                
        | | | |(_)   __   _   _   _    __   _ __ 
        | | | || | /'__`\( ) ( ) ( ) /'__`\( '__)
        | \_/ || |(  ___/| \_/ \_/ |(  ___/| |   
        `\___/'(_)`\____)`\___x___/'`\____)(_)   
                                                 loaded
]]



if SERVER then
    print(Welcome)
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
