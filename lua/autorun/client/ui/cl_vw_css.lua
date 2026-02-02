WV = WV or {}

function WV.GetCSS()
    return [[
*{box-sizing:border-box;user-select:none;scrollbar-width:thin;scrollbar-color:rgba(255,209,217,0.15) transparent}
html,body{margin:0;padding:0;height:100%;font-family:'Segoe UI',system-ui,sans-serif;background:#0f0d0e;color:#FFD1D9;overflow:hidden;font-size:12px}
::-webkit-scrollbar{width:5px;height:5px}
::-webkit-scrollbar-thumb{background:rgba(255,209,217,0.2);border-radius:3px}
::-webkit-scrollbar-track{background:transparent}

.app{display:flex;height:100%;background:#0f0d0e}
.sidebar{width:260px;display:flex;flex-direction:column;border-right:1px solid rgba(255,209,217,0.08);background:#141113;flex-shrink:0}
.main{flex:1;display:flex;flex-direction:column;min-width:0;background:#0f0d0e}

.toolbar{padding:8px 10px;display:flex;gap:6px;border-bottom:1px solid rgba(255,209,217,0.08);background:#1a1416;align-items:center}
.search-box{flex:1;position:relative}
.search-box input{width:100%;background:#0f0d0e;border:1px solid rgba(255,209,217,0.15);border-radius:4px;padding:5px 10px;color:#FFD1D9;font-family:inherit;font-size:11px;outline:none;transition:all .15s}
.search-box input:focus{border-color:#ff7aaa;background:#141113}
.btn{background:#1f1619;border:1px solid rgba(255,209,217,0.15);color:#FFD1D9;border-radius:3px;padding:4px 8px;cursor:pointer;font-size:11px;transition:all .1s;white-space:nowrap}
.btn:hover:not(:disabled){background:#2a1b1f;border-color:#ff7aaa}
.btn:disabled{opacity:0.3;cursor:not-allowed}
.btn:active:not(:disabled){transform:translateY(1px)}
.btn-icon{padding:4px 6px;font-size:13px}
.btn-close{background:#3d1f1f;border-color:rgba(255,100,100,0.3);color:#ff7a7a;padding:4px 8px;font-size:14px;font-weight:bold}
.btn-close:hover{background:#5a2a2a;border-color:#ff7a7a;color:#fff}

.addon-list{flex:1;overflow-y:auto;padding:6px}
.addon-item{display:flex;align-items:center;gap:8px;padding:6px 8px;border-radius:5px;cursor:pointer;transition:all .1s;margin-bottom:2px}
.addon-item:hover{background:#1f1619}
.addon-item.active{background:#2d1a23;border:1px solid rgba(255,122,170,0.3)}
.addon-thumb{width:32px;height:32px;border-radius:4px;background:#1a1416;flex-shrink:0;overflow:hidden;position:relative;display:flex;align-items:center;justify-content:center}
.addon-thumb img{width:100%;height:100%;object-fit:cover;opacity:0;transition:opacity .2s}
.addon-thumb img.loaded{opacity:1}
.addon-thumb .icon{font-size:14px;opacity:0.3}
.addon-thumb .initials{font-size:11px;font-weight:700;color:#ff7aaa;letter-spacing:0.5px;text-transform:uppercase}
.addon-info{flex:1;min-width:0;display:flex;flex-direction:column;gap:1px}
.addon-name{font-weight:600;font-size:11px;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.addon-meta{font-size:10px;color:#7a5f66;display:flex;gap:6px}
.addon-size{color:#9a7a85}
.ws-badge{background:rgba(255,122,170,0.15);color:#ff7aaa;padding:1px 4px;border-radius:2px;font-size:9px;font-weight:600;opacity:0.7}
.bookmark-btn{width:20px;height:20px;display:flex;align-items:center;justify-content:center;cursor:pointer;opacity:0.3;transition:all .15s;flex-shrink:0;border-radius:3px;font-size:13px;color:#7a5f66}
.bookmark-btn:hover{opacity:0.6;background:#2a1b1f}
.bookmark-btn.bookmarked{opacity:1;color:#ffd700}
.bookmark-section{padding:6px 8px;font-size:10px;font-weight:600;color:#5a444a;text-transform:uppercase;letter-spacing:0.5px}

.explorer-bar{padding:6px 10px;border-bottom:1px solid rgba(255,209,217,0.08);display:flex;align-items:center;gap:8px;background:#1a1416;height:32px;gap:8px}
.crumbs{flex:1;display:flex;gap:3px;overflow-x:auto;white-space:nowrap;align-items:center}
.crumb{padding:2px 6px;border-radius:3px;font-size:10px;color:#9a7a85;cursor:pointer;transition:all .1s}
.crumb:hover{background:#2a1b1f;color:#fff}
.crumb.active{background:#2d1a23;color:#ff7aaa}
.crumb-sep{color:#5a444a;font-size:9px}

.file-view{flex:1;display:flex;overflow:hidden}
.file-list{width:180px;border-right:1px solid rgba(255,209,217,0.08);overflow-y:auto;background:#0f0d0e;display:flex;flex-direction:column}
.f-item{padding:5px 10px;font-size:11px;cursor:pointer;display:flex;align-items:center;gap:6px;transition:all .1s;color:#9a7a85}
.f-item:hover{background:#1a1416;color:#fff}
.f-item.active{background:rgba(255,122,170,0.1);color:#ff7aaa;border-left:2px solid #ff7aaa;padding-left:8px}
.f-icon{font-size:12px;opacity:0.5}
.f-item.folder .f-icon{color:#9a7a85}
.f-item.file.lua .f-icon{color:#7a9aff}
.f-item.file.json .f-icon{color:#ffad7a}
.f-item.file.txt .f-icon{color:#7aff9a}
.f-item.file.vtf .f-icon{color:#ff7aff}
.f-item.file.vmt .f-icon{color:#ffad7a}
.f-item.file.png .f-icon{color:#ff7aff}
.f-item.file.jpg .f-icon{color:#ff7aff}
.f-item.file.jpeg .f-icon{color:#ff7aff}
.f-item.file.tga .f-icon{color:#ff7aff}
.f-item.file.mp3 .f-icon{color:#7affad}
.f-item.file.wav .f-icon{color:#7affad}
.f-item.file.ogg .f-icon{color:#7affad}
.f-item.file.bsp .f-icon{color:#ad7aff}
.f-item.file.mdl .f-icon{color:#7adfff}
.f-item.file.phy .f-icon{color:#7adfff}
.f-item.file.vvd .f-icon{color:#7adfff}
.f-item.file.vtx .f-icon{color:#7adfff}
.f-item.file.ani .f-icon{color:#7adfff}
.f-item.file.qc .f-icon{color:#7adfff}
.f-item.file.smd .f-icon{color:#7adfff}
.f-item.file.vpk .f-icon{color:#ffadad}
.f-item.file.gma .f-icon{color:#ffadad}

.editor-area{flex:1;display:flex;flex-direction:column;background:#0f0d0e;position:relative}
.tabs-bar{display:flex;align-items:center;background:#1a1416;border-bottom:1px solid rgba(255,209,217,0.08);min-height:28px;overflow-x:auto}
.tab{display:flex;align-items:center;gap:6px;padding:4px 8px;font-size:10px;color:#9a7a85;background:transparent;border:none;cursor:pointer;transition:all .1s;white-space:nowrap;position:relative;min-width:0}
.tab:hover{color:#fff;background:#2a1b1f}
.tab.active{color:#ff7aaa;background:#2d1a23;border-bottom:1px solid #ff7aaa}
.tab-name{max-width:150px;overflow:hidden;text-overflow:ellipsis}
.tab-close{width:14px;height:14px;border-radius:2px;display:flex;align-items:center;justify-content:center;opacity:0;transition:all .1s;font-size:12px}
.tab:hover .tab-close{opacity:0.5}
.tab-close:hover{background:#ff7aaa;color:#0f0d0e;opacity:1}
.tab-new{width:24px;height:20px;display:flex;align-items:center;justify-content:center;color:#7a5f66;cursor:pointer;border-left:1px solid rgba(255,209,217,0.08);flex-shrink:0}
.tab-new:hover{color:#fff;background:#2a1b1f}
#monaco-container{flex:1;min-height:0}
.editor-placeholder{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#3a2a2e;font-weight:600;text-transform:uppercase;letter-spacing:1px;pointer-events:none;gap:8px}
.editor-placeholder .icon{font-size:32px;opacity:0.2}
.status-bar{height:22px;background:#1a1416;border-top:1px solid rgba(255,209,217,0.08);display:flex;align-items:center;padding:0 10px;font-size:10px;color:#7a5f66;justify-content:space-between}

.no-results{padding:20px;text-align:center;color:#5a444a;font-style:italic;font-size:11px}
]]
end
