function setupUI(data as object) as void
    m.logger.set(m.errortype.info, m.errorTags.PublicMethod, "setupUI" + m.constant.info["705"])
    if data.view = invalid
        m.logger.set(m.errortype.Warning, m.errorTags.OneTrust, m.constant.warning["903"])
        return
    end if
    m.OT_Data.view = data.view
    if data.type <> invalid
        m.OT_Data.viewType = Lcase(data.type)
        if isValid(m.top.onDataSuccess) and m.top.onDataSuccess
            onDataSetupUI(m.top.onDataSuccess)
        else
            createPromiseFromNode(m.top, true, "onDataSuccess").then(sub(data)
                onDataSetupUI(data)
            end sub)
        end if
    end if
end function

function onDataSetupUI(data)
    if data <> invalid and data
        if m.OT_Data.viewType = "banner"
            showBannerUI(false)
        else if m.OT_Data.viewType = "preferencecenter"
            showPreferenceCenterUI()
        end if
    end if
end function

function showBannerUI(override = true) as void
    if isValid(m.top.onDataSuccess) and m.top.onDataSuccess
        status = shouldShowBanner()
        if status or override
            if isValid(m.OT_Data["view"])
                bannerView = createObject("roSGNode", "OTBanner")
                bannerView.observeField("eventlistener", "eventlistener")
                bannerView.id = "OTBanner"
                bannerView.OTinitialize = m
                bannerView.bannerData = getBannerData()
                m.OT_Data["view"].appendChild(bannerView)
            else
                m.logger.set(m.errortype.Warning, m.errorTags.OneTrust, m.constant.warning["903"])
            end if
        else
            bannerLoggingReason(m.OT_Data.OT_modelData.appConfig)
        end if
    else
        m.logger.set(m.errortype.Warning, m.errorTags.OneTrust, "please download the data using startSdk method")
    end if
end function

function showPreferenceCenterUI(bannerExits = false as boolean)
    if isValid(m.top.onDataSuccess) and m.top.onDataSuccess
        m.bannerExits = bannerExits
        data = getPreferenceCenterData()
        if data <> invalid and data.pcUIData <> invalid
            if isValid(m.OT_Data["view"])
                PCview = createObject("roSGNode", "OTPreferenceCenter")
                PCview.id = "OTPreferenceCenter"
                PCview.bannerExits = m.bannerExits
                PCview.OTinitialize = m
                PCview.data = data
                m.OT_Data["view"].appendChild(PCview)
            else
                m.logger.set(m.errortype.Warning, m.errorTags.OneTrust, m.constant.warning["903"])
            end if
        else
            ShowBusySpinner(true)
            m.apis = {
                preference: "notInitialized",
                vendor: "notInitialized"
            }
            m.apisCount = 0
            dataDownload(OTSdkParams())
            createPromiseFromNode(m.top, true, "onDataSuccess").then(sub(data)
                if data <> invalid and data
                    showPreferenceCenterUI(m.bannerExits)
                end if
                ShowBusySpinner(false)
            end sub)
        end if
    else
        m.logger.set(m.errortype.Warning, m.errorTags.OneTrust, "please download the data using startSdk method")
    end if
end function

function showVendorListUI(bannerExits = false, viewType = "iab", selectedFilteredData = invalid)
    data = getVendorListData()
    m.bannerExits = bannerExits
    if data <> invalid and data.vendorListUIData <> invalid
        if isValid(m.OT_Data["view"])
            vendorview = createObject("roSGNode", "OTVendorList")
            vendorview.id = "OTVendorList"
            vendorview.bannerExits = m.bannerExits
            vendorview.OTinitialize = m
            vendorview.selectedFilteredData = selectedFilteredData
            vendorview.viewType = viewType
            vendorview.data = data
            m.OT_Data["view"].appendChild(vendorview)
        else
            m.logger.set(m.errortype.Warning, m.errorTags.OneTrust, m.constant.warning["903"])
        end if
    else
        ShowBusySpinner(true)
        m.apis = {
            preference: "notInitialized",
            vendor: "notInitialized"
        }
        m.apisCount = 0
        dataDownload(OTSdkParams())
        createPromiseFromNode(m.top, true, "onDataSuccess").then(sub(data)
            if data <> invalid and data
                showVendorListUI(m.bannerExits)
            end if
            ShowBusySpinner(false)
        end sub)
    end if
end function

sub ShowBusySpinner(shouldShow)
    progressdialog = createObject("roSGNode", "ProgressDialog")
    progressdialog.backgroundUri = ""
    if shouldShow
        m.top.GetScene().dialog = progressdialog
    else
        m.top.GetScene().dialog.close = true
    end if
end sub

function shouldShowBanner() as boolean
    shouldShowBannervalue = m.registry.read("shouldShowBanner")
    if shouldShowBannervalue <> invalid then shouldShowBannervalue = shouldShowBannervalue.toInt()
    return shouldShowBannervalue = 0
end function

function isBannerShown()
    return m.registry.read("isBannerShown")
end function

function eventlistener(event) as object
    event = event.getData()
    m.top.eventlistener = m.constant.listener["ELB115"]
end function