sub init()
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    SetControls()
    SetObservers()
end sub

sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
    m.top.itemComponentName = "SideMenuItem"
    m.top.vertFocusAnimationStyle="floatingFocus"
    m.top.itemSize = [384,84]
    m.top.drawFocusFeedback = false
    m.top.numColumns = 1
    m.top.numRows = 1
    m.top.itemSpacing = [0,5]
end sub

sub SetControls()
    m.scene = m.top.GetScene()
    m.itemFocusChangeTimer = m.top.findnode("ItemFocusChangeTimer")
end sub

sub SetupFonts()
end sub

sub SetupColors()
end sub

sub SetObservers()
    m.top.observeField("content", "OnContentChange")
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild","OnFocusedChild")
    ' m.top.observeField("itemFocused","onItemFocusedChanged")
    m.itemFocusChangeTimer.observeField("fire","OnItemFocusChanging")

    m.top.observeField("itemSelected","onItemSelectedChanged")
end sub

sub OnJumpToFirst()
    m.lastAnimatedItem = 0
    m.top.itemFocused = 0
    m.top.itemSelected = 0
    SetSelctedItem(m.lastAnimatedItem, m.lastAnimatedItem)
end sub

sub OnFocusedChild()
    if not m.top.hasFocus()
      UnSetFocusedItem()
    else
      SetSelctedItem(m.top.itemSelected, m.top.itemFocused)
    end if
end sub

sub OnContentChange(event as dynamic)
    content = event.getData()
    if content <> invalid
        m.top.numRows = content.getChildCount()
        m.top.rowHeights = getMarkUpGridRowHeights(content)
    end if
    m.lastAnimatedItem = 0
    m.top.itemFocused = 0
    m.top.itemSelected = 0
    SetSelctedItem(m.lastAnimatedItem, m.lastAnimatedItem)
end sub


function OnItemFocusChanging()
    key = m.top.lastKeyPress
    if m.top.longKeyPressed and key <> invalid
      ChangeFocusedItem(key)
    end if
end function

sub onItemSelectedChanged(event as dynamic)
    index = event.getData()
    SetSelctedItem(index, invalid)
end sub

function ChangeFocusedItem(key) as boolean
    focusedItem = m.lastAnimatedItem
    if key = "up"
        nextIndex = focusedItem - 1
    else
        nextIndex = focusedItem + 1
    end if
    if nextIndex >= 0 and nextIndex < m.top.content.getChildCount()
        SetSelctedItem(invalid, nextIndex)
        m.lastAnimatedItem = nextIndex
        m.itemFocusChangeTimer.control= "start"
    end if
end function

function SetSelctedItem(itemSelected as dynamic, itemFocused as dynamic)
    items = m.top.content
    for i=0 to items.getChildCount() - 1 step 1
        item = items.getChild(i)
        if itemSelected <> invalid
          if i = itemSelected
              item.isSelected = true
          else if item.isSelected
              item.isSelected = false
          end if
        end if
        if itemFocused <> invalid
          if i = itemFocused
              item.isFocused = true
          else if item.isFocused
              item.isFocused = false
          end if
        end if
    end for
end function

function UnSetFocusedItem()
    items = m.top.content
    for i=0 to items.getChildCount() - 1 step 1
        item = items.getChild(i)
        if item.isFocused
            item.isFocused = false
        end if
    end for
end function

function getMarkUpGridRowHeights(content)
    rowHeights = []
    for i=0 to content.getChildCount() - 1 step 1
        item = content.getChild(i)
        if item.is_show_separate <> invalid and item.is_show_separate
            rowHeights.push(103)
        else
            rowHeights.push(84)
        end if
    end for
  return rowHeights
end function


'------------KeyeventHandle----------------------
function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    isScrolling = press and (key = "up" or key = "down")
    ' print "SideMenuComponent : onKeyEvent : key = " key " press = " press
    if press then
      if key = "OK"
          m.top.itemSelected = m.top.itemFocused
          handled = true
      end if
    end if
    if isScrolling then
        handled = ChangeFocusedItem(key)
        m.top.lastKeyPress = key
        m.top.longKeyPressed = true
    else
        m.itemFocusChangeTimer.control = "stop"
        m.top.lastKeyPress = invalid
        m.top.longKeyPressed = false
        m.top.itemFocused = m.lastAnimatedItem
    end if
    return handled
end function
