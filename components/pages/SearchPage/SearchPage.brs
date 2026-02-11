sub init()
    print "SearchPage : Init"
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetControls()
    SetObservers()
end sub

sub SetLocals()
    print "SearchPage : SetLocals"
    m.scene = m.top.GetScene()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.lastSearchTerm = ""
    m.isFirstTime = true
    m.IsUpdateIcon = false
end sub

sub SetControls()
    print "SearchPage : SetControls"
    m.miniKeyboard = m.top.FindNode("miniKeyboard")
    m.lNoItems = m.top.findNode("lNoItems")
    m.lSearchTitle = m.top.findNode("lSearchTitle")
    m.lSearchPlaceHolder = m.top.findNode("lSearchPlaceHolder")
    m.lSearchPlaceHolder.text = "Search " + GlobalGet("AppTitle") + " Content"
    m.gPreLoader = m.top.findNode("gPreLoader")
    m.bsPreloader = m.top.findNode("bsPreloader")
    m.lPreloader = m.top.findNode("lPreloader")
    m.UpdateTimer = m.top.findNode("UpdateTimer")
    m.UpdateProgress = m.top.findNode("UpdateProgress")
end sub

sub SetupFonts()
    print "SearchPage : SetupFonts"
    m.lSearchTitle.font = m.fonts.robotoReg66
    m.lSearchPlaceHolder.font = m.fonts.robotoReg66
    m.lNoItems.font = m.fonts.robotoReg24
end sub

sub SetupColors()
    print "SearchPage : SetupColors"
    m.lSearchTitle.color = m.theme.White
    m.lNoItems.color = m.theme.White
    m.lSearchPlaceHolder.color = m.theme.GrayTwo
    m.miniKeyboard.focusedKeyColor = m.theme.KeyFocused
    m.miniKeyboard.keyColor = m.theme.MenuUnFocused
end sub

sub SetObservers()
    print "SearchPage : SetObservers"
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChild")
    m.scene.observeField("IsUpdateData", "UpdateProgress")
    m.miniKeyboard.observeField("text", "OnKeyboard_TextChange")
    m.UpdateTimer.observeField("fire", "OnUpdateDetailsTimerExpired")
    m.UpdateProgress.observeField("fire", "OnUpdateDetailsTimerExpired")
end sub

sub onInitialize(event as dynamic)
    print "SearchPage : onInitialize"
    initialize = event.GetData()
    if initialize
        CreateBusySpinnerControls()
        m.currentPage = 1
        m.miniKeyboard.focusBitmapUri = "pkg:/images/others/keyboard_key.9.png"
        SetFocus(m.miniKeyboard)
    end if
end sub

'=======> ShowHide Loader'
sub CreateBusySpinnerControls()
    m.lPreloader.text = "Please wait..."
    m.bsPreloader.poster.uri = "pkg:/images/loader/loader.png"
    m.bsPreloader.poster.width = "160"
    m.bsPreloader.poster.height = "160"
    m.lPreloader.color = "#FFFFFF"
    m.lPreloader.font = m.fonts.robotoBold30
end sub

sub ShowHideLoader(isShow as boolean, message = "Please wait..." as string, issetFocus = true as boolean)
    m.gPreLoader.visible = isShow
    if issetFocus
        'm.gPreLoader.setFocus(isShow)
        if (isShow = false)
            RestoreFocus()
        end if
    end if
    m.lPreloader.text = message
end sub
'=======> ShowHide Loader'

sub OnKeyboard_TextChange()
    print "SearchPage : OnKeyboard_TextChange"
    m.lNoItems.visible = false
    searchTerm = m.miniKeyboard.text
    m.lSearchTitle.text = searchTerm
    print "SearchPage : OnKeyboard_TextChange : Search String " searchTerm
    if (searchTerm <> m.lastSearchTerm and searchTerm <> "")
        m.lSearchPlaceHolder.visible = false
        ClearContentArea()
        ShowHideLoader(true)
        m.currentPage = 1
        m.currentRowFocus = 0
        GetSearchDataFromServer(searchTerm, m.currentPage)
    else if (searchTerm = "")
        m.currentPage = 1
        m.currentRowFocus = 0
        m.lSearchPlaceHolder.visible = true
        ClearContentArea()
    end if
    m.lastSearchTerm = searchTerm
end sub

function GetSearchDataFromServer(searchString as string, page = 1 as integer, searchType = "" as string)
    print "SearchPage : GetSearchDataFromServer"
    if m.getSearchResultsTask <> invalid then
        m.getSearchResultsTask.control = "stop"
    end if
    requestData = { pageNo: page, searchType: searchType }
    m.getSearchDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getSearchDataTask.functionName = "GetHBCUSearchData"
    m.getSearchDataTask.requestData = requestData
    m.getSearchDataTask.searchData = searchString
    m.getSearchDataTask.ObserveField("result", "OnGetSearchDataAPIResponse")
    m.getSearchDataTask.control = "RUN"
end function

