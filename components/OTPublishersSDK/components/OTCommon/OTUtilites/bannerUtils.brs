function setShouldShowBannerStatus(status)
    isShouldShowBanner = m.registry.read("shouldShowBanner")
    if (not isString(isShouldShowBanner) and status = -1) or status <> -1 then m.registry.write("shouldShowBanner", status)
end function

function setIsBannerShownStatus(status as integer)
    ' old bannerDisplayed - need to depricate in cmp api
    bannerShown = m.registry.read("isBannerShown")
    if not (bannerShown = "1" or bannerShown = "2") or status = 2 then m.registry.write("isBannerShown", status)
end function

function bannerLoggingReason(data)
    m.logger.set(m.errortype.Banner, m.errorTags.OTUIDisplayReasonMessage, data.bannerReasonCode.toStr() + " - ", data.bannerReason)
end function