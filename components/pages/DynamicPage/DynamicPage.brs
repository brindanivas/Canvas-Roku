sub init()
    ' print "DynamicPage : Init"
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
    m.isFirstTime = true
    m.IsUpdateIcon = false
    m.rowListState = {
        "direction": "down",
        "state": "none"
    }
    m.lastRowFocus = 0
end sub

sub SetControls()
    m.scene = m.top.GetScene()
    m.rowListAnimation = m.top.findNode("rowListAnimation")
    m.transInterop = m.top.findNode("transInterop")
    m.UpdateTimer = m.top.findNode("UpdateTimer")
    m.UpdateProgress = m.top.findNode("UpdateProgress")
end sub

sub SetupFonts()
end sub

sub SetupColors()
end sub

sub Initialize()

end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChild")
    m.scene.observeField("IsUpdateData", "UpdateProgress")
    m.rowListAnimation.observeField("state", "OnRowListAnimationState")
    m.UpdateTimer.observeField("fire", "OnUpdateDetailsTimerExpired")
    m.UpdateProgress.observeField("fire", "OnUpdateDetailsTimerExpired")
    subscribeEvent("OnUpNextIndexChange")
end sub

sub onInitialize(event as dynamic)
    isInitialize = event.GetData()
    if isInitialize
        m.scene.CallFunc("StartStopBackgroundPlayer", "start")
        if m.rowList <> invalid and m.rowList.visible
            if not m.top.isLiveVideoPlay
                SetFocus(m.rowList)
                m.rowList.setFocus(false)
                SetFocus(m.rowList)
            end if
        end if
    end if
end sub

sub onDestroy(event as dynamic)
    destroy = event.GetData()
    if destroy
        m.scene.CallFunc("StartStopBackgroundPlayer", "destroy")
    end if
end sub

sub OnContentChange(event as dynamic)
    content = event.getData()
    if content <> invalid
        if content.getChildCount() > 0
            ShowDynamicRowList(content)
            m.rowList.visible = true
        end if
    end if

end sub

sub OnUpNextUpdate(index as dynamic)
    rowItemSelected = m.rowList.rowItemSelected
    m.rowList.jumpToRowItem = [rowItemSelected[0], index]
end sub


sub OnUpdateContentChange(event as dynamic)
    content = event.getData()
    if content <> invalid
        if content.Count() > 0
            m.rowList.paginationContent = content
        end if
    end if
end sub

sub OnUpdateRowContentChange(event as dynamic)
    content = event.getData()
    if content <> invalid
        if content.Count() > 0 and m.rowList <> invalid
            m.rowList.paginationRowContent = content
        end if
    end if
end sub

sub UpdateLiveData()
    print "DynamicPage : UpdateLiveData : "
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
                        ' dataArray.push([id,i,j])
                    end if
                end for
            end if
        end for
    end if
    if diffTimeDataArray.count() > 0
        diffTimeDataArray.sort()
        print "DynamicPage : UpdateLiveData : Timer Enable : " diffTimeDataArray[0]
        m.IsUpdateIcon = true
        m.UpdateTimer.duration = diffTimeDataArray[0]
        m.UpdateTimer.control = "start"
    end if
end sub

sub OnUpdateDetailsTimerExpired()
    print "DynamicPage : OnUpdateDetailsTimerExpired : "
    print "DynamicPage : OnUpdateDetailsTimerExpired : IsStopUpdateProgressTimer " m.scene.IsStopUpdateProgressTimer
    if m.scene.IsStopUpdateProgressTimer = false
        if m.rowList <> invalid
            for i = 0 to m.rowList.playlistContent.getChildCount() - 1 step 1
                rowData = m.rowList.playlistContent.getChild(i)
                if rowData.program_type = "event"
                    for j = 0 to m.rowList.playlistContent.getChild(i).getChildCount() - 1 step 1
                        itemData = m.rowList.playlistContent.getChild(i).getChild(j)
                        if itemData.currentDateTimeSecond <> invalid and itemData.playList_program_type = "event"
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

sub UpdateProgress()
    print "DynamicPage : UpdateProgress : "
    UpdateProgressTask = CreateObject("roSGNode", "UpdateProgressTask")
    UpdateProgressTask.functionName = "UpdateProgress"
    UpdateProgressTask.rowList = m.rowList
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
    return data
end function

sub OnRowListAnimationState(event as dynamic)
    m.rowListState.state = event.getData()
end sub

sub onRowFocused(event as object)
    index = event.GetData()
    node = event.getRoSGNode()
    ' childRow = node.content.getChild(index)
    lastRowIndex = node.content.getChildCount() - 1
    if (index >= 0 and lastRowIndex - 2 <= index and index < m.top.totalPlaylist - 1 and m.top.isApiLoaded)
        m.scene.callFunc("tabPlayListPagination", m.top.currentPage + 1)
    end if
