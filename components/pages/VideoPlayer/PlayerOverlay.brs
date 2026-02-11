sub init()
    SetLocals()
    SetControls()
    SetObservers()
    initilize()
end sub
'
sub SetLocals()
    m.scene = m.top.GetScene()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.initConfig = m.global.InitConfigs
end sub
'
sub SetControls()
    m.pVideoOverlayBackground = m.top.findNode("pVideoOverlayBackground")
    m.mainOverlayGroup = m.top.findNode("mainOverlayGroup")
    m.gPauseVideoOverlay = m.top.findNode("gPauseVideoOverlay")
    m.lgDetails = m.top.findNode("lgDetails")
    m.progress = m.top.findNode("progress")
    m.leftProgressLabel = m.top.findNode("leftProgressLabel")
    m.outlineRect = m.top.findNode("outlineRect")
    m.progressRect = m.top.findNode("progressRect")
    m.pSeekingDot = m.top.findNode("pSeekingDot")
    m.rightProgressLabel = m.top.findNode("rightProgressLabel")
    m.PlayPauseIcon = m.top.findNode("PlayPauseIcon")
    m.lPlayPause = m.top.findNode("lPlayPause")
    m.pRewindIcon = m.top.findNode("pRewindIcon")
    m.lrewind = m.top.findNode("lrewind")
    m.lfastforward = m.top.findNode("lfastforward")
    m.pForwardIcon = m.top.findNode("pForwardIcon")
end sub

sub SetObservers()
    m.top.observeField("visible", "onVisibleChange")
end sub

sub initilize()
    m.progressWidth = m.outlineRect.width
    m.videoDuration = 0
    m.trickPosition = 0
    m.trickOffset = 0

    m.trickPlayTimer = createObject("roSGNode", "Timer")
    m.trickPlayTimer.duration = 1
    m.trickPlayTimer.repeat = True
    m.trickPlayTimer.observeField("fire", "handleTrickPlayTimer")

    m.singleSeeking = false
    m.progressBarPosition = 0

    ResetData()
    SetupColor()
    SetupFonts()
end sub

sub SetupColor()
    m.progressRect.blendColor = m.theme.FocusedListBackground
    m.outlineRect.blendColor = m.theme.ProgressBar
    m.leftProgressLabel.color = m.theme.Progress
    m.rightProgressLabel.color = m.theme.Progress

    m.pForwardIcon.blendColor = m.theme.ThemeColor
    m.pRewindIcon.blendColor = m.theme.ThemeColor
end sub

sub SetupFonts()
    m.leftProgressLabel.font = m.fonts.robotoMed30
    m.rightProgressLabel.font = m.fonts.robotoMed30
    m.lPlayPause.font = m.fonts.robotoMed30
    m.lrewind.font = m.fonts.robotoMed30
    m.lfastforward.font = m.fonts.robotoMed30
end sub

sub onVisibleChange()
    if m.top.visible = true then
        UpdateIconState()
        showProgressBar(m.position)
    else
        m.trickPlayTimer.control = "STOP"
    end if
end sub

sub IsLiveChanged(event as dynamic)
    isLive = event.GetData()
    if isLive = true then
        m.progress.visible = false
    else
        m.progress.visible = true
    end if
end sub

sub OnVideoDurationChanged(event as dynamic)
    m.duration = event.GetData()
    if m.duration <> invalid then
        m.videoDuration = m.duration
        m.rightProgressLabel.text = FormatTime(m.videoDuration, true)
    end if
end sub

sub OnTrailerVideoPlay(event as dynamic)
    isTrailer = event.GetData()
    if isTrailer
        m.videoDuration = 00
        m.rightProgressLabel.text = FormatTime(m.videoDuration, true)
    end if
end sub

sub OnVideoParamsChanged(event as dynamic)
    videoParams = event.getData()
    if videoParams <> invalid then
        m.videoDuration = videoParams.duration.ToInt()
        UpdateDetails()
    end if
    if not m.top.isTrailer
        m.rightProgressLabel.text = FormatTime(videoParams.duration.toInt(), true)
    end if
end sub

