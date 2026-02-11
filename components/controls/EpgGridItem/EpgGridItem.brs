sub init()
    ' print "DynamicItem : Init"
    SetControls()
    SetObservers()
end sub

sub SetControls()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.scene = m.top.GetScene()

    m.channelIdentityPoster = m.top.findNode("channelIdentityPoster")
    m.channelIdentityPoster.blendColor = m.theme.EPGBoxColor
    m.channelIdentity = m.top.findNode("channelIdentity")
    m.channelIdentity.font = m.fonts.robotoReg20

    m.channelLogoBg = m.top.findNode("channelLogoBg")
    m.channelLogoBg.blendColor = m.theme.EPGBoxColor

    m.channelLogo = m.top.findNode("channelLogo")

    m.onNowBg = m.top.findNode("onNowBg")
    m.onNowBg.blendColor = m.theme.EPGBoxColor
    m.onNowLg = m.top.findNode("onNowLg")
    m.onNowTimeLg = m.top.findNode("onNowTimeLg")

    m.onNowWatchingGrp = m.top.findNode("onNowWatchingGrp")

    m.onNowTimeLabel = m.top.findNode("onNowTimeLabel")
    m.onNowTimeLabel.font = m.fonts.robotoMed24
    m.onNowTimeLabel.color = m.theme.EPGCategoryTextColor
    m.focusedOnNowTimeLabel = m.top.findNode("focusedOnNowTimeLabel")
    m.focusedOnNowTimeLabel.font = m.fonts.robotoMed24
    m.focusedOnNowTimeLabel.color = m.theme.Black
    m.programName = m.top.findNode("programName")
    m.programName.font = m.fonts.robotoMed24
    m.programName.color = m.theme.FocusedEPGCategoryTextColor
    m.focusedProgramName = m.top.findNode("focusedProgramName")
    m.focusedProgramName.font = m.fonts.robotoMed24
    m.focusedProgramName.color = m.theme.Black

    m.onNowFocusBg = m.top.findNode("onNowFocusBg")
    m.onNowFocusBg.blendColor = m.theme.MenuFocused
    m.onNowProgressFocusBg = m.top.findNode("onNowProgressFocusBg")
    m.onNowProgressFocusBg.blendColor = m.theme.EPGProgressColor
    m.focusRing = m.top.findNode("focusRing")
    m.focusRing.blendColor = m.theme.MenuFocused

    m.upNextBg = m.top.findNode("upNextBg")
    m.upNextBg.blendColor = m.theme.EPGBoxColor
    m.upNextLg = m.top.findNode("upNextLg")
    m.upNextTimeLg = m.top.findNode("upNextTimeLg")
    m.upNextTimeLabel = m.top.findNode("upNextTimeLabel")
    m.upNextTimeLabel.font = m.fonts.robotoMed24
    m.upNextTimeLabel.color = m.theme.EPGCategoryTextColor
    m.upNextProgramName = m.top.findNode("upNextProgramName")
    m.upNextProgramName.font = m.fonts.robotoMed24
    m.upNextProgramName.color = m.theme.FocusedEPGCategoryTextColor

    m.logoMask = m.top.findNode("logoMask")
    maskSize = [m.channelLogo.width,m.channelLogo.height]
    if m.global.designresolution = "720p"
        maskSize = [m.channelLogo.width/1.5,m.channelLogo.height/1.5]
    end if
    m.logoMask.maskSize = maskSize
end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild","OnFocusedChild")
end sub

