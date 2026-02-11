sub init()
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetObservers()
    initLoadingBar()
end sub

sub setupMediaMelonContent(content as object)
    if (content <> invalid and m.global.MMAnalytics <> invalid)
        title = m.VAL_UNSET
        is_live = false
        videoId = m.VAL_UNSET
        itemType = m.VAL_UNSET
        program_type = m.VAL_UNSET
        video_type = "VOD"
        if (content.title <> invalid) title = content.title
        if (content._id <> invalid) videoId = content._id
        if (content.itemType <> invalid) itemType = content.itemType
        if (content.itemType = m.VAL_UNSET and content.playList_content_type <> invalid and content.playList_content_type <> "") itemType = content.playList_content_type
        if (content.playList_program_type <> invalid) program_type = content.playList_program_type
        if (content.is_live <> invalid)
            if (is_live)
                video_type = "LIVE"
            end if
        end if

        contentMetadata = {
            "assetName": title,
            "assetId": Str(videoId).Trim(),
            "videoId": Str(videoId).Trim(),
            "genre": "Entertainment",
            "contentType": program_type,
            "videoType": video_type
        }

        m.global.MMAnalytics.setField("contentMetadata", contentMetadata)
        m.global.MMAnalytics.setField("video", m.videoPlayer)
        'Need to stop if config initilaize at once'
        m.global.MMAnalytics.control = "STOP"
        m.global.MMAnalytics.control = "RUN"
    end if
end sub

sub SetLocals()
    m.scene = m.top.GetScene()
    m.theme = m.global.appTheme
    m.appConfig = m.global.appConfig
    m.fonts = m.global.fonts
    m.loading = m.top.findNode("loading")
    m.LoadingIndicator = m.top.findNode("LoadingIndicator")
    m.LoadingPer = m.top.findNode("LoadingPer")
    m.isLive = false
    m.videoPos = 0
    m.previous_videoPos = 0
    m.heartbeatInt = 10
    m.VAL_UNSET = "null"
    m.MM = m.top.FindNode("MM")
    m.lastVideoStateOnBuffering = ""
end sub

sub initializeMediaMelon()
    if (m.appConfig <> invalid and (m.appConfig.mediaMelonID <> invalid and m.appConfig.mediaMelonID <> "") and (m.appConfig.enableMediaMelon <> invalid and m.appConfig.enableMediaMelon = true))
        print "[MainScene] INFO : MEDIAMELON ANALYTICS ENABLED..."
        appInfo = CreateObject("roAppInfo")
        appName = appInfo.GetTitle()
        appSdkVersion = appInfo.GetVersion()
        DeviceUniqueId = m.global.DeviceUniqueId
        subscriberType = "FREE_USER"
        ' subscriberType = "ADFREE_USER"
        MMConfig = {
            customerID: m.appConfig.mediaMelonID
            subscriberId: DeviceUniqueId
            subscriberType: subscriberType
            subscriberTag: m.appConfig.channel_id + DeviceUniqueId
            playerName: "Roku_NativePlayer"
            disableManifestFetch: false
            domainName: m.appConfig.domainName
            appName: appName + "-Roku"
            appSdkVersion: appSdkVersion
            hashSubscriberId: false
            enableCustomErrorReporting: true
        }
        print "MMConfig >> " MMConfig
        m.MM.setField("config", MMConfig)
        if not m.global.hasField("MMAnalytics")
            m.global.AddField("MMAnalytics", "node", false)
        end if
        m.global.MMAnalytics = m.MM
    else
        print "[MainScene] INFO : MEDIAMELON ANALYTICS DISABLED..."
    end if
end sub

sub SetControls()
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.blackRect = m.top.findNode("blackRect")
    m.videoPlayer.enableUI = false
    m.videoPlayer.enableTrickPlay = false
    m.startanimation = m.top.findNode("startanimation")
    m.PlayerOverlay = m.top.findNode("PlayerOverlay")
    m.hideControlsTimer = m.top.findNode("hideControlsTimer")
    m.fadeOutControls = m.top.findNode("fadeOutControls")
    m.hideControlsTimer.observeField("fire", "hideControls")
end sub

sub triggerHideControlsTimer(value as boolean, isShowOverlay = true as boolean)
    if (isShowOverlay)
        showOverlay(true)
    end if
    if not value
        m.hideControlsTimer.control = "stop"
    else
        m.hideControlsTimer.control = "start"
    end if
end sub

sub hideControls()
    fadeOutControls(true)
end sub

sub showOverlay(visible as boolean)
    m.PlayerOverlay.visible = visible
    m.PlayerOverlay.opacity = 1.0
end sub

