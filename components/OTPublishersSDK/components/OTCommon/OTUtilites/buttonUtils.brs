function getFooterContentNode(data)
    maxheight = 0
    buttonList = []
    rowHeights = []
    contentNode = CreateObject("roSGNode", "ContentNode")

    menuDividerID = ""
    if isValid(data.menuListNode) and isValid(m.top.viewType) and m.top.viewType <> "sdkList"
        if isValid(data.menuListNode.iabBtnNode) and isString(data.menuListNode.iabBtnNode.id) and m.top.viewType <> data.menuListNode.iabBtnNode.id 
            menuDividerID = data.menuListNode.iabBtnNode.id
            if m.top.viewType = menuDividerID then data.menuListNode.iabBtnNode.status = 1
            buttonList.push({position: 0, value: data.menuListNode.iabBtnNode})
        end if
        if isValid(data.menuListNode.googleBtnNode) and isValid(data.menuListNode.googleBtnNode.id) and m.top.viewType <> data.menuListNode.googleBtnNode.id 
            menuDividerID = data.menuListNode.googleBtnNode.id
            if m.top.viewType = menuDividerID then data.menuListNode.googleBtnNode.status = 1
            buttonList.push({position: 0, value: data.menuListNode.googleBtnNode})
        end if
    end if
    if isValid(data.savePreferencesButton) and isValid(data.savePreferencesButton.position) then buttonList.push({position: data.savePreferencesButton.position, value: data.savePreferencesButton})
    if isValid(data.acceptAll) and isValid(data.acceptAll.position) then buttonList.push({position: data.acceptAll.position, value: data.acceptAll})
    if isValid(data.rejectAll) and isValid(data.rejectAll.position) then buttonList.push({position: data.rejectAll.position, value: data.rejectAll})
    if isValid(data.showPreferences) and isValid(data.showPreferences.position) then buttonList.push({position: data.showPreferences.position, value: data.showPreferences})
    if isValid(data.vendorList) and isValid(data.vendorList.position) then buttonList.push({position: 5, value: data.vendorList})

    buttonList.SortBy("position")
    bcount = buttonList.count()
    bwidth = ((data.width) - ((bcount - 1) * m.style.buttonspacing)) / bcount
    if data.layout = "right" then bwidth = data.width
    i = 0
    rowSpacings=[]
    for each item in buttonList
        OTButtonView = CreateObject("roSGNode", "OTButtonView")
        OTButtonView.width = bwidth
        OTButtonView.itemContent = item.value
        height = OTButtonView.boundingRect().height
        rowHeights.push(height)
        if height > maxheight then maxheight = height
        if m.top.itemFocused <> invalid and item.value.id = "acceptAll"  then m.top.itemFocused = i
        if item.value.id = "savePreferencesButton" or item.value.id = menuDividerID
            item.value.showDivider = true
            rowSpacings.push(m.style.buttonspacing * 2)
        else
            rowSpacings.push(m.style.buttonspacing/2)
        end if
        contentNode.appendChild(item.value)
        i++
    end for
    return { contentNode: contentNode, height: maxheight, width: bwidth, rowHeights: rowHeights, rowSpacings: rowSpacings }
end function

function getCloseContentNode(data)
    contentNode = CreateObject("roSGNode", "ContentNode")
    OTButtonView = CreateObject("roSGNode", "OTButtonView")
    OTButtonView.width = (data.closeBtnRatio * data.Hwidth) - m.style.containerPaddingTop
    OTButtonView.itemContent = data.closeButton
    bsize = OTButtonView.boundingRect()
    contentNode.appendChild(data.closeButton)
    return { contentNode: contentNode, height: bsize.height, width: bsize.width, isclose: data.closeButton.Btype = "circleBtn" }
end function