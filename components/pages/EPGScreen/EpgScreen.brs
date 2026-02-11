sub init()
    ' print "DetailsScreen : Init"
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetObservers()
    Initialize()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.epgData = []
    m.paginationLimit = 10
    m.paginationQueue = []
    m.firstTime = false
    m.UpdateProgressTask = CreateObject("roSGNode", "UpdateProgramProgressTask")
    m.UpdateProgressTask.observeField("progressUpdated", "onProgressUpdated")
end sub

sub SetControls()
    m.scene = m.top.GetScene()
    m.categoryList = m.top.findNode("categoryList")
    m.epgGrid = m.top.findNode("epgGrid")

    m.categoryGrp = m.top.findNode("categoryGrp")
    m.categoryName = m.top.findNode("categoryName")
    m.onNowText = m.top.findNode("onNowText")
    m.upNextText = m.top.findNode("upNextText")

    m.noDataGrp = m.top.findNode("noDataGrp")
    m.noDataLabel = m.top.findNode("noDataLabel")

    m.liveMiniPlayerGrp = m.top.findNode("liveMiniPlayerGrp")
    m.livePlayerLabel = m.top.findNode("livePlayerLabel")
    m.liveMiniPlayerBorder = m.top.findNode("liveMiniPlayerBorder")

    m.refreshTimer = m.top.findNode("refreshTimer")
end sub

sub SetupFonts()
    m.categoryName.font = m.fonts.robotoMed24
    m.onNowText.font = m.fonts.robotoMed24
    m.upNextText.font = m.fonts.robotoMed24
    m.noDataLabel.font = m.fonts.robotoMed30
    m.livePlayerLabel.font = m.fonts.robotoMed24
end sub

sub SetupColors()
    m.categoryList.focusBitmapBlendColor = m.theme.FocusedBitmapBlendColor
    m.epgGrid.sectionDividerFont = m.fonts.robotoMed24
    m.epgGrid.sectionDividerTextColor = m.theme.EPGCategoryTextColor
    m.categoryName.color = m.theme.EPGCategoryTextColor
    m.onNowText.color = m.theme.MenuFocused
    m.upNextText.color = m.theme.EPGCategoryTextColor
    m.livePlayerLabel.color = m.theme.White
    m.liveMiniPlayerBorder.blendColor = m.theme.MenuFocused
end sub

sub SetObservers()
    m.top.observeField("focusedChild","OnFocusedChild")
    m.liveMiniPlayerGrp.observeField("focusedChild","OnLivePlayerFocusedChild")
    m.epgGrid.observeField("itemFocused", "onEPGGridItemFocused")
    m.epgGrid.observeField("itemSelected", "onEPGGridItemSelected")
    m.categoryList.observeField("itemSelected", "onCategoryItemSelected")
    m.refreshTimer.observeField("fire", "onRefreshTimerFire")
end sub

sub onRefreshTimerFire()
    if m.epgGrid <> invalid and m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0
        m.UpdateProgressTask.functionName = "UpdateProgress"
        m.UpdateProgressTask.epgGridContent = m.epgGrid.content
        m.UpdateProgressTask.control = "RUN"
    end if
end sub

sub onProgressUpdated(event as dynamic)
    progressUpdated = event.getData()
    if progressUpdated
        if  m.liveMiniPlayer <> invalid and m.liveMiniPlayer.content <> invalid
            selectedData = m.liveMiniPlayer.content
            if selectedData.limitedData <> invalid
                onNowData = getOnNowData(selectedData.limitedData)
                if onNowData <> invalid
                    m.livePlayerLabel.text = onNowData.title
                end if
            end if
        end if
    end if
end sub

sub Initialize()
    m.epgGrid.sectionDividerBitmapUri = "pkg:/images/nil.png"
end sub

sub CreateMiniPlayer()
    if m.liveMiniPlayer <> invalid
        m.liveMiniPlayer.content = invalid
        m.liveMiniPlayerGrp.removeChild(m.liveMiniPlayer)
        m.liveMiniPlayer = invalid
    end if
    m.liveMiniPlayer = CreateObject("roSGNode","Video")
    m.liveMiniPlayer.id = "liveMiniPlayer"
    m.liveMiniPlayer.width = 370
    m.liveMiniPlayer.height = 208
    m.liveMiniPlayer.enableUI = false
    m.liveMiniPlayer.enableTrickPlay = false
    m.liveMiniPlayer.translation = [75, 200]
    m.liveMiniPlayerGrp.insertChild(m.liveMiniPlayer, 1)
