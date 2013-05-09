Set XmlDiff = CreateObject("XmlDiffTool.XmlDiff")
Call XmlDiff.Init("1.0.0.55","test3.xml","Carl Shimer")
Call XmlDiff.GenMergedfile("D:\metratech\development\core\configuration\xmldiff\test\pipe3.xml","D:\metratech\development\core\configuration\xmldiff\test\pipe4.xml",true,true,true)