sub fadeOutControls(value as boolean)
    print "m.PlayerOverlay.visible >> " m.PlayerOverlay.visible
    if m.PlayerOverlay.visible
        if not value
            m.fadeOutControls.control = "stop"
        else
            m.fadeOutControls.control = "start"
            m.videoPlayer.setFocus(true)
        end if
    end if
end sub

sub SetupFonts()
    m.LoadingPer.font = m.fonts.robotoMed18
end sub

sub SetupColors()
    m.videoPlayer.retrievingBar.filledBarBlendColor = m.theme.ProgressBarFill
    m.videoPlayer.trickPlayBar.filledBarBlendColor = m.theme.ProgressBarFill
    m.videoPlayer.bufferingBar.filledBarBlendColor = m.theme.ProgressBarFill
end sub

sub SetObservers()
    m.top.observeField("focusedChild", "OnFocusedChild")
    m.videoPlayer.observeField("state", "OnVideoPlayerStatusChange")
    m.videoPlayer.observeField("position", "OnVideoPositionChanged")
    m.startanimation.observeField("state", "OnStartAnimation")
    m.PlayerOverlay.observeField("seekingStatus", "OnSeekingStatusChanged")
    m.videoPlayer.observeField("bufferingStatus", "handleBufferingStatus")
    m.PlayerOverlay.observeField("pauseVideo", "OnVideoPauseCall")
end sub

sub OnStartAnimation(event as dynamic)
    status = event.getData()
    if status = "stopped" and m.videoPlayer.content <> invalid
        m.blackRect.visible = false
        m.videoPlayer.visible = true
    end if
end sub

sub OnVideoPauseCall()
    m.PlayerOverlay.action = {
        userAction: "PAUSED",
        videoPosition: m.videoPlayer.position
    }
    if (not m.videoPlayer.state = "buffering") then m.videoPlayer.control = "pause"
end sub

sub OnContentChange(event as dynamic)
    m.content = event.getData()
    hideLoadingBar()
    m.scene.IsStopUpdateProgressTimer = true
    m.videoPlayer.visible = false
    m.blackRect.visible = true
    if m.top.content.is_live = 1
        m.isLive = true
        StartPlayer(0, true)
    else
        m.isLive = false
        if m.top.isTrailer
            StartPlayer(0)
        else if (m.videoPlayer.visible = false)
            if m.scene.IsStartFromBeginning = true
                m.scene.IsStartFromBeginning = false
                StartPlayer(0)
            else if (m.scene.IsResumeVideo = true)
                m.scene.IsResumeVideo = false
                bookmark = GetBookmarkData(m.content._id.toStr())
                if (bookmark <> invalid)
                    m.PlayerOverlay.seekPosition = bookmark
                    StartPlayer(bookmark)
                else
                    StartPlayer(0)
                end if
            else
                CheckAndShowResumeDialog()
            end if
        end if
    end if
end sub