end sub

sub OnLivePlayerFocusedChild(evt)
    if m.liveMiniPlayerGrp.hasFocus()
        m.liveMiniPlayerBorder.visible = true
    else
        m.liveMiniPlayerBorder.visible = false
    end if
end sub

sub OnContentChange(event as dynamic)
    contentData = event.getData().getFields()
    if contentData <> invalid and contentData._id <> invalid
        m.contentData = contentData
        m.scene.callFunc("showHideLoader", true)
        GetHBCUEPGContent(m.contentData._id)
    end if
end sub

function GetHBCUEPGContent(id as integer)
    if m.getEPGResultsTask <> invalid
        m.getEPGResultsTask.UnObserveField("result")
        m.getEPGResultsTask.control = "stop"
        m.getEPGResultsTask = invalid
    end if
    m.noDataGrp.visible = false
    m.categoryGrp.visible = false
    m.getEPGResultsTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getEPGResultsTask.tabId = id.toStr()
    m.getEPGResultsTask.functionName = "GetHBCUEPGData"
    m.getEPGResultsTask.ObserveField("result", "OnGetEPGDataAPIResponse")
    m.getEPGResultsTask.control = "RUN"
end function

sub OnGetEPGDataAPIResponse(event as dynamic)
    apiResponseData = event.getData()
    if (apiResponseData <> invalid AND apiResponseData.data <> invalid AND apiResponseData.data.content <> invalid AND apiResponseData.ok)
        if apiResponseData.data.content.playlists <> invalid and apiResponseData.data.content.playlists.count() > 0
            initializeEPG(apiResponseData.data.content)
            m.noDataGrp.visible = false
            m.categoryGrp.visible = true
        else
            m.categoryGrp.visible = false
            m.noDataGrp.visible = true
        end if
    else
        m.categoryGrp.visible = false
        m.noDataGrp.visible = true
    end if
    if m.getEPGResultsTask <> invalid
        m.getEPGResultsTask.UnObserveField("result")
        m.getEPGResultsTask.control = "stop"
        m.getEPGResultsTask = invalid
    end if
    m.scene.callFunc("showHideLoader", false)
end sub

sub initializeEPG(epgData)
    CreateMiniPlayer()
    if epgData <> invalid and epgData.playlists <> invalid and epgData.playlists.count() > 0
        mainContent = CreateObject("roSGNode", "ContentNode")
        counter = 0
        m.epgData = epgData.playlists
        for each category in m.epgData
            if counter = 0
                m.categoryName.text = category.title
            end if
            categoryItem = mainContent.createChild("ContentNode")
            categoryItem.TITLE = category.title
            counter++
        end for
        m.categoryList.content = mainContent
        SetFocus(m.categoryList)
        createEpgGrid()
    end if
end sub

sub onEPGGridItemFocused(evt)
    m.itemIndex = evt.getData()
    category = getTheCurrentFocusedItemCategory(m.itemIndex)
    m.categoryName.text = category
    updateCategoryList(category)
end sub

sub onEPGGridItemSelected(evt)
    selectedItem = evt.getData()
    m.scene.callFunc("showHideLoader", true)
    selectedContent = getTheCurrentSelectedItem(selectedItem)
    selectedData = selectedContent.programData
    videoNodeObj = CreateObject("roSGNode", "VideoNode")
    onNowData = getOnNowData(selectedData.limitedData)
    if onNowData <> invalid
        videoNodeObj.title = onNowData.title
    end if
    videoNodeObj.limitedData = selectedData.limitedData
    setIsWatching(selectedItem)
    if selectedData.liveUrl <> invalid then videoNodeObj.hls_url = selectedData.liveUrl
    videoNodeObj.is_live = 1
    m.liveMiniPlayer.control = "stop"
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.live = true
    videoContent.url = selectedData.liveUrl
    videoContent.title = videoNodeObj.title
    m.livePlayerLabel.text = videoNodeObj.title
    videoContent.addFields({"limitedData" : selectedData.limitedData})
    m.liveMiniPlayer.content = videoContent
    m.liveMiniPlayer.enableUI = false
    m.scene.callFunc("StartVideo", videoNodeObj)
