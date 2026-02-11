
sub init()
    m.top.id = "UpdateProgramProgressTask"
end sub

sub UpdateProgress()
    epgContent = m.top.epgGridContent
    if epgContent <> invalid and epgContent.getChildCount() > 0
        itemCount = -1
        for i = 0 to epgContent.getChildCount() - 1
            category = epgContent.getChild(i)
            if category <> invalid
                for j = 0 to category.getChildCount() - 1
                    itemCount++
                    programObj = category.getChild(j)
                    programObj.programData = updateLimitedData(programObj.programData)
                end for
            end if
        end for
    end if
    m.top.progressUpdated = true
end sub

function updateLimitedData(programData) as object 
    limitedData = programData.limitedData
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
            if currentDateObj.AsSeconds() >= startDateObj.AsSeconds()
                programDuration = endDateObj.AsSeconds() - startDateObj.AsSeconds()
                programLeftDuration = endDateObj.AsSeconds() - currentDateObj.AsSeconds()
                if programLeftDuration <= 0
                    percentageLeft = 0
                    programLeftDuration = 0
                    limitedData.Shift()
                end if
            end if
        end if
    end if
    programData.limitedData = limitedData
    return programData
end function


