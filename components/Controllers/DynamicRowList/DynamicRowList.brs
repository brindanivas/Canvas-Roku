sub init()
    ' print "DynamicRowList : Init"
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetControls()
    Initialize()
    SetObservers()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.top.itemComponentName = "DynamicItem"
    m.top.vertFocusAnimationStyle = "fixedFocus"
    m.top.rowFocusAnimationStyle = "fixedFocus"
    m.top.focusBitmapUri = "pkg:/images/focus/ring.9.png"
    m.top.focusBitmapBlendColor = m.theme.ThemeColor
    m.top.rowTitleComponentName = "RowTitleItem"
    m.top.rowLabelOffset = [[16, 10]]
    ' m.top.rowItemSpacing = [50, 0]
    m.top.focusxOffset = [0]
    m.top.numRows = 2
    m.top.showRowLabel = [true]
    m.top.drawFocusFeedback = true
end sub

sub SetControls()
    m.scene = m.top.GetScene()
end sub

sub SetupFonts()
end sub

sub SetupColors()
end sub

sub Initialize()
end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChild")
    m.top.observeField("rowItemFocused", "onRowItemFocused")
end sub


sub OnContentChanged(event as dynamic)
    content = event.getData()
    if m.top.width = invalid or m.top.width = 0 then m.top.width = 1920
    rowItemSize = []
    itemSize = []
    rowHeights = []
    rowItemSpacing = []
    rowSpacings = []
    if content.getChildCount() > 0
        for i = 0 to content.getChildCount() - 1 step 1
            item = content.getChild(i)
            rowItemSize.push(getRowItemSize(item))
            itemSize.push(getItemSize(item))
            rowHeights.push(getItemSize(item)[1])
            itemSpacing = getRowListItemSpacing(item)
            rowItemSpacing.push(itemSpacing)
            rowSpacings.push(itemSpacing[1])
        end for
    end if
    m.top.itemSize = itemSize[0]
    m.top.rowSpacings = rowSpacings
    m.top.rowItemSpacing = rowItemSpacing
    m.top.rowItemSize = rowItemSize
    m.top.rowHeights = rowHeights
    m.top.content = content
end sub

sub onPaginationContent(event as dynamic)
    print "onPaginationContent  ==>  " event.getData()
    content = event.getData()
    if content.Count() > 0
        for i = 0 to content.Count() - 1 step 1
            item = content[i]
            m.top.content.appendChild(item)
        end for
    end if
    m.top.jumpToRowItem = m.top.lastFocusItem
end sub

sub onPaginationRowContent(event as dynamic)
    print "onPaginationRowContent  ==>  " event.getData()
    content = event.getData()
    if content.Count() > 0
        for i = 0 to content.Count() - 1 step 1
            item = content[i]
            m.top.content.getChild(m.top.paginationRowFocusIndex).appendChild(item)
        end for
    end if
end sub

sub onRowItemFocused(event as dynamic)
    m.top.lastFocusItem = event.getData()
end sub

function getRowItemSize(content)
    program_type = LCase(content.program_type)
    if program_type = "movie" or program_type = "movies"
        rowItemSize = [292, 438]
    else if program_type = "event" or program_type = "events"
        rowItemSize = [560, 315]
    else if program_type = "video" or program_type = "videos"
        rowItemSize = [560, 315]
    else
        rowItemSize = [560, 315]
    end if
    return rowItemSize
end function

function getItemSize(content)
    program_type = LCase(content.program_type)
    if program_type = "movie" or program_type = "movies"
        itemSize = [m.top.width, 468]
    else if program_type = "event" or program_type = "events"
        itemSize = [m.top.width, 497.27]
    else if program_type = "video" or program_type = "videos"
        itemSize = [m.top.width, 497.27]
    else
        itemSize = [m.top.width, 497.27]
    end if
    return itemSize
end function

function getRowListItemSpacing(content)
    program_type = LCase(content.program_type)
    if program_type = "movie" or program_type = "movies"
        itemSpacing = [30, 43]
    else if program_type = "event" or program_type = "events"
        itemSpacing = [30, 43]
    else if program_type = "video" or program_type = "videos"
        itemSpacing = [30, 56]
    else
        itemSpacing = [30, 56]
    end if
    return itemSpacing
end function
