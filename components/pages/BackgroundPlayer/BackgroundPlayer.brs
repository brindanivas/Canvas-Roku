sub init()
    ' print "BackGroundPlayer : Init"
    Initialize()
    SetControls()
    SetObservers()
end sub

sub Initialize()
    m.top.enableUI = false
end sub

sub SetControls()
    m.scene = m.top.GetScene()
end sub

sub SetObservers()
    m.top.observeField("state", "OnVideoPlayerStatusChange")
end sub

sub OnContentChange(event as dynamic)
    videoUrl = event.getData()
    print "BackGroundPlayer OnContentChange "videoUrl
    videoContent = createObject("RoSGNode", "ContentNode")
    m.isFirstTimeVideoStarted = false
    videoContent.url = videoUrl
    videoContent.streamformat = "auto"
    videocontent.live = false
    m.top.visible = false
    m.top.loop = true
    m.top.mute = false
    m.top.content = videoContent
    ' m.top.control = "prebuffer"
    print "OnBackgroundVideoChange "
end sub


sub onInitialize(event as dynamic)
    isInitialize = event.GetData()
    m.isFirstTimeVideoStarted = false
    m.top.visible = false
    if isInitialize
        m.top.control = "play"
    end if
end sub

sub onStopPlayer()
    ClosePlayer()
end sub

sub onDestroy()
    ClosePlayer()
    m.top.content = invalid
end sub

sub OnVideoPlayerStatusChange(event as dynamic)
    videoStatus = event.GetData()
    print "BackGroundPlayer : OnVideoPlayerStatusChange : Video Status : " videoStatus
    if videoStatus = "stopped" Then
    end if
    if videoStatus = "playing"
        if m.isFirstTimeVideoStarted = false
            m.isFirstTimeVideoStarted = true
            m.top.visible = true
        end if
    else if videoStatus = "finished"
        ClosePlayer()
    else if videoStatus = "paused"
    else if videoStatus = "error"
        print "BackGroundPlayer : OnVideoPlayerStatusChange : Error Info : " m.top.errorInfo
        ClosePlayer()
    end if
end sub



Sub ClosePlayer()
    m.top.control = "stop"
    m.top.visible = false
end Sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    print "BackGroundPlayer : onKeyEvent : key = " key " press = " press
    result = false
    if (press)

    end if
    return result
end function
