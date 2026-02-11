function HBCUAPI()
    gThis = GetGlobalAA()
    if gThis.HBCUAPI = invalid
        gThis.HBCUAPI = HBCUAPI__New()
    end if
    return gThis.HBCUAPI
end function

function HBCUAPI__New()
    this = {}
    this.GetHBCUData = HBCUAPI__GetHBCUData
    this.GetSettingsData = HBCUAPI__GetSettingsData
    this.GetHBCUTabData = HBCUAPI__GetHBCUTabData
    this.GetHBCUTabPlayListData = HBCUAPI__GetHBCUTabPlayListData
    this.GetHBCUTabPlayListSeriesData = HBCUAPI__GetHBCUTabPlayListSeriesData
    this.GetHBCUSeriesEpisodesData = HBCUAPI__GetHBCUSeriesEpisodesData
    this.GetHBCUSearchData = HBCUAPI__GetHBCUSearchData
    this.GetHBCUVastData = HBCUAPI__GetHBCUVastData
    this.GetHBCUEPGData = HBCUAPI__GetHBCUEPGData
    this.GetHBCUChannelData = HBCUAPI__GetHBCUChannelData
    return this
end function


function HBCUAPI__GetHBCUData()
    path = GlobalGet("apiEndPoints").HBCUData

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetSettingsData()
    path = GlobalGet("apiEndPoints").SettingsData

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetSettingsData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetSettingsData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetSettingsData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUTabData(tabId as integer)
    path = GlobalGet("apiEndPoints").HBCUTabData + tabId.tostr()

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUTabData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUTabData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUTabData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUTabPlayListData(tabId as integer, playListId as string, pageNo as integer)
    path = GlobalGet("apiEndPoints").HBCUTabData + tabId.tostr() + "/" + playListId + "/all?per_page=" + GlobalGet("appConfig").perPageVideos.tostr() + "&page=" + pageNo.tostr()

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUTabData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUTabData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUTabData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUTabPlayListSeriesData(tabId as integer, playListId as string, pageNo as integer)
    path = GlobalGet("apiEndPoints").HBCUTabData + tabId.tostr() + "/" + playListId + "/series?per_page=" + GlobalGet("appConfig").perPageVideos.tostr() + "&page=" + pageNo.tostr()

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUTabData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUTabData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUTabData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUSeriesEpisodesData(tabId as integer, playListId as string, seriesId as string, pageNo as integer)
    path = GlobalGet("apiEndPoints").HBCUTabData + tabId.tostr() + "/" + playListId + "/series/" + seriesId + "/episode?per_page=" + GlobalGet("appConfig").perPageVideos.tostr() + "&page=" + pageNo.tostr()

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUSeriesEpisodesData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUSeriesEpisodesData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUSeriesEpisodesData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUSearchData(SearchString as string, request as dynamic)
    path = GlobalGet("apiEndPoints").HBCUSearchData + SearchString.tostr() + "&type=" + request.searchType + "&per_page=" + GlobalGet("appConfig").perPageVideos.tostr() + "&page=" + request.pageNo.tostr()

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUSearchData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUSearchData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUSearchData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUVastData(replacedVastUrl as string)
    path = replacedVastUrl

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUVastData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUVastData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUVastData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUEPGData(tabId as string)
    path = GlobalGet("apiEndPoints").HBCUTabData + "/" + tabId

    headers = GetHeaders()

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUVastData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUVastData : Succeeded."
        return ok(ParseJSON(response.response))
    else
        ' print "HBCUAPI : GetHBCUVastData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function HBCUAPI__GetHBCUChannelData(xmlUri)
    path = xmlUri

    headers = {
    }

    data = {
    }

    response = getRequest(path, data, headers)
    ' print "HBCUAPI : GetHBCUVastData : response : " response
    if (response.isSuccess)
        ' print "HBCUAPI : GetHBCUVastData : Succeeded."
        return ok(response.response)
    else
        ' print "HBCUAPI : GetHBCUVastData : Failed."
        return error(getErrorReason(response))
    end if

    return response
end function

function GetHeaders()
    headers = {
        "Accept": "application/json"
        "Content-Type": "application/json",
        "AppVersion": GetAppVersions()
        "DeviceID": CreateObject("roDeviceInfo").GetChannelClientId()
    }
    return headers
end function
