sub init()
    SetLocals()
    SetControls()
    SetupFonts()
    SetupColors()
    Initialize()
    SetObservers()
end sub


sub SetLocals()
    m.theme = m.global.appTheme
    m.fonts = m.global.fonts
end sub

sub SetControls()
    m.scene = m.top.GetScene()
    m.test = m.top.findnode("test")
    m.VectorTranAnimation = m.top.findnode("VectorTranAnimation")
    m.itemFocusChangeTimer = m.top.findnode("ItemFocusChangeTimer")
    m.TranAnimation = m.top.findnode("TranAnimation")
    m.focusIndicator = m.top.findnode("focusIndicator")
end sub

sub SetupFonts()
  m.test.font = m.fonts.robotoMed30
end sub

sub SetupColors()
  m.focusIndicator.color = m.theme.ThemeColor
end sub

sub Initialize()
  m.top.itemComponentName="MenuItem"
  m.top.numRows=1
  m.top.variableWidthItems=[true]
  m.top.rowFocusAnimationStyle="fixedFocusWrap"
  m.top.vertFocusAnimationStyle="floatingFocus"
  m.top.drawFocusFeedback=false
  m.itemSpacing = 60
  m.iconWidth = 44
  m.top.rowItemSize = [[55, 40]]
  m.top.rowItemSpacing = [[m.itemSpacing,0]]
  m.totalMenuWidth = 0
  m.lastSelectedItem = 0
end sub

sub SetObservers()
    m.top.observeField("visible", "OnVisibleChange")
    m.top.observeField("focusedChild","OnFocusedChild")
    m.top.observeField("rowitemFocused", "onItemFocusedChanged")
    m.TranAnimation.observeField("state", "OnTransAnimationStateChange")
    m.top.observeField("longKeyPressed", "OnLongKeyPressing")
    m.itemFocusChangeTimer.observeField("fire","OnItemFocusChanging")
end sub


sub OnVisibleChange(event as dynamic)
    isVisible = event.getData()
    print "CustomMenuList : OnVisibleChange : isVisible : " isVisible
end sub

sub OnFocusedChild()
  if m.top.hasFocus() and m.top.isInFocusChain() then
    m.focusIndicator.visible = true
    m.top.rowitemFocused = m.lastAnimatedItem
  else
    m.focusIndicator.visible = false
  end if
end sub

function OnCustomRowItemFocusChange(event as object)
    focusedItem = event.getData()
    if focusedItem <> invalid and m.menuPositions <> invalid
        m.lastAnimatedItem = focusedItem
        m.focusIndicator.translation = [m.menuPositions[m.lastAnimatedItem[1]], m.top.MenuFocusedYPos]
        m.top.rowitemFocused = m.lastAnimatedItem
    end if
end function

Function OnMenuItemChange(event as object)
    items = event.getdata()
    if items.count() > 0
         SetContent(items)
    else
        if m.top.content <> invalid
            m.top.content.setfields({"content":invalid})
        end if
        m.top.visible = false
    end if
End Function

function SetContent(items)
    if  m.top.content = invalid or m.top.content.getChildCount() = 0 then
      m.lastAnimatedItem = [0,0]
    end if
    m.top.content = invalid
    m.menuPositions = CreateObject("roArray",0,true)
    m.menuSize = CreateObject("roArray",0,true)
    content = createObject("roSGNode", "ContentNode")
    row  = createObject("roSGNode", "ContentNode")
    counter = 0
    m.prevWidth = 0
    SetLowestMenuitemSize(items)
    if  items[0].Title <> invalid
        for each item in items
            if LCase(item.playlist_layout) <> "settings" or (LCase(item.playlist_layout) = "settings" and item.settings <> invalid and item.settings.count() > 0)
                child = createObject("roSGNode", "ContentNode")
                if item.Title <> invalid and item.Title <> ""
                    child.title = item.Title
                end if
                ' child.id = item.ID
                child.AddFields(item)
                child.Addfields({"FHDItemWidth": 0.0, "type":"rowlist","isSelected":false})
                AddMenuItemPostion(child, child.title, counter)
                if counter = 0 then
                    if m.top.SetFirstItemSelected
                        child.isSelected = true
                    end if
                    m.top.removeSelectedFocus = false
                end if
                row.appendchild(child)
                counter++
            end if
        end for
        content.appendchild(row)
        ' m.focusIndicator.width = m.menuSize[0]
        m.focusIndicator.translation = [m.menuPositions[m.lastAnimatedItem[1]], m.top.MenuFocusedYPos]
    end if
    m.top.itemSize = [m.totalMenuWidth, 55]
    m.top.content = content
end function

sub SetLowestMenuitemSize(items as object)
    setHeight = true
    m.totalMenuWidth = 0
    if items[0].Title <> invalid
        for each item in items
            m.test.text = ""
            if item.Title <> invalid
                m.test.text = item.Title
            end if
            if m.test.text <> ""
                textBoundingRect = m.test.boundingRect()
                textWidth = textBoundingRect.width
            else
                textWidth = m.iconWidth
            end if
            m.totalMenuWidth += textWidth
            m.totalMenuWidth += m.itemSpacing
            if setHeight then
              m.top.MenuFocusedYPos = 144 - 60 'textBoundingRect.height + 13
              setHeight = false
            end if
        end for
        m.totalMenuWidth = m.totalMenuWidth - m.itemSpacing
        m.top.totalWidth = m.totalMenuWidth
    end if