sub OnGetSearchDataAPIResponse(event as dynamic)
    print "SearchPage : OnGetSearchDataAPIResponse : "
    print "SearchPage : OnGetSearchDataAPIResponse : currentPage " m.currentPage
    apiResponseData = event.getData()
    if (apiResponseData <> invalid and apiResponseData.data <> invalid and apiResponseData.data.content.count() > 0 and apiResponseData.ok)
        print "apiResponseData - " apiResponseData
        print "apiResponseData.data - " apiResponseData.data
        print "apiResponseData.data.content - " apiResponseData.data.content
        print "apiResponseData.data.content.events - " apiResponseData.data.content.events
        print "apiResponseData.data.content.movies - " apiResponseData.data.content.movies
        print "apiResponseData.data.content.videos - " apiResponseData.data.content.videos

        ShowHideLoader(false)
        if m.currentPage = 1
            ClearContentArea()
            pageData = CreateObject("roSGNode", "ContentNode")
            contentFound = false
            for each item in apiResponseData.data.content
                list = CreateObject("roSGNode", "PlayListNode")
                list.program_type = item
                if item = "events"
                    list.title = "Events"
                    list.search_type = "event"
                    for each videoData in apiResponseData.data.content.events
                        videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
                        videoItem.playList_program_type = item
                        videoItem.is_lock = videoData.isExclusiveContent
                       
                        list.appendChild(videoItem)
                        contentFound = true
                    end for
                    if apiResponseData.data.content.events.count() > 0
                        pageData.appendChild(list)
                    end if
                else if item = "movies"
                    list.title = "Movies"
                    list.search_type = "movie"
                    for each videoData in apiResponseData.data.content.movies
                        videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
                        videoItem.playList_program_type = item
                        videoItem.is_lock = videoData.isExclusiveContent
                        list.appendChild(videoItem)
                        contentFound = true
                    end for
                    if apiResponseData.data.content.movies.count() > 0
                        pageData.appendChild(list)
                    end if
                else if item = "videos"
                    list.title = "Videos"
                    list.search_type = "video"
                    for each videoData in apiResponseData.data.content.videos
                        videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
                        videoItem.playList_program_type = item
                        videoItem.is_lock = videoData.isExclusiveContent
                        list.appendChild(videoItem)
                        contentFound = true
                    end for
                    if apiResponseData.data.content.videos.count() > 0
                        pageData.appendChild(list)
                    end if
                end if
            end for
            if contentFound = false
                ClearContentArea()
                m.lNoItems.visible = true
            else
                ShowDynamicRowList(pageData)
                SetFocus(m.miniKeyboard)
            end if
        else
            contentFound = false
            for each item in apiResponseData.data.content
                list = []
                if item = "events"
                    for each videoData in apiResponseData.data.content.events
                        videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
                        videoItem.playList_program_type = item
                        videoItem.is_lock = videoData.isExclusiveContent
                        ' videoItem.start_date_time = "2022-07-06T19:23:00+00:00"
                        ' videoItem.end_date_time = "2022-07-06T19:24:00+00:00"
                        list.push(videoItem)
                        contentFound = true
                    end for
                else if item = "movies"
                    for each videoData in apiResponseData.data.content.movies
                        videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
                        videoItem.playList_program_type = item
                        videoItem.is_lock = videoData.isExclusiveContent
                        list.push(videoItem)
                        contentFound = true
                    end for
                else if item = "videos"
                    for each videoData in apiResponseData.data.content.videos
                        videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
                        videoItem.playList_program_type = item
                        videoItem.is_lock = videoData.isExclusiveContent
                        list.push(videoItem)
                        contentFound = true
                    end for
                end if
            end for
            if list.count() > 0
                AppendDynamicRowListItems(list)
            end if
        end if
    else if m.currentPage = 1
        ClearContentArea()
        ShowHideLoader(false)
        m.lNoItems.visible = true
        print "SearchPage : OnGetSearchDataAPIResponse : No results : " m.lastSearchTerm
    end if
    m.getSearchDataTask = invalid
end sub

function ShowDynamicRowList(playlistContent)
    m.rowList = CreateObject("roSGNode", "DynamicRowList")
    miniKeyboardBoundingRect = m.miniKeyboard.boundingRect()
    m.rowList.translation = [miniKeyboardBoundingRect.x + miniKeyboardBoundingRect.width + 52, miniKeyboardBoundingRect.y + 110]
    m.rowList.width = 1920 - (miniKeyboardBoundingRect.x + miniKeyboardBoundingRect.width + 52)
    m.rowList.observeField("rowItemSelected", "onRowItemSelected")
    m.rowList.observeField("rowItemFocused", "onRowItemFocused")
    m.rowList.observeField("itemFocused", "onItemFocused")
    m.rowList.playlistContent = playlistContent.clone(true)
    m.top.appendChild(m.rowList)
    if m.isFirstTime
        m.isFirstTime = false
        UpdateLiveData()
    end if
