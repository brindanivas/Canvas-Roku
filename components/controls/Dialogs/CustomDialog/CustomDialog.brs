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
    m.gConfirmation = m.top.findNode("gConfirmation")
    m.rBackground = m.top.findNode("rBackground")
    m.gPurchaseSection = m.top.findNode("gPurchaseSection")
    m.gDialog = m.top.findNode("gDialog")
    m.lgGroup = m.top.findNode("lgGroup")
    m.pImage = m.top.findNode("pImage")
    m.ltitle = m.top.findNode("ltitle")
    m.lMessage = m.top.findNode("lMessage")
    m.lConsentMsg = m.top.findNode("lConsentMsg")
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
    m.ltitle.font = m.fonts.robotoMed30
    m.lMessage.font = m.fonts.robotoReg32
    m.lConsentMsg.font = m.fonts.robotoBold32
    m.lNo.font = m.fonts.robotoBold32
    m.lYes.font = m.fonts.robotoBold32
end sub

sub SetupColor()
    m.ltitle.color = m.theme.White
    m.lMessage.color = m.theme.White
    m.lConsentMsg.color = m.theme.White
    m.lNo.color = m.theme.Black
    m.lYes.color = m.theme.Black
    m.bNo.blendColor = m.theme.White
    m.bYes.blendColor = m.theme.ThemeColor
    m.gPurchaseSection.blendColor = m.theme.baseColorDarkGray
end sub

sub SetObservers()
    m.top.observeField("focusedChild", "OnFocusedChild")
end sub

sub onContentNodeChanged()
    print "m.top.posterURL > " m.top.contentNode
    m.ltitle.text = ""
    m.lMessage.text = ""
    if m.top.contentNode <> invalid
        contentNode = m.top.contentNode
        if contentNode.poster_16_9 <> invalid and contentNode.poster_16_9 <> ""
            m.pImage.loadingBitmapUri = "pkg:/images/others/default_poster.png"
            m.pImage.failedBitmapUri = "pkg:/images/others/default_poster.png"
            m.pImage.uri = contentNode.poster_16_9
        end if
        m.ltitle.text = contentNode.title
        m.lMessage.text = contentNode.description
    end if
    SetTranslations()
end sub

sub SetTranslations()
    yPosition = 80
    itemSpace = 40
    xImagePos = (m.gPurchaseSection.width - m.pImage.width) / 2
    m.pImage.translation = [xImagePos, itemSpace]
    yPosition += m.pImage.BoundingRect().height

    m.ltitle.translation = [0, yPosition]
    yPosition += m.ltitle.BoundingRect().height + itemSpace

    m.lMessage.translation = [0, yPosition]
    yPosition += m.lMessage.BoundingRect().height + itemSpace

    m.lConsentMsg.translation = [0, yPosition]
    yPosition += m.lConsentMsg.BoundingRect().height + itemSpace

    lgButtons = m.lgButtons.BoundingRect()
    xLGButtons = (m.gPurchaseSection.width - lgButtons.width) / 2
    m.lgButtons.translation = [xLGButtons, yPosition]

    m.gPurchaseSection.height = yPosition + lgButtons.height + itemSpace
    detailSectionXPos = (1920 - m.gPurchaseSection.width) / 2
    detailSectionYPos = (1080 - m.gPurchaseSection.height) / 2
    m.gPurchaseSection.translation = [detailSectionXPos, detailSectionYPos]
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
        setButton(0, false)
        setButton(1, true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ' print "ExitDialog : Key = " key " Press = " press
        if key = "back"
            m.top.selectedButton = 0
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