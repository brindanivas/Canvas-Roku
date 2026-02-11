sub init()
    ' print "DetailsScreen : Init"
    SetLocals()
    SetControls()
    SetObservers()
    Initialize()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
end sub

sub SetControls()
    m.scene = m.top.GetScene()
    m.backgroundImage = m.top.findNode("backgroundImage")
    m.overlay = m.top.FindNode("overlay")
    m.gContentDetails = m.top.FindNode("gContentDetails")
    m.pbplay = m.top.FindNode("pbplay")
    m.pplayresume = m.top.FindNode("pplayresume")
    m.lplay = m.top.FindNode("lplay")
    m.pbrestart = m.top.FindNode("pbrestart")
    m.pResume = m.top.FindNode("pResume")
    m.lrestart = m.top.FindNode("lrestart")
    
    m.pbTrailer = m.top.FindNode("pbTrailer")
    m.pTrailer = m.top.FindNode("pTrailer")
    m.lTrailer = m.top.FindNode("lTrailer")
    
    m.lgDetails = m.top.FindNode("lgDetails")
    m.pVideoImage = m.top.FindNode("pVideoImage")
    m.borderMask = m.top.FindNode("borderMask")

    m.RowListUpAnimation = m.top.FindNode("RowListUpAnimation")
    m.RowListDownAnimation = m.top.FindNode("RowListDownAnimation")

    m.vDownTranslation = m.top.FindNode("vDownTranslation")
    m.vUpTranslation = m.top.FindNode("vUpTranslation")

    m.fDownContentOpacity = m.top.FindNode("fDownContentOpacity")
    m.fUpContentOpacity = m.top.FindNode("fUpContentOpacity")
end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChild")
    m.scene.observeField("IsUpdateData", "updateRowLIstDetails")
    m.pbplay.observeField("focusedChild", "OnPBPlayFocusedChild")
    m.pbrestart.observeField("focusedChild", "OnPBRestartFocusedChild")
    m.pbTrailer.observeField("focusedChild", "OnPBTrailerFocusedChild")

    m.RowListUpAnimation.observeField("state", "OnUpAnimationComplete")
    m.RowListDownAnimation.observeField("state", "OnDownAnimationComplete")
    subscribeEvent("OnUpNextIndexChange")
end sub
    
sub Initialize()
    m.lplay.color = "#1D1D26"
    m.lrestart.color = "#1D1D26"
    m.lTrailer.color = "#1D1D26"
end sub

sub OnVisible()
    if m.top.visible then
        SetFocus(m.pbplay)
        m.scene.callFunc("ShowHideMenu", false)
    end if
end sub

sub StartUpAnimation()
    if m.RowListUpAnimation.state <> "running"
        m.vUpTranslation.fieldToInterp = "rMovies.translation"
        m.fUpContentOpacity.fieldToInterp = "gContentDetails.opacity"
        m.RowListUpAnimation.control = "start"
    end if
end sub

sub StartDownAnimation()
    if m.RowListDownAnimation.state <> "running"
        m.vDownTranslation.fieldToInterp = "rMovies.translation"
        m.fDownContentOpacity.fieldToInterp = "gContentDetails.opacity"
        m.RowListDownAnimation.control = "start"
    end if
end sub

sub finishAnimation()
    m.RowListUpAnimation.control = "stop"
    m.RowListDownAnimation.control = "stop"
end sub

sub OnUpAnimationComplete(event as object)
    print "OnUpAnimationComplete "event.GetData()
    if event.GetData() = "stopped" and m.top.visible then
        SetFocus(m.pbplay)
    end if
end sub

sub OnDownAnimationComplete(event as object)
    if event.GetData() = "stopped" and m.top.visible then
        SetFocus(m.rowList)
        m.rowList.setFocus(false)
        SetFocus(m.rowList)
    end if
end sub

sub PlayMovieVideo(isTrailer = false as boolean)
    m.datarray.isTrailer = isTrailer
    m.datarray.selectedindex = m.index[1]
    m.scene.callFunc("PlayVideo", m.datarray)
end sub

function ShowDynamicRowList(playlistContent)
    if m.rowList = invalid
        rowList = CreateObject("roSGNode", "DynamicRowList")
        rowList.id = "rMovies"
        rowList.translation = [75, 950]
        rowList.observeField("rowItemSelected", "onRowItemSelected")
        rowList.playlistContent = playlistContent
        m.rowList = rowList
        m.top.appendChild(m.rowList)
    else
        m.rowList.playlistContent = playlistContent
    end if
end function

sub updateRowLIstDetails()
    UpdateButton(m.index)
end sub

sub onRowItemSelected(event as object)
    m.index = event.GetData()
    print "onRowItemSelected ... " m.index
    SetupMetaData(m.index)
    StartUpAnimation()
    UpdateButton(m.index)
end sub

sub OnUpNextUpdate(playIndex as dynamic)
    m.index = [0, playIndex]
    m.rowList.jumpToRowItem = m.index
    SetupMetaData(m.index)
    UpdateButton(m.index)
end sub



