sub init()
    ' print "DynamicGridPage : Init"
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetControls()
    SetObservers()
    CreatePaginationSpinner()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.IsUpdateIcon = false
end sub

sub SetControls()
    m.scene = m.top.GetScene()
    m.sideMenu = m.top.findNode("sideMenu")
    m.UpdateTimer = m.top.findNode("UpdateTimer")
    m.UpdateProgress = m.top.findNode("UpdateProgress")
    m.gPaginationLoader = m.top.findNode("gPaginationLoader")
    m.bsPaginationloader = m.top.findNode("bsPaginationloader")
    m.noData = m.top.findNode("noData")
end sub

sub SetupFonts()
    m.noData.font = m.fonts.robotoMed30
end sub

sub SetupColors()
end sub


sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChild")
    m.sideMenu.observeField("itemSelected", "onItemSelectedChanged")
    m.scene.observeField("IsUpdateData", "UpdateProgress")
    m.UpdateTimer.observeField("fire", "OnUpdateDetailsTimerExpired")
    m.UpdateProgress.observeField("fire", "OnUpdateDetailsTimerExpired")
    subscribeEvent("OnUpNextIndexChange")
end sub

sub CreatePaginationSpinner()
    m.bsPaginationloader.poster.uri = "pkg:/images/icons/loader.png"
    m.bsPaginationloader.poster.width = "60"
    m.bsPaginationloader.poster.height = "60"
end sub

sub onInitialize(event as dynamic)
    initialize = event.GetData()
    if initialize
        if m.sideMenu.content <> invalid
            m.scene.CallFunc("StartStopBackgroundPlayer", "start")
            SetFocus(m.sideMenu)
        end if
    end if
end sub

sub OnContentChange(event as dynamic)
    content = event.getData()
    if content <> invalid
        m.sideMenu.content = content
    end if
end sub

sub OnUpNextUpdate(index as dynamic)
    if m.markUpGrid <> invalid
        m.markUpGrid.jumpToItem = index
    end if
end sub

sub OnVisibleChange(event as dynamic)
    isVisible = event.getData()
    print "DynamicGridPage : OnVisibleChange : isVisible : " isVisible
end sub

sub OnFocusedChild()
    print "DynamicGridPage : OnFocusedChild : "m.top.hasFocus() " "m.top.IsInFocusChain()
    if m.top.hasFocus()
        isRestored = RestoreFocus()
        if not isRestored
            if m.sideMenu.content <> invalid
                m.scene.CallFunc("StartStopBackgroundPlayer", "start")
                SetFocus(m.sideMenu)
            end if
        else
            m.scene.CallFunc("StartStopBackgroundPlayer", "start")
        end if
    end if
end sub

sub onDestroy(event as dynamic)
    destroy = event.GetData()
    if destroy
        m.scene.CallFunc("StartStopBackgroundPlayer", "destroy")
    end if
end sub

function onItemSelectedChanged(event as dynamic)
    index = event.getData()
    item = m.sideMenu.content.getChild(index)
    if item <> invalid
        m.top.currentRowPage = 1
        SetContent(item)
    end if
end function

function SetContent(item)
    child = item.getChild(0)
    ClearContentArea()
    if item.getChildCount() = 0 and not item.hasSubPlayList
        m.noData.visible = true
    end if
    if item.hasSubPlayList
        'TODO : ShowDynamicRowList'
        m.lastRowFocus = 0
        m.rowData = CreateObject("roSGNode", "ContentNode")
        m.totalRows = item.childPlaylists.Count()
        playIndex = 1
        m.playCount = 0
        m.gPaginationLoader.visible = true
        m.top.isApiLoaded = false
        sideMenuBoundingRect = m.sideMenu.boundingRect()
        m.bsPaginationloader.translation = [(1920 - sideMenuBoundingRect.x + sideMenuBoundingRect.width + 52) / 2, 520]
        for each playList in item.childPlaylists
            playListItem = ContentHelpers().oneDimSingleItem2ContentNode(playList, "PlayListNode")
            playListItem.tabId = item.tabId
            playListItem.tabLayout = item.tabLayout
            GetTabPlayListData(playListItem, playIndex, m.top.currentRowPage)
            m.rowData.appendChild(playListItem)
            playIndex++
        end for
    else
        ShowDynamicMarkupGrid(item)
        m.noData.visible = false
    end if
    if child <> invalid
        UpdateLiveData()
    end if
