sub init()
    print "MainScene : Init "
    setGlobalNode(CreateFontManager())
    SetLocals()
    SetControls()
    SetObservers()
    SetupColor()
    getIPAddress()
    CreateBusySpinnerControls()
    InitSegmentAnalytics()
    CreatePaginationSpinner()
end sub

sub SetLocals()
    m.exitCalled = false
    m.exitPopUpOpened = false
    m.appStarted = false
    m.appLaunchCompleteBeaconSent = false
    m.appDialogInitiateBeaconSent = false
    m.appDialogCompleteBeaconSent = false
    m.tabData = []
    m.tabSeriesData = {}
    m.IsRowLIst = false

    m.theme = m.global.appTheme
    m.fonts = m.global.Fonts
    m.appConfig = m.global.appConfig
    m.ViewStackManager = CreateViewStackManager()
    m.RegistryManager = CreateRegistryManager()
    ' m.RegistryManager.ClearAllSettings()
end sub

sub InitSegmentAnalytics()
    if m.appConfig.enableSegmentAnalytics
        if (m.appConfig.segmentWriteKey <> invalid AND m.appConfig.segmentWriteKey <> "")
            print "[MainScene] INFO : SEGMENT ANALYTICS SETUP..."
            task =  m.top.findNode("segmentAnalyticsTask")
            m.library = SegmentAnalyticsConnector(task)

            config = {
              "writeKey": m.appConfig.segmentWriteKey
              "debug": true
              "queueSize": 3
              "retryLimit": 0
            }

            m.library.init(config)


            print "[MainScene] INFO : SEGMENT ANALYTICS ENABLED..."

        else
            print "[MainScene] ERROR : SEGMENT ANALYTICS > Missing Account ID. Please set 'segmentWriteKey' in appConfig.json"
        end if
    end if
end sub

function IsDeepLinkFlow()
    isDeepLink = (m.top.deepLinkingLand and IsValidDeepLink())
    return isDeepLink
end function

sub SetControls()
    m.gPageContainer = m.top.findNode("gPageContainer")
    m.gVideoPlayer = m.top.findNode("gVideoPlayer")
    m.gLoader = m.top.findNode("gLoader")
    m.gTopMenu = m.top.findNode("gTopMenu")
    m.gPreLoader = m.top.findNode("gPreLoader")
    m.bsPreloader = m.top.findNode("bsPreloader")
    m.lPreloader = m.top.findNode("lPreloader")
    ' Toast Message for DeepLinking'
    m.toastMessageTimer = m.top.FindNode("toastMessageTimer")
    m.loaderTimer = m.top.FindNode("loaderTimer")
    m.vpBackground = m.top.FindNode("vpBackground")
    m.backGround = m.top.FindNode("backGround")
    m.rBackgroundOpacity = m.top.FindNode("rBackgroundOpacity")
    m.gPaginationLoader = m.top.FindNode("gPaginationLoader")
    m.bsPaginationloader = m.top.FindNode("bsPaginationloader")
    m.noPlaylist = m.top.FindNode("noPlaylist")
    m.noPlaylist.font = m.fonts.robotoMed30
end sub

sub SetObservers()
    m.top.observeField("deepLinkingLand", "onDeepLinkingLand")
    m.toastMessageTimer.observeField("fire", "toastMessageTimerExpired")
    m.backGround.observeField("loadStatus", "OnBackGroundLoadStatus")
    m.loaderTimer.observeField("fire", "loaderTimerExpired")
end sub

sub onSelectedItemDataArray(event as dynamic)
    m.DataListArray = event.GetData()
    print "m.DataListArray "m.DataListArray
    m.top.IsStopUpdateProgressTimer = true
    childNode = m.DataListArray.selectedrowitem.getChild(m.DataListArray.selectedindex)
    if childNode.is_lock
        ShowHidePopUpDialog(childNode)
    else if m.DataListArray.programType <> invalid
        if m.DataListArray.programType = "series"
            ShowSeriesPage(false)
            content = m.DataListArray.selectedrowitem.clone(true)
            m.DataListArray.selectedrowitem = content
            m.SeriesScreenPage.seriesContent = m.DataListArray
        else if m.DataListArray.programType = "movies" or m.DataListArray.programType = "movie" or (m.appConfig.showDetailPageForVideo = true and (m.DataListArray.programType = "videos" or m.DataListArray.programType = "video"))
            showDetailScreenPage(false)
            content = m.DataListArray.selectedrowitem.clone(true)
            content.TITLE = "More Like This"
            print "content ... "content
            print "m.DataListArray "m.DataListArray
            m.DataListArray.selectedrowitem = content
            m.DetailScreenPage.datarray = m.DataListArray
        else
            PlayVideo(m.DataListArray, false)
        end if
    else
        PlayVideo(m.DataListArray, false)
    end if

end sub

sub SetupColor()
    m.top.backgroundUri = ""
    m.top.backgroundColor = m.theme.Black
end sub

sub CreatePaginationSpinner()
    m.bsPaginationloader.poster.uri = "pkg:/images/icons/loader.png"
    m.bsPaginationloader.poster.width = "60"
    m.bsPaginationloader.poster.height = "60"
end sub

sub getIPAddress()
    externalIP = GetExternalIpAddress()
    if (IsNullOrEmpty(externalIP))
        GlobalSet("getIPAddress", "")
    else
        GlobalSet("getIPAddress", externalIP)
    end if
end sub

' Beacon Events'
sub sendAppLaunchCompleteBeacon()
    if (m.appLaunchCompleteBeaconSent = false)
        print "MainScene : Sending AppLaunchComplete..."
        m.top.signalBeacon("AppLaunchComplete")
        m.appLaunchCompleteBeaconSent = true
    end if
end sub

sub sendAppDialogInitiateBeacon()
    if (m.appDialogInitiateBeaconSent = false and m.appLaunchCompleteBeaconSent = false)
        print "MainScene : Sending AppDialogInitiate..."
        m.top.signalBeacon("AppDialogInitiate")
        m.appDialogInitiateBeaconSent = true
    end if
end sub

sub sendAppDialogCompleteBeacon()
    if (m.appDialogCompleteBeaconSent = false and m.appDialogInitiateBeaconSent = true)
        print "MainScene : Sending AppDialogComplete..."
        m.top.signalBeacon("AppDialogComplete")
        m.appDialogCompleteBeaconSent = true
    end if
end sub

sub onInitialize(event as dynamic)
    initialize = event.GetData()
    print "MainScene : onInitialize : " initialize
    m.global.userSellingOrSharingPreference = true
    if initialize
        if isOneTrustEnable()
            cmp_setupOneTrust()
        end if
        StartApp()
    end if
end sub

function isOneTrustEnable()
    oneTrustEnable = false
    if (m.appConfig <> invalid and (m.appConfig.enableOneTrust <> invalid and m.appConfig.enableOneTrust) and (m.appConfig.oneTrustAppId <> invalid and m.appConfig.oneTrustAppId <> "") and (m.appConfig.oneTrustVersion <> invalid and m.appConfig.oneTrustVersion <> ""))
        oneTrustEnable = true
    end if
    print "[MainScene] INFO : OneTrust Enable : " oneTrustEnable
    return oneTrustEnable
end function

sub onContentUpdate()
    ?"onContentUpdate called"
    if m.SettingPage = invalid
        StartApp()
    end if
end sub

sub StartApp()
    ShowHideLoadingPage(true)
    GetHBCUDataAPI()
end sub

function OnApiDataLoaded()
    createTopMenu()
    ShowHideMenu(true)
    SelectDefaultMenu()
    sendAppLaunchCompleteBeacon()
    sendInstallAndOpenSegmentAnalytics()
end function

