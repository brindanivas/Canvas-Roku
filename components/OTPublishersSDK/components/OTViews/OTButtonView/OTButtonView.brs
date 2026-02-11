function init() as void
    try
        m.screenSize = m.global.screenSize
        m.style = style()
        m.getNode = getNode()
        m.buttonLayout = m.top.findNode("buttonLayout")
        m.bText = m.top.findNode("bText")
        m.bimage = m.top.findNode("bimage")
        m.bBorderimage = m.top.findNode("bBorderimage")
        m.statusImage = m.top.findNode("statusImage")
        m.statusText = m.top.findNode("statusText")
        m.btnPosterRec = m.top.findNode("btnPosterRec")
        m.sectionDivider = m.top.findNode("sectionDivider")

        ' m.rightArrow = m.top.findNode("rightArrow")

        m.top.observeField("focusedChild", "onfocusedChild")
    catch e
        ? "ERROR in OTButtonView init: "; e.message
    end try
end function

'***********************************************************************
'* onItemContentChanged()
'***********************************************************************
function itemContentChanged() as void
    try
        itemPading = m.style.buttonPadding
        m.itemContent = m.top.itemContent
        if isValid(m.itemContent)
            m.top.id = m.itemContent.id
            width = m.top.width
            height = m.top.height
            m.buttonLayout.itemSpacings = [m.style.button.itemSpacing]

            width = width - itemPading[0] - itemPading[3]

            m.bText.visible = false
            m.bText.scale = [0, 0]
            if isString(m.itemContent.text)
                m.bText.visible = true
                m.bText.scale = [1, 1]
                if isValid(m.itemContent.horizAlign) then m.bText.horizAlign = m.itemContent.horizAlign
                if isValid(m.itemContent.fonts) and isValid(m.itemContent.fonts.description) then m.bText.font = m.itemContent.fonts.description
                if isValid(m.itemContent.textColor) then m.bText.color = m.itemContent.textColor
                if isValid(m.itemContent.maxlines) then m.bText.maxlines = m.itemContent.maxlines
                if isString(m.itemContent.text) then m.bText.text = m.itemContent.text
            end if

            m.statusImage.visible = false
            m.statusImage.scale = [0, 0]
            if m.itemContent.Btype = "checkBox" and (m.itemContent.status = 0 or m.itemContent.status = 1)
                if m.itemContent.id = "iabFilterList" or m.itemContent.id = "sdkFilterList"
                    m.buttonLayout.removeChildIndex(2) ' Remove btnPosterRec
                    m.buttonLayout.insertChild(m.btnPosterRec, 0) ' Add at start
                end if
                if isValid(m.itemContent.status) then m.top.status = m.itemContent.status
                m.statusImage.visible = true
                m.statusImage.scale = [1, 1]
                m.statusImage.loadwidth = m.style.checkbox.size
                m.statusImage.loadheight = m.style.checkbox.size
                m.statusImage.width = m.style.checkbox.size
                m.statusImage.height = m.style.checkbox.size
                maxWidth = width - (2 * m.buttonLayout.itemSpacings[0]) - m.statusImage.width
                width = m.bText.boundingRect().width
                if maxWidth <= width then width = maxWidth
            end if

            if m.itemContent.id = "vendorListTextBtn" or m.itemContent.id = "viewIllustrations" or m.itemContent.id = "sdkListTextBtn" or m.itemContent.id = "iabVendorsBtn" or m.itemContent.id = "googleVendorsBtn" or m.itemContent.id = "vendorsPolicyBtn" or m.itemContent.id = "legIntClaimPolicyBtn"
                m.statusImage.visible = true
                m.statusImage.scale = [1, 1]
                m.statusImage.uri = "pkg:/components/OTPublishersSDK/images/arrow_forward.png"
                m.statusImage.loadwidth = m.style.checkbox.size
                m.statusImage.loadheight = m.style.checkbox.size
                m.statusImage.width = m.style.checkbox.size
                m.statusImage.height = m.style.checkbox.size
                m.buttonLayout.itemSpacings = [m.buttonLayout.itemSpacings[0], 0]
                width = width - m.buttonLayout.itemSpacings[0] - m.statusImage.width
            end if

            if m.itemContent.id = "filterIcon"
                m.statusImage.visible = true
                m.statusImage.scale = [1, 1]
                m.statusImage.uri = "pkg:/components/OTPublishersSDK/images/filter.png"
                m.statusImage.loadwidth = m.style.filter.size
                m.statusImage.loadheight = m.style.filter.size
                m.statusImage.width = m.style.filter.size
                m.statusImage.height = m.style.filter.size
            end if

            if m.itemContent.id = "textFilter" or m.itemContent.id = "filterIcon"
                filterPadding = m.style.filter.padding
                if m.itemContent.id = "filterIcon" then filterPadding = m.style.filter.filterPadding
                m.buttonLayout.itemSpacings = [0]
                itemPading = [filterPadding[0], filterPadding[1], filterPadding[1], filterPadding[0]]
                width = m.top.width - itemPading[0] - itemPading[3]
            end if

            m.statusText.visible = false
            m.statusText.scale = [0, 0]
            if m.itemContent.Btype = "checkBoxText" and m.itemContent.status >= 0
                m.statusText.visible = true
                m.statusText.scale = [1, 1]

                m.statusImage.visible = true
                m.statusImage.scale = [1, 1]
                m.statusImage.uri = "pkg:/components/OTPublishersSDK/images/arrow_forward.png"
                m.statusImage.loadwidth = m.style.checkbox.size
                m.statusImage.loadheight = m.style.checkbox.size
                m.statusImage.width = m.style.checkbox.size
                m.statusImage.height = m.style.checkbox.size

                m.statusText.width = 120
                if m.itemContent.status = 2 and isValid(m.itemContent.alwaysActiveNode) and isString(m.itemContent.alwaysActiveNode.text)
                    m.statusText.text = m.itemContent.alwaysActiveNode.text
                end if
                if m.itemContent.status = 1 and isValid(m.itemContent.activeTextNode) and isString(m.itemContent.activeTextNode.text)
                    m.statusText.text = m.itemContent.activeTextNode.text
                end if
                if m.itemContent.status = 0 and isValid(m.itemContent.inActiveTextNode) and isString(m.itemContent.inActiveTextNode.text)
                    m.statusText.text = m.itemContent.inActiveTextNode.text
                end if
                width = width - (2 * m.buttonLayout.itemSpacings[0]) - m.statusText.width - m.statusImage.width
            end if

            if isString(m.itemContent.text)
                m.bText.width = width
                if m.statusImage.visible
                    bheight = m.bText.boundingRect().height
                    m.statusText.height = bheight
                    m.statusImage.translation = [m.statusImage.translation[0], (bheight - m.statusImage.height - m.style.button.arrowAdj) / 2]
                end if
                if m.top.height <> 0
                    parentNode = m.top.getParent()
                    if isValid(parentNode) and parentNode.id = "buttonList" then m.bText.height = m.top.height - itemPading[1] - itemPading[2]
                end if
            end if

            height = m.buttonLayout.boundingRect().height + itemPading[1] + itemPading[2]
            m.buttonLayout.translation = [itemPading[0], itemPading[1]]

            m.bimage.visible = false
            m.bimage.scale = [0, 0]
            m.bBorderimage.visible = false
            m.bBorderimage.scale = [0, 0]
            if m.itemContent.id = "backButton" or (m.itemContent.id = "closeButton" and m.itemContent.Btype = "circleBtn")
                m.bBorderimage.visible = true
                m.bBorderimage.scale = [1, 1]
                m.bBorderimage.uri = "pkg:/components/OTPublishersSDK/images/circleBorder.png"
                m.bBorderimage.loadwidth = m.top.width
                m.bBorderimage.loadheight = m.top.height
                m.bBorderimage.width = m.top.width
                m.bBorderimage.height = m.top.height

                m.bimage.scale = [1, 1]
                m.bimage.uri = "pkg:/components/OTPublishersSDK/images/circle.png"
                m.bimage.loadwidth = m.top.width
                m.bimage.loadheight = m.top.height
                m.bimage.width = m.top.width
                m.bimage.height = m.top.height

                m.buttonLayout.itemSpacings = [0]
                m.buttonLayout.translation = [0, 0]
                m.statusImage.visible = true
                m.statusImage.scale = [1, 1]
                m.statusImage.uri = "pkg:/components/OTPublishersSDK/images/back.png"
                if (m.itemContent.id = "closeButton" and m.itemContent.Btype = "circleBtn") then m.statusImage.uri = "pkg:/components/OTPublishersSDK/images/cross.png"
                m.statusImage.loadwidth = m.top.width
                m.statusImage.loadheight = m.top.height
                m.statusImage.width = m.top.width
                m.statusImage.height = m.top.height

            else
                m.bimage.visible = true
                m.bimage.scale = [1, 1]
                m.bimage.loadwidth = m.top.width
                m.bimage.loadheight = height
                m.bimage.width = m.top.width
                m.bimage.height = height
                if isValid(m.itemContent.border) and m.itemContent.border
                    m.bBorderimage.visible = true
                    m.bBorderimage.scale = [1, 1]
                    m.bBorderimage.loadwidth = m.top.width
                    m.bBorderimage.loadheight = height
                    m.bBorderimage.width = m.top.width
                    m.bBorderimage.height = height
                end if
            end if

            m.sectionDivider.visible = false
            if isBoolean(m.itemContent.showDivider) and m.itemContent.showDivider
                m.sectionDivider.visible = true
                m.sectionDivider.width = m.top.width
                if isString(m.itemContent.descriptionColor) then m.sectionDivider.color = m.itemContent.descriptionColor
                m.sectionDivider.translation = [0, height + m.style.buttonspacing]
            end if
            setBtnColors()
        end if
    catch e
        ? "ERROR in itemContentChanged: "; e.message
    end try