end function


sub GetTabPlayListData(playListItem, playlistIndex, pageNo = 1 as integer)
    m.top.currentRowPage = pageNo
    requestData = { tabId: playListItem.tabId, playListId: playListItem._id, pageNo: pageNo }
    m.getHBCUTabDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getHBCUTabDataTask.functionName = "GetHBCUTabPlayListData"
    m.getHBCUTabDataTask.requestData = requestData
    m.getHBCUTabDataTask.additionalParams = {
        "playListItem": playListItem,
        "playlistIndex": playlistIndex
    }
    m.getHBCUTabDataTask.ObserveField("result", "OnGetHBCUTabPlaylistDataAPIResponse")
    m.getHBCUTabDataTask.control = "RUN"
end sub

sub OnGetHBCUTabPlaylistDataAPIResponse(event as dynamic)
    apiResponseData = event.getData()
    taskNode = event.getRoSGNode()
    print "DynamicGridPage: OnGetHBCUTabPlaylistDataAPIResponse : apiResponseData - " apiResponseData
    if (apiResponseData.data <> invalid and apiResponseData.ok and apiResponseData.data.staus <> "error")
        tabIndex = taskNode.requestData.tabId
        playListId = taskNode.requestData.playListId
        playListItem = taskNode.additionalParams.playListItem
        playlistIndex = taskNode.additionalParams.playlistIndex
        if (playListItem <> invalid)
            GetVideosData(playListItem, playlistIndex, apiResponseData.data.content, playListItem.tabLayout)
        end if
    end if
end sub

function GetVideosData(node, playlistIndex, videos, tabLayout)
    for each videoData in videos
        if videoData.type = "series"
            videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "PlayListNode")
            
            videoItem.description = videoItem.short_description
            videoItem.is_lock = node.isExclusiveContent
            videoItem.program_type = videoData.type
        else
            videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
            videoItem.playList_content_type = node.content_type
            videoItem.playList_program_type = node.program_type
            videoItem.is_lock = node.isExclusiveContent
            videoItem.program_type = videoData.type
            if (not IsNullOrEmpty(videoItem.start_date_time))
                date = CreateObject("roDateTime")
                date.FromISO8601String(videoItem.start_date_time)
                date.ToLocalTime()
                videoItem.start_date_time = date.ToISOString()
            end if

            if (not IsNullOrEmpty(videoItem.end_date_time))
                date = CreateObject("roDateTime")
                date.FromISO8601String(videoItem.end_date_time)
                date.ToLocalTime()
                videoItem.end_date_time = date.ToISOString()
            end if
        end if
        videoItem.itemType = tabLayout
        node.appendChild(videoItem)
    end for
    m.playCount++
    if m.totalRows = m.playCount
        if m.top.currentRowPage = 1
            if m.rowData.getChildCount() > 0
                ShowDynamicRowList(m.rowData)
                m.noData.visible = false
            else
                m.noData.visible = true
                m.gPaginationLoader.visible = false
                m.top.isApiLoaded = true
            end if
        end if
    end if
    m.top.isApiLoaded = true
end function

sub UpdateProgress()
    UpdateProgressTask = CreateObject("roSGNode", "UpdateProgressTask")
    UpdateProgressTask.functionName = "UpdateProgressDynamicGrid"
    UpdateProgressTask.rowList = m.rowList
    UpdateProgressTask.markUpGrid = m.markUpGrid
    UpdateProgressTask.control = "RUN"
end sub

function GetObjectToUpdateLock()
    data = {
        "rowList": invalid,
        "markUpGrid": invalid
    }
    if m.rowList <> invalid
        data.rowList = m.rowList
    end if
    if m.markUpGrid <> invalid and m.markUpGrid.playlistContent <> invalid
        data.markUpGrid = m.markUpGrid
    end if
    return data
end function

function ShowDynamicRowList(playlistContent)
    rowList = CreateObject("roSGNode", "DynamicRowList")
    sideMenuBoundingRect = m.sideMenu.boundingRect()
    rowList.translation = [sideMenuBoundingRect.x + sideMenuBoundingRect.width + 52, sideMenuBoundingRect.y]
    rowList.width = 1920 - (sideMenuBoundingRect.x + sideMenuBoundingRect.width + 52)
    rowList.playlistContent = playlistContent.clone(true)
    rowList.observeField("rowItemSelected", "onRowItemSelected")
    rowList.observeField("rowItemFocused", "onRowItemFocused")
    m.gPaginationLoader.visible = false
    m.top.appendChild(rowList)
    m.rowList = rowList
