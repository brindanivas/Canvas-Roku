sub init()
    m.top.id = "MM"
    m.top.SDK_VERSION = "RokuSDK_RAF_v2.6.2"
    ?"MediaMelon plugin initialised."
    m.mmSmart = SmartStream()
    m.mmSmart.init()

    m.isLive = false
    m.contentMetadata = {}
    m.config = {}
    m.customConfig = {}
    m.customTags = {}
    m._contentDuration = 0
    m._lastReportedPosition = 0

    m.top.observeField("config", "onConfigUpdate")
    m.top.observeField("customConfig", "onCustomConfigUpdate")
    m.top.observeField("contentMetadata", "onContentMetadataUpdate")
    m.top.observeField("customTags", "onCustomTagsUpdate")
    m.top.observeField("view", "onViewUpdate")
    m.top.observeField("seekThreshold", "onSeekThresholdUpdate")
    m.top.observeField("isVideoLive", "onIsVideoLiveUpdate")

    m.top.functionName = "registerPlugin"
end sub

sub onConfigUpdate(event as object)
    m.config = event.getData()
    m.top.unobserveField("config")
end sub

sub onCustomConfigUpdate(event as object)
    m.customConfig = event.getData()
    m.top.unobserveField("customConfig")
end sub

sub onContentMetadataUpdate(event as object)
    m.contentMetadata = event.getData()
    m.top.unobserveField("contentMetadata")
end sub

sub onCustomTagsUpdate(event as object)
    m.customTags = event.getData()
    m.top.unobserveField("customTags")
end sub

sub onViewUpdate(event as object)
    m.view = event.getData()
    m.top.unobserveField("view")
end sub

sub onSeekThresholdUpdate(event as object)
    m.seekThreshold = event.getData()
    m.top.unobserveField("seekThreshold")
end sub

sub onIsVideoLiveUpdate(event as object)
    m.isLive = event.getData()
    m.top.unobserveField("isVideoLive")
end sub

