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
    m.rowLabel = m.top.findNode("rowLabel")
end sub

sub SetupFonts()
    m.rowLabel.font = m.fonts.robotoBold30
end sub

sub SetupColor()
    m.rowLabel.color =  m.theme.White
end sub

sub itemContentChanged(event as dynamic)
    content = event.getData()
    m.rowLabel.text = content.TITLE
end sub