end function

function ShowDynamicMarkupGrid(playlistContent)
    m.top.currentRowPage = 0
    markUpGrid = CreateObject("roSGNode", "DynamicMarkUpGrid")
    sideMenuBoundingRect = m.sideMenu.boundingRect()
    markUpGrid.translation = [sideMenuBoundingRect.x + sideMenuBoundingRect.width + 52, sideMenuBoundingRect.y]
    ' markUpGrid.playlistContent = playlistContent.clone(true)
    markUpGrid.observeField("itemSelected", "onItemSelected")
    markUpGrid.observeField("itemFocused", "onItemFocused")
    m.top.appendChild(markUpGrid)
    m.markUpGrid = markUpGrid
    m.playlistContent = playlistContent
    m.totalPages = playlistContent.videos_count / GlobalGet("appConfig").perPageVideos
    m.gPaginationLoader.visible = true
    m.bsPaginationloader.translation = [(1920 - sideMenuBoundingRect.x + sideMenuBoundingRect.width + 52) / 2, 520]
    m.scene.callFunc("tabPlayListDataPagination", playlistContent, m.top.currentRowPage + 1, playlistContent.tabId, playlistContent._id)
end function

sub onRowItemFocused(event as dynamic)
    index = event.GetData()
    node = event.getRoSGNode()
    if m.lastRowFocus <> index[0]
        m.lastRowFocus = index[0]
        m.top.currentRowPage = Fix(index[1] / GlobalGet("appConfig").perPageVideos) + 1
    end if

    lastItemIndex = node.content.getChild(index[0]).getChildCount() - 1
    videosCount = node.content.getChild(index[0]).videos_count
    m.totalPages = videosCount / GlobalGet("appConfig").perPageVideos
    sideMenuBoundingRect = m.sideMenu.boundingRect()
    if (index[1] <> 0 and lastItemIndex - 3 <= index[1] and index[1] < videosCount and m.top.currentRowPage < m.totalPages and m.top.isApiLoaded)
        GetTabPlayListData(node.content.getChild(index[0]), index[0], m.top.currentRowPage + 1)
    end if
end sub

sub onItemFocused(event as dynamic)
    index = event.GetData()
    node = event.getRoSGNode()

    lastItemIndex = node.content.getChildCount() - 1
    sideMenuBoundingRect = m.sideMenu.boundingRect()
    if (index <> 0 and lastItemIndex - 3 <= index and index < node.content.videos_count - 1 and m.top.currentRowPage < m.totalPages and m.top.isApiLoaded)
        m.gPaginationLoader.visible = true
        m.bsPaginationloader.translation = [m.markUpGrid.boundingRect().x + (m.markUpGrid.boundingRect().width / 2) - 40, 820]
        m.scene.callFunc("tabPlayListDataPagination", node.content, m.top.currentRowPage + 1, node.content.tabId, node.content._id)
    end if
end sub

sub OnUpdateRowContentChange(event as dynamic)
    content = event.getData()
    if content <> invalid
        if m.top.currentRowPage = 1
            for i = 0 to content.Count() - 1
                m.playlistContent.appendChild(content[i])
            end for
            m.markUpGrid.playlistContent = m.playlistContent
        else
            m.markUpGrid.paginationContent = content
        end if
    end if
    m.gPaginationLoader.visible = false
end sub


sub onItemSelected(event as object)
    index = event.GetData()
    node = event.getRoSGNode()
    childRow = node.playlistContent
    if (childRow <> invalid)
        isPlaybackAllowed = true
        video = childRow.getChild(index)
        if (childRow.program_type = "event")
            date = CreateObject("roDateTime")
            date.ToLocalTime()
            currentTimeInSec = date.AsSeconds()
            startTimeInSec = 0
            endTimeInSec = 0
            if video.start_date_time <> invalid and video.start_date_time <> ""
                date.FromISO8601String(video.start_date_time)
                startTimeInSec = date.AsSeconds()
            end if
            if video.end_date_time <> invalid and video.end_date_time <> ""
                date.FromISO8601String(video.end_date_time)
                endTimeInSec = date.AsSeconds()
            end if
            if (startTimeInSec <= currentTimeInSec and currentTimeInSec < endTimeInSec)
                isPlaybackAllowed = true
            else
                isPlaybackAllowed = false
                if currentTimeInSec > endTimeInSec
                    isPlaybackAllowed = true
                    'm.scene.CallFunc("ShowTopRightCornerToast", "This event seems completed.")
                else
                    m.scene.CallFunc("ShowTopRightCornerToast", "This event is yet not started.")
                end if
            end if
        end if
        if (isPlaybackAllowed = true)
            m.scene.CallFunc("StartStopBackgroundPlayer", "stop")
            m.top.datarray = {
                programType: video.program_type
                ItemName: childRow.program_type
                selectedIndex: index
                selectedRowItem: childRow
                ListType: "MarkUpGrid"
            }
        end if
    end if