sub OnUpdateContentChange(event as dynamic)
    content = event.getData()
    if content <> invalid
        if content.Count() > 0
            m.rowList.paginationContent = content
        end if
    end if
end sub

sub UpdateButton(index as dynamic)
    data = m.rowList.content.getChild(index[0]).getChild(index[1])
    regProgress = GetBookmarkData(data._id.toStr())
    print "DetailsScreen : UpdateButton : regProgress : " regProgress
    print "DetailsScreen : UpdateButton : regProgress : " type(regProgress)
    if data.trailerUrl <> invalid and data.trailerUrl <> ""
        m.pbTrailer.visible = true
    else
        m.pbTrailer.visible = false
    end if
    if regProgress <> invalid and regProgress > 0
        position = FormatTime(regProgress, true)
        m.lplay.text = "Resume from " + position
        m.pbrestart.visible = true
        m.pbplay.width = 400
        m.lplay.width = 400
        m.pplayresume.uri = "pkg:/images/icons/resume.png"
        m.pplayresume.translation = "[25,26]"
        m.lplay.translation = "[30,0]"
        m.pbTrailer.translation="[990,600]"
    else
        m.pbrestart.visible = false
        m.pbplay.width = 236
        m.lplay.width = 236
        m.lplay.text = "Play"
        m.lplay.translation = "[25,0]"
        m.pplayresume.uri = "pkg:/images/icons/play_image.png"
        m.pplayresume.translation = "[60,26]"
        m.pbTrailer.translation="[386,600]"
    end if
end sub

sub OnContentChange(event as dynamic)
    m.datarray = event.getData()
    if (m.datarray.selectedrowitem <> invalid) then
        pageData = CreateObject("roSGNode", "ContentNode")
        pageData.appendChild(m.datarray.selectedrowitem)
        ShowDynamicRowList(pageData)
        m.index = [0, m.datarray.selectedindex]
        m.rowList.jumpToRowItem = m.index
        SetupMetaData(m.index)
        UpdateButton(m.index)
    end if
    m.lgDetails.visible = true
end sub

sub SetupMetaData(index)
    if m.rowList <> invalid then
        data = m.rowList.content.getChild(index[0]).getChild(index[1])
        itemSpacings = []
        if data.title <> invalid and data.title <> ""
            if m.lTitle = invalid
                m.lTitle = createObject("roSGNode", "Label")
                m.lTitle.id = "lTitle"
                m.lTitle.width = "1146"
                m.lTitle.height = "85"
                m.lTitle.horizAlign = "left"
                m.lTitle.vertAlign = "top"
                m.lTitle.wrap = "true"
                m.lTitle.maxLines = "2"
                m.lTitle.lineSpacing = "0"
                m.lgDetails.appendChild(m.lTitle)
                itemSpacings.push(20)
            end if
            m.lTitle.text = data.title
        else if m.lTitle <> invalid
            m.lgDetails.removeChild(m.lTitle)
            m.lTitle = invalid
        end if

        if data.rating <> invalid and data.rating <> ""
            if m.lRating = invalid
                m.lRating = createObject("roSGNode", "Label")
                m.lRating.id = "lRating"
                m.lRating.width = "286"
                m.lRating.height = "62.48"
                m.lRating.horizAlign = "left"
                m.lRating.vertAlign = "top"
                m.lRating.wrap = "true"
                m.lRating.maxLines = "2"
                m.lRating.lineSpacing = "0"
                m.lgDetails.appendChild(m.lRating)
                itemSpacings.push(20)
            end if
            m.lRating.text = data.rating
        else if m.lDescription <> invalid
            m.lgDetails.removeChild(m.lRating)
            m.lRating = invalid
        end if

        if data.DESCRIPTION <> invalid and data.DESCRIPTION <> ""
            if m.lDescription = invalid
                m.lDescription = createObject("roSGNode", "Label")
                m.lDescription.id = "lDescription"
                m.lDescription.width = "1146"
                m.lDescription.height = "170.5"
                m.lDescription.horizAlign = "left"
                m.lDescription.vertAlign = "top"
                m.lDescription.wrap = "true"
                m.lDescription.maxLines = "10"
                m.lDescription.lineSpacing = "0"
                m.lgDetails.appendChild(m.lDescription)
                itemSpacings.push(30)
            end if
            m.lDescription.text = data.DESCRIPTION
        else if m.lDescription <> invalid
            m.lgDetails.removeChild(m.lDescription)
            m.lDescription = invalid
        end if
        if data.poster_9_16 <> invalid and data.poster_9_16 <> "" and (data.playList_program_type = "movies" or data.playList_program_type = "movie")
            m.pVideoImage.uri = data.poster_9_16
            m.backgroundImage.uri = data.poster_9_16
            m.pVideoImage.height = "600"
            m.pVideoImage.width = "400"
            m.pVideoImage.loadHeight = "600"
            m.pVideoImage.loadWidth = "400"
            m.pVideoImage.loadingBitmapUri = "pkg:/images/others/default-movie.png"
            m.pVideoImage.failedBitmapUri = "pkg:/images/others/default-movie.png"
            m.borderMask.translation = "[1430,188]"
            m.borderMask.maskUri = "pkg:/images/focus/movie-big-mask.png"
        else if data.poster_16_9 <> invalid and data.poster_16_9 <> "" and (data.playList_program_type = "videos" or data.playList_program_type = "video")
            m.pVideoImage.uri = data.poster_16_9
            m.backgroundImage.uri = data.poster_16_9
            m.pVideoImage.height = "315"
            m.pVideoImage.width = "560"
            m.pVideoImage.loadHeight = "315"
            m.pVideoImage.loadWidth = "560"
            m.pVideoImage.loadingBitmapUri = "pkg:/images/others/default_poster.png"
            m.pVideoImage.failedBitmapUri = "pkg:/images/others/default_poster.png"
            m.borderMask.translation = "[1300,320]"
            m.borderMask.maskUri = "pkg:/images/focus/horiz-mask.png"
        end if
        if data.poster_9_16 <> invalid and data.poster_9_16 <> "" or data.poster_16_9 <> invalid and data.poster_16_9 <> ""
            maskSize = [m.pVideoImage.width, m.pVideoImage.height]
            if m.global.designresolution = "720p"
                maskSize = [maskSize[0] / 1.5, maskSize[1] / 1.5]
            end if
            m.borderMask.maskSize = maskSize
        end if
        SetupFonts()
        SetupColors()
    end if
