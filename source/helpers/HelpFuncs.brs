function IsNullOrEmpty(s as dynamic) as boolean
    return s = invalid or s = ""
end function

function ok(data as dynamic) as object
    result = {}
    result.ok = true
    result.data = data

    return result
end function

function error(data as string) as object
    result = {}
    result.ok = false
    result.error = data

    return result
end function

function getErrorReason(response as dynamic) as string
    unknown = "Unknown error. Please check your input, internet connection and try again"
    print "HelpFuncs : getErrorReason : ResponseError : " response
    if (response.reason.Len() = 0 )
        return unknown
    else
        if (response.code = 422 or response.code = 403 or response.code = 404)
            data = ParseJSON(response.reason)
						if data = invalid 'If, this is not json
								return response.reason
						end if

						msg = ""
						if data.message <> invalid
								msg = data.message
						else if data.detail <> invalid
								msg = data.detail
						end if

            return msg
        else
            return response.reason
        end if
    end if
end function

function FindMatchingItemIndexFromArray(array as object, itemName as string, itemValue as dynamic) as integer
    index = -1
    for each item in array
        index = index + 1
        if item[itemName] <> invalid and item[itemName] = itemValue
            return index
        end if
    end for
    return -1
end function

function GetTimeDifference(content) as integer
    date = CreateObject("roDateTime")
    date.ToLocalTime()
    currentTimeInSec = date.AsSeconds()
    currentDate = date.GetDayOfMonth()
    currentMonth = date.GetMonth()
    currentYear = date.GetYear()
    totalTime = ""
    if content.start_date_time <> invalid and content.start_date_time <> ""
        date.FromISO8601String(content.start_date_time)
        startTimeInSec = date.AsSeconds()
        startDate = date.GetDayOfMonth()
        startMonth = date.GetMonth()
        startYear = date.GetYear()
    end if

    if content.end_date_time <> invalid and content.end_date_time <> ""
        date.FromISO8601String(content.end_date_time)
        endTimeInSec = date.AsSeconds()
    end if

    if startTimeInSec < currentTimeInSec and currentTimeInSec < endTimeInSec
        if currentTimeInSec < endTimeInSec
            totalTime = endTimeInSec - currentTimeInSec
        else
            totalTime = currentTimeInSec - startTimeInSec
        end if
    else if currentDate + 1 = startDate and currentMonth = startMonth and currentYear = startYear
        totalTime = startTimeInSec - currentTimeInSec
    else if currentTimeInSec < startTimeInSec
        totalTime = startTimeInSec - currentTimeInSec
    else
        totalTime = currentTimeInSec - startTimeInSec
    end if
    return totalTime
end function

sub getOnNowData(programData) as dynamic
    if programData <> invalid and programData.count() > 0
        programIndex = -1
        for each program in programData
            startDateObj = CreateObject("roDateTime")
            startDateObj.FromISO8601String(getGMTDate(program.startDt))
            startDateObj.toLocalTime()
            endDateObj = CreateObject("roDateTime")
            endDateObj.FromISO8601String(getGMTDate(program.endDt))
            endDateObj.toLocalTime()
            currentDateObj = CreateObject("roDateTime")
            currentDateObj.toLocalTime()
            programIndex++
            if currentDateObj.AsSeconds() >= startDateObj.AsSeconds() and currentDateObj.AsSeconds() < endDateObj.AsSeconds()
                return program
                exit for
            end if
        end for
    end if
    return invalid
end sub

function getChannelOnNowAndUpNextData(programData) as object
    maxHourLimitForChannelProgram = 24
    limitedData = []
    if programData <> invalid and programData.count() > 0
        programIndex = -1
        onNowFound = false
        for each program in programData
            startDateObj = CreateObject("roDateTime")
            startDateObj.FromISO8601String(getGMTDate(program.startDt))
            startDateObj.toLocalTime()
            endDateObj = CreateObject("roDateTime")
            endDateObj.FromISO8601String(getGMTDate(program.endDt))
            endDateObj.toLocalTime()
            currentDateObj = CreateObject("roDateTime")
            currentDateObj.toLocalTime()
            programIndex++
            if endDateObj.AsSeconds() >= currentDateObj.AsSeconds()
                if currentDateObj.AsSeconds() >= startDateObj.AsSeconds() and currentDateObj.AsSeconds() < endDateObj.AsSeconds()
                    limitedData.push(program)
                    onNowFound = true
                    ' exit for
                else if currentDateObj.AsSeconds() <= startDateObj.AsSeconds() and startDateObj.AsSeconds() <= (currentDateObj.AsSeconds() + (maxHourLimitForChannelProgram * 60 * 60))
                    limitedData.push(program)
                else
                    exit for
                end if
            end if
        end for
    end if
    return limitedData
