WV = WV or {}

function WV.GetHTML()
    return [[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<style>
]] .. WV.GetCSS() .. [[
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
            <button class="btn btn-close" id="close-btn" title="Close">×</button>
        </div>
        
        <div class="file-view">
            <div class="file-list" id="file-list">
                <div class="f-item" style="justify-content:center;opacity:0.4;font-style:italic;padding:15px 10px">Select addon</div>
            </div>
            <div class="editor-area">
                <div class="tabs-bar" id="tabs-bar"></div>
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
]] .. WV.GetJavaScript() .. [[
</script>
</body>
</html>
]]
end