sub itemContentChanged(event as dynamic)
    itemContent = event.getData()
    programData = itemContent.programData
    isLoading = itemContent.isLoading
    m.channelIdentity.text = ""
    m.channelLogo.uri = ""
    m.onNowTimeLabel.text = ""
    m.focusedOnNowTimeLabel.text = ""
    m.programName.text = ""
    m.focusedProgramName.text = ""
    m.upNextTimeLabel.text = ""
    m.upNextProgramName.text = ""
    m.onNowProgressFocusBg.width = 1
    if isLoading = invalid or not isLoading
        m.channelIdentity.text = programData.channelName
        m.channelLogo.uri = programData.logo
        updateOnNowAndUpNext(programData)
        m.onNowWatchingGrp.removeChildrenIndex(m.onNowWatchingGrp.getChildCount(), 0)
        m.watchingLabel = invalid
        m.focusedWatchingLabel = invalid
        if m.watchingLabel = invalid and programData.isWatching <> invalid and programData.isWatching
            m.watchingLabel = CreateObject("roSGNode", "Label")
            m.watchingLabel.font = m.fonts.robotoMed24
            m.watchingLabel.color = m.theme.MenuFocused
            m.watchingLabel.text = "watching  "
            m.onNowWatchingGrp.insertChild(m.watchingLabel, 0)

            m.focusedWatchingLabel = CreateObject("roSGNode", "Label")
            m.focusedWatchingLabel.font = m.fonts.robotoMed24
            m.focusedWatchingLabel.color = m.theme.Black
            m.focusedWatchingLabel.text = "watching  "
            m.focusedWatchingLabel.opacity = 0
            if m.top.itemHasFocus
                m.watchingLabel.opacity = 0
                m.focusedWatchingLabel.opacity = 1
            end if
            m.onNowWatchingGrp.insertChild(m.focusedWatchingLabel, 0)
        else
            if m.watchingLabel <> invalid then m.watchingLabel.width = 1
            if m.focusedWatchingLabel <> invalid then m.focusedWatchingLabel.width = 1
        end if
    else
        m.channelIdentity.text = programData.channelName
        m.channelLogo.uri = programData.logo
        m.programName.text = "Loading..."
        m.focusedProgramName.text = "Loading..."
        m.upNextProgramName.text = "Loading..."
    end if

end sub

sub updateOnNowAndUpNext(programData)
    limitedData = programData.limitedData
    upNextFound = false
    if limitedData <> invalid and limitedData.count() > 0
        if limitedData[0] <> invalid
            startDateObj = CreateObject("roDateTime")
            startDateObj.FromISO8601String(getGMTDate(limitedData[0].startDt))
            startDateObj.toLocalTime()
            endDateObj = CreateObject("roDateTime")
            endDateObj.FromISO8601String(getGMTDate(limitedData[0].endDt))
            endDateObj.toLocalTime()
            currentDateObj = CreateObject("roDateTime")
            currentDateObj.toLocalTime()
            if currentDateObj.AsSeconds() >= startDateObj.AsSeconds() and currentDateObj.AsSeconds() < endDateObj.AsSeconds()
                programDuration = endDateObj.AsSeconds() - startDateObj.AsSeconds()
                programLeftDuration = endDateObj.AsSeconds() - currentDateObj.AsSeconds()
                if programLeftDuration <= 0
                    percentageLeft = 0
                    programLeftDuration = 0
                else
                    percentageLeft = (programLeftDuration * 100) / programDuration
                end if

                progressBarWidth = ((100 - percentageLeft) * m.onNowBg.width) / 100
                m.onNowProgressFocusBg.width = progressBarWidth
                m.onNowTimeLabel.text = startDateObj.asTimeStringLoc("short-h12") + " - " + endDateObj.asTimeStringLoc("short-h12") + " (" + (CInt(programLeftDuration / 60)).ToStr() + " mins left)"
                m.focusedOnNowTimeLabel.text = startDateObj.asTimeStringLoc("short-h12") + " - " + endDateObj.asTimeStringLoc("short-h12") + + " (" + (CInt(programLeftDuration / 60)).ToStr() + " mins left)"
                m.programName.text = limitedData[0].title
                m.focusedProgramName.text = limitedData[0].title
            else
                ?"here no program else"
                m.programName.text = "No program found."
                m.focusedProgramName.text = "No program found."
                m.upNextTimeLabel.text = startDateObj.asTimeStringLoc("short-h12") + " - " + endDateObj.asTimeStringLoc("short-h12")
                m.upNextProgramName.text = limitedData[0].title
                upNextFound = true
            end if
        else
            m.programName.text = "No program found."
            m.focusedProgramName.text = "No program found."
        end if

        if not upNextFound
            if limitedData.count() > 1 and limitedData[1] <> invalid
                upNextStartDate = CreateObject("roDateTime")
                upNextStartDate.FromISO8601String(getGMTDate(limitedData[1].startDt))
                upNextStartDate.toLocalTime()
                upNextEndDate = CreateObject("roDateTime")
                upNextEndDate.FromISO8601String(getGMTDate(limitedData[1].endDt))
                upNextEndDate.toLocalTime()
                m.upNextTimeLabel.text = upNextStartDate.asTimeStringLoc("short-h12") + " - " + upNextEndDate.asTimeStringLoc("short-h12")
                m.upNextProgramName.text = limitedData[1].title
            else
                m.upNextProgramName.text = "No program found."
            end if
        end if
    else
        m.channelIdentity.text = programData.channelName
        m.channelLogo.uri = programData.logo
        m.programName.text = "No program found."
        m.focusedProgramName.text = "No program found."
        m.upNextProgramName.text = "No program found."
    end if
