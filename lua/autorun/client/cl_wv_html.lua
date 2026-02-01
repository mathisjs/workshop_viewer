WV = WV or {}

function WV.GetHTML()
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

.editor-area{flex:1;display:flex;flex-direction:column;background:#0f0d0e;position:relative}
#monaco-container{flex:1;min-height:0}
.editor-placeholder{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#3a2a2e;font-weight:600;text-transform:uppercase;letter-spacing:1px;pointer-events:none;gap:8px}
.editor-placeholder .icon{font-size:32px;opacity:0.2}
.status-bar{height:22px;background:#1a1416;border-top:1px solid rgba(255,209,217,0.08);display:flex;align-items:center;padding:0 10px;font-size:10px;color:#7a5f66;justify-content:space-between}

.no-results{padding:20px;text-align:center;color:#5a444a;font-style:italic;font-size:11px}
</style>
</head>
<body>
<div class="app">
    <div class="sidebar">
        <div class="toolbar">
            <div class="search-box">
                <input id="search-input" placeholder="Search addons..." spellcheck="false">
            </div>
            <button class="btn btn-icon" id="refresh-btn" title="Refresh">↻</button>
        </div>
        <div class="addon-list" id="addon-list"></div>
    </div>

    <div class="main">
        <div class="explorer-bar">
            <button class="btn btn-icon" id="back-btn" title="Up" disabled>↑</button>
            <div class="crumbs" id="breadcrumbs"></div>
            <button class="btn" id="workshop-btn" disabled title="Open Workshop">WS</button>
            <button class="btn" id="copy-btn" title="Copy">Copy</button>
        </div>
        
        <div class="file-view">
            <div class="file-list" id="file-list">
                <div class="f-item" style="justify-content:center;opacity:0.4;font-style:italic;padding:15px 10px">Select addon</div>
            </div>
            <div class="editor-area">
                <div id="monaco-container"></div>
                <div class="editor-placeholder" id="editor-msg">

                </div>
                <div class="status-bar">
                    <span id="status-text">Ready</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs/loader.min.js"></script>
<script>
(function(){
    const state={addons:[],currentMount:null,currentPath:'',editor:null,bookmarks:new Set()};
    const els={list:document.getElementById('addon-list'),fileList:document.getElementById('file-list'),search:document.getElementById('search-input'),crumbs:document.getElementById('breadcrumbs'),status:document.getElementById('status-text'),editorMsg:document.getElementById('editor-msg'),backBtn:document.getElementById('back-btn'),workshopBtn:document.getElementById('workshop-btn'),copyBtn:document.getElementById('copy-btn'),refreshBtn:document.getElementById('refresh-btn')};
    
    function callLua(n,...a){if(window.wv&&window.wv[n])window.wv[n](...a)}
    function formatBytes(b){if(b===0)return'0 B';const k=1024,s=['B','KB','MB','GB'],i=Math.floor(Math.log(b)/Math.log(k));return parseFloat((b/Math.pow(k,i)).toFixed(1))+' '+s[i]}
    function getInitials(t){return t.split(' ').filter(w=>w.length>0).map(w=>w[0].toUpperCase()).slice(0,4).join('')}

    function initEditor(){
        require.config({paths:{'vs':'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs'}});
        window.MonacoEnvironment={getWorkerUrl:()=>proxyWorker()};
        require(['vs/editor/editor.main'],function(){
            monaco.editor.defineTheme('wv-theme',{
                base:'vs-dark',inherit:true,
                rules:[{background:'0f0d0e'}],
                colors:{
                    'editor.background':'#0f0d0e',
                    'editorLineNumber.foreground':'#3a2a2e',
                    'editor.selectionBackground':'#2d1a23',
                    'editorCursor.foreground':'#ff7aaa',
                    'editor.lineHighlightBackground':'#141113'
                }
            });
            state.editor=monaco.editor.create(document.getElementById('monaco-container'),{
                value:'',language:'plaintext',theme:'wv-theme',
                readOnly:true,minimap:{enabled:false},
                fontSize:12,fontFamily:"'Consolas','Fira Code',monospace",
                automaticLayout:true,lineNumbers:'on',scrollBeyondLastLine:false,
                padding:{top:8,bottom:8},renderLineHighlight:'all'
            });
            callLua('Ready');
        });
    }
    function proxyWorker(){const s="self.MonacoEnvironment={baseUrl:'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/'};importScripts('https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs/base/worker/workerMain.js');";return URL.createObjectURL(new Blob([s],{type:'text/javascript'}))}
    function setEditorContent(text,ext){
        if(!state.editor)return;
        const lang={lua:'lua',json:'json',md:'markdown',js:'javascript',html:'html',css:'css',xml:'xml'}[ext]||'plaintext';
        monaco.editor.setModelLanguage(state.editor.getModel(),lang);
        state.editor.setValue(text);
        state.editor.setScrollTop(0);
        els.editorMsg.style.display=text?'none':'flex';
    }
    
    function renderAddons(){
        const term=els.search.value.toLowerCase();
        els.list.innerHTML='';
        const sorted=[...state.addons].sort((a,b)=>(state.bookmarks.has(b.mount)?1:0)-(state.bookmarks.has(a.mount)?1:0)||a.title.localeCompare(b.title));
        sorted.forEach(a=>{
            if(term&&!a.haystack.includes(term))return;
            const item=document.createElement('div');
            item.className=`addon-item ${state.currentMount===a.mount?'active':''}`;
            item.dataset.wsid=a.wsid;
            item.dataset.mount=a.mount;
            const isBookmarked=state.bookmarks.has(a.mount);
            item.innerHTML=`
                <div class="addon-thumb">
                    ${a.imgUrl?`<img src="${a.imgUrl}" class="loaded" draggable="false">`:`<span class="initials">${getInitials(a.title)}</span>`}
                </div>
                <div class="addon-info">
                    <div class="addon-name" title="${a.title}">${a.title}</div>
                    <div class="addon-meta">
                        <span class="addon-size">${formatBytes(a.size)}</span>
                    </div>
                </div>
                <div class="bookmark-btn ${isBookmarked?'bookmarked':''}" data-mount="${a.mount}">★</div>
            `;
            item.onclick=(e)=>{
                if(e.target.classList.contains('bookmark-btn'))return;
                selectAddon(a);
            };
            item.querySelector('.bookmark-btn').onclick=(e)=>{
                e.stopPropagation();
                toggleBookmark(a.mount);
            };
            els.list.appendChild(item);
        });
        if(els.list.children.length===0)els.list.innerHTML='<div class="no-results">No addons</div>';
    }
    
    function renderFiles(dirs,files){
        els.fileList.innerHTML='';
        if(state.currentPath){
            const item=createFileItem('..','folder',()=>{
                const p=state.currentPath.split('/');
                p.pop();
                requestDir(p.join('/'));
            });
            els.fileList.appendChild(item);
        }
        (dirs||[]).forEach(d=>els.fileList.appendChild(createFileItem(d,'folder',()=>requestDir((state.currentPath?state.currentPath+'/':'')+d))));
        (files||[]).forEach(f=>els.fileList.appendChild(createFileItem(f.name,'file',()=>{
            callLua('RequestFile',state.currentMount,f.path);
            els.status.textContent='Loading '+f.name+'...';
        },f.ext)));
        renderCrumbs();
    }
    
    function createFileItem(name,type,onClick,ext){
        const div=document.createElement('div');
        div.className=`f-item ${type} ${ext||''}`;
        const icon=type==='folder'?'📁':{lua:'📜',json:'⚙️',txt:'📄'}[ext]||'📄';
        div.innerHTML=`<span class="f-icon">${icon}</span><span>${name}</span>`;
        div.onclick=(e)=>{
            if(type==='file'){
                Array.from(els.fileList.children).forEach(c=>c.classList.remove('active'));
                div.classList.add('active');
            }
            onClick();
        };
        return div;
    }
    
    function renderCrumbs(){
        els.crumbs.innerHTML='';
        const home=document.createElement('span');
        home.className='crumb '+(!state.currentPath?'active':'');
        home.textContent='Root';
        home.onclick=()=>requestDir('');
        els.crumbs.appendChild(home);
        if(state.currentPath){
            let acc='';
            state.currentPath.split('/').forEach((part,i)=>{
                els.crumbs.appendChild(document.createTextNode(' / '));
                acc+=(i>0?'/':'')+part;
                const cPath=acc;
                const span=document.createElement('span');
                span.className='crumb active';
                span.textContent=part;
                span.onclick=()=>requestDir(cPath);
                els.crumbs.appendChild(span);
            });
        }
        els.backBtn.disabled=!state.currentPath;
    }
    
    function selectAddon(addon){
        state.currentMount=addon.mount;
        state.currentPath='';
        els.workshopBtn.disabled=!addon.wsid;
        renderAddons();
        requestDir('');
        if(state.editor)state.editor.setValue('');
        els.editorMsg.innerHTML='';
        els.editorMsg.style.display='flex';
        callLua('SelectAddon',addon.mount,addon.title,addon.wsid);
    }
    
    function requestDir(path){
        state.currentPath=path||'';
        callLua('RequestDirectory',state.currentMount,state.currentPath);
        els.fileList.innerHTML='<div class="f-item" style="opacity:0.4">Loading...</div>';
    }
    
    function toggleBookmark(mount){
        if(state.bookmarks.has(mount)){
            state.bookmarks.delete(mount);
        }else{
            state.bookmarks.add(mount);
        }
        const arr=Array.from(state.bookmarks);
        callLua('SaveBookmarks',arr);
        renderAddons();
    }
    
    function updateImage(wsid,url){
        if(!wsid||!url)return;
        const a=state.addons.find(x=>x.wsid==wsid);
        if(a){
            a.imgUrl=url;
            const items=document.querySelectorAll('.addon-item');
            for(let i=0;i<items.length;i++){
                if(items[i].dataset.mount===a.mount){
                    const card=items[i].querySelector('.addon-thumb');
                    if(card)card.innerHTML=`<img src="${url}" class="loaded" draggable="false">`;
                    break;
                }
            }
        }
    }
    
    window.WVReceive=function(msg){
        if(!msg||!msg.event)return;
        const p=msg.payload;
        switch(msg.event){
            case 'addons':
                state.addons=(p||[]).map(a=>{a.haystack=(a.title+' '+a.file).toLowerCase();return a});
                renderAddons();
                callLua('LoadBookmarks');
                break;
            case 'bookmarks':
                state.bookmarks=new Set(p||[]);
                renderAddons();
                break;
            case 'addon_image':
                updateImage(p.wsid,p.url);
                break;
            case 'directory':
                if(p.mount!==state.currentMount)return;
                renderFiles(p.dirs,p.files);
                break;
            case 'file':
                setEditorContent(p.text,p.path.split('.').pop());
                els.status.textContent='Loaded '+p.path;
                break;
            case 'status':
                els.status.textContent=p.text;
                if(p.level==='error')els.status.style.color='#ff6d7a';
                else els.status.style.color='';
                setTimeout(()=>els.status.style.color='',3000);
        }
    };
    
    els.search.addEventListener('input',renderAddons);
    els.refreshBtn.onclick=()=>callLua('RefreshAddons');
    els.workshopBtn.onclick=()=>{
        const a=state.addons.find(x=>x.mount===state.currentMount);
        if(a&&a.wsid)callLua('OpenWorkshop',a.wsid);
    };
    els.copyBtn.onclick=()=>{if(state.editor)callLua('CopyText',state.editor.getValue())};
    els.backBtn.onclick=()=>{
        if(!state.currentPath)return;
        const p=state.currentPath.split('/');
        p.pop();
        requestDir(p.join('/'));
    };
    
    initEditor();
})();
</script>
</body>
</html>
    ]]
end
