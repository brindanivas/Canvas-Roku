function Main(args as Dynamic)
    m.screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    m.screen.setMessagePort(m.port)

    m.scene = m.screen.CreateScene("MainScene")
    m.scene.id = "MainScene"

    inputObject = CreateObject("roInput")
    inputObject.SetMessagePort(m.port)

    if args.contentId <> invalid and args.mediaType <> invalid
        print "Main : Deeplink Args : " args
        m.scene.deeplinkingContentID = LCase(args.contentId)
        m.scene.deeplinkingMediaType = LCase(args.mediaType)
        m.scene.deepLinkingLand = true
    else
        print "Main : No Deeplinking..."
    end if

    m.screen.show()
    m.scene.observeField("outRequest", m.port)
    m.scene.initialize = true
    m.scene.setFocus(true)
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                exit while
            end if
        else if msgType = "roSGNodeEvent"
            print "Main : Message Type : " msgType
            print "Main : Message Field : " msg.GetField()
            ' When The AppManager want to send command back to Main
            if (msg.GetField() = "outRequest")
                request = msg.GetData()
                print "Main : Request : " request
                if (request <> invalid)
                    if (request.DoesExist("ExitApp") and (request.ExitApp = true))
                        print "Main : Closing Screen."
                        m.screen.close()
                    end if
                end if
            end if
        else if msgType = "roInputEvent"
            print "Main : Input Event"
            if (msg.isInput() = true)
                messageInfo = msg.GetInfo()
                print "Main : messageInfo : "  messageInfo
                if (messageInfo.contentId <> invalid and messageInfo.mediaType <> invalid)
                    m.scene.callFunc("HandleDeepLinkingInputEvent", messageInfo)
                end if
            end if
        end if
    end while
end function
