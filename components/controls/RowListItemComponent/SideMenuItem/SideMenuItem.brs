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
    m.lTitle = m.top.findNode("lTitle")
    m.lgLabel = m.top.findNode("lgLabel")
    m.rItemBackground = m.top.findNode("rItemBackground")
end sub

sub SetupFonts()
end sub

sub SetupColor()
end sub

sub itemContentChanged(event as dynamic)
    itemContent = event.getData()
    if itemContent.sub_title <> invalid and itemContent.sub_title <> ""
        CreateSubTitleLabel(itemContent)
        subTitleBoudingRect = m.lSubTitle.boundingRect()
        m.lTitle.width = [336 - 20 - subTitleBoudingRect.width]
    end if
    m.lTitle.text = itemContent.TITLE
    if itemContent.isFocused
        m.rItemBackground.color = m.theme.FocusedListBackground
        m.lTitle.color = m.theme.FocusedListTextColor
        m.rItemBackground.opacity = 1
        m.lTitle.font = m.fonts.robotoMed30
    else
        m.lTitle.font = m.fonts.robotoReg30
        if itemContent.isSelected
            m.rItemBackground.color = m.theme.SelectedListBackground
            m.lTitle.color = m.theme.SelectedListTextColor
            m.rItemBackground.opacity = 1
        else
            m.lTitle.color = m.theme.UnFocusedListTextColor
            m.rItemBackground.opacity = 0
        end if
    end if

    if itemContent.is_show_separate <> invalid and itemContent.is_show_separate then
      CreateSeperator()
    end if
end sub

sub CreateSubTitleLabel(itemContent)
    if m.lSubTitle = invalid
        m.lSubTitle = CreateObject("roSGNode", "Label")
        m.lSubTitle.height = 84
        m.lSubTitle.maxLines = 1
        m.lSubTitle.horizAlign = "right"
        m.lSubTitle.vertAlign = "center"
        m.lgLabel.appendChild(m.lSubTitle)
    end if
    m.lSubTitle.text = itemContent.sub_title
    subTitleBoudingRect = m.lSubTitle.boundingRect()
    if subTitleBoudingRect.width > 100 then m.lSubTitle.width = 100
    if itemContent.isFocused
        m.lSubTitle.color = m.theme.FocusedListTextColor
        m.lSubTitle.font = m.fonts.robotoMed30
    else
        m.lSubTitle.font = m.fonts.robotoReg30
        if itemContent.isSelected
            m.lSubTitle.color = m.theme.SelectedListTextColor
        else
            m.lSubTitle.color = m.theme.UnFocusedListTextColor
        end if
    end if

end sub


sub CreateSeperator()
    if m.pSeperator = invalid
        m.pSeperator = CreateObject("roSGNode", "Poster")
        m.pSeperator.height = 4
        m.pSeperator.width = 384
        m.pSeperator.uri = "pkg:/images/others/Separator.png"
        m.pSeperator.translation = [0,94]
        m.top.appendChild(m.pSeperator)
    end if
end sub