end sub

sub UpdateLiveData()
    ' dataArray=[]
    diffTimeDataArray = []
    if m.rowList <> invalid
        for i = 0 to m.rowList.playlistContent.getChildCount() - 1 step 1
            rowData = m.rowList.playlistContent.getChild(i)
            if rowData.program_type = "event"
                for j = 0 to m.rowList.playlistContent.getChild(i).getChildCount() - 1 step 1
                    itemData = m.rowList.playlistContent.getChild(i).getChild(j)
                    if itemData.playList_program_type = "event"
                        if itemData.start_date_time <> invalid and itemData.start_date_time <> "" and itemData.end_date_time <> invalid and itemData.end_date_time <> ""
                            DiffTimeData = GetTimeDifference(itemData)
                            diffTimeDataArray.push(DiffTimeData)
                        end if
                    end if
                end for
            end if
        end for
    end if
    if m.markUpGrid <> invalid and m.markUpGrid.playlistContent <> invalid
        for i = 0 to m.markUpGrid.playlistContent.getChildCount() - 1 step 1
            itemData = m.markUpGrid.playlistContent.getChild(i)
            if itemData.playList_program_type = "event"
                if itemData.start_date_time <> invalid and itemData.start_date_time <> "" and itemData.end_date_time <> invalid and itemData.end_date_time <> ""
                    DiffTimeData = GetTimeDifference(itemData)
                    diffTimeDataArray.push(DiffTimeData)
                end if
                ' dataArray.push([id,i,j])
            end if
        end for
    end if
    if m.sideMenu <> invalid
        for i = 0 to m.sideMenu.content.getChildCount() - 1 step 1
            rowData = m.sideMenu.content.getChild(i)
            if rowData.program_type = "event"
                for j = 0 to m.sideMenu.content.getChild(i).getChildCount() - 1 step 1
                    itemData = m.sideMenu.content.getChild(i).getChild(j)
                    if itemData.start_date_time <> invalid and itemData.start_date_time <> "" and itemData.end_date_time <> invalid and itemData.end_date_time <> ""
                        DiffTimeData = GetTimeDifference(itemData)
                        diffTimeDataArray.push(DiffTimeData)
                    end if
                    ' dataArray.push([id,i,j])
                end for
            end if
        end for
    end if
    if diffTimeDataArray.count() > 0
        diffTimeDataArray.sort()
        ' if (diffTimeDataArray[0] / 60 <= 10)
        print "DynamicGridPage : UpdateLiveData : Timer Enable : " diffTimeDataArray[0]
        m.IsUpdateIcon = true
        m.UpdateTimer.duration = diffTimeDataArray[0]
        m.UpdateTimer.control = "start"
        ' end if
    end if
end sub

