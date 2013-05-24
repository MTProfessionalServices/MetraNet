dim lc
Set lc = CreateObject("Metratech.LocaleConfig")
lc.Initialize("core")
lc.LoadLanguage("de")
wscript.echo lc.GetLocalizedString("metratech.com/audioconfcall/ConferenceID", "de")
lc.LoadLanguage("US")
wscript.echo lc.GetLocalizedString("metratech.com/audioconfcall/ConferenceID", "US")