sub UpdateDetails()
    childNode = m.top.videoParams
    if childNode <> invalid
        title = ""
        description = ""

        if (childNode.Title <> invalid and childNode.Title <> "")
            title = childNode.Title
        end if
        if (childNode.Description <> invalid and childNode.Description <> "")
            description = childNode.Description
        end if
        if childNode.limitedData <> invalid
            onNowData = getOnNowData(childNode.limitedData)
            if onNowData <> invalid and onNowData.title <> invalid
                title = onNowData.title
            end if
        end if
        if m.lvideoTitle = invalid or (m.lvideoTitle.text <> title)
            m.lgDetails.removeChild(m.lvideoTitle)
            m.lgDetails.removeChild(m.lvideoDescription)

            if (title <> invalid and title <> "")
                m.lvideoTitle = createObject("roSGNode", "Label")
                m.lvideoTitle.id = "lvideoTitle"
                m.lvideoTitle.width="1500"
                m.lvideoTitle.wrap="true"
                m.lvideoTitle.maxLines="1"
                m.lvideoTitle.lineSpacing="0"
                m.lvideoTitle.text = title.trim()
                m.lvideoTitle.color = m.theme.AntiFlashWhite
                m.lvideoTitle.font = m.fonts.robotomed66
                m.lgDetails.appendChild(m.lvideoTitle)
            end if

            if (description <> invalid and description <> "")
                m.lvideoDescription = createObject("roSGNode", "Label")
                m.lvideoDescription.id = "lvideoDescription"
                m.lvideoDescription.width="1500"
                m.lvideoDescription.wrap="true"
                m.lvideoDescription.maxLines="2"
                m.lvideoDescription.lineSpacing="0"
                m.lvideoDescription.text = description.trim()
                m.lvideoTitle.color = m.theme.Progress
                m.lvideoDescription.font = m.fonts.robotoMed30
                m.lgDetails.appendChild(m.lvideoDescription)
            end if
        end if
    end if
end sub

sub ResetData()
    m.progressBarPosition = 0
    m.videoDuration = 0
    m.PlayPauseIcon.uri = "pkg:/images/icons/pause.png"
    m.lPlayPause.text = "Pause"
    m.progressRect.width = 0
    m.progressRect.visible = false
    m.top.seekingStatus = ""
    m.top.videoPlayerState = ""
    resetSeekLogic()
end sub

Function resetSeekLogic()
    m.trickPlaySpeed = 0
    m.trickOffset = 0
    m.trickPlayTimer.duration = 1
    m.trickInterval = 15
    m.trickSingleOffset = 0
    m.singleSeeking = false
    m.lrewind.text = ""
    m.lfastforward.text = ""
    m.pRewindIcon.visible = false
    m.pForwardIcon.visible = false
    UpdateIconState()
end Function

Function isSeeking() as boolean
    return m.trickPlaySpeed <> 0 or m.trickOffset <> 0 or m.trickSingleOffset <> 0
end Function

Function startSeeking()
    PauseVideo()
    m.trickPlayTimer.control = "STOP"

    if m.trickPlaySpeed <> 0
        m.trickPlayTimer.duration = 1 / abs(m.trickPlaySpeed)
        m.trickPlayTimer.control = "START"
    else
        m.TrickPlayTimer.duration = 1
    end if
end Function

Function endSeeking(shouldSeek = true as boolean, isSingleSeeking = false as boolean)
    m.trickPlayTimer.control = "STOP"
    if shouldSeek = true then
        m.top.seekPosition = m.progressBarPosition
        m.position = m.progressBarPosition
    else
        m.progressBarPosition = m.position
        m.top.seekPosition = -1
    end if
    if not isSingleSeeking then m.top.seekingStatus = "STOPPED"
    resetSeekLogic()
end Function

sub OnVideoPositionChanged(event as dynamic)
    m.position = event.getData()
    UpdateDetails()
    showProgressBar(m.position)
end sub

sub ActionOnPlay()
    if (m.top.videoPlayerState = "playing") then
        m.top.action = {
            userAction : "PAUSED",
            videoPosition : m.position
        }
    else
        m.top.action = {
            userAction : "PLAYED",
            videoPosition : m.position
        }
    end if
end sub

sub OnUserAction(event as dynamic)
    params = event.getData()
    if not IsNullOrEmpty(params.userAction) then
        if params.userAction = "PAUSED" then
            m.PlayPauseIcon.uri = "pkg:/images/icons/play.png"
            m.lPlayPause.text = "Play"
            If(m.progressBarPosition > 0 And params.videoPosition <> m.progressBarPosition And isSeeking())
                showProgressBar(m.progressBarPosition)
            Else
                showProgressBar(params.videoPosition)
            End If
        else if params.userAction = "PLAYED" then
            m.PlayPauseIcon.uri = "pkg:/images/icons/pause.png"
            m.lPlayPause.text = "Pause"
            resetSeekLogic()
        end if
    end if
end sub

sub UpdateIconState()
  if (m.top.videoPlayerState = "paused") then
      m.PlayPauseIcon.uri = "pkg:/images/icons/play.png"
      m.lPlayPause.text = "Play"
  else
      m.PlayPauseIcon.uri = "pkg:/images/icons/pause.png"
      m.lPlayPause.text = "Pause"
  end if
end sub

Function showProgressBar(position)
    if (m.videoDuration <> 0)
        m.progressBarPosition = position
        m.progressRect.width = position * m.progressWidth / m.videoDuration

        leftPositionSeconds = position * 100 / 100
        m.leftProgressLabel.text = FormatTime(leftPositionSeconds, true)
        m.pSeekingDot.translation = [127 + m.progressRect.width - 6, 13]
        if isSeeking()
            m.PlayPauseIcon.uri = "pkg:/images/icons/play.png"
            m.lPlayPause.text = "Play"
        end if
        if (m.progressRect.width = 0)
            m.progressRect.visible = false
        else
            m.progressRect.visible = true
        end if
    end if
