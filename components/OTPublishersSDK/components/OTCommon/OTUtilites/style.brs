function setColor(list, color) as object
    for each item in list
        item.color = color
    end for
end function

function setWidth(list, width) as object
    for each item in list
        item.width = width
    end for
end function

function setFont(list, font) as object
    for each item in list
        item.font = font
    end for
end function

function getNode()
    node = {
        font: function(uri as string, size as integer) 
            label = CreateObject("roSGNode", "Label")
            if uri.Instr("font:") <> -1 
                label.font = uri
            else 
                label.font.uri = uri
            end if
            label.font.size = size
            return label.font
        end function,
        label: function(id = "label" as string, text = "" as string, font = "font:MediumSystemFont" as dynamic, color = "0x000000" as dynamic, width = 0 as float) as dynamic
            label = CreateObject("roSGNode", "Label")
            label.id = id
            label.text = text
            label.font = font
            label.color = color
            label.width = width
            label.wrap = true
            return label
            end function,
        MultiStyleLabel: function(id = "MultiStyleLabel" as string, text = "" as string, width = 0 as float) as dynamic
            label = CreateObject("roSGNode", "MultiStyleLabel")
            label.id = id
            label.text = text
            label.width = width
            label.wrap = true
            return label
            end function,
        getMultiStyleLabel: function(id = "MultiStyleLabel" as string, isMultiStyleLabel = false, label = invalid, text = "" as string, drawingStyles = {}, width = 0 as float) as dynamic
            if not isValid(label)
                label = CreateObject("roSGNode", "Label")
                if isvalid(isMultiStyleLabel) and isMultiStyleLabel then label = CreateObject("roSGNode", "MultiStyleLabel")
                label.id = id
                label.text = text
                label.width = width
                label.wrap = true
            else
                if isValid(drawingStyles) and isValid(drawingStyles.default)
                    if isValid(label.font) then label.font = drawingStyles.default.fontUri
                    label.color = drawingStyles.default.color
                    if isvalid(isMultiStyleLabel) and isMultiStyleLabel and isValid(label.drawingStyles) then label.drawingStyles = drawingStyles
                end if
                label.text = text
                label.width = width
            end if
            return label
        end function,
        layoutGroup: function(id = "layoutGroup" as string, layoutDirection = "vert" as string, itemSpacings = [10] as dynamic,vertAlignment = "top" as string, horizAlignment = "left" as string)
            layoutGroup = CreateObject("roSGNode", "LayoutGroup")
            layoutGroup.id = id
            layoutGroup.layoutDirection = layoutDirection
            layoutGroup.vertAlignment = vertAlignment
            layoutGroup.horizAlignment = horizAlignment
            layoutGroup.itemSpacings = itemSpacings
            return layoutGroup
            end function,
        rectangle: function(id = "rectangle" as string, color = "0x000000" as dynamic, width = 0 as float, height = 0 as float)
            rectangle = CreateObject("roSGNode", "Rectangle")
            rectangle.id = id
            rectangle.color = color
            rectangle.width = width
            rectangle.height = height
            return rectangle
            end function
        animation: function(fieldToInterp as string, id = "rectangle" as string, duration = "0.5" as string, easeFunction = "linear" as string)
            animation = CreateObject("roSGNode", "Animation")
            animation.id = id
            animation.duration = duration
            animation.easeFunction = easeFunction
            animation.optional = true

            Vector2DFieldInterpolator = CreateObject("roSGNode", "Vector2DFieldInterpolator")
            Vector2DFieldInterpolator.id = id + "Interpolator"
            Vector2DFieldInterpolator.key = "[0.0, 1.0]"
            Vector2DFieldInterpolator.fieldToInterp = fieldToInterp

            animation.appendChild(Vector2DFieldInterpolator)
            return animation
        end function
    }

    return node
end function

