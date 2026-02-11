sub init()
    ' print "LoadingPage : Init"
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
end sub

sub SetControls()
    m.rBackground = m.top.findNode("rBackground")
    m.lgMain = m.top.findNode("lgMain")
    m.p1 = m.top.findNode("p1")
    m.p2 = m.top.findNode("p2")
    m.p3 = m.top.findNode("p3")
    m.lLoading = m.top.findNode("lLoading")
    m.animation = m.top.findNode("animation")
end sub

sub SetupFonts()
    m.lLoading.font = m.fonts.robotoBold72
end sub

sub SetupColors()
    m.lLoading.color = m.theme.ThemeColor
end sub

sub Initialize()

end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild","OnFocusedChild")
end sub

sub OnVisibleChange(event as dynamic)
    isVisible = event.getData()
    if not isVisible and m.animation <> invalid
      m.animation.control = "stop"
    end if
end sub

sub onInitialize()
    m.rBackground.width = m.top.width
    m.rBackground.height = m.top.height
    if m.top.dotSize = 0
      m.top.dotSize = 20
    end if
    m.animation.control = "start"
end sub

sub onDotSizeChange(event as dynamic)
    dotSize = event.GetData()
    SetDotObject(m.p1, dotSize)
    SetDotObject(m.p2, dotSize)
    SetDotObject(m.p3, dotSize)

    boundingRect = m.lgMain.boundingRect()
    boundingRectLoading = m.lLoading.boundingRect()
    boundingRectP1 = m.p1.boundingRect()
    m.lgMain.translation = [(m.top.width - boundingRect.width)/2, (m.top.height - boundingRect.height) / 2 ]
    m.p1.translation = [0, (boundingRectLoading.height - boundingRectP1.height) - 5]
    m.p2.translation = [0, (boundingRectLoading.height - boundingRectP1.height) - 5]
    m.p3.translation = [0, (boundingRectLoading.height - boundingRectP1.height) - 5]
end sub

sub SetDotObject(node, dotSize)
  node.height = dotSize
  node.loadheight = dotSize
  node.width = dotSize
  node.loadWidth = dotSize
  node.blendColor = m.theme.ThemeColor
  node.loadDisplayMode="scaleToFit"
  node.uri="pkg:/images/loader/circleDot.png"
end sub
