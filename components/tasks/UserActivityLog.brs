sub init()
    print " UserActivityLog : init : Start : "
    readdata = CreateObject("roUrlTransfer")
    readdata.EnableHostVerification(false)
    readdata.EnablePeerVerification(false)
    APIURL = "https://api.ipify.org/"
    readdata.EnableEncodings(true)
    readdata.setUrl(APIURL)
    readdata.SetMinimumTransferRate(1, 75)
    m.port = CreateObject("roMessagePort")
    readdata.setport(m.port)
    m.response = readdata.gettostring()
    if m.response <> invalid
        GlobalSet("getIPAddress",m.response)
    else
        di = CreateObject("roDeviceInfo")
        getIPAddrs = di.GetIPAddrs()
        if getIPAddrs.eth1 <> invalid and getIPAddrs.eth1 <> ""
            GlobalSet("getIPAddress",getIPAddrs.eth1)
        end if
    end if
    print "IP Address " GlobalGet("getIPAddress")
    print " UserActivityLog : init : End : "
end sub