end sub

function AddMenuItemPostion(child as object, title as string, counter as integer)
  if title <> ""
      m.test.text = title
      m.test.font = m.fonts.robotoMed30
      textWidth = m.test.boundingRect().width
  else
      textWidth = m.iconWidth
  end if
  child.Update({FHDItemWidth: textWidth}, true)
  if counter = 0
    xPos = (textWidth - m.top.MenuFocusedWidth) / 2
    focuseIndicatorPos = xPos
    m.prevWidth = textWidth + m.itemSpacing
  else
    xPos = (textWidth - m.top.MenuFocusedWidth) / 2
    focuseIndicatorPos = m.prevWidth + xPos
    m.prevWidth = m.prevWidth + textWidth + m.itemSpacing
  end if

  m.menuPositions.push(focuseIndicatorPos)
  m.menuSize.push(textWidth)
end function


function onItemFocusedChanged()
    if m.lastAnimatedItem = invalid then m.lastAnimatedItem = [0,0]
    if m.lastAnimatedItem[1] <> m.top.rowitemFocused[1]
      m.top.rowitemFocused = m.lastAnimatedItem
    end if
    if m.TranAnimation.state = "running"
      m.TranAnimation.control = "finish"
    end if
end function

function onItemSelectedChanged()
    if m.lastAnimatedItem = invalid then m.lastAnimatedItem = [0,0]
    if m.top.rowItemSelected.count() <> 2 then
        SetSelctedItem(m.lastAnimatedItem)
        m.top.customRowItemSelected = m.lastAnimatedItem
    else if m.lastAnimatedItem[1] <> m.top.customRowItemSelected[1] then
        SetSelctedItem(m.lastAnimatedItem)
        m.top.customRowItemSelected = m.lastAnimatedItem
    end if
end function

function SetSelctedItem(itemSelected as dynamic)
    items = m.top.content.getChild(0)
    for i=0 to items.getChildCount() - 1 step 1
        menuItem = items.getChild(i)
        if i = itemSelected[1]
            menuItem.isSelected = true
            m.top.removeSelectedFocus = false
        else if menuItem.isSelected
            menuItem.isSelected = false
        end if
    end for
end function

function StartAnimation(startPos, endPos)
      xPosStart = m.menuPositions[startPos]
      xPosEnd = m.menuPositions[endPos]
      ' currentSize = m.menuSize[startPos]
      ' nextSize = m.menuSize[endPos]
      m.lastAnimatedItem = [0,endPos]
      m.VectorTranAnimation.keyValue = [[xPosStart, m.top.MenuFocusedYPos], [xPosEnd, m.top.MenuFocusedYPos]]
      ' m.FloatFieldInterpolator.keyValue = [currentSize, nextSize]
      m.TranAnimation.control = "start"
end function

function OnTransAnimationStateChange(event as dynamic)
    state = event.getData()
    if state = "stopped"
      m.itemFocusChangeTimer.control= "start"
    end if
end function

'
function OnItemFocusChanging()
    key = m.top.lastKeyPress
    if m.top.longKeyPressed and key <> invalid
      result = ChangeFocusedItem(key)
      if not result then m.top.keyPress = { "key": key, "longPress" : true}
    else
      m.top.rowitemFocused = m.lastAnimatedItem
    end if
end function

function OnRemoveSelectedFocus()
    if m.top.removeSelectedFocus
        items = m.top.content.getChild(0)
        for i=0 to items.getChildCount() - 1 step 1
            menuItem = items.getChild(i)
            menuItem.isSelected = false
        end for
    end if
end function

function ChangeFocusedItem(key) as boolean
    result = false
    focusedItem = m.lastAnimatedItem[1]
    if key = "left"
        nextIndex = focusedItem - 1
    else
        nextIndex = focusedItem + 1
    end if
    if m.top.MenuItems <> invalid and nextIndex >= 0 and nextIndex < m.top.MenuItems.count()
      StartAnimation(focusedItem, nextIndex)
      result = true
    end if
    return result
end function

function OnOutSidekeyPass(event as dynamic)
    key = event.getData()
    onKeyEvent(key, true)
end function

'------------KeyeventHandle----------------------
function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    print "CustomMenuList onKeyEvent "m.top.id " "key " "press
    isScrolling = press and (key = "left" or key = "right")
    if press then
      if key = "OK"
        onItemSelectedChanged()
        return true
      end if
    end if
    if isScrolling then
        result = ChangeFocusedItem(key)
        if not result then m.top.keyPress = { "key": key, "longPress" : false}
        m.top.lastKeyPress = key
        m.top.longKeyPressed = true
        handled = true
    else
        if m.top.longKeyPressed = true and m.top.lastKeyPress <> invalid and m.TranAnimation.state <> "running"
          m.top.lastKeyPress = invalid
          m.top.longKeyPressed = false
          m.top.rowitemFocused = m.lastAnimatedItem
        else
          m.top.lastKeyPress = invalid
          m.top.longKeyPressed = false
        end if
    end if
    return handled
end function