'Top most function. When the plugin is given control to run, all operations take place in the following function.
'Use "'" to write a comment, Use "?" to print statement to console.
function registerPlugin()
    m.inAdBreak = false
    m.prevSeqNum = -1
    m.isConfigReceived = false
    m.messagePort = _createPort()
    m.exitPort = _createPort()  
    m.inView = false
    m.isInitialised = false
    m.isRegistered = False
    m.isPlaybackInitiated = false
    m._Flag_isSeeking = false
    m.isObserverAdded = false 
    m.content = {}
    m.prevBitrate = 0
    m.representation = []    
    m._seekThreshold = 1.25
    m._failedSegmentRequestCount = 0
    m._isVideoPaused = false
    m._prevBufferingState = "IDLE"
    m._beaconInterval = -1
    m._enableCustomErrorReporting = false
    m._streamInfo = {} 

    if m.config <> invalid        
        if m.config.subscriberId <> invalid            
            if m.config.hashSubscriberId = false
                subscriberId = m.config.subscriberId
            else
                subscriberId = _generateSubId(m.config.subscriberId)
            end if
        else subscriberId = ""
        end if
        if m.config.subscriberType <> invalid
            subscriberType = m.config.subscriberType
        else subscriberType = ""
        end if
        if m.config.subscriberTag <> invalid
            subscriberTag = m.config.subscriberTag
        else subscriberTag = ""
        end if
        if m.config.domainName <> invalid
            domainName = m.config.domainName
        else domainName = ""
        end if
        if m.config.disableManifestFetch <> invalid and (m.config.disableManifestFetch = True or m.config.disableManifestFetch = False)
            m.mmSmart.disableManifestFetch(m.config.disableManifestFetch)
        else
            m.mmSmart.disableManifestFetch(False)
        end if
        if m.config.appName <> invalid
            appName = m.config.appName
            if m.config.appSdkVersion <> invalid
                m.mmSmart.reportAppInfo(m.config.appName, m.config.appSdkVersion)
            end if
        end if
        if m.config.viewSessionId <> invalid
            m.mmSmart.reportViewSessionId(m.config.viewSessionId)
        end if
        if m.config.enableCustomErrorReporting <> invalid
            m._enableCustomErrorReporting = m.config.enableCustomErrorReporting
        end if

        if m.config.playerVersion = invalid
            m.config.playerVersion = ""
        end if
        if m.config.basePlayerName = invalid
            m.config.basePlayerName = ""
        end if
        if m.config.basePlayerVersion = invalid
            m.config.basePlayerVersion = ""
        end if

        m.mmSmart.registerMMSmartStreaming(m.config.playerName, m.config.customerID, "ROKUSDK", subscriberId, domainName, subscriberType, subscriberTag)
        m.mmSmart.reportPlayerInfo(m.config.playerVersion, m.config.basePlayerName, m.config.basePlayerVersion)
        'Report device information to the SDK
        deviceInfo = setDeviceInfo()
        m.mmSmart.reportDeviceInfo("Roku", deviceInfo["model"], "Roku OS", deviceInfo["osversion"], "None", deviceInfo["width"], deviceInfo["height"])    
        m.mmSmart.reportDeviceId(deviceInfo["channelClientId"])
        if deviceInfo.nwType = "WifiConnection"
            m.mmSmart.reportWifiSSID(deviceInfo["ssid"])
        end if
        m.isRegistered = True
    end if

    if m.customTags <> invalid and m.customTags.count() <> 0
        for each tag in m.customTags.keys()
            m.mmSmart.reportCustomMetaData(tag, m.customTags[tag])
        end for
    end if

    if m.customConfig <> invalid
        if m.customConfig.cdn <> invalid                        
            m.mmSmart.reportCDN(m.customConfig.cdn)
        end if
        if m.customConfig.experimentName <> invalid
            m.mmSmart.reportExperimentName(m.customConfig.experimentName)
        end if
        if m.customConfig.subPropertyId <> invalid
            m.mmSmart.reportSubPropertyId(m.customConfig.subPropertyId)
        end if
        if m.customConfig.streamFormat <> invalid
            m.mmSmart.reportStreamFormat(m.customConfig.streamFormat)
        end if
        if m.customConfig.mediaType <> invalid
            m.mmSmart.reportMediaType(m.customConfig.mediaType)
        end if
        if m.customConfig.drmProtection <> invalid
            m.mmSmart.updateDrmProtection(m.customConfig.drmProtection)
        end if
    end if

    if m.seekThreshold <> invalid and m.seekThreshold > 1
        m._seekThreshold = m.seekThreshold
    end if

    'Observed Fields
    m.top.ObserveField("video", m.messagePort)
    m.top.ObserveField("view", m.messagePort)
    m.top.ObserveField("config", m.messagePort)
    m.top.ObserveField("customConfig", m.messagePort)
    m.top.ObserveField("contentMetadata", m.messagePort)
    m.top.ObserveField("customTags", m.messagePort)
    m.top.ObserveField("imaads", m.messagePort)
    m.top.ObserveField("mmAdData", m.messagePort)
    m.top.ObserveField("mmRafEvent", m.messagePort)    
    m.top.ObserveField("error", m.messagePort)
    m.top.ObserveField("adError", m.messagePort)
    m.top.ObserveField("codecs", m.messagePort)
    m.top.ObserveField("requestInfo", m.messagePort)
    m.top.ObserveField("exit", m.exitPort)    

    m.top.video.ObserveField("state", m.messagePort)
    m.top.video.ObserveField("content", m.messagePort)
    m.top.video.ObserveField("control", m.messagePort)
    m.top.video.ObserveField("streamInfo", m.messagePort)
    m.top.video.ObserveField("duration", m.messagePort)
    m.top.video.ObserveField("seek", m.messagePort)
    m.top.video.observeField("streamingSegment", m.messagePort)    
    m.top.video.ObserveField("contentIndex", m.messagePort)
    m.top.video.ObserveField("position", m.messagePort)

    m.isObserverAdded = True

    if m.view <> Invalid and m.view <> ""
        _videoViewChangeHandler(m.view)
    end if

    'Beacon timer from the plugin. Signals the engine using mmSmart.fireBeacon().
    'Added to both wrapper and smartstream objects
    m.beaconTimer = createObject("roSGNode", "Timer")
    m.beaconTimer.repeat = True
    m.beaconTimer.id = "beaconTimer"
    m.beacontimer.ObserveField("fire", m.messagePort)

    if m.isInitialised <> True and m.isRegistered
        mmContentMetadata = _getContentMetaData(m.contentMetadata)
        response = m.mmSmart.initializeSession("QBRDisabled", "", mmContentMetadata)
        if response["status"] = True
            m.isInitialised = True
            m._beaconInterval = response.interval
        else
            m.isInitialised = False
            m.isRegistered = False
            m._beaconInterval = -1
        end if
    end if

    m.running = true
    'Start the infinite loop waiting for changes from the observed fields
    while (m.running)
        exitMsg = wait(10, m.exitPort)
        msg = wait(40, m.messagePort) 'wait for a message

        if exitMsg <> Invalid
            data = exitMsg.getData()
            if data = true                
                running = false
            end if
        end if

        if msg <> invalid
            msgType = type(msg)
            if msgType = "roSGNodeEvent"
                field = msg.getField()
                if field = "state"
                    msgData = msg.getData()
                    if msgData <> invalid and type(msgData) = "roString"
                        _videoStateChangeHandler(msgData)
                    end if
                else if field = "video"
                    m.top.unobserveField("video")
                    data = msg.getData()
                    _videoAddedHandler(data)
                else if field = "position"
                    currentPos = msg.getData()                    

                    if m._lastVideoState = "playing"                        
                        m.mmSmart.reportPlaybackPosition(currentPos)
                        m._lastReportedPosition = currentPos
                        _reportEvent("PLAYING")
                    end if
                else if field = "google_ima"
                    data = msg.getData()
                else if field = "imaads"
                    msgData = msg.getData()
                    _imaAdsEventHandler(msgData)
                else if field = "codecs"
                    msgData = msg.getData()
                    m.mmSmart.reportCodecs(msgData)
                else if field = "contentMetadata"
                    m.contentMetadata = msg.getData()
                    mmContentMeta = _getContentMetaData(m.contentMetadata)
                    if m._streamInfo <> invalid and m._streamInfo.streamUrl <> invalid
                        m.mmSmart.setStreamURL(m._streamInfo.streamUrl)
                    end if
                    m.mmSmart.reportContentMetadata(mmContentMeta)
                else if field = "customConfig"
                    m.customConfig = msg.getData()

                    if m.customConfig.cdn <> invalid                        
                        m.mmSmart.reportCDN(m.customConfig.cdn)
                    end if
                    if m.customConfig.experimentName <> invalid
                        m.mmSmart.reportExperimentName(m.customConfig.experimentName)
                    end if
                    if m.customConfig.subPropertyId <> invalid
                        m.mmSmart.reportSubPropertyId(m.customConfig.subPropertyId)
                    end if
                    if m.customConfig.streamFormat <> invalid
                        m.mmSmart.reportStreamFormat(m.customConfig.streamFormat)
                    end if
                    if m.customConfig.mediaType <> invalid
                        m.mmSmart.reportMediaType(m.customConfig.mediaType)
                    end if
                    if m.customConfig.drmProtection <> invalid
                        m.mmSmart.updateDrmProtection(m.customConfig.drmProtection)
                    end if
                else if field = "config"
                    m.mmSmart = SmartStream()
                    m.mmSmart.init()

                    if m.isObserverAdded = False
                        m.isObserverAdded = True
                        m.top.video.ObserveField("state", m.messagePort)
                        m.top.video.ObserveField("content", m.messagePort)
                        m.top.video.ObserveField("control", m.messagePort)
                        m.top.video.ObserveField("streamInfo", m.messagePort)
                        m.top.video.ObserveField("duration", m.messagePort)
                        m.top.video.ObserveField("seek", m.messagePort)
                        m.top.video.ObserveField("streamingSegment", m.messagePort)                        
                        m.top.video.ObserveField("error", m.messagePort)
                        m.top.video.ObserveField("contentIndex", m.messagePort)
                    end if

                    m.isConfigReceived = True
                    m.config = msg.getData()

                    if m.config.subscriberId <> invalid            
                        if m.config.hashSubscriberId = false
                            subscriberId = m.config.subscriberId
                        else
                            subscriberId = _generateSubId(m.config.subscriberId)
                        end if
                    else subscriberId = ""
                    end if
                    if m.config.subscriberType <> invalid
                        subscriberType = m.config.subscriberType
                    else subscriberType = ""
                    end if
                    if m.config.domainName <> invalid
                        domainName = m.config.domainName
                    else domainName = ""
                    end if
                    if m.config.subscriberTag <> invalid
                        subscriberTag = m.config.subscriberTag
                    else subscriberTag = ""
                    end if
                    if m.config.appName <> invalid
                        appName = m.config.appName
                        if m.config.appSdkVersion <> invalid
                            m.mmSmart.reportAppInfo(m.config.appName, m.config.appSdkVersion)
                        end if
                    end if
                    if m.config.disableManifestFetch <> invalid and (m.config.disableManifestFetch = True or m.config.disableManifestFetch = False)
                        m.mmSmart.disableManifestFetch(m.config.disableManifestFetch)
                    else
                        m.mmSmart.disableManifestFetch(False)
                    end if
                    if m.config.viewSessionId <> invalid
                        m.mmSmart.reportViewSessionId(m.config.viewSessionId)
                    end if
                    if m.config.enableCustomErrorReporting <> invalid
                        m._enableCustomErrorReporting = m.config.enableCustomErrorReporting
                    end if

                    if m.config.playerVersion = invalid
                        m.config.playerVersion = ""
                    end if
                    if m.config.basePlayerName = invalid
                        m.config.basePlayerName = ""
                    end if
                    if m.config.basePlayerVersion = invalid
                        m.config.basePlayerVersion = ""
                    end if
                    
                    m.mmSmart.registerMMSmartStreaming(m.config.playerName, m.config.customerID, "ROKUSDK", subscriberId, domainName, subscriberType, subscriberTag)
                    deviceInfo = setDeviceInfo()
                    m.mmSmart.reportDeviceInfo("Roku", deviceInfo["model"], "Roku OS", deviceInfo["osversion"], "None", deviceInfo["width"], deviceInfo["height"])
                    m.mmSmart.reportPlayerInfo(m.config.playerVersion, m.config.basePlayerName, m.config.basePlayerVersion)
                    m.mmSmart.reportDeviceId(deviceInfo["channelClientId"])
                    m.isRegistered = True
                else if field = "control"
                    _videoControlChangeHandler(msg.getData())
                else if field = "customTags"
                    customTags = msg.getData()
                    if customTags.count() <> 0
                        for each tag in customTags.keys()
                            m.mmSmart.reportCustomMetaData(tag, customTags[tag])
                        end for
                    end if
                else if field = "mmAdData"
                    msgData = msg.getData()
                    mmRafAdTracking(msgData)
                else if field = "mmRafEvent"
                    msgData = msg.getData()
                    rafEventHandler(msgData)                
                else if field = "duration"
                    m._contentDuration = msg.getData()
                    _setPresentation()
                else if field = "seek"
                else if field = "content"
                    _videoContentChangeHandler(msg.getData())
                else if field = "streamingSegment"
                    segment = msg.getData()
                    if segment.width <> invalid AND segment.height <> invalid
                        if segment.width <> 0 AND segment.height <> 0
                            res = StrI(segment.width) + "x" + StrI(segment.height)
                            res = res.Replace(" ", "")
                            chunk = { "cbrBitrate": segment.segBitrateBps, "dur": -1, "qbrBitrate": segment.segBitrateBps, "downloadRate": segment.segBitrateBps, "seqNum": segment.segSequence, "startTime": segment.segStartTime, "res": res}
                            m.mmsmart.reportChunkRequest(chunk)
                            m._isVideoPaused = false
                        end if
                    else
                        'Legacy Roku
                        chunk = { "cbrBitrate": segment.segBitrateBps, "dur": -1, "qbrBitrate": segment.segBitrateBps, "downloadRate": segment.segBitrateBps, "seqNum": segment.segSequence, "startTime": segment.segStartTime }
                        m.mmsmart.reportChunkRequest(chunk)
                    end if
                else if field = "view"
                    _videoViewChangeHandler(msg.getData())
                else if field = "fire"
                    node = msg.getNode()
                    if node = "beaconTimer"
                        'Segments payload beacons                        
                        m.mmSmart.fireBeacon(m._isVideoPaused)                    
                    end if
                else if field = "error"
                    errordata = msg.getData()
                    if errordata <> invalid
                        _videoErrorHandler(errordata, false)
                    end if
                else if field = "adError"
                    errordata = msg.getData()
                    if errordata <> invalid
                        _videoErrorHandler(errordata, true)
                    end if
                else if field = "streamInfo"
                    m._streamInfo = msg.getData()
                    if m.isInitialised = True                        
                        if m.prevMeasuredBitrate <> m._streamInfo.measuredBitrate and m._streamInfo.measuredBitrate <> invalid
                            m.mmSmart.reportDownloadRate(m._streamInfo.measuredBitrate)
                            m.prevMeasuredBitrate = m._streamInfo.measuredBitrate
                        end if
                    end if
                else if field = "contentIndex"
                    _videoContentIndexChangeHandler(msg.getData())
                else if field = "requestInfo"
                    _reportRequestInfo(msg.getData())
                end if
            else if (msgType = "String" or msgType = "roString")
                field = msg.getField()
            else if (msgType = "Boolean" or msgType = "roBoolean")
                field = msg.getField()
            end if
        end if
    end while

    m.beaconTimer.control = "stop"    

    m.beaconTimer.UnobserveField("fire")    

    m.top.UnobserveField("video")
    m.top.UnobserveField("config")
    m.top.UnobserveField("control")
    m.top.UnobserveField("view")
