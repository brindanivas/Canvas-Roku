'*********************************************************************
'** (c) 2016-2017 Roku, Inc.  All content herein is protected by U.S.
'** copyright and other applicable intellectual property laws and may
'** not be copied without the express permission of Roku, Inc., which
'** reserves all rights.  Reuse of any of this content for any purpose
'** without the permission of Roku, Inc. is strictly prohibited.
'*********************************************************************

Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "playContentWithAds"
    m.top.id = "PlayerTask"
end sub


sub playContentWithAds()
    video = m.top.video
    m.videodata = m.top.videodata
    view = video.getParent()
    RAF = Roku_Ads()
    ' RAF.setDebugOutput(true)
    RAF.enableNielsenDAR(true)
    RAF.setNielsenAppId("P2871BBFF-1A28-44AA-AF68-C7DE4B148C32")
    RAF.setNielsenGenre("GV")
    vastTag = GlobalGet("VastTAGURLNew")
    print "PlayerTask : playContentWithAds : vastTag : " vastTag
    RAF.setAdUrl(vastTag)
    RAF.enableAdMeasurements(true)
    RAF.setContentGenre("Sports")  'if unset, ContentNode has it as []
    RAF.setContentLength(m.videodata.duration.ToInt())
    RAF.setNielsenProgramId(m.videodata.title)
    RAF.setContentId(m.videodata._id.ToStr())

    logObj = {
        log: function(evtType = invalid as dynamic, ctx = invalid as dynamic)

            sendAdDataToMMSDK(ctx)

            if GetInterface(evtType, "ifString") <> invalid

                ' print "***** tracking event " + evtType + " fired."
                if ctx.companion = true then
                    print "***** companion = true"
                end if
                if ctx.errMsg <> invalid then print "*****   Error message: " + ctx.errMsg
                if ctx.adIndex <> invalid then print "*****  Ad Index: " + ctx.adIndex.ToStr()
                if ctx.ad <> invalid and ctx.ad.adTitle <> invalid then print "*****  Ad Title: " + ctx.ad.adTitle
            else if ctx <> invalid and ctx.time <> invalid
                ' print "***** checking tracking events for ad progress: " + ctx.time.ToStr()
            end if
        end function
    }

    logFunc = function(obj = invalid as dynamic, evtType = invalid as dynamic, ctx = invalid as dynamic)
        obj.log(evtType, ctx)
    end function

    RAF.setTrackingCallback(logFunc, logObj)


    adPods = RAF.getAds() 'array of ad pods
    keepPlaying = true 'gets set to `false` when showAds() was exited via Back button

    ' show the pre-roll ads, if any
    if adPods <> invalid and adPods.count() > 0
        video.control = "stop"
        m.top.playingAd = true
        print "Preroll adPods > " adPods
        if m.global <> invalid and m.global.MMAnalytics <> invalid
            m.global.MMAnalytics.setField("mmAdPlaying", true)
        end if
        keepPlaying = RAF.showAds(adPods, invalid, view)
    end if
    port = CreateObject("roMessagePort")
    if keepPlaying
        ' video.unobserveField("position")
        ' video.unobserveField("state")
        video.observeField("position", port)
        video.observeField("state", port)
        if m.top.bookmark > 0 then
            video.seek = m.top.bookmark
            video.seekMode = "accurate"
        end if
        video.visible = true
        video.control = "play"
        video.setFocus(true) 'so we can handle a Back key interruption
    end if

    curPos = 0
    lastPos = 0
    adPods = invalid
    adGap = 7 * 60 ' every 7 min show ads'
    nextAdTime = m.top.bookmark + adGap
    isPlayingPostroll = false
    while keepPlaying
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent"
            if msg.GetField() = "position"
                curPos = int(msg.GetData())
                ' print "curPos ---> " curPos
                ' m.top.currentPosition = curPos
                ' adPods = invalid
                if (curPos >= nextAdTime)
                    if (m.top.gettingUpdatedVastInProgress = false and m.top.getUpdatedVast = false)
                        if (m.top.vastURL <> invalid and m.top.vastURL <> "")
                            m.top.getUpdatedVast = true
                        else
                            m.top.gettingUpdatedVastInProgress = true
                            m.top.getUpdatedVast = true
                        end if
                    end if

                    if (m.top.gettingUpdatedVastInProgress = false and m.top.getUpdatedVast = true)
                        m.top.getUpdatedVast = false
                        vastTag = GlobalGet("VastTAGURLNew")
                        print "Setting NEW VAST => " vastTag
                        if (IsNullOrEmpty(vastTag))
                            nextAdTime = curPos + adGap
                            print "INFO: Skipped this break as No VAST recevied, Next Ad time : " nextAdTime
                        else
                            RAF.setAdUrl(vastTag)
                            adPods = RAF.getAds()
                            if adPods <> invalid
                                nextAdTime = curPos + adGap
                                print "Next Ad time : " nextAdTime
                            end if
                            if adPods <> invalid and adPods.count() > 0
                                'ask the video to stop - the rest is handled in the state=stopped event below
                                print "Midroll adPods > " adPods
                                if m.global <> invalid and m.global.MMAnalytics <> invalid
                                    m.global.MMAnalytics.setField("mmAdPlaying", true)
                                end if
                                video.control = "stop"
                            end if
                        end if
                    else
                        print "------------------------ Skipping progress as getting VAST in progress..."
                    end if
                else if (lastPos - curPos) > 30
                    nextAdTime = curPos + adGap
                    print "Next Ad time when rewind : " nextAdTime
                end if
                lastPos = curPos
            else if msg.GetField() = "state"
                curState = msg.GetData()
                ' m.top.currentState = curState
                if curState = "stopped"
                    keepPlaying = RAF.showAds(adPods, invalid, view)
                    adPods = invalid
                    if isPlayingPostroll
                        exit while
                    end if
                    if keepPlaying
                        video.visible = true
                        video.seek = curPos
                        video.control = "play"
                        video.setFocus(true) 'important: take the focus back (RAF took it above)
                    end if
                else if curState = "finished"
                    exit while
                    ' RAF.setAdUrl(vastTag)
                    ' adPods = RAF.getAds()
                    ' if adPods = invalid or adPods.count() = 0
                    '     exit while
                    ' end if
                    ' print "Postroll adPods > " adPods
                    ' isPlayingPostroll = true
                    ' video.control = "stop"
                else if curState = "paused"
                else if curState = "playing"
                else if curState = "error"
                    exit while
                end if
            end if
        end if
    end while

    video.visible = false
    ' m.top.currentPosition = -1
    m.top.stopped = true
    print "PlayerTask: exiting playContentWithAds()"
end sub


function sendAdDataToMMSDK(ctx as object)
    if m.global <> invalid and m.global.MMAnalytics <> invalid
        m.global.MMAnalytics.setField("mmAdData", ctx)
    end if
end function
