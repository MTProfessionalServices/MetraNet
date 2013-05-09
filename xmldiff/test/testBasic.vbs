Set XmlDiff = CreateObject("XmlDiffTool.XmlDiff")
Call XmlDiff.Init("1.0.0.55","Carl Shimer")
Call XmlDiff.GenDiffXml("D:\metratech\development\core\configuration\xmldiff\test\test1.xml","D:\metratech\development\core\configuration\xmldiff\test\test2.xml","D:\metratech\development\core\configuration\xmldiff\test\test3.xml")