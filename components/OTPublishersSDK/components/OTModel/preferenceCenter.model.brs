function getPreferenceCenterModelData(data, width)
    model = CreateObject("roSGNode", "OTPreferenceCenterInterface")
    try
        if data <> invalid and data.count() > 0
            regx = createObject("roRegex", "\s(\s+)?", "")
            model.fonts = m.OT_Data.fonts
            model.multiStyleFonts = m.OT_Data.multiStyleFonts
            data = data.pcUIData
            ' if data.logo <> invalid and data.logo.url <> invalid then model.logo = data.logo.url
            if isValid(data)
                if isValid(data.dsIdDetails) then model.dsIdDetails = data.dsIdDetails
                if data.menu <> invalid then model.menu = data.menu
                getWCAGRoles(data)
                if data.general <> invalid
                    if data.general.backgroundColor <> invalid then model.backgroundColor = data.general.backgroundColor
                    if data.general.buttonFocusColor <> invalid then model.buttonFocusColor = data.general.buttonFocusColor
                    if data.general.buttonFocusTextColor <> invalid then model.buttonFocusTextColor = data.general.buttonFocusTextColor
                    if data.general.buttonBorderShow <> invalid then model.border = data.general.buttonBorderShow
                    if data.general.illustrationsTitleText <> invalid then model.illustrationsTitleText = data.general.illustrationsTitleText
                    if data.general.vendorsListLabel <> invalid then model.vendorsListLabel = data.general.vendorsListLabel
                end if
                if isvalid(data) and isValid(data.purposeTree) and isvalid(data.purposeTree.styling) and data.purposeTree.styling.itemDescription <> invalid then model.itemDescription = data.purposeTree.styling.itemDescription
                if data.buttons <> invalid
                    if data.buttons.backButton <> invalid then model.backButton = buttonBackNodeItem(data.buttons.backButton, model, "backButton")
                    if data.buttons.closeButton <> invalid then
                        if isValid(data.buttons.closeButton.closeBtnVoiceOverText) then model.closeBtnVoiceOverText = data.buttons.closeButton.closeBtnVoiceOverText
                        model.closeButton = PCbuttonContentNodeItem(data.buttons, model, "closeButton")
                    end if
                    if data.buttons.acceptAll <> invalid
                        buttonsData = data.buttons.acceptAll
                        model.acceptAll = PCbuttonContentNodeItem(data.buttons, model, "acceptAll")
                    end if
                    if data.buttons.rejectAll <> invalid
                        buttonsData = data.buttons.rejectAll
                        model.rejectAll = PCbuttonContentNodeItem(data.buttons, model, "rejectAll")
                    end if
                    if data.buttons.showPreferences <> invalid then model.showPreferences = PCbuttonContentNodeItem(data.buttons, model, "showPreferences")
                    if data.buttons.vendorList <> invalid then model.vendorList = PCbuttonContentNodeItem(data.buttons, model, "vendorList")
                    if data.buttons.savePreferencesButton <> invalid
                        buttonsData = data.buttons.savePreferencesButton
                        model.savePreferencesButton = PCbuttonContentNodeItem(data.buttons, model, "savePreferencesButton")
                    end if
                end if
                consentColorCode = {
                    color: model.backgroundColor
                    textColor: model.itemDescription.textColor
                }
                if isValid(data.general)
                    if data.general.legitInterestText <> invalid and data.menu <> invalid then model.legitInterestBtn = getContentNodeItem(data.general.legitInterestText, consentColorCode, model, false, "checkBox", "left")
                    if data.general.iabVendorsLabel <> invalid and isValid(buttonsData) then model.iabVendorsBtn = getContentNodeItem(data.general.iabVendorsLabel, buttonsData, model, model.border)
                    if data.general.googleVendorsLabel <> invalid and isValid(buttonsData) then model.googleVendorsBtn = getContentNodeItem(data.general.googleVendorsLabel, buttonsData, model, model.border)
                end if
                if data.summary <> invalid
                    if data.summary.title <> invalid and data.summary.title.text <> invalid and data.summary.title.text <> "" then model.summaryTitle = data.summary.title
                    if data.summary.description <> invalid and data.summary.description.text <> invalid and data.summary.description.text <> "" then model.summaryDescription = data.summary.description
                end if
                if data.purposeTree <> invalid
                    if data.menu <> invalid then model.OTListView = OTListViewContentNode(data.purposeTree.purposes, data.menu, model, width)
                    if data.purposeTree.styling <> invalid
                        if data.purposeTree.styling.itemTitle <> invalid and isValid(data.summary) and isValid(data.summary.title)
                            data.summary.title["text"] = ""
                            model.itemTitle = data.summary.title
                            if isValid(data.general <> invalid) and isString(data.general.regionAriaLabel)
                                data.summary.title["text"] = data.general.regionAriaLabel
                                model.pageHeaderTitle = setbPCTextModel(data.summary.title, regx)
                            end if
                        end if

                        if data.purposeTree.styling.itemDetailsLinks <> invalid
                            if data.purposeTree.styling.itemDetailsLinks.vendorListText <> invalid and isValid(buttonsData) then model.vendorListTextBtn = getContentNodeItem(data.purposeTree.styling.itemDetailsLinks.vendorListText, buttonsData, model, model.border)
                            if data.purposeTree.styling.itemDetailsLinks.sdkListText <> invalid and isValid(buttonsData) then model.sdkListTextBtn = getContentNodeItem(data.purposeTree.styling.itemDetailsLinks.sdkListText, buttonsData, model, model.border)
                            if data.purposeTree.styling.itemDetailsLinks.fullLegalText <> invalid and isValid(buttonsData) then model.fullLegalTextBtn = getContentNodeItem(data.purposeTree.styling.itemDetailsLinks.fullLegalText, buttonsData, model, model.border)
                        end if
                        if data.purposeTree.styling.itemDetailsConsentCheckboxInfo <> invalid
                            if data.purposeTree.styling.itemDetailsConsentCheckboxInfo.subCategoryHeaderText <> invalid then model.subCategoryHeaderText = data.purposeTree.styling.itemDetailsConsentCheckboxInfo.subCategoryHeaderText
                            if data.purposeTree.styling.itemDetailsConsentCheckboxInfo.activeText <> invalid
                                model.activeTextNode = setbPCTextModel({ text: data.purposeTree.styling.itemDetailsConsentCheckboxInfo.activeText }, regx)
                                model.activeTextBtn = getContentNodeItem(data.purposeTree.styling.itemDetailsConsentCheckboxInfo.activeText, consentColorCode, model, false, "checkBox", "left")
                            end if
                            if data.purposeTree.styling.itemDetailsConsentCheckboxInfo.inActiveText <> invalid
                                model.inActiveTextNode = setbPCTextModel({ text: data.purposeTree.styling.itemDetailsConsentCheckboxInfo.inActiveText }, regx)
                                model.inActiveTextBtn = getContentNodeItem(data.purposeTree.styling.itemDetailsConsentCheckboxInfo.inActiveText, consentColorCode, model, false, "checkBox", "left")
                            end if
                        end if
                        if data.purposeTree.styling.alwaysActiveLabel <> invalid
                            if data.purposeTree.styling.alwaysActiveLabel <> invalid and isString(data.purposeTree.styling.alwaysActiveLabel.text) and data.menu <> invalid
                                model.alwaysActiveBtn = getContentNodeItem(data.purposeTree.styling.alwaysActiveLabel.text, consentColorCode, model, false, "checkBox", "left")
                                model.alwaysActiveNode = setbPCTextModel(data.purposeTree.styling.alwaysActiveLabel, regx)
                            end if
                        end if
                    end if
                end if
                consentText = ""
                if data.general <> invalid and data.general.consentText <> invalid then consentText = data.general.consentText
                if isValid(data.purposeTree) and isValid(data.purposeTree.styling) and isValid(data.purposeTree.styling.itemDetailsConsentCheckboxInfo) and isString(data.purposeTree.styling.itemDetailsConsentCheckboxInfo.interactionChoiceText) then consentText = data.purposeTree.styling.itemDetailsConsentCheckboxInfo.interactionChoiceText
                model.interactionChoiceShow = isValid(data.purposeTree) and isValid(data.purposeTree.styling) and isValid(data.purposeTree.styling.itemDetailsConsentCheckboxInfo) and isValid(data.purposeTree.styling.itemDetailsConsentCheckboxInfo.interactionChoiceText)
                if isValid(model.menu) then model.consentBtn = getContentNodeItem(consentText, consentColorCode, model, false, "checkBox", "left")
                if data.links <> invalid
                    if data.links.policyLink <> invalid then model.policyLink = setbPCTextModel(data.links.policyLink, regx)
                end if
            end if
        end if
    catch e
        ? "Error in getPreferenceCenterModelData: " + e.message
    end try
    return model