end function

function _getContentMetaData(content as object) as object
    mmContentMeta = {}
    if content <> invalid
        if content.videoId <> invalid
            mmContentMeta.AddReplace("videoID", content.videoId)
        else
            mmContentMeta.AddReplace("videoID", "NA")
        end if
        if content.assetId <> invalid
            mmContentMeta.AddReplace("assetID", content.assetId)
        else
            mmContentMeta.AddReplace("assetID", "NA")
        end if
        if content.assetName <> invalid
            mmContentMeta.AddReplace("assetName", content.assetName)
        else
            mmContentMeta.AddReplace("assetName", "NA")
        end if
        if content.contentType <> invalid
            mmContentMeta.AddReplace("contentType", content.contentType)
        end if
        if content.genre <> invalid
            mmContentMeta.AddReplace("genre", content.genre)
        end if
        if content.drmProtection <> invalid
            mmContentMeta.AddReplace("drmProtection", content.drmProtection)
        end if
        if content.episodeNumber <> invalid
            mmContentMeta.AddReplace("episodeNumber", content.episodeNumber)
        end if
        if content.season <> invalid
            mmContentMeta.AddReplace("season", content.season)
        end if
        if content.seriesTitle <> invalid
            mmContentMeta.AddReplace("seriesTitle", content.seriesTitle)
        end if
        if content.videoType <> invalid
            mmContentMeta.AddReplace("videoType", content.videoType)
        end if
    end if
    return mmContentMeta
