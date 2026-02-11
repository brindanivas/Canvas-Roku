sub init()
    SetLocals()
    SetControls()
end sub

sub SetLocals()
    m.fonts = m.global.Fonts
    m.theme = m.global.appTheme
end sub

sub SetControls()
    m.message = m.top.findNode("message")
    m.messageBackground = m.top.findNode("messageBackground")
    m.messageShowAnimation = m.top.findNode("messageShowAnimation")
    m.messageIcon = m.top.findNode("messageIcon")
end sub

sub onQuickHideChanged()
    if (m.top.quickHide = true and m.messageShowAnimation.state <> "stopped") then
        m.messageShowAnimation.control = "finish"
    end if
    m.top.quickHide = false
end sub

sub onMessageChanged()
    setData = m.top.msgData

    m.messageBackground.width = setData.width
    m.messageBackground.height = setData.height
    m.messageBackground.translation = setData.translation
    m.messageBackground.blendColor = m.theme.ThemeColor

    m.messageIcon.uri = setData.iconURI
    m.messageIcon.width = setData.iconWidth
    m.messageIcon.height = setData.iconHeight
    m.messageIcon.translation = [15,(setData.height - setData.iconHeight)/2]

    m.message.width = 0
    m.message.text = setData.message
    m.message.font = m.fonts.robotoReg22
    m.message.color = setData.messageColor

    if m.message.boundingRect().width > (setData.width - setData.iconWidth - 45) then
        m.message.wrap = true
        m.message.maxLines = 2
    else
        m.message.maxLines = 1
        m.message.wrap = false
    end if

    m.message.width = setData.width - setData.iconWidth - 45
    m.message.height = setData.height
    m.message.translation = [15 + setData.iconWidth + 15 ,0]

    m.messageShowAnimation.duration = setData.toastDuration
    m.messageShowAnimation.easeFunction = "linear"
    if (setData.message <> Invalid AND setData.message <> "")
        if (m.messageShowAnimation.state <> "stopped") then
            m.messageShowAnimation.control = "finish"
        end if
        m.messageBackground.opacity = 0
        m.messageShowAnimation.control = "start"
    end if
end sub