' ===> Menu
sub createTopMenu()
    if (m.TopMenu <> invalid)
        m.gTopMenu.removeChild(m.TopMenu)
    end if
    m.TopMenu = m.gTopMenu.createChild("CustomMenuList")
    m.TopMenu.id = "Menu"
    m.TopMenu.MenuFocusedHeight = 5
    m.TopMenu.MenuFocusedWidth = 110
    m.TopMenu.observeField("rowitemFocused", "onTopMenuItemFocused")
    m.TopMenu.observeField("customRowItemSelected", "onTopMenuItemSelected")
    m.TopMenu.observeField("keyPress", "OnMenuKeyPress")
    menu = m.global.menuList
    m.TopMenu.SetFirstItemSelected = true
    m.TopMenu.MenuItems = menu
    m.TopMenu.translation = [300, 60]
    m.TopMenu.setFocus(true)
    m.focusMenuId = m.TopMenu.id


    m.LocalMenu = m.gTopMenu.createChild("CustomMenuList")
    m.LocalMenu.id = "LocalMenu"
    m.LocalMenu.MenuFocusedHeight = 5
    m.LocalMenu.MenuFocusedWidth = 110
    m.LocalMenu.observeField("rowitemFocused", "onLocalMenuItemFocused")
    m.LocalMenu.observeField("customRowItemSelected", "onLocalMenuItemSelected")
    m.LocalMenu.observeField("keyPress", "OnMenuKeyPress")
    localMenu = m.global.localMenuList
    m.LocalMenu.MenuItems = localMenu
    if localMenu.count() = 1
        m.LocalMenu.translation = [1820, 60]
    else
        m.LocalMenu.translation = [1720, 60]
    end if
end sub

sub SelectDefaultMenu()
    selectedItem = m.TopMenu.content.getChild(0).getChild(0)
    DisplaySelectedMenu(selectedItem)
end sub

sub ShowHideMenu(visible as boolean)
    if m.TopMenu <> invalid
        m.gTopMenu.visible = visible
    end if
end sub

sub onTopMenuItemSelected()
    if m.LocalMenu <> invalid and not m.LocalMenu.removeSelectedFocus
        m.LocalMenu.removeSelectedFocus = true
    end if
    DisplaySelectedMenu(GetSelectedMenu())
end sub

sub onTopMenuItemFocused()
end sub

sub onLocalMenuItemSelected()
    if m.TopMenu <> invalid and not m.TopMenu.removeSelectedFocus
        m.TopMenu.removeSelectedFocus = true
    end if
    DisplaySelectedLocalMenu(GetSelectedLocalMenu())
end sub

sub onLocalMenuItemFocused()
end sub

sub OnBackGroundLoadStatus(event as dynamic)
    loadStatus = event.getData()
    print " OnBackGroundLoadStatus "loadStatus
    if loadStatus <> "ready" and m.vpBackground.content = invalid
        m.rBackgroundOpacity.visible = false
    end if
end sub

function GetSelectedMenu()
    if m.TopMenu <> invalid
        index = [0, 0]
        if m.TopMenu.customRowItemSelected <> invalid
            index = m.TopMenu.customRowItemSelected
        end if
        selectedItem = m.TopMenu.content.getChild(index[0]).getChild(index[1])
        return selectedItem
    end if
    return invalid
end function


function GetSelectedLocalMenu()
    if m.LocalMenu <> invalid
        index = [0, 0]
        if m.LocalMenu.customRowItemSelected <> invalid
            index = m.LocalMenu.customRowItemSelected
        end if
        selectedItem = m.LocalMenu.content.getChild(index[0]).getChild(index[1])
        return selectedItem
    end if
    return invalid
end function

sub PlayVideo(videoObject as object, playAutoNext = true as boolean)
    if videoObject <> invalid and videoObject.selectedrowitem <> invalid
        hideToastMessage()
        seriesId = ""
        selectedindex = videoObject.selectedindex
        video = videoObject.selectedrowitem.getChild(selectedindex)
        videoPlayList = invalid
        if (playAutoNext)
            videoPlayList = videoObject.selectedrowitem.clone(true)
        end if
       
        if video.episode <> invalid and video.episode <> 0 and videoObject.selectedrowitem.seriesId <> invalid  
            seriesId = videoObject.selectedrowitem.seriesId
        end if    
        vastURL = ""
        if videoObject.selectedrowitem.vast_url_roku <> invalid and videoObject.selectedrowitem.vast_url_roku <> ""
            vastURL = videoObject.selectedrowitem.vast_url_roku
        end if
        isTrailer = false
        if videoObject.isTrailer <> invalid and videoObject.isTrailer
            isTrailer = true
        end if
        print "videoObject.selectedrowitem "videoObject.selectedrowitem
        print "playvideo seriesId "seriesId
        print "playvideo videoPlayList "videoPlayList
        print "playvideo playAutoNext "playAutoNext
        print "playvideo selectedindex "selectedindex
        StartVideo(video, vastURL, isTrailer, seriesId, videoPlayList, selectedindex)
    end if
end sub

function GetSelectedMenuPageData()
    dynamicPage = invalid
    selectedMenuItem = GetSelectedMenu()
    if selectedMenuItem <> invalid
        dynamicPage = FindPageObject(selectedMenuItem.TITLE)
    end if
    return dynamicPage
end function

sub DisplaySelectedMenu(selectedItem)
    m.backGround.uri = ""
    m.rBackgroundOpacity.visible = false
    DestroyBackgroundVideo()
    if selectedItem <> invalid
        GetSelectedMenuDataFromServer(selectedItem)
    end if
end sub

sub DisplaySelectedLocalMenu(selectedItem)
    m.backGround.uri = ""
    m.rBackgroundOpacity.visible = false
    DestroyBackgroundVideo()
    if selectedItem <> invalid
        if LCase(selectedItem.playlist_layout) = "settings"
            settings = GetSelectedLocalMenuData(selectedItem)
            showSettingPage(true)
            m.SettingPage.content = GetSettingPageData(settings)
            m.SettingPage.initialize = true
            m.SettingPage.visible = true
        else if LCase(selectedItem.playlist_layout) = "search"
            ' search = GetSelectedLocalMenuData(selectedItem)
            showSearchPage(true)
            m.SearchPage.initialize = true
            m.SearchPage.visible = true
        end if
    end if
end sub

function GetSelectedMenuDataFromServer(selectedItem as dynamic)
    shouldFetchData = true
    storedData = invalid
    if selectedItem.refresh_all_time <> invalid and selectedItem.refresh_all_time = false
        storedTabDataIndex = FindMatchingItemIndexFromArray(m.tabData, "_id", selectedItem._id)
        if storedTabDataIndex <> -1
            shouldFetchData = false
            storedData = m.tabData[storedTabDataIndex]
            m.FirstMenuLoaded = true
        end if
    end if
    if shouldFetchData = true
        if m.FirstMenuLoaded = false
            ShowHideLoadingPage(true)
        else
            ShowHideLoader(true)
        end if
        GetTabData(selectedItem)
    else
        LoadPageWithContent(storedData, true)
    end if
end function


sub GetTabData(selectedItem)
    requestData = { tabId: selectedItem._id }
    m.getHBCUTabDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getHBCUTabDataTask.functionName = "GetHBCUTabData"
    m.getHBCUTabDataTask.requestData = requestData
    m.getHBCUTabDataTask.additionalParams = {
        selectedItem: selectedItem
    }
    m.getHBCUTabDataTask.ObserveField("result", "OnGetHBCUTabDataAPIResponse")
    m.getHBCUTabDataTask.control = "RUN"
end sub

sub OnGetHBCUTabDataAPIResponse(event as dynamic)
    apiResponseData = event.getData()
    taskNode = event.getRoSGNode()
    print "OnGetHBCUTabDataAPIResponse : apiResponseData - " apiResponseData
    if (apiResponseData.ok and apiResponseData.data <> invalid and apiResponseData.data.content <> invalid)
        tabData = apiResponseData.data.content
        tabIndex = taskNode.requestData.tabId
        selectedItem = taskNode.additionalParams.selectedItem
        storedTabDataIndex = FindMatchingItemIndexFromArray(m.tabData, "_id", tabIndex)
        if storedTabDataIndex <> -1
            m.tabData[storedTabDataIndex].tabData = tabData
        else
            m.tabData.push({
                _id: tabIndex,
                selectedItem: selectedItem
                tabData: tabData
            })
        end if
        LoadPageWithContent({
            _id: tabIndex,
            tabData: tabData,
            selectedItem: selectedItem
        }, true)
    else
        ShowHideNoData(true, "Something went wrong. Please try again.")
    end if
    if m.FirstMenuLoaded = false
        m.FirstMenuLoaded = true
        ShowHideLoadingPage(false)
        ' if IsValidDeepLink()
    else
        ShowHideLoader(false)
    end if
    ' TODO : RSS : Handle failure case
