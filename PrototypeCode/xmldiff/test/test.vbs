Set XmlDiff = CreateObject("XmlDiffTool.XmlDiff")
Call XmlDiff.Init("1.0.0.55","test3.xml","Carl Shimer")
Call XmlDiff.GenDiffXml("D:\metratech\development\core\configuration\xmldiff\test\pipe1.xml","D:\metratech\development\core\configuration\xmldiff\test\pipe2.xml","D:\metratech\development\core\configuration\xmldiff\test\pipe3.xml")
XmlDiff = nothing