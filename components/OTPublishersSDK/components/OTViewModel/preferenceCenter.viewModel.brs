function updateDetailScreen(data)
    if isValid(data)
        detailScreenViewNode = getDetailScreenViewNode(data.purposeItem, m.dataModel, m.contentContainer.height, data)
        OTPCDetailScreenView = m.OTPCDetailScreenView
        if isValid(m.top.isChildScreen) and m.top.isChildScreen then OTPCDetailScreenView = m.OTPCChildDetailScreenView
        itemFocusHandler(OTPCDetailScreenView, detailScreenViewNode)
        m.scrollThumb.height = scrollHeight()
    end if
end function

sub setFocusChildDetailScreen(currentValue = invalid)
    if isValid(m.backButton) and m.backButton.visible and isValid(m.backButton.content)
        node = { value: m.backButton }
        path = [0, 0]
        if not isValid(currentValue) then currentValue = getDefaultvalue("down", {}, [{ value: m.OTConsentButtons }, { value: m.OTAdditionalButtons }])
        if isValid(currentValue) and isValid(currentValue.["default"]) and isValid(currentValue["defaultPath"])
            node = { value: currentValue["default"] }
            path = currentValue["defaultPath"]
        end if
        setfocusNode(node, path)
    end if
end sub

sub onBackFocusChildDetailScreen(childData)
    itemFocused = invalid
    translation = invalid
    if isValid(childData)
        node = { value: childData.node }
        path = childData.key
        itemFocused = childData.itemFocused
        translation = childData.translation
    else if isValid(m.backButton) and m.backButton.visible and isValid(m.backButton.content)
        node = { value: m.backButton }
        path = [0, 0]
    else
        node = { value: m.OTConsentButtons }
        path = [1, 1]
    end if
    setfocusNode(node, path, invalid, translation, itemFocused)
end sub

sub setTextToSpeechDetailScreen(isSelected = false as boolean, issearchNoResults = false as boolean)
    if isValid(m.roAudioGuide) and isValid(m.WCAGRoles)
        vendorQrCode = invalid
        if isValid(m.descriptionRec) and m.descriptionRec.visible then vendorQrCode = m.descriptionRec.findNode("vendorQrCode")
        if isSelected
            m.roAudioGuide.Flush()
            if not (isValid(vendorQrCode) and vendorQrCode.visible) then sayText(m.heading, m.WCAGRoles.headingAriaLabel)
        end if
        if issearchNoResults and isValid(m.searchNoResultsFoundText) and m.searchNoResultsFoundText.visible then sayText(m.searchNoResultsFoundText)
        if isValid(vendorQrCode) and vendorQrCode.visible then sayPoster(vendorQrCode)
        subHeading = invalid
        if isValid(m.headerLayout) then subHeading = m.headerLayout.getChild(1)
        if isValid(subHeading) and subHeading.id = "subHeading" then sayText(subHeading)
        if isValid(m.alwaysActiveLabel) then sayText(m.alwaysActiveLabel)
        if isValid(m.descriptionRec) and m.descriptionRec.visible and not (isValid(vendorQrCode) and vendorQrCode.visible) then sayLayout(m.descriptionRec, "")
        if isValid(m.adtlDescriptionRec) and m.adtlDescriptionRec.visible then sayLayout(m.adtlDescriptionRec, "")
     
        if isValid(m.policyLinkText) and m.policyLinkText.visible and isValid(m.qrCodeImg) and m.qrCodeImg.visible
            sayPoster(m.qrCodeImg)
        end if
        if isValid(m.OTConsentButtons) and m.OTConsentButtons.isInFocusChain()
            item = m.OTConsentButtons.getChild(0).getChild(m.OTConsentButtons.itemFocused)
            role = m.WCAGRoles.button
            role2 = m.WCAGRoles.selectedAriaLabel
            if isValid(item) and (item.id = "legitInterestCheckBox" or item.id = "consentCheckBox" or item.id = "activeTextCheckBox" or item.id = "inActiveTextCheckBox" or item.id = "sdkFilterList" or item.id = "iabFilterList")
                role = m.WCAGRoles.checkBoxDisabledAriaLabel
                if item.status = 1 then role = m.WCAGRoles.checkBoxEnabledAriaLabel
                role2 = ""
                if item.id = "iabFilterList" or item.id = "sdkFilterList"
                    Mcount = m.OTConsentButtons.content.getChildCount()
                    itemFocused = m.OTConsentButtons.itemFocused + 1
                    role2 = itemFocused.toStr() + " of " + Mcount.toStr()
                end if
            end if
            saylayout(item, role, role2)
        else if isValid(m.backButton) and m.backButton.isInFocusChain()
            item = m.backButton.getChild(0).getChild(m.backButton.itemFocused)
            say(item.itemContent.subText, m.WCAGRoles.button, m.WCAGRoles.selectedAriaLabel)
        end if
    end if
end sub