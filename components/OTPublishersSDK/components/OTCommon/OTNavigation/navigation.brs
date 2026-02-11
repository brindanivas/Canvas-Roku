function navigation1(key as string, press as boolean) as boolean
    handled = false
    m.key = key
    currentValue = m.navDirections.value[m.navDirections.key[0]][m.navDirections.key[1]]
    if press
        if key = m.navConstant.up
            navigateUP(key, press, currentValue)
            handled = true
        else if key = m.navConstant.down
            navigateDown(key, press, currentValue)
            handled = true
        else if key = m.navConstant.ok
            navigateOK(currentValue)
            handled = true
        else if key = m.navConstant.back
            if isValid(m.top.isChildScreen) and m.top.isChildScreen
                setChildBackButton(m.backButton.content.getchild(0))
            else
                closeOnetrustScreen(m.OTinitialize.OT_Data.view, m.OTinitialize)
            end if
            handled = true
        else if key = m.navConstant.left
            navigateLeft(key, press, currentValue)
            handled = true
        else if key = m.navConstant.right
            navigateRight(key, press, currentValue)
            handled = true
        end if
    else
        processLongKeyPress(press)
    end if
    return handled
end function

' Function to process button to long press
sub processLongKeyPress(press as boolean)
    if press ' key code for the button pressed
        scrollText()
        if m.scrollTimer <> invalid
            m.scrollTimer.control = "start"
            m.scrollTimer.duration = 0.4 ' Set the delay for the timer
            m.scrollTimer.repeat = true
            m.scrollTimer.observeField("fire", "scrollText")
        end if
    else ' key code for the button release
        if m.scrollTimer <> invalid
            m.scrollTimer.unObserveField("fire")
            m.scrollTimer.control = "stop"
        end if
        if m.gridScrollAnimation <> invalid then m.gridScrollAnimation.control = "finish"
        if m.gridScrollThumbAnimation <> invalid then m.gridScrollThumbAnimation.control = "finish"
    end if
end sub

function scrollText()
    currentValue = m.navDirections.value[m.navDirections.key[0]][m.navDirections.key[1]]
    nextvalue = invalid
    if currentValue.key = m.navConstant.scrollTextButton then nextvalue = m.nextvalue
    if not (((currentValue.key = m.navConstant.scrollText and currentValue.value.hasFocus()) or (currentValue.key = m.navConstant.scrollTextButton and (m.navDirections.scrollValue.isInFocusChain() or m.navDirections.scrollValue.hasFocus()))) and isScrollable(m.key, nextvalue))
        processLongKeyPress(false)
        navigation1(m.key, true)
    else
        scrollAnimation(60)
    end if

end function