end sub

sub updateCategoryList(category)
    if m.categoryList <> invalid and m.categoryList.content <> invalid and m.categoryList.content.getChildCount() > 0
        for i=0 to m.categoryList.content.getChildCount() - 1
            categoryItem = m.categoryList.content.getChild(i)
            if categoryItem <> invalid and categoryItem.TITLE = category
                m.categoryList.animateToItem = i
                exit for
            end if
        end for
    end if
end sub

function getTheCurrentFocusedItemCategory(index) as string
    categoryName = ""
    if m.epgGrid <> invalid and m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0
        categoryItemCount = -1
        for i = 0 to m.epgGrid.content.getChildCount() - 1
            category = m.epgGrid.content.getChild(i)
            if category <> invalid
                categoryItemCount += category.getChildCount()
                if categoryItemCount >= index
                    return category.TITLE
                end if
            end if
        end for
    end if
    return categoryName
end function

function getTheCurrentSelectedItem(index) as dynamic
    programObj = invalid
    if m.epgGrid <> invalid and m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0
        itemCount = -1
        for i = 0 to m.epgGrid.content.getChildCount() - 1
            category = m.epgGrid.content.getChild(i)
            if category <> invalid
                for program = 0 to category.getChildCount() - 1
                    itemCount++
                    if index = itemCount
                        return category.getChild(program)
                        exit for
                    end if
                end for
            end if
        end for
    end if
    return programObj
end function

function setIsWatching(index) as dynamic
    programObj = invalid
    if m.epgGrid <> invalid and m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0
        itemCount = -1
        for i = 0 to m.epgGrid.content.getChildCount() - 1
            category = m.epgGrid.content.getChild(i)
            if category <> invalid
                for program = 0 to category.getChildCount() - 1
                    itemCount++
                    if index = itemCount
                        programObj = category.getChild(program)
                        programData = programObj.programData
                        programData.isWatching = true
                        programObj.programData = programData
                    else
                        programObj = category.getChild(program)
                        programData = programObj.programData
                        programData.isWatching = false
                        programObj.programData = programData
                    end if
                end for
            end if
        end for
    end if
    return programObj
end function

sub onCategoryItemSelected(evt)
    categoryName = m.epgGrid.content.getChild(evt.getData()).TITLE
    m.epgGrid.animateToItem = getTheCategoryItemIndex(categoryName)
    m.categoryName.text = categoryName
end sub

function getTheCategoryItemIndex(categoryName as string) as integer
    if m.epgGrid <> invalid and m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0
        selectedCategoryItemIndex = 0
        for i = 0 to m.epgGrid.content.getChildCount() - 1
            category = m.epgGrid.content.getChild(i)
            if category <> invalid and category.TITLE = categoryName
                return selectedCategoryItemIndex
            else
                if category <> invalid and category.getChildCount() > 0
                    for j = 0 to category.getChildCount() - 1
                        selectedCategoryItemIndex++
                    end for
                end if
            end if
        end for
    end if
    return selectedCategoryItemIndex
end function

sub createEpgGrid()
    if m.epgData.count() > 0
        m.paginationQueue = []
        if m.programApiTask <> invalid
            m.programApiTask.UnObserveField("result")
            m.programApiTask.control = "stop"
            m.programApiTask = invalid
        end if
        if m.liveMiniPlayer.content <> invalid
            m.liveMiniPlayer.enableUI = false
            m.liveMiniPlayer.control = "stop"
            m.liveMiniPlayer.content = invalid
            m.livePlayerLabel.text = ""
        end if
        if m.epgContent <> invalid and m.epgContent.getChildCount() > 0 then m.epgContent.removeChildrenIndex(m.epgContent.getChildCount(),0)
        if m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0 then m.epgGrid.content.removeChildrenIndex(m.epgGrid.content.getChildCount(),0)
        m.epgContent = CreateObject("roSGNode", "ContentNode")
        m.arrChannelId = []
        m.apiCallCount = 0
        m.isLivePlayerLoaded = false
        sectionIndex = -1
        for each item in m.epgData
            sectionIndex++
            addSection(item.title)
            channelIndex = -1
            'm.arrChannelId.push(item)
            for each program in item.channels
                channelIndex++
                objChannel = {}
                objChannel["liveUrl"] = program.URL
                objChannel["channelName"] = program.name
                objChannel["logo"] = program.channel_imagery
                objChannel["sectionName"] = item.title
                objChannel["isWatching"] = false
                objChannel["programs"] = invalid
                objChannel["uniqueId"] = program._id
                objChannel["sectionIndex"] = sectionIndex
                objChannel["channelIndex"] = channelIndex
                addItem(objChannel, true)
                getChannelPrograms(program, item.title, sectionIndex, channelIndex, true)
            end for
        end for
        if not(m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0)
            m.epgGrid.content = m.epgContent
            m.refreshTimer.control = "stop"
            m.refreshTimer.control = "start"
        end if
    end if