end function

'***********************************************************************
'* onItemHasFocusChanged()
'***********************************************************************
function updateFocus() as void
    try
        setBtnColors()
        if isValid(m.top.focusPercent) and isBoolean(m.top.gridHasFocus) and m.top.focusPercent > 0.5 and m.top.gridHasFocus
            if (m.itemContent.id = "vendorsPolicyBtn" or m.itemContent.id = "legIntClaimPolicyBtn") and m.top.itemUnfocused
                m.top.itemUnfocused = false
            end if
            if m.itemContent.id = "backButton" or (m.itemContent.id = "closeButton" and m.itemContent.Btype = "circleBtn") then m.bimage.visible = true
            if isValid(m.itemContent) and isValid(m.itemContent.focusButtonColor) then m.bimage.blendColor = m.itemContent.focusButtonColor
            if isValid(m.itemContent) and isValid(m.itemContent.focusButtonTextColor)
                m.bBorderimage.blendColor = m.itemContent.focusButtonTextColor
                temBlendColor = m.itemContent.focusButtonTextColor
                m.statusImage.blendColor = temBlendColor
                m.bText.color = m.itemContent.focusButtonTextColor
                if m.statusText.visible then m.statusText.color = m.itemContent.focusButtonTextColor
            end if
            '  if m.rightArrow.visible then m.rightArrow.blendColor = m.itemContent.focusButtonTextColor
        end if
    catch e
        ? "ERROR in updateFocus: "; e.message
    end try
