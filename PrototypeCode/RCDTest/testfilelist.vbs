option explicit

Dim aFileobj,file
set aFileObj = CreateObject("MetraTech.RcdFileList.1")

aFileObj.AddFile("foo")
aFileObj.AddFile("bar")

for each file in aFileObj
	wscript.echo file
next