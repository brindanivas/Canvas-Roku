sub say(stext as string, role = "" as string, role2 = "" as string, flushSpeech = false as boolean, role3 = "" as string, role4 = "" as string)
    if isValid(m.roAudioGuide) and isString(stext)
        if flushSpeech then m.roAudioGuide.Flush()
         if isString(role) then m.roAudioGuide.say(role, false, false)
         m.roAudioGuide.say(stext, false, false)
         if isString(role2) then m.roAudioGuide.say(role2, false, false)
         if isValid(role3) then m.roAudioGuide.say(role3, false, false)
         if isValid(role4) then m.roAudioGuide.say(role4, false, false)
    end if
end sub

sub sayPoster(node)
    if isValid(node) and isString(node["audioGuideText"]) then say(node["audioGuideText"])
end sub

sub sayText(node, role = "", visible = false as boolean, role2 = "", flushSpeech = false as boolean)
    if isValid(node) and isString(node.text) and ((isValid(node.visible) and node.visible) or visible) and isValid(role) then say(node.text, role, role2, flushSpeech)
end sub

sub sayLayout(node, role, role2 = "", flushSpeech = false as boolean)
    if isValid(node)
        nodeChildren = node.getChildren(-1, 0)
        if isArray(nodeChildren)
            for each item in nodeChildren
                tempRole = role
                if item.id = "dpdTitle" or (item.id.Instr("_Header") <> -1 and item.id.Instr("_Sub_Header") = -1 and item.id <> "cookieMaxAgeSeconds_Header") then tempRole = m.WCAGRoles.headingAriaLabel
                iscontinue = true
                if item.id = "buttonLayout"
                    btext = item.getChild(0)
                    subtext = item.getChild(1)
                    if isvalid(subtext) and subtext.id = "statusText" and subtext.visible
                        iscontinue = false
                        sayText(btext, tempRole, false, "", flushSpeech)
                        sayText(subtext, "", false, role2, false)
                    end if
                end if
                if iscontinue
                    if item.id.Instr("_bullet") <> -1
                        say(m.WCAGRoles.listItemAriaLabel, role, role2, flushSpeech)
                    else
                        sayText(item, tempRole, false, role2, flushSpeech)
                    end if
                    sayLayout(item, role, role2, flushSpeech)
                end if

            end for
        end if
    end if
end sub

sub saylist(node, role)
    if isValid(node)
        nodeChildren = node.content.getChildren(-1, 0)
        if isArray(nodeChildren)
            for each item in nodeChildren
                if isValid(item.id) and isValid(item.Btype) and item.Btype <> "circleBtn" then sayText(item, role, true)
            end for
        end if
    end if
end sub

sub sayFocused(node, role, role2)
if isValid(node) and isValid(node.content) and isValid(node.itemFocused)
    item = node.content.getChild(node.itemFocused)
    say(item.text, role, role2)
end if
end sub

sub saySelected(node, role, flushSpeech = false)
    if isValid(node) and isValid(node.content) and isValid(node.itemFocused)
        Mcount = node.content.getChildCount()
        itemFocused = node.itemFocused + 1
        item = node.content.getChild(node.itemFocused)
        if isvalid(item)
            text = item.text
            if node.id = "OTPurposeChildButtons"
                if item.status = 1 and isValid(item.activeTextNode)
                    text += " " + item.activeTextNode.text
                end if
                if item.status = 0 and isValid(item.inActiveTextNode)
                    text += " " + item.inActiveTextNode.text
                end if
            end if
            role2 = m.WCAGRoles.button + " " + itemFocused.toStr() + " of " + Mcount.toStr() + " " + m.WCAGRoles.selectedAriaLabel
            say(text, role, role2, flushSpeech)
        end if
    end if
end sub