end function

function setBtnColors()
    try
        if m.itemContent.id = "backButton" or (m.itemContent.id = "closeButton" and m.itemContent.Btype = "circleBtn") then m.bimage.visible = false
        if isValid(m.itemContent) and isValid(m.itemContent.color) then m.bimage.blendColor = m.itemContent.color
        if isValid(m.itemContent) and isValid(m.itemContent.textColor)
            m.bBorderimage.blendColor = m.itemContent.textColor
            temBlendColor = m.itemContent.textColor
            m.statusImage.blendColor = temBlendColor
            m.bText.color = m.itemContent.textColor
            if m.statusText.visible then m.statusText.color = m.itemContent.textColor
        end if
        '  if m.rightArrow.visible then m.rightArrow.blendColor = m.itemContent.textColor
        if (m.itemContent.id = "childItems" or m.itemContent.id = "viewIllustrations" or m.itemContent.id = "vendorsPolicyBtn" or m.itemContent.id = "legIntClaimPolicyBtn") and m.top.itemUnfocused
            setItemUnfocused()
        else if m.itemContent.id = "filterIcon" and m.itemContent.itemUnfocused
            setItemUnfocused()
        else if (m.itemContent.id = "textFilter" or m.itemContent.id = "filterIcon" or m.itemContent.id = "iab" or m.itemContent.id = "google") and m.itemContent.status = 1
            setItemUnfocused()
        end if
    catch e
        ? "ERROR in setBtnColors: "; e.message
    end try
