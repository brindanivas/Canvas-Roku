sub init()
    ' print "SettingPage : Init"
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetControls()
    SetObservers()
end sub

sub SetLocals()
    m.scene = m.top.GetScene()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
end sub

sub SetControls()
    m.scene = m.top.GetScene()
    m.backGround = m.top.findNode("backGround")
    m.lgMain = m.top.findNode("lgMain")
    m.settingMenu = m.top.findNode("settingMenu")
    m.pQRCode = m.top.findNode("pQRCode")
    m.lgDescription = m.top.findNode("lgDescription")
    m.lDescription = m.top.findNode("lDescription")
    m.lUrl = m.top.findNode("lUrl")
    m.gInfo = m.top.findNode("gInfo")
    m.lDeviceId = m.top.findNode("lDeviceId")
    m.lVersionNo = m.top.findNode("lVersionNo")   
    
    m.lgPrivacySettings = m.top.findNode("lgPrivacySettings")   
    m.lTitle = m.top.findNode("lTitle")   
    m.lPSDescription = m.top.findNode("lPSDescription")   
    m.bLetsGo = m.top.findNode("bLetsGo")   
    m.lLetsGo = m.top.findNode("lLetsGo")   
    
    drawingStyles = {
        "keyTitle":{
            "fontUri": "pkg:/Fonts/Roboto-Bold.ttf",
            "fontSize":25,
            "color": m.theme.ThemeColor
        },
        "keyValue": {
            "fontUri": "pkg:/Fonts/Roboto-Regular.ttf",
            "fontSize":25,
            "color": m.theme.White
        }
    }
    m.lDeviceId.drawingStyles = drawingStyles
    m.lVersionNo.drawingStyles = drawingStyles
    versionNo = GetAppVersions()
    deviceId = CreateObject("roDeviceInfo").GetChannelClientId()
    m.lDeviceId.text = "<keyTitle>Device ID: </keyTitle><keyValue>"+deviceId+"</keyValue>"
    m.lVersionNo.text = "<keyTitle>App Version: </keyTitle><keyValue>"+versionNo+"</keyValue>"
    gInfoBound = m.gInfo.BoundingRect()
    m.gInfo.translation = [(1920-gInfoBound.width) - 20, (1080-gInfoBound.height) - 20]
end sub

sub SetupFonts()
    m.lDescription.font = m.fonts.robotoReg36
    m.lUrl.font = m.fonts.robotoReg36
    m.lDeviceId.font = m.fonts.robotoReg42
    m.lVersionNo.font = m.fonts.robotoReg42
    
    m.lTitle.font = m.fonts.robotoBold32
    m.lPSDescription.font = m.fonts.robotoReg32
    m.lLetsGo.font = m.fonts.robotoBold32
end sub

sub SetupColors()
    m.lDescription.color = m.theme.White
    m.lUrl.color = m.theme.ThemeColor
    m.lDeviceId.color = m.theme.White
    m.lVersionNo.color = m.theme.White
    
    m.bLetsGo.blendColor = m.theme.ThemeColor
    m.lTitle.color = m.theme.White
    m.lPSDescription.color = m.theme.White
    m.lLetsGo.color = m.theme.White
end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild","OnFocusedChild")
    m.settingMenu.observeField("itemSelected","onItemSelectedChanged")
    m.bLetsGo.observeField("focusedChild","onLetGoButtonFocusChildChanged")
end sub

sub onInitialize(event as dynamic)
    initialize = event.GetData()
    if initialize
        if m.settingMenu.content <> invalid
            SetFocus(m.settingMenu)
        end if
    end if
end sub

sub OnContentChange(event as dynamic)
    content = event.getData()
    m.settingMenu.content = content
end sub

sub OnVisibleChange(event as dynamic)
    isVisible = event.getData()
    print "SettingPage : OnVisibleChange : isVisible : " isVisible
end sub

sub OnFocusedChild()
    if m.top.hasFocus()
        isRestored = RestoreFocus()
        if not isRestored
            if m.lgMain <> invalid and m.lgMain.visible
                SetFocus(m.bLetsGo)
            else if m.settingMenu.content <> invalid
                SetFocus(m.settingMenu)
            end if
        end if
    end if
end sub

sub onLetGoButtonFocusChildChanged()
    if m.bLetsGo <> invalid and m.bLetsGo.hasFocus()
        print "SettingPage : onLetGoButtonFocusChildChanged : Lets Go button has focus"
        m.bLetsGo.blendColor = m.theme.ThemeColor
    else
        print "SettingPage : onLetGoButtonFocusChildChanged : Lets Go button does not have focus"
        m.bLetsGo.blendColor = m.theme.black
    end if
end sub

function onItemSelectedChanged(event as dynamic)
    index = event.getData()
    item = m.settingMenu.content.getChild(index)
    if item <> invalid
        if item.title = "Privacy Settings"
            m.lgPrivacySettings.visible = true
            m.lgMain.visible = false
            SetFocus(m.bLetsGo)
        else
            m.lgPrivacySettings.visible = false    
            m.lgMain.visible = true    
            SetContent(item)
        end if
    end if
end function

function SetContent(item)
  print "SettingPage : SetContent : item = " item
  m.pQRCode.uri = "https://api.qrserver.com/v1/create-qr-code/?size=345X345&data="+item.Url
  m.lDescription.text = item.Description
  m.lUrl.text = item.url
  descriptionBoudingRect = m.lDescription.boundingRect()
  urlBoudingRect = m.lUrl.boundingRect()
  yPos = (m.pQRCode.height - (descriptionBoudingRect.height + urlBoudingRect.height + m.lgDescription.itemSpacings[0])) / 2
  m.lgDescription.translation = [0, yPos]
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        print "SettingPage : onKeyEvent : key = " key " press = " press
        if key = "left"
            if m.bLetsGo <> invalid and m.bLetsGo.hasFocus() and m.lgPrivacySettings <> invalid and m.lgPrivacySettings.visible
                SetFocus(m.settingMenu)
            end if
        else if key = "right"
            if m.settingMenu.content <> invalid and m.lgPrivacySettings <> invalid and m.lgPrivacySettings.visible
                SetFocus(m.bLetsGo)
            end if
        else if key = "OK"
            if m.bLetsGo <> invalid and m.bLetsGo.hasFocus() and m.lgPrivacySettings <> invalid and m.lgPrivacySettings.visible
                m.scene.callFunc("ShowPreferenceCenter")
            end if
            result = true
        end if
    end if
    return result
end function