sub OnUpdateDetailsTimerExpired()
    print "DynamicGridPage : UpdateTimerTimerExpired : "
    print "DynamicGridPage : UpdateTimerTimerExpired : IsStopUpdateProgressTimer " m.scene.IsStopUpdateProgressTimer
    if m.scene.IsStopUpdateProgressTimer = false
        if m.rowList <> invalid
            for i = 0 to m.rowList.playlistContent.getChildCount() - 1 step 1
                rowData = m.rowList.playlistContent.getChild(i)
                if rowData.program_type = "event"
                    for j = 0 to m.rowList.playlistContent.getChild(i).getChildCount() - 1 step 1
                        itemData = m.rowList.playlistContent.getChild(i).getChild(j)
                        if itemData.playList_program_type <> invalid and itemData.playList_program_type = "event" and itemData.currentDateTimeSecond <> invalid
                            if itemData.currentDateTimeSecond
                                itemData.currentDateTimeSecond = false
                            else
                                itemData.currentDateTimeSecond = true
                            end if
                        end if
                    end for
                end if
            end for
        end if
        if m.markUpGrid <> invalid and m.markUpGrid.playlistContent <> invalid
            for i = 0 to m.markUpGrid.playlistContent.getChildCount() - 1 step 1
                itemData = m.markUpGrid.playlistContent.getChild(i)
                if itemData.playList_program_type <> invalid and itemData.playList_program_type = "event" and itemData.currentDateTimeSecond <> invalid
                    if itemData.currentDateTimeSecond
                        itemData.currentDateTimeSecond = false
                    else
                        itemData.currentDateTimeSecond = true
                    end if
                end if
            end for
        end if
        if m.sideMenu <> invalid
            for i = 0 to m.sideMenu.content.getChildCount() - 1 step 1
                data = m.sideMenu.content.getChild(i)
                if data.program_type = "event"
                    for j = 0 to m.sideMenu.content.getChild(i).getChildCount() - 1 step 1
                        itemData = m.sideMenu.content.getChild(i).getChild(j)
                        if itemData.playList_program_type <> invalid and itemData.playList_program_type = "event" and itemData.currentDateTimeSecond <> invalid
                            if itemData.currentDateTimeSecond
                                itemData.currentDateTimeSecond = false
                            else
                                itemData.currentDateTimeSecond = true
                            end if
                        end if
                    end for
                end if
            end for
        end if
        if m.IsUpdateIcon
            m.IsUpdateIcon = false
            UpdateLiveData()
        end if
    end if
end sub

sub onRowItemSelected(event as object)
    index = event.GetData()
    node = event.getRoSGNode()
    childRow = node.content.getChild(index[0])
    childNode = childRow.getChild(index[1])
    if (childNode <> invalid)
        isPlaybackAllowed = true
        if (childRow.program_type = "event")
            video = childRow.getChild(index[1])
            date = CreateObject("roDateTime")
            date.ToLocalTime()
            currentTimeInSec = date.AsSeconds()
            startTimeInSec = 0
            endTimeInSec = 0
            if video.start_date_time <> invalid and video.start_date_time <> ""
                date.FromISO8601String(video.start_date_time)
                startTimeInSec = date.AsSeconds()
            end if
            if video.end_date_time <> invalid and video.end_date_time <> ""
                date.FromISO8601String(video.end_date_time)
                endTimeInSec = date.AsSeconds()
            end if
            if (startTimeInSec <= currentTimeInSec and currentTimeInSec < endTimeInSec)
                isPlaybackAllowed = true
            else
                isPlaybackAllowed = false
                if currentTimeInSec > endTimeInSec
                    isPlaybackAllowed = true
                    'm.scene.CallFunc("ShowTopRightCornerToast", "This event seems completed.")
                else
                    m.scene.CallFunc("ShowTopRightCornerToast", "This event is yet not started.")
                end if
            end if
        end if
        if (isPlaybackAllowed = true)
            m.scene.CallFunc("StartStopBackgroundPlayer", "stop")
            m.top.datarray = {
                programType: childNode.program_type
                ItemName: childRow.program_type
                selectedIndex: index[1]
                selectedRowItem: childRow
                ListType: "RowList"
            }
        end if
    end if
end sub

sub ClearContentArea()
    if m.markUpGrid <> invalid then
        m.top.removeChild(m.markUpGrid)
        m.markUpGrid = invalid
    end if

    if m.rowList <> invalid then
        m.top.removeChild(m.rowList)
        m.rowList = invalid
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    result = false
    if press
        print "DynamicGridPages : onKeyEvent : key = " key " press = " press
        if key = "OK"
            result = true
        else if key = "left"
            if (m.markUpGrid <> invalid and m.markUpGrid.hasFocus()) or (m.rowList <> invalid and m.rowList.hasFocus())
                SetFocus(m.sideMenu)
                result = true
            end if
        else if key = "right"
            if m.sideMenu.hasFocus()
                if m.markUpGrid <> invalid
                    SetFocus(m.markUpGrid)
                    m.markUpGrid.setFocus(false)
                    SetFocus(m.markUpGrid)
                    result = true
                else if m.rowList <> invalid
                    SetFocus(m.rowList)
                    m.rowList.setFocus(false)
                    SetFocus(m.rowList)
                    result = true
                end if
            end if
        end if
    end if
    return result
end function