end sub
    
function LoadPageWithContent(content as dynamic, isReplace as boolean)
    if content <> invalid
        ' print "content.tabData - " content.tabData " "isReplace
        selectedItem = content.selectedItem
        pageFound = FindPageObject(selectedItem.TITLE)
        playList = content.tabData
        dynamicPage = invalid

        if selectedItem.is_live_channel <> invalid and selectedItem.is_live_channel = 1
            dynamicPage =  showEPGPage(selectedItem.TITLE, selectedItem,isReplace)
        else
            if LCase(selectedItem.title) <> "live channels" And LCase(selectedItem.playlist_layout) = "rail"
                ' TODO : Need to change with DynamicPage with proper card'
                dynamicPage =  showDynamicPage(selectedItem.TITLE, isReplace)
            else if LCase(selectedItem.title) <> "live channels" And LCase(selectedItem.playlist_layout) = "grid"
                dynamicPage =  showDynamicGridPage(selectedItem.TITLE, isReplace)
            end if
        end if
        if selectedItem.live_video_in_background = 1
            if dynamicPage <> invalid and dynamicPage.hasField("isLiveVideoPlay")
                dynamicPage.isLiveVideoPlay = true
            end if
            ' setFocusToMenu()
            SetFocus(m.TopMenu)
        else if dynamicPage <> invalid and dynamicPage.hasField("isLiveVideoPlay")
            dynamicPage.isLiveVideoPlay = false
        end if
        if (pageFound = invalid or isReplace) and dynamicPage <> invalid
            m.dynamicPage = dynamicPage
            if m.dynamicPage.id <> "epgPage"
                GetSelectedPageData(playList.playlists, selectedItem.playlist_layout, selectedItem._id)
            end if
            m.dynamicPage.pageType = selectedItem.Type
        end if
        if selectedItem.featured_image <> invalid and selectedItem.featured_image <> ""
            m.backGround.uri = selectedItem.featured_image
            m.rBackgroundOpacity.visible = true
        end if
        if selectedItem.live_video_link <> invalid and selectedItem.live_video_link <> ""
            m.vpBackground.videoUrl = selectedItem.live_video_link
            m.rBackgroundOpacity.visible = true
        end if
        if dynamicPage <> invalid
            dynamicPage.initialize = true
            dynamicPage.visible = true
        end if
    end if
end function

function StartStopBackgroundPlayer(status as string)
    if Lcase(status) = "start"
        StartBackgroundVideo()
    else if Lcase(status) = "stop"
        StopBackgroundVideo()
    else if Lcase(status) = "destroy"
        DestroyBackgroundVideo()
    end if
end function

sub StartBackgroundVideo()
    if m.top.backGroundVideo <> invalid and m.top.backGroundVideo <> ""

        if m.vpBackground.state <> "playing"
            m.vpBackground.initialize = true
        end if
    end if
end sub

sub StopBackgroundVideo()
    m.vpBackground.stopPlayer = true
end sub

sub DestroyBackgroundVideo()
    m.vpBackground.destroy = true
end sub


function GetSelectedPageData(playListData, tabLayout, tabId)
    m.isFirstTime = true
    if playListData <> invalid and playListData.count() > 0
        m.pageData = CreateObject("roSGNode", "ContentNode")
        if (tabLayout = "rail")
            GetPlayListsData(playListData, tabLayout, tabId)
        else
            GetGridPlayListsData(playListData, tabLayout, tabId)
        end if
        ShowHideNoData(false)
    else
        ShowHideNoData(true)
        setFocus(m.TopMenu)
    end if
end function

function GetGridPlayListsData(playListData, tabLayout, tabId)
    for each playList in playListData
        playListItem = ContentHelpers().oneDimSingleItem2ContentNode(playList, "PlayListNode")
        playListItem.tabLayout = tabLayout
        playListItem.tabId = tabId
        if playList.child_playlists <> invalid and playList.child_playlists.count() > 0
            playListItem.hasSubPlayList = true
            ' GetGridPlayListsData(playList,tabLayout, tabId)
            playListItem.childPlaylists = playList.child_playlists
        else
            playListItem.hasSubPlayList = false
            ' GetVideosData(playListItem, playList, tabLayout)
        end if
        m.pageData.appendChild(playListItem)
    end for
    m.dynamicPage.content = m.pageData
    setFocus(m.dynamicPage)
end function

function GetPlayListsData(playListData, tabLayout, tabId)
    for i = 0 to playListData.count() - 1
        playListData[i].AddReplace("tabLayout", tabLayout)
        playListData[i].AddReplace("tabId", tabId)
    end for
    m.playListData = playListData
    print "m.playListData "m.playListData
    m.dynamicPage.isApiLoaded = true
    tabPlayListPagination()
end function

sub tabPlayListDataPagination(playListItem, page = 1 as integer, tabId = 0 as integer, playListId = 0 as string)
    if m.dynamicPage <> invalid
        m.dynamicPage.isApiLoaded = false
    end if
    ShowHidePagination(true)
    requestData = { tabId: tabId, playListId: playListId, pageNo: page }
    m.getHBCUTabDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getHBCUTabDataTask.functionName = "GetHBCUTabPlayListData"
    m.getHBCUTabDataTask.requestData = requestData
    m.getHBCUTabDataTask.additionalParams = {
        playListItem: playListItem,
    }
    m.getHBCUTabDataTask.ObserveField("result", "OnGetHBCUTabPlaylistPaginationDataAPIResponse")
    m.getHBCUTabDataTask.control = "RUN"
end sub

sub OnGetHBCUTabPlaylistPaginationDataAPIResponse(event as dynamic)
    apiResponseData = event.getData()
    taskNode = event.getRoSGNode()
    page = taskNode.requestData.pageNo
    playListItem = taskNode.additionalParams.playListItem
    print "OnGetHBCUTabPlaylistPaginationDataAPIResponse : apiResponseData - " apiResponseData
    if (apiResponseData <> invalid and apiResponseData.ok and apiResponseData.data <> invalid and apiResponseData.data.content <> invalid)
        if (m.dynamicPage <> invalid)
            videos = apiResponseData.data.content
            videoNodes = []

            for each videoData in videos
                if videoData.type = "series"
                    videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "PlayListNode")
                    ' videoItem.featured_image = videoItem.poster
                    videoItem.description = videoItem.short_description
                    videoItem.is_lock = playListItem.isExclusiveContent
                    videoItem.program_type = videoData.type
                else
                    videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "VideoNode")
                    videoItem.playList_content_type = playListItem.content_type
                    videoItem.playList_program_type = playListItem.program_type
                    videoItem.is_lock = playListItem.isExclusiveContent
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

                    ' videoItem.start_date_time = "2022-08-05 13:00:00"
                    ' videoItem.end_date_time = "2022-08-05 14:00:00"
                    videoItem.itemType = playListItem.tabLayout
                end if
                videoNodes.push(videoItem)
            end for
            if (m.dynamicPage <> invalid)
                m.dynamicPage.currentRowPage = page
                m.dynamicPage.updateRowContent = videoNodes
                m.dynamicPage.isApiLoaded = true
            end if
        end if
    end if
    ShowHidePagination(false)
end sub

function ceiling(x)
    i = int(x)
    if i < x then i = i + 1
    return i
end function

