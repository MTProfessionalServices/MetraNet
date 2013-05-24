set filesys = CreateObject("Scripting.FileSystemObject")
Set wshshell = WScript.CreateObject("WScript.Shell")


Function VerifyVDir(dirName, siteNum)
	Set vdir = GetObject("IIS://localhost/W3SVC/" & siteNum & "/ROOT/" & dirName)
	if not vdir.AppIsolated then
		wscript.echo dirName & " virtual directory must be marked as " & _
			"""run in separate memory space "" in site " & siteNum
		VerifyVDir = false
	else
		VerifyVDir = true
	end if
End Function


Sub VerifySite(InstanceName, siteNum)
	VerifyVDir "msix", siteNum
	VerifyVDir "mps", siteNum
	VerifyVDir "mt", siteNum

	' MPS sites
	Set defaultRoot = GetObject("IIS://LocalHost/W3SVC/1/ROOT")
	for each dir in defaultRoot
		if dir.Class = "IIsWebVirtualDir" then
			if dir.Name <> "mtinclude" _
					and InStr(dir.Path, "sites") then

				VerifyVDir dir.Name, siteNum
			end if
		end if
	next
end sub


Sub Main()
	VerifySite("", 1)
End Sub


Main
