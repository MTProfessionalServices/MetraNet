On Error goto 0
Set XmlDiff = CreateObject("XmlDiffTool.XmlDiff")
Call XmlDiff.Init("1.0.0.55","Carl Shimer")
Call XmlDiff.UnMergeByOwner(wscript.arguments(0),wscript.arguments(1),"__mtbase__",wscript.arguments(2))
set XmlDiff = nothing