sub tabPlayListPagination(page = 1 as integer)
    totalPageData = m.playListData.Count()
    m.paginationData = []
    if m.dynamicPage <> invalid
        m.dynamicPage.currentPage = page
        m.dynamicPage.totalPlaylist = totalPageData
    end if
    m.perPageRows = GlobalGet("appConfig").perPageRows
    m.totalPages = 0
    if m.perPageRows > 0
        m.totalPages = ceiling(totalPageData / m.perPageRows)
    end if
    if m.totalPages < 1 then m.totalPages = 1
    if page <= m.totalPages and m.dynamicPage.isApiLoaded
        ShowHidePagination(true)
        m.dynamicPage.isApiLoaded = false
        startLooping = 0
        if page > 1 then startLooping = ((page - 1) * m.perPageRows)
        endLooping = page * m.perPageRows
        if m.totalPages = 1 then endLooping = m.playListData.count()
        m.playListRow = 0
        for i = startLooping to endLooping - 1 step 1
            rowData = m.playListData[i]
            if rowData <> invalid and rowData.count() > 0
                playListItem = ContentHelpers().oneDimSingleItem2ContentNode(rowData, "PlayListNode")
                if rowData <> invalid and rowData.child_playlists <> invalid and rowData.child_playlists.count() > 0
                    playListItem.hasSubPlayList = true
                    GetPlayListsData(rowData.child_playlists, rowData.tabLayout, rowData.tabId)
                else
                    playListItem.hasSubPlayList = false
                end if
                if (page = 1)
                    m.pageData.appendChild(playListItem)
                else
                    m.paginationData.push(playListItem)
                end if
                print "playListItem "playListItem
                if playListItem.videos_count > 0 or playListItem.series_count > 0
                    GetTabPlayListData(playListItem, i)
                end if
            end if
        end for
    end if
end sub

sub GetTabPlayListData(playListItem, playlistIndex)
    ShowHideNoData(false)
    requestData = { tabId: playListItem.tabId, playListId: playListItem._id, pageNo: 1 }
    m.getHBCUTabDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getHBCUTabDataTask.functionName = "GetHBCUTabPlayListData"
    m.getHBCUTabDataTask.requestData = requestData
    m.getHBCUTabDataTask.additionalParams = {
        playListItem: playListItem,
        playlistIndex: playlistIndex
    }
    m.getHBCUTabDataTask.ObserveField("result", "OnGetHBCUTabPlaylistDataAPIResponse")
    m.getHBCUTabDataTask.control = "RUN"
end sub

sub OnGetHBCUTabPlaylistDataAPIResponse(event as dynamic)
    apiResponseData = event.getData()
    taskNode = event.getRoSGNode()
    print "OnGetHBCUTabPlaylistDataAPIResponse : apiResponseData - " apiResponseData
    if (apiResponseData.ok and apiResponseData.data <> invalid and apiResponseData.data.content <> invalid)
        tabIndex = taskNode.requestData.tabId
        playListId = taskNode.requestData.playListId
        playListItem = taskNode.additionalParams.playListItem
        playlistIndex = taskNode.additionalParams.playlistIndex
        ' print "playListItem>>>>>>>>>>>: " playListItem
        GetVideosData(playListItem, playlistIndex, apiResponseData.data.content, playListItem.tabLayout)
    else
        ShowHidePagination(false)
        if m.playListData = invalid or m.playListData.count() = 1
            ShowHideNoData(true, "Something went wrong. Please try again.")
        end if
    end if
end sub

function GetVideosData(node, playlistIndex, videos, tabLayout) as void
    if m.dynamicPage = invalid or m.dynamicPage.visible = false
        ShowHidePagination(false)
        return
    end if
    for each videoData in videos
        if videoData.type = "series"
            videoItem = ContentHelpers().oneDimSingleItem2ContentNode(videoData, "PlayListNode")
            ' videoItem.featured_image = videoItem.poster
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
            videoItem.itemType = tabLayout
        end if
        ' videoItem.start_date_time = "2022-08-05 13:00:00"
        ' videoItem.end_date_time = "2022-08-05 14:00:00"

        if(m.dynamicPage <> invalid and m.dynamicPage.content = invalid)
            m.pageData.getChild(playlistIndex).appendChild(videoItem)
        else
            node.appendChild(videoItem)
        end if
    end for

    m.playListRow++
    if (m.totalPages = 1 and m.playListData.count() = m.playListRow and m.dynamicPage.content = invalid)
        m.dynamicPage.content = m.pageData
        print "show hide page 1"
        ShowHidePagination(false)
        m.dynamicPage.isApiLoaded = true
        setFocus(m.dynamicPage)
        if m.top.deepLinkingLand and IsValidDeepLink()
            GetDeepLinkVideo(m.top.DeeplinkingContentID)
        end if
    else
        if (m.dynamicPage.content = invalid and m.playListRow = m.perPageRows) or (m.dynamicPage.content <> invalid and m.playListRow <= m.perPageRows)
            ShowHidePagination(false)
            m.dynamicPage.isApiLoaded = true
            if (m.dynamicPage.content = invalid)
                m.dynamicPage.content = m.pageData
                setFocus(m.dynamicPage)
            else
                m.dynamicPage.updateContent = m.paginationData
            end if
            if m.top.deepLinkingLand and IsValidDeepLink()
                GetDeepLinkVideo(m.top.DeeplinkingContentID)
            end if
        end if
    end if
    if m.dynamicPage.isLiveVideoPlay and m.TopMenu <> invalid and m.isFirstTime
        currentScreen = m.ViewStackManager.GetTop()
        subType = currentScreen.subtype()
        selectedMenuItem = GetSelectedMenu()
        if selectedMenuItem <> invalid and selectedMenuItem.directly_focus_on_firstrow <> invalid and selectedMenuItem.directly_focus_on_firstrow = 1
            if subType = "DynamicPage"
                currentScreen.downClick = true
            else
                SetFocus(m.dynamicPage)
            end if
        else
            SetFocus(m.TopMenu)
        end if
        if m.perPageRows = m.playListRow
            m.isFirstTime = false
        end if
    end if
end function

function GetSettingPageData(settings)
    pageData = CreateObject("roSGNode", "ContentNode")
    pageData.id = "settingNode"
    for each setting in settings
        
        allowedSetting = true
        if allowedSetting
            settingData = ContentHelpers().oneDimSingleItem2ContentNode(setting, "SettingNode")
            pageData.appendChild(settingData)
        end if
    end for
    return pageData
end function

function GetTabMenu(topMenuItems)
    MenuArray = []
    for each menu in topMenuItems
        menuItem = ContentHelpers().oneDimSingleItem2AssocArray(menu, "TabNode")
        MenuArray.push(menuItem)
    end for
    return MenuArray
end function

function GetSelectedLocalMenuData(selectedItem)
    seletedData = invalid
    if selectedItem <> invalid
        for each item in m.HBCUResponse.local_menus
            if selectedItem._id = item._id
                if LCase(item.playlist_layout) = "settings"
                    seletedData = item.settings
                    exit for
                else if LCase(item.playlist_layout) <> "search"
                    seletedData = item.playlists
                    exit for
                end if
            end if
        end for
    end if
    return seletedData
end function

sub GetHBCUDataAPI()
    print "GetHBCUDataAPI "
    if m.getHBCUDataTask <> invalid
        m.getHBCUDataTask.control = "stop"
    end if
    m.FirstMenuLoaded = false
    requestData = {}
    m.getHBCUDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getHBCUDataTask.functionName = "GetHBCUData"
    m.getHBCUDataTask.requestData = requestData
    m.getHBCUDataTask.ObserveField("result", "OnGetHBCUDataAPIResponse")
    m.getHBCUDataTask.control = "RUN"
end sub

sub OnGetHBCUDataAPIResponse()
    print "OnGetHBCUDataAPIResponse "
    if (m.getHBCUDataTask.result <> invalid and m.getHBCUDataTask.result.ok)
        m.HBCUResponse = m.getHBCUDataTask.result.data.content
        localMenuData = ReadAsciiFile("pkg:/source/data/LocalMenu.json")
        localMenuJsonContent = ParseJson(localMenuData)
        newMenu = m.HBCUResponse.top_menus
        localMenu = localMenuJsonContent.localMenu
        m.HBCUResponse["local_menus"] = localMenu
        m.global.setFields({ "menuList": newMenu, "localMenuList": localMenu })
        isSettingsMenuAvailable = false
        for each item in localMenu
            if LCase(item.playlist_layout) = "settings"
                isSettingsMenuAvailable = true
                exit for
            end if
        end for
        if isSettingsMenuAvailable
            GetSettingsAPI()
        else
            OnApiDataLoaded()
        end if
    else
        ShowHideNoData(true, "Something went wrong. Please try again")
        ShowHideLoader(false)
        ShowHideLoadingPage(false)
    end if
