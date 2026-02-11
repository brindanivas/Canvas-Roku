function itemSelectedHandler(data, OTinitialize = invalid)
    if isValid(data) and isValid(data.content) and isValid(data.itemSelected)
        contentData = data.content.getChild(data.itemSelected)
        if contentData.id <> "iab" and contentData.id <> "google"
            if contentData.interactionType <> invalid and contentData.interactionType <> ""
                eventinteractionType = contentData.interactionType
                if isString(contentData.eventinteractionType) then eventinteractionType = contentData.eventinteractionType
                eventListeners(m.OTinitialize.top.eventlistener, eventinteractionType, true, "click")
                saveLogConsent(contentData, m.OTinitialize)
                closeOnetrustScreen(m.OTinitialize.OT_Data.view, m.OTinitialize, contentData.interactionType)
            else
                if contentData.id = "showPreferences"
                    if OTinitialize <> invalid then OTinitialize.top.callFunc("showPreferenceCenterUI", true)
                end if
                if contentData.id = "vendorList"
                    if OTinitialize <> invalid then OTinitialize.top.callFunc("showVendorListUI", true)
                end if
            end if
        end if
    end if
end function

function itemFocusHandler(node, data)
    node.data = data
end function

function closeOnetrustScreen(view, otsdk, interactionType = invalid)
    'm.logger.set(m.errortype.Info + "." + m.errortype.Banner, m.errorTags.EventListener, m.constant.listener["ELB105"])
    viewChildCount = view.getChildCount()
    isOTClose = false
    onHide = ""
    currentView = view.getChild(viewChildCount - 1)
    if currentView.id = "OTBanner" then onHide = m.constant.listener["ELB105"]
    if currentView.id = "OTPreferenceCenter" then onHide = m.constant.listener["ELP110"]
    if currentView.id = "OTVendorList"
        if currentView.viewType = "sdkList" then eventName = m.constant.listener["ELS100"] else eventName = m.constant.listener["ELV100"]
        onHide = eventName
    end if
    onScreen = ""
    for i = viewChildCount to 1 step -1
        child = view.getChild(i - 1)
        if child <> invalid and (child.id.Instr("OTPreferenceCenter") <> -1 or child.id.Instr("OTVendorList") <> -1 or (child.id.Instr("OTBanner") <> -1 and interactionType <> invalid))
            view.removeChild(child)
            onDestroyView(child, interactionType)
            isOTClose = true
            if not isString(interactionType)
                ichild = view.getChild(i - 2)
                if ichild <> invalid and (ichild.id = "OTBanner" or ichild.id = "OTPreferenceCenter")
                    isOTClose = false
                    ichild.callFunc("setViewFocus", {})
                    if ichild.id = "OTBanner" then onScreen = m.constant.listener["ELB115"]
                    if ichild.id = "OTPreferenceCenter" then onScreen = m.constant.listener["ELP115"]
                end if
                exit for
            end if
        else
            exit for
        end if
    end for

    if isString(onHide)
        eventListeners(otsdk.top.eventlistener, onHide)
    end if
    if isString(onScreen)
        eventListeners(otsdk.top.eventlistener, onScreen)
    end if

    if isOTClose
        otsdk.consentData.purposesStatus = {}
        otsdk.consentData.iabVendorsStatus = {}
        otsdk.consentData.googleVendorsStatus = {}
        otsdk.consentData.sdkStatus = {}
        eventListeners(otsdk.top.eventlistener, "allSDKViewsDismissed", interactionType)
    end if
end function

function onDestroyView(view, interactionType)
    ' Assume vendorView is a previously created roSGNode
    if view <> invalid
        ' Remove from parent if necessary
        'parent = view.getParent()
        if view.parent <> invalid
            view.parent.RemoveChild(view)
        end if

        ' Clear references
        view.removeChildren(view.getChildren(-1, 0))
        view = invalid
    end if

    ' Optional: Force garbage collection
    if not isString(interactionType) then RunGarbageCollector()
