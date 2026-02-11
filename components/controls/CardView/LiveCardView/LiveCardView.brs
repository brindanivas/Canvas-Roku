sub init()
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColor()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
end sub

sub SetControls()
    m.pLive = m.top.findNode("pLive")
    m.pPlayicon = m.top.findNode("pPlayicon")
    m.lTitle = m.top.findNode("lTitle")
    m.lDescription = m.top.findNode("lDescription")
    m.borderMask = m.top.findNode("borderMask")
    m.rProgressBar = m.top.findNode("rProgressBar")
    m.rProgressBarFill = m.top.findNode("rProgressBarFill")

    If m.global.designresolution = "720p"
        m.rProgressBar.uri="pkg:/images/focus/5pxRoundHDRect.9.png"
        m.rProgressBarFill.uri="pkg:/images/focus/5pxRoundHDRect.9.png"
        m.rProgressBar.height="6"
        m.rProgressBarFill.height="6"
    Else
        m.rProgressBar.uri="pkg:/images/focus/5pxRoundRect.9.png"
        m.rProgressBarFill.uri="pkg:/images/focus/5pxRoundRect.9.png"
        m.rProgressBar.height="9"
        m.rProgressBarFill.height="9"
    End If

    m.gBadge = m.top.findNode("gBadge")
    m.pBadge = m.top.findNode("pBadge")
    m.lBadgeText = m.top.findNode("lBadgeText")
    m.lgInformation = m.top.findNode("lgInformation")
end sub

sub SetupFonts()
    m.lTitle.font = m.fonts.robotoBold30
    m.lDescription.font = m.fonts.robotoReg24
    m.lBadgeText.font = m.fonts.robotoMed24

end sub

sub SetupColor()
    m.lTitle.color = m.theme.CardTitle
    m.lDescription.color = m.theme.CardSubtitle
    m.lBadgeText.color = m.theme.ThemeColor
    m.rProgressBar.blendColor = m.theme.ProgressBar
    m.rProgressBarFill.blendColor = m.theme.ThemeColor
end sub

sub itemContentChanged(event as dynamic)
    content = event.getData()
    if content.poster_16_9_small <> invalid and  content.poster_16_9_small <> ""
        m.pLive.uri = content.poster_16_9_small
    else 
        m.pLive.uri = content.poster_16_9
    end if
    m.lTitle.text = content.title.trim()
    SetBadge(content)
    m.lDescription.text = ""

    date = CreateObject("roDateTime")
    date.ToLocalTime()
    currentTimeInSec = date.AsSeconds()
    startTimeInSec = 0
    endTimeInSec = 0
    if content.start_date_time <> invalid and content.start_date_time <> ""
        date.FromISO8601String(content.start_date_time)
        startTimeInSec = date.AsSeconds()
        'm.lDescription.text += " | " +GetDescriptionTime(date)
        m.lDescription.text = GetDescriptionTime(date)
    end if
    if content.end_date_time <> invalid and content.end_date_time <> ""
        date.FromISO8601String(content.end_date_time)
        endTimeInSec = date.AsSeconds()
    end if

    perProgress = 0
    totalEventTime = endTimeInSec - startTimeInSec
    if content.start_date_time <> invalid AND content.start_date_time <> "" AND content.end_date_time <> invalid AND content.end_date_time <> ""
        if totalEventTime > 0 and startTimeInSec < currentTimeInSec and currentTimeInSec < endTimeInSec
            position = currentTimeInSec - startTimeInSec
            if position > 0
                progress = (100 * position / totalEventTime)
                perProgress = (550 * progress / 100)
                m.rProgressBarFill.width = perProgress
            end if
        else if currentTimeInSec > endTimeInSec
            ' To show full event'
            'm.rProgressBarFill.width = 550
        else
            m.rProgressBarFill.width = 0
        end if
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

    ' print "Event .rProgressBarFill.width > " m.rProgressBarFill.width

    boudingRect = m.pLive.boundingRect()
    maskSize = [boudingRect.width, boudingRect.height]
    if m.global.designresolution = "720p"
        maskSize = [maskSize[0]/1.5,maskSize[1]/1.5]
    end if
    m.borderMask.maskSize = maskSize