end sub

sub onRowItemFocused(event as object)
    index = event.GetData()
    node = event.getRoSGNode()
    if m.lastRowFocus <> index[0]
        m.lastRowFocus = index[0]
        m.top.currentRowPage = 1
        if index[1] > 0
            m.top.currentRowPage = Cint(index[1] / GlobalGet("appConfig").perPageVideos) + 1
        end if
    end if
    childRow = node.content.getChild(index[0])
    numVideosRowPage = Cint(childRow.videos_count / GlobalGet("appConfig").perPageVideos)
    if m.top.currentRowPage <= numVideosRowPage
        lastItemIndex = node.content.getChild(index[0]).getChildCount() - 1
        if (index[1] <> 0 and lastItemIndex - 3 <= index[1] and index[1] < childRow.videos_count and m.top.isApiLoaded)
            m.rowList.paginationRowFocusIndex = index[0]
            m.scene.callFunc("tabPlayListDataPagination", childRow, m.top.currentRowPage + 1, childRow.tabId, childRow._id)
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

sub OnVisibleChange(event as dynamic)
    isVisible = event.getData()
    print "DynamicPage : OnVisibleChange : isVisible : " isVisible
end sub

sub OnFocusedChild()
    print "DynamicPage : OnFocusedChild : "m.top.hasFocus() " "m.top.IsInFocusChain()
    if m.top.hasFocus()
        isRestored = RestoreFocus()
        if not isRestored and m.rowList <> invalid
            if m.rowList <> invalid and m.rowList.visible
                if (not m.top.isLiveVideoPlay) then m.scene.CallFunc("StartStopBackgroundPlayer", "start")
                SetFocus(m.rowList)
                m.rowList.setFocus(false)
                SetFocus(m.rowList)
            end if
        else
            m.scene.CallFunc("StartStopBackgroundPlayer", "start")
        end if
    end if
end sub

function OnDownClick()
    if m.top.downClick
        if m.rowListState.state <> "stopped"
            m.rowListAnimation.control = "finish"
        end if
        if m.rowList <> invalid and m.rowListState.direction <> "up" and (m.rowListState.state = "stopped" or m.rowListState.state = "none")
            StartRowListAnimation("up")
            m.scene.CallFunc("StartStopBackgroundPlayer", "start")
            SetFocus(m.rowList)
            m.rowList.setFocus(false)
            SetFocus(m.rowList)
        end if
        m.top.downClick = false
    end if
end function

function StartRowListAnimation(direction)
    m.transInterop.fieldToInterp = "rowList.translation"
    if m.rowListState.state <> "stopped"
        m.rowListAnimation.control = "finish"
    end if
    m.rowListState.direction = direction
    m.rowListState.state = "started"
    if direction = "up"
        m.transInterop.keyValue = [[0.0, 830.0], [0.0, 217.0]]
        m.rowListAnimation.control = "start"
    else if direction = "down"
        m.transInterop.keyValue = [[0.0, 217.0], [0.0, 830.0]]
        m.rowListAnimation.control = "start"
    end if
end function

function ShowDynamicRowList(playlistContent)
    rowList = CreateObject("roSGNode", "DynamicRowList")
    rowList.id = "rowList"
    rowList.focusxOffset = [90]
    rowList.rowLabelOffset = [[106, 10]]
    rowList.observeField("rowItemSelected", "onRowItemSelected")
    rowList.observeField("rowItemFocused", "onRowItemFocused")
    rowList.observeField("itemFocused", "onRowFocused")
    rowList.playlistContent = playlistContent.clone(true)
    m.top.appendChild(rowList)
    m.rowList = rowList
    OnLiveVideoPlay()
    if m.isFirstTime
        m.isFirstTime = false
        UpdateLiveData()
    end if
end function


function OnLiveVideoPlay() as void
    if m.rowList = invalid then return
    if m.top.isLiveVideoPlay
        m.rowList.translation = [0, 830]
    else
        m.rowList.translation = [0, 217]
    end if
end function

function onKeyEvent(key as string, press as boolean) as boolean
    result = false
    if press
        print "DynamicPage : onKeyEvent : key = " key " press = " press
        if key = "OK"
            ' TODO
        else if key = "back"
            if m.rowList <> invalid and m.rowList.hasFocus() or m.rowList.IsInFocusChain()
                if m.rowList.rowitemFocused[0] <> 0
                    m.rowList.jumpToItem = 0
                    result = true
                else if m.top.isLiveVideoPlay
                    StartRowListAnimation("down")
                end if
            end if
        else if key = "up" and m.top.isLiveVideoPlay
            StartRowListAnimation("down")
        end if
    end if

    return result
end function
