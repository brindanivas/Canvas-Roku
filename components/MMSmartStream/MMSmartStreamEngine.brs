function MMStore() as object
    'Store object. Contains event queues, segment queues and storage variable with the data.
    'm.mainStore is the associative array which acts as the main point of storage
    store = {}
    store.init = function()
        m.mainStore = CreateObject("roAssociativeArray")
        m.mainStore.AddReplace("Component", "ROKUSDK")
        m.mainStore.AddReplace("Platform", "Brightscript")
        m.mainStore.AddReplace("SDKVERSION", "RokuSDK_RAF_v2.6.2")
        m.mainStore.AddReplace("hFileVersion", "3.0.0")
        m.mainStore.AddReplace("EP_SCHEMA", "3.0.0")
        m.mainStore.AddReplace("isRegistration", false)
        m.mainStore.AddReplace("lastKnownPos", 0)
        m.mainStore.AddReplace("customTags", false)
        m.mainStore.AddReplace("custom", {})
        m.mainStore.AddReplace("playDur", 0.0)
        m.mainStore.AddReplace("pauseDur", 0.0)
        m.mainStore.AddReplace("lastPauseDur", 0.0)
        m.mainStore.AddReplace("latency", 0.0)
        m.mainStore.AddReplace("totalProfiles", -1)
        m.mainStore.AddReplace("deltaTime", 0)
        m.mainStore.AddReplace("maxFps", 0)
        m.mainStore.AddReplace("minFps", 0)
        m.mainStore.AddReplace("maxRes", "")
        m.mainStore.AddReplace("minRes", "")
        m.mainStore.AddReplace("sumBuffWait", 0)
        m.mainStore.AddReplace("profileNum", -1)
        m.mainStore.AddReplace("prevChunkInfo", {})
        m.buffWait = []
        m.eventQueue = []
        m.segmentQueue = []
        m.bufferedQueue = [] 'This is to store the events when device is not coneected to internet
        m.segmentTimespan = createObject("roTimeSpan")
        m.dataRates = []
        m.rate = 0
        m.lastRate = 0
        m.upshift = 0
        m.downShift = 0
        m.prevTimestamp = 0
        m.onLoadTimestamp = 0
        m.payloadCount = 1

        m.adIntervalTimespan = createObject("roTimeSpan")

        m.adPauseTimespan = invalid
        m.adKonstantInterval = 5 ' set to 5 seconds
        m.isAdPlaying = false
        m.mainStore.AddReplace("adLatency", 0.0)
        m.mainStore.AddReplace("adInterval", 0.0)
        m.mainStore.AddReplace("adPauseDur", 0.0)
        m.mainStore.AddReplace("adPlayDur", 0.0)
        m.mainStore.AddReplace("adSumBuffWait", 0)
        m.mainStore.AddReplace("adPlaybackPos", 0)
        m.MMPlayerStates = {
            "START": { event: "START", desc: "Playback Start", id: "START" },
            "START_AFTER_AD": { event: "START_AFTER_AD", desc: "Playback Start after Ad", id: "START_AFTER_AD" },
            "ONLOAD": { event: "ONLOAD", desc: "Player Initializing", id: "ONLOAD" },
            "PAUSE": { event: "PAUSE", desc: "Playback Paused", id: "PAUSE" },
            "RESUME": { event: "RESUME", desc: "Playback resumed", id: "RESUME" },
            "SEEK_START": { event: "SEEK_START", desc: "Playback Seek Start", id: "SEEK_START" },
            "SEEK_COMPLETE": { event: "SEEK_COMPLETE", desc: "Playback Seek Complete", id: "SEEK_COMPLETE" },
            "COMPLETE": { event: "COMPLETE", desc: "Playback completion", id: "COMPLETE" },
            "BUFFERING_START": { event: "BUFFERING_START", desc: "Playback Buffering Started", id: "BUFFERING_START" },
            "BUFFERING_COMPLETE": { event: "BUFFERING_COMPLETE", desc: "Playback Buffering Completed", id: "BUFFERING_COMPLETE" },
            "ENDED": { event: "ENDED", desc: "Playback completion", id: "ENDED" }
        }
        m.MMAdStates = {
            "AD_BLOCK": { event: "AD_BLOCK", desc: "Ad blocked", id: "AD_BLOCK" },
            "AD_BUFFERING": { event: "AD_BUFFERING", desc: "Ad Buffering started", id: "AD_BUFFERING" },
            "AD_BREAK_STARTED": { event: "AD_BREAK_STARTED", desc: "Ad Break Started", id: "AD_BREAK_STARTED" },
            "AD_BREAK_ENDED": { event: "AD_BREAK_ENDED", desc: "Ad Break Ended", id: "AD_BREAK_ENDED" },
            "AD_IMPRESSION": { event: "AD_IMPRESSION", desc: "Ad impression has been made", id: "AD_IMPRESSION" },
            "AD_PLAY": { event: "AD_PLAY", desc: "Ad Playback started", id: "AD_PLAY" },
            "AD_CLICK": { event: "AD_CLICK", desc: "Ad has been clicked", id: "AD_CLICK" },
            "AD_PAUSED": { event: "AD_PAUSED", desc: "Ad has been paused", id: "AD_PAUSED" },
            "AD_RESUMED": { event: "AD_RESUMED", desc: "Ad has been resumed", id: "AD_RESUMED" },
            "AD_SKIPPED": { event: "AD_SKIPPED", desc: "Ad has been skipped", id: "AD_SKIPPED" },
            "AD_PLAYING": { event: "AD_PLAYING", desc: "AD KEEP ALIVE", id: "AD_PLAYING" },
            "AD_COMPLETE": { event: "AD_COMPLETE", desc: "Ad completed", id: "AD_COMPLETE" },
            "AD_REQUEST": { event: "AD_REQUEST", desc: "Ad has been requested", id: "AD_REQUEST" },
            "AD_PLAYED_FIRST_QUARTILE": { event: "AD_PLAYED_FIRST_QUARTILE", desc: "Ad reached first quartile", id: "AD_PLAYED_FIRST_QUARTILE" },
            "AD_PLAYED_MID_QUARTILE": { event: "AD_PLAYED_SECOND_QUARTILE", desc: "Ad reached midpoint", id: "AD_PLAYED_SECOND_QUARTILE" },
            "AD_PLAYED_THIRD_QUARTILE": { event: "AD_PLAYED_THIRD_QUARTILE", desc: "Ad reached third quartile", id: "AD_PLAYED_THIRD_QUARTILE" },
            "AD_ENDED": { event: "AD_ENDED", desc: "Ad ended", id: "AD_ENDED" }
        }

    end function

    'Unique ID generator for creating and returning unique session ID.
    store.generateSessionId = function () as String
        pattern = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
        randomiseX = function() as String
          return StrI(Rnd(0) * 16, 16)
        end function
        randomiseY = function() as String
          randomNumber = Rnd(0) * 16
          randomNumber = randomNumber + 3
          if randomNumber >= 16
            randomNumber = 8
          end if
          return StrI(randomNumber, 16)
        end function
        patternArray = pattern.split("")
        sessionId = ""
        for each char in patternArray
          if char = "x"
            sessionId = sessionId + randomiseX()
          else if char = "y"
            sessionId = sessionId + randomiseY()
          else
            sessionId = sessionId + char
          end if
        end for

        timestamp = _getDateTime()
        timestamp = 0# + timestamp.AsSeconds() * 1000.0# + timestamp.GetMilliseconds()
        sessionId = sessionId + "-" +_convertDoubleToString(timestamp)

        return sessionId
    end function

    ' Next 3 functions- Event Queue Functions for pushing, clearing and returning the queue
    store.ReportLatency = function(time)
        if time < 0
            time = 0
        end if
        m.mainStore.addReplace("latency", time)        
    end function

    store.ReportAdLatency = function(time)
        if time < 0
            time = 0
        end if
        m.mainStore.addReplace("adLatency", time)
    end function

    store.pushToEventQueue = function(event)
        m.eventQueue.push(event)
    end function

    store.clearEventQueue = function()
        m.eventQueue = []
    end function

    store.getEventQueue = function() as object
        return m.eventQueue
    end function

    store.pushToBufferedQueue = function(event)
        m.bufferedQueue.push(event)
    end function

    store.shiftBufferedQueue = function()
        m.bufferedQueue.Shift()
    end function

    store.clearBufferedQueue = function()
        m.bufferedQueue = []
    end function

    store.getBufferedQueue = function() as object
        return m.bufferedQueue
    end function

    ' Next 3 functions- Segment Queue Functions for pushing, clearing and returning the queue

    store.getSegmentQueue = function() as object
        if m.segmentQueue.Count() > 0
            return m.segmentQueue
        else
            return -1
        end if
    end function


    store.clearSegmentQueue = function()
        m.segmentQueue = []
    end function

    store.pushToSegmentQueue = function(data as object)
        m.segmentQueue.push(data)
    end function

    store.getContentMeta = function() as object
        contentMetadata = {}
        if m.mainStore.assetID <> invalid
            contentMetadata.AddReplace("assetId", m.mainStore.assetID)
        end if
        if m.mainStore.assetName <> invalid
            contentMetadata.AddReplace("assetName", m.mainStore.assetName)
        end if
        if m.mainStore.videoID <> invalid
            contentMetadata.AddReplace("videoId", m.mainStore.videoID)
        end if
        if m.mainStore.contentType <> invalid
            contentMetadata.AddReplace("contentType", m.mainStore.contentType)
        end if
        if m.mainStore.drmProtection <> invalid
            contentMetadata.AddReplace("drmProtection", m.mainStore.drmProtection)
        end if
        if m.mainStore.episodeNumber <> invalid
            contentMetadata.AddReplace("episodeNumber", m.mainStore.episodeNumber)
        end if
        if m.mainStore.genre <> invalid
            contentMetadata.AddReplace("genre", m.mainStore.genre)
        end if
        if m.mainStore.season <> invalid
            contentMetadata.AddReplace("season", m.mainStore.season)
        end if
        if m.mainStore.seriesTitle <> invalid
            contentMetadata.AddReplace("seriesTitle", m.mainStore.seriesTitle)
        end if
        return contentMetadata
    end function

    ' Next 2 functions- Stats creation function. Event stats on playback event, segmentStats on beacon timer firing.

    store.createEventStats = function(state as string) as object
        sdkInfo = { "hFileVersion": m.mainStore.hFileVersion, "sdkVersion": m.mainStore.SDKVERSION }        
        if m.mainStore.statsInterval <> invalid
            interval = m.mainStore.statsInterval
        else
            interval = 30
        end if

        scrnRes = m.mainStore.screenheight.toStr() + "x" + m.mainStore.screenwidth.toStr()
        stats = { "version": m.mainStore.hFileVersion, "interval": interval, "pbTime": m.mainStore.lastKnownPos, "playDur": m.mainStore.playDur }
        streamID = { "assetId": m.mainStore.assetID, "assetName": m.mainStore.assetName, "custId": m.mainStore.customerId, "dataSrc": m.mainStore.dataSrc, "mode": m.mainStore.mode }
        streamID.addReplace("playerName", m.mainStore.playerName)
        streamID.addReplace("playerVersion", m.mainStore.playerVersion)
        streamID.addReplace("basePlayerName", m.mainStore.basePlayerName)
        streamID.addReplace("basePlayerVersion", m.mainStore.basePlayerVersion)        
        streamID.addReplace("sessionId", m.mainStore.sessionId)
        streamID.AddReplace("streamURL", m.mainStore.manifestURL)
        streamID.AddReplace("subscriberId", m.mainStore.subscriberId)
        streamID.AddReplace("subscriberType", m.mainStore.subscriberType)
        streamID.AddReplace("subscriberTag", m.mainStore.subscriberTag)

        if m.mainStore.viewSessionId <> invalid or m.mainstore.viewSessionId <> ""
            streamID.AddReplace("viewSessionId", m.mainStore.viewSessionId)
        end if
        if m.mainStore.experimentName <> invalid or m.mainstore.experimentName <> ""
            streamID.AddReplace("experimentName", m.mainStore.experimentName)
        end if
        if m.mainStore.subPropertyId <> invalid or m.mainstore.subPropertyId <> ""
            streamID.AddReplace("subPropertyId", m.mainStore.subPropertyId)
        end if
        if m.mainStore.mediaType <> invalid or m.mainstore.mediaType <> ""
            streamID.AddReplace("mediaType", m.mainStore.mediaType)
        end if
        if m.mainStore.videoID <> invalid or m.mainstore.videoID <> ""
            streamID.AddReplace("videoId", m.mainStore.videoID)
        end if
        if m.mainStore.domainName <> invalid or m.mainstore.domainName <> ""
            streamID.addreplace("domainName", m.mainStore.domainName)
        end if
        if m.mainStore.isLive <> invalid
            streamID.addReplace("isLive", m.mainStore.isLive)
        end if
        if m.mainStore.streamSourceType <> invalid or m.mainstore.streamSourceType <> ""
            streamID.addReplace("sourceType", m.mainStore.streamSourceType)
        end if

        contentMetadata = m.getContentMeta()
        clientInfo = { "device": "Roku", "scrnRes": scrnRes, "playerRes": scrnRes, "model": m.mainStore.deviceModel, "platform": m.mainStore.deviceOS, "brand": m.mainStore.brand, "version": m.mainStore.deviceOSVersion, "deviceId": m.mainStore.deviceId }

        if m.mainStore.appName <> invalid or m.mainstore.appName <> ""
            clientInfo.AddReplace("appName", m.mainStore.appName)
        end if

        if m.mainStore.appSdkNumber <> invalid or m.mainstore.appSdkNumber <> ""
            clientInfo.AddReplace("appVersion", m.mainStore.appSdkNumber)
        end if

        if m.mainStore.cdn <> invalid or m.mainstore.cdn <> ""
            clientInfo.AddReplace("cdn", m.mainStore.cdn)
        end if

        timestamp = _getDateTime()
        timestamp = 0# + timestamp.AsSeconds() * 1000.0# + timestamp.GetMilliseconds() + m.mainStore.deltaTime
        stats.AddReplace("timestamp", timestamp)
        pbInfo = []
        pbInfo.Push({ "timestamp": timestamp })
        if state <> invalid
            if state = "BUFFERING_START"
                pbEventInfo = m.MMPlayerStates["BUFFERING_START"]
            else if state = "BUFFERING_COMPLETE"
                pbEventInfo = m.MMPlayerStates["BUFFERING_COMPLETE"]
            else if state = "COMPLETE" or state = "ENDED"
                pbEventInfo = m.MMPlayerStates[state]
                pbInfo[pbInfo.count() - 1].AddReplace("sumBuffWait", m.mainStore.sumBuffWait)
                if m.mainStore.lastPauseDur > 0
                    pbInfo[pbInfo.count() - 1].AddReplace("pauseDuration", m.mainStore.lastPauseDur)
                end if
            else if state = "ONLOAD"
                m.onLoadTimestamp = timestamp
                pbEventInfo = m.MMPlayerStates["ONLOAD"]                
            else if state = "PAUSE"
                pbEventInfo = m.MMPlayerStates["PAUSE"]
            else if state = "RESUME"
                pbEventInfo = m.MMPlayerStates["RESUME"]
                m.segmentTimespan.mark()
                pbInfo[pbInfo.count() - 1].addReplace("pauseDuration", m.mainStore.lastPauseDur)
                m.mainStore.lastPauseDur = 0.0
            else if state = "SEEK_START"
                pbEventInfo = m.MMPlayerStates["SEEK_START"]
            else if state = "SEEK_COMPLETE"
                pbEventInfo = m.MMPlayerStates["SEEK_COMPLETE"]
            else if state = "START"
                m.segmentTimespan.mark()
                pbEventInfo = m.MMPlayerStates["START"]                                
                pbInfo[pbInfo.count() - 1].addReplace("latency", m.mainStore.latency)
            else if state = "START_AFTER_AD"
                m.segmentTimespan.mark()
                pbEventInfo = m.MMPlayerStates["START_AFTER_AD"]                
                pbInfo[pbInfo.count() - 1].addReplace("latency", m.mainStore.latency)
            else if state = "ERROR"
                if m.mainStore.errorString = invalid
                    m.mainStore.errorString = "Unknown Error"
                end if
                pbEventInfo = { "event": "ERROR", "id": "ERROR", "desc": m.mainStore.errorString }
                m.mainStore.errorString = invalid
            else if state = "RENDITION_CHANGE"                
                pbEventInfo = {"event": "RENDITION_CHANGE", "id": "RENDITION_CHANGE", "desc":  m.mainStore.renditionDesc}
            else if (Left(state, 3) = "RF_") or (Left(state, 3) = "RC_")
                pbEventInfo = {"event": state, "id": state, "desc":  m.mainStore.requestStatusDesc}
            else    
                pbEventInfo = { "event": "RETURN" }
            end if
        end if

        if m.onLoadTimestamp <> invalid or m.onLoadTimestamp <> 0
            streamID.addReplace("sst", m.onLoadTimestamp)
        else 
            streamID.addReplace("sst", timestamp)
        end if

        pbEventInfo.AddReplace("pbTime", m.mainStore.lastKnownPos)
        streamInfo = {}
        if m.mainStore.bwInUse <> invalid and (state <> "START" or state <> "ONLOAD")
            pbInfo[pbInfo.count() - 1].addReplace("bwInUse", m.mainStore.bwInUse)
        end if
        if m.mainStore.totalDuration <> 0 and m.mainStore.totalDuration <> invalid
            streamInfo.addReplace("totalDuration", m.mainStore.totalDuration)
        end if
        if state <> "ONLOAD"
            streamInfo.addReplace("numOfProfile", m.mainStore.totalProfiles)
            streamInfo.addReplace("maxFps", m.mainStore.maxFps)
            streamInfo.addReplace("minFps", m.mainStore.minFps)
            streamInfo.addReplace("minRes", m.mainStore.minRes)
            streamInfo.addReplace("maxRes", m.mainStore.maxRes)
        end if
        if m.mainStore.streamFormat <> invalid or m.mainstore.streamFormat <> ""
            streamInfo.addReplace("streamFormat", m.mainStore.streamFormat)
        end if

        qubitData = [{ "streamID": streamID, "sdkInfo": sdkInfo, "clientInfo": clientInfo, "contentMetadata": contentMetadata, "pbEventInfo": pbEventInfo, "pbInfo": pbInfo, "streamInfo": streamInfo }]
        if m.mainStore.customTags = True
            custom = m.mainStore.custom
            qubitData[0].addReplace("customTags", custom)
        end if

        if m.mainStore.customerId <> invalid and m.mainStore.sessionId <> invalid and timestamp <> invalid
            pidString = m.mainStore.customerId + m.mainStore.sessionId + _convertDoubleToString(timestamp) + Str(m.payloadCount)
        else
            pidString = "Error in PID generation"
            ? "Error in PID generation"
        end if
        pid = _generatePID(pidString)
        m.payloadCount = m.payloadCount + 1
        qubitData[0].streamID.addReplace("pId", pid)
        stats.AddReplace("qubitData", qubitData)

        if pbEventInfo.event <> "RETURN"
            ?""
            ?""
            ?"************* MM EVENT *************   =  " pbEventInfo.event
            ?""
            ?""
        end if
        return stats
    end function

    store.createSegmentStats = function() as object
        sdkInfo = { "hFileVersion": m.mainStore.hFileVersion, "sdkVersion": m.mainStore.SDKVERSION }
        interval = (m.segmentTimespan.TotalMilliseconds()/1000.0)

        if interval <= 0
            return invalid
        end if

        m.segmentTimespan.mark()
        scrnRes = m.mainStore.screenheight.toStr() + "x" + m.mainStore.screenwidth.toStr()
        stats = { "version": m.mainStore.hFileVersion, "interval": interval, "pbTime": m.mainStore.lastKnownPos, "playDur": m.mainStore.playDur }
        streamID = { "assetId": m.mainStore.assetID, "assetName": m.mainStore.assetName, "custId": m.mainStore.customerId, "dataSrc": m.mainStore.dataSrc, "mode": m.mainStore.mode }
        streamID.addReplace("playerName", m.mainStore.playerName)
        streamID.addReplace("playerVersion", m.mainStore.playerVersion)
        streamID.addReplace("basePlayerName", m.mainStore.basePlayerName)
        streamID.addReplace("basePlayerVersion", m.mainStore.basePlayerVersion)
        streamID.addReplace("sessionId", m.mainStore.sessionId)
        streamID.AddReplace("streamURL", m.mainStore.manifestURL)
        streamID.AddReplace("subscriberId", m.mainStore.subscriberId)
        streamID.AddReplace("subscriberType", m.mainStore.subscriberType)
        streamID.AddReplace("subscriberTag", m.mainStore.subscriberTag)

        if m.mainStore.viewSessionId <> invalid or m.mainstore.viewSessionId <> ""
            streamID.AddReplace("viewSessionId", m.mainStore.viewSessionId)
        end if
        if m.mainStore.experimentName <> invalid or m.mainstore.experimentName <> ""
            streamID.AddReplace("experimentName", m.mainStore.experimentName)
        end if
        if m.mainStore.subPropertyId <> invalid or m.mainstore.subPropertyId <> ""
            streamID.AddReplace("subPropertyId", m.mainStore.subPropertyId)
        end if
        if m.mainStore.mediaType <> invalid or m.mainstore.mediaType <> ""
            streamID.AddReplace("mediaType", m.mainStore.mediaType)
        end if
        if m.mainStore.videoID <> invalid or m.mainstore.videoID <> ""
            streamID.AddReplace("videoId", m.mainStore.videoID)
        end if
        if m.mainStore.domainName <> invalid or m.mainstore.domainName <> ""
            streamID.addreplace("domainName", m.mainStore.domainName)
        end if
        if m.mainStore.isLive <> invalid
            streamID.addReplace("isLive", m.mainStore.isLive)
        end if
        if m.mainStore.streamSourceType <> invalid or m.mainstore.streamSourceType <> ""
            streamID.addReplace("sourceType", m.mainStore.streamSourceType)
        end if        

        contentMetadata = m.getContentMeta()

        clientInfo = { "device": "Roku", "scrnRes": scrnRes, "playerRes": scrnRes,
            "model": m.mainStore.deviceModel, "platform": m.mainStore.deviceOS,
        "brand": m.mainStore.brand, "version": m.mainStore.deviceOSVersion, "deviceId": m.mainStore.deviceId }

        if m.mainStore.appName <> invalid or m.mainstore.appName <> ""
            clientInfo.AddReplace("appName", m.mainStore.appName)
        end if

        if m.mainStore.appSdkNumber <> invalid or m.mainstore.appSdkNumber <> ""
            clientInfo.AddReplace("appVersion", m.mainStore.appSdkNumber)
        end if

        if m.mainStore.cdn <> invalid or m.mainstore.cdn <> ""
            clientInfo.AddReplace("cdn", m.mainStore.cdn)
        end if

        timestamp = _getDateTime()
        timestamp = 0# + timestamp.AsSeconds() * 1000.0# + timestamp.GetMilliseconds() + m.mainStore.deltaTime
        pbInfo = []
        if m.upshift <> 0
            info = { "timestamp": timestamp, "upShiftCount": m.upshift }
            if m.mainStore.bwInUse <> invalid
                info.addReplace("bwInUse", m.mainStore.bwInUse)
            end if
            pbInfo.Push(info)            
        end if
        if m.downshift <> 0
            info = { "timestamp": timestamp, "downShiftCount": m.downshift }
            if m.mainStore.bwInUse <> invalid
                info.addReplace("bwInUse", m.mainStore.bwInUse)
            end if
            pbInfo.Push(info)            
        end if
        if m.mainStore.bwInUse <> invalid
            info = { "timestamp": timestamp, "pbTime": m.mainStore.lastKnownPos, "bwInUse": m.mainStore.bwInUse }
            pbInfo.Push(info)
        end if
        if m.mainStore.totalDuration <> 0 and m.mainStore.totalDuration <> invalid
            progressMark = (m.mainStore.lastKnownPos/m.mainStore.totalDuration) * 100
            info = { "timestamp": timestamp, "progressMark": progressMark}
            pbInfo.Push(info)
        else 
            info = { "timestamp": timestamp, "progressMark": 100}
            pbInfo.Push(info)
        end if

        if m.onLoadTimestamp <> invalid or m.onLoadTimestamp <> 0
            streamID.addReplace("sst", m.onLoadTimestamp)
        else 
            streamID.addReplace("sst", timestamp)
        end if

        segInfo = m.segmentQueue
        streamInfo = {}
        if m.mainStore.totalDuration <> 0 and m.mainStore.totalDuration <> invalid
            streamInfo.addReplace("totalDuration", m.mainStore.totalDuration)
        end if
        if m.mainStore.streamFormat <> invalid and m.mainStore.streamFormat <> ""
            streamInfo.addReplace("streamFormat", m.mainStore.streamFormat)
        end if
        streamInfo.addReplace("numOfProfile", m.mainStore.totalProfiles)
        streamInfo.addReplace("maxFps", m.mainStore.maxFps)
        streamInfo.addReplace("minFps", m.mainStore.minFps)
        streamInfo.addReplace("minRes", m.mainStore.minRes)
        streamInfo.addReplace("maxRes", m.mainStore.maxRes)

        if m.buffWait.count() <> 0
            pbInfo.append(m.buffWait)
            m.buffWait = []
        end if
        qubitData = [{ "streamID": streamID, "sdkInfo": sdkInfo, "clientInfo": clientInfo, "contentMetadata": contentMetadata, "segInfo": segInfo, "pbInfo": pbInfo, "streamInfo": streamInfo }]
        if m.mainStore.customTags = True
            custom = m.mainStore.custom
            qubitData[0].addReplace("customTags", custom)
        end if
        if m.mainStore.customerId <> invalid and m.mainStore.sessionId <> invalid and timestamp <> invalid
            pidString = m.mainStore.customerId + m.mainStore.sessionId + _convertDoubleToString(timestamp) + Str(m.payloadCount)
        else
            pidString = "Error in PID generation"
            ? "Error in PID generation"
        end if
        pid = _generatePid(pidString)
        m.payloadCount = m.payloadCount + 1
        qubitData[0].streamID.addReplace("pId", pid)
        stats.AddReplace("qubitData", qubitData)
        stats.AddReplace("timestamp", timestamp)
        return stats
    end function

    ' function to create update Ad Events ----------------------------------------------------------------------------------------------------
    store.createAdEventStats = function(state as string) as object
        sdkInfo = { "hFileVersion": m.mainStore.hFileVersion, "sdkVersion": m.mainStore.SDKVERSION }
        ?""
        ?""
        ?"************* MM AD EVENT *************   =  " state
        ?""
        ?""
        if m.mainStore.statsInterval <> invalid
            interval = m.mainStore.statsInterval
        else
            interval = 30
        end if
        scrnRes = m.mainStore.screenheight.toStr() + "x" + m.mainStore.screenwidth.toStr()
        stats = { "version": m.mainStore.hFileVersion, "interval": interval, "pbTime": m.adPlaybackPos, "playDur": m.mainStore.adPlayDur }
        streamID = { "assetId": m.mainStore.assetID, "assetName": m.mainStore.assetName, "custId": m.mainStore.customerId, "dataSrc": m.mainStore.dataSrc, "mode": m.mainStore.mode }
        streamID.addReplace("playerName", m.mainStore.playerName)
        streamID.addReplace("playerVersion", m.mainStore.playerVersion)
        streamID.addReplace("basePlayerName", m.mainStore.basePlayerName)
        streamID.addReplace("basePlayerVersion", m.mainStore.basePlayerVersion)
        streamID.addReplace("sessionId", m.mainStore.sessionId)
        streamID.AddReplace("streamURL", m.mainStore.manifestURL)
        streamID.AddReplace("subscriberId", m.mainStore.subscriberId)
        streamID.AddReplace("subscriberType", m.mainStore.subscriberType)
        streamID.AddReplace("subscriberTag", m.mainStore.subscriberTag)

        if m.mainStore.viewSessionId <> invalid or m.mainstore.viewSessionId <> ""
            streamID.AddReplace("viewSessionId", m.mainStore.viewSessionId)
        end if
        if m.mainStore.experimentName <> invalid or m.mainstore.experimentName <> ""
            streamID.AddReplace("experimentName", m.mainStore.experimentName)
        end if
        if m.mainStore.subPropertyId <> invalid or m.mainstore.subPropertyId <> ""
            streamID.AddReplace("subPropertyId", m.mainStore.subPropertyId)
        end if
        if m.mainStore.mediaType <> invalid or m.mainstore.mediaType <> ""
            streamID.AddReplace("mediaType", m.mainStore.mediaType)
        end if
        if m.mainStore.videoID <> invalid or m.mainstore.videoID <> ""
            streamID.AddReplace("videoId", m.mainStore.videoID)
        end if
        if m.mainStore.domainName <> invalid or m.mainstore.domainName <> ""
            streamID.addreplace("domainName", m.mainStore.domainName)
        end if
        if m.mainStore.isLive <> invalid
            streamID.addReplace("isLive", m.mainStore.isLive)
        end if
        if m.mainStore.isLive <> invalid
            streamID.addReplace("isLive", m.mainStore.isLive)
        end if
        if m.mainStore.streamSourceType <> invalid or m.mainstore.streamSourceType <> ""
            streamID.addReplace("sourceType", m.mainStore.streamSourceType)
        end if

        contentMetadata = m.getContentMeta()

        clientInfo = { "device": "Roku", "scrnRes": scrnRes, "playerRes": scrnRes, "model": m.mainStore.deviceModel, "platform": m.mainStore.deviceOS, "brand": m.mainStore.brand, "version": m.mainStore.deviceOSVersion, "deviceId": m.mainStore.deviceId }

        if m.mainStore.appName <> invalid or m.mainstore.appName <> ""
            clientInfo.AddReplace("appName", m.mainStore.appName)
        end if

        if m.mainStore.appSdkNumber <> invalid or m.mainstore.appSdkNumber <> ""
            clientInfo.AddReplace("appVersion", m.mainStore.appSdkNumber)
        end if

        if m.mainStore.cdn <> invalid or m.mainstore.cdn <> ""
            clientInfo.AddReplace("cdn", m.mainStore.cdn)
        end if

        timestamp = _getDateTime()
        timestamp = 0# + timestamp.AsSeconds() * 1000.0# + timestamp.GetMilliseconds() + m.mainStore.deltaTime
        stats.AddReplace("timestamp", timestamp)
        pbInfo = []
        pbInfo.Push({ "timestamp": timestamp })
        if m.adIntervalTimespan <> invalid
            m.mainStore.AddReplace("adInterval", m.adIntervalTimespan.TotalMilliseconds())
        end if
        if state <> invalid
            if state = "AD_REQUEST"
                pbEventInfo = m.MMAdStates["AD_REQUEST"]
                m.mainStore.AddReplace("adInterval", 0.0)
                m.resetAdInfo()                
            else if state = "AD_BREAK_STARTED"
                pbEventInfo = m.MMAdStates["AD_BREAK_STARTED"]
                m.mainStore.AddReplace("adInterval", 0.0)
                m.resetAdInfo()
            else if state = "AD_IMPRESSION"
                pbEventInfo = m.MMAdStates["AD_IMPRESSION"]
                m.mainStore.AddReplace("adInterval", 0.0)
            else if state = "AD_PLAY"
                pbEventInfo = m.MMAdStates["AD_PLAY"]
                m.mainStore.AddReplace("adInterval", 0.0)
                pbInfo[pbInfo.count() - 1].AddReplace("latency", m.mainStore.adLatency)
            else if state = "AD_PLAYING"
                pbEventInfo = m.MMAdStates["AD_PLAYING"]
            else if state = "AD_PLAYED_FIRST_QUARTILE"
                pbEventInfo = m.MMAdStates["AD_PLAYED_FIRST_QUARTILE"]
            else if state = "AD_PLAYED_MID_QUARTILE"
                pbEventInfo = m.MMAdStates["AD_PLAYED_MID_QUARTILE"]
            else if state = "AD_PLAYED_THIRD_QUARTILE"
                pbEventInfo = m.MMAdStates["AD_PLAYED_THIRD_QUARTILE"]
            else if state = "AD_BUFFERING"
                pbEventInfo = m.MMAdStates["AD_BUFFERING"]
            else if state = "AD_COMPLETE"
                pbEventInfo = m.MMAdStates["AD_COMPLETE"]
                pbInfo[pbInfo.count() - 1].AddReplace("sumBuffWait", m.mainStore.adSumBuffWait)
            else if state = "AD_ENDED"
                pbEventInfo = m.MMAdStates["AD_ENDED"]
                pbInfo[pbInfo.count() - 1].AddReplace("sumBuffWait", m.mainStore.adSumBuffWait)            
            else if state = "AD_PAUSED"
                pbEventInfo = m.MMAdStates["AD_PAUSED"]
            else if state = "AD_RESUMED"
                pbEventInfo = m.MMAdStates["AD_RESUMED"]
                m.mainStore.AddReplace("adInterval", 0.0)
                m.segmentTimespan.mark()
                pbInfo[pbInfo.count() - 1].addReplace("pauseDuration", m.mainStore.lastAdPauseDur)
            else if state = "AD_SKIPPED"
                pbEventInfo = m.MMAdStates["AD_SKIPPED"]
                pbInfo[pbInfo.count() - 1].AddReplace("sumBuffWait", m.mainStore.adSumBuffWait)
            else if state = "AD_CLICK"
                pbEventInfo = m.MMAdStates["AD_CLICK"]
            else if state = "AD_BLOCK"
                pbEventInfo = m.MMAdStates["AD_BLOCK"]                        
            else if state = "AD_ERROR"
                if m.mainStore.errorString = invalid
                    m.mainStore.errorString = "UnKnown Error"
                end if
                pbEventInfo = { "event": "AD_ERROR", "id": "AD_ERROR", "desc": m.mainStore.errorString }
                m.mainStore.errorString = invalid     
            else if state = "AD_BREAK_ENDED"
                pbEventInfo = m.MMAdStates["AD_BREAK_ENDED"]
                m.mainStore.AddReplace("adInterval", 0.0)
                m.resetAdInfo()
            else
                pbEventInfo = { "event": "RETURN" }
            end if
        end if

        if m.onLoadTimestamp <> invalid or m.onLoadTimestamp <> 0
            streamID.addReplace("sst", m.onLoadTimestamp)
        else 
            streamID.addReplace("sst", timestamp)
        end if

        adInfo = {}
        if m.mainStore.adClient <> invalid
            adInfo.AddReplace("adClient", m.mainStore.adClient)
        end if
        if m.mainStore.adId <> invalid
            adInfo.AddReplace("adId", m.mainStore.adId)
        end if
        if m.mainStore.adDuration <> invalid
            adInfo.AddReplace("adDuration", m.mainStore.adDuration)
        end if
        if m.mainStore.adCreativeId <> invalid
            adInfo.AddReplace("adCreativeId", m.mainStore.adCreativeId)
        end if
        if m.mainStore.adPosition <> invalid
            adInfo.AddReplace("adPosition", m.mainStore.adPosition)
        end if
        if m.mainStore.adPodIndex <> invalid
            adInfo.AddReplace("adPodIndex", m.mainStore.adPodIndex)
        end if
        if m.mainStore.adPodLength <> invalid
            adInfo.AddReplace("adPodLength", m.mainStore.adPodLength)
        end if
        if m.mainStore.adPodPosition <> invalid
            adInfo.AddReplace("adPodPosition", m.mainStore.adPodPosition)
        end if
        if m.mainStore.adLinear <> invalid
            adInfo.AddReplace("adLinear", m.mainStore.adLinear)
        end if
        if m.mainStore.adCreativeType <> invalid
            adInfo.AddReplace("adCreativeType", m.mainStore.adCreativeType)
        end if
        if m.mainStore.adSystem <> invalid
            adInfo.AddReplace("adSystem", m.mainStore.adSystem)
        end if
        if m.mainStore.adUrl <> invalid
            adInfo.AddReplace("adUrl", m.mainStore.adUrl)
        end if
        if m.mainStore.adTitle <> invalid
            adInfo.AddReplace("adTitle", m.mainStore.adTitle)
        end if
        if m.mainStore.adBitrate <> invalid
            adInfo.AddReplace("adBitrate", m.mainStore.adBitrate)
        end if
        if m.mainStore.isBumper <> invalid
            adInfo.AddReplace("isBumper", m.mainStore.isBumper)
        end if
        if m.mainStore.adInterval <> invalid
            adInfo.AddReplace("adInterval", m.mainStore.adInterval/1000.0)
        end if

        if m.adPlaybackPos = invalid
            ' pbEventInfo.AddReplace("pbTime",m.mainStore.adPlaybackPos)
            m.adPlaybackPos = 0
        end if
        
        pbEventInfo.AddReplace("pbTime", m.adPlaybackPos)
        streamInfo = {}

        if m.mainStore.totalDuration <> 0 and m.mainStore.totalDuration <> invalid
            streamInfo.addReplace("totalDuration", m.mainStore.totalDuration)
        end if
        if state <> "ONLOAD"
            streamInfo.addReplace("numOfProfile", m.mainStore.totalProfiles)
            streamInfo.addReplace("maxFps", m.mainStore.maxFps)
            streamInfo.addReplace("minFps", m.mainStore.minFps)
            streamInfo.addReplace("minRes", m.mainStore.minRes)
            streamInfo.addReplace("maxRes", m.mainStore.maxRes)
        end if
        if m.mainStore.streamFormat <> invalid and m.mainStore.streamFormat <> ""
            streamInfo.addReplace("streamFormat", m.mainStore.streamFormat)
        end if        
        qubitData = [{ "adInfo": adInfo, "streamID": streamID, "sdkInfo": sdkInfo, "clientInfo": clientInfo, "contentMetadata": contentMetadata, "pbEventInfo": pbEventInfo, "pbInfo": pbInfo, "streamInfo": streamInfo }]
        if m.mainStore.customTags = True
            custom = m.mainStore.custom
            qubitData[0].addReplace("customTags", custom)
        end if
        if m.mainStore.customerId <> invalid and m.mainStore.sessionId <> invalid and timestamp <> invalid
            pidString = m.mainStore.customerId + m.mainStore.sessionId + _convertDoubleToString(timestamp) + Str(m.payloadCount)
        else
            pidString = "Error in PID generation"
            ? "Error in PID generation"
        end if
        pid = _generatePID(pidString)
        m.payloadCount = m.payloadCount + 1
        qubitData[0].streamID.addReplace("pId", pid)
        stats.AddReplace("qubitData", qubitData)

        m.adIntervalTimespan.mark()

        return stats
    end function

    store.resetAdInfo = function()
        m.mainStore.AddReplace("adClient", invalid)
        m.mainStore.AddReplace("adId", invalid)
        m.mainStore.AddReplace("adCreativeId", invalid)
        m.mainStore.AddReplace("adDuration", invalid)
        m.mainStore.AddReplace("adPosition", "pre")
        m.mainStore.AddReplace("adLinear", invalid)
        m.mainStore.AddReplace("adCreativeType", invalid)
        m.mainStore.AddReplace("adSystem", invalid)
        m.mainStore.AddReplace("adResolution", invalid)
        m.mainStore.AddReplace("isBumper", false)
        m.mainStore.AddReplace("adPodIndex", invalid)
        m.mainStore.AddReplace("adPodLength", invalid)
        m.mainStore.AddReplace("adPodPosition", invalid)
        m.mainStore.AddReplace("adUrl", invalid)
        m.mainStore.AddReplace("adTitle", invalid)
        m.mainStore.AddReplace("adBitrate", invalid)
    end function
    ' Next 4 functions- Main storage object getters and setters

    store.getStore = function() as object
        return m.mainStore
    end function

    store.updateStore = function(mainStore as object)
        m.mainStore = mainStore
    end function

    store.addToStore = function(key as string, value)
        m.mainStore.AddReplace(key, value)
    end function

    store.getFromStore = function(key as string)
        if m.mainStore[key] <> invalid
            response = m.mainStore[key]
        else
            response = invalid
        end if
        return response
    end function

    ' Next 2 functions- Registration Status getters and setters
    store.setRegistrationStatus = function(isEnable as boolean)
        m.mainStore["isRegistered"] = isEnable
    end function

    store.getRegistrationStatus = function() as boolean
        if m.mainStore["isRegistered"] <> invalid
            register = m.mainStore["isRegistered"]
        else
            register = False
        end if
        return register
    end function

    ' Next 2 functions- Producer URL getter and setter
    store.getProducerURL = function() as string
        if m.mainStore["producerURL"] <> invalid
            _prod = m.mainStore["producerURL"]
        else
            _prod = invalid
        end if
        '?_prod
        return _prod
    end function

    store.setProducerURL = function(_prod as string)
        m.mainStore.AddReplace("producerURL", _prod)
    end function

    store.getSecondaryProducerList = function() as object
        return m.mainStore["secondaryProducerList"]
    end function

    store.setSecondaryProducerList = function(_secProdList as object)
        if Type(_secProdList) = "roArray"
            m.mainStore.AddReplace("secondaryProducerList", _secProdList)
        end if        
    end function

    ' Next 2 functions- Beacon interval getter and setter
    store.getInterval = function() as integer
        if m.mainStore["statsInterval"] <> invalid
            _stats = m.mainStore["statsInterval"]
        else
            _stats = 30
        end if
        return _stats
    end function

    store.setInterval = function(_stats as integer)
        m.mainStore.AddReplace("statsInterval", _stats)
    end function

    store.sendCoordinates = function(latitude as string, longitude as string)
        m.mainStore.AddReplace("latitude", latitude)
        m.mainStore.AddReplace("longitude", longitude)
    end function

    ' Next 2 functions- Player State getter and setter
    store.setplayerState = function(_state as integer)
        if m.mainStore.presentState <> _state and m.mainStore.presentState <> invalid
            m.mainStore.AddReplace("previousState", m.mainStore.presentState)
            m.mainStore.AddReplace("presentState", _state)
        end if
    end function

    store.getPlayerState = function() as string
        if m.mainStore["presentState"] <> invalid
            _state = m.mainStore["presentState"]
        else
            _state = invalid
        end if
        return _state
    end function

    store.setSSID = function(ssid as string)
        m.mainStore.AddReplace("ssid", ssid)
    end function

    store.setWifiSignalStrength = function(strength as string)
        m.mainStore.AddReplace("wifiStrength", strength)
    end function

    store.setSubscriberID = function(ID as string)
        m.mainStore["subscriberId"] = ID
    end function

    store.getsubscriberID = function() as boolean
        if m.mainStore["subscriberId"] <> invalid
            _sub = m.mainStore["subscriberId"]
        else
            _sub = False
        end if
        return _sub
    end function

    store.setSubscriberType = function(subtype as string)
        m.mainStore["subscriberType"] = subtype
    end function

    store.getsubscriberType = function() as boolean
        if m.mainStore["subscriberType"] <> invalid
            _sub = m.mainStore["subscriberType"]
        else
            _sub = False
        end if
        return _sub
    end function

    store.setPlaybackPos = function(pos1 as longinteger)
        m.mainStore["lastKnownPos"] = pos1
    end function

    store.getPlaybackPos = function() as longinteger
        if m.mainStore["lastKnownPos"] <> invalid
            _pos = m.mainStore["lastKnownPos"]
        else
            _pos = m.mainStore.playDur
        end if
        return _pos
    end function
    'Functions to calculate Play Duration
    store.updatePlayDuration = function(playDur)
        m.mainstore.playDur = playDur - m.mainStore.pauseDur
        if m.mainStore.playDur < 0
            m.mainStore.playDur = playDur
        end if
    end function

    store.updateAdPlayDuration = function(adPlayDur)
        if adPlayDur <> invalid
            m.mainstore.adPlayDur = adPlayDur - m.mainStore.adPauseDur
            if m.mainStore.adPlayDur < 0
                m.mainStore.adPlayDur = adPlayDur
            end if
        end if
    end function

    store.updatePauseDuration = function(pauseDur)
        m.mainstore.pauseDur += pauseDur
        '?pauseDur
    end function

    store.updateAdPauseDuration = function(pauseDur)
        m.mainstore.adPauseDur += pauseDur
    end function

    store.pushDataRate = function(dataRate)
        if dataRate <> invalid
            m.dataRates.Push(dataRate)
            m.rate += dataRate
        end if
        bwInUse = m.rate / m.dataRates.count()
        bwInUse = bwInUse / 1024
        m.mainStore.AddReplace("bwInUse", bwInUse)
    end function

    store.getMinAndMaxRes = function()
        if m.mainStore.resolutions.count() > 0
            max = 0
            min = 0
            maximum = 0
            minimum = 0
            for each items in m.mainStore.resolutions
                item = items.split("x")
                if item[0].toInt() > max
                    max = item[0].toInt()
                    maximum = items
                else if item[0].toInt() < min or min = 0
                    min = item[0].toInt()
                    minimum = items
                else if item[1].toInt() > max
                    max = item[0].toInt()
                    maximum = items
                else if item[1].toInt() < min
                    min = item[0].ToInt()
                    minimum = items
                end if
            end for
            m.mainStore.addReplace("minRes", minimum)
            m.mainStore.AddReplace("maxRes", maximum)
        end if
    end function

    store.updateCustomTags = function(key as string, value as string)
        m.mainStore.customTags = True
        m.mainStore.custom.addReplace(key, value)
    end function

    store.updateBuffWait = function(buffWait)
        timestamp = _getDateTime()
        timestamp = 0# + timestamp.AsSeconds() * 1000.0# + timestamp.GetMilliseconds() + m.mainStore.deltaTime
        buffWaiting = { "timestamp": timestamp, "buffWait": buffWait, "pbTime": m.mainStore.lastKnownPos, "buffWaitType": m.mainStore.buffWaitType}
        m.buffWait.push(buffWaiting)
        m.mainStore.sumBuffWait += buffWait
    end function

    store.sendRenditionEvent = function(chunkInfo)
        renditionDesc = {}
        isRenditionSet = false
        prevChunkInfo = m.mainStore.prevChunkInfo
        if chunkInfo <> invalid and prevChunkInfo <> invalid
            if chunkInfo.cbrBitrate <> invalid and chunkInfo.cbrBitrate > 0
                if prevChunkInfo.cbrBitrate = invalid
                    prevChunkInfo.cbrBitrate = 0
                end if
                if prevChunkInfo.cbrBitrate <> chunkInfo.cbrBitrate 
                    bitrateString = "Prev: " + StrI(prevChunkInfo.cbrBitrate).Replace(" ", "") + ", New: " + StrI(chunkInfo.cbrBitrate).Replace(" ", "")
                    renditionDesc.addReplace("Bitrate", bitrateString)
                    isRenditionSet = true
                end if
            end if
            if chunkInfo.res <> invalid and chunkInfo.res <> ""
                if prevChunkInfo.res = invalid
                    prevChunkInfo.res = "0x0"
                end if
                if prevChunkInfo.res <> chunkInfo.res
                    resString = "Prev: " + prevChunkInfo.res + ", New: " + chunkInfo.res
                    renditionDesc.addReplace("Res", resString)
                    isRenditionSet = true
                end if
            end if
            if chunkInfo.vCodec <> invalid
                if prevChunkInfo.vCodec = invalid
                    prevChunkInfo.vCodec = "NA"
                end if
                if prevChunkInfo.vCodec <> chunkInfo.vCodec
                    vCodecString = "Prev: " + prevChunkInfo.vCodec + ", New: " + chunkInfo.vCodec
                    renditionDesc.addReplace("VCodec", vCodecString)
                    isRenditionSet = true
                end if
            end if
            if chunkInfo.aCodec <> invalid
                if prevChunkInfo.aCodec = invalid
                    prevChunkInfo.aCodec = "NA"
                end if
                if prevChunkInfo.aCodec <> chunkInfo.aCodec
                    aCodecString = "Prev: " + prevChunkInfo.aCodec + ", New: " + chunkInfo.aCodec
                    renditionDesc.addReplace("ACodec", aCodecString)
                    isRenditionSet = true
                end if
            end if
        end if

        m.mainStore.addReplace("prevChunkInfo", chunkInfo)

        if isRenditionSet
            m.mainStore.addReplace("renditionDesc", FormatJson(renditionDesc))
            return true
        end if
        return false
    end function

    store.updateChunk = function(chunkInfo as object)
        timestamp = _getDateTime()
        timestamp = 0# + timestamp.AsSeconds() * 1000.0# + timestamp.GetMilliseconds() + m.mainStore.deltaTime
        if timestamp <> m.prevTimestamp
            chunkInfo.AddReplace("timestamp", timestamp)
            m.prevTimestamp = timestamp
            if m.mainStore.vCodec <> invalid
                chunkInfo.addReplace("vCodec", m.mainStore.vCodec)
            end if
            if m.mainStore.aCodec <> invalid
                chunkInfo.addReplace("aCodec", m.mainStore.aCodec)
            end if
            if m.mainStore.bitrateProfiles <> invalid and m.mainStore.bitrateProfiles.count() > 0
                index = 0
                for each item in m.mainStore.bitrateProfiles
                    if chunkInfo.cbrBitrate = item
                        chunkInfo.AddReplace("profileNum", index)
                        if m.mainStore.resolutions <> invalid and index < m.mainStore.resolutions.count()
                            chunkInfo.AddReplace("res", m.mainStore.resolutions[index])
                        end if
                    end if
                    index += 1
                end for
            end if
            if chunkInfo.cbrBitrate > m.lastRate and m.lastRate <> 0
                m.upshift += 1
            end if
            if chunkInfo.cbrBitrate < m.lastRate and m.lastRate <> 0
                m.downShift += 1
            end if

            if m.segmentQueue.Count() = 0 or m.lastRate <> chunkInfo.cbrBitrate
                m.segmentQueue.Push(chunkInfo)
            end if

            m.lastRate = chunkInfo.cbrBitrate
            m.lastSegment = chunkInfo
        end if
    end function

    store.updateDeltaTime = function(time)
        m.mainStore.addReplace("deltaTime", time)
    end function

    store.updateAdBuffWait = function(adBuffWait)
        timestamp = _getDateTime()
        timestamp = 0# + timestamp.AsSeconds() * 1000.0# + timestamp.GetMilliseconds() + m.mainStore.deltaTime
        'buffWaiting={"timestamp":timestamp,"buffWait":adBuffWait,"pbTime":m.mainStore.adPlaybackPos}
        'm.buffWait.push(buffWaiting)
        m.mainStore.adSumBuffWait += adBuffWait
    end function

    return store