end function

function navigateOK(focusValue)
    if focusValue <> invalid and focusValue.value <> invalid and focusValue.value.visible and focusValue.value.focusedChild <> invalid
        getPurposesStatus(focusValue)
        setAdditionalButtons(focusValue)
        setPurposeChild(focusValue)
        selectBackButton(focusValue)
        onClickQrcode(focusValue)
        onclickVendorbtn(focusValue)
        onclickFilterListItem(focusValue)
    end if
end function

function getPurposesStatus(focusValue)
    if focusValue.value.id = "OTConsentButtons"
        focusNode = getFocusedChild(focusValue)
        if isValid(focusNode) and (focusNode.id = "consentCheckBox" or focusNode.id = "legitInterestCheckBox" or focusNode.id = "activeTextCheckBox" or focusNode.id = "inActiveTextCheckBox")
            updateConsents(focusNode, m.OTinitialize, m.top.viewType)
            role = m.WCAGRoles.checkBoxDisabledAriaLabel
            if focusNode.status = 1 then role = m.WCAGRoles.checkBoxEnabledAriaLabel
            say(focusNode.itemContent.text, role, "", true)
        end if
    end if
end function

function setAdditionalButtons(focusValue)
    if focusValue.value.id = "OTAdditionalButtons"
        focusNode = getFocusedChild(focusValue)
        if isValid(focusNode)
            if focusNode.itemContent.id = "viewIllustrations"
                m.top.slideLayer += 1
                if isValid(m.childData)
                    m.childData.push({
                        node: focusValue.value,
                        key: m.navDirections.key,
                        itemFocused: focusValue.value.itemFocused,
                        translation: [m.detailScreenlayoutScroll.translation, m.scrollThumb.translation]
                    })
                end if
                focusNode.itemUnfocused = true
                if isValid(m.top.isChildScreen) then m.top.isChildScreen = true
                updateDetailScreen(focusNode.itemContent)
                setFocusChildDetailScreen()
                setTextToSpeechDetailScreen(true)
            end if
            if focusNode.itemContent.id = "vendorListTextBtn"
                m.OTinitialize.top.callFunc("showVendorListUI", m.top.bannerExits, "iab", getSelectedFilteredData(focusNode.itemContent.purposeItem, "iab"))
            end if
            if focusNode.itemContent.id = "sdkListTextBtn"
                m.OTinitialize.top.callFunc("showVendorListUI", m.top.bannerExits, "sdkList", getSelectedFilteredData(focusNode.itemContent.purposeItem, "sdkList"))
            end if
        end if
    end if
end function

function getSelectedFilteredData(data, viewType)
    selectedFilteredData = {}
    if isValid(data) and isString(data.groupId)
        isIabPurpose = data.isIabPurpose <> invalid and data.isIabPurpose
        if (viewType = "sdkList" and not isIabPurpose) or (viewType = "iab" and isIabPurpose)
            if not isIab_STACK(data.Type) then selectedFilteredData[data.groupId] = 1
            if isValid(data.children) and data.children.count() > 0
                for each item in data.children
                    if isString(item.groupId) then selectedFilteredData[item.groupId] = 1
                end for
            end if
        end if
    end if
    return selectedFilteredData
end function

function isIab_STACK(iab_type)
    return iab_type <> invalid and iab_type.Instr("_STACK") <> -1
end function

function setPurposeChild(focusValue)
    if focusValue.value.id = "OTPurposeChildButtons"
        focusNode = getFocusedChild(focusValue)
        if isValid(focusNode)
            m.top.slideLayer += 1
            if isValid(m.childData)
                m.childData.push({
                    node: focusValue.value,
                    key: m.navDirections.key,
                    itemFocused: focusValue.value.itemFocused,
                    translation: [m.detailScreenlayoutScroll.translation, m.scrollThumb.translation]
                })
            end if
            focusNode.itemUnfocused = true
            if isValid(m.top.isChildScreen) then m.top.isChildScreen = true
            updateDetailScreen(focusNode.itemContent)
            setFocusChildDetailScreen()
            setTextToSpeechDetailScreen(true)
        end if
    end if
