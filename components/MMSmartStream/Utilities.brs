
function setDeviceInfo()
  device = CreateObject("roDeviceInfo")
  deviceinfo = {
    "model": device.GetModelDisplayName(),
    "nwType": device.getConnectionInfo().type,
    "video_mode": device.GetVideoMode(),
    "ipAddress": device.getIPAddrs().eth1,
    "width": device.GetDisplaySize().w,
    "height": device.GetDisplaySize().h,
    "osversion": device.GetOSVersion().major + "." + device.GetOSVersion().minor + "." + device.GetOSVersion().revision + "." + device.GetOSVersion().build,
    "channelClientId": device.GetChannelClientId()
  }
  if device.getConnectionInfo().type = "WiFiConnection"
    deviceinfo.AddReplace("ssid", device.getConnectionInfo().ssid)
  end if
  return deviceinfo
end function

function setAppInfo()
  info = CreateObject("roAppInfo")
  appinfo = {
    "ID": info.GetID(),
    "appDev": info.IsDev()
  }
  return appinfo
end function

function _createConnection(port as object) as object
  connection = CreateObject("roUrlTransfer")
  connection.SetPort(port)
  connection.SetCertificatesFile("common:/certs/ca-bundle.crt")
  connection.AddHeader("Content-Type", "application/json")
  connection.AddHeader("Accept", "application/json")
  connection.AddHeader("Expect", "")
  connection.AddHeader("Connection", "keep-alive")
  'connection.AddHeader("Accept-Encoding", "gzip, deflate, br")
  'connection.EnableEncodings(true)
  return connection
end function

function _createPort() as object
  return CreateObject("roMessagePort")
end function

function _createByteArray() as object
  return CreateObject("roByteArray")
end function

function _createEVPDigest() as object
  return CreateObject("roEVPDigest")
end function

function _getStreamFormat(url as string) as string

  ismRegex = CreateObject("roRegex", "\.isml?\/manifest", "i")
  if ismRegex.IsMatch(url)
    return "ism"
  end if

  hlsRegex = CreateObject("roRegex", "\.m3u8", "i")
  if hlsRegex.IsMatch(url)
    return "HLS"
  end if

  dashRegex = CreateObject("roRegex", "\.mpd", "i")
  if dashRegex.IsMatch(url)
    return "DASH"
  end if
  ''
  formatRegex = CreateObject("roRegex", "\*?\.([^\.]*?)(\?|\/$|$|#).*", "i")
  if formatRegex <> invalid
    extension = formatRegex.Match(url)
    if extension <> invalid and extension.count() > 1
      return extension[1]
    end if
  end if

  return "unknown"
end function

function _getStreamSourceType(url as string) as string
  if url = invalid or url = "" then
    return "unknown"
  end if

  ' Match Smooth Streaming (ISM)
  ismRegex = CreateObject("roRegex", "\.isml?\/manifest", "i")
  if ismRegex.IsMatch(url)
    return "application/vnd.ms-sstr+xml"
  end if

  ' Match HLS (M3U8)
  hlsRegex = CreateObject("roRegex", "\.m3u8", "i")
  if hlsRegex.IsMatch(url)
    return "HLS"
  end if

  ' Match DASH (MPD)
  dashRegex = CreateObject("roRegex", "\.mpd", "i")
  if dashRegex.IsMatch(url)
    return "DASH"
  end if

  ' Match common video formats
  extensionRegex = CreateObject("roRegex", "\.([^\.?#/]+)(\?|#|$)", "i")
  match = extensionRegex.Match(url)
  if match <> invalid and match.count() > 1
    ext = LCase(match[1])
    ' Map extensions to MIME types
    mimeMap = {
      "mp4": "video/mp4",
      "webm": "video/webm",
      "avi": "video/x-msvideo",
      "mkv": "video/x-matroska",
      "flv": "video/x-flv"
    }
    if mimeMap.doesExist(ext)
      return mimeMap[ext]
    end if
  end if

  ' Default to unknown for unrecognized URLs
  return "unknown"
end function

function _getVideoFormat(url as string) as string
  formatRegex = CreateObject("roRegex", "\*?\.([^\.]*?)(\?|\/$|$|#).*", "i")
  if formatRegex <> invalid
    extension = formatRegex.Match(url)
    if extension <> invalid and extension.count() > 1
      return extension[1]
    end if
  end if

  return "unknown"