end function

function MMSmartStream() as object
    'MM API's engine. Has access to storage object. "init()" function enables beacon timer object and utility functions for engine functioning
    'All requests are handled by this component scope functions.
    mmsdk = {}
    mmsdk.init = function()
        m.httpPort = _createPort()
        m.mainStore = MMStore()
        m.mainStore.init()
        m.isInitialised = false
        m.playingTime = _getDateTime()
        m.pauseTime = _getDateTime()
        m.latencyTimespan = createObject("roTimeSpan")
        m.bufferTimespan = createObject("roTimeSpan")
        m.pauseTimespan = createObject("roTimeSpan")
        m.events = []
        m.prevState = ""
        m.prevBufferingState = "IDLE"
        m.prevAdState = ""
        m.isStartAfterAd = false
        m.adLatencyTimespan = createObject("roTimeSpan")
        m.adPlayingTime = _getDateTime()
        m.adPauseTime = _getDateTime()

        m.sendOutStats = function(data as object, isBufferedEvent as object) as void
            if m.isInitialised = false
                return
            end if

            if isBufferedEvent = false
                m.checkForBufferedEvents()
            end if

            p_url = m.mainStore.getProducerUrl()
            connection = _createConnection(m.httpPort)
            connection.SetURL(p_url)
            connection.SetRequest("POST")
            dataCopy = data            
            data = minifyPayload(data)
            data = formatJson(data)
            
            retryCountdown = 3
            while retryCountdown > 0
                sent = connection.AsyncPostFromString(data)                
                if sent                    
                    msg = wait(0, m.httpPort)                    
                    if type(msg) = "roUrlEvent"                        
                        ' ?data 'uncomment this to print payloads in terminal
                        exit while
                        ' retryCountdown = -1
                    end if
                end if
                retryCountdown = retryCountdown - 1
            end while

            if retryCountdown <= 0 and isBufferedEvent = false
                deviceInfo = CreateObject("rodeviceinfo")
                connectionStatus = deviceInfo.GetInternetStatus()

                if connectionStatus = false
                    bufferedEvents = m.mainStore.getBufferedQueue()
                    if(bufferedEvents.Count() > 500)
                        m.mainStore.shiftBufferedQueue()
                    end if
                    m.mainStore.pushToBufferedQueue(dataCopy)
                end if
            end if

            secondaryProducerList = m.mainStore.getSecondaryProducerList()
            if secondaryProducerList <> invalid
                m.sendDataToSecondaryProducerList(data, secondaryProducerList)
            end if
        end function

        m.sendDataToSecondaryProducerList = function(data as string, secondaryProducerList as object) as void            
            if type(secondaryProducerList) <> "roArray"                
                return
            end if

            for each producerURL in secondaryProducerList                
                connection = _createConnection(m.httpPort)
                connection.SetURL(producerURL)
                connection.SetRequest("POST")
                sent = connection.AsyncPostFromString(data)
            end for            
        end function

        m.AsyncRegisterSession = function(api_url as string)
            m.httpPort = _createPort()
            connection = _createConnection(m.httpPort)            
            connection.setURL(api_url)
            connection.setRequest("GET")
            'data=formatJSON(data)
            'ParseJson(m.connection.AsyncGetToString())
            'Set Retries
            retryCountdown = 3
            timeout = 15000
            while retryCountdown > 0
                response = connection.AsyncGetToString()
                event = wait(timeout, m.httpPort)
                if type(event) = "roUrlEvent"
                    '?"Post Registration"
                    response = event.getString()
                    ? response
                    response = ParseJSON(response)
                    if response <> invalid and response.error = invalid
                        timestamp = _getDateTime()
                        timestamp = 0# + timestamp.AsSeconds() * 1000.0 + timestamp.GetMilliseconds()
                        m.mainStore.updateDeltaTime(response.timestamp - timestamp)
                        'm.mainStore.adjustQueueTime()
                        m.mainStore.setProducerURL(response["producerURL"])
                        if response["secProdList"] <> invalid                            
                            m.mainStore.setSecondaryProducerList(response["secProdList"])
                        end if
                        m.mainStore.setInterval(response["statsInterval"])
                        m.mainStore.setRegistrationStatus(true)
                        m.isInitialised = true
                        retryCountdown = -1
                    else if response = invalid or response.error <> invalid
                        m.isInitialised = False
                        exit while
                    end if
                    exit while
                end if
                retryCountdown = retryCountdown - 1
            end while
        end function

        m.getProfiles = function(manifestURL as string) as void
            if manifestURL = invalid
                return
            end if
            
            if m.manifestDisable = True
                m.mainStore.addToStore("mode", "QBRDisabled-NoPresentationInfo")
                return
            end if

            format = _getStreamFormat(manifestURL)
            if format = "HLS"
                connection = _createConnection(m.httpPort)
                connection.setURL(manifestURL)
                connection.setRequest("GET")
                response = connection.getToString()
                if response <> invalid
                    bitrates = response.split("BANDWIDTH=")
                    profiles = []
                    if bitrates <> invalid
                        bitrates.shift()
                        for each item in bitrates
                            item = item.split("\n")
                            item = item[0].split(",")
                            profiles.Push(item[0].toInt())
                        end for                        
                    end if
                    m.mainStore.addToStore("bitrateProfiles", profiles)

                    bits = profiles.count()
                    res = response.split("RESOLUTION=")
                    profiles = []

                    if res <> invalid
                        res.shift()
                        for each item in res
                            item = item.split("\n")
                            item = item[0].split(",")
                            profiles.Push(item[0])
                        end for
                    end if
                    if profiles.count() > 0
                        temp = profiles[profiles.count() - 1].split(",")
                        profiles[profiles.count() - 1] = temp[0]
                    end if
                    m.mainStore.addToStore("resolutions", profiles)

                    if bits > 0 and profiles.count() > 0
                        m.mainStore.addToStore("totalProfiles", profiles.count())
                    else if profiles.count() = 0 and bits > 0
                        m.mainStore.addToStore("totalProfiles", bits)
                    end if
                    m.mainStore.getMinAndMaxRes()
                end if
            else if format = "DASH"
                connection = _createConnection(m.httpPort)
                connection.setURL(manifestURL)
                connection.setRequest("GET")
                profiles = []
                res = []
                temp = []
                response = connection.getToString()
                xml = CreateObject("roXMLelement")

                if response <> invalid and xml <> invalid
                    xml.Parse(response)
                    if xml.getNamedElements("Period") <> invalid and xml.getNamedElements("Period").count() > 0 and xml.getNamedElements("Period")[0] <> invalid and xml.getNamedElements("Period")[0].getBody() <> invalid
                        temp = xml.getNamedElements("Period")[0].getBody().GetNamedElements("Representation")
                    end if
                end if
                
                if temp <> invalid
                    for each item in temp
                        avc = CreateObject("roRegex", "avc3", "")
                        if item <> invalid and item.getAttributes() <> invalid
                            if item.getAttributes().codecs <> invalid and avc.isMatch(item.getAttributes().codecs)
                                m.mainStore.addToStore("vCodec", item.getAttributes().codecs)
                                if item.getAttributes().bandwidth <> invalid
                                    profiles.push(item.getAttributes().bandwidth)
                                end if                                
                            else if item.getAttributes().codecs <> invalid and avc.isMatch(item.getAttributes().codecs) = False
                                m.mainStore.addToStore("aCodec", item.getAttributes().codecs)
                            end if
                            if item.getAttributes().height <> invalid and item.getAttributes().width <> invalid
                                res.push(item.getAttributes().width.toStr() + "x" + item.getAttributes().height.toStr())
                            end if
                        end if                        
                    end for
                end if
                m.mainStore.addToStore("totalProfiles", profiles.count())
                m.mainStore.addToStore("resolutions", res)
            end if
        end function

        m.checkForBufferedEvents = function() as void
            deviceInfo = CreateObject("rodeviceinfo")
            connectionStatus = deviceInfo.GetInternetStatus()
            bufferedEvents = m.mainStore.getBufferedQueue()

            if connectionStatus = True and bufferedEvents.Count() > 0
                for each data in bufferedEvents
                    m.sendOutStats(data, true)
                end for
                m.mainStore.clearBufferedQueue()
            end if
        end function

        m.sendOutQueue = function() as void
            events = m.mainStore.getEventQueue()
            if events.count() > 0
                for each data in events
                    if data.qubitData[0].pbEventInfo <> invalid
                        if data.qubitData[0].pbeventInfo.event = "START"
                            store = m.mainStore.getStore()
                            if data.qubitData[0].streamInfo.totalDuration = invalid
                                if store.totalDuration <> invalid and store.totalDuration <> 0
                                    data.qubitData[0].streamInfo["totalDuration"] = store.totalDuration
                                else return
                                end if
                            else if data.qubitData[0].streamID.mode = invalid
                                if store.mode <> invalid
                                    data.qubitData[0].streamID["mode"] = store.mode
                                else return
                                end if
                            else if data.qubitData[0].streamID.isLive = invalid
                                if store.mode <> invalid
                                    data.qubitData[0].streamID["isLive"] = store.isLive
                                else return
                                end if
                            end if
                        end if
                    end if
                    m.sendOutStats(data, false)
                end for
                m.mainStore.clearEventQueue()
            end if
        end function

        m.setContentMetadata = function(contentMeta as object)
            store = m.mainStore.getStore()
            if contentMeta <> invalid
                if contentMeta.assetID <> invalid
                    store.AddReplace("assetID", contentMeta.assetID)
                end if
                if contentMeta.assetName <> invalid
                    store.AddReplace("assetName", contentMeta.assetName)
                end if
                if contentMeta.videoID <> invalid
                    store.AddReplace("videoID", contentMeta.videoID)
                end if
                if contentMeta.contentType <> invalid
                    store.AddReplace("contentType", contentMeta.contentType)
                end if
                if contentMeta.drmProtection <> invalid
                    store.AddReplace("drmProtection", contentMeta.drmProtection)
                end if
                if contentMeta.episodeNumber <> invalid
                    store.AddReplace("episodeNumber", contentMeta.episodeNumber)
                end if
                if contentMeta.genre <> invalid
                    store.AddReplace("genre", contentMeta.genre)
                end if
                if contentMeta.season <> invalid
                    store.AddReplace("season", contentMeta.season)
                end if
                if contentMeta.seriesTitle <> invalid
                    store.AddReplace("seriesTitle", contentMeta.seriesTitle)
                end if
            end if
        end function
    end function

    mmsdk.disableManifestFetch = function(disable as boolean)
        if disable = true
            m.manifestDisable = True
        end if
    end function

    mmsdk.enableLogTrace = function(isEnable as boolean)        
        m.mainStore.addToStore("enableLogTrace", isEnable)
    end function

    mmsdk.getRegistrationStatus = function()
        'Not Implemented
    end function

    mmsdk.getVersion = function()        
        return m.mainStore.getFromStore["SDK_VERSION"]
    end function    

    mmsdk.initializeSession = function(mode as string, manifestURL as string, contentMetadata as object) as object
        store = m.mainStore.getStore()
        api_url = "https://register.mediamelon.com/mm-apis/register/" + store.customerID + "?sdkVersion=" + store.SDKVERSION + "&hintFileVersion=" + store.hFileVersion + "&EP_SCHEMA_VERSION=" + store.EP_SCHEMA + "&platform=" + store.platform + "&qmetric=true&component=" + store.component + "&mode=QBRDisabled"
        store.addReplace("mode", mode)
        store.addReplace("manifestURL", manifestURL)
        
        m.setContentMetadata(contentMetadata)

        sessionId = m.mainstore.generateSessionId()
        store.AddReplace("sessionId", sessionId)
        m.mainStore.updateStore(store)        
        m.latencyTimespan.mark()
        m.prevState = "ONLOAD"
        m.isStartAfterAd = false
        m.asyncRegisterSession(api_url)
        if manifestURL <> invalid and manifestURL <> ""
            m.getProfiles(manifestURL)
        end if 
        data = m.mainStore.createEventStats("ONLOAD")
        m.sendOutStats(data, false)
        response = { "status": m.isInitialised, "interval": m.mainStore.getInterval() }
        return response

        'Create a new branched out thread for subsequent function call and exit.
    end function

    mmsdk.setStreamURL = function(manifestURL as string)
        store = m.mainStore.getStore()
        store.addReplace("manifestURL", manifestURL)
    end function

    mmsdk.registerMMSmartStreaming = function(name as string, customerID as string, component as string, subscriberID as string, domainName as string, subscriberType as string, subscriberTag as string)
        store = m.mainStore.getStore()
        store.AddReplace("customerID", customerID)
        store.AddReplace("component", component)
        store.AddReplace("subscriberID", subscriberID)
        store.AddReplace("playerName", name)
        store.AddReplace("domainName", domainName)
        store.AddReplace("subscriberType", subscriberType)
        store.AddReplace("subscriberTag", subscriberTag)
        store.AddReplace("dataSrc", "Player")
        store.AddReplace("isRegistered", True)
        m.mainStore.updateStore(store)
    end function

    'Start of ADs-----------------------------------------------------
    mmsdk.reportAdError = function(Error as string, pos1 as double) as void
        'Update and send Error Event
        if m.isInitialised = false or Error = invalid
            return
        end if
        date = _getDateTime()
        curTimeInMS = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
        adplayTimeInMS = 0# + m.adPlayingTime.AsSeconds() * 1000.0# + m.adPlayingTime.GetMilliseconds()
        adPlayDur = _ceiling((curTimeInMS - adplayTimeInMS) / 1000)
        m.mainStore.updateAdPlayDuration(adPlayDur)
        m.mainStore.addToStore("errorString", error)
        if pos1 <> invalid and pos1 >= 0
            m.mainStore.addToStore("adPlaybackPos", pos1)
        end if
        data = m.mainStore.createAdEventStats("AD_ERROR")
        m.sendOutStats(data, false)
    end function

    mmsdk.reportAdInfo = function(adInfo as object)
        'Store Ad Info
        if adInfo <> invalid
            store = m.mainStore.getStore()
            if adInfo.adClient <> invalid
                store.AddReplace("adClient", adInfo.adClient)
            end if
            if adInfo.adId <> invalid
                store.AddReplace("adId", adInfo.adId)
            end if
            if adInfo.adCreativeId <> invalid
                store.AddReplace("adCreativeId", adInfo.adCreativeId)
            end if
            if adInfo.adDuration <> invalid
                store.AddReplace("adDuration", adInfo.adDuration)
            end if
            if adInfo.adPosition <> invalid
                store.AddReplace("adPosition", adInfo.adPosition)
            end if
            if adInfo.adLinear <> invalid
                store.AddReplace("adLinear", adInfo.adLinear)
            end if
            if adInfo.adCreativeType <> invalid
                store.AddReplace("adCreativeType", adInfo.adCreativeType)
            end if
            if adInfo.adSystem <> invalid
                store.AddReplace("adSystem", adInfo.adSystem)
            end if
            if adInfo.adResolution <> invalid
                store.AddReplace("adResolution", adInfo.adResolution)
            end if
            if adInfo.isBumper <> invalid
                store.AddReplace("isBumper", adInfo.isBumper)
            end if
            if adInfo.adPodIndex <> invalid
                store.AddReplace("adPodIndex", adInfo.adPodIndex)
            end if
            if adInfo.adPodLength <> invalid
                store.AddReplace("adPodLength", adInfo.adPodLength)
            end if
            if adInfo.adPodPosition <> invalid
                store.AddReplace("adPodPosition", adInfo.adPodPosition)
            end if
            if adInfo.adUrl <> invalid
                store.AddReplace("adUrl", adInfo.adUrl)
            end if
            if adInfo.adTitle <> invalid
                store.AddReplace("adTitle", adInfo.adTitle)
            end if
            if adInfo.adBitrate <> invalid
                store.AddReplace("adBitrate", adInfo.adBitrate)
            end if

            m.mainStore.updateStore(store) ' TODO: Check If this fuction is needed to update the values ??
        end if
    end function

    mmsdk.reportAdPlaybackTime = function(playbackPos as longinteger)
        'Store / update AdPlayback time
        if playbackPos <> invalid and playbackPos > 0
            m.mainStore.AddReplace("adPlaybackPos", playbackPos)
            if playbackPos > 0 and m.prevAdState <> "AD_PAUSED" and m.isAdPlaying = true
                if m.mainStore.adIntervalTimespan <> invalid
                    elapsed = _getDateTime().AsSeconds() - m.adPlayingTime.AsSeconds()
                    if elapsed mod (m.mainStore.adKonstantInterval) = 0
                        ' Ad PlayDur
                        date = _getDateTime()
                        curTimeInMS = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
                        adplayTimeInMS = 0# + m.adPlayingTime.AsSeconds() * 1000.0# + m.adPlayingTime.GetMilliseconds()
                        adPlayDur = _ceiling((curTimeInMS - adplayTimeInMS) / 1000)
                        m.mainStore.updateAdPlayDuration(adPlayDur)

                        ' Create and Push Ad playing Event Data into EventQueue
                        data = m.mainStore.createAdEventStats("AD_PLAYING")
                        if data.qubitData[0].pbEventInfo.event <> "RETURN"
                            m.mainStore.pushToEventQueue(data)

                            if m.isInitialised = true
                                m.sendOutQueue()
                            end if
                        end if
                    end if
                end if
            end if
        end if
    end function

    mmsdk.reportAdState = function(adState as string) as void
        if m.isInitialised = false
            return
        end if

        if adState <> m.prevAdState
            date = _getDateTime()
            curTimeInMS = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
            adplayTimeInMS = 0# + m.adPlayingTime.AsSeconds() * 1000.0# + m.adPlayingTime.GetMilliseconds()
            adPlayDur = _ceiling((curTimeInMS - adplayTimeInMS) / 1000)

            if adState = "AD_IMPRESSION"
                ' AD Impression, reset for new ad session
                m.adLatencyTimespan.mark()
                m.adPlayingTime.mark()
                m.mainStore.AddReplace("adLatency", 0.0)
                m.mainStore.AddReplace("adInterval", 0.0)
                m.mainStore.AddReplace("adPauseDur", 0.0)
                m.mainStore.AddReplace("adPlayDur", 0.0)
                m.mainStore.AddReplace("adSumBuffWait", 0)
                m.mainStore.AddReplace("adPlaybackPos", 0)
                adPlayDur = 0                
                m.isAdPlaying = false
            end if
            if adState = "AD_PLAY"
                m.adPlayingTime.mark() ' Start Ad Session for AdPlayDur
                latency = int(m.adLatencyTimespan.TotalMilliseconds())
                m.mainStore.reportAdLatency(latency)
                m.isAdPlaying = true
                adPlayDur = 0

            end if
            if adState = "AD_RESUMED" and m.prevAdState = "AD_PAUSED"
                curTimeInMS = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
                adPauseTimeInMS = 0# + m.adPauseTime.AsSeconds() * 1000.0# + m.adPauseTime.GetMilliseconds()
                adPauseDur = _ceiling((curTimeInMS - adPauseTimeInMS) / 1000)

                m.mainStore.updateAdPauseDuration(adPauseDur)
                m.mainStore.addToStore("lastAdPauseDur", m.adPauseTimespan.TotalMilliseconds())
            end if
            if adState = "AD_PAUSED"
                if m.adPauseTimespan = invalid
                    m.adPauseTimespan = createObject("roTimeSpan")
                end if
                m.adPauseTimespan.mark()
                m.adPauseTime.mark()

                m.mainStore.updateAdPlayDuration(adPlayDur)
                segments = m.mainStore.createSegmentStats()
                if segments <> invalid
                    m.mainStore.pushToEventQueue(segments)
                    m.mainStore.clearSegmentQueue()
                end if
            end if
            if adState = "AD_ENDED" or adState = "AD_COMPLETE" or adState = "AD_SKIPPED" or adState = "AD_BREAK_ENDED"
                m.isAdPlaying = false
            end if

            m.mainStore.updateAdPlayDuration(adPlayDur)

            data = m.mainStore.createAdEventStats(adState)
            ' Push Event Data into EventQueue
            if data.qubitData[0].pbEventInfo.event <> "RETURN"
                m.mainStore.pushToEventQueue(data)
                m.prevAdState = adState
                if m.isInitialised = true
                    m.sendOutQueue()
                    'if successful.
                end if
            end if
        end if
        m.prevAdState = adState
    end function

    mmsdk.reportAdBufferingCompleted = function() as void
        if m.isInitialised = false
            return
        end if
        if m.prevAdState = "AD_BUFFERING"            
            m.mainStore.updateBuffWait(m.bufferTimespan.Totalmilliseconds())
        end if
    end function

    mmsdk.reportAdBufferingStarted = function() as void
        if m.isInitialised = false
            return
        end if
        m.bufferTimespan.mark()
        date = _getDateTime()
        curTimeInMS = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
        adplayTimeInMS = 0# + m.adPlayingTime.AsSeconds() * 1000.0# + m.adPlayingTime.GetMilliseconds()
        adPlayDur = _ceiling((curTimeInMS - adplayTimeInMS) / 1000)
        m.mainStore.updateAdPlayDuration(adPlayDur)
        data = m.mainStore.createEventStats("AD_BUFFERING")
        m.mainStore.pushToEventQueue(data)
        m.prevAdState = "AD_BUFFERING"
        if m.isInitialised = true
            m.sendOutQueue()
        end if
    end function
    'End of ADs-----------------------------------------------------

    mmsdk.reportBufferingStarted = function(isVRT as boolean) as void
        if m.isInitialised = false
            return
        end if
        if isVRT = True
            m.mainStore.addToStore("buffWaitType", "VRT")                     
        else 
            m.mainStore.addToStore("buffWaitType", "CIRR")                        
        end if
        m.bufferTimespan.mark()                
        date = _getDateTime()
        playDur = date.AsSeconds() - m.playingTime.AsSeconds()
        m.mainStore.updatePlayDuration(playDur)
        if m.prevBufferingState <> "BUFFERING_START"
            data = m.mainStore.createEventStats("BUFFERING_START")
            m.mainStore.pushToEventQueue(data)
            m.prevBufferingState = "BUFFERING_START"
            if m.isInitialised = true
                m.sendOutQueue()
            end if
        end if
    end function

    mmsdk.reportBufferingCompleted = function() as void
        if m.isInitialised = false
            return
        end if
        if m.prevBufferingState = "BUFFERING_START"
            m.mainStore.updateBuffWait(m.bufferTimespan.Totalmilliseconds())
            data = m.mainStore.createEventStats("BUFFERING_COMPLETE")
            m.mainStore.pushToEventQueue(data)
            m.prevBufferingState = "BUFFERING_COMPLETE"
            if m.isInitialised = true
                m.sendOutQueue()
            end if
        end if
    end function

    mmsdk.reportChunkRequest = function(chunkInfo as object)
        m.mainStore.updateChunk(chunkInfo)
        isRenditionSet = m.mainStore.sendRenditionEvent(chunkInfo)

        if isRenditionSet = true
            data = m.mainStore.createEventStats("RENDITION_CHANGE")
            m.mainStore.pushToEventQueue(data)            
            if m.isInitialised = true
                m.sendOutQueue()                
            end if
        end if
    end function

    mmsdk.reportCustomMetadata = function(key as string, value as string)
        m.mainStore.updateCustomTags(key, value)
    end function

    mmsdk.reportContentMetadata = function(contentMetadata as object)
        m.setContentMetadata(contentMetadata)
    end function

    mmsdk.reportDeviceInfo = function(brand as string, deviceModel as string, deviceOS as string, deviceOsVersion as string, telecomOperator as string, screenWidth as integer, screenHeight as integer)
        m.mainStore.addToStore("brand", brand)
        m.mainStore.addToStore("deviceModel", deviceModel)
        m.mainStore.addToStore("deviceOS", deviceOS)
        m.mainStore.addToStore("deviceOSVersion", deviceOSVersion)
        m.mainStore.addToStore("telecomOperator", telecomOperator)
        m.mainStore.addToStore("screenWidth", screenWidth)
        m.mainStore.addToStore("screenHeight", screenHeight)
    end function

    mmsdk.reportDownloadRate = function(downloadRate as integer)
        'Not Implemented
        m.mainStore.pushDataRate(downloadRate)
    end function

    mmsdk.reportError = function(Error as string, pos1 as double) as void
        'Update and send Error Event
        if m.isInitialised = false
            return
        end if
        date = _getDateTime()
        playDur = date.AsSeconds() - m.playingTime.AsSeconds()
        if m.prevState = "ONLOAD"
            playDur = 0
        end if
        m.mainStore.updatePlayDuration(playDur)
        m.mainStore.addToStore("errorString", error)
        m.mainStore.addToStore("lastKnownPos", pos1)
        data = m.mainStore.createEventStats("ERROR")
        m.sendOutStats(data, false)
    end function

    mmsdk.reportFrameLoss = function(lossCnt as integer)
        'Not Implemented
        m.store.AddReplace("lossCount", lossCnt)
    end function

    mmsdk.reportLocation = function(latitude as double, longitude as double)
        'Not Implemented
        m.mainStore.sendCoordinates(latitude, longitude)
    end function

    'mmsdk.reportNetworkType = function(networkType as object)
    'Not Implemented
    'end function

    mmsdk.reportPlaybackPosition = function(playbackPos as double)
        m.mainStore.addToStore("lastKnownPos", playbackPos)
        'playDur=m.calculatePlayDuration()
        'm.mainStore.addToStore("playDur",playDur)
    end function

    mmsdk.reportPlayerInfo = function(playerVersion as string, basePlayerName as string, basePlayerVersion as string)
        'Not Implemented
        m.mainStore.addToStore("playerVersion", playerVersion)
        m.mainStore.addToStore("basePlayerName", basePlayerName)
        m.mainStore.addToStore("basePlayerVersion", basePlayerVersion)
    end function

    mmsdk.reportPlayerSeekStarted = function() as void
        if m.isInitialised <> true
            return
        end if

        data = m.mainStore.createEventStats("SEEK_START")
        m.mainStore.pushToEventQueue(data)
        m.sendOutQueue()
    end function

    mmsdk.reportPlayerSeekCompleted = function(seekEndPos as double) as void ' why the seek end position not sent question
        m.seekEndPos = seekEndPos
        if m.isInitialised <> true
            return
        end if
        m.date = _getDateTime()
        data = m.mainStore.createEventStats("SEEK_COMPLETE")
        m.mainStore.pushToEventQueue(data)
        m.prevState = "SEEKED"        
        m.sendOutQueue()        
    end function

    mmsdk.reportPlayerState = function(playerState as string) as void
        if m.isInitialised = false or m.prevState = "ENDED" or m.prevState = "COMPLETE"
            return
        end if
        if playerState <> m.prevState
            date = _getDateTime()
            playDur = date.AsSeconds() - m.playingTime.AsSeconds()
            if (m.prevState = "PAUSE" or m.prevState = "SEEKED") and (playerState = "PLAYING" or playerState = "RESUME")
                playerState = "RESUME"
                curTimeInMS = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
                pauseTimeInMS = 0# + m.pauseTime.AsSeconds() * 1000.0# + m.pauseTime.GetMilliseconds()
                pauseDur = _ceiling((curTimeInMS - pauseTimeInMS) / 1000)

                m.mainStore.updatePauseDuration(pauseDur)
                m.mainStore.addToStore("lastPauseDur", m.pauseTimespan.totalMilliseconds())
                m.mainStore.updatePlayDuration(playDur)
            end if
            if playerState = "PAUSE"
                m.pauseTime.mark()
                m.pauseTimespan.mark()
                m.mainStore.updatePlayDuration(playDur)
                segments = m.mainStore.createSegmentStats()
                if segments <> invalid
                    m.mainStore.pushToEventQueue(segments)
                    m.mainStore.clearSegmentQueue()
                end if
            end if
            if playerState = "ENDED" or playerState = "COMPLETE"
                if m.prevState = "PAUSE"
                    curTimeInMS = 0# + date.AsSeconds() * 1000.0# + date.GetMilliseconds()
                    pauseTimeInMS = 0# + m.pauseTime.AsSeconds() * 1000.0# + m.pauseTime.GetMilliseconds()
                    pauseDur = _ceiling((curTimeInMS - pauseTimeInMS) / 1000)

                    m.mainStore.updatePauseDuration(pauseDur)
                    m.mainStore.addToStore("lastPauseDur", m.pauseTimespan.totalMilliseconds())
                end if

                m.mainStore.updatePlayDuration(playDur)
                segments = m.mainStore.createSegmentStats()
                if segments <> invalid
                    m.mainStore.pushToEventQueue(segments)
                    m.mainStore.clearSegmentQueue()
                end if
            end if
            data = m.mainStore.createEventStats(playerState)
            if data.qubitData[0].pbEventInfo.event <> "RETURN"
                m.mainStore.pushToEventQueue(data)
                m.prevState = playerState
                if m.isInitialised = true
                    m.sendOutQueue()
                    'if successful.
                end if
            end if
        end if
        m.prevState = playerState
    end function

    'mmsdk.reportPresentationSize = function(width as integer, height as integer)
    'Not Implemented
    'end function

    mmsdk.reportUserInitiatedPlayback = function()        
        m.playingTime.mark()        
        latency = int(m.latencyTimespan.TotalMilliseconds())
        latency = latency
        m.mainStore.reportLatency(latency)
        m.prevState = "START"

        ' Send
        if m.isStartAfterAd = true
            data = m.mainStore.createEventStats("START_AFTER_AD")
            m.mainStore.pushToEventQueue(data)
            m.sendOutQueue()
        else
            data = m.mainStore.createEventStats("START")
            m.mainStore.pushToEventQueue(data)
            m.sendOutQueue()
        end if
    end function

    'mmsdk.reportWifiDataRate = function(dataRate as longinteger)

    'Not Implemented
    'end function

    mmsdk.reportWifiSSID = function(ssid as string)
        m.mainStore.setSsid(ssid)
    end function

    mmsdk.reportWifiSignalStrengthPercentage = function(strength as double)
        'Not Implemented
        m.mainStore.setWifiSignalStrength(strength)
    end function

    mmsdk.setPresentationInformation = function(presentationInfo as object)
        'Not Implemented
        if presentationInfo.isLive = true
            presentationInfo.duration = -1
            m.mainStore.addToStore("mode", "QBRDisabled-LiveSessionNotSupported")
        else if presentationInfo.duration = -1
            presentationInfo.isLive = True
            m.mainStore.addToStore("mode", "QBRDisabled-LiveSessionNotSupported")
        end if

        m.mainStore.addToStore("totalDuration", presentationInfo.duration)
        m.mainStore.addToStore("representation", presentationInfo.representation)
        m.mainStore.addToStore("isLive", presentationInfo.isLive)
        m.mainStore.addToStore("streamSourceType", presentationInfo.streamSourceType)        
        m.sendOutQueue()
    end function

    mmsdk.updateSubscriber = function(subscriberID as string, subscriberType as string)
        'Not Implemented
        m.mainStore.setSubscriberID(subscriberID)
        m.mainStore.setSubscriberType(subscriberType)
    end function

    mmsdk.updateSubscriberID = function(subscriberID as string)
        'Not Implemented
        m.mainStore.setSubscriberID(subscriberID)
    end function

    mmsdk.fireBeacon = function(isPingPayload as boolean)
        date = _getDateTime()

        if isPingPayload = false
            playDur = date.AsSeconds() - m.playingTime.AsSeconds()
            m.mainStore.updatePlayDuration(playDur)
        end if        
        data = m.mainStore.createSegmentStats()

        if isPingPayload = true and data <> invalid
            'Convert data to ping payload
            pingData = {}
            for each key in data.Keys()
                if key <> "qubitData"
                    pingData.AddReplace(key, data[key])
                end if
            end for
            
            streamIdObj = data.qubitData[0].streamID

            newStreamId = {}
            if streamIdObj <> invalid
                if streamIdObj.custId <> invalid
                    newStreamId.AddReplace("custId", streamIdObj.custId)
                end if
                if streamIdObj.sessionId <> invalid
                    newStreamId.AddReplace("sessionId", streamIdObj.sessionId)
                end if
                if streamIdObj.pId <> invalid
                    newStreamId.AddReplace("pId", streamIdObj.pId)
                end if
                if streamIdObj.dataSrc <> invalid
                    newStreamId.AddReplace("dataSrc", "Player-ping")
                end if
                if streamIdObj.sst <> invalid
                    newStreamId.AddReplace("sst", streamIdObj.sst)
                end if
                if streamIdObj.subscriberId <> invalid
                    newStreamId.AddReplace("subscriberId", streamIdObj.subscriberId)
                end if
            end if
            
            qubitData = [{"streamID": newStreamId}]
            pingData.AddReplace("qubitData", qubitData)
            data = pingData
        end if

        if data <> invalid
            m.sendOutStats(data, false)
            m.mainStore.clearSegmentQueue()
        end if
    end function

    mmsdk.reportAppInfo = function(appName as string, appSdkVersion as string)
        m.mainStore.addToStore("appName", appName)
        m.mainStore.addToStore("appSdkNumber", appSdkVersion)
    end function

    mmsdk.reportDeviceId = function(deviceId as string)
        m.mainStore.addToStore("deviceId", deviceId)
    end function

    mmsdk.reportViewSessionId = function(viewSessionId as string)
        m.mainStore.addToStore("viewSessionId", viewSessionId)        
    end function

    mmsdk.reportCDN = function(cdn as string)
        m.mainStore.addToStore("cdn", cdn)        
    end function

    mmsdk.reportExperimentName = function(experimentName as string)
        m.mainStore.addToStore("experimentName", experimentName)        
    end function

    mmsdk.reportSubPropertyId = function(subPropertyId as string)
        m.mainStore.addToStore("subPropertyId", subPropertyId)        
    end function

    mmsdk.reportStreamFormat = function(streamFormat as string)
        m.mainStore.addToStore("streamFormat", streamFormat)        
    end function

    mmsdk.reportMediaType = function(mediaType as string)
        m.mainStore.addToStore("mediaType", mediaType)        
    end function

    mmsdk.updateDrmProtection = function(drmType as string)
        m.mainStore.addToStore("drmProtection", drmType)        
    end function

    mmsdk.reportCodecs = function(codecs as object)
        if codecs <> invalid
            if codecs.video <> invalid
                m.mainStore.addToStore("vCodec", codecs.video)
            end if

            if codecs.audio <> invalid
                m.mainStore.addToStore("aCodec", codecs.audio)
            end if
        end if
    end function

    mmsdk.reportRequestStatusEvent = function(eventName as string, desc as object)
        descString = "{}"
        if desc <> invalid
            descString = FormatJson(desc)
        end if
        m.mainStore.addToStore("requestStatusDesc", descString)

        data = m.mainStore.createEventStats(eventName)
        m.mainStore.pushToEventQueue(data)
        if m.isInitialised = true
            m.sendOutQueue()                
        end if
    end function

    return mmsdk
end function