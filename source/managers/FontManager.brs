function CreateFontManager() as Object
    print "FontManager : CreateFontManager"

    robotoBold = "pkg:/Fonts/Roboto-Bold.ttf"
    robotoReg = "pkg:/Fonts/Roboto-Regular.ttf"
    robotoMed = "pkg:/Fonts/Roboto-Medium.ttf"

    this = {}

    ' *** Roboto Bold Fonts ***
    this.robotoBold72 = CreateFonts(robotoBold, 72)
    this.robotoBold32 = CreateFonts(robotoBold, 32)
    this.robotoBold30 = CreateFonts(robotoBold, 30)
    this.robotoBold26 = CreateFonts(robotoBold, 26)
    this.robotoBold22 = CreateFonts(robotoBold, 22)

    ' *** Roboto Medium Fonts ***
    this.robotoMed18 = CreateFonts(robotoMed, 18)
    this.robotoMed20 = CreateFonts(robotoMed, 20)
    this.robotoMed24 = CreateFonts(robotoMed, 24)
    this.robotoMed26 = CreateFonts(robotoMed, 26)
    this.robotoMed30 = CreateFonts(robotoMed, 30)
    this.robotoMed66 = CreateFonts(robotoMed, 66)

    ' *** Roboto Regular Fonts ***
    this.robotoReg20 = CreateFonts(robotoReg, 20)
    this.robotoReg22 = CreateFonts(robotoReg, 22)
    this.robotoReg24 = CreateFonts(robotoReg, 24)
    this.robotoReg28 = CreateFonts(robotoReg, 28)
    this.robotoReg30 = CreateFonts(robotoReg, 30)
    this.robotoReg32 = CreateFonts(robotoReg, 32)
    this.robotoReg36 = CreateFonts(robotoReg, 36)
    this.robotoReg42 = CreateFonts(robotoReg, 42)
    this.robotoReg66 = CreateFonts(robotoReg, 66)



    node = CreateObject("roSGNode", "node")
    node.addfields(this)
    return node
end function

function CreateFonts(uri as string, size as integer) as dynamic
    font = CreateObject("roSGNode", "Font")
    font.uri = uri
    font.size = size
    return font
end function