end function

function _initiatePlayback() as void 
    if m.isInitialised = True and m.isRegistered and m.isPlaybackInitiated <> true        
        if m._streamInfo <> invalid and m._streamInfo.streamUrl <> invalid
            m.mmSmart.setStreamURL(m._streamInfo.streamUrl)
            _setPresentation()
            m.beaconTimer.duration = m._beaconInterval            
            m.mmSmart.reportUserInitiatedPlayback()
            m.isPlaybackInitiated = true
            m._isVideoPaused = false
            m.beaconTimer.control = "start"                     
        end if
    end if
end function

function _initializeSession()
    streamURL = ""
    if m._streamInfo <> invalid and m._streamInfo.streamUrl <> invalid
        streamURL = m._streamInfo.streamUrl
    end if

    if m.isRegistered
        mmContentMetadata = _getContentMetaData(m.contentMetadata)
        response = m.mmSmart.initializeSession("QBRDisabled", streamURL, mmContentMetadata)
        _setPresentation()

        if response.status = True
            m.isInitialised = True
            m._beaconInterval = response.interval
        else
            m.isInitialised = False
            m.isRegistered = False
            m._beaconInterval = -1
        end if
    end if
end function

function _startView(setByClient = false as boolean) as void
    if setByClient = true
        m._clientOperatedStartAndEnd = true
    end if
    if m._clientOperatedStartAndEnd = true AND setByClient = false then return    
    
    if m.inView = false
        if m.isInitialised <> True
            _initializeSession()      
        end if        
        m.inView = true
    end if

    if m.top.video <> invalid        
        _videoAddedHandler(m.top.video)
    end if