end sub

sub ShowPreferenceCenter()
    print "Privacy button pressed — opening Preference Center"
    if m.global.OTsdk <> invalid
        ' m.global.OTsdk.callFunc("setupUI", {
        '     view: m.top
        ' })
        m.global.OTsdk.callFunc("showPreferenceCenterUI")
        ' m.global.OTsdk.callFunc("showPreferenceCenterUI")
    end if
end sub

sub onPcShown()
    ' SetFocus(m.top)
end sub

sub onOTUiEvent(event as dynamic)
  evt = event.getData()
  name   = evt.name
  resp   = evt.response
  print "🟩 OneTrust UI event:", name

  if name = "onPreferenceCenterAcceptAll"
    print "User onPreferenceCenterAcceptAll"
  else if name = "onPreferenceCenterRejectAll"
    print "User onPreferenceCenterRejectAll"
  else if name = "onPreferenceCenterConfirmChoices"
    print "User onPreferenceCenterConfirmChoices"
  else if name = "onHidePreferenceCenter"
    print "User onHidePreferenceCenter"
  else if name = "allSDKViewsDismissed"
    print "User allSDKViewsDismissed"
    if m.SettingPage <> invalid and m.SettingPage.visible
        SetFocus(m.SettingPage)
    end if
  end if
end sub

sub GetSettingsAPI()
    print "GetSettingsAPI "
    if m.getSettingsDataTask <> invalid
        m.getSettingsDataTask.control = "stop"
    end if
    requestData = {}
    m.getSettingsDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getSettingsDataTask.functionName = "GetSettingsData"
    m.getSettingsDataTask.requestData = requestData
    m.getSettingsDataTask.ObserveField("result", "OnGetSettingsDataAPIResponse")
    m.getSettingsDataTask.control = "RUN"
end sub

sub OnGetSettingsDataAPIResponse()
    print "OnGetSettingsDataAPIResponse "
    if (m.getSettingsDataTask.result <> invalid and m.getSettingsDataTask.result.ok)
        settings = m.getSettingsDataTask.result.data.settings
        localMenuData = ReadAsciiFile("pkg:/source/data/LocalMenu.json")
        localMenuJsonContent = ParseJson(localMenuData)
        localMenu = localMenuJsonContent.localMenu
        if isOneTrustEnable() and settings <> invalid
            privacySettings = {}
            privacySettings["_id"] = 9999
            privacySettings["Title"] = "Privacy Settings"
            privacySettings["Description"] = ""
            privacySettings["Url"] = ""
            settings.push(privacySettings)
        end if
        index = 0
        for each item in localMenu
            if LCase(item.playlist_layout) = "settings"
                if settings <> invalid and settings.count() > 0
                    item.settings = settings
                else
                    localMenu.Delete(index)
                end if
                exit for
            end if
            index++
        end for
        m.HBCUResponse["local_menus"] = localMenu
        m.global.setFields({ "localMenuList": localMenu })
    end if
    OnApiDataLoaded()
end sub

sub StartVideo(videoInfo as object, vastURL = "" as string, isTrailer = false as boolean, seriesId = "" as string, videoPlayList = invalid as dynamic, currentItemIndex = invalid as dynamic, setAnimation = true as boolean)
    print "StartVideo "videoInfo " "setAnimation
    if videoInfo <> invalid
        m.videoPlayerControl = GetVideoPlayer()
        SetFocus(m.videoPlayerControl)
        m.videoPlayerControl.isTrailer = isTrailer
        m.videoPlayerControl.SetAnimation = setAnimation

        m.videoPlayerControl.vastURL = vastURL
        if seriesId <> ""
            m.videoPlayerControl.metaInfo = {"seriesId": seriesId}
        end if
        m.videoPlayerControl.contentPlaylist = videoPlayList
        m.videoPlayerControl.contentIndex = currentItemIndex
        m.videoPlayerControl.content = videoInfo.clone(true)
        m.videoPlayerControl.visible = true
        m.videoPlayerControl.setFocus(true)
    end if
    ShowHideLoader(false)
end sub


sub GetVideoPlayer() as object
    if (m.videoPlayerControl = invalid)
        m.videoPlayerControl = createObject("roSGNode", "VideoPlayer")
        m.videoPlayerControl.id = "VideoPlayer"
        m.videoPlayerControl.observeField("isVideoPlayerStopped", "StopVideoPlayback")
        m.videoPlayerControl.observeField("contentIndex", "OnUpNextIndex")
        m.gVideoPlayer.appendChild(m.videoPlayerControl)
    end if
    return m.videoPlayerControl
end sub

sub OnUpNextIndex(event as object)
    index = event.getData()
    publishEvent("OnUpNextIndexChange", index)
end sub

sub StopVideoPlayback()
    if (m.videoPlayerControl <> invalid)
        m.videoPlayerControl.visible = false
        m.gVideoPlayer.removeChild(m.videoPlayerControl)
        m.videoPlayerControl = invalid
    end if
    currentScreen = m.ViewStackManager.GetTop()
    if (currentScreen.id <> "DetailsScreen" and currentScreen.id <> "SeriesScreenPage" and currentScreen.id <> "SearchPage" and currentScreen.id <> "SettingPage" and m.playingDeeplinkVideo = true)
        StartStopBackgroundPlayer("start")
        result = false
        if m.lastFocusOnMenu = true
            result = setFocusToMenu()
        end if
        if (result = false)
            m.ViewStackManager.FocusTop()
        end if
    else
        m.ViewStackManager.FocusTop()
    end if
    m.playingDeeplinkVideo = false
    m.lastFocusOnMenu = false
end sub

' <=== Menu

function showDynamicPage(pageName as string, isReplace = false as boolean) as object
    print "MainScene : showDynamicPage : " pageName "   Is Replace : " isReplace
    removePrevScreen(isReplace)
    dynamicPage = GetDynamicPageObject(pageName, isReplace)
    ShowHideMenu(true)
    if (isReplace = true)
        m.ViewStackManager.ReplaceScreen(dynamicPage)
    else
        m.ViewStackManager.ShowScreen(dynamicPage)
    end if
    setFocus(dynamicPage)
    return dynamicPage
end function

function showDynamicGridPage(pageName as string, isReplace = false as boolean)
    print "MainScene : showDynamicGridPage : Is Replace : " isReplace
    removePrevScreen(isReplace)
    dynamicGridPage = GetDynamicGridPageObject(pageName, false)
    ShowHideMenu(true)
    if (isReplace = true)
        m.ViewStackManager.ReplaceScreen(dynamicGridPage)
    else
        m.ViewStackManager.ShowScreen(dynamicGridPage)
    end if
    setFocus(dynamicGridPage)
    return dynamicGridPage
end function

function showEPGPage(pageName as string, contentData as object,isReplace = false as boolean)
    print "MainScene : showEPGPage : Is Replace : "  isReplace
    removePrevScreen(isReplace)
    ShowHidePagination(false)
    ShowHideMenu(true)
    epgPage = GetEPGPageObject(false)
    epgPage.content = contentData
    if (isReplace = true)
        m.ViewStackManager.ReplaceScreen(epgPage)
    else
        m.ViewStackManager.ShowScreen(epgPage)
    end if
    setFocus(epgPage)
    return epgPage
end function

function showSearchPage(isReplace = false as boolean)
    print "MainScene : showSearchPage : Is Replace : " isReplace
    removePrevScreen(isReplace)
    m.SearchPage = GetSearchPageObject(isReplace)
    ShowHideMenu(true)
    if (isReplace = true)
        m.ViewStackManager.ReplaceScreen(m.SearchPage)
    else
        m.ViewStackManager.ShowScreen(m.SearchPage)
    end if
    setFocus(m.SearchPage)
