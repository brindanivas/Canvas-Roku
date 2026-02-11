function isValid(value)
    return not (value = invalid or type(value) = "roInvalid")
end function

function isString(value)
    return isStringType(value) and value.Trim() <> ""
end function

function isStringType(value)
    return isValid(value) and (type(value) = "String" or type(value) = "roString")
end function

function isArray(value) as Boolean
    return isValid(value) and type(value) = "roArray"
end function

function isBoolean(value)
    return isValid(value) and value
end function

' Custom function for optional chaining
function optionalChaining(obj as object, properties as string) as dynamic
    error = invalid
    currentObj = invalid
    try
        if obj <> invalid
            propertyList = properties.split(".")
            currentObj = obj

            for each property in propertyList
                if currentObj = invalid
                    return invalid
                end if
                currentObj = currentObj[property]
            end for
        end if
    catch e
        error = e
    end try
    if error <> invalid then return invalid
    return currentObj
end function

function timeUtil() as object

    util = {

        _timers: {}

        log: function(msg)
            print msg
        end function

        time: function(eventName as string)
            m._startTimer(eventName.trim())
            m.log(eventName + ": timer started")
        end function

        timeEnd: function(eventName)
            ellapsedTime = m._endTimer(eventName.trim())
            if ellapsedTime <> invalid then m.log(eventName + ": " + ellapsedTime + "ms")
        end function

        _startTimer: function(event as string)
            m._timers[event] = createObject("roTimespan")
        end function

        _endTimer: function(event as string) as dynamic
            if m._timers[event] = invalid then return invalid
            eventTime = m._timers[event].totalMilliseconds().toStr()
            m._timers.delete(event)
            return eventTime
        end function
    }

    return util

end function

function getDeviceInfo(data)
    error = invalid
    try
        deviceData = CreateObject("roDeviceInfo")
        if data = "osVersion" and FindMemberFunction(deviceData, "GetOSVersion") <> invalid
            osData = deviceData.GetOSVersion()
            return Val(osData["major"] + "." + osData["minor"])
        end if
    catch e
        error = e
    end try
    if error <> invalid then return invalid
end function

function verifyMultistyleLabel()
    osVersion = getDeviceInfo("osVersion")
    multiStyleLabel = true
    if osVersion = invalid or osVersion < 10.5 then multiStyleLabel = false
    return multiStyleLabel
end function

function checkAllPurposeUpdatedSync() as boolean
    sdkData = m.global._OT_initialize_data
    if sdkData.profile.doesExist("sync") and sdkData.profile.sync.keys().count() > 0
        m.registry.write("allPurposesUpdatedAfterSync", sdkData.profile.sync.allPurposesUpdatedAfterSync.tostr())
        m.logger.set(m.errortype.info, m.errorTags.OneTrust, m.constant.info["727"], sdkData.profile.sync.allPurposesUpdatedAfterSync)
        return sdkData.profile.sync.allPurposesUpdatedAfterSync
    else
        allPurposesUpdatedAfterSync = m.registry.read("allPurposesUpdatedAfterSync")
        return allPurposesUpdatedAfterSync = "true"
    end if
    return false
end function