end function

function getGMTDate(timeStamp) as String
    finalStr = ""
    if timeStamp.Instr("-") > 2 and (Left(Right(timeStamp, 5), 1) = "+" or Left(Right(timeStamp, 5), 1) = "-")
        dateObj = CreateObject("roDateTime")
        dateObj.FromISO8601String(timeStamp)
        dateSecs = dateObj.AsSeconds()
        offsetStr = timeStamp.Right(5)
        offsetHrsDifference = offsetStr.Mid(1,2)
        offsetMinDifference = offsetStr.Mid(3,2)
        offsetSign = offsetStr.Left(1)
        if offsetSign = "+"
            dateSecs -= (offsetHrsDifference.ToInt() * 60 * 60) + (offsetMinDifference.ToInt() * 60)
            dateObj.FromSeconds(dateSecs)
        else if offsetSign = "-"
            dateSecs += (offsetHrsDifference.ToInt() * 60 * 60) + (offsetMinDifference.ToInt() * 60)
            dateObj.FromSeconds(dateSecs)
        end if
        finalStr = dateObj.ToISOString()
    else
        yearStr = timeStamp.Left(4)
        monthStr = timeStamp.Mid(4,2)
        dateStr = timeStamp.Mid(6,2)
        remainingStr = timeStamp.Mid(8, Len(timeStamp))
        remainingStr = remainingStr.replace(" ", "")
        hrStr = remainingStr.Mid(0,2)
        minStr = remainingStr.Mid(2,2)
        secStr = remainingStr.Mid(4,2)
        offsetStr = remainingStr.Mid(6,Len(remainingStr))
        offsetHrsDifference = offsetStr.Mid(1,2)
        offsetMinDifference = offsetStr.Mid(3,2)
        offsetSign = offsetStr.Left(1)
        finalStr = yearStr + "-" + monthStr + "-" + dateStr + "T" + hrStr + ":" + minStr + ":" + secStr + offsetStr
        dateObj = CreateObject("roDateTime")
        dateObj.FromISO8601String(finalStr)
        dateSecs = dateObj.AsSeconds()
        if offsetSign = "+"
            dateSecs -= (offsetHrsDifference.ToInt() * 60 * 60) + (offsetMinDifference.ToInt() * 60)
            dateObj.FromSeconds(dateSecs)
        else if offsetSign = "-"
            dateSecs += (offsetHrsDifference.ToInt() * 60 * 60) + (offsetMinDifference.ToInt() * 60)
            dateObj.FromSeconds(dateSecs)
        end if
        finalStr = dateObj.ToISOString()
    end if
    return finalStr
end function

Function GetAllBookmarkData() As object
    sec = CreateObject("roRegistrySection", "Bookmarks")
    allKeys = sec.GetKeyList()
    return allKeys
End Function

Function GetBookmarkData(id as string) As Integer
    sec = CreateObject("roRegistrySection", "Bookmarks")
    if sec.Exists("Bookmark_" + id)
        return sec.Read("Bookmark_" + id).ToInt()
    end if
    return 0
End Function

Function SetBookmarkData(id as string, position as String) As Integer
    sec = CreateObject("roRegistrySection", "Bookmarks")
    sec.Write("Bookmark_" + id, position)
    sec.Flush()
End Function

Function FormatTime(timeInSecond as integer,fullTimeFormat = false as boolean) as String
    if (timeInSecond <> invalid)
				timeInSecond = timeInSecond
        timeInSecond = timeInSecond MOD (24 * 3600)
        hours = timeInSecond \ 3600
        timeInSecond = timeInSecond MOD 3600
        minutes = timeInSecond \ 60
        timeInSecond = timeInSecond MOD 60
        seconds = timeInSecond

        hrStr = hours.toStr()
        minutesStr = minutes.toStr()
        secondsStr = seconds.toStr()

        if (hours < 10)
          hrStr = "0" + hrStr
        end if
        if (minutes < 10)
          minutesStr = "0" + minutesStr
        end if
        if (seconds < 10)
          secondsStr = "0" + secondsStr
        end if
        if(fullTimeFormat = false) then
            if(hrStr = "00" and minutesStr = "00")
                return minutesStr + ":" + secondsStr
            else
                return hrStr + ":" + minutesStr
            end if
        else
            return hrStr + ":" + minutesStr + ":" + secondsStr
        end if
    else
        return ""
    end if