end function

function showDetailScreenPage(isReplace = false as boolean)
    print "MainScene : showDetailScreenPage : Is Replace : " isReplace
    hideToastMessage()
    m.DetailScreenPage = GetDetailScreenPageObject(true)
    ShowHideMenu(false)
    if (isReplace = true)
        m.ViewStackManager.ReplaceScreen(m.DetailScreenPage)
    else
        m.ViewStackManager.ShowScreen(m.DetailScreenPage)
    end if
    setFocus(m.DetailScreenPage)
end function

function ShowSeriesPage(isReplace = false as boolean)
    print "MainScene : ShowSeriesPage : Is Replace : " isReplace
    hideToastMessage()
    m.SeriesScreenPage = GetSeriesScreenPageObject(true)
    ShowHideMenu(false)
    if (isReplace = true)
        m.ViewStackManager.ReplaceScreen(m.SeriesScreenPage)
    else
        m.ViewStackManager.ShowScreen(m.SeriesScreenPage)
    end if
    setFocus(m.SeriesScreenPage)
end function

function showSettingPage(isReplace = false as boolean)
    print "MainScene : showSettingPage : Is Replace : " isReplace
    ShowHideMenu(true)
    removePrevScreen(isReplace)
    GetSettingPageObject(isReplace)
    if (isReplace = true)
        m.ViewStackManager.ReplaceScreen(m.SettingPage)
    else
        m.ViewStackManager.ShowScreen(m.SettingPage)
    end if
    setFocus(m.SettingPage)
end function

sub removePrevScreen(isReplace)
    if isReplace
        prevScreen = m.ViewStackManager.GetTop()
        if(prevScreen <> invalid and prevScreen.subtype() = "EpgScreen" and prevScreen.hasField("destroy"))
            prevScreen.destroy = true
        end if
    end if
end sub


function ShowHideLoadingPage(visible as boolean, width = 1920 as integer, height = 1080 as integer, translation = [0, 0] as object)
    if m.LoadingPage = invalid
        m.LoadingPage = createObject("roSGNode", "LoadingPage")
        m.LoadingPage.id = "LoadingPage"
        m.gLoader.appendChild(m.LoadingPage)
    end if
    m.LoadingPage.width = width
    m.LoadingPage.height = height
    m.LoadingPage.translation = translation
    m.LoadingPage.visible = visible
    m.LoadingPage.initialize = visible
end function

function GetSearchPageObject(isReplace as boolean) as object
    print "GetSearchPageObject =========================== "
    if isReplace and m.SearchPage <> invalid
        m.SearchPage.unObserveField("datarray")
        m.gPageContainer.removeChild(m.SearchPage)
        m.SearchPage = invalid
    end if
    if m.SearchPage = invalid
        m.SearchPage = createObject("roSGNode", "SearchPage")
        m.SearchPage.observeField("datarray", "onSelectedItemDataArray")
        m.SearchPage.visible = false
        m.SearchPage.id = "SearchPage"
    end if
    m.gPageContainer.appendChild(m.SearchPage)
    return m.SearchPage
end function

function GetSeriesScreenPageObject(isReplace as boolean) as object
    print "GetSeriesScreenPageObject =========================== "
    if isReplace and m.SeriesScreenPage <> invalid
        m.SeriesScreenPage.unObserveField("seriesContent")
        m.SeriesScreenPage.unObserveField("datarray")
        m.gPageContainer.removeChild(m.SeriesScreenPage)
        m.SeriesScreenPage = invalid
    end if
    if m.SeriesScreenPage = invalid
        m.SeriesScreenPage = createObject("roSGNode", "SeriesPage")
        m.SeriesScreenPage.observeField("datarray", "onSelectedItemDataArray")
        m.SeriesScreenPage.visible = false
        m.SeriesScreenPage.id = "SeriesScreen"
    end if
    m.gPageContainer.appendChild(m.SeriesScreenPage)
    return m.SeriesScreenPage
end function

function GetDetailScreenPageObject(isReplace as boolean) as object
    print "GetDetailScreenPageObject =========================== "
    if isReplace and m.DetailScreenPage <> invalid
        m.gPageContainer.removeChild(m.DetailScreenPage)
        m.DetailScreenPage = invalid
    end if
    if m.DetailScreenPage = invalid
        m.DetailScreenPage = createObject("roSGNode", "DetailsScreen")
        m.DetailScreenPage.visible = false
        m.DetailScreenPage.id = "DetailsScreen"
    end if
    m.gPageContainer.appendChild(m.DetailScreenPage)
    return m.DetailScreenPage
end function

function GetSettingPageObject(isReplace as boolean)
    print "GetSettingPageObject =========================== "
    if isReplace and m.SettingPage <> invalid
        m.SettingPage.unObserveField("selectedIndex")
        m.gPageContainer.removeChild(m.SettingPage)
        m.SettingPage = invalid
    end if
    if m.SettingPage = invalid
        m.SettingPage = createObject("roSGNode", "SettingPage")
        m.SettingPage.visible = false
        m.SettingPage.id = "SettingPage"
    end if
    m.gPageContainer.appendChild(m.SettingPage)
end function

function GetDynamicPageObject(pageId as string, isReplace as boolean) as object
    page = FindPageObject(pageId)
    print "GetDynamicPageObject ========= "isReplace
    if isReplace and page <> invalid
        page.unObserveField("datarray")
        page.destroy = true
        m.gPageContainer.removeChild(page)
        page = invalid
    end if
    if page = invalid
        page = createObject("roSGNode", "DynamicPage")
        page.observeField("datarray", "onSelectedItemDataArray")
        page.visible = false
        page.id = pageId
        m.gPageContainer.appendChild(page)
    end if
    return page
end function

function GetDynamicGridPageObject(pageId as string, isReplace as boolean) as object
    print "GetDynamicGridPageObject =========================== "isReplace
    page = FindPageObject(pageId)
    if isReplace and page <> invalid
        page.unObserveField("datarray")
        page.destroy = true
        m.gPageContainer.removeChild(page)
        page = invalid
    end if
    if page = invalid
        page = createObject("roSGNode", "DynamicGridPage")
        page.observeField("datarray", "onSelectedItemDataArray")

        page.visible = false
        page.id = pageId
        m.gPageContainer.appendChild(page)
    end if
    m.gPageContainer.appendChild(page)
    return page
end function

function GetEPGPageObject(isReplace as boolean) as object
    print "GetEPGPageObject =========================== "
    if isReplace and m.epgPage <> invalid
       m.gPageContainer.removeChild(m.epgPage)
       m.epgPage = invalid
    end if
    if m.epgPage = invalid
        m.epgPage = createObject("roSGNode", "EpgScreen")
        m.epgPage.visible = false
        m.epgPage.id = "epgPage"
    end if
    m.gPageContainer.appendChild(m.epgPage)
    return m.epgPage
end function

function FindPageObject(pageId) as Object
    page = invalid
    for i = 0 to m.gPageContainer.getChildCount() step 1
        tabPage = m.gPageContainer.getChild(i)
        if tabPage <> invalid and tabPage.id = pageId
            page = tabPage
        end if
    end for
    return page
end function

'===> Deep Linking

function IsValidDeepLink() as boolean
    contentID = m.top.deepLinkingContentId
    mediaType = m.top.deepLinkingMediaType
    isDeeplinkingValid = false
    if (IsNullOrEmpty(contentID) = false and IsNullOrEmpty(mediaType) = false and (Lcase(mediaType) = "movie"))
        isDeeplinkingValid = true
    end if
    return isDeeplinkingValid
end function

