sub init()
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColor()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.appConfig = m.global.appConfig
end sub

sub SetControls()
    m.gVideo = m.top.findNode("gVideo")
    m.pVideo = m.top.findNode("pVideo")
    m.lTitle = m.top.findNode("lTitle")
    m.pPlayicon = m.top.findNode("pPlayicon")
    m.pVideoLock = m.top.findNode("pVideoLock")
    m.lDescription = m.top.findNode("lDescription")
    m.lProgressDuration = m.top.findNode("lProgressDuration")
    m.borderMask = m.top.findNode("borderMask")
    m.rProgressBar = m.top.findNode("rProgressBar")
    m.rProgressBarFill = m.top.findNode("rProgressBarFill")

    m.gSeries = m.top.findNode("gSeries")
    m.borderMaskSeries = m.top.findNode("borderMaskSeries")
    m.pSeries = m.top.findNode("pSeries")
    m.pSeriesLock = m.top.findNode("pSeriesLock")
    m.pShadowSeries = m.top.findNode("pShadowSeries")

    if m.appConfig.showDetailPageForVideo = true
        m.pPlayicon.visible = false
    else
        m.pPlayicon.visible = true
    end if

    if m.global.designresolution = "720p"
        m.rProgressBar.uri = "pkg:/images/focus/5pxRoundHDRect.9.png"
        m.rProgressBarFill.uri = "pkg:/images/focus/5pxRoundHDRect.9.png"
        m.rProgressBar.height = "6"
        m.rProgressBarFill.height = "6"
    else
        m.rProgressBar.uri = "pkg:/images/focus/5pxRoundRect.9.png"
        m.rProgressBarFill.uri = "pkg:/images/focus/5pxRoundRect.9.png"
        m.rProgressBar.height = "9"
        m.rProgressBarFill.height = "9"
    end if

    m.lgInformation = m.top.findNode("lgInformation")
end sub

sub SetupFonts()
    m.lTitle.font = m.fonts.robotoBold30
    m.lDescription.font = m.fonts.robotoReg24
    m.lProgressDuration.font = m.fonts.robotoMed30
end sub

sub SetupColor()
    m.lTitle.color = m.theme.CardTitle
    m.lDescription.color = m.theme.CardSubtitle
    m.lProgressDuration.color = m.theme.White

    m.rProgressBar.blendColor = m.theme.ProgressBar
    m.rProgressBarFill.blendColor = m.theme.ThemeColor
end sub

sub itemContentChanged(event as dynamic)
    content = event.getData()
    m.gVideo.visible = false
    m.gSeries.visible = false
    m.lTitle.text = content.title.trim()
    m.lDescription.text = content.description.trim()

    if content <> invalid and content.program_type = "series"
        m.gSeries.visible = true
        m.pSeries.uri = content.featured_image
        if content.poster_16_9_small <> invalid and  content.poster_16_9_small <> ""
            m.pSeries.uri = content.poster_16_9_small
        else 
            m.pSeries.uri = content.poster_16_9
        end if
        m.pPlayicon.visible = false
        m.pSeriesLock.visible = content.is_lock
        boudingRect = m.pVideo.boundingRect()
        maskSize = [boudingRect.width, boudingRect.height]
        if m.global.designresolution = "720p"
            maskSize = [maskSize[0] / 1.5, maskSize[1] / 1.5]
        end if
        m.borderMaskSeries.maskSize = maskSize
    else
        m.gVideo.visible = true
        if content.poster_16_9_small <> invalid and  content.poster_16_9_small <> ""
            m.pVideo.uri = content.poster_16_9_small
        else 
            m.pVideo.uri = content.poster_16_9
        end if
        m.pVideoLock.visible = content.is_lock
        SetProgressDuration(content)
        'TODO : Set proper progress value'
        perProgress = 0
        regProgress = GetBookmarkData(content._id.toStr())
        if regProgress <> invalid AND regProgress > 0 AND content.duration <> "" AND content.duration <> "0"
            progress = (100 * regProgress / content.duration.toInt())
            perProgress = (550 * progress / 100)
            if perProgress > 550
                m.rProgressBarFill.width = 0
            else
                m.rProgressBarFill.width = perProgress
            end if

            if (m.rProgressBarFill.width > 10)
                m.rProgressBar.visible = true
                m.rProgressBarFill.visible = true
            else if (m.rProgressBarFill.width > 0)
                m.rProgressBarFill.width = 10
                m.rProgressBar.visible = true
                m.rProgressBarFill.visible = true
            else
                m.rProgressBar.visible = false
                m.rProgressBarFill.visible = false
            end if
        else
            m.rProgressBar.visible = false
            m.rProgressBarFill.visible = false
        end if
        ' m.rProgressBarFill.width = RND(550)
        boudingRect = m.pVideo.boundingRect()
        maskSize = [boudingRect.width, boudingRect.height]
        if m.global.designresolution = "720p"
            maskSize = [maskSize[0] / 1.5, maskSize[1] / 1.5]
        end if
        m.borderMask.maskSize = maskSize
    end if
