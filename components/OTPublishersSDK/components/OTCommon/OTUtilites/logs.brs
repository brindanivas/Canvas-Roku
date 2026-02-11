function logUtil()
    logger = {
        set: function(errortype as string, tag as string, msg as dynamic, addMsg = "" as dynamic)
           ' date = CreateObject("roDateTime").ToISOString()
            Print " ["; errortype;".";tag; "] |"; msg; addMsg
        end function
        error: sub(e) 
            try
            errortype = "error"
            tag = ""
            if e.message <> invalid then tag = e.message
            print " ["; errortype;".";tag; "] |"; FormatJson(e)
            catch e
                print FormatJson(e)
            end try
        end sub 
    }
    return logger
end function

