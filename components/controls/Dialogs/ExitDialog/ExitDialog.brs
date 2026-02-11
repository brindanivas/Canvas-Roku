'setting top interfaces
sub Init()
    ' print "ExitDialog : Init"
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColor()
    SetObservers()
    m.showAnimation.control = "start"
end sub

sub SetLocals()
    m.fonts = m.global.fonts
    m.theme = m.global.appTheme
end sub

sub SetControls()
    m.rBackground = m.top.findNode("rBackground")
    m.pImage = m.top.findNode("pImage")
    m.message = m.top.findNode("message")
    m.lgButtons = m.top.findNode("lgButtons")
    m.bNo = m.top.findNode("bNo")
    m.bYes = m.top.findNode("bYes")
    m.lNo = m.top.findNode("lNo")
    m.lYes = m.top.findNode("lYes")
    m.showAnimation = m.top.findNode("showAnimation")

    m.buttons = []
    m.buttons.push(m.bNo)
    m.buttons.push(m.bYes)
end sub

sub SetupFonts()
    m.message.font = m.fonts.robotoReg32
    m.lNo.font = m.fonts.robotoBold32
    m.lYes.font = m.fonts.robotoBold32
end sub

sub SetupColor()
    m.message.color = m.theme.White
    m.lNo.color = m.theme.Black
    m.lYes.color = m.theme.Black
    m.bNo.blendColor = m.theme.White
    m.bYes.blendColor = m.theme.ThemeColor
end sub

sub SetObservers()
    m.top.observeField("focusedChild", "OnFocusedChild")
end sub

sub onIsResumeBoxChanged()
    if m.top.isresumebox
        m.pImage.width = 560
        m.pImage.height = 315
        m.pImage.translation = [680,270]
        m.message.translation = [0,650]
        m.bYes.width = 400
        m.lYes.width = 400
        m.bNo.width = 400
        m.lNo.width = 400
        m.lgButtons.translation = [560,800]
    end if
end sub

sub onPosterImageChanged()
      print "m.top.posterURL > " m.top.posterURL
      if m.top.posterURL <> invalid AND m.top.posterURL <> ""
          m.pImage.loadingBitmapUri="pkg:/images/others/default_poster.png"
          m.pImage.failedBitmapUri="pkg:/images/others/default_poster.png"
          m.pImage.uri = m.top.posterURL
      end if
end sub

sub setButton(index as object, selected as boolean)
    if selected
        m.currentBtn = index
        m.buttons[index].opacity = 1
        m.buttons[index].setFocus(true)
    else
        m.buttons[index].opacity = 0.5
    end if
end sub

sub OnFocusedChild()
    if m.top.hasFocus()
        setButton(0, true)
        setButton(1, false)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ' print "ExitDialog : Key = " key " Press = " press
        if key = "back"
            if m.top.isResumeBox
                m.top.selectedButton = 2
            else
                m.top.selectedButton = 0
            end if
        else if key = "OK"
            m.top.selectedButton = m.currentBtn
        else if key = "left"
            if m.bYes.hasFocus()
                setButton(0, true)
                setButton(1, false)
            end if
        else if key = "right"
            if m.bNo.hasFocus()
                setButton(1, true)
                setButton(0, false)
            end if
        end if
    end if

    return true
end function