end sub

function onFocusPercentChange()
    if m.top.gridHasFocus or m.top.rowListHasFocus
        num = 1 + (m.top.focusPercent * 0.1 )
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
            num = 1 + (m.top.focusPercent * 0.1 )
            itemFocused(num)
        end if
    end if
end sub

sub itemFocused(percent as Float)
    m.pPlayicon.opacity = m.top.focusPercent
    if not m.top.gridHasFocus and not m.top.rowListHasFocus
        m.pPlayicon.opacity = 0
    else
    end if
end sub



sub onRowFocusPercentChange()
    ' print "onRowFocusPercentChange "event.getData()
end sub

sub onRowListFocusChange()
    if not m.top.rowListHasFocus
        itemFocused(1)
    else
        if m.top.focusPercent = 1
            num = 1 + (m.top.focusPercent * 0.1 )
            itemFocused(num)
        end if
    end if
end sub

function SetBadge(content)
    date = CreateObject("roDateTime")
    date.ToLocalTime()
    currentTimeInSec = date.AsSeconds()

    totalSecondsToday = (date.GetHours() * 60 + date.GetMinutes()) * 60 + date.GetSeconds()
    totalSecondsInADay = 86400
    remainingSecondsInTodayUntilEnd = 86400 - totalSecondsToday

    ' print "remainingSecondsInTodayUntilEnd ==> " remainingSecondsInTodayUntilEnd
    startTimeInSec = invalid
    endTimeInSec = invalid
    m.lBadgeText.text = ""
    m.pBadge.uri = ""
    m.gBadge.visible = false
    if content.start_date_time <> invalid and content.start_date_time <> ""
        date.FromISO8601String(content.start_date_time)
        startTimeInSec = date.AsSeconds()
    end if

    ' content.start_date_time = "2022-08-26T07:14:00+00:00"
    ' content.end_date_time   = "2022-08-26T07:14:00+00:00"

    if content.end_date_time <> invalid and content.end_date_time <> ""
        date.FromISO8601String(content.end_date_time)
        endTimeInSec = date.AsSeconds()
    end if
    if startTimeInSec <> invalid and endTimeInSec <> invalid
        if (startTimeInSec <= currentTimeInSec AND currentTimeInSec < endTimeInSec)
            m.lBadgeText.text = "ON NOW"
            m.pBadge.uri = "pkg:/images/icons/live-now.png"
        else if (startTimeInSec > currentTimeInSec AND (startTimeInSec < (currentTimeInSec + remainingSecondsInTodayUntilEnd)))
            m.lBadgeText.text = "TODAY"
            m.pBadge.uri = "pkg:/images/icons/live-upcomming.png"
        else if (startTimeInSec > currentTimeInSec AND (startTimeInSec < (currentTimeInSec + remainingSecondsInTodayUntilEnd + totalSecondsInADay)))
            m.lBadgeText.text = "TOMORROW"
            m.pBadge.uri = "pkg:/images/icons/live-upcomming.png"
        end if
    end if
    if not IsNullOrEmpty(m.lBadgeText.text)
        m.gBadge.visible = true
        groupBoundingRect = m.gBadge.boundingRect()
        m.gBadge.translation = [560 - groupBoundingRect.width - 15, 315 - groupBoundingRect.height - 25]
    end if
end function

function GetDescriptionTime(date)
      startDate = date.AsDateString("short-month-no-weekday")
      hours = date.GetHours()
      minutes = date.GetMinutes()
      hourText = ""
      minuteText = ""
      amPmText = ""
      if hours < 12
        if hours = 0
          hourText = "12"
        else if hours < 10
          hourText = "0"+hours.ToStr()
        else
          hourText = hours.ToStr()
        end if
        amPmText = "AM"
      else
        if hours = 12
          hourText = hours.ToStr()
        else
          hourText = (hours - 12).ToStr()
        end if
        amPmText = "PM"
      end if
      if minutes < 10
        minuteText = "0" + minutes.ToStr()
      else
        minuteText = minutes.ToStr()
      end if
      return startDate + " • " + hourText + ":" + minuteText + " "+ amPmText
end function
