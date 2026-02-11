function CreateRegistryManager() as object
    instance = {

        SaveUserInfo: sub(userInfo as object)
            reg = CreateObject("roRegistrySection", "HBCUSettings")
            userInfoJson = FormatJson(userInfo)
            reg.Write("userInfo",userInfoJson)
            reg.Flush()
        end sub,
        GetUserInfo: function() as object
            reg = CreateObject("roRegistrySection", "HBCUSettings")
            readValues = reg.Read("userInfo")
            userInfo = ParseJson(readValues)
            return userInfo
        end function,
        ClearUserInfo: sub()
            reg = CreateObject("roRegistrySection", "HBCUSettings")
            reg.Delete("userInfo")
            reg.Flush()
        end sub,

        RegRead: function(key, section=invalid)
            if section = invalid then section = "Default"
            sec = CreateObject("roRegistrySection", section)
            if sec.Exists(key) then return sec.Read(key)
            return invalid
        end function

        RegWrite: function(key, val, section=invalid)
            if section = invalid then section = "Default"
            sec = CreateObject("roRegistrySection", section)
            sec.Write(key, val)
            sec.Flush()
        end function

        RegDelete: sub(key, section=invalid)
            if section = invalid then section = "Default"
            sec = CreateObject("roRegistrySection", section)
            if sec.Exists(key)
              print "delete reg "key
              sec.Delete(key)
            end if
            sec.Flush()
        end sub

        ClearAllSettings: sub()
            Registry = CreateObject("roRegistry")

            for each section in Registry.GetSectionList()
                RegistrySection = CreateObject("roRegistrySection", section)
                for each key in RegistrySection.GetKeyList()
                    print "RegistryManager : ClearAllSettings : Deleting : Section : " + section + "Key : " key
                    RegistrySection.Delete(key)
                end for
                Registry.Delete(section)
                RegistrySection.flush()
            end for
        end sub
    }

    return instance
end function
