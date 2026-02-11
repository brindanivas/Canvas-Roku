'********************************************************************
'**  http-request.brs
'********************************************************************
'**  Example:
'**  req = HttpRequest({
'**      url: "http://www.apiserver.com/login",
'**      method: "POST",
'**      headers: { "Content-Type": "application/json" },
'**      data: { user: "johndoe", password: "12345" }
'**  })
'**  req.send()
'********************************************************************

function HttpRequest(params = invalid as dynamic) as object
    url = invalid
    method = invalid
    headers = invalid
    data = invalid
    timeout = 0
    retries = 1
    interval = 500

    if params <> invalid then
        if params.url <> invalid then url = params.url
        if params.method <> invalid then method = params.method
        if params.headers <> invalid then headers = params.headers
        if params.data <> invalid then data = params.data
        if params.timeout <> invalid then timeout = params.timeout
        if params.retries <> invalid then retries = params.retries
        if params.interval <> invalid then interval = params.interval
    end if

    test_mock_available = test_Mock_obj(url, headers)
    if test_mock_available <> invalid
        obj = test_mock_available
    else
        obj = {
            _timeout: timeout
            _retries: retries
            _interval: interval
            _deviceInfo: createObject("roDeviceInfo")
            _url: url
            _method: method
            _requestHeaders: headers
            _data: data
            _http: invalid
            _isAborted: false

            _isProtocolSecure: function(url as string) as boolean
                return left(url, 6) = "https:"
            end function

            _createHttpRequest: function() as object
                request = CreateObject("roUrlTransfer")
                request.SetMessagePort(createObject("roMessagePort"))
                request.setUrl(m._url)
                request.retainBodyOnError(true)
                request.enableCookies()
                if m._requestHeaders <> invalid then request.setHeaders(m._requestHeaders)
                if m._method <> invalid then request.setRequest(m._method)

                'Checks if URL protocol is secured, and adds appropriate parameters if needed
                if m._isProtocolSecure(m._url) then
                    request.setCertificatesFile("common:/certs/ca-bundle.crt")
                    '  request.addHeader("X-Roku-Reserved-Dev-Id", "")
                    request.initClientCertificates()
                end if

                return request
            end function

            getPort: function()
                if m._http <> invalid then
                    return m._http.GetMessagePort()
                else
                    return invalid
                end if
            end function

            getCookies: function(domain as string, path as string) as object
                if m._http <> invalid then
                    return m._http.getCookies(domain, path)
                else
                    return invalid
                end if
            end function

            send: function(data = invalid as dynamic) as dynamic
                timeout = m._timeout
                retries = m._retries
                response = invalid

                if data <> invalid then m._data = data

                if m._data <> invalid and getInterface(m._data, "ifString") = invalid then
                    m._data = formatJson(m._data)
                end if

                while retries > 0 and m._deviceInfo.getLinkStatus()
                    if m._sendHttpRequest(m._data) then
                        event = wait(timeout, m._http.GetMessagePort())
                        if m._isAborted then
                            m._isAborted = false
                            m._http.asyncCancel()
                            exit while
                        else if type(event) = "roUrlEvent" then
                            response = event
                            exit while
                        end if

                        m._http.asyncCancel()
                        timeout *= 2
                        sleep(m._interval)
                    end if

                    retries--
                end while

                return response
            end function

            _sendHttpRequest: function(data = invalid as dynamic) as dynamic
                m._http = m._createHttpRequest()

                if data <> invalid then
                    return m._http.AsyncPostFromString(data)
                else
                    return m._http.AsyncGetToString()
                end if
            end function

            abort: function()
                m._isAborted = true
            end function

        }
    end if
    return obj
end function

function test_Mock_obj(url, headers) as dynamic
    if m.global.OT_isAutomation <> invalid and headers <> invalid and url<> invalid and headers["OT-App-Id"] <> invalid and m.global.OT_isAutomation
        urlNamelist = url.split("/")
        urlName = urlNamelist[urlNamelist.count() - 1]
        filename = urlName + "_" + headers["OT-App-Id"] + "_" + headers["OT-Language"] + "_" + headers["OT-Country-Code"] + "_" + headers["OT-Region-Code"] + "_" + ".json"
        path = "pkg:/mocks/" + filename
        files = MatchFiles("pkg:/mocks/", filename)
        test_data = invalid
        if files <> invalid and files.count() > 0
            test_data = ParseJson(ReadAsciiFile(path))
        end if
        if test_data <> invalid and test_data.response <> invalid
            obj = {
                _test_data: test_data
                _urlName: urlName
                send: function() as dynamic
                    test_data = m._test_data
                    urlName = m._urlName
                    test_response_obj = {
                        _test_data: test_data
                        _urlName: urlName
                        GetString: function() as string
                            print m._urlName " API fetched from mock data"
                            return FormatJson(m._test_data.response)
                        end function
                        GetResponseCode: function() as integer
                            return m._test_data.code
                        end function
                        GetFailureReason: function() as string
                            return m._test_data.error
                        end function
                    }
                    return test_response_obj
                end function
            }
            return obj
        end if
    end if
    return invalid
end function