end sub

sub getChannelPrograms(data, sectionName, sectionIndex, channelIndex,isFromPagination = false)
    if m.paginationLimit > m.apiCallCount
        m.apiCallCount++
        m.programApiTask = CreateObject("roSGNode", "HBCUApiAction")
        m.programApiTask.functionName = "GetHBCUChannelData"
        m.programApiTask.xmlUri = data.EPG
        m.programApiTask.positionObj = {
            "sectionIndex": sectionIndex,
            "channelIndex": channelIndex
        }
        m.programApiTask.program = data
        m.programApiTask.sectionName = sectionName
        m.programApiTask.ObserveField("result", "OnGetProgramResponse")
        m.programApiTask.control = "RUN"
    else if isFromPagination
        m.paginationQueue.push({data: data, sectionName: sectionName, sectionIndex: sectionIndex, channelIndex: channelIndex})
    end if
end sub

sub OnGetProgramResponse(event as dynamic)
    m.apiCallCount--
    response = event.getData()
    taskObj = event.getROSGNode()
    if taskObj <> invalid
        taskObj.control = "STOP"
        taskObj.UnObserveField("result")
        taskObj = invalid
    end if
    FillChannelData(response)
    FillPrograms()
end sub

sub FillChannelData(objChannel)
    if m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0
        channelData = m.epgGrid.content.getChild(objChannel.sectionIndex).getChild(objChannel.channelIndex)
        channelData.isLoading = objChannel.isLoading
        tempData = channelData.programData
        tempData = objChannel
        tempData.isWatching = channelData.programData.isWatching
        onNowData = getOnNowData(tempData.limitedData)
        if onNowData <> invalid and onNowData.title <> invalid and tempData.isWatching
            m.livePlayerLabel.text = onNowData.title
        end if
        channelData.programData = tempData
    end if
end sub

sub FillPrograms()
    if (m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0 and m.liveMiniPlayer.content = invalid)
        programObj = getTheCurrentSelectedItem(0)
        if programObj <> invalid and programObj.programData <> invalid and programObj.programData.liveUrl <> invalid
            videoContent = createObject("RoSGNode", "ContentNode")
            videoContent.live = true
            videoContent.url = programObj.programData.liveUrl
            if programObj.programData.limitedData <> invalid and programObj.programData.limitedData.count() > 0
                videoContent.addFields({"limitedData" : programObj.programData.limitedData})
                onNowData = getOnNowData(programObj.programData.limitedData)
                if onNowData <> invalid and onNowData.title <> invalid
                    m.livePlayerLabel.text = onNowData.title
                end if
            end if
            setIsWatching(0)
            m.liveMiniPlayer.content = videoContent
            m.liveMiniPlayer.enableUI = false
            m.liveMiniPlayer.control = "play"
            m.liveMiniPlayer.content = videoContent
        end if
    end if
    checkPaginationQueueItem()
end sub

sub checkPaginationQueueItem()
    if m.paginationQueue.count() > 0
        for i=0 to (m.paginationLimit - m.apiCallCount) - 1
            programData = m.paginationQueue.shift()
            if programData <> invalid
                getChannelPrograms(programData.data, programData.sectionName, programData.sectionIndex, programData.channelIndex)
            end if
        end for
    end if
end sub

function GetDayFromDate(startTime as dynamic, currentTime as dynamic)
    isCurrentDay = false
    a = startTime.Split("T")
    b = currentTime.Split("T")
    if a[0] = b[0]
        isCurrentDay = true
    end if
    return isCurrentDay
end function

sub addSection(sectiontext as string)
    sectionContent = m.epgContent.createChild("ContentNode")
    sectionContent.CONTENTTYPE = "SECTION"
    sectionContent.TITLE = sectiontext