end Function

Function handleSingleSeeking(direction as string)
  if direction = "right"
      if m.progressBarPosition + 15 <= m.videoDuration
          m.trickSingleOffset = 15
      else
          m.trickSingleOffset = m.videoDuration - m.progressBarPosition ' Seek to t = duration
      end if
  else if direction = "left"
      if m.progressBarPosition - 15 >= 0
          m.trickSingleOffset = 15 * -1
      else
          m.trickSingleOffset = m.progressBarPosition * -1
      end if
  end if

  showProgressBar(m.progressBarPosition + m.trickSingleOffset)
  if ((m.progressBarPosition <= 0 and direction = "left") or (m.progressBarPosition >= m.videoDuration and direction = "right")) then
      UpdateProgress()
  end if
  endSeeking(true, true)
end Function
'
Function handleTrickPlayTimer()
    if m.trickPlaySpeed > 0
        if m.progressBarPosition + m.trickInterval <= m.videoDuration
            m.trickOffset = m.trickInterval
        else
            m.trickOffset = m.videoDuration - m.progressBarPosition
        end if
    else if m.trickPlaySpeed < 0
        if m.progressBarPosition - m.trickInterval >= 0
            m.trickOffset = m.trickInterval * -1
        else
            m.trickOffset = m.progressBarPosition * -1
        end if
    end if
    showProgressBar(m.progressBarPosition + m.trickOffset)
    if ((m.progressBarPosition <= 0 and m.trickPlaySpeed < 0) or (m.progressBarPosition >= m.videoDuration and m.trickPlaySpeed > 0)) then
        UpdateProgress()
    end if
end Function

sub UpdateProgress()
    if isSeeking()
        endSeeking()
    end if
end sub

Sub PauseVideo()
    m.top.pauseVideo = true
End Sub

sub SetSeekInterval()
    if m.trickPlaySpeed = 1 or m.trickPlaySpeed = -1 then
        m.trickInterval = 30
    else if m.trickPlaySpeed = 2 or m.trickPlaySpeed = -2 then
        m.trickInterval = 60
    else if m.trickPlaySpeed = 3 or m.trickPlaySpeed = -3 then
        m.trickInterval = 90
    else
        m.trickInterval = 15
    end if
end sub

function OnCustomPlayerKeyPress(msg)
    data = msg.getData()
    onKeyEvent(data.key, data.press)
end function

function onKeyEvent(key as string, press as boolean) as boolean
    result = false
    print "PlayerOverlay : onKeyEvent : key = " key " press = " press
    if (press)
        if (key = "play" or key = "OK" or (key = "back" and isSeeking()))
            m.lrewind.text = ""
            m.lfastforward.text = ""
            m.pRewindIcon.visible = false
            m.pForwardIcon.visible = false
            if m.top.isLive = false and m.top.isTrailer = false and isSeeking()
                endSeeking()
                ActionOnPlay()
            end if
        else if (key = "up")
            result = true
        else if (key = "down")
            result = true
        else if (key = "back") then
            m.trickPlayTimer.control = "STOP"
        else if (m.top.isLive = false and m.top.isTrailer = false and (key = "fastforward" or key = "rewind"))
            m.singleSeeking = false
            m.top.seekingStatus = "STARTED"
            position = m.progressBarPosition
            if key = "fastforward"
                m.lrewind.text = ""
                m.pRewindIcon.visible = false
                m.trickPlaySpeed++
                if m.trickPlaySpeed > 3 or m.trickPlaySpeed <= 0
                    m.trickPlaySpeed = 1
                end if
                m.lfastforward.text = m.trickPlaySpeed.toStr() + "x"
                m.pForwardIcon.visible = true
                SetSeekInterval()
            else if key = "rewind"
                m.lfastforward.text = ""
                m.pForwardIcon.visible = false
                m.trickPlaySpeed--
                if m.trickPlaySpeed < -3 or m.trickPlaySpeed >= 0
                    m.trickPlaySpeed = -1
                end if
                trickPlaySpeed = m.trickPlaySpeed.toStr()
                trickPlay = trickPlaySpeed.Split("-")
                m.lrewind.text = trickPlay[1] + "x"
                m.pRewindIcon.visible = true
                SetSeekInterval()
            end if
            if position <= m.videoDuration and position >= 0
              showProgressBar(position)
              startSeeking()
            end if
            result = true
        else if (m.top.isLive = false and m.top.isTrailer = false and (key = "right" or key = "left"))
            m.singleSeeking = true
            m.top.seekingStatus = "STARTED"
            m.trickPlayTimer.control = "stop"
            m.trickPlaySpeed = 0
            handleSingleSeeking(key)
            result = true
        end if
    end if
    return result
end function