end sub


sub SetupFonts()
    if (m.lTitle <> invalid)
        m.lTitle.font = m.fonts.robotoReg66
    end if
    if (m.lDescription <> invalid)
        m.lDescription.font = m.fonts.robotoReg28
    end if
    if (m.lRating <> invalid)
        m.lRating.font = m.fonts.robotoReg28
    end if
    m.lplay.font = m.fonts.robotoMed30
    m.lrestart.font = m.fonts.robotoMed30
    m.lTrailer.font = m.fonts.robotoMed30
end sub

sub SetupColors()
    if (m.lTitle <> invalid)
        m.lTitle.color = m.theme.White
    end if
    if (m.lDescription <> invalid)
        m.lDescription.color = m.theme.White
    end if
    if (m.lRating <> invalid)
        m.lRating.color = m.theme.White
    end if
end sub

sub OnFocusedChild()
    if m.top.hasFocus() then
        isRestored = RestoreFocus()
        if not isRestored
            SetFocus(m.pbplay)
        end if
    end if
end sub

sub OnPBPlayFocusedChild()
    if m.pbplay.hasFocus()
        m.pbplay.blendColor = m.theme.FocusedListBackground
    else
        m.pbplay.blendColor = m.theme.White
    end if
end sub

sub OnPBRestartFocusedChild()
    if m.pbrestart.hasFocus()
        m.pbrestart.blendColor = m.theme.FocusedListBackground
    else
        m.pbrestart.blendColor = m.theme.White
    end if
end sub

sub OnPBTrailerFocusedChild()
    if m.pbTrailer.hasFocus()
        m.pbTrailer.blendColor = m.theme.FocusedListBackground
    else
        m.pbTrailer.blendColor = m.theme.White
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    print "DetailsScreen OnkeyEvent : " key " " press
    handled = false
    if press then
        if key = "OK"
            if m.pbplay.hasFocus()
                m.scene.IsResumeVideo = true
                PlayMovieVideo()
                handled = true
            else if m.pbrestart.hasFocus()
                m.scene.IsStartFromBeginning = true
                PlayMovieVideo()
                handled = true
            else if m.pbTrailer.hasFocus()
                PlayMovieVideo(true)
                handled = true
            end if
        else if key = "right"
            if m.pbplay.hasFocus()
                if m.pbrestart.visible
                    SetFocus(m.pbrestart)
                else if m.pbTrailer.visible
                    SetFocus(m.pbTrailer)
                end if
                handled = true
            else if m.pbrestart.hasFocus()
                if m.pbTrailer.visible
                    SetFocus(m.pbTrailer)
                end if
                handled = true
            end if
        else if key = "left"
            if m.pbTrailer.hasFocus()
                if m.pbrestart.visible
                    SetFocus(m.pbrestart)
                else if m.pbplay.visible
                    SetFocus(m.pbplay)
                end if
                handled = true
            else if m.pbrestart.hasFocus() and m.pbplay.visible
                SetFocus(m.pbplay)
                handled = true
            end if
        else if key = "back"
            finishAnimation()
        else if key = "down"
            if m.pbplay.hasFocus()
                if m.rowList <> invalid
                    StartDownAnimation()
                    handled = true
                end if
            else if m.pbrestart.hasFocus()
                if m.rowList <> invalid
                    StartDownAnimation()
                    handled = true
                end if
            else if m.pbTrailer.visible and m.pbTrailer.hasFocus()
                if m.rowList <> invalid
                    StartDownAnimation()
                    handled = true
                end if
            end if
        else if key = "up"
            if m.rowList <> invalid and m.rowList.hasFocus() or m.rowList.IsInFocusChain()
                StartUpAnimation()
            end if
            handled = true
        end if
    end if
    return handled
end function
