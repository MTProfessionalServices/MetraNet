Set XmlDiff = CreateObject("XmlDiffTool.XmlDiff")
Call XmlDiff.Init("1.0.0.55","Carl Shimer")
Call XmlDiff.MergeXML("D:\metratech\development\core\configuration\xmldiff\test\basic1.xml","D:\metratech\development\core\configuration\xmldiff\test\basic2.xml","D:\metratech\development\core\configuration\xmldiff\test\basic3.xml","","ed62f6f0-da56-11d3-a611-00c04f579c39")