function navController(key, press, currentValue, nextPath)
    if isValid(currentValue) and isValid(currentValue.value)
        if isValid(currentValue.redirect) and isValid(currentValue.redirect[key]) then nextPath = currentValue.redirect[key]
        if currentValue.value.visible
            iscurrentValueVisible = true
            if isValid(m.navDirections.scrollValue) and m.navDirections.scrollValue.isSameNode(currentValue.value) then iscurrentValueVisible = isValid(m.scrollThumb) and m.scrollThumb.visible
            if iscurrentValueVisible then m.navDirections.visiblePath = m.navDirections.key
        end if
        m.nextvalue = m.navDirections.value[nextPath[0]][nextPath[1]]
        if isValid(m.nextvalue) and isValid(m.nextvalue.value)
            if isValid(currentValue.allowPreviousPath) and currentValue.allowPreviousPath and isValid(m.nextvalue.accecptPreviousPath) and m.nextvalue.accecptPreviousPath
                m.navDirections.previousPath = m.navDirections.key
            else if isValid(m.nextvalue.allowPreviousPath) and m.nextvalue.allowPreviousPath and isValid(currentValue.accecptPreviousPath) and currentValue.accecptPreviousPath
                nextPath = m.navDirections.previousPath
                m.nextvalue = m.navDirections.value[nextPath[0]][nextPath[1]]
            end if
            if isValid(m.nextvalue) and isValid(m.nextvalue.value)
                if isValid(m.navDirections.scrollValue) and isValid(m.nextvalue.resetScroll) and m.nextvalue.resetScroll then resetScroll({ value: m.navDirections.scrollValue }, m.navDirections.resetValues)
                if not m.nextvalue.value.visible or (isValid(m.navDirections.scrollValue) and m.navDirections.scrollValue.isSameNode(m.nextvalue.value) and not (isValid(m.scrollThumb) and m.scrollThumb.visible)) or (isValid(m.nextvalue.skipSameNode) and m.nextvalue.skipSameNode and currentValue.value.isSameNode(m.nextvalue.value))
                    if currentValue.key = m.navConstant.scrollTextButton and (key = m.navConstant.up or key = m.navConstant.down) and (currentValue.value.isInFocusChain() or currentValue.value.hasFocus()) and isScrollable(key, m.nextvalue)
                        processLongKeyPress(press)
                    else
                        m.navDirections.key = nextPath
                        navigation1(key, press)
                    end if
                else
                    if currentValue.key = m.navConstant.scrollTextButton
                        if (key = m.navConstant.up or key = m.navConstant.down) and (currentValue.value.isInFocusChain() or currentValue.value.hasFocus()) and isScrollable(key, m.nextvalue)
                            processLongKeyPress(press)
                        else
                            if (currentValue.value.isInFocusChain() or currentValue.value.hasFocus()) and currentValue.key = m.navConstant.scrollTextButton
                                if m.scrollThumb <> invalid and m.scrollThumb.visible and not m.nextvalue.key = m.navConstant.scrollTextButton then setScrollOpacity(m.style.opacity)
                            end if
                            setfocusNode(m.nextvalue, nextPath, currentValue)
                        end if
                    else if currentValue.key = m.navConstant.button
                        if m.nextvalue.key = m.navConstant.scrollTextButton and m.scrollThumb <> invalid and m.scrollThumb.visible
                            setScrollOpacity(m.style.focusOpacity)
                        end if
                        setfocusNode(m.nextvalue, nextPath, currentValue)
                    end if
                end if
            end if
        else if currentValue.key = m.navConstant.scrollTextButton and (key = m.navConstant.up or key = m.navConstant.down) and (m.navDirections.scrollValue.isInFocusChain() or m.navDirections.scrollValue.hasFocus()) and isScrollable(key)
            processLongKeyPress(press)
        else
            m.navDirections.key = m.navDirections.visiblePath
        end if
    end if
end function

function getDefaultvalue(key, currentValue, resetValues)
    defaultBtn = invalid
    defaultPath = invalid
    if resetValues <> invalid and resetValues.count() > 0
        if key = m.navConstant.up
            for i = resetValues.count() - 1 to 0 step -1
                if isValid(resetValues[i]) and isValid(resetValues[i].value) and resetValues[i].value.visible
                    defaultBtn = resetValues[i].value
                    defaultPath = [0, i + 1]
                    exit for
                end if
            end for
        else
            for i = 0 to resetValues.count() - 1
                if isValid(resetValues[i]) and isValid(resetValues[i].value) and resetValues[i].value.visible
                    defaultBtn = resetValues[i].value
                    defaultPath = [0, i + 1]
                    exit for
                end if
            end for
        end if
    end if
    if (defaultBtn = invalid or defaultPath = invalid) and m.scrollThumb <> invalid and m.scrollThumb.visible
        defaultBtn = m.detailScreenlayoutScroll
        defaultPath = [1, 1]
    end if
    currentValue["default"] = defaultBtn
    currentValue["defaultPath"] = defaultPath
    return currentValue
end function

function resetScroll(currentValue, values = invalid)
    if currentValue <> invalid then currentValue.value.translation = [currentValue.value.translation[0], 0]
    if m.scrollThumb <> invalid then m.scrollThumb.translation = [m.scrollThumb.translation[0], 0]
    m.lastTranslation = [0, 0]
    m.lastThumbTranslation = [0, 0]
    if values <> invalid and values.count() > 0
        for each item in values
            if isValid(item) and isValid(item.value.reset) then item.value.reset = true
        end for
    end if
