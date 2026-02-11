function getSaveLogConsentdata(viewData, consentData)
    data = {
        method: "POST",
        name: "saveLogConsent" 
        body: getPayload(viewData, consentData),
        headers:  m.global.OT_Data["headers"],
        functionName: "fetchApi"     
    }
    return data
end function

function getPayload(viewData, consentData)
    data = {
        "interactionType": viewData.interactionType,
        "userAgent": ""
    }
    if data.interactionType.Instr("_CONFIRM") <> -1
        data["consent"] = {
            "purposesStatus":  getStatusData(consentData.purposesStatus),
            "iabVendorsStatus": getStatusData(consentData.iabVendorsStatus),
            "googleVendorsStatus": getStatusData(consentData.googleVendorsStatus),
            "sdkStatus": getStatusData(consentData.sdkStatus)
        }
    end if
    return data
end function

function getStatusData(data)
    purposesStatus = []
    if data <> invalid and data.count()
        for each item in data.items()
            purposesStatus.push(item.value)
        end for
    end if
    return purposesStatus
end function

'function userAgent()
'    data = ""
'    request = CreateObject("roUrlTransfer")
'    if FindMemberFunction(request, "GetUserAgent") <> invalid then data = request.GetUserAgent()
'    return data
'end function