WV = WV or {}

function WV.GetJavaScript()
    return [[
(function(){
    const state={addons:[],currentMount:null,currentPath:'',editor:null,bookmarks:new Set(),tabs:[],activeTabId:null};
    const els={list:document.getElementById('addon-list'),fileList:document.getElementById('file-list'),search:document.getElementById('search-input'),crumbs:document.getElementById('breadcrumbs'),status:document.getElementById('status-text'),editorMsg:document.getElementById('editor-msg'),backBtn:document.getElementById('back-btn'),workshopBtn:document.getElementById('workshop-btn'),copyBtn:document.getElementById('copy-btn'),closeBtn:document.getElementById('close-btn'),refreshBtn:document.getElementById('refresh-btn'),tabsBar:document.getElementById('tabs-bar')};
    
    const textExtensions=new Set(['lua','txt','json','md','cfg','ini','vmt','vmf','vdf','log','qc','smd']);
    const binaryExtensions=new Set(['vtf','mp3','wav','ogg','bsp','vpk','mdl','phy','vvd','vtx','ani','png','jpg','jpeg','tga','gma']);
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
    function generateTabId(){return Date.now().toString(36)+Math.random().toString(36).substr(2)}
    function createTab(path, content, ext){
        const lang={lua:'lua',json:'json',md:'markdown',js:'javascript',html:'html',css:'css',xml:'xml'}[ext]||'plaintext';
        const model=monaco.editor.createModel(content, lang);
        const tab={id:generateTabId(),path:path||'',content:content||'',ext:ext||'',model:model};
        state.tabs.push(tab);
        state.activeTabId=tab.id;
        renderTabs();
        return tab;
    }
    function closeTab(tabId, event){
        if(event)event.stopPropagation();
        const idx=state.tabs.findIndex(t=>t.id===tabId);
        if(idx===-1)return;
        const closingTab=state.tabs[idx];
        if(closingTab.model)closingTab.model.dispose();
        if(state.activeTabId===tabId){
            if(state.tabs.length===1){
                state.tabs=[];
                state.activeTabId=null;
                if(state.editor){
                    state.editor.setModel(monaco.editor.createModel('', 'plaintext'));
                }
                els.editorMsg.style.display='flex';
                els.editorMsg.innerHTML='';
            }else{
                state.tabs.splice(idx,1);
                state.activeTabId=state.tabs[Math.min(idx, state.tabs.length-1)].id;
                const newTab=state.tabs.find(t=>t.id===state.activeTabId);
                if(newTab&&newTab.model)state.editor.setModel(newTab.model);
            }
        }else{
            state.tabs.splice(idx,1);
        }
        renderTabs();
    }
    function switchTab(tabId){
        if(state.activeTabId===tabId)return;
        state.activeTabId=tabId;
        const tab=state.tabs.find(t=>t.id===tabId);
        if(tab&&state.editor&&tab.model){
            state.editor.setModel(tab.model);
            state.editor.setScrollTop(0);
            els.editorMsg.style.display='none';
            els.status.textContent=tab.path||'Loaded file';
        }
        renderTabs();
    }
    function renderTabs(){
        els.tabsBar.innerHTML='';
        state.tabs.forEach(tab=>{
            const btn=document.createElement('button');
            btn.className=`tab ${tab.id===state.activeTabId?'active':''}`;
            btn.innerHTML=`<span class="tab-name">${tab.path.split('/').pop()||'Untitled'}</span><span class="tab-close">×</span>`;
            btn.onclick=()=>switchTab(tab.id);
            btn.querySelector('.tab-close').onclick=(e)=>closeTab(tab.id, e);
            els.tabsBar.appendChild(btn);
        });
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
            if(textExtensions.has(f.ext)){
                callLua('RequestFile',state.currentMount,f.path);
                els.status.textContent='Loading '+f.name+'...';
            }else{
                els.status.textContent='Cannot view binary file: '+f.name;
            }
        },f.ext)));
        renderCrumbs();
    }
    
    function createFileItem(name,type,onClick,ext){
        const div=document.createElement('div');
        div.className=`f-item ${type} ${ext||''}`;
        const icon=type==='folder'?'📁':{
            lua:'📜',json:'⚙️',txt:'📄',
            vtf:'🖼️',png:'🖼️',jpg:'🖼️',jpeg:'🖼️',tga:'🖼️',
            mp3:'🎵',wav:'🎵',ogg:'🎵',
            bsp:'🗺️',
            mdl:'🧊',phy:'🧊',vvd:'🧊',vtx:'🧊',ani:'🧊',qc:'🧊',smd:'🧊',
            vmt:'📦',vpk:'📦',gma:'📦',
            vdf:'⚙️',ini:'⚙️',cfg:'⚙️',log:'⚙️',md:'📄',
            vmf:'🏗️'
        }[ext]||'📄';
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
                const ext=p.path.split('.').pop();
                const existingTab=state.tabs.find(t=>t.path===p.path);
                if(existingTab){
                    switchTab(existingTab.id);
                }else{
                    createTab(p.path, p.text, ext);
                    if(state.editor){
                        const newTab=state.tabs.find(t=>t.id===state.activeTabId);
                        if(newTab&&newTab.model)state.editor.setModel(newTab.model);
                        els.editorMsg.style.display='none';
                    }
                }
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
    els.closeBtn.onclick=()=>callLua('Close');
    
    initEditor();
})();
]]
end
