sub init()
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColor()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
end sub

sub SetControls()
    m.pMovie = m.top.findNode("pMovie")
    m.pVideoLock = m.top.findNode("pVideoLock")
    m.borderMask = m.top.findNode("borderMask")
end sub

sub SetupFonts()
end sub

sub SetupColor()
end sub

sub itemContentChanged(event as dynamic)
    content = event.getData()
    if content.poster_9_16_small <> invalid and  content.poster_9_16_small <> ""
        m.pMovie.uri = content.poster_9_16_small
    else 
        m.pMovie.uri = content.poster_9_16
    end if
    m.pVideoLock.visible = content.is_lock
    boudingRect = m.pMovie.boundingRect()
    maskSize = [boudingRect.width, boudingRect.height]
    if m.global.designresolution = "720p"
        maskSize = [maskSize[0] / 1.5, maskSize[1] / 1.5]
    end if
    m.borderMask.maskSize = maskSize
end sub
''
' Use focusPercent to scale the poster
''
function onFocusPercentChange()
    if m.top.gridHasFocus or m.top.rowListHasFocus
        num = 1 + (m.top.focusPercent * 0.1)
        itemFocused(num)
    else
        itemFocused(1)
    end if
end function

function onFocusChanged()
end function


''
' handle focus when markupgrid has focus
''
sub onGridFocusChange()
    if not m.top.gridHasFocus
        itemFocused(1)
    else
        if m.top.focusPercent = 1
            num = 1 + (m.top.focusPercent * 0.1)
            itemFocused(num)
        end if
    end if
end sub



sub onRowFocusPercentChange()
    ' print "onRowFocusPercentChange "event.getData()
end sub

sub onRowListFocusChange()
    if not m.top.rowListHasFocus
        itemFocused(1)
    else
        if m.top.focusPercent = 1
            num = 1 + (m.top.focusPercent * 0.1)
            itemFocused(num)
        end if
    end if
end sub

sub itemFocused(percent as float)
    if not m.top.gridHasFocus and not m.top.rowListHasFocus
        'we need to reset this to get the focus back
        m.top.focusPercent = 0
        ' m.scalingGroup.scale = [1,1]
    end if
end sub