end function

function _endView(setByClient = false as boolean) as void
    if m._clientOperatedStartAndEnd = true AND setByClient = false then return
    if m._clientOperatedStartAndEnd = false AND setByClient = true then return

    if m.inView = true
        if m.isLive = false and m._lastReportedPosition > 0 and m._contentDuration > 0 and m._lastReportedPosition >= m._contentDuration
            _reportEvent("COMPLETE")
        else 
            _reportEvent("ENDED")
        end if
        m.beaconTimer.control = "stop"        
        m.inAdBreak = false
        m._isVideoPaused = false        
        m.isLive = false        
        m.isInitialised = False        
        m._beaconInterval = -1
        m.isPlaybackInitiated = false
        m.prevBitrate = 0
        m._lastVideoState = invalid
        m._prevBufferingState = "IDLE"
        m.firstQuartileSent = false
        m.midQuartileSent = false
        m.thirdQuartileSent = false
        m.representation = []
        m.prevMeasuredBitrate = invalid
        m._lastReportedPosition = 0
        m._lastPause = invalid
        m.isConfigReceived = false
        m.prevSeqNum = -1
        m._failedSegmentRequestCount = 0
        m._flag_isSeeking = false
        m.inView = false
        m.contentMetadata = {}
        m.config = {}
        m.customConfig = {}
        m.customTags = {}
    end if
end function

function _videoViewChangeHandler(view as string)
    if view = "end"
        _endView(true)
    else if view = "start"        
        _startView(true)
    end if
end function

function _reportRequestInfo(requestInfo as object)
    eventName = ""
    if requestInfo <> invalid
        if requestInfo.requestStatus <> invalid
            if requestInfo.requestStatus = "failed"
                eventName = "RF_"
            else if requestInfo.requestStatus = "cancelled"
                eventName = "RC_"
            end if
        end if

        if requestInfo.requestType <> invalid
            eventName = eventName + UCase(requestInfo.requestType)
        end if

        if eventName <> ""  and ((Left(eventName, 3) = "RF_") or (Left(eventName, 3) = "RC_"))          
            m.mmSmart.reportRequestStatusEvent(eventName, requestInfo)
        end if
    end if
end function

function _videoAddedHandler(video as object)
    m.video = video
end function

function _videoStateChangeHandler(videoState as string)
    if m.isRegistered and m.video <> invalid
        m._isPaused = (videoState = "paused" or (videoState = "buffering" and m._lastVideoState = "paused"))
        '_checkForSeek is called at states buffering,paused and playing because the state transition during seeking is
        'PAUSE->BUFFERING->PLAYING->BUFFERING

        previouslyLastReportedPosition = m._lastReportedPosition
        currentPlayheadPosition = m.video.position

        if m._Flag_isSeeking <> true and m.isPlaybackInitiated = true
            if (currentPlayheadPosition < previouslyLastReportedPosition) or (currentPlayheadPosition > (previouslyLastReportedPosition + m._seekThreshold))
                _reportEvent("SEEKING")
                m._Flag_isSeeking = true
            end if
        end if

        if videoState = "buffering"            
            if m.isInitialised
                _reportEvent("BUFFERING")
            end if
        else if videoState = "paused"  
            _reportEvent("PAUSE")
        else if videoState = "playing"
            _reportEvent("PLAYING")
        else if videoState = "stopped" or videoState = "finished"
            if m.isInitialised
                _endView()
            end if
        else if videoState = "error"
            if m._enableCustomErrorReporting <> true
                errorCode = "NA"
                errorMessage = "NA"
                errorDetails = "NA"
                finalErrorString = ""

                if m.video <> invalid
                    if m.video.errorCode <> invalid
                        errorCode = Str(m.video.errorCode)
                    end if
                    if m.video.errorMsg <> invalid
                        errorMessage = m.video.errorMsg
                    end if
                    if m.video.errorStr <> invalid
                        errorDetails = m.video.errorStr
                    end if
                end if
                
                finalErrorString = errorCode + "_" + errorMessage + "_" + errorDetails
                m.mmSmart.reportError(finalErrorString, m._lastReportedPosition) 
            end if
        end if

        if m.video <> invalid            
            if m.inAdBreak = false                  
                m._lastVideoState = videoState
            end if
        end if

    end if