end function

sub AppendDynamicRowListItems(items)
    if (m.rowList <> invalid)
        m.rowList.paginationRowFocusIndex = m.currentRowFocus
        m.rowList.paginationRowContent = items
    end if
end sub

sub UpdateLiveData()
    print "SearchPage : UpdateLiveData"
    ' dataArray=[]
    diffTimeDataArray = []
    if m.rowList <> invalid
        for i = 0 to m.rowList.playlistContent.getChildCount() - 1 step 1
            rowData = m.rowList.playlistContent.getChild(i)
            if rowData.program_type = "event" or rowData.program_type = "events"
                for j = 0 to m.rowList.playlistContent.getChild(i).getChildCount() - 1 step 1
                    itemData = m.rowList.playlistContent.getChild(i).getChild(j)
                    if itemData.playList_program_type = "event" or itemData.playList_program_type = "events"
                        if itemData.start_date_time <> invalid and itemData.start_date_time <> "" and itemData.end_date_time <> invalid and itemData.end_date_time <> ""
                            DiffTimeData = GetTimeDifference(itemData)
                            diffTimeDataArray.push(DiffTimeData)
                        end if
                    end if
                end for
            end if
        end for
    end if
    if diffTimeDataArray.count() > 0
        diffTimeDataArray.sort()
        print "SearchPage : UpdateLiveData : Timer Enable " diffTimeDataArray[0]
        m.IsUpdateIcon = true
        m.UpdateTimer.duration = diffTimeDataArray[0]
        m.UpdateTimer.control = "start"
    end if
end sub

sub OnUpdateDetailsTimerExpired()
    print "SearchPage : UpdateTimerTimerExpired"
    if m.rowList <> invalid
        for i = 0 to m.rowList.playlistContent.getChildCount() - 1 step 1
            rowData = m.rowList.playlistContent.getChild(i)
            if rowData.program_type = "event" or rowData.program_type = "events"
                for j = 0 to m.rowList.playlistContent.getChild(i).getChildCount() - 1 step 1
                    itemData = m.rowList.playlistContent.getChild(i).getChild(j)
                    if itemData.playList_program_type = "event" or itemData.playList_program_type = "events"
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
end sub

sub UpdateProgress()
    print "SearchPage : UpdateProgress : "
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
sub onItemFocused(event as object)
    index = event.GetData()
    ' if (m.currentRowFocus <> index)
    '     m.currentRowFocus = index
    ' end if
end sub

sub onRowItemFocused(event as object)
    index = event.GetData()
    node = event.getRoSGNode()
    childRow = node.content.getChild(index[0])
    lastItemIndex = node.content.getChild(index[0]).getChildCount() - 1
    if (index[1] <> 0 and lastItemIndex - 3 <= index[1])
        m.currentPage = Fix(index[1] / GlobalGet("appConfig").perPageVideos) + 1
        m.currentPage++
        m.currentRowFocus = index[0]
        GetSearchDataFromServer(m.lastSearchTerm, m.currentPage, childRow.search_type)
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
            m.top.datarray = {
                programType: childRow.program_type
                ItemName: childRow.program_type
                selectedIndex: index[1]
                selectedRowItem: childRow
                ListType: "RowList"
            }
        end if
    end if
end sub

sub ClearContentArea()
    print "ClearContentArea "
    if m.rowList <> invalid then
        print "m.rowList "m.rowList.hasFocus()
        m.top.removeChild(m.rowList)
        m.rowList = invalid
    end if
end sub

sub OnVisibleChange(event as dynamic)
    print "SearchPage : OnVisibleChange : "
    isVisible = event.getData()
    print "SearchPage : OnVisibleChange : isVisible : " isVisible
    if isVisible

    end if
end sub

sub OnFocusedChild()
    if m.top.hasFocus()
        if m.rowList <> invalid and m.rowList.visible
            SetFocus(m.rowList)
        else if m.miniKeyboard.visible
            SetFocus(m.miniKeyboard)
        end if
    end if

end sub

function onKeyEvent(key as string, press as boolean) as boolean
    print "SearchScreen : onKeyEvent : key = " key " press = " press
    handled = false
    if press then
        if key = "OK"
        else if key = "left"
            if m.rowList <> invalid and m.rowList.hasFocus()
                SetFocus(m.miniKeyboard)
                handled = true
            end if
        else if key = "right"
            if (m.miniKeyboard.hasFocus() or m.miniKeyboard.IsInFocusChain()) and m.rowList <> invalid and m.rowList.playlistContent <> invalid and m.rowList.playlistContent.getChildCount() > 0
                SetFocus(m.rowList)
                m.rowList.setFocus(false)
                SetFocus(m.rowList)
                handled = true
            end if
        else if key = "back"
            if m.rowList <> invalid and m.rowList.hasFocus()
                SetFocus(m.miniKeyboard)
                handled = true
            else
                ' m.UpdateTimer.control = "stop"
            end if
        end if
    end if
    return handled
end function
