return [[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<style>
*{box-sizing:border-box}
html,body{margin:0;padding:0;height:100%;font-family:'Segoe UI',Tahoma,sans-serif;background:#0a0a0f;color:#f5f5f5}
body{font-size:14px;font-weight:600}
.wv-app{display:flex;gap:12px;padding:16px;height:100%;background:linear-gradient(145deg,#0c0c15,#09090d)}
.wv-col{flex:1;display:flex;flex-direction:column;border-radius:16px;padding:16px;background:#1b1b24;border:1px solid #2b2b37;box-shadow:0 18px 45px rgba(0,0,0,0.45)}
.wv-col h2{margin:0 0 12px;font-size:16px;letter-spacing:1px;text-transform:uppercase;color:#f0f0ff}
.wv-toolbar{display:flex;gap:10px;margin-bottom:12px}
.wv-toolbar input{flex:1;border:none;border-radius:12px;padding:10px 14px;background:#232331;color:#f6f6ff;font-weight:600}
button{border:none;border-radius:12px;padding:10px 16px;background:#4141ff;color:#fff;font-weight:700;cursor:pointer;transition:background .2s,transform .2s}
button:hover{background:#5d5dff}
button:active{transform:scale(0.97)}
.wv-list{flex:1;overflow-y:auto;border-radius:12px;background:#15151d}
.wv-item{padding:12px 16px;border-bottom:1px solid rgba(255,255,255,0.05);cursor:pointer;display:flex;flex-direction:column;gap:4px}
.wv-item:last-child{border-bottom:none}
.wv-item:hover{background:rgba(255,255,255,0.04)}
.wv-item.active{background:rgba(94,118,255,0.25)}
.wv-item .wv-title{color:#f8f8ff;font-size:14px}
.wv-item .wv-meta{color:#a7a7c7;font-size:12px;font-weight:500}
.wv-browser .wv-path{margin-bottom:12px;color:#c7c7e8;font-weight:500}
.wv-files .wv-item{flex-direction:row;justify-content:space-between;align-items:center}
.wv-files .wv-item span{font-weight:600}
.wv-files .wv-item small{color:#8d8db3;font-weight:500}
.wv-viewer{flex:1.2}
.wv-viewer-bar{display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:12px}
.wv-viewer-bar .wv-path{flex:1;color:#d9daf9;font-size:13px}
.wv-viewer-bar .wv-actions{display:flex;gap:8px}
#code-view{flex:1;background:#0d0d15;border-radius:14px;border:1px solid #272738;padding:14px;overflow-y:auto;font-family:'Consolas','Fira Code',monospace;font-size:13px;white-space:pre-wrap;line-height:1.45}
.wv-status{margin-top:12px;min-height:24px;color:#9da2ff;font-size:12px}
.wv-status.error{color:#ff6d7a}
.wv-status.success{color:#6bffb3}
::-webkit-scrollbar{width:6px;height:6px}
::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.18);border-radius:6px}
</style>
</head>
<body>
<div class="wv-app">
    <div class="wv-col wv-addons">
        <h2>Addons</h2>
        <div class="wv-toolbar">
            <input id="addon-search" placeholder="Filter..." autocomplete="off" />
            <button id="refresh-btn" title="Refresh">&#8635;</button>
        </div>
        <div class="wv-list" id="addon-list"></div>
    </div>
    <div class="wv-col wv-browser">
        <h2 id="browser-title">Files</h2>
        <div class="wv-path" id="browser-path">/</div>
        <div class="wv-list wv-files" id="dir-list"></div>
    </div>
    <div class="wv-col wv-viewer">
        <div class="wv-viewer-bar">
            <div class="wv-path" id="viewer-path">No file selected</div>
            <div class="wv-actions">
                <button id="copy-btn">Copy</button>
                <button id="workshop-btn">Workshop</button>
            </div>
        </div>
        <pre id="code-view"></pre>
        <div class="wv-status" id="status-bar"></div>
    </div>
</div>
<script>
(function(){
    const state={addons:[],currentMount:'',currentAddon:null,currentDir:'',dirs:[],files:[],fileText:'',statusTimer:null};
    const els={addons:document.getElementById('addon-list'),search:document.getElementById('addon-search'),browserTitle:document.getElementById('browser-title'),browserPath:document.getElementById('browser-path'),dirList:document.getElementById('dir-list'),viewerPath:document.getElementById('viewer-path'),codeView:document.getElementById('code-view'),status:document.getElementById('status-bar'),copy:document.getElementById('copy-btn'),workshop:document.getElementById('workshop-btn'),refresh:document.getElementById('refresh-btn')};
    function callNative(name){if(window.wv&&typeof window.wv[name]==='function'){const args=Array.prototype.slice.call(arguments,1);window.wv[name].apply(window.wv,args);}}
    function setAddons(list){state.addons=Array.isArray(list)?list:[];renderAddons();}
    function renderAddons(){const filter=(els.search.value||'').toLowerCase();els.addons.innerHTML='';const frag=document.createDocumentFragment();state.addons.filter(addon=>{if(!filter)return true;const hay=((addon.title||addon.file||'')+' '+(addon.wsid||'')).toLowerCase();return hay.includes(filter);}).forEach(addon=>{const div=document.createElement('div');div.className='wv-item'+(addon.mount===state.currentMount?' active':'');const sizeText=addon.size_human||'';const updatedText=addon.updated_human||'';div.innerHTML=`<span class="wv-title">${addon.title||addon.file||'Addon'}</span><span class="wv-meta">WSID: ${addon.wsid||'?'} | ${sizeText} | ${updatedText}</span>`;div.addEventListener('click',()=>selectAddon(addon));frag.appendChild(div);});els.addons.appendChild(frag);}
    function selectAddon(addon){state.currentMount=addon.mount||'';state.currentAddon=addon;state.currentDir='';state.dirs=[];state.files=[];state.fileText='';renderAddons();renderDirectory();renderFile();callNative('SelectAddon',addon.mount||'',addon.title||addon.file||'Addon',addon.wsid||'');}
    function upPath(path){if(!path)return'';const segments=path.split('/').filter(Boolean);if(!segments.length)return'';segments.pop();return segments.length?segments.join('/')+'/':'';}
    function renderDirectory(){els.browserTitle.textContent=state.currentAddon?(state.currentAddon.title||state.currentAddon.file||'Files'):'Files';els.browserPath.textContent=state.currentDir===''?'/':'/'+state.currentDir;els.dirList.innerHTML='';const frag=document.createDocumentFragment();if(state.currentDir!==''){const up=document.createElement('div');up.className='wv-item';up.innerHTML='<span>..</span><small>Back</small>';up.addEventListener('click',()=>changeDirectory(upPath(state.currentDir)));frag.appendChild(up);} (state.dirs||[]).forEach(name=>{const item=document.createElement('div');item.className='wv-item';item.innerHTML=`<span>${name}/</span><small>Folder</small>`;item.addEventListener('click',()=>{const next=(state.currentDir||'')+name+'/';changeDirectory(next);});frag.appendChild(item);});(state.files||[]).forEach(file=>{const item=document.createElement('div');item.className='wv-item';item.innerHTML=`<span>${file.name}</span><small>Open</small>`;item.addEventListener('click',()=>{callNative('RequestFile',state.currentMount,file.path);showStatus('Loading '+file.name+' ...');});frag.appendChild(item);});els.dirList.appendChild(frag);}
    function changeDirectory(path){state.currentDir=path||'';renderDirectory();callNative('RequestDirectory',state.currentMount,path||'');}
    function renderFile(){els.viewerPath.textContent=state.filePath||'No file selected';els.codeView.textContent=state.fileText||'';}
    function updateDirectory(payload){state.currentMount=payload.mount||state.currentMount;state.currentDir=payload.dir||'';state.dirs=payload.dirs||[];state.files=payload.files||[];if(payload.wsid){state.currentAddon=state.currentAddon||{};state.currentAddon.wsid=payload.wsid;}if(payload.addon){state.currentAddon=state.currentAddon||{};state.currentAddon.title=payload.addon;}renderDirectory();}
    function updateFile(payload){state.fileText=payload.text||'';state.filePath=payload.path||'';renderFile();}
    function showStatus(text,level){if(state.statusTimer){clearTimeout(state.statusTimer);state.statusTimer=null;}els.status.textContent=text||'';els.status.className='wv-status'+(level?' '+level:'');if(text){state.statusTimer=setTimeout(()=>{els.status.textContent='';els.status.className='wv-status';},4000);}}
    window.WVReceive=function(msg){if(!msg||!msg.event)return;const payload=msg.payload||{};switch(msg.event){case'addons':setAddons(payload);break;case'directory':updateDirectory(payload);break;case'file':updateFile(payload)}};
    els.search.addEventListener('input',renderAddons);
    els.refresh.addEventListener('click',()=>callNative('RefreshAddons'));
    els.copy.addEventListener('click',()=>callNative('CopyText',state.fileText||''));
    els.workshop.addEventListener('click',()=>{if(state.currentAddon&&state.currentAddon.wsid){callNative('OpenWorkshop',state.currentAddon.wsid);}});
    document.addEventListener('DOMContentLoaded',()=>{callNative('Ready');});
})();
</script>
</body>
</html>
]]