end sub

sub addItem(itemData as object, isLoading = false)
    if m.epgContent <> invalid and m.epgContent <> invalid and m.epgContent.getChildCount() > 0
        for i=0 to m.epgContent.getChildCount() - 1
            sectionContent = m.epgContent.getChild(i)
            if sectionContent <> invalid and sectionContent.TITLE = itemData.sectionName
                exit for
            end if
        end for
        item = sectionContent.createChild("ContentNode")
        item.addFields({"programData": itemData, "isLoading": isLoading})
    end if
end sub

sub addItemPagination(itemData as object)
    if m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0
        index = -1
        for i=0 to m.epgGrid.content.getChildCount() - 1
            sectionContent = m.epgGrid.content.getChild(i)
            index = i
            if sectionContent <> invalid and sectionContent.TITLE = itemData.sectionName
                exit for
            end if
        end for
        m.epgGrid.content.removeChild(sectionContent)
        item = CreateObject("roSGNode", "ContentNode")
        item.addFields({"programData": itemData})
        sectionContent.appendChild(item)
        m.epgGrid.content.insertChild(sectionContent, index)
    end if
end sub

sub destroy()
    m.scene.callFunc("showHideLoader", false)
    m.paginationQueue = []
    m.epgGrid.content = invalid
    if m.liveMiniPlayer <> invalid
        if m.liveMiniPlayer.content <> invalid
            m.liveMiniPlayer.enableUI = false
            m.liveMiniPlayer.control = "stop"
            m.liveMiniPlayer.content = invalid
            m.livePlayerLabel.text = ""
        end if
        m.liveMiniPlayerGrp.removeChild(m.liveMiniPlayer)
        m.liveMiniPlayer = invalid
    end if
    if m.refreshTimer <> invalid
        m.refreshTimer.control = "stop"
    end if
    destroyTasks()
end sub

sub destroyTasks()
    if m.programApiTask <> invalid
        m.programApiTask.UnObserveField("result")
        m.programApiTask.control = "stop"
        m.programApiTask = invalid
    end if
    if m.getEPGResultsTask <> invalid
        m.getEPGResultsTask.UnObserveField("result")
        m.getEPGResultsTask.control = "stop"
        m.getEPGResultsTask = invalid
    end if
    if m.UpdateProgressTask <> invalid
        m.UpdateProgressTask.UnObserveField("progressUpdated")
        m.UpdateProgressTask.control = "stop"
    end if
end sub

sub OnFocusedChild()
    if m.top.hasFocus() then
        isRestored = RestoreFocus()
        if not isRestored
            SetFocus(m.categoryList)
        end if
        if (m.epgGrid <> invalid and m.epgGrid.content <> invalid and m.epgGrid.content.getChildCount() > 0)
            if m.liveMiniPlayer.content <> invalid
                m.liveMiniPlayer.control = "play"
            end if
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    print "EPGScreen OnkeyEvent : " key " " press
    handled = false
    if press then
        if key = "OK"
            if m.liveMiniPlayerGrp.hasFocus() and m.liveMiniPlayer.content <> invalid and m.liveMiniPlayer.content.url <> invalid
                selectedData = m.liveMiniPlayer.content
                videoNodeObj = CreateObject("roSGNode", "VideoNode")
                videoNodeObj.title = m.livePlayerLabel.text
                if selectedData.url <> invalid then videoNodeObj.hls_url = selectedData.url
                videoNodeObj.is_live = 1
                m.liveMiniPlayer.control = "stop"
                onNowData = getOnNowData(selectedData.limitedData)
                if onNowData <> invalid
                    videoNodeObj.title = onNowData.title
                end if
                videoNodeObj.limitedData = selectedData.limitedData
                m.scene.callFunc("StartVideo", videoNodeObj)
            end if
        else if key = "right"
            if m.categoryList.hasFocus() or m.liveMiniPlayerGrp.hasFocus()
                SetFocus(m.epgGrid)
            end if
            handled = true
        else if key = "left"
            if m.epgGrid.hasFocus()
                SetFocus(m.liveMiniPlayerGrp)
            end if
        else if key = "back"
        else if key = "down"
            if m.liveMiniPlayerGrp.hasFocus()
                SetFocus(m.categoryList)
                handled = true
            end if
        else if key = "up"
        end if
    end if
    return handled
end function