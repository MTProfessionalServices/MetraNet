set XmlTrans = CreateObject("XmlTranslator.clsXmlTranslator")
call XmlTrans.TranslateWithXmlFile(wscript.arguments(0),wscript.arguments(1))
