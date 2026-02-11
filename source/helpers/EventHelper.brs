sub publishEvent(eventType as string, data as object)
    if (m.scene = invalid)
        m.scene = m.top.getScene()
    end if
    m.scene.event = {
        "type": eventType
        "data": data
    }
end sub

sub subscribeEvent(functionName as string)
    if (m.scene = invalid)
        m.scene = m.top.getScene()
    end if
    m.scene.observeField("event", functionName)
end sub

sub OnUpNextIndexChange(msg)
    eventData = msg.getData()
    if (eventData.type = "OnUpNextIndexChange")
        OnUpNextUpdate(eventData.data)
    end if
end sub

sub OnExclusiveLockGivePermission(msg)
    eventData = msg.getData()
    updateNode = GetObjectToUpdateLock()
    if (eventData.type = "exclusiveLockAction")
        if (updateNode.rowList <> invalid)
            UpdateRowList(updateNode.rowList, eventData.data)
        end if
        if (updateNode.markupGrid <> invalid)
            UpdateMarkupGrid(updateNode.markupGrid, eventData.data)
        end if
    end if
end sub

sub UpdateRowList(rowList, data)
    content = rowList.content
    for i = 0 to content.getChildCount() - 1 step 1
        rowContent = content.getChild(i)
        for j = 0 to rowContent.getChildCount() - 1 step 1
            itemData = rowContent.getChild(j)
            if (itemData.is_lock = true and data)
                itemData.is_lock = false
            else if (itemData.is_lock = false and not data)
                itemData.is_lock = true
            end if
        end for
    end for
end sub

sub UpdateMarkupGrid(markupGrid, data)
    content = markUpGrid.content
    for i = 0 to content.getChildCount() - 1 step 1
        itemData = content.getChild(i)
        if (itemData.is_lock = true and data)
            itemData.is_lock = false
        else if (itemData.is_lock = false and not data)
            itemData.is_lock = true
        end if
    end for
end sub