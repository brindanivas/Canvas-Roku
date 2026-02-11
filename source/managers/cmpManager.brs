sub cmp_setupOneTrust()
    try
        m.configRegionCode = invalid
        ' Create a global handle to the SDK
        print "[MainScene] INFO : CMP SETUP ONETRUST..."
        m.global.Addfield("OTsdk", "node", false)
        m.global.OTsdk = CreateObject("roSGNode", "OTinitialize")

        ' Start SDK with params
        sdkParams = getOTsdkParams()
        m.global.OTsdk.callFunc("startSDK", sdkParams)

        ' Set event listeners
        m.global.OTsdk.eventlistener.observeField("dataDownloadSucess", "onDataSuccess")
        m.global.OTsdk.eventlistener.observeField("OTConsentUpdated", "onContentUpdate")
        m.global.OTsdk.eventlistener.observeField("onShowPreferenceCenter", "onPcShown")
        m.global.OTsdk.eventlistener.observeField("onShowPreferenceCenter",      "onOTUiEvent")
        m.global.OTsdk.eventlistener.observeField("onPreferenceCenterAcceptAll", "onOTUiEvent")
        m.global.OTsdk.eventlistener.observeField("onPreferenceCenterRejectAll", "onOTUiEvent")
        m.global.OTsdk.eventlistener.observeField("onPreferenceCenterConfirmChoices", "onOTUiEvent")
        m.global.OTsdk.eventlistener.observeField("onHidePreferenceCenter",      "onOTUiEvent")
        m.global.OTsdk.eventlistener.observeField("allSDKViewsDismissed",        "onOTUiEvent")
        m.global.OTsdk.eventlistener.observeField("OTConsentUpdated",            "onOTConsentUpdated")



        ' Setup UI only once after SDK initialized
        ' Register where OneTrust UI will mount (don’t show anything yet)
         m.global.OTsdk.callFunc("setupUI", { view: m.top })

    catch e
        print "Error in cmp_setupOneTrust(): "; e
    end try
end sub

function onDataSuccess(event as dynamic)
    print "onDataSuccess: "; event.GetData()
    ' print "onDataSuccess: "; event.GetData().success.storageKeys.OT_GroupConsents
    ' print "onDataSuccess: "; event.GetData().success.storageKeys.OT_SdkConsents

    print "Get Subject Identifier :===========> " m.global.OTsdk.callFunc("getCurrentActiveProfile")
     ' Check consent status for specific group ID
    if m.global.OTsdk.callFunc("getConsentStatusForGroupID", "BG121") = 1 then
        m.global.userSellingOrSharingPreference = true
    else
        m.global.userSellingOrSharingPreference = false
    end if

    shouldShow = m.global.OTsdk.callFunc("shouldShowBanner")
    print "shouldShowBanner: "; shouldShow
    value = ""
    key = "IABUSPrivacy_String"
    regSection = CreateObject("roRegistrySection", "TCF")
    if regSection.exists(key) then
        value = regSection.read(key)
    end if
    GlobalSet("USPrivacy_String", value)
    print "CCPA / US Privacy String: "; value
    if m.SettingPage = invalid
        if shouldShow then
            m.global.OTsdk.callFunc("showBannerUI")
        else
            startApp()
        end if
    end if
end function

sub onOTConsentUpdated(event as dynamic)
    print "onOTConsentUpdated: "; event.GetData().success.storageKeys.OT_GroupConsents
    ' Consent data has changed, app can read new values
    ' Read consent values from storage keys
    value = ""
    key = "IABUSPrivacy_String"
    regSection = CreateObject("roRegistrySection", "TCF")
    if regSection.exists(key) then
        value = regSection.read(key)
    end if
    GlobalSet("USPrivacy_String", value)
    print "CCPA / US Privacy String: "; value

    value = ""
    key = "OT_GroupConsents"
    regSection = CreateObject("roRegistrySection", "OneTrust")
    if regSection.exists(key) then
        value = regSection.read(key)
    end if
    print "OT_GroupConsents: "; value

    value = ""
    key = "OT_SdkConsents"
    regSection = CreateObject("roRegistrySection", "OneTrust")
    if regSection.exists(key) then
        value = regSection.read(key)
    end if
    print "OT_SdkConsents: "; value
    ' Check consent status for specific group ID
    if m.global.OTsdk.callFunc("getConsentStatusForGroupID", "BG121") = 1 then
        m.global.userSellingOrSharingPreference = true
    else
        m.global.userSellingOrSharingPreference = false
        if m.global.MMAnalytics <> invalid
            m.global.MMAnalytics.control = "STOP"
            m.global.MMAnalytics = invalid
        end if
    end if

end sub

function getOTsdkParams() as object
    sdkParams = {}
    lang = CreateObject("roDeviceInfo").GetCurrentLocale()
    countryCode = CreateObject("roDeviceInfo").GetCountryCode()
    if lang <> invalid and lang <> ""
        langCode =  lang.Left(2)
    else
         langCode = "en"
    end if
    if m.global.OTsdk <> invalid then sdkParams = m.global.OTsdk.callFunc("OTSdkParams")

    oneTrustAppId = ""
    oneTrustVersion = ""
    if (m.appConfig <> invalid and (m.appConfig.oneTrustAppId <> invalid and m.appConfig.oneTrustAppId <> ""))
        oneTrustAppId = m.appConfig.oneTrustAppId
    end if
    if (m.appConfig <> invalid and (m.appConfig.oneTrustVersion <> invalid and m.appConfig.oneTrustVersion <> ""))
        oneTrustVersion = m.appConfig.oneTrustVersion
    end if
    sdkParams.applicationId = oneTrustAppId
    sdkParams.version = oneTrustVersion
    sdkParams.location = "cdn.cookielaw.org"
    sdkParams.language = langCode
    sdkParams.countryCode = countryCode ' optional
    ' sdkParams.identifier = CreateObject("roDeviceInfo").GetChannelClientId()
    return sdkParams
end function