end function

function _videoControlChangeHandler(control as string)
    if control = "play" or control = "resume"
        _startView()
    else if control = "pause"
        _reportEvent("PAUSE")
    else if control = "stop"
        _endView()        
    end if
end function

function _videoContentChangeHandler(videoContent as object)
    m.content = videoContent
    if m.content.StreamBitrates <> invalid
        m.representation = m.content.StreamBitrates
    else if m.content.Streams <> invalid
        for each item in m.content.streams
            m.representation.push(item.bitrate)
        end for
    else if m.content.Stream <> invalid
        m.representation.Push(m.Content.Stream.bitrate)
    end if

    if m._clientOperatedStartAndEnd <> true and m.isInitialised = true
        _endView()
        _startView()
    end if
end function

function _videoContentIndexChangeHandler(contentIndex as integer)
    if contentIndex > 0
        _endView(true)
        _startView(true)
    end if
end function

function _videoErrorHandler(error as object, isAdError as boolean)
    errorObject = error
    errorCode = "NA"
    errorMessage = "NA"
    errorDetails = "NA"
    errorCategory = "FATAL"
    finalErrorString = ""
    if errorObject <> invalid
        if errorObject.errorCode <> invalid
            errorCode = errorObject.errorCode
        end if
        if errorObject.errorMessage <> invalid
            errorMessage = errorObject.errorMessage
        end if
        if errorObject.errorDetails <> invalid
            errorDetails = errorObject.errorDetails
        end if
        if error.errorSeverity <> Invalid
            if error.errorSeverity = "warning"
                errorCategory = "WARNING"
            end if
        end if
    end if

    if Type(errorCode) = "Integer" or Type(errorCode) = "Float" or Type(errorCode) = "roInt" or Type(errorCode) = "roFloat"
        errorCode = Str(errorCode)
    end if
     
    finalErrorString = errorCode + "_" + errorMessage + "@@" + errorCategory + "@@" + errorDetails

    if isAdError = True        
        m.mmSmart.reportAdError(finalErrorString, m._lastReportedPosition)
    else
        m.mmSmart.reportError(finalErrorString, m._lastReportedPosition)
    end if
end function

'Function to send presentation information to the SDK
function _setPresentation() as void    
    streamSourceType = "NA"
    if m._streamInfo <> invalid and m._streamInfo.streamUrl <> invalid        
        streamSourceType = _getStreamSourceType(m._streamInfo.streamUrl)
    end if

    presentation = { "isLive": m.isLive, "duration": m._contentDuration, "representation": m.representation, "streamSourceType":  streamSourceType}
    m.mmSmart.setPresentationInformation(presentation)
end function

'Function to report a playback event to the SDK. Sends both playback time and event state to SDK.
function _reportEvent(eventType as string)
    if eventType = "BUFFERING"
        if m.isPlaybackInitiated = true
            m.mmSmart.reportBufferingStarted(m._Flag_isSeeking)                      
            m._prevBufferingState = "BUFFERING_START"
        end if   
    else if eventType = "PLAYING"
        if m.isInitialised = false
            _startView(true)
        end if
        
        if m.isPlaybackInitiated = false
            _initiatePlayback()
        else
            if m._prevBufferingState = "BUFFERING_START"
                m.mmSmart.reportBufferingCompleted()
                m._prevBufferingState = "BUFFERING_COMPLETE"
            end if

            if m._Flag_isSeeking = true
                m.mmSmart.reportPlayerSeekCompleted(m._lastReportedPosition)
                m._Flag_isSeeking = false
            end if

            if m._Flag_isSeeking = false or m._Flag_isSeeking = invalid
                if m._isVideoPaused = true
                    if m.inAdBreak = true
                        m.mmSmart.reportAdState("AD_RESUMED")
                    else
                        m.mmSmart.reportPlayerState("RESUME")
                    end if

                    m.beaconTimer.control = "start"
                    m._isVideoPaused = false
                end if
            end if
        end if
    else if eventType = "PAUSE"
        if m._Flag_isSeeking = false or m._Flag_isSeeking = invalid
            if m.isPlaybackInitiated = true and m._isVideoPaused = false
                if m.inAdBreak = true
                    m.mmSmart.reportAdState("AD_PAUSED")
                else
                    m.mmSmart.reportPlayerState("PAUSE")
                end if

                m._isVideoPaused = true 'Adding this to send ping payload instead of stats when video is paused
                ' m.beaconTimer.control = "stop" 'HERE
            end if            
        end if
    else if eventType = "SEEKING"
        m.mmSmart.reportPlayerSeekStarted()
    else
        m.mmSmart.reportPlayerState(eventType)
    end if
end function

'************* CUSTOM FUNCTION FOR PROJECT W **************
function rafEventHandler(data)
    if data <> invalid
        eventType = data.eventType
        obj = data.obj
        ctx = data.ctx

        adURL = ""
        if obj <> Invalid
        if obj.adurl <> Invalid
            adURL = obj.adurl
        end if
        end if

        _rafEventHandler(eventType, ctx, adURL)
    end if    
end function

