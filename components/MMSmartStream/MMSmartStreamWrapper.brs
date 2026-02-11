
function SmartStream() as object
  wrapper = {}

  wrapper.init = function()
    m.mmsdk = MMSmartStream()
    m.mmsdk.init()
  end function

  ' wrapper.blacklistRepresentation = function(representationIdx as integer,blacklistRepresentation as boolean)

  ' m.mmsdk.blacklistRepresentation(representationIdx,blacklistRepresentationn)
  'end function

  wrapper.disableManifestFetch = function(disable as boolean)
    m.mmsdk.disableManifestFetch(disable)
  end function

  wrapper.enableLogTrace = function(isEnable as boolean)
    m.mmsdk.enableLogTrace(isEnable)
    return false
  end function

  wrapper.getInstance = function(context as object)
    m.mmsdk.getInstance(context)
  end function

  wrapper.getQBRBandwidth = function(representationTrackIdx as integer, defaultBitrate as integer, bufferLength as integer, playbackPos as integer)

    m.mmsdk.getQBRBandwidth(representationTrackIdx, defaultBitrate, bufferLength, playbackPos)
  end function

  wrapper.getQBRChunk = function(cbrChunk as object)

    m.mmsdk.getQBRChunk(cbrChunk)
  end function

  wrapper.getSmartRouteUrl = function(downloadUrl as string)

    m.mmsdk.getSmartRouteUrl(downloadUrl)
  end function

  wrapper.getRegistrationStatus = function()

    m.mmsdk.getRegistrationStatus()
  end function

  wrapper.getVersion = function()

    m.mmsdk.getVersion()
  end function

  wrapper.setStreamURL = function(manifestURL as string)
    m.mmsdk.setStreamURL(manifestURL)
  end function

  wrapper.initializeSession = function(mode as string, manifestURL as string, contentMeta as object) as object
    response = false
    if manifestURL <> invalid
      response = m.mmsdk.initializeSession(mode, manifestURL, contentMeta)
    end if
    return response
  end function

  wrapper.registerMMSmartStreaming = function(name as string, customerID as string, component as string, subscriberID as string, domainName as string, subscriberType as string, subcriberTag as string)
    'Registration call wrapper
    response = false
    if customerID <> invalid
      m.mmsdk.registerMMSmartStreaming(name, customerID, component, subscriberID, domainName, subscriberType, subcriberTag)
      response = true
    end if
    return response
  end function

  wrapper.reportAdError = function(error as string, pos1 as double)
    m.mmsdk.reportAdError(error, pos1)
  end function

  wrapper.reportAdInfo = function(adInfo as object)
    '?adInfo
    'print("********************** adinfo wrapper *********************")
    m.mmsdk.reportAdInfo(adInfo)
  end function

  wrapper.reportAdPlaybackTime = function(playbackPos as longinteger)
    m.mmsdk.reportAdPlaybackTime(playbackPos)
  end function

  wrapper.reportAdState = function(adState as string)
    m.mmsdk.reportAdState(adState)
  end function

  wrapper.reportBufferingCompleted = function()

    m.mmsdk.reportBufferingCompleted()
  end function

  wrapper.reportBufferingStarted = function(isVRT as boolean)
    m.mmsdk.reportBufferingStarted(isVRT)
  end function

  wrapper.reportChunkRequest = function(chunkInfo as object)
    m.mmsdk.reportChunkRequest(chunkInfo)
  end function

  wrapper.reportCustomMetadata = function(key as string, value as string)
    m.mmsdk.reportCustomMetadata(key, value)
  end function

  wrapper.reportContentMetadata = function(contentMetadata as object)
    m.mmsdk.reportContentMetadata(contentMetadata)
  end function

  wrapper.reportDeviceInfo = function(brand as string, deviceModel as string, deviceOS as string, deviceOsVersion as string, telecomOperator as string, screenWidth as integer, screenHeight as integer)
    m.mmsdk.reportDeviceInfo(brand, deviceModel, deviceOS, deviceOsVersion, telecomOperator, screenWidth, screenHeight)
  end function

  wrapper.reportDownloadRate = function(downloadRate as longinteger)
    m.mmsdk.reportDownloadRate(downloadRate)
  end function

  wrapper.reportError = function(Error as string, pos1 as double)
    m.mmsdk.reportError(Error, pos1)
  end function

  wrapper.reportFrameLoss = function(lossCnt as integer)
    m.mmsdk.reportFrameLoss(lossCnt)
  end function

  wrapper.reportLocation = function(latitude as double, longitude as double)
    m.mmsdk.reportLocation(latitude, longitude)
  end function

  wrapper.reportNetworkType = function(networkType as object)
    m.mmsdk.reportNetworkType(networkType)
  end function

  wrapper.reportPlaybackPosition = function(playbackPos as double)
    m.mmsdk.reportPlaybackPosition(playbackPos)
  end function

  wrapper.reportPlayerInfo = function(playerVersion as string, basePlayerName as string, basePlayerVersion as string)
    m.mmsdk.reportPlayerInfo(playerVersion, basePlayerName, basePlayerVersion)
  end function

  wrapper.reportPlayerSeekStarted = function()
    m.mmsdk.reportPlayerSeekStarted()
  end function

  wrapper.reportPlayerSeekCompleted = function(seekEndPos as double)
    m.mmsdk.reportPlayerSeekCompleted(seekEndPos)
  end function

  wrapper.reportPlayerState = function(playerState as string)
    m.mmsdk.reportPlayerState(playerState)
  end function

  wrapper.reportPresentationSize = function(width as integer, height as integer)
    m.mmsdk.reportPresentationSize(width, height)
  end function

  wrapper.reportUserInitiatedPlayback = function()
    m.mmsdk.reportUserInitiatedPlayback()
  end function

  wrapper.reportWifiDataRate = function(dataRate as longinteger)
    m.mmsdk.reportWifiDataRate(dataRate)
  end function

  wrapper.reportWifiSSID = function(ssid as string)
    m.mmsdk.reportWifiSSID(ssid)
  end function

  wrapper.reportWifiSignalStrengthPercentage = function(strength as double)
    m.mmsdk.reportWifiSignalStrengthPercentage(strength)
  end function

  wrapper.setPresentationInformation = function(presentationInfo as object)
    m.mmsdk.setPresentationInformation(presentationInfo)
  end function

  wrapper.updateSubscriber = function(subscriberID as string, subscriberType as string)
    m.mmsdk.updateSubscriber(subscriberID, subscriberType)
  end function

  wrapper.updateSubscriberID = function(subscriberID as string)
    m.mmsdk.updateSubscriberID(subscriberID)
  end function

  wrapper.fireBeacon = function(isPingPayload as boolean)
    m.mmsdk.fireBeacon(isPingPayload)
  end function

  wrapper.reportAppInfo = function(appName as string, appSdkVersion as string)
    m.mmsdk.reportAppInfo(appName, appSdkVersion)
  end function

  wrapper.reportViewSessionId = function(viewSessionId as string)
    m.mmsdk.reportViewSessionId(viewSessionId)
  end function

  wrapper.reportCDN = function(cdn as string)
    m.mmsdk.reportCDN(cdn)
  end function

  wrapper.reportExperimentName = function(experimentName as string)
    m.mmsdk.reportExperimentName(experimentName)
  end function

  wrapper.reportSubPropertyId = function(subPropertyId as string)
    m.mmsdk.reportSubPropertyId(subPropertyId)
  end function

  wrapper.reportStreamFormat = function(streamFormat as string)
    m.mmsdk.reportStreamFormat(streamFormat)
  end function

  wrapper.reportMediaType = function(mediaType as string)
    m.mmsdk.reportMediaType(mediaType)
  end function

  wrapper.reportCodecs = function(codecs as object)
    m.mmsdk.reportCodecs(codecs)
  end function

  wrapper.reportRequestStatusEvent = function(eventName as string, desc as object)
    m.mmsdk.reportRequestStatusEvent(eventName, desc)
  end function

  wrapper.reportDeviceId=function(deviceId as string)
    m.mmsdk.reportDeviceId(deviceId)
  end function

  wrapper.updateDrmProtection=function(drmType as string)
    m.mmsdk.updateDrmProtection(drmType)
  end function

  return wrapper
end function
