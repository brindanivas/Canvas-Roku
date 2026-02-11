
sub init()
    m.top.id = "UpdateProgressTask"
end sub

sub UpdateProgress()
    if m.rowList <> invalid
        for i = 0 to m.rowList.playlistContent.getChildCount() - 1 step 1
            rowData = m.rowList.playlistContent.getChild(i)
            if rowData.program_type <> "event" or rowData.program_type <> "events"
                for j = 0 to m.rowList.playlistContent.getChild(i).getChildCount() - 1 step 1
                    itemData = m.rowList.playlistContent.getChild(i).getChild(j)
                    if itemData.playList_program_type <> "event" or itemData.playList_program_type <> "events"
                        if itemData.currentDateTimeSecond
                            itemData.currentDateTimeSecond = false
                        else
                            itemData.currentDateTimeSecond = true
                        end if
                    end if
                end for
            end if
        end for
    end if
end sub


sub UpdateProgressDynamicGrid()
    if m.rowList <> invalid
        for i = 0 to m.rowList.playlistContent.getChildCount() - 1 step 1
            for j = 0 to m.rowList.playlistContent.getChild(i).getChildCount() - 1 step 1
                itemData = m.rowList.playlistContent.getChild(i).getChild(j)
                if itemData.currentDateTimeSecond
                    itemData.currentDateTimeSecond = false
                else
                    itemData.currentDateTimeSecond = true
                end if
            end for
        end for
    end if
    if m.markUpGrid <> invalid and m.markUpGrid.playlistContent <> invalid
        for i = 0 to m.markUpGrid.playlistContent.getChildCount() - 1 step 1
            itemData = m.markUpGrid.playlistContent.getChild(i)
            if itemData.currentDateTimeSecond
                itemData.currentDateTimeSecond = false
            else
                itemData.currentDateTimeSecond = true
            end if
        end for
    end if
end sub