function ReplaceMacrosForLive(streamUrl as string) as string
    if streamUrl <> invalid and streamUrl <> ""
        ip = GlobalGet("getIPAddress")
        player_width = GetDeviceDisplaySize().w.ToStr()
        player_height = GetDeviceDisplaySize().h.ToStr()
        page_url = m.appConfig.page_url.Escape()
        app_name = CreateObject("roAppInfo").GetTitle().Escape()
        app_store_url = m.appConfig.app_store_url.Escape()
        did = GetUniqueId().Escape()
        device_model = GetDeviceModel().Escape()
        ua = GetUserAgent().Escape()
        app_bundle = m.appConfig.app_bundle
        ifa_type = "rida"
                
        dnt = "0"
        if checkLimitAdTracking()
            dnt = "1"
        end if
        
        us_privacy = ""
        us_privacy_string = GlobalGet("USPrivacy_String")
        if us_privacy_string <> invalid and us_privacy_string <> ""
            us_privacy = GlobalGet("USPrivacy_String")
        end if
        gpp_String = getGPPValues()
        gpp_sid = getGPPSIDValues()

        liveUrlN = streamUrl.Replace("[PLAYER-WIDTH]", player_width).Replace("[PLAYER-HEIGHT]", player_height)
        liveUrlN = liveUrlN.Replace("[APP-NAME]", app_name).Replace("[WEB-URL]", page_url).Replace("[DEVICE-ID]", did)
        liveUrlN = liveUrlN.Replace("[DEVICE-MODEL]", device_model).Replace("[USER-AGENT]", ua)
        liveUrlN = liveUrlN.Replace("[IP-ADDRESS]", ip)
        liveUrlN = liveUrlN.Replace("[APP-BUNDLE]", app_bundle)
        liveUrlN = liveUrlN.Replace("[APP-STORE-URL]", app_store_url)
        liveUrlN = liveUrlN.Replace("[DEVICE-ID-TYPE]", ifa_type)
        liveUrlN = liveUrlN.Replace("[DNT]", dnt)
        liveUrlN = liveUrlN.Replace("[DEVICE-MAKER]", "Roku") ' FireTV, Apple'
        liveUrlN = liveUrlN.Replace("[DEVICE-TYPE]", "3")
        liveUrlN = liveUrlN.Replace("[PLATFORM-NAME]", "Roku") ' Platform: Roku, fire_tv, desktop_web, android'
        liveUrlN = liveUrlN.Replace("[US-PRIVACY]", us_privacy)
        liveUrlN = liveUrlN.Replace("{GPP_STRING}", gpp_String).Replace("{GPP_SID}", gpp_sid)
        return liveUrlN.Replace(" ", "%20").Replace("|", "%7C").Replace("(", "%28").Replace(")", "%29").Replace("\", "")
    end if
end function

function getVastTagAdsURL(vastUrl as dynamic) as string
    VastUrlN = ""
    if vastUrl <> invalid and vastUrl <> ""
        ip = GlobalGet("getIPAddress")
        cb = Rnd(100000).toStr()
        player_width = GetDeviceDisplaySize().w.ToStr()
        player_height = GetDeviceDisplaySize().h.ToStr()
        page_url = ""
        app_name = CreateObject("roAppInfo").GetTitle().Escape()
        app_version = GetAppVersions()
  
        dnt = "0"
        did = "00000000-0000-0000-0000-000000000000"
        if not checkLimitAdTracking()
            tempId = GetRIDA()
            if tempId <> invalid and tempId <> ""
                did = tempId
            end if
        else
            dnt = "1"
        end if

        language = "en"
        device_model = GetDeviceModel().Escape()
        device_make = "Roku"
        ua = GetUserAgent().Escape()
        osv = GetOsVersion()
        os = "Roku"

        gdpr = "1"
        gdpr_consent = "1"
        ifa_type= "rida"
        coppa = "0" 
        pod_ad_slots = "3"
        content_livestream = "0"
        device_type = "3"
        
        connection_type = GetConnectionType()
        content_type = m.content.playList_program_type
        content_id = m.content._id.ToStr()
        content_title = m.content.title.Escape()
        content_series = ""
        content_episode = ""
        content_season = ""
        if m.top.metaInfo <> invalid and m.content.episode <> invalid and m.content.episode <> 0
            content_series = m.top.metaInfo.seriesId.ToStr()
            content_season = m.content.season.ToStr()
            content_episode = m.content.episode.ToStr()
        end if
       
        content_genre = m.content.genres.ToStr()
        content_category = m.content.category.ToStr()
        content_duration = m.content.duration.ToStr()
        us_privacy = ""
        us_privacy_string = GlobalGet("USPrivacy_String")
        if us_privacy_string <> invalid and us_privacy_string <> ""
            us_privacy = GlobalGet("USPrivacy_String")
        end if
        gpp_String = getGPPValues()
        gpp_sid = getGPPSIDValues()
        VastUrlN = vastUrl.Replace("{category}", content_category).Replace("{content_categories}", content_category).Replace("{video_id}", content_id).Replace("{content_episode}", content_episode).Replace("{media_title}", content_title)
        VastUrlN = VastUrlN.Replace("{series_title}", content_series).Replace("{content_season}", content_season).Replace("{content_type}", content_type)
        VastUrlN = VastUrlN.Replace("{content_genre}", content_genre).Replace("{video_rating}", m.content.rating).Replace("{content_duration}", content_duration).Replace("{content_len}", content_duration)
        VastUrlN = VastUrlN.Replace("{vid_duration}", content_duration).Replace("{page_url}", page_url).Replace("{language}", language).Replace("{device_type}", device_type)
       
        VastUrlN = VastUrlN.Replace("{cb}", cb).Replace("{ua}", ua)
        VastUrlN = VastUrlN.Replace("{did}", did).Replace("{device_ifa}", did).Replace("{os}", os).Replace("{osv}", osv)
        VastUrlN = VastUrlN.Replace("{model}", device_model).Replace("{device_model}", device_model).Replace("{device_make}", device_make)
        VastUrlN = VastUrlN.Replace("{device_width}", player_width).Replace("{device_height}", player_height).Replace("{player_width}", player_width).Replace("{player_height}", player_height)
        VastUrlN = VastUrlN.Replace("{connection_type}", connection_type)

        VastUrlN = VastUrlN.Replace("{GDPR}", gdpr).Replace("{CONSENT}", gdpr_consent).Replace("{IFA_TYPE}", ifa_type).Replace("{dnt}", dnt).Replace("{us_privacy}", us_privacy)
        VastUrlN = VastUrlN.Replace("{GPP_STRING}", gpp_String).Replace("{GPP_SID}", gpp_sid)
        VastUrlN = VastUrlN.Replace("{COPPA}", coppa).Replace("{POD_AD_SLOTS}", pod_ad_slots).Replace("{CONTENT_LIVESTREAM}", content_livestream)
       

        VastUrlN = VastUrlN.Replace("{app_name}", app_name).Replace("{app_version}", app_version)
        VastUrlN = VastUrlN.Replace(" ", "%20").Replace("|", "%7C").Replace("(", "%28").Replace(")", "%29").Replace("\", "")
        VastUrlN = VastUrlN + "&custom_app_version=" + app_version
    end if

    return VastUrlN
end function

sub GetHBCUVastData(vastURlEndpoint as string)
    m.getVastInProgress = true
    m.getHBCUVastDataTask = CreateObject("roSGNode", "HBCUAPIAction")
    m.getHBCUVastDataTask.functionName = "GetHBCUVastData"
    m.getHBCUVastDataTask.replacedVastUrl = vastURlEndpoint
    m.getHBCUVastDataTask.forMidroll = false
    m.getHBCUVastDataTask.ObserveField("result", "OnGetHBCUVastDataAPIResponse")
    m.getHBCUVastDataTask.control = "RUN"
end sub

sub OnGetHBCUVastDataAPIResponse(event as dynamic)
    vastAPIResponseData = event.getData()
    if (vastAPIResponseData.data <> invalid and vastAPIResponseData.ok and vastAPIResponseData.data.content <> invalid)
        vastData = ""
        if (not IsNullOrEmpty(vastAPIResponseData.data.content.vast_url))
            vastData = vastAPIResponseData.data.content.vast_url
            ' vastData = vastData.Replace("{series_title}", "").Replace("{content_episode}", "").Replace("{content_season}", "")
        end if
        GlobalSet("VastTAGURLNew", vastData)
        if m.getHBCUVastDataTask.forMidroll = false
            startPlayback()
        else
            if m.PlayerTask <> invalid
                m.PlayerTask.gettingUpdatedVastInProgress = false
            end if
        end if
    else
        if m.PlayerTask <> invalid
            m.PlayerTask.gettingUpdatedVastInProgress = false
        end if
        if m.getHBCUVastDataTask.forMidroll = false
            vastData = ""
            GlobalSet("VastTAGURLNew", vastData)
            startPlayback()
        end if
    end if

    m.getVastInProgress = false
end sub

sub GetUpdatedVastForMidroll(event as dynamic)
    getUpdatedVast = event.GetData()
    if (getUpdatedVast = true)
        m.getVastInProgress = true
        if (m.getHBCUVastDataTask <> invalid )
            vastURL = GlobalGet("vastUrl")
            vastUrlReplaced = getVastTagAdsURL(vastUrl)
            vastUrlReplaced = vastUrlReplaced.Replace("{Ad_Position}", "mid")
            m.getHBCUVastDataTask.replacedVastUrl = vastUrlReplaced
            m.getHBCUVastDataTask.forMidroll = true
            m.getHBCUVastDataTask.control = "RUN"
        end if
    end if
end sub

sub PreparedAnalyticsData(content as dynamic, lastPosition = 0 as dynamic)
    if CreateObject("roDeviceInfo").IsRIDADisabled()
        m.clientId = CreateObject("roDeviceInfo").GetRandomUUID()
    else
        m.clientId = CreateObject("roDeviceInfo").GetChannelClientId()
    end if
    m.statAA = {}
    m.statAA["channelName"] = CreateObject("roAppInfo").GetTitle()
    m.statAA["channelId"] = content.channel_id
    m.statAA["videoTitle"] = content.title
    m.statAA["videoId"] = content._id
    m.statAA["startTime"] = lastPosition
    m.statAA["deviceId"] = m.clientId
    m.statAA["platform"] = "Roku"
    m.statAA.SetModeCaseSensitive()
end sub

sub StartPlayer(lastPosition as integer, isLive = false as boolean)
    PreparedAnalyticsData(m.content, lastPosition)
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.title = m.content.Title
    if m.top.isTrailer 
        if m.content.trailerUrl <> invalid and m.content.trailerUrl <> ""
            streamUrl = m.content.trailerUrl
        end if
    else 
        streamUrl = m.content.hls_url
    end if

    if (isLive = true)
        videoContent.url = ReplaceMacrosForLive(streamUrl)
    else
        videoContent.url = streamUrl
    end if
    videoContent.streamformat = "auto"
    if not m.top.isTrailer 
        m.PlayerOverlay.duration = m.content.duration.toInt()
        if m.content.srt_url <> invalid and m.content.srt_url <> ""
            videoContent.SubtitleConfig = { TrackName: m.content.srt_url }
        else if m.content.vtt_url <> invalid and m.content.vtt_url <> ""
            videoContent.SubtitleConfig = { TrackName: m.content.vtt_url }
        end if
    else
        m.PlayerOverlay.duration = 0
    end if
    videocontent.live = isLive
    updateVideoDetail()
    if m.top.content.is_live = 0
        m.PlayerOverlay.videoPosition = lastPosition
    end if
    m.videoPlayer.content = videoContent
    if m.global.userSellingOrSharingPreference = true
        initializeMediaMelon()
        setupMediaMelonContent(m.content)
    end if
    if m.global <> invalid and m.global.MMAnalytics <> invalid
        m.global.MMAnalytics.setField("exit", false)
        m.global.MMAnalytics.setField("view", "start")
    end if

    m.videoPlayer.notificationInterval = 1

    if lastPosition = m.content.duration.toInt()
        m.videoPlayer.seek = 0
        m.videoPlayer.seekMode = "accurate"
    else if (lastPosition <> -1)
        m.videoPlayer.seek = lastPosition
        m.videoPlayer.seekMode = "accurate"
    end if
    if m.top.SetAnimation
        m.blackRect.width = 160
        m.blackRect.height = 90
        m.blackRect.translation = [880, 375]
        m.blackRect.visible = true
        m.videoPlayer.visible = false
        m.startanimation.control = "start"
    else
        m.blackRect.visible = false
        m.videoPlayer.translation = [0, 0]
        m.videoPlayer.visible = true
    end if
    m.PlayerOverlay.isLive = isLive
    m.PlayerOverlay.isTrailer = m.top.isTrailer
    if isLive = true or m.top.isTrailer
        m.videoPlayer.control = "play"
    else
        vastURL = GlobalGet("vastUrl")
        if (vastUrl <> invalid or vastUrl <> "")
            vastUrlReplaced = getVastTagAdsURL(vastUrl)
            vastUrlReplaced = vastUrlReplaced.Replace("{Ad_Position}", "pre")
            GetHBCUVastData(vastUrlReplaced)
        else 
            m.videoPlayer.control = "play"
        end if
        m.LoadingPer.text = ""
        showLoadingBar()
    end if
    m.videoPlayer.setFocus(true)
end sub

sub startPlayback()
    if m.PlayerTask <> invalid
        m.PlayerTask.control = "stop"
        m.PlayerTask = invalid
    end if
    m.PlayerTask = CreateObject("roSGNode", "PlayerTask")
    m.PlayerTask.videodata = m.content
    m.PlayerTask.video = m.videoPlayer
    m.PlayerTask.vastURL = m.top.vastURL
    m.PlayerTask.bookmark = m.videoPlayer.seek
    ' m.PlayerTask.currentPosition = 0
    m.PlayerTask.gettingUpdatedVastInProgress = false
    m.PlayerTask.getUpdatedVast = false
    ' m.PlayerTask.observeField("currentState", "OnVideoPlayerStatusChange")
    m.PlayerTask.observeField("playingAd", "OnPlayingAd")
    ' m.PlayerTask.observeField("currentPosition", "OnVideoPositionChanged")
    m.PlayerTask.observeField("stopped", "OnStoppedPlayer")
    m.PlayerTask.observeField("getUpdatedVast", "GetUpdatedVastForMidroll")
    m.PlayerTask.functionName = "playContentWithAds"
    m.PlayerTask.control = "RUN"
end sub

sub OnPlayingAd()
    hideLoadingBar()
end sub

sub OnVideoPlayerStatusChange(event as dynamic)
    m.videoStatus = event.GetData()
    print "VideoPlayer : OnVideoPlayerStatusChange : Video Status : " m.videoStatus

    m.PlayerOverlay.videoPlayerState = m.videoStatus

    if m.videoStatus = "stopped" then
        if m.videoPlayer.position <> 0 then
            m.PlayerOverlay.seekPosition = m.videoPlayer.position
        end if
    end if
    if m.videoStatus = "playing"
        if m.top.isTrailer
            m.PlayerOverlay.duration = m.videoPlayer.duration
        end if
        if not m.lastVideoStateOnBuffering = "paused"
            m.videoPlayer.setFocus(true)
            m.PlayerOverlay.action = {
                userAction: "PLAYED",
                videoPosition: m.videoPlayer.position
            }
            triggerHideControlsTimer(false, false)
            fadeOutControls(true)
        else
            m.lastVideoStateOnBuffering = ""
            m.videoPlayer.control = "pause"
            m.PlayerOverlay.action = {
                userAction: "PAUSED",
                videoPosition: m.videoPlayer.position
            }
            triggerHideControlsTimer(false)
        end if

    else if m.videoStatus = "finished"
        PlayNextVideo()
    else if m.videoStatus = "paused"
        updateVideoDetail()
        fadeOutControls(false)
        triggerHideControlsTimer(false)
        m.PlayerOverlay.setFocus(true)
    else if m.videoStatus = "error"
        if (m.global.MMAnalytics <> invalid)
            m.global.MMAnalytics.error = { errorMsg: m.videoPlayer.errorInfo }
        end if
        ClosePlayer()
    end if
end sub

function OnSeekingStatusChanged(event as dynamic)
    status = event.getData()
    if status = "STARTED" then
        if m.videoPlayer.state = "buffering"
            m.lastVideoStateOnBuffering = "paused"
        end if
        if (not m.videoPlayer.state = "buffering") then m.videoPlayer.control = "pause"
        triggerHideControlsTimer(false)
    else if status = "STOPPED" then
        if m.PlayerOverlay.seekPosition <> -1 and m.videoStatus <> "buffering" then
            m.videoPlayer.seek = m.PlayerOverlay.seekPosition
            m.videoPlayer.seekMode = "accurate"
        end if
        m.videoPlayer.seekMode = "accurate"
        m.videoPlayer.control = "resume"
    end if
end function

' *** Loading Bar Section *** '
function initLoadingBar()
    m.loadingPercentage = 0
    m.LoadingIndicator.control = "stop"
    m.LoadingIndicator.visible = false
    m.LoadingIndicator.poster.uri = "pkg:/images/loader/small-loader.png"
    m.LoadingIndicator.poster.width = "60"
    m.LoadingIndicator.poster.height = "60"
    m.loading.visible = false
    m.LoadingPer.visible = false
end function

function showLoadingBar()
    m.loading.visible = true
    m.LoadingPer.visible = true
    m.LoadingIndicator.control = "start"
    m.LoadingIndicator.visible = true
end function

function hideLoadingBar()
    m.loading.visible = false
    m.LoadingPer.visible = false
    m.LoadingIndicator.control = "stop"
    m.LoadingIndicator.visible = false
    m.loadingPercentage = 0
end function

function handleBufferingStatus(event as dynamic)
    bufferingStatus = event.GetData()
    if bufferingStatus <> invalid
        m.loadingPercentage = bufferingStatus.percentage
        if m.LoadingPer <> invalid then
            m.LoadingPer.text = (m.loadingPercentage).ToStr() + "%"
            m.LoadingPer.color = "#FFFFFF"
        end if
        showLoadingBar()
        if m.loadingPercentage = 100
            hideLoadingBar()
        end if
    end if
end function
' *** Loading Bar Section *** '

sub updateVideoDetail()
    if m.top.content <> invalid
        m.PlayerOverlay.videoParams = m.top.content
    end if
end sub

sub OnVideoPositionChanged(event as object)
    m.videoPos = event.getData() / 1
    if m.videoPos > 0
        m.PlayerOverlay.videoPosition = m.videoPos
    end if
    if m.top.content.is_live = 0
        SaveProgress()
    end if
    if (m.videoPos <> 0 and (m.videoPos mod m.heartbeatInt = 0))
        if m.videoPos <> m.previous_videoPos
            SendSegmentAnalyticsHeartBeatData()
            m.previous_videoPos = m.videoPos
        end if
    end if
end sub

sub SendSegmentAnalyticsHeartBeatData()
    ' For Segment Analytics'
    if (m.appconfig.enableSegmentAnalytics = true)
        if (m.appconfig.segmentWriteKey <> invalid AND m.appconfig.segmentWriteKey <> "")
            m.scene.segmentEvent = GetSegmentVideoEventInfo()
        else
            print "[VideoPlayer] [HEARTBEAT] ERROR : SEGMENT ANALYTICS > Missing Account ID. Please set 'segmentWriteKey' in appConfig.json"
        end if
    end if
end sub

            
sub OnStartVideoAPIResponse()
    if (m.getStartVideoTask.result <> invalid and m.getStartVideoTask.result.ok) then
        response = m.getStartVideoTask.result.data
        if response.success = "true" and response.sessionId <> invalid and response.sessionId <> ""
            GlobalSet("SessionId", response.sessionId)
            m.heartbeatInt = response.heartbeatInt
        end if
    end if
    m.getStartVideoTask = invalid
end sub

sub OnHeartBeatAPIResponse()
    if (m.getHeartBeatTask.result <> invalid and m.getHeartBeatTask.result.ok) then
        response = m.getHeartBeatTask.result.data
        'print "OnHeartBeatAPIResponse " response
    end if
    m.getHeartBeatTask = invalid
end sub

sub OnSeekAPIResponse()
    if (m.getSeekTask.result <> invalid and m.getSeekTask.result.ok) then
        ' response = m.getSeekTask.result.data
    end if
    m.getSeekTask = invalid
end sub

sub OnEndAPIResponse()
    if (m.getEndTask.result <> invalid and m.getEndTask.result.ok) then
    end if
    m.getEndTask = invalid
end sub

sub SaveProgress(forceSave = false as boolean, duration = invalid as dynamic)
    position = m.videoPlayer.position \ 1
    if not m.top.isTrailer
        if (forceSave = true or (position mod 5 = 0 and m.top.content.duration.toInt() <> 0))
            m.SetVideoPositionTask = CreateObject("roSGNode", "VideoPositionTask")
            m.SetVideoPositionTask.videoId = m.content._id.toStr()
            if duration <> invalid
                m.SetVideoPositionTask.newPosition = duration.toStr()
            else            
                m.SetVideoPositionTask.newPosition = position.toStr()
            end if
            m.SetVideoPositionTask.functionName = "savePosition"
            m.SetVideoPositionTask.control = "RUN"
        end if
    end if
end sub

function GetSegmentVideoEventInfo()

    scene = m.top.getScene()

    eventStr = GetSegmentVideoStateEventString("playingHeartBeat")
    properties = {
            "asset_id": m.content._id.toStr(),
            "asset_display_name": m.content.Title,
            "asset_system_name": "",
            "channel_id": m.global.appConfig.channel_id,
            "platform": "roku",
            "version": GetAppVersions()
        }

    trackObj = {
        "action": "track",
        "event": eventStr,
        "userId": "",
    }

    trackObj.properties = properties
    print "heartbeat trackObj : " trackObj
    print "heartbeat trackObj.properties : " trackObj.properties

    return trackObj
end function


sub CheckAndShowResumeDialog()
    bookmark = GetBookmarkData(m.content._id.toStr())
    if IsShowResume(bookmark)
        m.bookmarkPos = bookmark
        m.isResumeDialog = true
        message = "Looks like you already started watching: " + chr(10) + chr(10) + """" + m.content.Title + """"
        position = FormatTime(bookmark, true)
        ShowResumeDialog(m.content.poster, message, position)
    else
        m.bookmarkPos = 0
        m.PlayerOverlay.seekPosition = m.bookmarkPos
        StartPlayer(m.bookmarkPos)
    end if
end sub

sub IsShowResume(bookmark as integer) as boolean
    result = false
    if (bookmark <> invalid and bookmark > 0 and m.content.duration <> invalid and m.content.duration.toInt() > 0)
        percentProg = ((100 * bookmark) / m.content.duration.toInt())
        if (percentProg > 2 and percentProg < 98)
            result = true
        end if
    end if
    return result
end sub

sub ShowResumeDialog(posterImage as string, messageText as string, position as string)
    if (m.ResumeDialog <> invalid) then
        m.top.removeChild(m.ResumeDialog)
    end if
    m.isShowYesNoButtons = true
    ' Create Message Dialog'
    m.ResumeDialog = CreateObject("roSGNode", "ExitDialog")
    m.ResumeDialog.id = "ResumeDialog"
    m.ResumeDialog.message = messageText
    if (IsNullOrEmpty(posterImage))
        posterImage = "pkg:/images/others/default_poster.png"
    end if
    m.ResumeDialog.posterURL = posterImage
    m.ResumeDialog.yesBtnText = "Play from beginning"
    m.ResumeDialog.noBtnText = "Resume from " + position
    m.ResumeDialog.isResumeBox = true
    m.ResumeDialog.observeField("selectedButton", "ResumeDialog_ButtonSelected")
    m.top.appendChild(m.ResumeDialog)
    m.ResumeDialog.setFocus(true)
end sub

' Message dialog button section'
sub ResumeDialog_ButtonSelected(event as dynamic)
    data = event.GetData()
    CloseResumeDialog()
    if (m.isShowYesNoButtons = true and data <> 2)
        m.isShowYesNoButtons = false
        if (m.isResumeDialog = true)
            if data <> invalid and data = 1 then
                StartPlayer(0)
            else
                m.PlayerOverlay.seekPosition = m.bookmarkPos
                StartPlayer(m.bookmarkPos)
            end if
        end if
    else
        ClosePlayer()
    end if
end sub

sub CloseResumeDialog()
    if (m.ResumeDialog <> invalid) then
        m.top.removeChild(m.ResumeDialog)
        m.ResumeDialog = invalid
    end if
end sub

sub OnStoppedPlayer()
    ClosePlayer()
end sub

sub PlayNextVideo()
    if m.top.contentPlaylist <> invalid and m.top.contentIndex < (m.top.contentPlaylist.getChildCount() - 1)
        StopPlayerForNextVideo()
        PrepareAndPlayNextVideoContent()
    else
        SaveProgress(true, m.videoPlayer.duration)
        showOverlay(false)
        ClosePlayer()
    end if
end sub

sub PrepareAndPlayNextVideoContent()
    if (m.top.contentIndex < m.top.contentPlaylist.getChildCount() - 1)
        contentIndex = m.top.contentIndex + 1
        m.top.contentIndex = contentIndex
        content = m.top.contentPlaylist.getChild(contentIndex)
        if (content <> invalid)
            m.top.SetAnimation = false
            m.scene.IsStartFromBeginning = true
            m.top.content = content
        end if
    end if
    m.scene.IsUpdateData = true
end sub


sub StopPlayerForNextVideo()
    showOverlay(false)
    SaveProgress(true, m.videoPlayer.duration)
    if m.PlayerTask <> invalid
        m.PlayerTask.control = "stop"
        m.PlayerTask = invalid
    end if
    m.scene.IsStopUpdateProgressTimer = false
end sub

sub ClosePlayer()
    hideLoadingBar()
    SaveProgress(true)
    showOverlay(false)
    if m.global <> invalid and m.global.MMAnalytics <> invalid
        m.global.MMAnalytics.setField("view", "end")
        m.global.MMAnalytics.setField("exit", true)
    end if
    if m.PlayerTask <> invalid
        m.PlayerTask.control = "stop"
        m.PlayerTask = invalid
    end if

    m.videoPlayer.control = "stop"
    showOverlay(false)
    m.top.isVideoPlayerStopped = true
    m.videoPlayer.visible = false
    m.scene.IsUpdateData = true
    m.scene.IsStopUpdateProgressTimer = false
end sub

function OnOkPress(key as string)
    m.PlayerOverlay.videoPlayerState = m.videoPlayer.state
    if (m.videoPlayer.state = "playing" or m.videoPlayer.state = "buffering") then
        m.PlayerOverlay.action = {
            userAction: "PAUSED",
            videoPosition: m.videoPlayer.position
        }
        if m.videoPlayer.state = "buffering"
            if key = "play" and m.lastVideoStateOnBuffering <> ""
                if m.lastVideoStateOnBuffering = "paused"
                    m.lastVideoStateOnBuffering = "playing"
                    m.PlayerOverlay.action = {
                        userAction: "PLAYED",
                        videoPosition: m.videoPlayer.position
                    }
                else if m.lastVideoStateOnBuffering = "playing"
                    m.lastVideoStateOnBuffering = "paused"
                end if
            else
                m.lastVideoStateOnBuffering = "paused"
            end if
        end if
        'Handle case: Roku player stuck at 99% if we again pasue while state is paused already.
        if (not (m.videoPlayer.state = "buffering")) then m.videoPlayer.control = "pause"
    else if m.videoPlayer.state <> "none"
        m.PlayerOverlay.action = {
            userAction: "PLAYED",
            videoPosition: m.videoPlayer.position
        }
        if(m.PlayerOverlay.seekPosition <> m.videoPlayer.seek)
            m.videoPlayer.seek = m.PlayerOverlay.seekPosition
            m.videoPlayer.seekMode = "accurate"
        else
            m.videoPlayer.control = "resume"
        end if
    end if
end function

function OnReplay()
    position = ((m.videoPlayer.position \ 1) - 20)
    if (position > 0)
        m.videoPlayer.seek = position
        m.videoPlayer.seekMode = "accurate"
        m.videoPlayer.control = "resume"
    end if
end function

sub OnFocusedChild()
    if m.top.hasFocus()
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    result = false
    if (press)
        if ((key = "up" or key = "down") and m.videoPlayer.state <> "none")
            fadeOutControls(false)
            triggerHideControlsTimer(true)
            m.PlayerOverlay.setFocus(true)
            result = true
        else if (key = "back") then
            if (m.ResumeDialog <> invalid) then
                CloseResumeDialog()
            else if m.PlayerOverlay.visible = true
                showOverlay(false)
                m.videoPlayer.setFocus(true)
            else
                if (m.getVastInProgress = true)
                    m.getHBCUVastDataTask.control = "stop"
                    m.getVastInProgress = false
                end if
                ClosePlayer()
            end if
            result = true
        else if (key = "play" or key = "OK") then
            OnOkPress(key)
            result = true
        else if (key = "replay") then
            OnReplay()
            result = true
        else if ((m.isLive = false and m.top.isTrailer = false and key = "left" or key = "right") and m.videoPlayer.state <> "none")
            triggerHideControlsTimer(false)
            m.PlayerOverlay.key = { "key": key, "press": press }
            result = true
        else if ((m.isLive = false and m.top.isTrailer = false and (key = "fastforward" or key = "rewind")) and m.videoPlayer.state <> "none")
            triggerHideControlsTimer(false)
            m.PlayerOverlay.key = { "key": key, "press": press }
            result = true
        end if
    end if
    return result
end function