sub HandleDeepLinkingInputEvent(deeplinkEvent)
    print "MainScene : HandleDeepLinkingInputEvent : DeepLinking Data : " deeplinkEvent
    contentID = deeplinkEvent.contentid
    mediaType = deeplinkEvent.mediaType

    m.top.deepLinkingContentId = ""
    m.top.deepLinkingMediaType = ""

    isDeeplinkingValid = false
    if IsNullOrEmpty(contentID)
        msg = "Required mediaType not provided."
    else if IsNullOrEmpty(mediaType)
        msg = "Required contentId not provided."
    else if (Lcase(mediaType) <> "movie")
        msg = "Provided mediaType is not supported."
    else
        msg = "Fetching details for provided id..."
        m.top.deepLinkingContentId = contentID
        m.top.deepLinkingMediaType = mediaType
        isDeeplinkingValid = true
    end if
    ' if not isDeeplinkingValid
    m.top.deeplinkMsg = msg
    ' end if
    print "isDeeplinkingValid "
    print "DeeplinkMsg "m.top.deeplinkMsg
    ' Show Toast Message'
    if (not IsNullOrEmpty(m.top.DeeplinkMsg))
        ShowDeeplinkDialog(m.top.DeeplinkMsg)
        m.toastMessageTimer.control = "start"
    end if

    if isDeeplinkingValid
        GetDeepLinkVideo(contentID)
    end if
end sub

sub toastMessageTimerExpired()
    if (m.top.DeeplinkingContentID = "")
        m.top.DeeplinkMsg = ""
        m.toastMessageTimer.control = "stop"
        CloseDeeplinkDialog()
    end if
end sub

sub GetDeepLinkVideo(deepLinkId)
    print "GetDeepLinkVideo "deepLinkId

    selectedItem = m.TopMenu.content.getChild(0).getChild(0)
    if selectedItem <> invalid
        pageFound = FindPageObject(selectedItem.TITLE)
        print "GetDeepLinkVideo "pageFound
        isDeeplinkingFound = false
        if pageFound <> invalid and pageFound.content <> invalid
            for i = 0 to pageFound.content.getChildCount() - 1 step 1
                playlist = pageFound.content.getChild(i)
                for j = 0 to playlist.getChildCount() - 1 step 1
                    video = playlist.getChild(j)
                    if video._id.ToStr() = deepLinkId.ToStr() and video.itemType <> invalid and video.itemType <> "series"
                        isDeeplinkingFound = true
                        PlayDeepLinkVideo(video)
                        exit for
                    end if
                end for
                if isDeeplinkingFound
                    exit for
                end if
            end for
        end if
    end if
    if not isDeeplinkingFound
        m.top.DeeplinkMsg = "No data found."
        m.top.DeeplinkingContentID = ""
        m.top.deepLinkingMediaType = ""
    end if
end sub

sub PlayDeepLinkVideo(video)
    if m.top.DeeplinkingContentID <> invalid and m.top.DeeplinkingContentID <> ""
        print "MainScene : PlayDeepLinkVideo : DeeplinkingContentID : " m.top.DeeplinkingContentID
        if video <> invalid
            m.top.deepLinkingLand = false
            m.top.DeeplinkingContentID = ""
            m.top.deepLinkingMediaType = ""
            m.top.IsResumeVideo = true
            StartStopBackgroundPlayer("stop")

            m.playingDeeplinkVideo = true
            if (m.TopMenu.IsInFocusChain() or m.TopMenu.hasFocus()) or (m.LocalMenu.IsInFocusChain() or m.LocalMenu.hasFocus())
                m.lastFocusOnMenu = true
            end if
            StartVideo(video)
        end if
    else
        ClearDeepLinkDetail()
    end if
end sub

sub ClearDeepLinkDetail()
    m.top.DeeplinkingContentID = ""
    m.top.DeeplinkingMediaType = ""
end sub

sub ChangeDeeplinkDialogMessage()
    if (m.top.dialog <> invalid)
        m.top.dialog.message = m.top.DeeplinkMsg
    end if
end sub

sub ShowDeeplinkDialog(message as string)
    sendAppDialogInitiateBeacon()
    m.top.dialog = invalid
    dialog = createObject("roSGNode", "ProgressDialog")
    dialog.title = "Deeplinking..."
    dialog.message = message
    dialog.optionsDialog = false
    m.top.dialog = dialog
end sub

sub CloseDeeplinkDialog()
    if (m.top.dialog <> invalid)
        m.top.dialog.close = true
        m.top.dialog = invalid
    end if
    sendAppDialogCompleteBeacon()
    sendAppLaunchCompleteBeacon()
end sub
'===> Deep Linking

'=======> ShowHide Loader'
sub CreateBusySpinnerControls()
    m.lPreloader.text = "Please wait..."
    m.bsPreloader.poster.uri = "pkg:/images/loader/loader.png"
    m.bsPreloader.poster.width = "160"
    m.bsPreloader.poster.height = "160"
    m.lPreloader.color = m.theme.white
    m.lPreloader.font = m.fonts.robotoBold30
end sub

sub ShowHideLoader(isShow as boolean, message = "Please wait..." as string, focusSet = true as boolean)
    m.top.IsLoadingData = isShow
    if isShow
        ShowHidePagination(false)
    end if
    m.gPreLoader.visible = isShow
    if focusSet 
        m.gPreLoader.setFocus(isShow)
        if (isShow = false)
            RestoreFocus()
        end if
    end if
    m.lPreloader.text = message
    m.bsPreloader.translation = "[880, 400]"
    m.lPreloader.translation = "[0, 600]"
end sub


sub ShowHideNoData(isShow as boolean, message = "No data available." as string)
    m.noPlaylist.text = message
    m.noPlaylist.visible = isShow
    if isShow
        setFocusToMenu()
    end if
end sub

sub ShowHidePagination(isShow as boolean)
    m.gPaginationLoader.visible = isShow
end sub

'=======> ShowHide Loader'
sub ShowHidePopUpDialog(videoNode)
    m.cmDialog = CreateObject("roSGNode", "CustomDialog")
    m.cmDialog.contentNode = videoNode
    m.cmDialog.id = "CustomDialog"
    m.cmDialog.yesBtnText = "Yes"
    m.cmDialog.noBtnText = "No"
    m.cmDialog.observeField("selectedButton", "onCloseShowHidePopUpDialog")
    m.top.appendChild(m.cmDialog)
    m.cmDialog.setFocus(true)
end sub

sub onCloseShowHidePopUpDialog(event as dynamic)
    data = event.GetData()
    print "onCloseShowHidePopUpDialog : data>>>>>: " data
    if data = 0
        if m.cmDialog <> invalid
            m.top.removeChild(m.cmDialog)
            m.cmDialog = invalid
            m.ViewStackManager.FocusTop()
        end if
    else if data = 1
        print "MainScene : onCloseShowHidePopUpDialog : dlgExit : " ' m.dlgExit
        if m.cmDialog <> invalid
            m.top.removeChild(m.cmDialog)
            m.cmDialog = invalid
            m.ViewStackManager.FocusTop()
        end if
    end if
end sub

'===> Exit Confirmation
sub ShowHideExitLogoutConfirmation(isExit = true as boolean)
    if (m.exitPopUpOpened = false)
        m.dlgExit = CreateObject("roSGNode", "ExitDialog")
        m.dlgExit.id = "ExitDialog"
        m.dlgExit.isExit = isExit
        if (isExit = true)
            m.dlgExit.message = "Are you sure you want to exit application?"
            m.dlgExit.yesBtnText = "Yes"
        else
            m.dlgExit.message = "Are you sure you want to logout from application?"
            m.dlgExit.yesBtnText = "Yes"
        end if
        m.dlgExit.noBtnText = "No"

        m.dlgExit.observeField("selectedButton", "onExitDialogButtonSelected")
        m.top.appendChild(m.dlgExit)

        m.dlgExit.setFocus(true)
        m.exitPopUpOpened = true
    else
        if (m.dlgExit <> invalid)
            m.top.removeChild(m.dlgExit)
        end if
        ' currentScreen = m.ViewStackManager.GetTop()
        ' currentScreen.setFocus(true)
        setFocusToMenu()
        m.exitPopUpOpened = false
    end if
end sub