end sub

sub onFocusChanged(msg)
    if m.top.gridHasFocus
        if msg.GetData()
            m.focusRing.opacity = 1
            m.onNowFocusBg.opacity = 1
            m.onNowProgressFocusBg.opacity = 1

            m.onNowTimeLabel.opacity = 0
            m.focusedOnNowTimeLabel.opacity = 1
            m.programName.opacity = 0
            m.focusedProgramName.opacity = 1

            if m.focusedWatchingLabel <> invalid then m.focusedWatchingLabel.opacity = 1
            if m.watchingLabel <> invalid then m.watchingLabel.opacity = 0
        end if
    end if
end sub

sub onFocusPercentChange(msg)
    focusPercent = msg.GetData()
    if m.top.gridHasFocus
        m.focusRing.opacity = focusPercent
        m.onNowFocusBg.opacity = focusPercent
        m.onNowProgressFocusBg.opacity = focusPercent

        m.onNowTimeLabel.opacity = 1 - focusPercent
        m.focusedOnNowTimeLabel.opacity = focusPercent
        m.programName.opacity = 1 - focusPercent
        m.focusedProgramName.opacity = focusPercent

        if m.focusedWatchingLabel <> invalid then m.focusedWatchingLabel.opacity = focusPercent
        if m.watchingLabel <> invalid then m.watchingLabel.opacity = 1 - focusPercent
    end if
end sub

sub onGridFocusChange(msg)
    focus = msg.GetData()
    if not focus
        m.focusRing.opacity = 0
        m.onNowFocusBg.opacity = 0
        m.onNowProgressFocusBg.opacity = 0

        m.onNowTimeLabel.opacity = 1
        m.focusedOnNowTimeLabel.opacity = 0
        m.programName.opacity = 1
        m.focusedProgramName.opacity = 0

        if m.focusedWatchingLabel <> invalid then m.focusedWatchingLabel.opacity = 0
        if m.watchingLabel <> invalid then m.watchingLabel.opacity = 1
    else if focus and m.top.itemHasFocus and m.top.focusPercent
        m.focusRing.opacity = 1
        m.onNowFocusBg.opacity = 1
        m.onNowProgressFocusBg.opacity = 1

        m.onNowTimeLabel.opacity = 0
        m.focusedOnNowTimeLabel.opacity = 1
        m.programName.opacity = 0
        m.focusedProgramName.opacity = 1

        if m.focusedWatchingLabel <> invalid
            m.focusedWatchingLabel.opacity = 1
        end if
        if m.watchingLabel <> invalid
            m.watchingLabel.opacity = 0
        end if
    end if
end sub