end function

function OTListViewContentNode(list, menuColor, model, width)
    width = width * model.ratio[0]
    node = getContentNodeItemList("listItems", list, menuColor, model, width, "listViewRectangle")
    OTListViewInterface = CreateObject("roSGNode", "OTListViewInterface")
    OTListViewInterface.listContentNode = node.contentNode
    OTListViewInterface.width = width
    OTListViewInterface.backgroundColor = menuColor.color
    OTListViewInterface.textColor = menuColor.textColor
    OTListViewInterface.rowheights = node.rowHeights
    return OTListViewInterface
end function

function getDetailScreenViewNode(data, preferenceModel, height, dataNode)
    OTDetailScreenViewInterface = CreateObject("roSGNode", "OTDetailScreenViewInterface")
    if isValid(data)
        consentData = m.OTinitialize.consentData
        if isValid(preferenceModel.WCAGRoles) then OTDetailScreenViewInterface.WCAGRoles = preferenceModel.WCAGRoles
        regx = createObject("roRegex", "\s(\s+)?", "")
        OTDetailScreenViewInterface.width = preferenceModel.width * preferenceModel.ratio[1]
        OTDetailScreenViewInterface.translation = [preferenceModel.width * preferenceModel.ratio[0], 0]
        OTDetailScreenViewInterface.height = height
        OTDetailScreenViewInterface.backgroundColor = preferenceModel.backgroundColor
        OTDetailScreenViewInterface.id = dataNode.id
        itemTitle = preferenceModel.itemTitle
        itemDescription = preferenceModel.itemDescription
        if dataNode.id = "privacyItem"
            itemTitle = preferenceModel.summaryTitle
            itemDescription = preferenceModel.summaryDescription
            if isValid(preferenceModel.dsIdDetails) then OTDetailScreenViewInterface.dsIdDetails = preferenceModel.dsIdDetails
            if isValid(preferenceModel.policyLink) then OTDetailScreenViewInterface.policyLink = preferenceModel.policyLink
        end if
        itemTitle["text"] = data.groupName
        if data.groupDescription <> invalid then itemDescription["text"] = data.groupDescription
        OTDetailScreenViewInterface.overlayTranslation = [-m.innerContainer.translation[0], - (m.innerContainer.translation[1] + m.contentContainer.translation[1])]
        if dataNode <> invalid and dataNode.id = "viewIllustrations" and data.iabIllustrations <> invalid and data.iabIllustrations.count() > 0
            OTDetailScreenViewInterface.subHeaderNode = setbPCTextModel(itemTitle, regx)
            itemTitle["text"] = preferenceModel.illustrationsTitleText
            OTDetailScreenViewInterface.headerNode = setbPCTextModel(itemTitle, regx)
            OTDetailScreenViewInterface.viewIllustrations = data.iabIllustrations
            if isString(itemDescription["text"]) then OTDetailScreenViewInterface.descriptionNode = setbPCTextModel(itemDescription, regx)
            OTDetailScreenViewInterface.backButton = getBackButtonContentNode(preferenceModel.backButton.clone(true), dataNode)
        else
            if dataNode.id = "childItems"
                OTDetailScreenViewInterface.backButton = getBackButtonContentNode(preferenceModel.backButton.clone(true), dataNode)
            end if
            OTDetailScreenViewInterface.headerNode = setbPCTextModel(itemTitle, regx)
            if isString(dataNode.subText)
                itemTitle["text"] = dataNode.subText
                OTDetailScreenViewInterface.subHeaderNode = setbPCTextModel(itemTitle, regx)
            end if
            if isValid(itemDescription) then OTDetailScreenViewInterface.descriptionNode = setbPCTextModel(itemDescription, regx, true)
            OTButtonView = CreateObject("roSGNode", "OTButtonView")
            OTButtonView.width = OTDetailScreenViewInterface.width
            descriptionColor = "#ffffff"
            if isValid(itemDescription["textColor"]) then descriptionColor = itemDescription["textColor"]
            consentBtnRowheights = []
            consentBtnNode = CreateObject("roSGNode", "ContentNode")
            if data.consentToggleStatus <> invalid and data.consentToggleStatus <> -1
                if data.consentToggleStatus <> 2 and not preferenceModel.interactionChoiceShow
                    activeTextBtn = createConsentButton("activeTextCheckBox", preferenceModel.activeTextBtn, data, dataNode, consentData)
                    if activeTextBtn <> invalid
                        OTButtonView.itemContent = activeTextBtn
                        height = OTButtonView.boundingRect().height
                        consentBtnRowheights.push(height)
                        consentBtnNode.appendChild(activeTextBtn)
                    end if
                    inActiveTextBtn = createConsentButton("inActiveTextCheckBox", preferenceModel.inActiveTextBtn, data, dataNode, consentData)
                    if inActiveTextBtn <> invalid
                        OTButtonView.itemContent = inActiveTextBtn
                        height = OTButtonView.boundingRect().height
                        consentBtnRowheights.push(height)
                        consentBtnNode.appendChild(inActiveTextBtn)
                    end if
                else
                    consentBtn = invalid
                    if isValid(preferenceModel.alwaysActiveBtn) and data.consentToggleStatus = 2 then consentBtn = preferenceModel.alwaysActiveBtn.clone(true)
                    if isValid(preferenceModel.consentBtn) and data.consentToggleStatus <> 2 then consentBtn = preferenceModel.consentBtn.clone(true)
                    if isValid(consentBtn)
                        consentBtn.id = "consentCheckBox"
                        consentBtn.uId = data.groupId
                        if data.parent <> invalid then consentBtn.parentId = data.parent
                        if isArray(dataNode.ParentFirstPartyCookies) and dataNode.ParentFirstPartyCookies.count() > 0 then consentBtn.ParentFirstPartyCookies = dataNode.ParentFirstPartyCookies
                        consentStatus = data.consentStatus
                        if data.consentToggleStatus = 2
                            consentStatus = data.consentToggleStatus
                        else
                            if consentData <> invalid and consentData.OT_GroupConsents[consentBtn.uId] <> invalid
                                consentStatus = consentData.OT_GroupConsents[consentBtn.uId]
                            end if
                            if consentData <> invalid and consentData.purposesStatus[consentBtn.uId] <> invalid and consentData.purposesStatus[consentBtn.uId]["status"] <> invalid
                                consentStatus = getStatusBoolToNum(consentData.purposesStatus[consentBtn.uId]["status"])
                            end if
                        end if
                        consentBtn.status = consentStatus
                        consentBtn.purposeItem = data
                        OTButtonView.itemContent = consentBtn
                        height = OTButtonView.boundingRect().height
                        consentBtnRowheights.push(height)
                        consentBtnNode.appendChild(consentBtn)
                    end if
                end if
            end if
            if isValid(preferenceModel.legitInterestBtn) and data.legIntStatus <> invalid and data.legIntStatus <> -1
                legitInterestBtn = preferenceModel.legitInterestBtn.clone(true)
                legIntStatus = data.legIntStatus
                legitInterestBtn.id = "legitInterestCheckBox"
                legitInterestBtn.uId = data.groupId
                if consentData <> invalid and consentData.OT_GroupLIConsents[legitInterestBtn.uId] <> invalid
                    legIntStatus = consentData.OT_GroupLIConsents[legitInterestBtn.uId]
                end if
                if consentData <> invalid and consentData.purposesStatus[legitInterestBtn.uId] <> invalid and consentData.purposesStatus[legitInterestBtn.uId]["liStatus"] <> invalid
                    legIntStatus = getStatusBoolToNum(consentData.purposesStatus[legitInterestBtn.uId]["liStatus"])
                end if
                legitInterestBtn.status = legIntStatus
                OTButtonView.itemContent = legitInterestBtn
                height = OTButtonView.boundingRect().height
                consentBtnRowheights.push(height)
                consentBtnNode.appendChild(legitInterestBtn)
            end if
            if dataNode.id = "vendorsListItem"
                if isValid(preferenceModel.iabVendorsBtn)
                    iabVendorsBtn = preferenceModel.iabVendorsBtn.clone(true)
                    iabVendorsBtn.id = "iabVendorsBtn"
                    iabVendorsBtn.descriptionColor = descriptionColor
                    consentBtnNode.appendChild(iabVendorsBtn)
                end if
                if isValid(preferenceModel.googleVendorsBtn)
                    googleVendorsBtn = preferenceModel.googleVendorsBtn.clone(true)
                    googleVendorsBtn.id = "googleVendorsBtn"
                    googleVendorsBtn.descriptionColor = descriptionColor
                    consentBtnNode.appendChild(googleVendorsBtn)
                end if
            end if
            OTDetailScreenViewInterface.consentBtnRowheights = consentBtnRowheights
            if consentBtnNode.getChildCount() > 0 then OTDetailScreenViewInterface.consentBtnNode = consentBtnNode

            additionalBtnRowheights = []
            additionalBtnNode = CreateObject("roSGNode", "ContentNode")
            if isValid(preferenceModel.vendorListTextBtn) and data.isIabPurpose <> invalid and data.isIabPurpose
                vendorListTextBtn = preferenceModel.vendorListTextBtn.clone(true)
                vendorListTextBtn.id = "vendorListTextBtn"
                vendorListTextBtn.descriptionColor = descriptionColor
                vendorListTextBtn.purposeItem = data
                OTButtonView.itemContent = vendorListTextBtn
                height = OTButtonView.boundingRect().height
                additionalBtnRowheights.push(height)
                additionalBtnNode.appendChild(vendorListTextBtn)
            end if
            if isValid(preferenceModel.sdkListTextBtn) and data.showSDKListLink <> invalid and data.showSDKListLink and isValid(data.type) and data.type <> "BRANCH" and not (isValid(data.isIabPurpose) and data.isIabPurpose)
                havingChildFirstPartyCookies = false
                if data.FirstPartyCookies <> invalid and data.FirstPartyCookies.count() > 0
                    havingChildFirstPartyCookies = true
                else if isValid(data.children) and data.children.count() > 0
                    for each childItem in data.children
                        if childItem.showSDKListLink <> invalid and childItem.showSDKListLink and childItem.FirstPartyCookies <> invalid and childItem.FirstPartyCookies.count() > 0
                            havingChildFirstPartyCookies = true
                            exit for
                        end if
                    end for
                end if

                if havingChildFirstPartyCookies
                    sdkListTextBtn = preferenceModel.sdkListTextBtn.clone(true)
                    OTButtonView.itemContent = sdkListTextBtn
                    sdkListTextBtn.id = "sdkListTextBtn"
                    sdkListTextBtn.descriptionColor = descriptionColor
                    sdkListTextBtn.purposeItem = data
                    height = OTButtonView.boundingRect().height
                    additionalBtnRowheights.push(height)
                    additionalBtnNode.appendChild(sdkListTextBtn)
                end if
            end if
            if isValid(preferenceModel.fullLegalTextBtn) and data.iabIllustrations <> invalid and data.iabIllustrations.count() > 0
                fullLegalTextBtn = preferenceModel.fullLegalTextBtn.clone(true)
                fullLegalTextBtn.id = "viewIllustrations"
                fullLegalTextBtn.descriptionColor = descriptionColor
                fullLegalTextBtn.purposeItem = data
                fullLegalTextBtn.previousNode = dataNode
                OTButtonView.itemContent = fullLegalTextBtn
                height = OTButtonView.boundingRect().height
                additionalBtnRowheights.push(height)
                additionalBtnNode.appendChild(fullLegalTextBtn)
            end if
            if additionalBtnNode.getChildCount() > 0 then OTDetailScreenViewInterface.additionalBtnNode = additionalBtnNode
            OTDetailScreenViewInterface.additionalBtnRowheights = additionalBtnRowheights

            if data.children <> invalid and data.children.count() > 0
                itemDescription.text = preferenceModel.subCategoryHeaderText
                OTDetailScreenViewInterface.childHeaderText = setbPCTextModel(itemDescription, regx)
                childButtonColorCode = {
                    color: preferenceModel.backgroundColor
                    textColor: descriptionColor
                    focusColor: preferenceModel.buttonFocusColor
                    focusTextColor: preferenceModel.buttonFocusTextColor
                    activeColor: preferenceModel.menu.activeColor
                    activeColor: preferenceModel.menu.activeTextColor
                }
                node = getContentNodeItemList("childItems", data.children, childButtonColorCode, preferenceModel, OTDetailScreenViewInterface.width, "checkBoxText", consentData, dataNode, data.firstPartyCookies)
                OTDetailScreenViewInterface.purposeChildBtnNode = node.contentNode
                OTDetailScreenViewInterface.purposeChildBtnRowheights = node.rowHeights
            end if
        end if
    end if
    return OTDetailScreenViewInterface