function _rafEventHandler(eventType, ctx, adURL)
    if eventType = "Start"
        m.inAdBreak = true
    else if eventType = "PodComplete" or eventType = "Complete" or eventType = "Skip"
        m.inAdBreak = false
    end if

    if eventType = "PodStart"        
        m.mmSmart.reportAdState("AD_BREAK_STARTED")
    else if eventType = "PodComplete"
        m.mmSmart.reportAdState("AD_BREAK_ENDED")
    else if eventType = "Impression"
        'Not considering this impression as it is sending only once per ad break
    else if eventType = "Pause"
        _reportEvent("PAUSE")
    else if eventType = "Start"        
        adInfo = _fetchAndUpdateCSAIAdInfo(ctx, adURL)
        if adInfo <> invalid
            m.mmSmart.reportAdInfo(adInfo)
        end if
        m.mmSmart.reportAdState("AD_IMPRESSION")
        m.mmSmart.reportAdState("AD_PLAY")
    else if eventType = "Resume"
        _reportEvent("PLAYING")
    else if eventType = "Complete"
        m.mmSmart.reportAdState("AD_ENDED")        
    else if eventType = "FirstQuartile"
        m.mmSmart.reportAdState("AD_PLAYED_FIRST_QUARTILE")
    else if eventType = "Midpoint"
        m.mmSmart.reportAdState("AD_PLAYED_SECOND_QUARTILE")
    else if eventType = "ThirdQuartile"
        m.mmSmart.reportAdState("AD_PLAYED_THIRD_QUARTILE")
    else if eventType = "Skip"
        m.mmSmart.reportAdState("AD_SKIPPED")        
    else if eventType = "ContentPosition"
        if ctx.contentpos <> invalid
            m.mmSmart.reportAdPlaybackTime(ctx.contentpos)
        end if
    end if
end function
'************* CUSTOM FUNCTION FOR PROJECT W **************

'************** MMSDK Roku Plugin for CSAI ADs through RAF **************
function mmRafAdTracking(adDetails as object)
    if adDetails <> invalid
        if adDetails.type = "AdRequest"
            m.mmSmart.reportAdState("AD_REQUEST")
        else if adDetails.type = "PodStart"
            m.inAdBreak = true
            m.mmSmart.reportAdState("AD_BREAK_STARTED")
        else if adDetails.type = "Impression"
            m.inAdBreak = true
            adInfo = _fetchAndUpdateCSAIAdInfo(adDetails, "")
            if adInfo <> invalid 
                m.mmSmart.reportAdInfo(adInfo)
            end if
            m.mmSmart.reportAdState("AD_IMPRESSION")
            m.mmSmart.reportAdState("AD_PLAY")
        else if adDetails.type = "Start NA"  'Remove " NA" from this. Customisation for SSAI RAF
            m.inAdBreak = true
            adInfo = _fetchAndUpdateCSAIAdInfo(adDetails, "")
            if adInfo <> invalid
                m.mmSmart.reportAdInfo(adInfo)
            end if
            m.firstQuartileSent = false
            m.midQuartileSent = false
            m.thirdQuartileSent = false
            m.mmSmart.reportAdState("AD_PLAY")
        else if adDetails.type = "Complete"            
            adInfo = _fetchAndUpdateCSAIAdInfo(adDetails, "")
            if adInfo <> invalid
                m.mmSmart.reportAdInfo(adInfo)
            end if
            m.mmSmart.reportAdState("AD_ENDED")
            m.inAdBreak = false
        else if adDetails.type = "PodComplete"            
            m.mmSmart.reportAdState("AD_BREAK_ENDED")
            m.inAdBreak = false
        else if adDetails.type = "NoAdsError"
            ' m.mmSmart.reportAdError(adDetails.errmsg, -1)
        else if adDetails.type = "FirstQuartile"
            m.mmSmart.reportAdState("AD_PLAYED_FIRST_QUARTILE")            
        else if adDetails.type = "Midpoint"
            m.mmSmart.reportAdState("AD_PLAYED_SECOND_QUARTILE")            
        else if adDetails.type = "ThirdQuartile"
            m.mmSmart.reportAdState("AD_PLAYED_THIRD_QUARTILE")            
        else if adDetails.type = invalid
            if adDetails.time <> invalid
                m.mmSmart.reportAdPlaybackTime(adDetails.time)
            end if

            ' if adDetails.time <> invalid and adDetails.duration <> invalid
            '     if m.firstQuartileSent = false and adDetails.duration * 0.25# <= adDetails.time
            '         m.mmSmart.reportAdState("AD_PLAYED_FIRST_QUARTILE")
            '         m.firstQuartileSent = true
            '     else if m.midQuartileSent = false and adDetails.duration * 0.50# <= adDetails.time
            '         m.mmSmart.reportAdState("AD_PLAYED_MID_QUARTILE")
            '         m.midQuartileSent = true
            '     else if m.thirdQuartileSent = false and adDetails.duration * 0.75# <= adDetails.time
            '         m.mmSmart.reportAdState("AD_PLAYED_THIRD_QUARTILE")
            '         m.thirdQuartileSent = true
            '     end if
            ' end if
        end if
    end if