end function

function selectBackButton(focusValue)
    isMainBack = true
    if focusValue.value.id = "backButton"
        if isValid(m.top.isChildScreen) and m.top.isChildScreen
            focusNode = getFocusedChild(focusValue)
            if isValid(focusNode)
                setChildBackButton(focusNode.itemContent)
                isMainBack = false
            end if
        end if
        if isMainBack then navigation1("back", true)
    end if
end function

sub setChildBackButton(itemContent)
    resetScroll({ value: m.navDirections.scrollValue }, [{ value: m.OTConsentButtons }])
    previousNode = itemContent.previousNode
    childData = m.childData.pop()
    if isValid(m.filteredListId) and isValid(childData) and isValid(childData.filteredListId) then m.filteredListId = childData.filteredListId
    if isValid(m.top.isChildScreen) and m.top.slideLayer = 1
        m.OTPCChildDetailScreenView.slide = true
        m.top.isChildScreen = false
    end if
    if isValid(previousNode) then updateDetailScreen(previousNode)
    m.top.slideLayer -= 1
    onBackFocusChildDetailScreen(childData)
end sub

function onClickQrcode(focusValue)
    if focusValue.value.id = "OTAdditionalButtons"
        focusNode = getFocusedChild(focusValue)
        if isValid(focusNode) and (focusNode.id = "vendorsPolicyBtn" or focusNode.id = "legIntClaimPolicyBtn")
            qrCodeDialog(focusNode.itemContent, focusValue, focusNode)
        end if
    end if
end function

function qrCodeDialog(item, focusValue, focusNode)
    if item.text <> invalid and item.url <> invalid and item.text <> "" and item.url <> ""
        m.top.slideLayer += 1
        if isValid(m.childData)
            m.childData.push({
                node: focusValue.value,
                key: m.navDirections.key,
                itemFocused: focusValue.value.itemFocused,
            })
        end if
        focusNode.itemUnfocused = true
        if isValid(m.top.isChildScreen) then m.top.isChildScreen = true
        updateDetailScreen(item)
        setFocusChildDetailScreen()
        setTextToSpeechDetailScreen(true)
    end if
end function

function onclickVendorbtn(focusValue)
    if focusValue.value.id = "OTConsentButtons"
        focusNode = getFocusedChild(focusValue)
        if isValid(focusNode)
            if focusNode.id = "iabVendorsBtn" then m.OTinitialize.top.callFunc("showVendorListUI", m.top.bannerExits)
            if focusNode.id = "googleVendorsBtn" then m.OTinitialize.top.callFunc("showVendorListUI", m.top.bannerExits, "google")
        end if
    end if
end function

function onclickFilterListItem(focusValue)
    if focusValue.value.id = "OTConsentButtons"
        focusNode = getFocusedChild(focusValue)
        if isValid(focusNode) and isValid(m.filteredListId) and (focusNode.id = "sdkFilterList" or focusNode.id = "iabFilterList")
            groupid = focusNode.itemContent.uId
            if focusNode.status = 0
                focusNode.status = 1
                m.filteredListId[groupid] = focusNode.status
            else if focusNode.status = 1
                focusNode.status = 0
                if m.filteredListId.doesExist(groupid) then m.filteredListId.delete(groupid)
            end if
            role = m.WCAGRoles.checkBoxDisabledAriaLabel
            if focusNode.status = 1 then role = m.WCAGRoles.checkBoxEnabledAriaLabel
            say(focusNode.itemContent.text, role, "", true)
        end if
    end if
end function

function getFocusedChild(focusValue)
    childNode = invalid
    if isValid(focusValue) and isValid(focusValue.value) and isValid(focusValue.value.focusedChild) and isValid(focusValue.value.focusedChild.focusedChild)
        childNode = focusValue.value.focusedChild.focusedChild
    end if
    return childNode
end function