end function

function getContentNodeItem(text, buttonData, model, border, Btype = "rectangleBtn", horizAlign = "center")
    color = buttonData.color
    textcolor = buttonData.textColor
    if Btype = "closeButton"
        color = model.backgroundColor
    end if
    contentNodeItem = CreateObject("roSGNode", "OTButtonInterface")
    contentNodeItem.text = text
    contentNodeItem.color = color
    contentNodeItem.textColor = textcolor
    contentNodeItem.focusButtonColor = model.buttonFocusColor
    contentNodeItem.focusButtonTextColor = model.buttonFocusTextColor
    contentNodeItem.fonts = model.fonts
    contentNodeItem.Btype = Btype
    contentNodeItem.border = border
    contentNodeItem.horizAlign = horizAlign
    if isValid(model.alwaysActiveNode) then contentNodeItem.alwaysActiveNode = model.alwaysActiveNode
    if isValid(model.activeTextNode) then contentNodeItem.activeTextNode = model.activeTextNode
    if isValid(model.inActiveTextNode) then contentNodeItem.inActiveTextNode = model.inActiveTextNode
    return contentNodeItem
end function

function getContentNodeItemList(id, list, menuColor, model, width, Btype = "rectangleBtn", consentData = invalid, dataNode = invalid, ParentFirstPartyCookies = invalid)
    contentNode = CreateObject("roSGNode", "ContentNode")

    if id = "listItems"
        if isValid(model.summaryTitle) and isString(model.summaryTitle.text)
            contentNodeItem = getContentNodeListItem("privacyItem", { groupName: model.summaryTitle.text, groupDescription: model.summaryDescription.text }, menuColor, model, dataNode, Btype)
            contentNode.appendChild(contentNodeItem)
        end if
        if isString(model.vendorsListLabel)
            contentNodeItem = getContentNodeListItem("vendorsListItem", { groupName: model.vendorsListLabel }, menuColor, model, dataNode, Btype)
            contentNode.appendChild(contentNodeItem)
        end if
    end if


    rowHeights = []
    if list <> invalid and list.count() > 0
        OTButtonView = CreateObject("roSGNode", "OTButtonView")
        OTButtonView.width = width
        listCount = list.count() - 1
        for i = 0 to listCount step 1
            contentNodeItem = getContentNodeListItem(id, list[i], menuColor, model, dataNode, Btype, consentData, ParentFirstPartyCookies)
            OTButtonView.itemContent = contentNodeItem
            height = OTButtonView.boundingRect().height
            rowHeights.push(height)
            contentNode.appendChild(contentNodeItem)
        end for
    end if
    return { contentNode: contentNode, rowHeights: rowHeights }
