WV = WV or {}

function WV.GetHTML()
    return [[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<style>
*{box-sizing:border-box;user-select:none}
html,body{margin:0;padding:0;height:100%;font-family:'Segoe UI',Tahoma,sans-serif;background:#191117;color:#FFD1D9;overflow:hidden}
body{font-size:14px;font-weight:600}
.wv-app{display:flex;gap:0;padding:16px;height:100%;background:#191117}
.wv-col{display:flex;flex-direction:column;flex:1 1 0;border-radius:12px;padding:16px;background:#21121D;border:1px solid #2b1d25;box-shadow:0 14px 34px rgba(0,0,0,0.45);min-width:150px;min-height:0}
.wv-col h2{margin:0 0 12px;font-size:15px;letter-spacing:0.5px;text-transform:uppercase;color:#FFD1D9}
.wv-toolbar{display:flex;gap:10px;margin-bottom:12px}
.wv-toolbar input{flex:1;border:1px solid #34212a;border-radius:10px;padding:10px 14px;background:#181017;color:#FFD1D9;font-weight:600;outline:none}
.wv-toolbar input:focus{box-shadow:0 0 0 1px #ff7aaa;outline:none;border-color:#ff7aaa;background:#1d0f18}
button{border:1px solid #34212a;border-radius:10px;padding:10px 16px;background:#25141d;color:#FFD1D9;font-weight:700;cursor:pointer;transition:background .15s,transform .15s,border-color .15s;outline:none}
button:focus{outline:none;box-shadow:none}
button:hover{background:#2c1823;border-color:#ff7aaa}
button:active{transform:scale(0.98);background:#1e0f17}
.wv-list{flex:1;overflow-y:auto;border-radius:10px;background:#1a0f15;border:1px solid #2b1b22}
.wv-item{padding:12px 16px;border-bottom:1px solid rgba(255,255,255,0.05);cursor:pointer;display:flex;flex-direction:column;gap:4px}
.wv-item:last-child{border-bottom:none}
.wv-item:hover{background:rgba(255,122,170,0.08)}
.wv-item.active{background:rgba(255,122,170,0.16);border-color:rgba(255,122,170,0.28)}
.wv-item .wv-title{color:#FFD1D9;font-size:14px}
.wv-item .wv-meta{color:#d9a7b2;font-size:12px;font-weight:500}
.wv-addon-header{display:flex;justify-content:space-between;align-items:center;gap:10px}
.wv-addon-actions{display:flex;gap:6px}
.wv-addon-body{margin-top:10px;padding:10px;border-radius:8px;background:#21121D;border:1px solid #2f1c24}
.wv-pathline{display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;color:#d9a7b2;font-size:12px;font-weight:600}
.wv-files{display:flex;flex-direction:column;gap:6px}
.wv-file{display:flex;justify-content:space-between;align-items:center;padding:10px 12px;border-radius:8px;border:1px solid #2b1b22;background:#1b1117;cursor:pointer}
.wv-file:hover{background:#21121d;border-color:#ff7aaa}
.wv-file span{color:#FFD1D9;font-weight:600}
.wv-file small{color:#c78ea1;font-weight:500}
.wv-breadcrumb{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
.wv-crumb{padding:6px 10px;border-radius:8px;font-size:12px;border:1px solid #34212a;background:#1b1117;cursor:pointer}
.wv-crumb:hover{border-color:#ff7aaa;background:#21121d}
.wv-crumb.active{border-color:#ff7aaa;background:rgba(255,122,170,0.16)}
.wv-viewer{min-height:0}
.wv-viewer-bar{display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:12px}
.wv-viewer-bar .wv-path{flex:1;color:#d9a7b2;font-size:13px}
.wv-viewer-bar .wv-actions{display:flex;gap:8px}
#code-view{position:relative;flex:1;background:#191117;border-radius:12px;border:1px solid #2b1d25;overflow:hidden;min-height:300px;min-width:0}
#code-view,#code-view *{user-select:text}
.wv-editor-loading{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;color:#FFD1D9;font-weight:700;font-size:13px;background:linear-gradient(145deg,rgba(25,17,23,0.96),rgba(33,18,29,0.96));letter-spacing:1px;text-transform:uppercase}
#code-view .monaco-editor,#code-view .monaco-editor .margin{background-color:transparent!important}
#code-view .monaco-editor .margin{border-right:1px solid rgba(255,255,255,0.04)}
.wv-status{margin-top:12px;min-height:24px;color:#d9a7b2;font-size:12px}
.wv-status.error{color:#ff6d7a}
.wv-status.success{color:#6bffb3}
::-webkit-scrollbar{width:6px;height:6px}
::-webkit-scrollbar-thumb{background:rgba(255,209,217,0.25);border-radius:6px}
.wv-resizer{width:6px;cursor:col-resize;position:relative;flex-shrink:0;margin:0 6px}
.wv-resizer::before{content:'';position:absolute;top:0;bottom:0;left:2px;width:2px;background:rgba(255,255,255,0.08);border-radius:2px;transition:background .2s}
.wv-resizer:hover::before,.wv-resizer.active::before{background:rgba(255,111,159,0.6)}
</style>
</head>
<body>
<div class="wv-app">
    <div class="wv-col wv-addons" id="col-addons">
        <h2>Addons</h2>
        <div class="wv-toolbar">
            <input id="addon-search" placeholder="Filter..." autocomplete="off" />
            <button id="refresh-btn" title="Refresh">&#8635;</button>
        </div>
        <div class="wv-list" id="addon-list"></div>
    </div>
    <div class="wv-resizer" data-resize="0"></div>
    <div class="wv-col wv-viewer" id="col-viewer">
        <div class="wv-viewer-bar">
            <div class="wv-path" id="viewer-path">No file selected</div>
            <div class="wv-actions">
                <button id="copy-btn">Copy</button>
                <button id="workshop-btn">Workshop</button>
            </div>
        </div>
        <div id="code-view"><div class="wv-editor-loading" id="editor-loading">Loading editor...</div></div>
        <div class="wv-status" id="status-bar"></div>
    </div>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs/loader.min.js"></script>
<script>
(function(){
    const EMPTY_TEXT="-- you need to select one file !\n-- Workshop Viewer";
    const state={addons:[],currentMount:'',currentAddon:null,currentDir:'',dirs:[],files:[],fileText:'',filePath:'',statusTimer:null,fileExt:'',editor:null,pendingContent:null};
    const els={addons:document.getElementById('addon-list'),search:document.getElementById('addon-search'),viewerPath:document.getElementById('viewer-path'),codeView:document.getElementById('code-view'),status:document.getElementById('status-bar'),copy:document.getElementById('copy-btn'),workshop:document.getElementById('workshop-btn'),refresh:document.getElementById('refresh-btn'),colAddons:document.getElementById('col-addons'),colViewer:document.getElementById('col-viewer'),editorLoading:document.getElementById('editor-loading')};

    function callNative(name){if(window.wv&&typeof window.wv[name]==='function'){const args=Array.prototype.slice.call(arguments,1);window.wv[name].apply(window.wv,args);}}

    function extFromPath(path){if(!path)return'';const idx=path.lastIndexOf('.');return idx>=0?path.substring(idx+1).toLowerCase():'';}
    function languageForExt(ext){const map={lua:'lua',json:'json',md:'markdown',txt:'plaintext',cfg:'ini',ini:'ini',log:'ini',vmt:'ini',vdf:'ini',vmf:'plaintext'};return map[ext]||'plaintext';}

    function setEditorContent(text,ext){
        state.fileText=text||'';
        state.fileExt=(ext||state.fileExt||'')||'';
        if(!state.editor){
            state.pendingContent={text:state.fileText,ext:state.fileExt};
            return;
        }
        const lang=languageForExt(state.fileExt);
        const model=state.editor.getModel();
        if(model){monaco.editor.setModelLanguage(model,lang);}
        state.editor.setValue(state.fileText);
    }

    function bootEditor(){
        if(typeof require==='undefined'){
            if(els.editorLoading){els.editorLoading.textContent='Editor unavailable';}
            callNative('Ready');
            return;
        }
        require.config({paths:{'vs':'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs'}});
        window.MonacoEnvironment={getWorkerUrl:function(){const src="self.MonacoEnvironment={baseUrl:'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/'};importScripts('https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs/base/worker/workerMain.js');";const blob=new Blob([src],{type:'text/javascript'});return URL.createObjectURL(blob);}};
        require(['vs/editor/editor.main'],function(){
            monaco.editor.defineTheme('wv-darkpink',{
                base:'vs-dark',
                inherit:true,
                rules:[{token:'',background:'191117'}],
                colors:{
                    'editor.background':'#191117',
                    'editorLineNumber.foreground':'#8c767b',
                    'editorLineNumber.activeForeground':'#FFD1D9',
                    'editorLineHighlightBackground':'#21121D',
                    'editorGutter.background':'#191117',
                    'editor.selectionBackground':'#2d1a23',
                    'editor.selectionHighlightBackground':'#23141d',
                    'editorCursor.foreground':'#FFD1D9',
                    'editorIndentGuide.background':'#24161d',
                    'editorIndentGuide.activeBackground':'#2f1c24',
                    'scrollbarSlider.background':'#3a2f30aa',
                    'scrollbarSlider.hoverBackground':'#4a3b3caa',
                    'scrollbarSlider.activeBackground':'#ff7aaaaa'
                }
            });
            if(els.editorLoading){els.editorLoading.remove();}
            state.editor=monaco.editor.create(els.codeView,{value:'',language:'plaintext',theme:'wv-darkpink',readOnly:true,minimap:{enabled:false},automaticLayout:true,scrollBeyondLastLine:false,lineNumbers:'on',fontSize:13,fontFamily:"'Fira Code', Consolas, 'Segoe UI Mono', monospace",renderWhitespace:'none',overviewRulerLanes:0});
            if(state.pendingContent){setEditorContent(state.pendingContent.text,state.pendingContent.ext);state.pendingContent=null;}
            state.editor.layout();
            callNative('Ready');
        });
    }

    function setAddons(list){state.addons=Array.isArray(list)?list:[];renderAddons();}
    function renderAddons(){
        const filter=(els.search.value||'').toLowerCase();
        els.addons.innerHTML='';
        const frag=document.createDocumentFragment();
        state.addons.filter(addon=>{
            const isActive=addon.mount===state.currentMount;
            if(isActive)return true;
            if(!filter)return true;
            const hay=((addon.title||addon.file||'')+' '+(addon.wsid||'')).toLowerCase();
            return hay.includes(filter);
        }).forEach(addon=>{
            const isActive=addon.mount===state.currentMount;
            const wrap=document.createElement('div');
            wrap.className='wv-item'+(isActive?' active':'');

            const header=document.createElement('div');
            header.className='wv-file wv-addon';
            const sizeText=addon.size_human||'';
            const updatedText=addon.updated_human||'';
            header.innerHTML=`<div class="wv-addon-header"><div><span>${addon.title||addon.file||'Addon'}</span><br/><small>${sizeText} • ${updatedText}</small></div></div>`;
            header.addEventListener('click',()=>selectAddon(addon));
            wrap.appendChild(header);

            if(isActive){
                const body=document.createElement('div');
                body.className='wv-addon-body';

                const pathLine=document.createElement('div');
                pathLine.className='wv-pathline';
                const crumbs=document.createElement('div');
                crumbs.className='wv-breadcrumb';
                const root=document.createElement('div');
                root.className='wv-crumb'+(state.currentDir===''?' active':'');
                root.textContent='/';
                root.addEventListener('click',()=>changeDirectory(''));
                crumbs.appendChild(root);
                const segments=state.currentDir.split('/').filter(Boolean);
                let acc='';
                segments.forEach((seg,idx)=>{
                    acc+=seg+'/';
                    const crumb=document.createElement('div');
                    crumb.className='wv-crumb'+(idx===segments.length-1?' active':'');
                    crumb.textContent=seg+'/';
                    crumb.addEventListener('click',()=>changeDirectory(acc));
                    crumbs.appendChild(crumb);
                });
                pathLine.appendChild(crumbs);
                const backBtn=document.createElement('button');
                backBtn.textContent='Back';
                backBtn.disabled=state.currentDir==='';
                backBtn.addEventListener('click',()=>changeDirectory(upPath(state.currentDir)));
                pathLine.appendChild(backBtn);
                body.appendChild(pathLine);

                const list=document.createElement('div');
                list.className='wv-files';
                (state.dirs||[]).forEach(name=>{
                    const item=document.createElement('div');
                    item.className='wv-file';
                    item.innerHTML=`<span>${name}/</span><small>Folder</small>`;
                    item.addEventListener('click',()=>{
                        const next=(state.currentDir||'')+name+'/';
                        changeDirectory(next);
                    });
                    list.appendChild(item);
                });
                (state.files||[]).forEach(file=>{
                    const item=document.createElement('div');
                    item.className='wv-file';
                    item.innerHTML=`<span>${file.name}</span><small>Open</small>`;
                    item.addEventListener('click',()=>{
                        state.fileExt=file.ext||'';
                        callNative('RequestFile',state.currentMount,file.path);
                        showStatus('Loading '+file.name+' ...');
                    });
                    list.appendChild(item);
                });
                body.appendChild(list);
                wrap.appendChild(body);
            }

            frag.appendChild(wrap);
        });
        els.addons.appendChild(frag);
    }
    function selectAddon(addon){
        if(state.currentMount===addon.mount){
            state.currentMount='';
            state.currentAddon=null;
            state.currentDir='';
            state.dirs=[];
            state.files=[];
            state.fileText='';
            state.filePath='';
            state.fileExt='';
            renderAddons();
            renderFile();
            return;
        }
        state.currentMount=addon.mount||'';
        state.currentAddon=addon;
        state.currentDir='';
        state.dirs=[];
        state.files=[];
        state.fileText='';
        state.filePath='';
        state.fileExt='';
        renderAddons();
        renderFile();
        callNative('SelectAddon',addon.mount||'',addon.title||addon.file||'Addon',addon.wsid||'');
        changeDirectory('');
    }
    function upPath(path){if(!path)return'';const segments=path.split('/').filter(Boolean);if(!segments.length)return'';segments.pop();return segments.length?segments.join('/')+'/':'';}
    function changeDirectory(path){
        if(!state.currentMount)return;
        state.currentDir=path||'';
        renderAddons();
        callNative('RequestDirectory',state.currentMount,path||'');
    }
    function renderFile(){
        const hasFile=!!state.filePath;
        const prefix=state.currentAddon?(state.currentAddon.title||state.currentAddon.file||'Addon'):'';
        const pathLabel=hasFile?(prefix!==''?prefix+': ':'')+state.filePath:'No file selected';
        els.viewerPath.textContent=pathLabel;
        setEditorContent(hasFile?state.fileText:EMPTY_TEXT,state.fileExt);
    }
    function updateDirectory(payload){
        state.currentMount=payload.mount||state.currentMount;
        state.currentDir=payload.dir||'';
        state.dirs=payload.dirs||[];
        state.files=payload.files||[];
        if(payload.wsid){state.currentAddon=state.currentAddon||{};state.currentAddon.wsid=payload.wsid;}
        if(payload.addon){state.currentAddon=state.currentAddon||{};state.currentAddon.title=payload.addon;}
        renderAddons();
    }
    function updateFile(payload){state.fileText=payload.text||'';state.filePath=payload.path||'';state.fileExt=extFromPath(state.filePath);renderFile();}
    function showStatus(text,level){if(state.statusTimer){clearTimeout(state.statusTimer);state.statusTimer=null;}els.status.textContent=text||'';els.status.className='wv-status'+(level?' '+level:'');if(text){state.statusTimer=setTimeout(()=>{els.status.textContent='';els.status.className='wv-status';},4000);}}
    window.WVReceive=function(msg){if(!msg||!msg.event)return;const payload=msg.payload||{};switch(msg.event){case'addons':setAddons(payload);break;case'directory':updateDirectory(payload);break;case'file':updateFile(payload);break;case'status':showStatus(payload.text,payload.level);break;}};

    const cols=[els.colAddons,els.colViewer];
    const resizers=document.querySelectorAll('.wv-resizer');
    let resizeData=null;

    function initSizes(){
        const saved=localStorage.getItem('wv-col-sizes');
        if(saved){
            try{
                const sizes=JSON.parse(saved);
                cols.forEach((col,i)=>{if(sizes[i])col.style.flexBasis=sizes[i];});
                return;
            }catch(e){}
        }
        cols[0].style.flexBasis='35%';
        cols[1].style.flexBasis='65%';
    }

    function saveSizes(){
        const sizes=cols.map(col=>col.style.flexBasis||'');
        localStorage.setItem('wv-col-sizes',JSON.stringify(sizes));
    }

    resizers.forEach(resizer=>{
        resizer.addEventListener('mousedown',e=>{
            e.preventDefault();
            const idx=parseInt(resizer.getAttribute('data-resize'));
            resizer.classList.add('active');
            resizeData={
                idx:idx,
                startX:e.clientX,
                leftCol:cols[idx],
                rightCol:cols[idx+1],
                leftStart:cols[idx].offsetWidth,
                rightStart:cols[idx+1].offsetWidth
            };
        });
        resizer.addEventListener('dblclick',()=>{
            cols[0].style.flexBasis='35%';
            cols[1].style.flexBasis='65%';
            saveSizes();
        });
    });

    document.addEventListener('mousemove',e=>{
        if(!resizeData)return;
        const delta=e.clientX-resizeData.startX;
        const leftWidth=resizeData.leftStart+delta;
        const rightWidth=resizeData.rightStart-delta;
        if(leftWidth>100&&rightWidth>100){
            resizeData.leftCol.style.flexBasis=leftWidth+'px';
            resizeData.rightCol.style.flexBasis=rightWidth+'px';
        }
    });

    document.addEventListener('mouseup',()=>{
        if(resizeData){
            resizers.forEach(r=>r.classList.remove('active'));
            saveSizes();
            resizeData=null;
        }
    });

    els.search.addEventListener('input',renderAddons);
    els.refresh.addEventListener('click',()=>callNative('RefreshAddons'));
    els.copy.addEventListener('click',()=>{const txt=state.editor?state.editor.getValue():state.fileText||'';callNative('CopyText',txt);});
    els.workshop.addEventListener('click',()=>{if(state.currentAddon&&state.currentAddon.wsid){callNative('OpenWorkshop',state.currentAddon.wsid);}});
    document.addEventListener('DOMContentLoaded',()=>{initSizes();bootEditor();});
    initSizes();
})();
</script>
</body>
</html>
]]
end
