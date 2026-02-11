sub setGlobalNode(fontManager)
    appConfig = getAppConfigFromFile()
    deviceInfo = createObject("roDeviceInfo")
    appInfo = CreateObject("roAppInfo")

    globalFields = {
        appConfig: appConfig
        designResolution: deviceInfo.GetDisplayMode()
        appTheme: getAppThemeFromFile()
        menuList: []
        localMenuList: [],
        ' apiEndPoints: getApiEndPoints(appConfig.baseUrl + appConfig.rokuJsonVersion)
        apiEndPoints: getApiEndPoints(appConfig)
        vastUrl: appConfig.vastUrl
        fonts: fontManager
        DeviceUniqueId: deviceInfo.GetChannelClientId()
        UserLanguage: deviceInfo.GetCurrentLocale()
        DisplaySize: deviceInfo.GetDisplaySize()
        AppVersion: appInfo.GetVersion()
        AppTitle: appInfo.GetTitle()
        userSellingOrSharingPreference: true
    }
    m.global.addFields(globalFields)
end sub

sub getAppConfigFromFile() as dynamic
    print "Globals : getAppConfigFromFile "
    config = ReadAsciiFile("pkg:/source/data/appConfig.json")
    configJson = ParseJson(config)
    if configJson <> invalid
        if configJson.isProduction
            configJson.segmentWriteKey = configJson.prodSegmentWriteKey
        else
            configJson.segmentWriteKey = configJson.devSegmentWriteKey
        end if
        
        configJson.baseUrl = Substitute(configJson.baseUrl, configJson.channel_id)
        print "Globals : getAppConfigFromFile : App config file loaded : " config
    else
        print "*** Error : Globals : getAppConfigFromFile : Invalid configuration"
    end if

    return configJson
end sub

sub getAppThemeFromFile() as dynamic
    print "Globals : getAppThemeFromFile "
    theme = ReadAsciiFile("pkg:/source/data/appTheme.json")
    themeJson = ParseJson(theme)
    if themeJson <> invalid
        print "Globals : getAppThemeFromFile : App Theme file loaded : " ' config
    else
        print "*** Error : Globals : getAppThemeFromFile : Invalid theme configuration!"
    end if

    return themeJson
end sub

sub getApiEndPoints(appconfig as dynamic) as dynamic
    print "Globals : getApiEndPoints : baseUrl : " appconfig
    baseURL = appconfig.baseUrl + appConfig.rokuJsonVersion
    apiEndPoints = {
        HBCUData: baseURL
        SettingsData: appconfig.baseUrl + "legal_pages"
        HBCUTabData: baseURL + "/tab/"
        HBCUSearchData: baseURL + "/search?search="
    }
    return apiEndPoints
end sub

sub GlobalSet(key as string, entity as dynamic)
    if (type(entity) = invalid)
        print "*** Utilities ERROR *** GlobalSet"
    else
        if (m.global.hasField(key))
            m.global.setField(key, entity)
        else
            obj = {}
            obj[key] = entity
            m.global.addFields(obj)
        end if
    end if
end sub

function GlobalGet(key as string, default = invalid as dynamic) as dynamic
    if (m.global.hasField(key))
        return m.global.getField(key)
    else
        return default
    end if
end function


function GetVersion() as object
    displaySize = CreateObject("roAppInfo").GetVersion()
    return displaySize
end function

function GetTitle() as object
    appName = CreateObject("roAppInfo").GetTitle()
    return appName
end function
