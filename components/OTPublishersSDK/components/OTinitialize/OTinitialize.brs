function init()
    m.registry = RegistryUtil()
    m.constant = applicationConstants()
    m.errortype = getErrorType()
    m.errorTags = getErrorTags()
    m.logger = logUtil()
    setfullScreenResolution()
    m.OTinitializeViewModel = CreateObject("roSGNode", "OTinitializeViewModel")

    m.top.eventlistener = CreateObject("roSGNode", "OTEventliseners")

     m.OTinitializeViewModel.eventlistener.observeField("dataDownloadSucess", "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELB115"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELB105"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELB101"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELB102"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELB106"], "eventlistener")

     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP115"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP110"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP101"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP102"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP103"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP107"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP105"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP104"], "eventlistener")
     

     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP116"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELV100"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELV101"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELV102"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELV103"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELV107"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELV108"], "eventlistener")

     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELP117"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELS100"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELS101"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELS102"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELS103"], "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField(m.constant.listener["ELS104"], "eventlistener")

     m.OTinitializeViewModel.eventlistener.observeField("allSDKViewsDismissed", "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField("OTConsentUpdated", "eventlistener")

     m.OTinitializeViewModel.eventlistener.observeField("onDeleteProfileCallback", "eventlistener")
     m.OTinitializeViewModel.eventlistener.observeField("onSwitchUserProfileCallback", "eventlistener")
end function

 ' Starts the OT SDK, downloads data and returns the response required to create OT SDK UI.
    ' - Parameters:
    '   - location: Contains the storage location from where data has to be fetched (ex: "cdn.cookielaw.org").
    '   - identifier: Containins unique Domain Identifier to be passed (ex: "5376c4e0-8367-450c-8669-a0d41bed69ac").
    '   - language: Contains valid ISO Language code for langauge for which localized data has be fetched (ex: "en")
    '   - params: Optional parameter containing additional SDK parameters like country, region code, syncProfileAuth parameters etc.
    ' - Note: This call would fail if there are internet connectivity issues, invalid storage url/domain-Identifier/language-code is passed.
    ' - Note: Starting 202503.2.0, this API will only download Banner data.
function startSDK(params as object)
    return m.OTinitializeViewModel.callFunc("startSDK", params)
end function

' OTSdkParams will return the SDK params
function OTSdkParams() as object
    return m.OTinitializeViewModel.callFunc("OTSdkParams")
end function

' Use this API to clear all the OT SDK data.
function clearOTSDK()
    return m.OTinitializeViewModel.callFunc("clearOTSDK")
end function

' Switches the profile based on the identifier passed.
' - Parameter DSID: The identifier of the profile to be loaded.
' - Parameter completion: The completion observable that will be triggered at the end of the profile switch operation.
' - Note: If the data is missing, SDK will throw an error.
' - Note: Please make sure that startSDK call is complete before calling this API.
function switchUserProfile(DSID as string)
    return m.OTinitializeViewModel.callFunc("switchUserProfile", DSID)
end function

' Deletes the profile and its associated storage from OT SDK.
' - Parameter DSID: The identifier of the profile to be deleted.
' - Parameter completion: The completion observable that will be triggered after deleting a profile.
' - Note: Please make sure that startSDK call is complete before calling this API.
function deleteProfile(DSID as string)
    return m.OTinitializeViewModel.callFunc("deleteProfile", DSID)
end function

' Renames the profile storage from the current profile identifier to the new one.
' - Parameters:
'   - oldDSID: The current identifier of the profile. If no profile identifier is passed, current profile identifier will be updated to new identifier.
'   - newDSID: The new identifier to which the profile ID should be changed to.
'   - completion: Completion observable that will be triggered once the rename operation is complete. The boolean status determines if the renaming was successful or not.
'   - Note: Please make sure that startSDK call is complete before calling this API.
function renameProfile(oldDSID as string, newDSID = invalid as dynamic)
    return m.OTinitializeViewModel.callFunc("renameProfile", oldDSID, newDSID)
end function

' This API sets up the OT SDK UI and checks if the UI needs to be shown and presents the UI based on this check.
' Call this method on application's main view controller.
    ' - Parameters: data = { view: view, type: banner}
    '   - view: The View Controller of the application on which the OT SDK UI will be presented.
    '   - type: Represents the various types of OT SDK UI that can be presented using this API. Whatever type is passed here, will be displayed if the conditions are satisfied.
    ' - Note: This API uses the `shouldShowBanner` logic to determine if the OT SDK UI should be shown to the user.
    ' - Note: Starting 202503.2.0, if a valid UI Type is passed, OneTrust SDK will check if corresponding data already exists and if it does not exist, it will make a network call to Cmp Api to download that data and then display the corresponding UI.
function setupUI(data as object) as void
    m.OTinitializeViewModel.callFunc("setupUI", data)
end function

' This API will display the OT SDK Banner UI.
' Please call this method only after setupUI() method has been called atleast once in the current app launch.
' Please make sure that the OT SDK Data is downloaded prior to calling this API.
' - Note: This method doesn't consider value of `shouldShowBanner`.
' - Note: Starting 202504.1.0, OneTrust SDK will check if Banner data already exists
function showBannerUI()
    return m.OTinitializeViewModel.callFunc("showBannerUI")
end function

' This API will display the OT SDK Preference Center UI.
' Please call this method only after setupUI() method has been called atleast once in the current app launch.
' Please make sure that the OT SDK Data is downloaded prior to calling this API.
' - Note: This method doesn't consider value of `shouldShowBanner`.
' - Note: Starting 202503.2.0, OneTrust SDK will check if Preference Center data already exists and if it does not exist, it will make a network call to Preferences Cmp Api to download that data and then display the UI.
function showPreferenceCenterUI()
    return m.OTinitializeViewModel.callFunc("showPreferenceCenterUI")
end function

 ' Retrieves all the data needed to construct the OT SDK Banner UI.
' - Note: The keys will not be the same when Cmp Api is enabled vs disabled.
' - Note: Starting 202503.2.0, this API will return banner data only if Banner data is already downloaded by the OneTrust SDK locally.
function getBannerData()
    return m.OTinitializeViewModel.callFunc("getBannerData")
end function

' Retrieves all the data needed to construct the OT SDK Preference Center UI.
' - Note: The keys will not be the same when Cmp Api is enabled vs disabled.
' - Note: Starting 202503.2.0, this API will return preference center data only if Preference Center data is already downloaded by the OneTrust SDK locally.
function getPreferenceCenterData()
    return m.OTinitializeViewModel.callFunc("getPreferenceCenterData")
end function

' Determines if OT SDK Banner/Preference center was presented to user at least once.
' This method will support only if SDK UI methods are used.
' - Returns: 1 if Banner/Preference Center shown
'            0 if Banner/Preference Center was not shown yet (implied consent)
'            -1 if SDK not initialized yet
'            2 if consent taken using profile syncing
function isBannerShown()
    return m.OTinitializeViewModel.callFunc("isBannerShown")
end function

' Retrieves the Saved consent value for specified group (purpose/category) identifier.
' - Parameter categoryId: The group represented as a string, for which consent value has to be returned.
' - Returns: Integer value representing the consent status of the passed in category identifier.
' - Note: This API will return -1 if the passed in group identifier is not valid.
function getConsentStatusForGroupID(groupId as string) as integer
    return m.OTinitializeViewModel.callFunc("getConsentStatusForGroupID", groupId)
end function

' Retrieves the Saved consent value for specified SDK's linked to (purpose/category) identifier.
' - Parameter skdId: The skdID represented as a string, for which consent value has to be returned.
' - Returns: Integer value representing the consent status of the passed in SDK (purpose/category).
' - Note: This API will return -1 if the passed in group identifier is not valid.
function getConsentStatusForSDKId(skdId as string) as integer
    return m.OTinitializeViewModel.callFunc("getConsentStatusForSDKId", skdId)
end function

' Retrieves the Saved consent value for specified vendors.
' - Parameter vendorId: The vendorId represented as a string, for which consent value has to be returned.
'           - OTVendorListMode: which mode of consent status can be retived. ex: iab, google.
' - Returns: Integer value representing the consent status of the passed in vendor.
' - Note: This API will return -1 if the passed in group identifier is not valid.
function getConsentStatusForVendorId(OTVendorListMode as string, vendorId as string) as integer
    return m.OTinitializeViewModel.callFunc("getConsentStatusForVendorId", OTVendorListMode, vendorId)
end function

' Determines if OT SDK UI should be displayed for a user location.
' - Returns: Return boolean true if OT SDK UI should be shown, else returns false.
function shouldShowBanner()
    return m.OTinitializeViewModel.callFunc("shouldShowBanner")
end function

' Method to get vendor count configured for a particular purpose.
' - Parameter customGroupId: String, group id for which vendors have been assigned to. It can be a parent group id like Stack or an individual group like an IAB purpose.
' - Returns: Int, count from saved object, 0 (no vendors configured), -1(error cases) are the possible values.
' - Note: Starting 202503.2.0, this API will return vendor count only if Preference Center and Vendors data is already downloaded by the OneTrust SDK locally.
function getVendorCount(customGroupId as string)
    return m.OTinitializeViewModel.callFunc("getVendorCount", customGroupId)
end function

' Retrieves all the data needed to construct the OT SDK vendor UI.
' - Note: The keys will not be the same when Cmp Api is enabled vs disabled.
' - Note: Starting 202503.2.0, this API will return vendor data only if vendor data is already downloaded by the OneTrust SDK locally.
function getVendorListData()
    return m.OTinitializeViewModel.callFunc("getVendorListData")
end function

' it returns the current active profile indentifier
function getCurrentActiveProfile()
    return m.OTinitializeViewModel.callFunc("getCurrentActiveProfile")
end function

' Saves the consent of the application based on the interaction type passed, and triggers notifications for the same.
' - Parameter :
'   - interactionType: The interaction type associated with the consent.
'   - completion: The completion observable that gets called once the saving is complete.
' - Note: Consent will not be logged to server when interaction type is preference center close.
function saveConsent(interactionType as string)
    return m.OTinitializeViewModel.callFunc("saveConsent", interactionType)
end function

' Updates the consent value for a specified group (purpose/category) identifier.
' - Parameters:
'   - id: The group represented as a string, for which consent value has to be updated.
'   - status: Boolean value specifying updated consent value.
function updatePurposeConsent(id as string, status as boolean)
    return m.OTinitializeViewModel.callFunc("updatePurposeConsent", id, status)
end function

' Updates the legitimate interest value for a specified group (purpose/category) Identifier.
' - Parameters:
'   - id: The group represented as a string, for which legitimate interest value has to be updated.
'   - status: Boolean value specifying updated legitimate interest value.
function updatePurposeLegitInterest(id as string, status as boolean)
    return m.OTinitializeViewModel.callFunc("updatePurposeLegitInterest", id, status)
end function

' Updates the consent status for a specific vendor locally.
' - Parameters:
'   - id: The vendor identifier for which the consent status needs to be updated.
'   - status: Updated consent status.
' - Note: Starting 202503.2.0, this API will update vendor consent only if Preference Center and Vendors data is already downloaded by the OneTrust SDK locally.
function updateVendorConsent(id as string, status as boolean)
    return m.OTinitializeViewModel.callFunc("updateVendorConsent", id, status)
end function

' Updates the legitimate interest status for the specified vendor.
' - Parameters:
'   - id: The vendor identifier for which the LI status needs to be updated.
'   - status: Updated legitimate interest status.
' - Note: Legitimate interest is supported only for IAB vendors.
' - Note: Starting 202503.2.0, this API will update vendor legit interest only if Preference Center and Vendors data is already downloaded by the OneTrust SDK locally.
function updateVendorLegitInterest(id as string, status as boolean)
    return m.OTinitializeViewModel.callFunc("updateVendorLegitInterest", id, status)
end function

' it will set the full screen resolution of the SDK UI 
function setfullScreenResolution()
    deviceInfo = CreateObject("roDeviceInfo")
    scale = {
        "FHD": 1,
        "HD": 2 / 3,
        "SD": 3 / 8
    }
    screenSize = deviceInfo.GetUIResolution()
    scene = m.top.GetScene()
    m.global.Addfield("screenSize", "assocarray", false)
    if optionalChaining(scene, "currentDesignResolution.height") <> invalid then screenSize.height = scene.currentDesignResolution.height
    if optionalChaining(scene, "currentDesignResolution.width") <> invalid then screenSize.width = scene.currentDesignResolution.width
    if optionalChaining(scene, "currentDesignResolution.resolution") <> invalid then screenSize.name = scene.currentDesignResolution.resolution
    resolution = {
        w: screenSize.width
        h: screenSize.height
        name: screenSize.name
        scale: scale[screenSize.name]
    }
    m.global.screenSize = resolution
end function

' Observable will be triggered and mapped to the eventlistener
function eventlistener(data)
    data = data.getData()
    m.top.eventlistener[data.name] = data
end function
