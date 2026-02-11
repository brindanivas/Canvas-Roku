sub init()
    ' print "DynamicMakupGrid : Init"
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
    m.top.vertFocusAnimationStyle="fixedFocus"
    m.top.horizFocusAnimationStyle="floatingFocus"
    m.top.focusBitmapUri = "pkg:/images/focus/ring.9.png"
    m.top.focusBitmapBlendColor = m.theme.ThemeColor

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
    m.top.observeField("focusedChild","OnFocusedChild")
    m.top.observeField("itemFocused","onItemFocused")
end sub


sub OnContentChanged(event as dynamic)
    content = event.getData()
    count = content.getChildCount()
    if count > 0
        if m.top.columns = invalid or m.top.columns = 0 then
           m.top.numColumns = getDefaultNumberOfColoums(content)
        else
           m.top.numColumns = m.top.columns
        end if
        if m.top.rows = invalid or m.top.rows = 0 then
           numColumns = m.top.numColumns
           numRows = INT(count / numColumns)
           if numRows * numColumns < count then numRows++
           m.top.numRows = numRows
        else
           m.top.numRows = m.top.rows
        end if

        rowHeights = []
        rowHeight = getMarkUpGridRowHeight(content)
        for i=0 to m.top.numRows - 1 step 1
          rowHeights.push(rowHeight)
        end for
        m.top.rowHeights = rowHeights
        m.top.itemSize = getMarkUpGridItemSize(content)
        itemSpacing = getMarkuGridItemSpacing(content)
        m.top.itemSpacing =  [ itemSpacing[0], m.top.itemSize[1] - rowHeight + itemSpacing[1]]
        m.top.content = content
    end if
end sub

sub onPaginationContent(event as dynamic)
    content = event.getData()
    for i=0 to content.Count()-1
        m.top.content.appendChild(content[i])
    end for
    m.top.jumpToItem = m.lastFocusItem
end sub

sub onItemFocused(event as dynamic)
    m.lastFocusItem = event.getData()
end sub

function getDefaultNumberOfColoums(content)
    if LCase(content.program_type) = "movies"
        columns = 4
    else if LCase(content.program_type) = "event"
        columns = 2
    else if LCase(content.program_type) = "videos"
        columns = 2
    else
        columns = 2
    end if
    return columns
end function

function getDefaultNumberOfRows(content)
    if LCase(content.program_type) = "movies"
        rows = 2
    else if LCase(content.program_type) = "event"
        rows = 2
    else if LCase(content.program_type) = "videos"
        rows = 2
    else
        rows = 2
    end if
    return rows
end function

function getMarkUpGridRowHeight(content)
    if LCase(content.program_type) = "movies"
        rowHeight = 438
    else if LCase(content.program_type) = "event"
        rowHeight = 315
    else if LCase(content.program_type) = "video"
        rowHeight = 315
    else
        rowHeight = 315
    end if

    return rowHeight
end function

function getMarkUpGridItemSize(content)
      if LCase(content.program_type) = "movies"
          itemSize = [292, 438]
      else if LCase(content.program_type) = "event"
          itemSize = [560, 461.27]
      else if LCase(content.program_type) = "video"
          itemSize = [560, 497.27]
      else
          itemSize = [560, 497.27]
      end if
      return itemSize
end function

function getMarkuGridItemSpacing(content)
    if LCase(content.program_type) = "movies"
        itemSpacing = [85, 30]
    else if LCase(content.program_type) = "event"
        itemSpacing = [80, 24.73]
    else if LCase(content.program_type) = "video"
        itemSpacing = [60, 24.73]
    else
        itemSpacing = [60, 24.73]
    end if
    return itemSpacing
end function


function OnFocusedChild()
    ' print "OnFocusedChild "m.top.hasFocus() " "m.top.IsInFocusChain()

end function
