
function updatelazyloadingListView()
    if m.top <> invalid
        data = m.top.data
        if data <> invalid and data.data <> invalid and data.data.getChildCount() > 0
            endItemIndex = data.data.getChildCount() - 1
            for i = data.startItemIndex to endItemIndex
                item = CreateObject("roSGNode", data.top.itemComponentName)
                item.width = data.top.width
                item.itemContent = data.data.getChild(i)
                if item <> invalid then data.view.appendChild(item)
            end for
        end if
        if m.top.complete <> invalid then m.top.complete = true
    end if
end function
