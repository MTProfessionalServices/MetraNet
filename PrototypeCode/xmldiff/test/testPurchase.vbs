Set XmlDiff = CreateObject("XmlDiffTool.XmlDiff")
Call XmlDiff.Init("1.0.0.55","Carl Shimer")
Call XmlDiff.MergeXML("D:\metratech\development\core\configuration\xmldiff\test\purchase1.xml","D:\metratech\development\core\configuration\xmldiff\test\purchase2.xml","D:\metratech\development\core\configuration\xmldiff\test\purchase3.xml","Carl","")