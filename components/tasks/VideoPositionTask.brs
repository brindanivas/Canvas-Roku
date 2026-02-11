sub init()
end sub

function savePosition() as void
    SetBookmarkData(m.top.videoId, m.top.newPosition.toStr())
end function

function getPosition() as void
    m.top.currentPosition = GetBookmarkData(m.top.videoId)
end function
