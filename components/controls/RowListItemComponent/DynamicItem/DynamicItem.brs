sub init()
    ' print "DynamicItem : Init"
    SetControls()
    SetObservers()
end sub

sub SetControls()
    m.scene = m.top.GetScene()
end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChild")
end sub

sub itemContentChanged(event as dynamic)
    itemContent = event.getData()
    playList_program_type = ""
    if itemContent.playList_program_type <> invalid
        playList_program_type = LCase(itemContent.playList_program_type)
    end if
    if playList_program_type = "movie" or playList_program_type = "movies"
        cardViewType = "MovieCardView"
    else if playList_program_type = "event" or playList_program_type = "events"
        cardViewType = "LiveCardView"
    else if playList_program_type = "video" or playList_program_type = "videos" or itemContent.program_type = "series"
        cardViewType = "VideoCardView"
    else
        cardViewType = "VideoCardView"
    end if

    if m.cardView = invalid or (m.cardView <> invalid and m.cardView.SubType() <> cardViewType)
        if m.cardView <> invalid
            m.top.removeChild(m.cardView)
            m.cardView = invalid
        end if
        m.cardView = CreateObject("roSGNode", cardViewType)
        m.top.appendChild(m.cardView)
    end if

    m.cardView.content = itemContent
end sub


sub onFocusChanged(msg)
    m.isFocused = msg.getData()
    if m.cardView <> invalid
        m.cardView.itemHasFocus = msg.getData()
    end if
end sub

sub onFocusPercentChange(msg)
    if m.cardView <> invalid
        m.cardView.focusPercent = msg.getData()
    end if
end sub

sub onGridFocusChange(msg)
    if m.cardView <> invalid
        m.cardView.gridHasFocus = msg.getData()
        if m.isFocused <> invalid and m.isFocused then
            m.top.focusPercent = 0.0
            m.top.focusPercent = 1.0
        end if
    end if
end sub

sub onRowFocusPercentChange(msg)
    if m.cardView <> invalid
        m.cardView.rowFocusPercent = msg.getData()
    end if
end sub

sub onRowListFocusChange(msg)
    if m.cardView <> invalid
        m.cardView.rowListHasFocus = msg.getData()
    end if
end sub
