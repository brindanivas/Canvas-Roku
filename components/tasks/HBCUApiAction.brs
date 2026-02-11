sub Init()
end sub

function GetHBCUData() as void
    response = HBCUAPI().GetHBCUData()
    m.top.result = response
end function

function GetSettingsData() as void
    response = HBCUAPI().GetSettingsData()
    m.top.result = response
end function

function GetHBCUTabData() as void
    response = HBCUAPI().GetHBCUTabData(m.top.requestData.tabId)
    m.top.result = response
end function

function GetHBCUTabPlayListData() as void
    contentType = "video"
    if m.top.requestData.contentType <> invalid
        contentType = m.top.requestData.contentType
    end if
    response = HBCUAPI().GetHBCUTabPlayListData(m.top.requestData.tabId, m.top.requestData.playlistId, m.top.requestData.pageNo)
    m.top.result = response
end function

function GetHBCUTabPlayListSeriesData() as void
    response = HBCUAPI().GetHBCUTabPlayListSeriesData(m.top.requestData.tabId, m.top.requestData.playlistId, m.top.requestData.pageNo)
    m.top.result = response
end function

function GetHBCUSeriesEpisodesData() as void
    response = HBCUAPI().GetHBCUSeriesEpisodesData(m.top.requestData.tabId, m.top.requestData.playlistId, m.top.requestData.seriesId, m.top.requestData.pageNo)
    m.top.result = response
end function

function GetHBCUSearchData() as void
    response = HBCUAPI().GetHBCUSearchData(m.top.searchData, m.top.requestData)
    m.top.result = response
end function

function GetHBCUVastData() as void
    response = HBCUAPI().GetHBCUVastData(m.top.replacedVastUrl)
    m.top.result = response
end function

function GetHBCUEPGData() as void
    response = HBCUAPI().GetHBCUEPGData(m.top.tabId)
    m.top.result = response
end function

function GetHBCUChannelData() as void
    response = HBCUAPI().GetHBCUChannelData(m.top.xmlUri)
    m.top.result = GetProgram(response)
end function

function GetProgram(response) as object
    objChannel = {}
    taskObj = m.top
    if response <> invalid and response.ok and response.data <> invalid
        responseXML = ParseXML(response.data)
        if responseXML <> invalid then
            responseXML = responseXML.GetChildElements()
        end if
        objChannel["liveUrl"] = taskObj.program.URL
        objChannel["channelName"] = taskObj.program.name
        objChannel["logo"] = taskObj.program.channel_imagery
        objChannel["sectionName"] = taskObj.sectionName
        objChannel["sectionIndex"] = taskObj.positionObj.sectionIndex
        objChannel["channelIndex"] = taskObj.positionObj.channelIndex
        objChannel["isLoading"] = false
        objChannel["isWatching"] = false
        arrProgram = []
        for each xmlItem in responseXML
            objProgram = {}
            xmlItemName = xmlItem.GetName()
            m.xmlItemChild = xmlItem.GetBody()
            if xmlItemName <> invalid and xmlItemName = "programme"
                objProgram["title"] = CheckFieldName("title")
                ThumbnailUrl = invalid
                ThumbnailUrl =  CheckFieldName("icon")
                if ThumbnailUrl <> invalid
                    objProgram["ThumbnailUrl"] = ThumbnailUrl.src
                else
                    objProgram["ThumbnailUrl"] = CheckFieldName("ThumbnailUrl")
                end if
                objProgram["description"] = CheckFieldName("desc")
                dateAttribute = xmlItem.GetAttributes()
                objProgram["startDt"] = dateAttribute.start
                objProgram["endDt"] = dateAttribute.stop
                objChannel["channelId"] = dateAttribute.channel
                objProgram.["hls_url"] = taskObj.program.URL
                arrProgram.push(objProgram)
            end if
        end for
        if arrProgram.count () > 0
            objChannel["programs"] = arrProgram
            objChannel["limitedData"] = getChannelOnNowAndUpNextData(arrProgram)
        else
            objChannel["programs"] = invalid
            objChannel["limitedData"] = invalid
        end if
    else
        objChannel["liveUrl"] = taskObj.program.URL
        objChannel["channelName"] = taskObj.program.name
        objChannel["logo"] = taskObj.program.channel_imagery
        objChannel["sectionName"] = taskObj.sectionName
        objChannel["sectionIndex"] = taskObj.positionObj.sectionIndex
        objChannel["channelIndex"] = taskObj.positionObj.channelIndex
        objChannel["programs"] = invalid
        objChannel["limitedData"] = invalid
        objChannel["isWatching"] = false
        objChannel["isLoading"] = false
    end if
    return objChannel
end function

Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml=CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function

Function CheckFieldName(fieldName as string)
    strFieldData = invalid
    for each xmlItemChildElement in m.xmlItemChild
        if xmlItemChildElement.GetName() = fieldName and Type(xmlItemChildElement.GetName()) = "String"
            strFieldData = xmlItemChildElement.GetBody()
            if strFieldData = "" or strFieldData = invalid
                strFieldData = xmlItemChildElement.GetAttributes()
            end if
        end if
    end for
    return strFieldData
end function