sub init()
    ' print "DynamicItem : Init"
    SetControls()
    SetObservers()
end sub

sub SetControls()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.scene = m.top.GetScene()
    m.categoryName = m.top.findNode("categoryName")
    m.categoryName.color = m.theme.EPGCategoryTextColor
    m.categoryName.font = m.fonts.robotoReg32
    m.focusCategoryName = m.top.findNode("focusCategoryName")
    m.focusCategoryName.color = m.theme.FocusedEPGCategoryTextColor
    m.focusCategoryName.font = m.fonts.robotoReg32
end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild","OnFocusedChild")
end sub

sub itemContentChanged(event as dynamic)
    itemContent = event.getData()
    m.categoryName.text = itemContent.TITLE
    m.focusCategoryName.text = itemContent.TITLE
    m.categoryName.translation = [0, (60 - m.categoryName.BoundingRect().height) / 2]
    m.focusCategoryName.translation = [0, (60 - m.focusCategoryName.BoundingRect().height) / 2]
end sub


sub onFocusChanged(msg)
end sub

sub onFocusPercentChange(msg)
    m.focusCategoryName.opacity = msg.getData()
    m.categoryName.opacity = 1 - msg.getData()
end sub

sub onGridFocusChange(msg)
end sub