end function

function _generateVideoId(src as string) as string
  hostAndPath = _getHostnameAndPath(src)
  'byteArray = _createByteArray()
  'byteArray.FromAsciiString(hostAndPath)
  'bigString = byteArray.ToBase64String()
  'smallString = bigString.split("=")[0]
  return hostAndPath
end function

function _getHostnameAndPath(src as string) as string
  hostAndPath = src
  hostAndPathRegEx = CreateObject("roRegex", "^https?://", "")
  parts = hostAndPathRegEx.split(src)
  if parts <> invalid and parts.count() > 0
    if parts.count() > 1
      parts.shift()
    end if
    if parts.count() > 1
      hostAndPath = parts.join()
    else
      hostAndPath = parts[0]
    end if
    hostAndPathRegEx = CreateObject("roRegex", "\?|#", "")
    parts = hostAndPathRegEx.split(hostAndPath)
    if parts.count() > 1
      hostAndPath = parts[0]
    end if
  end if
  return hostAndPath
end function

function _getDomain(url as string) as string
  domain = ""
  strippedUrl = url.Split("//")
  if strippedUrl.count() = 1
    url = strippedUrl[0]
  else if strippedUrl.count() > 1
    if strippedUrl[0].len() > 7
      url = strippedUrl[0]
    else
      url = strippedUrl[1]
    end if
  end if
  splitRegex = CreateObject("roRegex", "[\/|\?|\#]", "")
  strippedUrl = splitRegex.Split(url)
  if strippedUrl.count() > 0
    url = strippedUrl[0]
  end if
  domainRegex = CreateObject("roRegex", "([a-z0-9\-]+)\.([a-z]+|[a-z]{2}\.[a-z]+)$", "i")
  matchResults = domainRegex.Match(url)
  if matchResults.count() > 0
    domain = matchResults[0]
  end if
  return domain
end function

function _getHostname(url as string) as string
  host = ""
  hostRegex = CreateObject("roRegex", "([a-z]{1,})(\.)([a-z.]{1,})", "i")
  matchResults = hostRegex.Match(url)
  if matchResults.count() > 0
    host = matchResults[0]
  end if
  return host
end function

function _getDateTime() as object
  return CreateObject("roDateTime")
end function

function _generatePid(src as string) as string
  ba = _createByteArray()
  ba.FromAsciiString(src)
  digest = _createEVPDigest()
  digest.setup("md5")
  result = digest.process(ba)
  part1 = result.mid(8, 8)
  part2 = result.right(8)
  part3 = result.left(8)
  part4 = result.Mid(16, 8)
  result = part1 + part2 + part3 + part4
  return result
end function

function _convertDoubleToString(timestamp as double) as string
  output = formatJSON({ double: timestamp })
  output = output.Mid(output.InStr(":") + 1)
  output = output.Mid(0, output.InStr("}"))
  return output.Trim()
end function

function _generateSubId(src as string) as string
  ba = _createByteArray()
  ba.FromAsciiString(src)
  digest = _createEVPDigest()
  digest.setup("md5")
  result = digest.process(ba)
  return result
end function

function _ceiling(x):
  i = int(x)
  if i < x then i = i + 1
  return i
end function

Function minifyPayload(originalObject As Object) As Object
    clonedObject = {}
    payloadKeyMap = getPayloadKeyMapping()

    for each key in originalObject
        newKey = payloadKeyMap.Lookup(key)
        if newKey = invalid then newKey = key

        value = originalObject[key]

        if Type(value) = "roArray"
            newArray = []
            for each item in value
                if Type(item) = "roAssociativeArray"
                    newArray.Push(minifyPayload(item)) ' Recursive call for object items
                else
                    newArray.Push(item) ' Primitive value
                end if
            end for
            clonedObject[newKey] = newArray

        else if Type(value) = "roAssociativeArray"
            clonedObject[newKey] = minifyPayload(value) ' Recursive call for nested objects

        else
            clonedObject[newKey] = value ' Primitive value
        end if
    end for

    return clonedObject
End Function

