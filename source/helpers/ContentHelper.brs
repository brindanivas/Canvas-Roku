function ContentHelpers() as object
    this = {}

    this.oneDimSingleItem2ContentNode = function(item as object, node_type as string)
        content = CreateObject("roSGNode", node_type)
        for each key in item
            trimmedKey = key.trim()
            if content[trimmedKey] <> invalid
                content[trimmedKey] = item[key]
                if trimmedKey = "isExclusiveContent"
                    content[trimmedKey] = false
                else
                    content[trimmedKey] = item[key]
                end if
            end if
        end for
        return content
    end function

    this.oneDimSingleItem2AssocArray = function(item as object, node_type as string)
        content = CreateObject("roSGNode", node_type)
        assocArray = {}
        for each key in item
            trimmedKey = key.trim()
            if content[trimmedKey] <> invalid
                assocArray[trimmedKey] = item[key]
            end if
        end for
        return assocArray
    end function

    return this
end function