end function

function getContentNodeListItem(id, list, menuColor, model, dataNode, Btype, consentData = invalid, ParentFirstPartyCookies = invalid)
    contentNodeItem = CreateObject("roSGNode", "OTButtonInterface")
    contentNodeItem.id = id
    if list.groupId <> invalid then contentNodeItem.uId = list.groupId
    contentNodeItem.text = list.groupName
    if isString(list.vendorsLinkedInfo) then contentNodeItem.subText = list.vendorsLinkedInfo
    if isArray(ParentFirstPartyCookies) and ParentFirstPartyCookies.count() > 0 then contentNodeItem.ParentFirstPartyCookies = ParentFirstPartyCookies
    contentNodeItem.color = menuColor.color
    contentNodeItem.textColor = menuColor.textColor
    contentNodeItem.focusButtonColor = menuColor.focusColor
    contentNodeItem.focusButtonTextColor = menuColor.focusTextColor
    contentNodeItem.activeColor = menuColor.activeColor
    contentNodeItem.activeTextColor = menuColor.activeTextColor
    contentNodeItem.maxLines = 10
    contentNodeItem.fonts = model.fonts
    contentNodeItem.multiStyleFonts = model.multiStyleFonts
    if dataNode <> invalid then contentNodeItem.previousNode = dataNode
    contentNodeItem.purposeItem = list
    contentNodeItem.Btype = Btype
    if list.consentStatus <> invalid
        consentStatus = list.consentStatus
        if consentData <> invalid and consentData.OT_GroupConsents[contentNodeItem.uId] <> invalid
            consentStatus = consentData.OT_GroupConsents[contentNodeItem.uId]
        end if
        if consentData <> invalid and list.groupId <> invalid and consentData.purposesStatus[contentNodeItem.uId] <> invalid and consentData.purposesStatus[contentNodeItem.uId]["status"] <> invalid
            consentStatus = getStatusBoolToNum(consentData.purposesStatus[contentNodeItem.uId]["status"])
        end if
        contentNodeItem.status = consentStatus
    end if
    if isValid(model.alwaysActiveNode) then contentNodeItem.alwaysActiveNode = model.alwaysActiveNode
    if isValid(model.activeTextNode) then contentNodeItem.activeTextNode = model.activeTextNode
    if isValid(model.inActiveTextNode) then contentNodeItem.inActiveTextNode = model.inActiveTextNode
    return contentNodeItem