end sub


''
' Use focusPercent to scale the poster
''
function onFocusPercentChange()
    if m.top.gridHasFocus or m.top.rowListHasFocus
        num = 1 + (m.top.focusPercent * 0.1)
        itemFocused(num)
    else
        itemFocused(1)
    end if
end function

function onFocusChanged()
end function


''
' handle focus when markupgrid has focus
''
sub onGridFocusChange()
    if not m.top.gridHasFocus
        itemFocused(1)
    else
        if m.top.focusPercent = 1
            num = 1 + (m.top.focusPercent * 0.1)
            itemFocused(num)
        end if
    end if
end sub

sub itemFocused(percent as float)
    m.pPlayicon.opacity = m.top.focusPercent
    if not m.top.gridHasFocus and not m.top.rowListHasFocus
        m.pPlayicon.opacity = 0
    end if
end sub

sub onRowListFocusChange()
    if not m.top.rowListHasFocus
        itemFocused(1)
    else
        if m.top.focusPercent = 1
            num = 1 + (m.top.focusPercent * 0.1)
            itemFocused(num)
        end if
    end if
end sub


sub SetProgressDuration(content)
    m.lProgressDuration.visible = false
    duration = content.duration
    durationText = ""
    if duration <> invalid and duration <> ""
        duration = duration.ToInt()
        hourText = ""
        minuteText = ""
        secondText = ""
        hour = 0
        remainingDuration = duration
        hourSecond = (60 * 60)
        minuteSecond = 60

        if remainingDuration > hourSecond
            hour = FIX(remainingDuration / hourSecond)
            remainingDuration = remainingDuration - (hour * hourSecond)
            if hour < 10 then
                hourText = "0" + hour.ToStr()
            else
                hourText = hour.ToStr()
            end if
            durationText = hourText
        end if

        if remainingDuration > (remainingDuration - minuteSecond)
            minute = FIX(remainingDuration / minuteSecond)
            remainingDuration = remainingDuration - (minute * minuteSecond)
            if minute < 10 then
                minuteText = "0" + minute.ToStr()
            else
                minuteText = minute.ToStr()
            end if
            if durationText <> "" then
                durationText += ":" + minuteText
            else
                durationText = minuteText
            end if
        end if

        if remainingDuration > 0
            second = remainingDuration
            if second < 10 then
                secondText = "0" + second.ToStr()
            else
                secondText = second.ToStr()
            end if
            if durationText <> "" then
                durationText += ":" + secondText
            else
                durationText = secondText
            end if
        end if
        if durationText <> ""
            m.lProgressDuration.text = durationText
            m.lProgressDuration.visible = true
            boundingRect = m.lProgressDuration.boundingRect()
            m.lProgressDuration.translation = [560 - boundingRect.width - 15, 315 - boundingRect.height - 25]
        end if
    end if
end sub