end function

function _fetchAndUpdateCSAIAdInfo(adDetails as object, adURL as string) as object
    adInfo = { "adClient": "SSAI", "adLinear": "linear" }

    if adURL <> invalid and adURL <> ""
        adInfo.AddReplace("adUrl", adURL)
    end if

    if adDetails <> invalid and adDetails.ad <> invalid
        if adDetails.ad.adid <> invalid
            adInfo.AddReplace("adId", adDetails.ad.adid)
        end if
        if adDetails.ad.creativeid <> invalid
            adInfo.AddReplace("adCreativeId", adDetails.ad.creativeid)
        end if
        if adDetails.ad.duration <> invalid
            adInfo.AddReplace("adDuration", adDetails.ad.duration)
        end if
        if adDetails.ad.adsystem <> invalid
            adInfo.AddReplace("adSystem", adDetails.ad.adsystem)
        end if
        if adDetails.ad.adtitle <> invalid
            adInfo.AddReplace("adTitle", adDetails.ad.adtitle)
        end if

        adPosition = "mid"
        if adDetails.rendersequence <> invalid
            if adDetails.rendersequence = "preroll"
                adPosition = "pre"
            else if adDetails.rendersequence = "midroll"
                adPosition = "mid"
            else
                adPosition = "post"
            end if
        end if
        adInfo.AddReplace("adPosition", adposition)

        if adDetails.slotcount <> invalid
            adInfo.AddReplace("adPodIndex", adDetails.slotcount)
        end if
        if adDetails.adindex <> invalid
            adInfo.AddReplace("adPodPosition", adDetails.adindex)
        end if
        if adDetails.adcount <> invalid
            adInfo.AddReplace("adPodLength", adDetails.adcount)
        end if
        
        ' adInfo.AddReplace("adResolution",adInfo.adResolution)
        ' adInfo.AddReplace("isBumper",adInfo.isBumper)        
        ' adInfo.AddReplace("adPodLength",adInfo.adPodLength)        
        ' adInfo.AddReplace("adUrl", adDetails.adserver)        
        ' adInfo.AddReplace("adBitrate",adInfo.adBitrate)        
    end if
    return adInfo
end function

'*************** MMSDK roku plugin for IMA ADs ***************
function _imaAdsEventHandler(adDetails as object)
    if adDetails <> invalid and adDetails.eventType <> invalid
        eventType = adDetails.eventType

        if eventType = "AD_PLAY" or eventType = "AD_IMPRESSION"
            m.inAdBreak = true
        end if 

        if eventType = "AD_BREAK_ENDED" or eventType = "AD_COMPLETE" or eventType = "AD_ERROR" or eventType = "AD_SKIPPED"
            m.inAdBreak = false
        end if 

        if eventType = "AD_BREAK_STARTED"
            m.mmSmart.reportAdState("AD_REQUEST")
            m.mmSmart.reportAdState("AD_BREAK_STARTED")
        else if eventType = "AD_PROGRESS"
            currentTime = Int(adDetails.ad.currentTime)
            if currentTime = invalid or currentTime < 0
                currentTime = 0
            end if
            m.mmSmart.reportAdPlaybackTime(currentTime)
        else if eventType = "AD_ERROR"
            if m._enableCustomErrorReporting <> true
                if adDetails.error <> invalid
                    m.mmSmart.reportAdError(adDetails.error, m._lastReportedPosition)
                end if
            end if
        else
            adData = _fetchAndUpdateIMAAdInfo(adDetails)
            if adData <> invalid
                m.mmSmart.reportAdInfo(adData)
            end if
            m.mmSmart.reportAdState(eventType)
        end if
    end if
end function

function _fetchAndUpdateIMAAdInfo(adDetails as object) as object
    if adDetails <> invalid and adDetails.ad <> invalid
        adInfo = adDetails.ad
        adData = { "adClient": "IMA", "adId": adInfo.adId, "adLinear": "Linear" }

        adData.AddReplace("adSystem", adInfo.adSystem)
        adData.AddReplace("adTitle", adInfo.adTitle)
        adData.AddReplace("adCreativeId", adInfo.creativeAdId)
        adData.AddReplace("adDuration", adInfo.duration)

        adPosition = "pre"
        if adInfo.adbreakinfo <> invalid and adInfo.adbreakinfo.podindex <> invalid
            if adInfo.adbreakinfo.podindex = 0
                adPosition = "pre"
            else if adInfo.adbreakinfo.podindex = -1
                adPosition = "post"
            else
                adPosition = "mid"
            end if
        end if
        adData.AddReplace("adPosition", adposition)

        if (adInfo.adbreakinfo <> invalid)
            if adPosition = "mid" and m.isLive = true
                adData.AddReplace("adPodIndex", -2)
            else    
                adData.AddReplace("adPodIndex", adInfo.adbreakinfo.podindex)
            end if
            adData.AddReplace("adPodPosition", adInfo.adbreakinfo.adPosition)
            adData.AddReplace("adPodLength",adInfo.adbreakinfo.totalAds)
        end if
        
        return adData
    end if
end function