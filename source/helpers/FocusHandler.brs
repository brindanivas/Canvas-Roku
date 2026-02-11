sub SetFocus(component as dynamic)
    m.focusedItem = component
    m.focusedItem.setFocus(true)
end sub

function RestoreFocus() as boolean
    focusRestored = false
    if (m.focusedItem <> invalid)
        m.focusedItem.setFocus(true)
        focusRestored = true
    end if
    return focusRestored
end function

sub ResetFocus()
    if (m.focusedItem <> invalid)
        m.focusedItem = invalid
    end if
end sub
