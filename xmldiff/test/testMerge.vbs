Set XmlDiff = CreateObject("XmlDiffTool.XmlDiff")
Call XmlDiff.Init("1.0.0.55","Carl Shimer")
Call XmlDiff.MergeXML(wscript.arguments(0),wscript.arguments(1),wscript.arguments(2),"Carl","")
set XmlDiff = nothing