end function

function createConsentButton(id as string, btnNode as object, data as object, dataNode as object, consentData as object) as object
    ' Initialize the button as invalid
    consentBtn = invalid

    ' Clone the button if valid
    if isValid(btnNode)
        consentBtn = btnNode.clone(true)
    end if

    ' Proceed only if the button is valid
    if consentBtn <> invalid
        consentBtn.id = id
        consentBtn.uId = data.groupId

        if data.parent <> invalid
            consentBtn.parentId = data.parent
        end if

        if isArray(dataNode.ParentFirstPartyCookies) and dataNode.ParentFirstPartyCookies.count() > 0
            consentBtn.ParentFirstPartyCookies = dataNode.ParentFirstPartyCookies
        end if

        ' Determine consent status
        consentStatus = data.consentStatus
        if data.consentToggleStatus = 2
            consentStatus = data.consentToggleStatus
        else
            if consentData <> invalid and consentData.OT_GroupConsents[consentBtn.uId] <> invalid
                consentStatus = consentData.OT_GroupConsents[consentBtn.uId]
            end if
            if consentData <> invalid and consentData.purposesStatus[consentBtn.uId] <> invalid and consentData.purposesStatus[consentBtn.uId]["status"] <> invalid
                consentStatus = getStatusBoolToNum(consentData.purposesStatus[consentBtn.uId]["status"])
            end if
        end if

        consentBtn.status = consentStatus
    end if

    return consentBtn
end function


