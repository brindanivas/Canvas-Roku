sub init()
    print "SeriesPage : Init"
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetObservers()
    CreateBusySpinnerControls()
end sub

sub SetLocals()
    print "SeriesPage : SetLocals"
    m.scene = m.top.GetScene()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.lastSearchTerm = ""
    m.isFirstTime = true
    m.IsUpdateIcon = false
end sub

sub SetControls()
    print "SeriesPage : SetControls"
    m.lTitle = m.top.findNode("lTitle")
    m.lNoItems = m.top.findNode("lNoItems")
    m.gPreLoader = m.top.findNode("gPreLoader")
    m.bsPreloader = m.top.findNode("bsPreloader")
    m.lPreloader = m.top.findNode("lPreloader")
end sub

sub SetupFonts()
    print "SeriesPage : SetupFonts"
    m.lNoItems.font = m.fonts.robotoReg24
end sub

sub SetupColors()
    print "SeriesPage : SetupColors"
    m.lNoItems.color = m.theme.White
end sub

sub SetObservers()
    print "SeriesPage : SetObservers"
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChild")
    m.scene.observeField("IsUpdateData", "UpdateProgress")
    subscribeEvent("OnUpNextIndexChange")
end sub

sub onInitialize(event as dynamic)
    print "SeriesPage : onInitialize"
    initialize = event.GetData()
    ClearContentArea()
    if initialize
        m.currentPage = 1
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

sub ShowHideLoader(isShow as boolean, message = "Please wait..." as string, isSetFocus = true as boolean)
    m.gPreLoader.visible = isShow
    if isSetFocus
        'm.gPreLoader.setFocus(isShow)
        if (isShow = false)
            RestoreFocus()
        end if
    end if
    m.lPreloader.text = message
end sub
'=======> ShowHide Loader'

sub OnUpNextUpdate(playIndex as dynamic)
    m.index = [0, playIndex]
    m.rowList.jumpToRowItem = m.index
end sub

sub OnContentChange(event as dynamic)
    m.datarray = event.getData()
    if (m.datarray.selectedrowitem <> invalid) then
        ShowHideLoader(true)
        seriesData = m.datarray.selectedRowItem.getChild(m.datarray.selectedindex)
        m.lTitle.text = seriesData.title
        GetTabPlayListSeriesData(m.datarray.selectedRowItem, seriesData.id, m.datarray.selectedindex)
        m.index = [0, m.datarray.selectedindex]
    end if
end sub

sub GetTabPlayListSeriesData(playListItem, seriesId, playlistIndex)
    requestData = { tabId: playListItem.tabId, playListId: playListItem._id, seriesId: seriesId, pageNo: 1 }
    m.getHBCUEpisodesDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getHBCUEpisodesDataTask.functionName = "GetHBCUSeriesEpisodesData"
    m.getHBCUEpisodesDataTask.requestData = requestData
    m.getHBCUEpisodesDataTask.additionalParams = {
        playListItem: playListItem,
        playlistIndex: playlistIndex
    }
    m.getHBCUEpisodesDataTask.ObserveField("result", "OnGetHBCUSeriesEpisodesDataAPIResponse")
    m.getHBCUEpisodesDataTask.control = "RUN"
end sub

sub OnGetHBCUSeriesEpisodesDataAPIResponse(event as dynamic)
    apiResponseData = event.getData()
    taskNode = event.getRoSGNode()
    print "OnGetHBCUSeriesEpisodesDataAPIResponse : apiResponseData - " apiResponseData
    if (apiResponseData.ok and apiResponseData.data <> invalid and apiResponseData.data.content <> invalid and apiResponseData.data.content.series <> invalid)
        series = apiResponseData.data.content.series
        if (series[0] <> invalid and series[0].episodes <> invalid)
            createNode(series[0])
        end if
    end if
    ShowHideLoader(false)
end sub