end function

function onfocusedChild()
    try
        if m.top.hasFocus()
            m.top.gridHasFocus = true
            m.top.focusPercent = 1
        else
            m.top.gridHasFocus = false
            m.top.focusPercent = 0
        end if
    catch e
        ? "ERROR in onfocusedChild: "; e.message
    end try
end function

function setStatus()
    try
        statusUri = "pkg:/components/OTPublishersSDK/images/checkbox-unselected.png"
        isStatus = m.top.status = 1
        if m.itemContent.id = "activeTextCheckBox" or m.itemContent.id = "inActiveTextCheckBox"
            isStatus = (m.top.status = 1 and m.itemContent.id = "activeTextCheckBox") or (m.top.status = 0 and m.itemContent.id = "inActiveTextCheckBox")
        end if
        if isStatus then statusUri = "pkg:/components/OTPublishersSDK/images/checkbox-selected.png"
        m.statusImage.uri = statusUri
    catch e
        ? "ERROR in setStatus: "; e.message
    end try
end function

function setItemUnfocused()
    try
        if m.itemContent.id = "childItems" or m.itemContent.id = "viewIllustrations" or m.itemContent.id = "vendorsPolicyBtn" or m.itemContent.id = "legIntClaimPolicyBtn" or (m.itemContent.id = "filterIcon" and m.itemContent.itemUnfocused)
            if isValid(m.itemContent) and isValid(m.itemContent.focusButtonColor) then m.bimage.blendColor = m.itemContent.focusButtonColor
            if isValid(m.itemContent) and isValid(m.itemContent.focusButtonTextColor)
                m.bText.color = m.itemContent.focusButtonTextColor
                m.statusImage.blendColor = m.itemContent.focusButtonTextColor
                m.statusText.color = m.itemContent.focusButtonTextColor
            end if
        else if m.itemContent.Btype = "listViewRectangle" or m.itemContent.id = "textFilter" or m.itemContent.id = "filterIcon" or m.itemContent.id = "iab" or m.itemContent.id = "google"
            if isValid(m.itemContent) and isValid(m.itemContent.activeColor) then m.bimage.blendColor = m.itemContent.activeColor
            if isValid(m.itemContent) and isValid(m.itemContent.activeTextColor)
                m.bBorderimage.blendColor = m.itemContent.activeTextColor
                m.bText.color = m.itemContent.activeTextColor
                m.statusImage.blendColor = m.itemContent.activeTextColor
            end if
        end if
    catch e
        ? "ERROR in setItemUnfocused: "; e.message
    end try
end function