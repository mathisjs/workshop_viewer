WV = WV or {}

local bookmarkFile = "workshop_viewer_bookmarks.txt"
local bookmarks = {}

function WV.LoadBookmarksFromFile()
    local data = file.Read(bookmarkFile, "DATA")
    if data then
        bookmarks = util.JSONToTable(data) or {}
    else
        bookmarks = {}
    end
end

function WV.SaveBookmarksToFile()
    file.Write(bookmarkFile, util.TableToJSON(bookmarks))
end

function WV.SendBookmarks()
    WV.SendEvent("bookmarks", bookmarks)
end

function WV.SaveBookmarks(bookmarksTable)
    bookmarks = bookmarksTable or {}
    WV.SaveBookmarksToFile()
end

hook.Add("Initialize", "WV_InitBookmarks", function()
    WV.LoadBookmarksFromFile()
end)
