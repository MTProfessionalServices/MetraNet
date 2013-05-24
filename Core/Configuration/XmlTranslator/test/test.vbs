set XmlTrans = CreateObject("XmlTranslator.clsXmlTranslator")
call XmlTrans.TranslateToLatestVersion(wscript.arguments(0),_ 
	wscript.arguments(1),_ 
	wscript.arguments(2)) 