function setFocusToMenu() as boolean
    result = false
    if m.TopMenu <> invalid and m.focusMenuId = m.TopMenu.id
        m.TopMenu.setFocus(true)
        result = true
    else if m.LocalMenu <> invalid and m.focusMenuId = m.LocalMenu.id
        m.LocalMenu.setFocus(true)
        result = true
    end if
    return result
end function

sub onExitDialogButtonSelected(event as dynamic)
    data = event.GetData()
    if data = 0
        ShowHideExitLogoutConfirmation() ' Not passing anything as its just for closing dialog'
    else if data = 1
        print "MainScene : onExitDialogButtonSelected : dlgExit : " ' m.dlgExit
        if (m.dlgExit.isExit)
            m.top.outRequest = { "ExitApp": true }
            m.exitCalled = true
        else
            ' CallLogoutAPI()
        end if
    end if
end sub
'<=== Exit Confirmation

sub ShowTopRightCornerToast(message as string)
    messageData = {
        "message": message,
        "width": 400,
        "height": 70,
        "translation": "[1460,130]",
        "iconURI": "pkg:/images/icons/info-50.png",
        "iconWidth": 50,
        "iconHeight": 50,
        "toastDuration": 10,
        "messageColor": "#FFFFFF"
    }
    showToastMessage(messageData)
end sub

sub showToastMessage(msg)
    if m.toastMessageBox = invalid
        m.toastMessageBox = m.top.CreateChild("ToastMessage")
    end if
    m.toastMessageBox.msgData = msg
end sub

sub hideToastMessage()
    if m.toastMessageBox <> invalid
        m.toastMessageBox.quickHide = true
    end if
end sub

function OnMenuKeyPress(event as dynamic)
    data = event.getData()
    key = data.key
    longPress = data.longPress
    if key = "left"
        if m.LocalMenu <> invalid and m.focusMenuId = m.LocalMenu.id and m.TopMenu <> invalid and not (m.TopMenu.hasFocus() or m.TopMenu.IsInFocusChain())
            m.TopMenu.setFocus(true)
            if longPress
                m.TopMenu.OutSidekeyPass = key
            end if
            m.focusMenuId = m.TopMenu.id
        end if
    else if key = "right"
        if m.TopMenu <> invalid and m.focusMenuId = m.TopMenu.id and m.LocalMenu <> invalid and not (m.LocalMenu.hasFocus() or m.LocalMenu.IsInFocusChain())
            m.LocalMenu.setFocus(true)
            if longPress
                m.LocalMenu.OutSidekeyPass = key
            end if
            m.focusMenuId = m.LocalMenu.id
        end if
    end if
end function


function OnkeyEvent(key as string, press as boolean) as boolean
    result = false
    print "MainScene : onKeyEvent : key = " key " press = " press
    if press
        if key = "back"
            print "MainScene : onKeyEvent : View Stack Count : " m.ViewStackManager.GetViewCount()
            print "MainScene : onKeyEvent : m.exitCalled : " m.exitCalled
            if (m.VideoPlayerControl <> invalid and m.VideoPlayerControl.visible = true)
                StopVideoPlayback()
                result = true
            else if (m.ViewStackManager.GetViewCount() > 1)
                ShowHideLoader(false)
                m.ViewStackManager.HideTop()
                if m.ViewStackManager.GetViewCount() = 1
                    ShowHideMenu(true)
                end if
                result = true
            else if m.exitCalled = false
                if (m.ViewStackManager.GetViewCount() = 1)
                    if m.TopMenu.IsInFocusChain() or m.LocalMenu.IsInFocusChain()
                        if (m.exitPopUpOpened = false or m.exitCalled = false)
                            ShowHideExitLogoutConfirmation(true)
                            result = true
                        end if
                    else
                        result = setFocusToMenu()
                    end if
                end if
            end if
        else if key = "down"
            if not m.noPlaylist.visible
                if (m.TopMenu.IsInFocusChain() or m.TopMenu.hasFocus()) or (m.LocalMenu.IsInFocusChain() or m.LocalMenu.hasFocus())
                    m.ViewStackManager.FocusTop()
                    currentScreen = m.ViewStackManager.GetTop()
                    subType = currentScreen.subtype()
                    selectedItem = GetSelectedMenu()
                    if selectedItem <> invalid and selectedItem.live_video_in_background = 1
                        if subType = "DynamicPage"
                            currentScreen.downClick = true
                        end if
                    end if
                    result = true
                end if
            end if
        else if key = "up"
            result = setFocusToMenu()
        end if
    end if

    return result
end function

sub sendInstallAndOpenSegmentAnalytics()
    if (m.appConfig.enableSegmentAnalytics = true)
        if (m.appConfig.segmentWriteKey <> invalid AND m.appConfig.segmentWriteKey <> "")
            isInstalledKeyFound = m.RegistryManager.RegRead("IsInstalled","IsInstalled")
            if (isInstalledKeyFound = invalid OR isInstalledKeyFound <> "1")
                m.RegistryManager.RegWrite("IsInstalled", "1", "IsInstalled")
                ' Send application installed event only once when its not in registry'
                SendAppInstalledOrOpenedSegmentAnalyticsEvent(false)
            end if
            ' Send application opened event'
            SendAppInstalledOrOpenedSegmentAnalyticsEvent(true)
        else
            print "[HomeScene] [Install_OPEN_EVENT] ERROR : SEGMENT ANALYTICS > Missing Account ID. Please set 'segmentWriteKey' in appConfig.json"
        end if
    else
       print "[HomeScene] [Install_OPEN_EVENT] INFO : SEGMENT ANALYTICS IS NOT ENABLED..."
    end if
end sub

Sub SendAppInstalledOrOpenedSegmentAnalyticsEvent(isOpened as boolean)
    m.top.segmentEvent = GetSegmentAppOpenedOrInstalledEventInfo(isOpened)
End Sub

function GetSegmentAppOpenedOrInstalledEventInfo(isOpened as boolean)
    eventStr = ""

    if (isOpened = true)
        eventStr = GetSegmentVideoStateEventString("appOpened")
    else
        eventStr = GetSegmentVideoStateEventString("appInstalled")
    end if
    appInfo = CreateObject("roAppInfo")
    appMajorVersion = appInfo.GetValue("major_version")
    appMinorVersion = appInfo.GetValue("minor_version")
    appBuildVersion = appInfo.GetValue("build_version")
    properties = {
            "version":   appMajorVersion + "." + appMinorVersion, 'String (autogenerated for the user's session)
            "build":     appBuildVersion
        }
    trackObj = {
        "action": "track",
        "event": eventStr,
        "userId": getAppUniqueChannelID(), ' for Now we are setting unique ID as we are not using UserID as per requirement'
    }

    trackObj.properties = properties
    print "App Open/Installed trackObj : " trackObj
    print "App Open/Installed trackObj.properties : " trackObj.properties
    return trackObj
end function


Sub onSegmentEventChanged()
    if (m.top.segmentEvent<>invalid)
        segmentEventInfo = m.top.segmentEvent
        segmentEventAction = segmentEventInfo.action
        segmentEventString = segmentEventInfo.event
        if (m.appConfig.enableSegmentAnalytics = true)
            if (m.appConfig.segmentWriteKey <> invalid AND m.appConfig.segmentWriteKey <> "")
                if (segmentEventAction = "track")
                    ' Get ID'
                    anonymousId = getAdID()
                    if (anonymousId = "")
                        ' Try get using channelID'
                        anonymousId = getAdsAppID()
                        if (anonymousId = "")
                            ' Not able to find unique id - Should never occur but its error handling as Segment need atleast one options'
                            anonymousId = "anonymousId"
                        end if
                    end if
                    options = {
                      "anonymousId": anonymousId
                    }
                    m.library.track(segmentEventString, segmentEventInfo.properties, options)
                end if
            else
                print "[HomeScene] ["+segmentEventString+"] ERROR : SEGMENT ANALYTICS > Missing Account ID. Please set 'segmentWriteKey' in appConfig.json"
            end if
        else
           print "[HomeScene] ["+segmentEventString+"] INFO : SEGMENT ANALYTICS IS NOT ENABLED..."
        end if
    end if
End SUb