end function

function setScrollOpacity(opacity)
    if m.scrollThumb <> invalid then m.scrollThumb.opacity = opacity
end function

function setfocusNode(nextvalue, nextPath, currentValue = invalid, translation = invalid, itemfocused = invalid)
    if nextvalue <> invalid and nextvalue.value <> invalid and isValid(nextPath)
        m.navDirections.key = nextPath
        if isValid(translation)
            if isValid(m.OTConsentButtons) and m.OTConsentButtons.visible then m.OTConsentButtons.itemFocused = m.OTConsentButtons.content.getChildCount() - 1
            if isValid(m.OTAdditionalButtons) and m.OTAdditionalButtons.visible then m.OTAdditionalButtons.itemFocused = m.OTAdditionalButtons.content.getChildCount() - 1
            m.detailScreenlayoutScroll.translation = translation[0]
            m.lastTranslation = translation[0]
            if isValid(m.scrollThumb) and m.scrollThumb.visible
                m.scrollThumb.translation = translation[1]
                setScrollOpacity(m.style.focusOpacity)
            end if
            m.lastThumbTranslation = translation[1]

        end if
        if isValid(itemfocused) then nextvalue.value.itemFocused = itemfocused
        nextvalue.value.setFocus(true)
        if isValid(m.navDirections.visiblePath) and isValid(currentValue)
            previousNode = m.navDirections.value[m.navDirections.visiblePath[0]][m.navDirections.visiblePath[1]]
            if isValid(previousNode) and isValid(previousNode.value) and isValid(previousNode.value.jumpToItem) and isValid(previousNode.jumptoItem) then previousNode.value.jumpToItem = previousNode.jumptoItem
        end if
        setFocusWCAG(nextvalue.value)
    end if
end function

sub setFocusWCAG(node)
    if node.id = "OTConsentButtons"
        item = node.getChild(0).getChild(node.itemFocused)
        role = m.WCAGRoles.button
        role2 = m.WCAGRoles.selectedAriaLabel
        if isValid(item) and (item.id = "legitInterestCheckBox" or item.id = "consentCheckBox" or item.id = "activeTextCheckBox" or item.id = "inActiveTextCheckBox" or item.id = "iabFilterList" or item.id = "sdkFilterList")
            role = m.WCAGRoles.checkBoxDisabledAriaLabel
            if item.status = 1 then role = m.WCAGRoles.checkBoxEnabledAriaLabel
            role2 = ""
        end if
        if item.id = "iabFilterList" or item.id = "sdkFilterList"
            Mcount = node.content.getChildCount()
            itemFocused = node.itemFocused + 1
            role2 = itemFocused.toStr() + " of " + Mcount.toStr()
        end if
        saylayout(item, role, role2, true)
    else if node.id = "OTAdditionalButtons"
        saylayout(node.getChild(0).getChild(node.itemFocused), m.WCAGRoles.button, m.WCAGRoles.selectedAriaLabel, true)
    else if node.id = "OTPurposeChildButtons"
        role = ""
        if isValid(m.childHeading) then role = m.childHeading.text
        saySelected(node, role, true)
        'saylayout(node.getChild(0).getChild(node.itemFocused), m.WCAGRoles.button, m.WCAGRoles.selectedAriaLabel, true)
    else if node.id = "backButton"
        item = node.getChild(0).getChild(node.itemFocused)
        say(item.itemContent.subText, m.WCAGRoles.button, m.WCAGRoles.selectedAriaLabel, true)
    else if node.id = "detailScreenlayoutScroll" or node.id = "descriptionScrollRec"
        say(m.WCAGRoles.scroll, "", "", true)
    else if node.id = "OTListGridview"
        saySelected(node, m.WCAGRoles.listAriaLabel, true)
    end if
end sub