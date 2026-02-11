
sub init()
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColor()
end sub


sub SetControls()
  m.title = m.top.findNode("title")
  m.icon = m.top.findNode("icon")
end sub

sub SetLocals()
    m.fonts = m.global.fonts
    m.theme = m.global.appTheme

end sub

sub SetupFonts()
    m.title.font = m.fonts.robotoMed30
end sub


sub SetupColor()
    m.title.color = m.theme.MenuUnFocused
    m.icon.blendColor = m.theme.MenuUnFocused
end sub

sub itemContentChanged()
    itemContent = m.top.itemContent
    m.title.visible = false
    m.icon.uri = ""
    m.icon.visible = false
    if itemContent.title <> ""
        m.title.text = itemContent.title

        if itemContent.isSelected
            m.title.color = m.theme.MenuFocused
            'm.title.font = m.fonts.robotoMed30
        else
            m.title.color = m.theme.MenuUnFocused
            'm.title.font = m.fonts.robotoMed30
        end if
        m.title.visible = true
    else if itemContent.ICON <> ""
        m.icon.uri = itemContent.ICON
        if itemContent.isSelected
            m.icon.blendColor = m.theme.MenuFocused
        else
            m.icon.blendColor = m.theme.MenuUnFocused
        end if
        m.icon.visible = true
    end if

end sub

sub OnWidthChanged()
    m.title.width = m.top.width
end sub