function getPayloadKeyMapping() As object 
  return {
    "timestamp": "t",
    "pbTime": "pt",
    "playDur": "pd",
    "interval": "i",
    "version": "v",
  
    "qubitData": "qd",
  
    "streamID": "sd", 
  
    "custId": "ci",
    "dataSrc": "dsr",
    "playerName": "pn",
    "sessionId": "si",
    "domainName": "dn",
    "streamURL": "su",
    "playerVersion": "pv",
    "pb": "pb",
    "pm": "pm",
    "experimentName": "exn",
    "subPropertyId": "spi",
    "viewSessionId": "vsi",
    "basePlayerName": "bpn",
    "basePlayerVersion": "bpv",
    "subscriberId": "sbi",
    "subscriberType": "sbt",
    "subscriberTag": "sg",      
    "mode": "m",
    "isLive": "il",
    "pId": "pi",
    "sst": "sst",
    "sourceType": "sct",
    "parentCustId": "pci",
    "streamMode": "sm",
    "mediaType": "mt",
  
    "streamInfo": "sif",
  
    "totalDuration": "td",
    "maxRes": "xr",
    "minRes": "nr",
    "maxFps": "xf",
    "minFps": "nf",
    "numOfProfile": "np",
    "streamFormat": "sf",
    "videoTrack": "vk",
    "subtitleTrack": "sk",
    "audioTrack": "ak",
    "isVDSActive": "iv",
    "isSubtitleActive": "is",
  
    "contentMetadata": "cm",
  
    "assetId": "ai",
    "assetName": "an",
    "videoId": "vi",
    "contentType": "ct",
    "drmProtection": "dp",
    "episodeNumber": "en",
    "genre": "g",
    "season": "se",
    "seriesTitle": "st",
    "videoType": "vt",
  
    "segInfo": "sgi",
  
    "res": "r",
    "cbrBitrate": "cb",
    "vCodec": "vc",
    "aCodec": "ac",
    "downloadRate": "dr",  
    "qbrBitrate": "qb",                    
    "qbrQual": "qq",
    "cbrQual": "cq",
    "dur": "du",
    "fps": "f",
    "seqNum": "sn",
    "startTime": "s",
    "profileNum": "pfn",
    "lastTS": "lts",
    "cbrSize": "cz",
    "qbrSize": "qz",
    "cbrProfileNum": "cp",
    "bufferLength": "bl",    
  
    "pbEventInfo": "pe",
  
    "event": "e",
    "desc": "dsc",
    "id": "id",
    "playbackStatus": "ps",    
  
    "pbInfo": "pif",
    
    "bwInUse": "bu",  
    "progressMark": "gm",
    "latency": "l",
    "buffWait": "bw",
    "buffWaitType": "bwt",
    "sumBuffWait": "sb",
    "sumBuffWaitCIRR": "sbc",
    "sumBuffWaitVRT": "sbv",
    "sumBuffWaitAAD": "sba",
    "frameloss": "fl",
    "upShiftCount": "us",
    "downShiftCount": "ds",
    "pauseDuration": "ud",
  
    "sdkInfo": "sdi",
  
    "sdkVersion": "sv",
    "hFileVersion": "hv",    
    "sdkType": "skt",    
  
    "clientInfo": "cif",
  
    "appName": "apn",
    "appVersion": "apv",
    "deviceMarketingName": "dm",
    "scrnRes": "sr",
    "deviceId": "di",
    "deviceCapabilities": "dc",
    "cdn": "c",
    "operator": "op",
    "nwType": "nt",
    "wifissid": "ws",
    "wifidatarate": "wd",
    "signalstrength": "ss",
    "platform": "p",
    "location": "l",
    "device": "d",
    "brand": "br",
    "model": "ml",
    "videoQuality": "vq",
    "userAgent": "ua",
    "browserVersion": "bv",
    "browser": "b",  
    "clientIP": "cip",
    "playerRes": "pr",
    "asn": "asn",    
  
    "adInfo": "aif",
  
    "adId": "id",
    "adClient": "cl",
    "adCreative": "c",
    "adCreativeId": "cid",
    "adCreativeType": "ct",
    "adDuration": "d",
    "adInterval": "i",
    "adPosition": "p",
    "adLinear": "al",
    "adSystem": "s",
    "adPodIndex": "pi",
    "adPodPosition": "pp",
    "adPodLength": "pl",
    "adResolution": "r",
    "adBitrate": "b",
    "adTitle": "t",
    "adUrl": "u",
    "isBumper": "ib",
  
    "customTags": "ctg"
  }
end function