End Function

Function GetOsVersion() as string
    version = createObject("roDeviceInfo").GetOSVersion()
    return version.major + "." + version.minor + "." + version.revision + "." + version.build
end Function

Function GetAppVersions() as string
    manifest = GetManifestsAsAA()

    major = manifest.major_version
    minor = manifest.minor_version
    build = manifest.build_version

    return major + "." + minor + "."+ build
end Function

Function GetDeviceModel() as string
    model = createObject("roDeviceInfo").GetModel()
    displayName = createObject("roDeviceInfo").GetModelDisplayName()
    deviceModelName = model + " - " + displayName
    return deviceModelName
end Function

Function GetDeviceDisplaySize() as object
    displaySize = createObject("roDeviceInfo").GetDisplaySize()
    return displaySize
end Function

Function GetUniqueId() as string
    deviceUniqueId = createObject("roDeviceInfo").GetChannelClientId()
    return deviceUniqueId
end Function

function checkLimitAdTracking() as boolean
    dev_info = createObject("roDeviceInfo")
    isLimitAdTracking = dev_info.IsRIDADisabled()
    return isLimitAdTracking
end function

function GetRIDA() as string
    dev_info = createObject("roDeviceInfo")
    advertisingID = dev_info.GetRIDA()
    return advertisingID
end function

Function GetExternalIpAddress() as string
    ip = createObject("roDeviceInfo").GetExternalIp()
    return ip
end Function

Function GetConnectionType() as string
    connectionType = createObject("roDeviceInfo").GetConnectionType()
    return connectionType
end Function

Function GetUserAgent() as string
    osVersion = GetOsVersion()
    appVersion = GetAppVersions()
    deviceModel = GetDeviceModel()
    userAgentName = ""
    if m.global.appConfig <> invalid and m.global.appConfig.registryPrefix <> invalid and m.global.appConfig.registryPrefix <> ""
        registryPrefix = m.global.appConfig.registryPrefix
        userAgentName = UCase(m.global.appConfig.registryPrefix)
    end if
    userAgent = "Roku/"+osVersion+userAgentName+"/"+appVersion+" "+deviceModel
    return userAgent
end Function

' MANIFEST FUNCTIONS
Function GetManifestsAsAA() As Object
    manifest = {}

    text = ReadAsciiFile("pkg:/manifest")

    lines = text.Tokenize( Chr( 10 ) )

    for each line in lines
        line = line.Trim()
        if (line.Len() = 0)
            '** empty line
        else if (line.Left( 1 ) = "#")
            '** comment line
        else
            sepPos = line.Instr( "=" )
            if (sepPos <= 0)
                '** invalid
            else
                name = line.Mid( 0, sepPos )
                value = line.Mid( sepPos + 1 )
                manifest.AddReplace( name, value )
            end if
        end if
    end for

    return manifest
End Function


Function getAdID() as String
    advertisingID = ""
    dev_info = createObject("roDeviceInfo")
    if not dev_info.IsRIDADisabled()
        advertisingID = dev_info.GetRIDA()
    end if
    return advertisingID
End Function

Function getAdsAppID() as String
    dev_info = createObject("roDeviceInfo")
    return dev_info.GetChannelClientId()
End Function

Function getAppUniqueChannelID() as String
    dev_info = createObject("roDeviceInfo")
    return dev_info.GetChannelClientId()
End Function

function GetSegmentVideoStateEventString(state as dynamic) as string
    ' print "GetSegmentVideoStateEventString ================================================================> " state
    eventStr = ""
    if (state = "appInstalled")
        eventStr = "Application Installed"
    else if (state = "appOpened")
        eventStr = "Application Opened"
    else if (state = "playingHeartBeat")
        eventStr = "Video HeartBeat"
    end if
    ' print "eventStr ====================================================================== : " eventStr
    return eventStr
end function

function getGPPValues() as string
    gppString = ""
    regSection = CreateObject("roRegistrySection", "GPP")
    if regSection.exists("IABGPP_HDR_GppString") then
        gppString = regSection.read("IABGPP_HDR_GppString")
    end if
    return gppString
end function

function getGPPSIDValues() as string
    gppSid = ""
    regSection = CreateObject("roRegistrySection", "GPP")
    if regSection.exists("IABGPP_GppSID") then
        gppSid = regSection.read("IABGPP_GppSID")
    end if
    return gppSid
end function