function createNode(seriesData)
    pageData = CreateObject("roSGNode", "ContentNode")
    seasonDetails = []
    data = RowListDataParser(seriesData.episodes)
    if data <> invalid and data.count() > 0
        parentData = m.datarray.selectedRowItem
        for each item in data
            rowNode = pageData.createChild("ContentNode")
            rowNode.id = item.seasonId
            rowNode.title = "Season " + item.seasonId.toStr()
            rowNode.addFields({ "seriesId": seriesData.id, "vast_url_roku": parentData.vast_url_roku, "seriesTitle": seriesData.title, "isExclusiveContent": parentData.isExclusiveContent, "program_type": "video", "content_type": "", "isselected": false, "tabLayout": "rail" })
            rowNode.addFields({ "is_lock": parentData.isExclusiveContent })
        
            for each videoNode in item.programs
                videoNode.is_lock = videoNode.isExclusiveContent
                rowNode.appendChild(videoNode)
            end for
        end for
        ShowDynamicRowList(pageData)
    else 
        m.lNoItems.visible = true
        SetFocus(m.lNoItems)
    end if
end function

function RowListDataParser(videos as dynamic) as dynamic
    seasonDetails = []
    for each item in videos
        if item.season <> invalid
            programs = []
            categoriesData = getGetcategories(seasonDetails, item.season)
            if categoriesData <> invalid and categoriesData.count() > 0
                programs = categoriesData.programs
                categoriesData.programs = getAndSetContentNode(programs, item)
            else
                categoriesData = { "seasonId": item.season }
                categoriesData.programs = getAndSetContentNode(programs, item)
                seasonDetails.push(categoriesData)
            end if
        end if
    end for
    return seasonDetails
end function

function getAndSetContentNode(programs as dynamic, item as dynamic) as dynamic
    videoItem = ContentHelpers().oneDimSingleItem2ContentNode(item, "VideoNode")
    videoItem.playList_content_type = ""
    videoItem.playList_program_type = item.type
    videoItem.is_lock = item.isExclusiveContent
    programs.push(videoItem)
    return programs
end function

function getGetcategories(seasonData as dynamic, seasonNo as integer) as dynamic
    season = invalid
    if seasonData <> invalid and seasonData.count() > 0 and seasonNo <> invalid and seasonNo > 0
        for each item in seasonData
            if item.seasonId = seasonNo
                season = item
                exit for
            end if
        end for
    end if
    return season
end function

function ShowDynamicRowList(playlistContent)
    m.rowList = CreateObject("roSGNode", "DynamicRowList")
    m.rowList.translation = [75, 150]
    m.rowList.observeField("rowItemSelected", "onRowItemSelected")
    m.rowList.observeField("rowItemFocused", "onRowItemFocused")
    m.rowList.observeField("itemFocused", "onItemFocused")
    m.rowList.playlistContent = playlistContent.clone(true)
    m.top.appendChild(m.rowList)
    SetFocus(m.rowList)
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
                ItemName: childNode.program_type
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
    print "SeriesPage : OnVisibleChange : "
    isVisible = event.getData()
    print "SeriesPage : OnVisibleChange : isVisible : " isVisible
    if isVisible

    end if
end sub

sub OnFocusedChild()
    print "SeriesPage : OnFocusedChild : "
    if m.top.hasFocus()
        if m.rowList <> invalid and m.rowList.visible
            SetFocus(m.rowList)
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    print "SeriesScreen : onKeyEvent : key = " key " press = " press
    handled = false
    if press then
        if key = "OK"
        else if key = "left" or key = "right" or key = "up" or key = "down"
            handled = true
        else if key = "back"
            if m.rowList <> invalid and (m.rowList.hasFocus() or m.rowList.IsInFocusChain())
                if m.rowList.rowItemFocused[0] <> 0
                    m.rowList.animateToItem = 0
                    handled = true
                else
                    m.scene.callFunc("ShowHideMenu", true)
                end if
            end if
        end if
    end if
    return handled
end function
